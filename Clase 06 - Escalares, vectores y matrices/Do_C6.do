*****************************************************
** Universidad de los Andes - Facultad de Economía **
** 			       Taller de Stata                 **
**												   **
** 				Miguel Garzón-Ramirez              **
** 			   Cristhian Acosta-Pardo              **
** 			   						               **
** 	        Clase 6: Escalares y matrices          **
*****************************************************

clear all
cap log close
set more off, perm 
* En esta clase no es necesario cambiar el directorio de trabajo. Usaremos datos disponibles en internet y los resultados los leeremos de la ventana de resultados.
webuse auto, clear

*-------------------------*
*I. Creación de Escalares *
*-------------------------*
scalar a="La raiz cuadrada de dos es "
scalar b=sqrt(2)
display a b  // Para llamar a un escalar basta hacerlo con el nombre, no hay que usar comillas.

 * return list
sum price
return list
 
scalar media=r(mean)
scalar rango=r(max)-r(min)
 
 * scalar list
scalar list
display "La media de price es " media
display "El tamaño del rango de price es " rango

 * e-return list
reg price mpg trunk weight length
ereturn list

scalar a=e(r2)
scalar b=e(N)
scalar c=e(rss)              

display "El R2 de la regresion es" a
display "El número de observaciones de la regresión es " b
display "La suma de los errores al cuadrado es " c 
	
*-------------------------* 
*II. Creación de Matrices *
*-------------------------*
matrix b=(1,2,3,4) // la sintaxis completa es: matrix define b=(1,2,3,4)
matlist b
matrix v=(1\2\3\4) // Vector columna
matlist v 

 *Definición de matrices
matrix H=(1,0,4,5\8,0,3,7) 
matrix list H

  * Renombrar filas y columnas
matrix rownames H="Fila 1" "Fila 2"
matrix colnames H="Columna 1" Columna2 "Columna 3" Columna4 // Si no coloca nombre a todas la columnas, el último nombre se repite para las columnas faltantes
matlist H
	
  * Cambiar una posición de la matriz
matrix H[1,2]=888 //[i,j]: fila i, columna j
matlist H

 * Escalares a partir de matrices
scalar d=H[1,2] 
display d

*----------------------------------------------------------------* 
*III. Matrices con los resultados de una regresión y operaciones *
*----------------------------------------------------------------*
reg price mpg trunk weight length
ereturn list
	
matrix coeficientes=e(b)
matlist coeficientes
  
matrix varcovar=e(V)
matlist varcovar

matrix v=(1\2\3\4)
matlist v 
  *suma  
matrix G=H+H
matlist G
 *matrix T=H+v	// error de dimensión    
  *multiplicación
matlist H
matlist v
matrix H2=H*v
matlist H2
*matrix G2=H*H // error de conformación
matrix G2=H*H'
matlist G2
  	
*---------------------------------------------------* 
*IV. Ejemplo: Derivar el beta de MCO matricialmente *
*---------------------------------------------------* 
reg price mpg trunk weight length
matrix define cons=J(74,1,1)  // Genera un vector con 74 filas y una columna cuyos elementos son 1 (J es una matriz constante)
matrix colnames cons= constante
  
  * mkmat: Crea una matriz a partir de variables de la base de datos
mkmat price, matrix(Y)
mkmat mpg trunk weight length, matrix(X)
matrix X=[X,cons]
matlist Y
matlist X
  
  * Operaciones matriciales
matrix B=(inv(X'*X))*(X'*Y) //Abreviando
matlist B
matrix Beta=B'
matlist Beta
  
  * Comprobamos si el vector Beta contiene los mismos valores de los coeficientes de la regresión
reg price mpg trunk weight length
clear

  * svmat: Crea variables a partir de matrices
svmat B
br       //Note que el nombre de la variable aparece como B1. En el caso de una matriz con n columnas, al convertirlas a variables tendríamos n variables con los nombre de B1, B2, ... Bn
clear
svmat Beta, names(col)
gen dep="price"
		  
matrix A=[1\2\3\4\5]
matrix C=[B,A]
matlist C
svmat C, names(col) //las columnas de esta matriz se agregan a la base como nuevas variables, sus nombres serían C1 y C2 si no se usa la opción names()

*-----------------------------* 
*V. MATA - Manejo de matrices *
*-----------------------------*
clear all
cls //Limpia la ventana de resultados

/* MATA es un lenguaje de programación que se encuentra detrás de todo lo que hace Stata. Usar MATA puede tener grandes ventajas sobre el uso normal de Stata y la programación es bastante similar a la de MATLAB o R, por lo cual se puede importar rutinas desde esos lenguajes. Entre las ventajas que tiene MATA sobre STATA, esta la capacidad de almacenar matrices de gran tamaño y la velocidad al realizar ciertos procesos. */

mata

a=1 /* Asi defino los escalares  */
a 
b=(1,2) /* Para definir vectores fila  */
b
c=(3\6) /* Para definir vectores columna  */
c
A=(1,2,3\4,5,6) /* Para definir matrices  */
A 
H=J(1,3,0) /* Matriz constante J: crea una matriz de 1 fila y tres columnas con ceros  */
H
C=(A\H) /* Unión de matrices y vectores  */
C
C[3,3]=10  /* reemplaza el elemento de la tercera fila y columna por un 10*/
C
Cinv=luinv(C) /* Invertir matrices */
Cinv

end

*-------------------------------------------* 
*VI. MATA - Cargar matrices y datos en MATA *
*-------------------------------------------*
webuse auto, clear
reg price mpg trunk weight length
mata: b=st_matrix("e(b)") //Transferir una matriz a Mata

mata
b
data=st_data(.,.) /* Carga a Mata una copia de toda la base de datos en Stata*/
data=st_data(1, 2) /* Carga a Mata la primera fila de la segunda variable de la base de datos en Stata*/
data=st_data((1,10), 2) /* Carga las primeras 10 observaciones de la segunda variable de la base de datos en Stata */
data1=st_data(., ("mpg", "weight")) /* Carga a Mata todas las observaciones de las variables mpg y weight */
data1=st_data(., "mpg weight") /* hace lo mismo que el anterior comando */
mata describe

st_matrix("datos", data) /* Transferir matriz de Mata a Stata */

max=colmax(data)   /* Crea matriz con el máximo por columna para las variables mpg weight */
st_matrix("max_data", max)  /* Transferir matriz de Mata a Stata */

end

matlist datos
matlist max_data