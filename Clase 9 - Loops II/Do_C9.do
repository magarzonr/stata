*****************************************************
** Universidad de los Andes - Facultad de Economía **
** 			       Taller de Stata                 **
**												   **
** 				Miguel Garzón-Ramírez              **
** 			   Cristhian Acosta-Pardo              **
** 			   						               **
** 	  			  Clase 9:  Loops-II               **
*****************************************************
global clase_9 "_____" // Coloque entre las comillas la dirección completa de la carpeta donde están los datos. 

***************************
* I. Tokenize - framename *
***************************
* Crear múltiples local con un índice
tokenize primero segundo tercero cuarto quinto
macro dir

* Ejemplo 1: crear un diccionario de datos

* Aplicar tokenize a una lista en un local
cd "$clase_9"
use Uchoques_2013_et, clear 

gen nombre=""
gen descripcion=""

*ssc install findname
findname id_hogar-hizo15, local(nombres)
local cantidad: word count `nombres'
tokenize `nombres'

forvalues j=1/`cantidad' {
	replace nombre="``j''" if _n==`j'
	local etiqueta: var label ``j''
	replace descripcion="`etiqueta'" if _n==`j'
}
keep nombre descripcion
keep if descripcion!=""

export excel "Diccionario.xlsx", firstrow(variables) replace

***************************
* II. Tokenize con frases *
***************************
* ¿Cómo es la sintaxis cuando la lista contiene elementos con varias palabras? 
tokenize `""primer elemento" "segundo elemento""'
macro dir 
* Ejemplo 2: Colocar etiquetas a las variables según el código que identifica el choque
cd "$clase_9"
use "Uchoques_2013", clear

* Definición de etiquetas de choques

# d;  
tokenize	`""Accidente o enfermedad de algún miembro del hogar que le impidió realizar sus actividades cotidianas"
			"Muerte del que era jefe del hogar o del cónyuge"
			"Muerte de algún(os) otro(s) miembro(s) del hogar"
			"Separación de los cónyuges"
			"El jefe del hogar perdió su empleo"
			"El cónyuge perdió su empleo"
			"Otro miembro del hogar perdió su empleo"
			"Llegada o acogida de un familiar en el hogar"
			"Tuvieron que abandonar su lugar de residencia habitual"
			"Quiebra(s) y/o cierre(s) del(los) negocio(s) familiar(es)"
			"Pédida de la vivienda"
			"Pérdida o recorte de remesas"
			"Robo, incendio o destrucción de bienes del hogar (en casa o raponeo)"
			"Fueron víctimas de la violencia"
			"Sufrieron inundaciones, avalanchas, derrumbes, desbordamientos o deslizamientos, vendavales, temblores o terremotos""'
;
# d cr  

macro dir

forvalues i=1/15{
	label var tuvo_choque`i' "La familia tuvo: ``i''"
}

forvalues i=1/15{
	label var imp_econ`i' "Impacto económico de: ``i''"
}

forvalues i=1/15{
	label var hizo`i' "Hizo ante: ``i''"
}

label var id_hogar "Identificador del hogar"
save Uchoques_2013_et, replace

*********************************************
* III. Llenar una matriz con loops anidados *
*********************************************
*Crear una matriz de (6x4) con missing values
matrix diferencianumeros = J(6,4,.) 
matrix list diferencianumeros 

* Llenar la matriz con un patrón donde al número de fila se le reste el número de la columna

forvalues fila=1(1)6 {
 forvalues columna=1(1)4{
  matrix diferencianumeros[`fila',`columna'] = `fila'-`columna' 
 }
}
matlist diferencianumeros

*********************************************************************************
* IV - Loop anidado- Programación del comando encode para un grupo de variables *
*********************************************************************************
cd "$clase_9"

use Uchoques_2013_et, clear
*decode hizo1, gen(hizo1_s)
* ¿Qué hicieron las familias frente al choque 1, Accidente o enfermedad de algun miembro del hogar...
* Crear una variable que contenga la informacion de la variable hizo1 en cadenas de caracteres, hizo1_str
levelsof hizo1, local(levels)
gen hizo1_str=""
foreach x of local levels{
	display "`x'"
	local hizo_et : label hizoc `x'
	replace hizo1_str="`hizo_et'" if hizo1==`x' 
}

* Repetir el proceso anterior para todas las variables hizo* iterando sobre el número (solución del video)
use Uchoques_2013_et, clear
forvalues i=1/15{
    levelsof hizo`i', local(levels)
	gen hizo`i'_str=""
	foreach x of local levels{
		display "hizo`i'   `x'"
		local hizo_et : label hizoc `x'
		replace hizo`i'_str="`hizo_et'" if hizo`i'==`x' 
	}
}

* Repetir el mismo proceso para todas las variables hizo* iterando sobre el nombre completo
use Uchoques_2013_et, clear
foreach var of varlist hizo* {
	display "`var'"
	levelsof `var', local(levels)
	gen `var'_str=""
	foreach x of local levels{
		display "`var'   `x'"
		local et : label hizoc `x'
		replace `var'_str="et'" if `var'==`x' 
	}
}	

***********************
* V - Loop anidado II *
***********************
* Repetir el proceso anterior para todas las variables hizo* tuvo_choque* e imp_econ* iterando sobre el número 
cd "$clase_9"
use Uchoques_2013_et, clear
foreach list in hizo tuvo_choque imp_econ{
	forvalues i=1/15{
		levelsof `list'`i', local(levels)
		gen `list'`i'_str=""
		foreach x of local levels{
			display "`list'`i'    `x'"
			if "`list'"== "hizo"{ // definición del nombre de las etiquetas de valor
				local lab_val hizoc
			}
			else if "`list'"== "tuvo_choque"{
				local lab_val tuvoc
			}
			else if "`list'"== "imp_econ"{
				local lab_val impe
			}
			local et : label `lab_val' `x'
			replace `list'`i'_str="`et'" if `list'`i'==`x' 
		}
	}
}


* Repetir el mismo proceso para las variables tuvo_choque* e imp_econ* iterando sobre el nombre completo
use Uchoques_2013_et, clear

foreach list in hizo tuvo_choque imp_econ{
 	foreach var of varlist `list'* {
		display "`var'"
		levelsof `var', local(levels)
		gen `var'_str=""
		foreach x of local levels{
			display "`var'   `x'"
			if "`list'"== "hizo"{ // definición del nombre de las etiquetas de valor
				local lab_val hizoc
			}
			else if "`list'"== "tuvo_choque"{
				local lab_val tuvoc
			}
			else if "`list'"== "imp_econ"{
				local lab_val impe
			}
			local et : label `lab_val' `x'
			replace `var'_str="`et'" if `var'==`x' 
		}
	}	
}

********************************************************************************
**********************
* I. Otros ejemplos  *
**********************
cd "$clase_9"
use "Base_clase_9", clear
	
 /*Regiones:
 1. América central y caribe: ccodecow<100
 2. América del sur: 100<=codecow<200
 3. Europa 1: 200<=codecow<300
 4. Europa 2: 300<=codecow<400
 5. África 1: 400<=codecow<500
 6. África 2: 500<=codecow<600
 7. Mundo árabe: 600<=codecow<700
 8. Asia 1: 700<=codecow<800
 9. Asia 2: 700<=codecow<900
 10. Oceanía: 900<=codecow<1000*/
 
 gen region=.
 tokenize `""América central y Caribe" "América del sur" "Europa 1" "Europa 2" "África 1" "África 2" "Mundo árabe" "Asia 1" "Asia 2" "Oceania""'
 macro dir
 forvalues i=1(1)10{
	display "Se generan los códigos para los países en ``i'' "
	replace region=`i' if ccodecow>=(`i'-1)*100 & ccodecow<`i'00
	display  "         "   (`i'-1)*100   "                 " `i'00            
	display "Se genera el label de ``i'' para la región `i' "
	label define regionl `i' "``i''", add 
 }

 label values region regionl

*III. Uso de Macros para Ejecutar un Programa y el comando Levelsof
 *Quiero averiguar, para un cierto intervalo de tiempo, cuántos y cuáles
 *tipos de régimenes políticos tuvo un cierto país. 
 
 label define regimen 0 "Democracia parlamentaria" ///
                      1 "Democracia mixta"         ///
				      2 "Democracia presidencial"  ///
					  3 "Dictadura civil"          ///
					  4 "Dictadura militar"        ///
					  5 "Monarquía dictatorial"

 label values chga_hinst regimen
 
 *Información para ser introducida por el usuario*
  local anho_inicial=1948
  local anho_final=1998
  local pais="Colombia"
 
 *1. Definir un local con los regímenes políticos para el país y los años introducidos por el usario
  br if cname=="`pais'" & year>=`anho_inicial' & year<=`anho_final'
  levelsof chga_hinst if cname=="`pais'" & year>=`anho_inicial' & year<=`anho_final', local(levels) 
  *local a=r(levels) // local b=`levels'
  
  macro dir

 *2. Hacer un Tokenize para que cada régimen quede guardado en un local
  macro dir
  tokenize "`levels'"

 *3. Contar el número de regímenes para el display de la información
  local numero: word count `levels'
  macro dir

 *4. Introducir en un local el label value asociado al número de cada régimen
  forvalues i=1(1)`numero'{
	 quietly: local reg`i': label regimen ``i''
  }
	macro dir
 *5. Definir el local de resultado
  if `numero'==1{
	 local resultado "El país `pais' tan solo tuvo un régimen institucional entre los años `anho_inicial' y `anho_final'. este fue `reg1'"
  }
  if `numero'==2{
	 local resultado "El país `pais' tuvo dos regímenes entre los años `anho_inicial' y `anho_final'. Estos fueron  `reg1' y `reg2'"
  }
  if `numero'==3{
	 local resultado "El país `pais' tuvo tres regímenes entre los años `anho_inicial' y `anho_final'. Estos fueron  `reg1', `reg2' y `reg3'"
  }
  if `numero'==4{
	 local resultado "El país `pais' tuvo cuatro regímenes entre los años `anho_inicial' y `anho_final'. Estos fueron  `reg1', `reg2' , `reg3' y `reg4'"
  }
  if `numero'==5{
	 local resultado "El país `pais' tuvo cinco regímenes entre los años `anho_inicial' y `anho_final'. Estos fueron  `reg1', `reg2' , `reg3' , `reg4' y `reg5'"
  }

 *6. Mostrar el resultado en la pantalla de Stata 
  display "`resultado'"
