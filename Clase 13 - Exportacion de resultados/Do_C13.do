*****************************************************
** Universidad de los Andes - Facultad de Economía **
** 			   		Taller de Stata                **
**												   **
** 				Miguel Garzón-Ramírez              **
** 			   Cristhian Acosta-Pardo              **
** 			   						               **
** 	  	  Clase 13:  Exportando Resultados         **
*****************************************************

clear all  
cap log close
set more off, perm 
cd "_____" // Coloque entre las comillas la dirección completa de la carpeta donde están los datos. 
*sysdir set PLUS "cd"

*-------------------------------------------------------------------*
*I. Exportación de Tablas de Frecuencias y Estadísticas Descriptivas*
*-------------------------------------------------------------------*
use "clase13_a", clear
drop if missing(erosion, altura)  // otra forma: drop if erosion==. | altura==.
** Tablas con información por departamentos

** 1. Export excel
* Exportar tablas de frecuencias
tab coddepto, m
preserve
	contract coddepto, freq(Freq) percent(Percent) cpercent(Cum)
	export excel "Tabla_dpto.xlsx", firstrow(variables) sheet("Frecuencias", replace)
restore
* Exportar estadísticas descriptivas
preserve
	#d ;
	 collapse 	(mean) meanaltura=altura  meanerosion=erosion 
				(sd) sdaltura=altura  sderosion=erosion
				(max) maxaltura=altura  maxerosion=erosion
				(min) minaltura=altura  minerosion=erosion,
				by(coddepto)
				 ;
	#d cr
	reshape long mean sd max min, i(coddepto) j(variable) string
	order var coddepto mean sd min max
	export delimited using "Tabla_dpto.txt", replace
	export excel "Tabla_dpto.xlsx", firstrow(variables) sheet("Descriptivas", replace)
restore
		
** 2. Tabout
ssc install tabout, replace // Revisar anexo de la Clase 12, comandos UWS
tab coddepto, m
* Exportar tablas de frecuencias
tabout coddepto using "Tabla_dpto_frec.xls", replace // sin editar
tabout coddepto using "Tabla_dpto_frec.xls", replace cells(freq cell cum) clab(Freq Percent Cum)

* Exportar estadísticas descriptivas
tabout coddepto using "Tabla_dpto_desc.xls", replace sum cells(mean erosion max erosion min erosion sd erosion) clab(Media Maximo Minimo Sd) f(3 3 3 3)
tabout coddepto using "Tabla_dpto_desc.xls", append sum c(mean altura max altura min altura sd altura) clab(Media Maximo Minimo Sd) f(4 4 4 4)

** 3. Asdoc
ssc install asdoc, replace
tab coddepto, m
* Exportar tablas de frecuencias
cap drop coddepto_n
encode coddepto, gen(coddepto_n) // asdoc tiene problemas tabulando variables con caracteres
asdoc tabulate coddepto_n, m save(tabla_depto_frec) replace
* Exportar estadísticas descriptivas
asdoc tabstat altura erosion, by(coddepto) stat(N mean max min sd) col(stat) save(tabla_depto_desc) replace

tabstat altura erosion, by(coddepto) stat(N mean max min sd)  col(stat) 

** 4. Putexcel
* Exportar un tabstat 
tabstat altura erosion, stat(N mean max min sd) col(stat) save
return list
matrix tabs=r(StatTotal)
matlist tabs

putexcel set Tabla_put_excel_tabstat.xlsx, sheet(Nacional, replace) modify
putexcel A2=matrix(tabs), names nformat(number_d2)

* Exportar estadísticas descriptivas seleccionadas
putexcel set Tabla_put_excel_s.xlsx, sheet(Nacional, replace) modify
putexcel A1=("Variable") 
putexcel B1=("N") 
putexcel C1=("Mean") D1=("SD") E1=("Min") F1=("Max") // nombres de columnas 
putexcel A2=("altura") A3=("erosion") // nombres de filas

local row = 1
foreach y of varlist altura erosion {
qui: sum `y'
local ++row
	putexcel B`row' = (r(N))
	putexcel C`row' = (r(mean))
	putexcel D`row' = (r(sd))
	putexcel E`row' = (r(min))
	putexcel F`row' = (r(max))
}

* Exportar estadísticas descriptivas por departamentos, uno en cada hoja
levelsof coddepto, local(deptos)
foreach y of local deptos{
	putexcel set Tabla_put_excel_s.xlsx, sheet(`y') modify
	putexcel A1=("Variable") B1=("N") C1=("Mean") D1=("SD") E1=("Min") F1=("Max")
	putexcel A2=("altura") A3=("erosion") // nombres de filas

	tokenize A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
	local row = 2
	foreach var of varlist altura erosion{
	qui: sum `var' if coddepto == "`y'" 
	local col =2
		foreach stat in r(N) r(mean) r(sd) r(min) r(max){
			putexcel ``col''`row' = (`stat')
			local ++col
		}  
	local ++row
	}
}

*-------------------------------------------------------*		
*II. Exportación de Tablas de Regresiones y Estimaciones*
*-------------------------------------------------------*
use "clase13_b", clear
** 1. asdoc
*A Regresiones completas
asdoc reg razmatss ingresos educa_pa, save(reg_asdoc) replace
asdoc reg razmatss ingresos educa_pa personas orden_n, append save(reg_asdoc)

*B Regresiones compactas
asdoc reg razmatss ingresos educa_pa, nested save(reg_asdoc_comp) replace
asdoc reg razmatss ingresos educa_pa personas orden_n, nested append save(reg_asdoc_comp)

*C Regresiones por categorías
bys age_nihf: asdoc reg razmatss ingresos educa_pa personas orden_n, nested save(reg_asdoc_comp_age) replace

** 2. outreg2
ssc install outreg2, replace
*A. Sintaxis*
*a. Opción 1*
reg razmatss ingresos educa_pa personas orden_n
outreg2 using "regresiones1.doc"
outreg2 using "regresiones1.xls"
*b. Opción 2*
reg razmatss ingresos educa_pa personas orden_n
estimates store regresion2
outreg2 [regresion2] using "regresiones2.doc", see replace

*B. Outreg2 al interior de un loop*

forvalues  i=4(1)6{
	reg razmatss ingresos educa_pa personas orden_n if age_nihf==`i'
	if age_nihf==4 outreg2 using "regresiones_loop1.doc", replace
	outreg2 using "regresiones_loop1.doc"
}

*C. Posiciones decimales*
outreg2 [regresion2] using "regresiones_dec.doc", dec(8) replace
outreg2 [regresion2] using "regresiones_dec.doc", bdec(5) sdec(1)

*D. Niveles de significancia
*a. Reportando ? para alpha=0.01 y + para alpha=0.05*
outreg2 [regresion2] using "regresiones_sign.doc", bdec(5) sdec(1) replace 
outreg2 [regresion2] using "regresiones_sign.doc", bdec(5) sdec(1) alpha(0.01, 0.05) symbol(?, +)
 
*b. No reportar símbolos para variables significativas*
outreg2 [regresion2] using "regresiones_sign.doc", noaster

*E. Estadísticas
*a. Estadístico t en vez de error estándar*
outreg2 [regresion2] using "regresiones_est.doc", replace stats(coef tstat)

*b. Estadísticas adicionales*
outreg2 [regresion2] using "regresiones_est.doc", stats(coef tstat pval N)

*c. Paréntesis y paréntesis cuadrados.
outreg2 [regresion2] using "regresiones_est.doc", stats(coef se tstat N) bracket(tstat) paren(se N)
outreg2 [regresion2] using "regresiones_est.doc", addstat(Adj, e(F)) bracket
			
*F. Títulos y notas
forvalues  i=3(1)6{
	reg razmatss ingresos educa_pa personas orden_n if age_nihf==`i'
	if age_nihf==4 outreg2 using "regresiones_loop1.doc", replace title(Desarrollo cognitivo) ctitle("Edad: `i'") addnote(Fuente: HCB)
	outreg2 using "regresiones_title.doc", title(Desarrollo cognitivo) ctitle("Edad: `i'") addnote(Fuente: HCB)
}
*G. Eliminar, seleccionar y ordenar variables en las Tablas
*	1. Eliminar variables de la Tabla*
outreg2 [regresion2] using "regresiones_drop.xls", replace drop(ingresos)
*	2. Seleccionar variables de la Tabla*
outreg2 [regresion2] using "regresiones_keep.xls", replace keep(educa_pa personas orden_n)
*	3. Ordenar variables de la Tabla*
outreg2 [regresion2] using "regresiones_keep.xls", replace keep(educa_pa personas orden_n) sortvar(personas _cons orden_n educa_pa)

*4. Esttab*
findit esttab // Instalar el paquete "st0085_2"
*El uso de este comando se ilustrará con los estimadores guardados bajo el nombre regresion2*
		
*A. Sintaxis*
esttab regresion2
esttab regresion2 using "esttab", replace

*B. Formatos*
esttab regresion2 using "esttab.csv", replace
esttab regresion2 using "esttab.smcl", replace
esttab regresion2 using "esttab.rtf", replace

*C. Decimales*
esttab regresion2, beta(%3.2f) 
esttab regresion2, beta(%3.2f) se(%2.1f)
esttab regresion2, beta(%3.2f) t(%2.1f)
		
*D. Estadísticas adicionales*
esttab regresion2, scalars(r2_a) sfmt(%3.1g)
esttab regresion2, scalars(r2_a) sfmt(%3.1g) noobs

*E. Reemplazar y adjuntar resultados a una tabla*
forvalues i=3(1)6{
	reg razmatss ingresos educa_pa personas orden_n if age_nihf==`i'
	estimates store edad_`i'
	esttab edad_`i' using "esttab_edades", append
}

*F. Eliminar, seleccionar y ordenar variables en las Tablas
*	1. Eliminar variables de la Tabla*
esttab regresion2, scalars(r2_a) sfmt(%3.1g) drop(ingresos)	
*	2. Seleccionar variables de la Tabla*
esttab regresion2, scalars(r2_a) sfmt(%3.1g) keep(educa_pa personas orden_n _cons)
*	3. Ordenar variables de la Tabla*
esttab regresion2, scalars(r2_a) sfmt(%3.1g) keep(educa_pa personas orden_n _cons) order(personas _cons orden_n educa_pa)	