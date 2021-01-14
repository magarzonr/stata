*****************************************************
** Universidad de los Andes - Facultad de Economía **
** 			       Taller de Stata                 **
**												   **
** 				Miguel Garzón-Ramirez              **
** 			   Cristhian Acosta-Pardo              **
** 			   						               **
**     Clase  11: Gráficos II - Edición y unión    ** 
*****************************************************
clear all
cap log close
set more off, perm 
graph set window fontface "Garamond"

global clase11 "_____" // Coloque entre las comillas la dirección completa de la carpeta donde están los datos. 
cd "$clase11"

use "Base_clase_11", replace

*************************************
***I. Edición de gráficos Twoway ***
*************************************
*Gráfico base
twoway (connected DPNM DPNE YEAR) if SECTOR==0, name(base1, replace)	
	
*Opciones básicas de títulos y otras
twoway (connected DPNM DPNE YEAR) if SECTOR==0, ///
title(Crecimiento Producción Nominal) subtitle(EAM vs MMM: 2002-2006) /// Título y subtítulo
note(Crecimiento con base en el valor del año anterior.) /// Notas a la gráfica 
caption(Fuente: EAM y MMM. DANE. Cálculos de los autores.) /// Comentarios a la gráfica
legend(cols(1)) /// Leyenda en columnas
graphregion(color(white)) ///
name(mod1,replace)
	
*Cambiar la apariencia de una línea
twoway (connected DPNM YEAR) (connected DPNE YEAR, lpattern(dash_dot)) if SECTOR==0, /// Ingresando linea punteada
title(Crecimiento Producción Nominal) subtitle(EAM vs MMM: 2002-2006) caption(Fuente: EAM y MMM. DANE) ///
note(Crecimiento con base en el valor del año anterior.) name(mod2,replace) legend(cols(1))

*Introducir un texto en varias líneas
twoway (connected DPNM DPNE YEAR) if SECTOR==0, ///
title("Crecimiento" "Producción Nominal" "EAM vs MMM: 2002-2006") ///
caption (Fuente: EAM y MMM. DANE) note(Crecimiento con base en el valor del año anterior.) ///
name(mod3,replace) legend(cols(1))

*Cambiar posición del título
twoway (connected DPNM DPNE YEAR) if SECTOR==0, ///
title("Crecimiento" "Producción Nominal" "EAM vs MMM: 2002-2006", ///
size(medium) position(9) ring(7) box orientation(vertical)) ///
caption (Fuente: EAM y MMM. DANE) ///
note(Crecimiento con base en el valor del año anterior.) ///
name(mod4,replace) legend(cols(1))

*Opciones de los ejes
twoway (connected DPNM DPNE YEAR) if SECTOR==0, ///
title(Crecimiento Producción Nominal) subtitle(EAM vs MMM: 2002-2006) ///
caption (Fuente: EAM y MMM. DANE) note(Crecimiento con base en el valor del año anterior.) ///
legend(cols(1)) b2title(Leyenda, place(center)) ///
ytitle(Crecimiento Porcentual (%)) /// Título del eje Y
xtitle("año", size(medium)) /// Título del eje X
ylabel(,angle(45) format(%4.2f)) /// Cambiar visualización de los números del eje Y
xlabel(2000(3)2010, angle(vertical) labsize(small) format(%5.0f) grid) ///
graphregion(color(white)) ///
name(mod5,replace)
**Si tengo una lista de números determinados para los ejes también puedo agregarlos uno por uno
	
**************************************
***II. Graph manipulation: macros  ***
**************************************
* Ejemplo 1: Uso de local para insertar texto en los gráficos
/* Queremos crear un gráfico que compare el crecimiento de la producción nominal en las dos fuentes de información para el sector Cacao. El gráfico debe mostrar la correlación de las dos variables. */

* Crear el objeto local que contiene la correlación
correlate DPNE DPNM if SECTOR==16
local corr = round(`r(rho)',0.01)
local corr : display %3.2f `corr' 
macro dir
display `corr'
display "`corr'" // Como usamos la función extendida "display" con un formato de número para definir el local "corr", si usamos comillas va a aparecer con el cero antes del punto decimal.

* Crear los objetos local del título
local p: var label DPNM
display  "`p'"
local titulo=subinstr("`p'"," MMM","",1)
display  "`titulo'"
local nombre: label sector 16 
display "`nombre'"

* Creación de la gráfico con los parámetros
twoway (connected DPNM YEAR)(connected DPNE YEAR) if SECTOR==16, ///
title("`titulo'" "`nombre'") ///
subtitle(EAM vs MMM: 2002-2006) ///
ytitle(Cambio Porcentual (%)) ///
ylabel(,angle(horizontal) labsize(small)) ///
text(15 2003 "Correlación=`corr'", place(r)) caption(Fuente: DANE) ///
legend(order(1 "MMM" 2 "EAM")) ///
graphregion(color(white)) ///
name(DPN_16,replace) 

**************************************
***III. Graph manipulation: Loops  ***
**************************************
* Ejemplo 2: Uso de loops para crear un gráfico combinado
/* Queremos crear un gráfico que compare el crecimiento de la producción, ventas y salarios nominales y el empleo para las dos fuentes de información. El gráfico debe mostrar la correlación de las dos variables. */

*Loop para crear cuatro gráficos 
foreach var in DPN DVN DSSN DET{ // Los objetos de la lista son los caracteres iniciales de los nombres de las variables de interes.
	
 * Crear el objeto local que contiene la correlación
 correlate `var'E `var'M if SECTOR==16
 local corr = round(`r(rho)',0.01)
 local corr : display %3.2f `corr' 
 display "`corr'"
 
 * Crear los objetos local del título
 local p: var label `var'M
 display  "`p'"
 local titulo=subinstr("`p'"," MMM","",1)
 display  "`titulo'"
 
 * Creación del gráfico con los parámetros
 twoway (connected `var'M YEAR)(connected `var'E YEAR) if SECTOR==16, ///
 title("`titulo'") /// El sector lo indicamos cuando unamos los gráficos
 subtitle(EAM vs MMM: 2002-2006) ///
 ytitle(Cambio Porcentual (%)) ///
 ylabel(,angle(horizontal) labsize(small)) ///
 text(15 2003 "Correlación=`corr'") ///
 legend(order(1 "MMM" 2 "EAM")) ///
 graphregion(color(white)) ///
 name(`var'_16,replace)  
}
	
************************
***IV. Graph combine ***
************************
local nombre : label sector 16
graph combine DPN_16 DVN_16 DSSN_16 DET_16, ///
iscale(*0.7) /// Cambia el tamaño de los elementos
title(`nombre') caption(Fuente: DANE) /// Título y nota 
graphregion(color(white)) /// Formato de fondo
ycommon /// Asigna el mismo eje Y para todas las gráficas
xcommon ///
c(2)  /// número de columnas
name(comb_16, replace) saving(comb_16, replace)

* Otros comandos
graph export comb_16.png, replace
graph export comb_16.pdf, replace
graph save comb_16, replace
graph describe comb_16
graph rename comb_16 c_16, replace
graph dir

*********************************************
*** V. Gráficos e intervalos de confianza ***
*********************************************
*a) lfitci - Predicción lineal con intervalos de confianza
twoway (lfitci DPNM YEAR if SECTOR==10),  title(Tendencia en el tiempo) xtit(Tiempo) name(ic_95, replace) 
twoway (lfitci DPNM YEAR if SECTOR==10, level(99)), title(Tendencia en el tiempo) xtit(Tiempo) name(ic_99, replace) 
twoway (lfitci DPNM YEAR if SECTOR==10, level(90)), title(Tendencia en el tiempo) xtit(Tiempo) name(ic_90, replace) 

graph combine ic_90 ic_95 ic_99, r(1) ycommon xsize(20) ysize(10) name(comb1, replace)

*Cambiando color del intervalo de confianza*
twoway (lfitci DPNM YEAR if SECTOR==10, acolor(orange)), nodraw ///
title(Tendencia en el tiempo) xtit(Tiempo) name(ic_95, replace)

twoway (lfitci DPNM YEAR if SECTOR==10, level(99) acolor(green)), nodraw ///
title(Tendencia en el tiempo) xtit(Tiempo) name(ic_99, replace)

twoway (lfitci DPNM YEAR if SECTOR==10, level(90) acolor(purple)), nodraw ///
title(Tendencia en el tiempo) xtit(Tiempo) name(ic_90, replace)

graph combine ic_90 ic_95 ic_99, rows(1) ycommon xsize(20) ysize(10) name(comb2, replace)

*b) qfitci - Predicción cuadrática con intervalos de confianza
	
twoway (qfitci DPNM YEAR if SECTOR==10,  level(90)) , title(Tendencia en el tiempo) xtit(Tiempo) name(qfitci, replace)

*******************************************************
*** VI. Gráficos Barras con intervalos de confianza ***
*******************************************************
use "Base_clase_11", replace

collapse (mean) meanDPNM= DPNM (sd) sdDPNM=DPNM (count) n=DPNM, by(SECTOR)

generate hi = meanDPNM + invttail(n-1,0.025)*(sdDPNM / sqrt(n))
generate lo = meanDPNM - invttail(n-1,0.025)*(sdDPNM / sqrt(n))

graph twoway (bar meanDPNM SECTOR) (rcap hi lo SECTOR) if inlist(SECTOR, 10, 16, 25, 29)

gen seleccion=SECTOR if inlist(SECTOR, 10, 16, 25, 29)
recode seleccion (10=1) (16=2) (25=3) (29=4)
	   
twoway (bar meanDPNM seleccion if SECTOR==10) ///
       (bar meanDPNM seleccion if SECTOR==16) ///
       (bar meanDPNM seleccion if SECTOR==25) ///
       (bar meanDPNM seleccion if SECTOR==29) ///
       (rcap hi lo seleccion if inlist(SECTOR, 10, 16, 25, 29), color(gs5)), ///
       legend(row(1) order(1 "Carnes" 2 "Cacao y Otros" 3 "Papel" 4 "Plástico")) ///
	   xlabel(, nolabels noticks) ///
       xtitle("Sector") ytitle("Procentaje (%)") ///
	   title(Crecimiento Promedio de la Producción Nominal por Sector) ///
	   subtitle(2002-2006) ///
	   note(Datos de la Muestra Mensual Manufacturera) ///
	   graphregion(color(white)) name(bar_ci, replace)

