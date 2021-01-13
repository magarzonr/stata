*****************************************************
** Universidad de los Andes - Facultad de Economía **
** 			   Taller de Stata 2020-II             **
**												   **
** 				Miguel Garzón-Ramirez              **
** 			   Cristhian Acosta-Pardo              **
** 			   						               **
** 		        Clase 3-Variables II               **
*****************************************************
* Empezamos los do-files limpiando el espacio de trabajo y especificando los comando que permiten la ejecución continua
clear all 
cap log close
set more off 

log using "log_clase3", replace

*cd "C:\Users/`c(username)'\Dropbox\Taller de Stata\2020-II\4 - Clases\Clase 3 - Variables II"
cd "G:\Mi unidad\4_DOCENCIA\Taller de Stata\2020-II\4 - Clases\Clase 3 - Variables II"

use "Base_clase_3", replace 
*----------*
* Contexto: 
*----------*
* Esta base de datos contiene información de las notas de los estudiantes de una clase. Se pide realizar las siguientes tareas: 
*		(a)	Etiquetar datos
*		(b) Limpiar la base de datos (Generar y recodificar variables, manejar valores perdidos)
*		(c) Distinguir los resultados por género, semestre, año de entrada y carrera 
*		(d) Generar variables de estadísticas del desempeño de los estudiantes (nota más alta, más baja, promedio, etc.)

*****************
* (I) Etiquetas * 
*****************
* (A) Bases de datos
label data "Notas de los estudiantes de una clase"
describe

* (B) Variables
label var codigo "Identificación del estudiante"
label var genero "Género del estudiante" 
label var col_mixto "Si viene de un colegio mixto" 
label var parcial1 "Notas del parcial 1" 
label var parcial2 "Notas del parcial 2" 
label var e_final "Examen final - missing values 1" 
label var e_final2 "Examen final - missing values 2" 
label var programa "Primera carrera del estudiante"

* (C) Valores
label define etbinario 1 "Sí" 0 "No", replace
label values col_mixto etbinario
 
**********************************************************
* (II) Manejo de missing values con  mvdecode - mvencode *
**********************************************************
* Etiquetas 
count if e_final >=3.0
count if e_final >=3.0 & !missing(e_final)
label define missing .a "Faltó con excusa" .b "Faltó sin excusa", replace
label values e_final  missing
label var e_final "Nota examen final con excusas"

tab e_final, miss

* De valor a missing value
gen e_final3=e_final2
mvdecode e_final3, mv(98=.a \ 99=.b)  // Método 1. 

drop e_final3 

mvdecode parcial1 parcial2 e_final2,  mv(98=.a \ 99=.b) // Método 2. Especifica diferentes tipos de missing values
mvencode parcial1 parcial2 e_final, mv(.a=0 \ .b=0) // De todas maneras, sobre esta variable vamos a calcular la calificación final

order codigo genero col_mixto programa parcial1 parcial2 e_final
br codigo genero col_mixto programa parcial1 parcial2 e_final

*** Cálculo de nota definitiva
gen n_def=(parcial1+parcial2+e_final)/3
sort n_def

*************************
* (III) Recode - encode *
*************************
gen aprobado=(n_def>=3 & n_def<=5) 
replace aprobado=. if missing(n_def) // Es importante decirle a Stata que tome en cuenta los missing values de la variable original
label var aprobado "Marca si un estudiante aprobó el curso"

recode aprobado (0=1) (1=0), gen(reprobado)
label var reprobado "Marca si un estudiante reprobó el curso"
label values aprobado reprobado etbinario

encode genero, gen(genero_c)

*******************************************
* (IV) Funciones para variables de texto  * 
*******************************************
* Para ver las estadísticas creemos una variable que indique el año de ingreso del estudiante
* 1) Extraer caracteres por posición
gen a_ing=substr(codigo,1,4)
destring a_ing, replace

*Arreglar la variable programa
tab programa 

* 2) Funciones para mayúsculas y minúsculas
replace programa=strupper(programa) 
tab programa // Dos categorias menos pero no se ajustan las tildes
replace programa=strlower(programa)
tab programa // Esto es muy difícil de leer
replace programa=strproper(programa) // Inicial de las palabras en mayuscula
tab programa 

* 3) Expresiones regulares
* Consulte el siguiente recurso para una síntesis con ejemplos: http://soc596.blogspot.com/
	*----------------------------------------------------------------------*
	* Expresión regular			Significado                                *
	*----------------------------------------------------------------------*
	* regexm (match)		Operación lógica - Encontar coincidencias      *
	*						con una cadena de caracteres. Se usa con "if". *
	* regexr (replace)		Reemplaza directamente una cadena de           *
	*						caracteres por otra.                           *
	* regexs (subexpresión)	Reemplaza una cadena de caracteres con la      *
	*						expresión identificada con regexm.    		   *
	* 		regexs(0)			Toma la expresión completa                 *
	*		regexs(1)			Si la expresión tiene varias partes,       *
	*							Toma solo la primera                       *
	*		regexs(2)			Toma solo la segunda parte de la expresión *
	*----------------------------------------------------------------------*
	
* Veamos los resultados de los estudiantes de gobierno
br programa if regexm(programa,"Gob") //Identificando expresiones regulares

* Solución 1: Identificar las tres primeras letras del nombre del programa y reemplazar
br programa
gen solucion1=strlower(programa)

replace solucion1="Economía" if regexm(solucion1, "eco") 
replace solucion1="Gobierno y Asuntos Pub." if regexm(solucion1, "gob")
replace solucion1="Derecho" if regexm(solucion1, "der")

*Solución 2
tab programa
gen solucion2=regexr(programa,"Gob. ","Gobierno ")
replace solucion2=regexr(solucion2,"As. ","Asuntos ") // equivalente a la función: subinstr(programa,"As. ","Asuntos ",1)
replace solucion2=regexr(solucion2,"íA", "ía")
replace solucion2=regexr(solucion2,"ia", "ía")
replace solucion2="Economía" if solucion2=="Econ"
tab solucion2 // Hecho

*Solución 3
gen gob=regexs(0) if regexm(programa,"(^[A-Z][a-z][a-z]*)[ ]([A-Z])")
gen gob1=regexs(1) if regexm(programa,"(^[A-Z][a-z][a-z]*)[ ]([A-Z])")
gen gob2=regexs(2) if regexm(programa,"(^[A-Z][a-z][a-z]*)[ ]([A-Z])")
gen gob3=regexs(2)+" "+regexs(1) if regexm(programa,"(^[A-Z][a-z][a-z]*)[ ]([A-Z])")
/* Para otros casos de extracción de expresiones regulares (por ejemplo regexs(1)) 
consulte: https://stats.idre.ucla.edu/stata/faq/how-can-i-extract-a-portion-of-a-string-variable-using-regular-expressions/ */
drop gob*
gen solucion3=regexs(0) if regexm(programa,"(^[A-Z][a-z][a-z])") // crea una variable con la expresión 
replace solucion3="Economía" if solucion3=="Eco" 
replace solucion3="Gobierno y Asuntos Pub." if solucion3=="Gob"
replace solucion3="Derecho" if solucion3=="Der"

replace programa=solucion3
drop sol*

* 4) Funciones para condicionales
tab genero
*Método 1
gen genero2=.
replace genero2=0 if genero=="h"
replace genero2=1 if genero=="m"
*Método 2
gen genero3=cond(genero== "m",1,0)
replace genero3=. if missing(genero)
*Método 3: Resultado de una operación lógica
gen genero4=genero=="m"    
replace genero4=. if genero=="" // Conservar missing values de la variable original
br genero genero2 genero3 genero4

* 5) Uso de condicionales en estadísticas descriptivas
sum n_def if genero2==1
sum n_def if regexm(programa,"Gob")

sort a_ing
sum n_def in 1/16 //Toma las observaciones de la 1 a la 16
gsort -a_ing +n_def
sum n_def in -16/L // Otra forma: sum n_def in 21/36

br programa genero2 
br if regexm(programa,"Eco") & genero2==0
count if a_ing==2013 & regexm(programa,"Gob")

* Utilizar esos condicionales para las estadisticas descriptivas 
sum n_def if a_ing==2013 & (regexm(programa,"Derec") | regexm(programa,"Gob"))

********************
* (V) Comando egen * 
********************
* Queremos ver los promedios según cada año de ingreso
bysort a_ing: sum n_def

* 1) Calculos con una variable y sus categorias.
egen nota_maxima=max(n_def)
egen nota_minima=min(n_def)
egen desvest=sd(n_def)
egen promedio=mean(n_def)
egen percentil=pctile(n_def), p(75)
br nota_maxima nota_minima desvest promedio percentil

order a_ing n_def
br a_ing n_def
bys a_ing: egen media=mean(n_def)
bys a_ing: egen desvest2=sd(n_def)

order a_ing genero_c n_def
br a_ing genero_c n_def
bys a_ing genero2: egen media_ai=mean(n_def)
bys a_ing genero2: egen sd_ai=sd(n_def)

* 2) Cálculos con varias variables
egen n_def1=rowmean(parcial1 parcial2 e_final) // Cálculo de nota definitiva con egen
egen mejor_nota=rowmax(parcial1 parcial2 e_final) // Identificación de la mejor nota del estudiante
 
* 3) Funciones para crear variables categóricas
egen grupo=cut(n_def), at(1,2,3,4,5) // En este caso asigna 1 si (1 <= n_def <2), 2 si (2 <=n_def <3 ) y así....
sort n_def
br n_def grupo

egen grupo2=cut(n_def), at(1(1)5) // Este comando especifica exactamente la misma instrucción
egen grupo3 =cut(n_def), group(10)
br n_def grupo grupo2 grupo3

egen aprobado3=cut(n_def), at(0,3,5) icode

egen año_genero=group(a_ing genero2)

bysort año_genero: sum(n_def)
bysort año_genero: egen total=sum(n_def)

* 4) Orden
sum n_def
egen top=max(n_def)
gen temp=top-n_def
egen ranking=rank(temp), track     // Calcula el orden de la secuencia, con la opción "track" se asigna 1 al valor más bajo y se sigue un orden ascendente.
egen ranking2=rank(n_def), field   // Calcula el orden de la secuencia, con la opción "field" se asigna 1 al valor más alto y se sigue un orden descendente.
sort ranking
br n_def ranking

/* Fin de la clase de hoy */
log close

