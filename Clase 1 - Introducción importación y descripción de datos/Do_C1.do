*********************************************************
**   Universidad de los Andes - Facultad de Economía   **
**   			   Taller de Stata 2020-II             **
**												       **
** 			  	    Miguel Garzón-Ramírez              **
** 			   						                   **
** Clase 1 - Introducción e importación  de variables  **
*********************************************************

***************
* I) Interfaz *
***************
webuse auto, clear
* En la ventana de revisión se encuentran todos los comandos que se hayan empleado hasta el momento
* En la ventana de resultados se muestran el producto de la ejecución de los comandos
* En la ventana de variables se lista y describe la composición de la base de datos
* En la ventana de propiedades se describe la variable seleccionada y se muestran datos generales de la base de datos.
* En la ventana de comandos se puede escribir y ejecutar un comando por vez.

* 1. Comando display: Con este comando se le puede pedir a Stata que nos muestre un texto determinado

display "Bienvenidos a la clase de Stata" // comentario de comando 

*"Bienvenidos a la clase de Stata" // ¿Qué ocurrió?

dis 2+2 // Este comando también puede ser empleado como una calculadora 

** Archivos de ayuda y búsqueda e instalación de paquetes 
help dis // Esto muestra el archivo de ayuda del comando especificado. 

* 2. ¿Cómo incorporar comentarios en el do-file?

*  Opción 1: Este comentario se puede hacer al final de una linea de código
/* Opción 2: Este comentario se puede hacer al final de una línea de
			 código y se puede extender 
			 por mas líneas, por eso
			 tiene inicio (/*) y fin (*/) */

display "Opción 3.1:" // Este comentario se puede hacer al final de una linea de código
display "Opción 3.2: " /// Esto permite comentar varias partes de un comando y le dice a Stata que el comando continua en ejecución
		"Dividir la ejecución de un cómando en " /// Este sería el segundo comentario en el comando
		"varias líneas" // Así se le dice a Stata que el comando acaba su ejecución
** Ejemplos:
display "Esta es la clase de Taller de Stata" // Esta opción permite comentar sobre los comandos mismos
display "Esta es la clase de Taller de Stata" // Esta también
display "20+10-5*3" /*Vale la pena notar que todo lo que vaya entre comillas ("") 
					 se va entender como un texto. */
display 20+10 /// Interrupción para seguir en la siguiente línea
		-5*3 // Fin del comando
		
		

display 20+10 /* Interrupción para seguir en la siguiente línea
		*/ -5*3 // Fin del comando
	
* 3. ¿Qué se puede hacer cuando los comandos son muy largos? 
* Forma 1:
display /// como veíamos, aquí puede comentar
"Esta es la clase de Taller de Stata" // y comentar al final
* Forma 2:
dis /* Se separa la ejecución de un comando en varias líneas
*/ "Esta es la clase de Taller de Stata"
* Forma 3: 
# delimit ;
 dis 
 "Esta es la clase de Taller de Stata";
# delimit cr

* Forma 3 abreviada
# d;

 dis
 "Para terminar la ejecución de este comando debo finalizarlo con un punto y coma";
 dis
 "Puedo ejecutar una serie de comandos dentro del espacio del delimit";
 
# d cr
* Forma 4: vaya al menu "Ver" y seleccione la opción "Envolver líneas"

* 3. Tipos de archivos

* Base de datos	.dta
* Do-file	.do
* Log-file	.log
* Archivo de ayuda	.hlp
* Archivos de extensión	.ado 

**************************************************
* II) Exploración de bases con comandos en Stata *
**************************************************
clear all 
* 1. Defina el directorio de trabajo (¿Dónde están los datos? ¿Donde se guardan los resultados?)
cd "G:\Mi unidad\4_DOCENCIA\Taller de Stata\2020-II\4 - Clases\Clase 1 - Introducción importación y descripción de datos"

* 2. Cargue la base de datos de la clase.
use "notas", clear 
	compress // comprime la base de datos para reducir la cantidad de memoria usada
	browse // Con esto puede ver la base de datos
	edit // Con esto puede ver y editar la base de datos 
	br codigo genero n_def 

* 3. Expore la base base de datos con los comandos describe y codebook
describe
codebook

* 4. Explore variables categóricas con el comando tabulate.
tabulate genero
tab col_mixto, missing

* 5. Explore variables continuas con el comando summarize
summarize n_def
sum parcial1 parcial2

* 6. Organice la base de datos de acuerdo con las notas finales
sort n_def
gsort -parcial1 +n_def

* 7. Guarde una base de datos que contenga solamente la variable código y nota definitiva

keep codigo n_def // otra opción : drop genero col_mixto parcial1 parcial2 e_final e_final2 n_max
save notas_def, replace

************************************
* III) Uso de la bitácora log-file *
************************************
clear all
cap log close
** Los log-files son usados como bitácoras de trabajo, en donde queda registrado todo lo que se muestra por la ventana de resultados 
* 1. Cree el log-file
log using "bitacora_C1.log", replace // Note que en la ventana de resultados aparece la fecha, la hora y el tipo.
* En el comando anterior se añadió la opción replace por si ya existía un archivo con este nombre 
* Sino se especifica el formato de texto .log, por defecto, Stata crea un archivo con extensión .smcl

* 2. Repitamos los comandos de la exploración que hicimos anteriormente
	cd "G:\Mi unidad\4_DOCENCIA\Taller de Stata\2020-II\4 - Clases\Clase 1 - Introducción importación y descripción de datos" 
	use "notas", clear  
	describe // 3. Expore la base base de datos
	codebook
	tabulate genero // 4. Explore variables categóricas
	tab col_mixto, missing
	summarize n_def // 5. Explore variables continuas
	sum parcial1 parcial2
	sort n_def // 6. Organice la base de datos
	gsort -parcial1 +n_def
	
* 3. Cierre el registro en el log-file
log close

* 4. Abra el log-file desde el do-file
view bitacora_C1.log

* 5. ¿Cómo escribir sobre log-files ya creados? --> opción append 
log using "bitacora_C1.log", append

* 6. ¿Cómo "apagar" y "prender" un log-file? 
dis "Lo que voy a hacer abajo no aparece"
log off // "Apagando" el log 
tabulate n_max 
log on // "Prendiendo" el log
display "Pero ahora si aparece"
describe codigo
log close
view bitacora_C1.log

******************************************
* IV)  Importar datos de otros formatos  *
******************************************
clear all
cap log close

log using "bitacora_C1_importacion.log", replace
cd "G:\Mi unidad\4_DOCENCIA\Taller de Stata\2020-II\4 - Clases\Clase 1 - Introducción importación y descripción de datos" 
dir // ¿Que hay en la carpeta?

* 1 Archivo Excel
import excel "NBI_2011", describe  
import excel "NBI_2011.xlsx", clear // Si se tiene un archivo de Excel con varias hojas y no se especifica la opción sheet ,Stata toma la primera hoja 
import excel "NBI_2011.xlsx", sheet("Municipios") cellrange(A5:G1127) firstrow clear

* 2 Archivos de texto (.csv - .txt)

* 2.1 Separado por comas(.csv)
type NBI_1993.csv, lines(20)

import delimited "NBI_1993.csv", delimiter(comma) clear 
import delimited "NBI_1993", delimiter(comma) rowrange(1:1001)   stringcols(1 2)  clear //permite ajustar el número de columnas o variables. No es necesario colocar la extensión, por defecto es .csv

* 2.2 Separado por espacio(.txt)
type NBI_1993.txt, lines(20)

import delimited "NBI_1993.txt", delimiter(tab) clear stringcols(1 2)

* 3 Archivo dbf

import dbase "cabeceras_dane_2012.dbf", clear

* 4 Introducción directa de datos
 clear
 input var1 var2 
  1 2 
  3 4 
  5 6
 end
log close
