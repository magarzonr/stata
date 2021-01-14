*****************************************************
** Universidad de los Andes - Facultad de Economía **
** 			       Taller de Stata                 **
**												   **
** 				Miguel Garzón-Ramírez              **
** 			   Cristhian Acosta-Pardo              **
** 			   						               **
**        Clase  10: Gráficos I - Clasificación    ** 
*****************************************************
clear all
cap log close
set more off, perm 

global clase10 "_____" // Coloque entre las comillas la dirección completa de la carpeta donde están los datos. 
cd "$clase10"

use "Base_clase_10", replace

** Documentación: https://www.stata.com/bookstore/graphics-reference-manual/

**************************************************
***I. Gráficos básicos de barras, pie y caja   ***
**************************************************
*a) Barras
graph bar (mean) DPNE, name(barras1, replace) // el promedio es por defecto

*Opción over (valores de una variable en categorias)
graph bar (mean) DPNE, over(SECTOR) name(barras2, replace) 

*Condicionales
graph bar (mean) DPNE if YEAR<=2003, /// Condicional
over(SECTOR, label(angle(90)))  /// Orientación del eje X
name(barras3, replace)

*Barras horizontales 
graph hbar DPNE if YEAR<=2003, /// 
over(SECTOR, label(angle(0) labsize(small))) ///
ytitle(Porcentaje (%)) name(barrash, replace)

*Doble over, título, subtítulo y título de eje
graph bar (mean) DPNE if YEAR<=2003, /// 
over(SECTOR, label(angle(90) labsize(small))) /// Orientación y tamaño de leyenda
over(YEAR, label(angle(90) labsize(vsmall))) /// Orientación y tamaño de leyenda  
title(Crecimiento Promedio de la Producción por Sector) /// Título
subtitle(2002-2003. EAM) /// Subtitulo
ytitle(Porcentaje (%)) /// Título del eje Y
name(barras4, replace)
	
*Varios cálculos - Un color para cada uno
graph bar (mean) DPNE (median) DPNE, over(SECTOR, label(angle(vertical))) ///
b1title(Sectores Cuentas Nacionales) /// Titulo de la leyenda
ytitle(Porcentaje (%)) ylabel(0(10)30) /// Modificar el eje
title(Crecimiento Promedio de la Producción por Sector) ///
subtitle(2002-2006. EAM) ///
name(barras5, replace)

*Varios cálculos con condicionales y etiquetas en la leyenda
graph bar (asis) (mean) DPNE DPNM if (SECTOR==15|SECTOR==20|SECTOR==33)&YEAR<2005, ///
over(YEAR) over(SECTOR) ///
legend(c(1)) /// Colocar en columna la leyenda
ytitle(Porcentaje (%)) ///
title(Crecimiento de la Producción por Sector) ///
subtitle(2002-2006. EAM) ///
name(barras6, replace)

*Uso de 'yvars' para acomodar varios over 
graph bar  DPNE if (SECTOR==15|SECTOR==20|SECTOR==33)& YEAR<2005, ///
over(SECTOR) over(YEAR) name(barras7a, replace)
 
	* Años en el eje X
graph bar (mean) DPNE if (SECTOR==15|SECTOR==20|SECTOR==33)& YEAR<2005, ///  note el cambio al introducir asyvars
over(SECTOR) over(YEAR) name(barras7b, replace) asyvars

	* Sector en el eje X
graph bar DPNE if (SECTOR==15|SECTOR==20|SECTOR==33)& YEAR<2005, /// note el cambio al colocar YEAR antes de SECTOR
over(YEAR) over(SECTOR) name(barras7c, replace) asyvars
	
*Uso de ascategory para modificar la visualización de la variable y
graph bar (mean) DPNE DVNE DETE, name(barras8a, replace) over(YEAR) 

graph bar (mean) DPNE DVNE DETE, name(barras8b, replace) over(YEAR) ascategory  xsize(20) ysize(5) //Un gráfico por cada "over"

*b) Box
graph box DPNE, over(SECTOR) name(box1,replace) saving(box1, replace)

*Opciones
graph box DPNE, over(SECTOR, label(angle(vertical))) ///
ytitle(Porcentaje (%)) ///
title(Variación del Crecimiento de la Producción Nominal) ///
subtitle(Según la Encuesta Anual Manufacturera) ///
name(box2,replace) ///
saving(box2, replace)

*Varias variables
graph box DPNE DVNE, over(SECTOR, label(angle(vertical))) ///
ytitle(Porcentaje (%)) ///
title(Variación Crecimiento de la Producción y las Ventas Nominal) ///
subtitle(Según la Encuesta Anual Manufacturera) ///
legend(r(2)) /// Arregla en columnas la variables en la leyenda 
marker(1,msize(vsmall)) /// tamaño de los marcadores que corresponden a atípicos 
marker(2,msize(vsmall)) ///
name(box3,replace) ///
saving(box3, replace)

*c) Pie
graph pie DPNE if YEAR==2003 & inlist(SECTOR, 10, 11, 12, 13, 14, 15, 16), over(SECTOR) name(pie1,replace)

* Opciones
graph pie DPNE if YEAR==2003 & inlist(SECTOR, 10, 11, 12, 13, 14, 15, 16), over(SECTOR) /// Puede usar condicionales
scheme(economist) /// Estilos de colores, más en la documentación (p. 689)
sort descending /// Organiza las categorias de menor a mayor en sentido contrario de las manecillas del reloj
title(Crecimiento de la producción por sector en 2003, size(med)) ///
saving(pie1,replace) /// Guarda la gráfica en el directorio
name(pie1,replace)
	
*Sacar un pedazo del pie e incluir porcentajes o valores
graph pie DPNE if YEAR==2003 & SECTOR!=0 ,over(SECTOR) saving(pie4,replace) sort ///
pie(12, explode) pie(14, explode) /// Sacar pedazos específicos
plabel(_all percent) /// También puede usar plabel(_all sum) para mostrar los valores de la categoria
legend(off)

**************************
***II. Familia Twoway  ***
**************************
*a) Barra
graph twoway bar DPNE YEAR //La sintaxis cambia respecto al comando anterior
tw bar DPNE YEAR, name(barras1, replace) // Abreviando el comando
tw bar DPNE YEAR if SECTOR==00, ylabel(0(2)20) name(barras12, replace) // Note el uso del condicional

*b) Línea
tw line DPNE YEAR if SECTOR==00, name(linea1, replace) 
line DPNE YEAR if SECTOR==00, ylabel(0(2)20) name(linea2, replace) //Se puede abreviar aún más
	
*c) Scatter
twoway scatter DPNE YEAR if SECTOR==00, ylabel(0(2)20) name(scat1, replace)

twoway (scatter DPNE YEAR) (lfit DPNE YEAR) if SECTOR==00, ylabel(0(2)20) name(scat2, replace) //Introduce línea de tendencia
scatter DPNE YEAR || lfit DPNE YEAR || if SECTOR==00  , ylabel(0(2)20) name(scat3, replace)

*d) Unir varios twoways scatter
twoway scatter DPNE DPNM YEAR if SECTOR==00, ylabel(0(2)20) name(scat3, replace) // Varias variables

twoway (scatter DPNE DPNM YEAR) (lfit DPNE YEAR) (lfit DPNM YEAR) if SECTOR==00, legend(c(1)) name(scat4, replace) 
scatter DPNE DPNM YEAR || lfit DPNE YEAR || lfit DPNM YEAR || if SECTOR==00  , name(scat4, replace)
**
local t: variable label DPNE
#d;
twoway 
(scatter DPNE YEAR if SECTOR==00)(lfit DPNE YEAR  if SECTOR==00) 
(scatter DPNE YEAR if SECTOR==36)(lfit DPNE YEAR  if SECTOR==36)
, name(scat5, replace) 
legend(order(1 "`t' para todos" 2 "tendencia para todos" 3 "`t' para otros" 4 "tendencia para otros"))
;
#d cr
	
*e) Connected
twoway connected DPNE YEAR if SECTOR==00, name(connect1, replace)
twoway (connected DPNE YEAR) (connected DPNM YEAR) if SECTOR==00, name(connect2, replace)

*f) R Cap (Distancia entre DPNE y DPRE: comparar con scat2)
graph display scat2
twoway (rcap DPNE DPRE YEAR, color(blue)) if SECTOR==00, name(r_cap1, replace)
twoway (rcap DPNM DPNE YEAR, color(red)) if SECTOR==00, name(r_cap2, replace)
twoway (rcap DPNE DPRE YEAR, color(blue)) (rcap  DPNM DPNE YEAR, color(red)) if SECTOR==00, name(r_cap3, replace)

*g) Area
twoway area DPNE YEAR if SECTOR==00, name(area, replace)

*h.) R Area
twoway  (rarea DPNE DPRE YEAR, color(purple))	if SECTOR==00, name(r_area1, replace)
twoway 	(rarea  DVNE DPNE YEAR, color(magenta))	if SECTOR==00, name(r_area2, replace)

twoway  (rarea DPNE DPRE YEAR, color(orange)) (rarea  DVNE DPNE YEAR, color(gray)) ///
if SECTOR==00, name(r_area3, replace) legend(cols(1)) 

*i) Histograma
twoway histogram DPNE, name(histogr1, replace)
twoway histogram DPNE if YEAR==2002, name(histogr2, replace)
twoway histogram DPNE if YEAR==2002, freq name(histogr3, replace)

hist DPNE if YEAR==2002, bin(20) name(histogr4, replace)

*j) By en gráficos
twoway (connected DPNM YEAR), by(SECTOR) name(scat_by, replace)	

********************************
***III. Otros gráficos       ***
********************************

*a) Scatterplot Matrix
graph matrix DPNE DVNE, name(matrix1, replace)
graph save matrix1, replace

*Opciones
graph matrix DPNE DVNE DSSNTE if SECTOR!=00&SECTOR!=36&YEAR!=2002, ///
half /// Solo muestra la zona inferior de la matriz
ms(Oh) /// Cambiar el tamaño de los puntos, ms(p) los hace más pequeños
maxes(ylab(#4, grid) xlab (#4, grid)) /// Definir las guias de los ejes
title("Relación entre Producción, Ventas y Salarios Nominales") ///
subtitle(Según la Encuesta Anual Manufacturera) ///
name(matrix2, replace)

*b) Kernel Density
kdensity DPNE, normal name(kernel, replace)
