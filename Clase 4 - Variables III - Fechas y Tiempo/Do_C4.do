*****************************************************
** Universidad de los Andes - Facultad de Economía **
** 			   Taller de Stata 2020-II             **
**												   **
** 				Miguel Garzón-Ramirez              **
** 			   Cristhian Acosta-Pardo              **
** 			   						               **
** 	       Clase 4: Variables III - Fechas         **
*****************************************************

clear all 
cap log close
set more off
cd "G:\Mi unidad\4_DOCENCIA\Taller de Stata\2020-II\4 - Clases\Clase 4 - Variables III - Fechas y Tiempo"

*------------------*
*I. Fechas y tiempo*
*------------------*

use "Base_clase_4", clear

*1. ¿Como entiende Stata el tiempo?*

*2. ¿Como incluir fechas a Stata?*
	*2.1. De un string a una fecha
gen fecnac0=date(nac,"MDY") 
gen fecnac=date(nac,"MD19Y") 
gen fecnac00=date(nac,"MDY",2020) 

sum fecnac  // Vemos que la variable es un número, pero no se puede inferir a partir de él de qué fecha estamos hablando
format fecnac* %td
* Calcular la edad de las personas
gen age=td(31aug2020)-fecnac  // Para realizar operaciones, las variables de tiempo deben estar en la misma unidad
replace age=age/365.25  //  365 días y 6 horas (calendario egipcio)
replace age=floor(age)

*Separar día y mes de una variable string   
gen largo=length(nac) // Cuenta la cantidad de caracteres de las fechas
gen mes=substr(nac,1,2)
gen dia=substr(nac,4,2)
*Extraer el año en varios formatos
gen anho="19"+substr(nac,7,2) if largo==8   
replace anho=substr(nac,7,4) if largo==10

*Generar una variable de caracteres con fechas
egen nac_ns=concat(mes dia anho) // gen nac=mes+dia+anho1

*Generar la variable numérica con las fechas
gen fecnac1=date(nac_ns,"MDY")
gen fecnac2=date(nac_ns,"MD19Y")
 
format fecnac1 fecnac2  %td
 
	*2.2 De variables numéricas a fechas
destring mes,replace
destring dia,replace
destring anho,replace
generate fecnac3=mdy(mes,dia,anho)
format fecnac3 %td  
  
*3.¿Cómo modificar la visualización de una variable numérica? - Tabla 6
br fecnac fecnac1 fecnac2 fecnac3 
format fecnac1 %tdMonth_dd,_CCYY 
format fecnac2 %tdDay-Month-DD-CCYY-JJJ
format fecnac3 %tdccyy,Mon,DD,Day

*4. ¿Cómo alternar entre tipos de fecha?*
  *Convertir de fecha a unidad de tiempo (dia, mes, trimestre, año...)
format fecnac %tg
gen anho1=yofd(fecnac)
format anho1 %tg
format anho1 %ty

gen quar=qofd(fecnac)
format quar %tq

gen mes1=mofd(fecnac)
format mes1 %tm // pruebe otros formatos: format mes1 %ty - format mes1 %tg 

gen dia1=dofd(fecnac2)
format dia1 %td

*Conversiones de tiempo - tabla 7
br quar mes1
gen quar1=qofd(dofm(mes1))  // De mes se extrae cuatrimestre
format quar1 %tq
gen anho2=yofd(dofm(mes1)) // De mes se extrae año
gen anho3=yofd(dofq(quar)) // De cuatrimestre se extrae año

*5.¿Cómo trabajar con fechas en Stata?*

	* 5.1. Extrayendo información (calendario)
gen anho4=year(fecnac)
gen mes2=month(fecnac)		// Extrae el mes del año
gen dia_anho=doy(fecnac2)  	// Extrae el día del año. 
gen dia_mes=day(fecnac3)   	// Extrae el día del mes

*Explorando el grupo
bysort genero: tab anho
bysort genero: egen mean_anho=mean(anho)

egen grupo=cut(anho), group(10) // 10 grupos mas o menos iguales
tab grupo,m
egen decadas=cut(anho), at(1930(10)1990)
tab decadas, m

	* 5.2. Usando las fechas una vez construidas
*Usar fechas dentro de un condicional (día)
br fecnac fecnac2 mes1
format fecnac %tg
sort fecnac
gen viejo=cond(fecnac<-5622,1,0)
gen viejo1=cond(fecnac<td(10aug1944),1,0) //Note que "td" le permite introducir la fecha(día mes año) directamente

*Usar variables de tiempo en condicionales
 **mes
gen viejo2=cond(mes1<tm(1944m8),1,0)
gen viejo3=cond(mofd(fecnac)<tm(1944m8),1,0)
gen viejo4=mofd(fecnac)<tm(1944m8)

 **trimestre
gen viejo5=cond(quar<tq(1944q3),1,0)
 **año 
gen viejo6=cond(fecnac<dofy(1944),1,0) // comparar una fecha (dia) con un año
gen viejo7=cond(fecnac<1944,1,0) // ¿Qué pasa si no se usa la función dofy?

	* 5.3. Usando la fecha de hoy
gen hoy = c(current_date)
gen fechoy=date(hoy,"DMY")
br hoy fechoy

format fechoy %dM-D-CY //Cambia el formato a mes(letras) - día(num) - año(num)

gen edad=fechoy-fecnac2
replace edad=floor(edad/365.25)

egen generacion=cut(edad), at(0(10)90) icodes
tab generacion,m
