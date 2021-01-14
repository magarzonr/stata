*****************************************************
** Universidad de los Andes - Facultad de Economía **
** 			       Taller de Stata                 **
**												   **
** 				Miguel Garzón-Ramirez              **
** 			   Cristhian Acosta-Pardo              **
** 			   						               **
**  Clase 5: Unión y compresión de bases de datos  **
*****************************************************

clear all
set more off, perm
cd "_____" // Coloque entre las comillas la dirección completa de la carpeta donde están los datos. 
dir 
*-----------------------------------------*

* 1. Usando varias bases de datos: frames 
** Bases de datos de esta clase
use Base_Depto_Mun, clear //Base con correspondencia departamento y municipio
use Base_Depto_Mun_2, clear //Base con municipios adicionales
use Poblacion_total, clear	//Poblacion total por municipios
use natdis, clear //Cantidad de parques naturales adicional por departamento

**  Podemos cargarlas todas en la memoria de Stata usando frames (solo en Stata 16)
* Frame por defecto
use Base_Depto_Mun, clear
frame dir // cuando cargamos una base de datos a la memoria de Stata se crea un frame por defecto
* Crear un frame
frame create Base_Depto_Mun_2
frame dir
frame change Base_Depto_Mun_2 // ver un frame
use Base_Depto_Mun_2, clear // cargar la base al frame

* Crear los demás frames
frame create Poblacion_total
frame create natdis
* Crear los demás frames
frame Poblacion_total: use Poblacion_total, clear
frame natdis: use natdis, clear
frame dir

* Explorando los frames creados
frame change Poblacion_total
frame change natdis
*-----------------------------------------*

* 2. Analizar la unidad de observación - filas: duplicates 
frame change default // Análisis de unidad de observación para la base Base_Depto_Mun
duplicates report // ¿hay observaciones (filas) idénticas? - duplicados sobre todas las variables - Ver la documentación de duplicates para ver otros usos del comando
duplicates drop	 // borrar filas repetidas
*
duplicates report cod_dpto // La variable tiene valores repetidos.
duplicates tag cod_dpto, gen(dup_cod_dpto) // crear una variable que indique cuantas veces está duplicado un dato
duplicates report cod_mpio // esta es la variable que identifica la unidad de observación, los municipios
* Otras formas de encontrar el identificador
isid cod_mpio
bys cod_mpio: assert _N==1
* Análisis para las demás bases, todas cargadas en memoria como frames
*
frame change Base_Depto_Mun_2 // tiene las mismas variables que Base_Depto_Mun
isid cod_mpio // y la misma unidad de observación, municipios
*
frame change Poblacion_total
bys cod_mpio: assert _N==1 // Su unidad de observación son los municipios
*
frame change natdis
duplicates report cod_dpto // Su unidad de observación son los departamentos
*-----------------------------------------*

* 3. Agregar observaciones: append
frame pwf
frame change default // Base departamentos municipios es MASTER
append using "Base_Depto_Mun_2", gen(a1) // La opción gen() permite marcar en la variable "origen" la fuente de las observaciones
* ¿Qué pasa cuando las bases no tienen las mismas variables?
*-----------------------------------------*

* 4. Agregar variables: merge
* Caso 1:1 : matching variable identifica únicamente a las observaciones, tanto en la base de datos master como en la using.
	* Ejemplo. Unir dos bases de datos a nivel municipal: Población municipal con base municipal.

merge 1:1 cod_mpio using "Poblacion_total", gen(m1) // opciones para explorar: update y replace	  

* Caso m:1 : la variable llave identifica a las observaciones únicamente en la "using". En la "master" hay valores repetidos.
	* Ejemplo. Unir la cantidad de parques naturales a nivel departamental a la base municipal.
	*merge 1:1 cod_dpto using "natdis.dta"	
merge m:1 cod_dpto using "natdis.dta", gen(m2) // Note que las observaciones con el mismo departamento toman el mismo valor en la variable natdis. 

save "base_depto_mun_completa", replace
*-----------------------------------------*

* 5. Crear una base de datos agregada: collapse
* Crear base departamental con población total y parques 
use "base_depto_mun_completa", replace
collapse (mean) natdis (sum) pob_total, by(cod_dpto nom_dpto_pob_2005)	
save mean_dep.dta, replace
export excel "collapse.xlsx", firstrow(variables) sheet("mean_dep", replace)

* Estadísticas descriptivas de una variable
use "base_depto_mun_completa", replace
collapse 	mean_pob=pob_total ///
			(sd) sd_pob=pob_total ///
			(median) mediana_pob=pob_total ///
			(min) min_pob=pob_total ///
			(max) max_pob=pob_total
export excel "collapse.xlsx", firstrow(variables) sheet("pop_dept_stat", replace)

* Creación de la variable cantidad de municipios por departamento
use "base_depto_mun_completa", replace
bys cod_dpto: gen num_mun=_N
bys cod_dpto: gen num_mun1=_n
gen num_mun2=1
collapse num_mun (max) num_mun1 (sum) num_mun2 (count) num_mun3=a1, by(cod_dpto nom_dpto)
export excel "collapse.xlsx", firstrow(variables) sheet("num_mun", replace)
*-----------------------------------------*

* 6. Procesamiento con preserve - restore *
* Estadísticas descriptivas de una variable por cada valor de una variable categórica
use "base_depto_mun_completa", replace
preserve // Se debe ejecutar desde preserve hasta restore
	#d ;
	collapse	
				(sum) pob_total 
				(sd) sd_pob=pob_total 
				(median) mediana_pob=pob_total 
				(min) min_pob=pob_total 
				(max) max_pob=pob_total, by(cod_dpto) ;
	#d cr
	export excel "collapse.xlsx", firstrow(variables) sheet("pop_depto", replace)
restore // durante la ejecución de código se modificó la base de datos, con restore se recupera la base como estaba antes de preserve.
*-----------------------------------------------------*

* 7. Cambiar estructura de los datos: reshape 
* Ejemplo de las CheatSheets 
webuse set "https://github.com/GeoCenter/StataTraining/raw/master/Day2/Data" // Dirección de donde se cargarán las bases de datos
webuse "coffeeMaize.dta", clear
* Tidy data (melt) - de wide a long
reshape long coffee maize, i(country) j(year)
* Cast
reshape wide coffee maize, i(country) j(year)


* Tidy data (melt), even more
reshape long coffee maize, i(country) j(year)
rename (coffee maize) (cropcoffee cropmaize)
reshape long crop, i(country year) j(type) s
* Cast
reshape wide crop, i(country year) j(type) s
rename crop* * 
reshape wide coffee maize, i(country) j(year)


* Ejemplos con documentación
help reshape
 webuse set // Establecer la dirección donde están las bases de datos usadas en la documentación por defecto
* wide -> long:

webuse "reshape1", clear
reshape long inc ue, i(id) j(year) string
list, sepby(id)
 
* long -> wide: 
 
**Regresar a long después de ejecutar wide
reshape wide inc ue, i(id) j(year) string //comando explícito
*reshape wide //comando implícito
	
*-> Con otro formato de nombre de variable
webuse "reshape3", clear
list
  
reshape long inc@r ue, i(id) j(year) //de wide a long
list, sepby(id) //Observe el cambio en los nombres de las variables
reshape wide
list
 
*-> De long-long a wide wide  
webuse reshape5, clear
list
  
reshape wide @inc, i(hid year) j(sex) string
list
reshape wide minc finc, i(hid) j(year)
list
*----------------------------------------------*

* 8. Tablas de frecuencias contract
use "base_depto_mun_completa", replace
tab cod_dpto
preserve
	contract cod_dpto
	export excel "freq.xlsx", firstrow(variables) replace
restore
preserve
	contract nom_dpto
	export excel "freq2.xlsx", firstrow(variables) replace
restore
preserve
	contract nom_dpto, cpercent(porcent_acum)
	export excel "freq3.xlsx", firstrow(variables) replace
restore

** Final de la clase
