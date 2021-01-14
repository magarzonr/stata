*****************************************************
** Universidad de los Andes - Facultad de Economía **
** 			       Taller de Stata                 **
**												   **
** 				Miguel Garzón-Ramírez              **
** 			   Cristhian Acosta-Pardo              **
** 			   						               **
** 	  	          Clase 7: 	Macros                 **
*****************************************************
clear all
cap log close
set more off

cd "_____" // Coloque entre las comillas la dirección completa de la carpeta donde están los datos. 
webuse auto, clear

/* Los globals y los locals son conjuntos de elementos que pueden ser utilizados
en cualquier parte del código */

*------------------*
* I. Introducción  *
*------------------*
* Global
global X rep78  // Un elemento e.g. El nombre de una variable
global uno=1 // Otro elemento e.g. Un número
describe $X
replace $X = $uno if missing($X) 
 
// Las variables de una regresión
global Y "price"
sum $Y
global X "mpg headroom trunk weight length turn displacement gear_ratio" 
des $X
reg $Y $X
reg $M $X // No genera error, pero no ejecuta lo que deseamos

macro dir

* Local
local Y price 
sum `Y' 
macro list

local X "mpg headroom trunk weight length turn displacement gear_ratio"
des `X'
reg rep78 `X' 
reg `Y' `X'
reg `M' `X' // No genera error, pero no ejecuta lo que deseamos

macro dir 
/* El local solo exite mientras se ejecuta el grupo de líneas seleccionado. El local solo se verá en la lista de macros si se ejecuta desde la linea 41 hasta la linea 45. Esto es un bloque de código */

*-------------------------------* 
* II. Ejemplos de uso de macros *
*-------------------------------*
*********
* Ej. 1: direcciones de archivos en Windows
*********
* Con global
global carpeta "_______" // Coloque entre las comillas la dirección completa de la carpeta donde están los datos. 
global archivo "Base_clase_7" 
cd "$carpeta"
use "$archivo" , clear
*use "${carpeta}\${archivo}", clear	// No ejecuta porque Stata entiende el símbolo '\' como "ignorar la macro siguiente", entonces se usa '/' como en la siguiente línea.
use "${carpeta}/${archivo}",clear  // Cargar un archivo por medio de su dirección completa.

* Con local
local carpeta "_______" // Coloque entre las comillas la dirección completa de la carpeta donde están los datos. 
local archivo "Base_clase_7" 
**use "`carpeta'\`archivo'", clear	// No ejecuta porque Stata entiende el símbolo '\' como "ignorar la macro siguiente", entonces se usa '/'
use "`carpeta'/`archivo'",clear   

/* Ej. 1.2: direcciones de archivos en Mac
clear all 
local carpeta "______" // Coloque entre las comillas la dirección completa de la carpeta donde están los datos. 
local archivo "Base_clase_7"

use "`carpeta'/`archivo'", clear 
   
global carpeta "____"  // Coloque entre las comillas la dirección completa de la carpeta donde están los datos. 
global archivo "Base_clase_7" 
use "${carpeta}/${archivo}",clear */

*************
*Ej. 2: Tabla con el valor de exportaciones a Venezuela en Enero de 2005 según distintas categorías --> Vamos a crear una especie de "interfaz"
*************
cd "$carpeta"
use Base_clase_7 , clear

*A. Opciones elegidas por el usuario - Parámetros
 *1. Moneda: Dólares (FOB_DOL) o pesos (FOB_PES) FOB: Free on Board - Valor de la mercancía sumado el transporte hasta el puerto de salida
local moneda FOB_PES 

 *2. Criterio (Se puede escoger más de uno): 
  *a) Sector (CIIU_Seccion)   *b) Exportaciones tradicionales (TRAD_NO_TRAD)  *c) Departamento de origen (DPTO_ORIGEN)   *d) Modo de transporte (VIA)
local criterio VIA TRAD_NO_TRAD
  
  *3. Forma: 0 = valor Exports, 1 = porcentaje del total 
local forma=1

*B. Ejecución del Programa --> Esta sería la parte del código que está detrás de la "interfaz"
egen TOTAL=sum(`moneda')
collapse TOTAL (sum) `moneda', by (`criterio')

/* if sirve para que el programa cree la tabla que el usuario seleccione en la opción 3. Forma. */
 
if `forma'==0{
	drop TOTAL
}
 else if `forma'==1{
	gen PCT=(`moneda'/TOTAL)*100
	drop `moneda' TOTAL
	format PCT %3.2f
}

export excel using "tablas2.xlsx", firstrow(var) sheet("`moneda'`criterio'`forma'", replace) // Guarda la tabla en la carpeta establecida con el comando cd
***********
* Ej. 3: Uso de comillas en macros para condicionales* 
***********
cd "$carpeta"
use Base_clase_7 , clear

*A. Opciones elegidas por el usuario*
 *1. Moneda: Dólares (FOB_DOL) o pesos (FOB_PES)
local moneda FOB_DOL 
 
 *2. Criterio (Se puede escoger más de uno): 
  *a) Sector (CIIU_Seccion, CIIU_2, CIIU_3, CIIU_4) 
  *b) Exportaciones tradicionales (TRAD_NO_TRAD)
  *c) Departamento de origen (DPTO_ORIGEN)
  *d) Medio de transporte (VIA)
 local criterio DPTO_ORIGEN
 
 *3. Forma: valor = valor Exports, porcentaje = porcentaje del total 
local forma "valor"

*B. Ejecución del Programa 
egen TOTAL=total(`moneda')
collapse TOTAL (sum) `moneda', by (`criterio')

if "`forma'"=="porcentaje"{
	gen PCT=(`moneda'/TOTAL)*100
	drop `moneda' TOTAL
	format PCT %3.2f
}
else if "`forma'"=="valor"{
	drop TOTAL
}
else{
	display as red "Opción no válida, por favor elegir porcentaje o valor"
}
export excel using "ejemplos.xlsx", firstrow(var) sheet("Ejemplo 3", replace) 

*----------------------------* 
* III.  Funciones extendidas *
*----------------------------*  
cd "${carpeta}"
local folders: dir . dir "Prueba*"
local dirfiles: dir . files "*.dta"
macro dir
* También funcionan con global
global folders: dir . dir "*"
global dirfiles: dir . files "*"
macro dir

use "${carpeta}/${archivo}",clear  
local etiqueta_var : var label DPTO_ORIGEN // Guardar etiqueta de variable

local etiqueta_valor : label trad_no_trad 2 // Guardar una etiqueta de valor
macro dir
 
local tipo : type NIT9 // Guardar tipo de variable
local formato : format MES_EM //Guardar formato de variable
local orden : sortedby // Guardar la variable que ordena la base de datos
local palabras : word count "Esta frase" tiene 4 palabras // Contar palabras
macro dir

*--------------------------------------* 
* IV.  Macros local: tempvar y tempfile*
*--------------------------------------*  
* A: Tempvar
webuse auto, clear
/* se requiere reemplazar los missing de rep78 por el promedio 
   de la variable por tipo de origen (doméstico o extranjero)  */
* Reemplazar los missing values de la variable rep78 con el promedio por tipo de carro 
tempvar newvar1 newvar2
bys foreign : egen `newvar1' = mean(rep78)
gen `newvar2' = floor(`newvar1')
replace rep78 = `newvar2' if missing(rep78)

* B: Tempfile
preserve
	collapse (mean) media_precio = price, by(foreign)
	format media_precio %8.0fc
	tempfile data
	save `data', replace
restore
merge m:1 foreign using `data', nogen
*---------------------------------------------------------------* 
* V.  Macros con los retornos de los programas y en expresiones *
*---------------------------------------------------------------*  
cap log close

local fecha =c(current_date)
log using "log_`fecha'", replace

disp "este log tiene en el nombre la fecha de hoy, que es `fecha'"

cd "$carpeta"
use Base_clase_7 , clear

sum FOB_DOL
return list
local FOB_DOL_mean=r(mean)

reg FOB_DOL DPTO_ORIGEN
ereturn list
local estimacion = e(model)
global estimacion = e(model)
macro dir

log close

*view "log_`fecha'.smcl"

cap log close
log using "log_`=c(current_date)'", replace
br FOB*
list FOB* in 1/`=2+3'
log close
*view "log_`=c(current_date)'.smcl"
macro dir

