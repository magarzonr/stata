*****************************************************
** Universidad de los Andes - Facultad de Economía **
** 			    Taller de Stata 2020-II            **
**												   **
** 				Miguel Garzón-Ramírez              **
** 			   Cristhian Acosta-Pardo              **
** 			   						               **
** 				Clase 2 - Variables-I              **
*****************************************************
* Empezamos los do-files limpiando el espacio de trabajo y especificando los comando que permiten la ejecución continua

clear all
cap log close
set more off

cd "G:\Mi unidad\4_DOCENCIA\Taller de Stata\2020-II\4 - Clases\Clase 2 - Variables I"
log using "log_clase2.log", replace

dir // ¿Que hay en la carpeta?
type Base_clase_2.txt, lines(20)
import delimited Base_clase_2.txt, delim(tab) stringcols(1 2 3 4 13) case(preserve) clear
save "Base_clase_2", replace

*******************************************************************************
** 1. Comandos para la descripción de variables, bys, condicionales y tabstat *
*******************************************************************************
use "Base_clase_2", clear
*1.1 Describe
describe // todas las variables de la base
describe EDI MALT IRA EDA // variables señaladas
 
*1.2 Inspect
codebook EDA  depmuni
inspect EDA 

*1.3 Summarize 
sum ingresos_hogar_jefe
sum ingresos_hogar_jefe, d
sum ingresos_hogar_jefe if  qq1=="Quintil 1"

*1.4 Tabulate
tab qq1
tab qq1, m
tab qq1 IRA // Tabla de contingencia
*tab qq1 IRA EDA  // Stata arroja error porque tab solo acepta una variable
tab1 qq1 IRA EDA // Este comando me permite hacer tabulaciones de varias variables
tab2 qq1 IRA EDA // Tres tablas de contingencia, una por cada pareja de variables 

*1.5 Comandos by y bysort
* Supongamos que queremos ver el promedio de ingreso para cada quintil
sum  ingresos_hogar_jefe if  qq1==""
sum  ingresos_hogar_jefe if  qq1=="Quintil 1"
sum  ingresos_hogar_jefe if  qq1=="Quintil 2"
sum  ingresos_hogar_jefe if  qq1=="Quintil 3"
sum  ingresos_hogar_jefe if  qq1=="Quintil 4"
sum  ingresos_hogar_jefe if  qq1=="Quintil 5"

*by qq1: sum ingresos_hogar_jefe // Arroja un error pues la base no está ordenanda por en el orden de a_ing       
sort qq1
by qq1: sum ingresos_hogar_jefe
* El comando bysort hace todo en un paso.  
bys depmuni: sum ingresos_hogar_jefe, d
bys depmuni: tab qq1

*1.6. Operadores lógicos
	*-------------------------------------------------------------------*
	*	Expresiones Lógicas 					Significado				*
	*-------------------------------------------------------------------*
	*			&, |						  Y (And), O (Or)			*
	*			>,<							Mayor que, Menor que		*
	*		   ==, !=						Igual a, Diferente a		*
	*		   >=, <=					Mayor Igual, Menor o Igual 		*
	*-------------------------------------------------------------------*
	*	Expresiones Aritméticas 										*
	*-------------------------------------------------------------------*
	*			+, -							Más, Menos				*
	*			*, /					 Multiplicación, Division 		*
	*			_n					Número de observación corriente		*
	*			_N					Número de observaciones totales		*
	*-------------------------------------------------------------------*
	
sum ingresos_hogar_jefe if _n<=10
sum ingresos_hogar_jefe if _n<=10 & _n>15
sum ingresos_hogar_jefe if _n<10 & ingresos_hogar_jefe!=0, d

*1.7 Tabstat
tabstat ingresos_hogar_jefe 
tabstat ingresos_hogar_jefe, stat(mean sd) by(EDA)
tabstat ingresos_hogar_jefe EDI, stat(mean sd) by(EDA)

**************************************
** 2. Nombres y listas de variables **
**************************************
sum i* // Podemos emplear abreviaciones con asteriscos para denotar las variables 
tab I* // Stata distingue mayúsculas de minúsculas.
sum E* // Hay más de dos variables que empiezan por E, se debe utilizar el asterísco para llamarlas en lista

** Listas de variables
sum *A // Que terminen en "A"
sum ED*
sum ED? // Que tengan 3 caracteres y empiecen con "ED"
sum *A* // Que contengan "A"
sum EDA-EDI // Lista las variables en ese orden en la base

aorder // Orden alfabético. Primero las mayúsculas y luego las minúsculas
*sum EDI-EDA  // Si rompiésemos el orden no funcionaría el comando. Se debe tener claro el orden de las variables 
order EDI MALT IRA EDA
sum EDI-EDA
aorder 
order *, alpha

** Cambiar el nombre de las variables
rename EDA eda
rename (algo qq1) (desconocida quintil_n)
rename ingresos* ing*
rename *, lower // también se escribe rename *, lower

******************************
** 3. Creación de variables **
******************************
** (A) Numéricas
 *--------------------------------------------------------------------------*
 *  Storage                                              Número más         *
 *  type      Número más pequeño    Número más grande    cercano a 0  bytes *
 *  ----------------------------------------------------------------------- *
 *  byte                    -127                  100    +/-1          1    *
 *  int                  -32,767               32,740    +/-1          2    *
 *  long          -2,147,483,647        2,147,483,620    +/-1          4    *
 *  float   -1.70141173319*10^38  1.70141173319*10^38    +/-10^-38     4    *
 *  double  -8.9884656743*10^307  8.9884656743*10^307    +/-10^-323    8    *
 *  ----------------------------------------------------------------------- *

gen bogota=0
replace bogota=1 if depmuni=="11001"

* Simplificado con función lógica
gen bogota1=depmuni=="11001" 

* Especificando tipo de almacenamiento
gen byte bogota2=depmuni=="11001" 

* Cambiar tipo de almacenamiento
recast byte bogota1
recast byte edi // Stata no va a cambiar el tipo de almacenamiento si esto implica pérdida de información
compress 

* Formato
gen ing_hogar_jefe1=ing_hogar_jefe
*browse ing*
format %-12.0g ing_hogar_jefe1
format %-12.0gc ing_hogar_jefe1

gen edi1=edi
*br edi*
format %3.2f edi1
format %3.2g edi1

*Creando variables con elementos de Stata
gen obs=_N
gen id=_n

** (B) Texto o "Strings"
*---------------------------------------------*
*   String                                    *
*   storage       Maximum                     *
*   type          length         Bytes        *
*   ----------------------------------------- *
*   str1             1             1          *
*   str2             2             2          *
*    ...             .             .          *
*    ...             .             .          *
*    ...             .             .          *
*   str2045         2045           2045       *
*   strL            2000000000     2000000000 *
*   ----------------------------------------- *

sum ing_hogar_jefe
return list
sum ing_hogar_jefe, detail
return list
gen ingresos_altos="Sí" if ing_hogar_jefe>=r(mean)
replace ingresos_altos="No" if ing_hogar_jefe<r(mean)

* Crear variables de caracter con base en otros caracteres
*br muestreo vivienda hogar orden_ma
gen codigo=muestreo + vivienda + hogar + orden_ma
gen codigo1=muestreo + "0" + vivienda + hogar + orden_ma

******************************************
** 4. Conversión entre tipo de variables *
******************************************
* de número a caracter
tostring eda, gen(eda1) // Creando nueva variable con el cambio
*br eda*
tostring eda, replace // Haciendo el cambio sobre la misma variable, reflexivo
drop eda1
* de caracter a número
destring muestreo, gen(muestreo1) // Creando nueva variable con el cambio
*br muestreo*
destring muestreo, replace // Haciendo el cambio sobre la misma variable, reflexivo

gen ej_force="A"
replace ej_force="10" if _n>1000
destring ej_force, replace force
tab ej_force, miss

gen ej_ignore="15A"
replace ej_ignore="10B" if _n>3000
destring ej_ignore, ignore("A" "B") replace

/* 	Fin 
	de 
	la 
	clase */
	
log close

