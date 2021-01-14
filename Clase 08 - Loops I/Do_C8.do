*****************************************************
** Universidad de los Andes - Facultad de Economía **
** 			       Taller de Stata                 **
**												   **
** 				Miguel Garzón-Ramírez              **
** 			   Cristhian Acosta-Pardo              **
** 			   						               **
** 	  			  Clase 8:  Loops -I               **
*****************************************************
clear all
cap log close
set more off, perm 

************
* I. while *
************
* Ejemplo 1
set trace on
local i=1 // crear local de control - iterador
macro dir
while `i'<=15{
	display `i'
	local i=`i'+1   // es equivalente a local ++i   			 
}
* Ejemplo 2
set obs 100 // crear observaciones
gen var0=. // crear variable numérica vacia
local i=1 
while `i'<=100{
	display `i'
	replace var0=`i' in `i'
	local ++i    // es equivalente a local i=`i'+1
}
*****************
* II. Forvalues *
*****************
* Ejemplo 1
forvalues i=1/20{ // lista de números con secuencia
	dis `i'
} 
* Ejemplo 2
clear
set obs 100
forvalues i=0(2)20{  // lista de números con secuencia
	dis `i'
	gen var`=`i'/2'=`i'+_n
}  
**************************
* III. Foreach - directo *
**************************
* Ejemplo 1: Iterando sobre cadenas de caracteres
foreach x in algo1 algo2 { 
	display "`x'"
}
* Ejemplo 2: Iterando sobre cadenas de caracteres de varias palabras
set trace on
foreach y in "algo 1" "alguno 2" { 
	display "`y'"
	display length("`y'")
}
* Ejemplo 3: Iterando sobre números (que están en nombres de variables)
set trace on
local i=1  //crear un local para que lleve la cuenta de una iteración
foreach x in 1 2 3 4 5 9 10 { 	// Esta notación no usa la escritura de secuencias de números
	display "Esta es la iteración `i'"
	display `x'
	replace var`x'=888 if var`x'==20
	local ++i
}

******************************
* IV. Foreach - Sobre listas *
******************************
* 1) Lista en Local
local variables "var1 var2 var3" 
foreach x of local variables {
	sum `x'
} 
* 2) Lista en Global
global variables "var1 var2 var3" 
foreach x of global variables {
	sum `x'
}
global variables "var1 var2 var3" 
foreach x of global variables {
	sum `x'
}
* 3) Lista de nombres de variables 
foreach var of varlist $variables {
	egen sd_`var'=sd(`var')
}
foreach var of varlist var* {
	egen max_`var'=max(`var')
}
foreach var of varlist var1-var3{
	sum `var'
}
*Notación abreviada de iteración sobre variables
for var m*: replace X=X*100
for var v*: replace X=X*100 if X>21

* 4) Numlist
foreach x of numlist 1/10 12 56 73 45 100(3)106 {
	* Esta notación si usa la escritura de secuencias de números
	display `x'
}

************************************************
* V - Ejemplo: programación del comando decode *
************************************************
global principal "_____" // Coloque entre las comillas la dirección completa de la carpeta donde están los datos. 
cd "$principal"
use Uchoques_2013_et, clear

br hizo1 
decode hizo1, gen(hizo1_s)
* ¿Qué hicieron las familias frente al choque 1, Accidente o enfermedad de algun miembro del hogar...
* Crear una variable que contenga la informacion de la variable hizo1 en cadenas de caracteres, hizo1_str
gen hizo1_str=""
order hizo1 hizo1_str hizo1_s  
br hizo1 hizo1_str hizo1_s  

levelsof hizo1, local(levels)

foreach x of local levels{
	display "`x'"
	local et: label hizoc `x'
	replace hizo1_str="`et'" if hizo1==`x' 
}

count if hizo1_str!=hizo1_s
macro dir