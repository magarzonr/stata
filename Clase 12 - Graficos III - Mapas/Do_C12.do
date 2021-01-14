*****************************************************
** Universidad de los Andes - Facultad de Economía **
** 			       Taller de Stata                 **
**											       **
** 				Miguel Garzón-Ramírez              **
** 			   Cristhian Acosta-Pardo              **
** 												   **
**        Clase  12: Gráficos III - Mapas          ** 
*****************************************************
clear all
cap log close
set more off, perm 
global dir "_____" // Coloque entre las comillas la dirección completa de la carpeta donde están los datos. 
cd "$dir"

*----------------------------------------------------*
*I. Datos para la creación de un mapa departamental  *
*----------------------------------------------------*	
/* 	1. Mapa departamentos de Colombia co_dep.shp
	2. Base de datos a nivel municipal. Variables: 
		a. Evaluación de Desarrollo Infantil Cognitivo
		b. Ingresos del jefe de hogar
		c. Número de personas en el hogar
	3. Base de datos a nivel Departamental. Variables: 
		a. Población rural
		b. Población urbana
		c. Población total   */

use desarrollo, clear
use pob_depto, clear
* La variable llave para unir la información es el código departamental (coddepto)
	
use desarrollo, clear  // La base desarrollo tiene informacion a nivel hogar de ingresos del hogar, etc.
rename departam coddepto
collapse ingresos_hogar_jefe tam_hogar=personas, by(coddepto)
save desarrollo_dep, replace // desarrollo_pordep.dta queda a nivel departamental, con promedios

*----------------------------------------------------*
*II. Convertir datos geográficos a formatos de Stata *
*----------------------------------------------------*
clear all
unzipfile co_dep, replace
spshape2dta co_dep, replace

/* Nota
El comando anterior crea dos bases de datos:
   	1. co_dep.dta: Atributos. Infomación del departamento junto con el indentificador del departamento.  Por defecto, el comando genera 3 variables en el archivo "co_dep.dta":
		1. _ID: Identificador del departamento
		2. _CX: Coordenada X del centroide del departamento (Longitud)
		3. _CY: Coordenada Y del centroide del departamento (Latitud)
   	2. co_dep_shp.dta: Coordenadas por departamento que Stata usa para hacer la proyección.
*/
*-------------------------------*
*III. Unión de la base de datos	*
*-------------------------------*
clear all
use co_dep, replace  // co_dep fue creada por spshape2dta y contiene información del departamento junto con los indicadores geográficos.								 
rename (DPTO_CCDGO DPTO_CNMBR) (coddepto nomdepto)
destring coddepto, replace

merge 1:1 coddepto using desarrollo_dep, gen(m1)
merge 1:1 coddepto using pob_depto, gen(m2)
keep _ID _CX _CY coddepto nomdepto ingresos_hogar_jefe tam_hogar pob_rur pob_urb pob_tot

gen p_pob_rur=pob_rur/pob_tot*100
gen p_pob_urb=pob_urb/pob_tot*100

format p_pob_rur p_pob_urb %4.1f // En los mapas se muestran estos datos con una sola cifra decimal

label var coddepto "Código de departamento"
label var nomdepto "Nombre del departamento"
label var ingresos_hogar_jefe "Ingresos del jefe de hogar"
label var tam_hogar "Personas por hogar"
label var pob_rur "Población rural"
label var pob_urb "Población urbana"
label var pob_tot "Población total"
label var p_pob_rur "Porcentaje de población rural"
label var p_pob_urb "Porcentaje de población urbana"

*------------------------------------------*
*IV. Opciones básicas para graficar mapas  *
*------------------------------------------*
** Proyectar el mapa. Datos geográficos
grmap, activate
grmap using "co_dep_shp", id(_ID) name(mapa_1, replace)

** Proyectar solo algunos departamentos - Uso de condicional
grmap using "co_dep_shp" if coddepto==5|coddepto==25, id(_ID) name(mapa_1, replace)

** Proyectar el mapa con centroides
grmap using co_dep_shp, id(_ID) ///
	point(	x(_CX) y(_CY) size(*.7) ///
			fcolor(red) ocolor(white) ///
			osize(*0.2)	) /// Opciones de los centroides
	name(mapa_2, replace) // Se le da nombre al mapa y se guarda en la memoria

*-----------------------*
*V. Mapas coropléticos  *
*-----------------------*
** Mapa de los ingresos del jefe de hogar por departamento. Mapa coroplético en cuatro clases por defecto, cuartiles
grmap ingresos_hogar_jefe using "co_dep_shp", id(_ID) name(mapa_3, replace) 

** Método de cuantiles - Población rural (p_pob_rur) o ingresos jefe de hogar (ingresos_hogar_jefe)
grmap p_pob_rur using "co_dep_shp", id(_ID) ///
	clnumber(6) /// Cantidad de clases
	clmethod(quantile) /// Las clases se crean con cuantiles
	fcolor(BuRd) /// Colores de las clases (también puede ser reds, blues, etc...)
	ndfcolor(gs8) /// Color de los missing values (Por defecto es blanco)
	legstyle(2) /// Estilo de la leyenda, probar con 0, 1, 2, 3 
	legend(size(*1.4)) /// Opciones de leyenda
	title("Nivel de ruralidad", size(*0.8)) ///
	subtitle("Colombia 2009" " ", size(*0.8)) ///
	name(mapa_4p, replace)
	
** Método de caja - Población rural (p_pob_rur) o ingresos jefe de hogar (ingresos_hogar_jefe)
grmap p_pob_rur using "co_dep_shp", id(_ID) ///
	clnumber(4) clmethod(boxplot) /// Datos clasificados como una caja de distribución
	fc(BuRd) ndf(gs8) /// Opciones de cuantiles
	ndlab("Missing") legend(size(*1.4)) /// Opciones de leyenda
	title("Nivel de ruralidad", size(*0.8)) ///
	subtitle("Colombia 2009" " ", size(*0.8)) ///
	name(mapa_5p, replace)

** Ingreso manual de la leyenda - ingresos_hogar_jefe
grmap ingresos_hogar_jefe using co_dep_shp, id(_ID) /// 
	clnumber(3) fcolor(Greens) ndf(gray) title(Ingresos por Departamento) subtitle(Año 2009) ///
	legend(	order(	1 "Sin Información"  /// Ingreso manual de la leyenda  
					2 "Tercil 1" ///
					3 "Tercil 2" ///
					4 "Tercil 3") /// 
			c(2) position(7)) /// Leyenda en dos columnas y posición 7 (8 por defecto) 
	caption(Fuente: HCB) /// 
	scalebar(units(500) scale(100/1) label(Kilometros) x(150) y(-100))  ///Opciones de escala
	name(mapa_6, replace)
	
graph dir // Ver los mapas (gráficos) guardados en la memoria de Stata

**Introduciendo las clases manualmente
* Población
grmap p_pob_rur using "co_dep_shp", id(_ID) ///
	clmethod(custom) /// Las clases se crean manualmente
	clbreaks(0 25 50 75 100) /// Cortes de las categorías del mapa
	fcolor(YlGn) ///
	legend(	order(	1 "Bajo" ///
					2 "Medio bajo" /// 
					3 "Medio alto" ///
					4 "Alto") ///
			c(1) position(7)) /// Opciones de la leyenda
	title("Nivel de ruralidad", size(*0.8)) ///
	subtitle("Colombia 2009" " ", size(*0.8)) ///
	name(mapa_7, replace)
	
* Ingreso de los hogares
grmap ingresos_hogar_jefe using "co_dep_shp", id(_ID) ///
	clmethod(custom) /// 
	clb(367892.3 590846.4 715309 1091704) ///
	fcolor(Reds) ndf(gray) ///  
	legend(	order(	1 "Información no disponible" ///
					2 "Ingreso bajo" ///
					3 "Ingreso medio" ///
					4 "Ingreso alto") ///
			r(1) position(6) ring(1)) /// Leyenda en fila y posición
	title (Ingresos del hogar por departamento, size(*0.8)) ///  
	subtitle("Colombia" "2009", size (*0.6)) ///
	caption(Fuente: HCB) /// 
	name(mapa_8, replace)
	
**Otros colores
grmap ingresos_hogar_jefe using "co_dep_shp", id(_ID) ///
   ndf(gray) fcolor(Greens2) ///
   title("Ingresos hogares", size(*0.8)) ///
   subtitle("Colombia 2009" " ", size(*0.8)) /// 
   legend(	ring(1) position(3) c(1) ///
			order(	1 "No disponible" ///
					2 "Ingreso bajo" ///)
					3 "" 4 "" 5 "" 6 "" 7 "" 8 "" ///
					9 "" 10 "" 11 "" 12 "" 13 "" ///
					14 "" 15 "" 16 "" 17 "" 18 "" 19 ""  ///
					20 "Ingreso alto")) /// Opciones de leyenda
   clnumber(20) /// Número de clases en la leyenda
   scalebar(units(500) scale(100/1) label(Kilometros)) ///Opciones de escala
   name(mapa_9, replace)
	
*------------------------------------*
*VI. Mapas coropleticos con objetos  *
*------------------------------------*
**Mapa de puntos proporcionales
grmap using "co_dep_shp", id(_ID) fcolor(white) ///
	point(	x(_CX) y(_CY) /// Coordenadas de los puntos
			proportional(p_pob_rur) /// Tamaños proporcionales a la variable
			fcolor(green) /// Color del relleno de los puntos
			ocolor(white) /// Color del borde de los puntos
			size(*0.5)) /// Cambia el tamaño de todos los puntos
	label(	x(_CX) y(_CY) /// Coordenadas de la leyenda de los puntos
			label(p_pob_rur) /// Dato para marcar el punto
			color(black) /// Color de las letras
			size(*0.7) /// Cambia el tamaño de las letras
			position(6)) /// Opciones de los números
	title("Población rural", size(*0.8)) subtitle("Colombia 2009" " ", size(*0.8)) ///
	name(mapa_10, replace)
	
**Mapa de diagrama - barra
grmap using "co_dep_shp", id(_ID) fcolor(white) ///
	diagram(	var(p_pob_rur) ///
				refweight(p_pob_rur) ///
				fcolor(green) ///
				x(_CX) y(_CY) size(1)) /// Opciones de diagrama
	label(	x(_CX) y(_CY) label(p_pob_rur) ///
			color(black) size(*0.7) position(3)) /// Opciones de los números
	title("Población rural", size(*0.8)) subtitle("Colombia 2009" " ", size(*0.8)) ///
	name(mapa_11, replace)

**Mapa de diagramas - pie
grmap using "co_dep_shp", id(_ID) fcolor(stone) ///
	diagram(	var(p_pob_rur p_pob_urb) ///
				fcolor(green white) ///
				x(_CX) y(_CY) size(0.6)) /// Opciones de diagrama
	label(		x(_CX) y(_CY) label(p_pob_rur) ///
				color(black) size(*0.7) position(3)) /// Opciones de los números
	title("Población rural", size(*0.8)) subtitle("Colombia 2009" " ", size(*0.8)) ///
	name(mapa_12, replace)

**Mapa multivariable
grmap ingresos_hogar_jefe using "co_dep_shp", id(_ID) ///
	clmethod(custom) clb(367892.3 590846.4 715309 1091704) /// 
	legstyle(3) fcolor(Blues) ndf(gs8) /// Opciones de colores
	legend(	order(	1 "No hay información disponible" ///
					2 "Ingreso bajo"  ///
					3 "Ingreso medio" ///
					4 "Ingreso alto") ///
			c(1) position(7) ring(0)) /// Opciones de la leyenda
	diagram(	var(p_pob_rur p_pob_urb) ///
				fcolor(green white) x(_CX) y(_CY) size(.5)) /// Opciones de diagrama
	label(		x(_CX) y(_CY) label(p_pob_rur) ///
				color(black) size(*0.5) position(3) gap(1)) /// Opciones de los números
	title ("Ingresos del hogar por departamento", size(*0.8)) ///
	subtitle("Colombia" "2009", size(*0.6)) /// Titulos
	name(mapa_13, replace)

*-------------------*
*VIII. Otros ejemplos *
*-------------------*	
help grmap
*https://ideas.repec.org/c/boc/bocode/s456812.html (Descargar la base de datos para ejecutar los ejemplos)

* ANEXO *
*----------------*
* Programas UWS: Users Written Software *  http://ideas.repec.org/i/c.html
*----------------*
/*
Si trabaja desde los computadores de la universidad y desea usar un comando desarrollado por un usuario, es posible que se genere un error intentando instalar el programa. Puede utilizar el siguiente comando al inicio del do-file para superar las restricciones:

global dir "Su carpeta de trabajo"
sysdir set PLUS "C:\Users/`c(username)'\Dropbox\Taller de Stata\2019-I\4 - Clases\Clase 11 - Graficos 3 - Mapas"
*/
ssc new
ssc hot
ssc hot, n(20)
ssc hot, author(Cox)
ssc describe outreg2
*--------------------------------*
*I. Herramientas para crear mapas en versiones de Stata anteriores a 15
*--------------------------------*	
ssc install spmap, replace // Construir mapas. Añadir información a los mapas
ssc install shp2dta, replace //Transformar datos de mapas vectoriales a formato de stata
