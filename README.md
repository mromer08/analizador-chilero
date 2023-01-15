Compilador CHILERO (primera fase)
=================================

Al iniciar la tarea, su repositorio debera contener los siguientes archivos y directorios importantes:

* Makefile
* README.md
* lexer-chilero
* lexer-chilero/src/main/java/gt/edu/usac/compiler
* lexer-chilero/src/main/jflex
* cooltests

`Makefile` contiene objetivos para compilar y ejecutar su programa. NO MODIFICAR.

`README.md` contiene esta información. 

`lexer-chilero/src/main/jflex/simpletokenizer.lex` es un archivo esqueleto para la especificación del analizador léxico. Debera completarlo con expresiones, patrones y acciones.

Dentro de `cooltests` encontrará tres programas de prueba:

1. `test.cl` en el cual puede probar análisis léxico y recuperación de errores. Este programa NO es correcto y le puede servir para verificar que su analizador léxico detecte correctamente los errores. Así mismo debera modificarlo para que sea correcto.
2. `factloop.cl` es una calculadora de factorial previamente elaborada en el laboratorio.
3. `stack.cl` es una solución a la máquina de pila previamente elaborada en el laboratorio.

`lexer-chilero/src/main/java/gt/edu/usac/TokenConstants.java` contiene definiciones de constantes que utilizan casi todas las partes del compilador. NO MODIFICAR.

`lexer-chilero/src/main/java/gt/edu/usac/Table.java` y `lexer-chilero/src/main/java/gt/edu/usac/Symbol.java` contienen tablas de cadenas y símbolos útiles en las siguientes fases del compilador NO MODIFICAR.

`lexer-chilero/src/main/java/gt/edu/usac/Utilities.java` contiene varias funciones de soporte utilizadas por el controlador lexer principal (Lexer.java). NO MODIFICAR.

`mycoolc` es un script de shell que une las fases del compilador que utiliza pipes de Unix en lugar de vincular estáticamente el código.  Si bien es ineficiente, esta arquitectura facilita la combinación y combinación los componentes que escribe con los del compilador del curso. NO MODIFICAR.

Tareas principales
------------------

1. Implemente el analizador léxico para COOL y su dialecto CHILERO en el archivo `lexer-chilero/src/main/jflex/simpletokenizer.lex`.
2. En la última sección de este archivo debera redactar una explicación clara de su solución en lenguaje académico (formal, en tercera persona, directo). Debera explicar las decisiones de diseño, como implementó el soporte al dialecto, si necesitó estados intermedios en JFlex, explicar por qué su código es correcto y que modificaciones se realizaron sobre `test.cl` para que fuera un programa correcto.  Asi mismo debe comentar el código que considere conveniente en JFlex.
3. En el archivo `lexer-chilero/src/main/java/gt/edu/usac/Lexer.java` encontrará una implementación de un método principal que invoca a su lexer e imprime los tokens que se detectan. Esta salida es obligatoria para las siguientes fases del proyecto. Debera escribir su propia versión utilizando PicoCLI tal y como se vio en el laboratorio. Esta versión también debera soportar análisis individual de Tokens.
4. El día de la entrega/calificación su instructor le indicará algunas modificaciones con pruebas adicionales (programas en español, ejecuciones de lexer en línea de comandos). El cual usted debera aceptar para comprobar el análisis de su solución.

Note que el autograder proporcionado con este repositorio incluye únicamente pruebas sobre stack y factorial

Instrucciones de uso del makefile
---------------------------------

El archivo Makefile incluido en su repositorio presenta algunas tareas útiles que pueden ser invocadas directamente en la línea de comandos.

Para compilar su programa ejecute

> make compile

Para generar un script `lexer` que ejecute su analizador léxico, ejecute

> make lexer

Para limpiar todo el proyecto ejecute:

> make clean

Así mismo existen dos fases adicionales que ejecutan en secuencia varios pasos para una prueba completa de su solución.

La primera es `make dofactorial` la cual limpia su proyecto, ejecuta la compilación, genera el lexer y ejecuta una prueba del programa `factloop.cl`.

La segunda es `make dostack` la cual limpia su proyecto, ejecuta la compilación, genera el lexer y ejecuta una prueba del programa `stack.cl`.

Si cree que su analizador léxico es correcto, puede ejecutar `mycoolc` el cual une SU analizador léxico con, los analizadores sintácticos, semánticos, generador de código y optimizador de cool. 

Si su analizador léxico se comporta de una manera inesperada, puede obtener errores en cualquier lugar, es decir, durante análisis sintáctico, durante el análisis semántico, durante la generación de código o solo cuando ejecuta el código producido en spim. 

¡Éxitos!

Redacción para primera fase
---------------------------

En la primera fase del proyecto, se realizó la implementación de un analizador léxico que sea compatible con la gramática de COOL y el dialecto CHILERO.

Se agregó un método para poder manejar el error del string demasiado largo, y algunas variables auxiliares. La primer variable `comment_lvl`, se utiliza para llevar un control de los comentarios largos dentro de comentarios largos. Pudiendo salir del estado `MULTILINE_COMMENT` solo si para cada apertura de comentario existe un cierre. La variable `null_in_string` se utiliza para saber si exitió algún caracter nulo dentro de un string y seguir analizando hasta llegar al final de la cadena. Y el método `max_str_error` retorna un `Symbol` del tipo error diciendo que la cadena es demasiado larga. Se colocó en un método, debido a que hay que hacer en repetidas ocasiones dentro del estado `STRING` la comparación entre la longitud de la cadena encontrada y la longitud máxima permitida para una cadena.

Luego, el reconociemiento de simbolos y operadores son sencillos debido a que solo son un caracter.

### Palabras reservadas
Las palabras reservadas son una parte indispensable de esta fase y hay dos cosas a destacar: que en COOL las palabras reservadas no distinguen entre mayusculas y minúsculas (exceptuando true y false), y la equivalencia de las palabras reservadas de COOL en el dialecto CHILERO. Para solucionarlo simplemente se utilizó una unión entre los caracteres en mayúsculas y minúsculas para la keyword de COOL y su equivalencia en el dialecto CHILERO. Por ejemplo con la palabra reservada if:
```
([iI][fF]) | ([sS][iI])
```
### Estados intermedios en JFLEX
Para poder manejar de manera correcta los strings y los errores que involucran `EOF` la mejor forma es utilizando estados intermedios. En concreto se crearon dos estados `STRING` Y `MULTILINE_COMMENT`. En el caso concreto de los strings, es realmente útil utilizar un estado, debido a las diferentes cosas que pueden ocurrir dentro de una cadena en COOL, como el manejo de caracteres como `\t` y los errores del caracter nulo, salto de linea sin escape y longitud máxima de una cadena.

### Modificaciónes sobre el archivo test.cl
Al intentar compilar el archivo `test.cl`, se obtiene la siguiente salida:
```
"test.cl", line 56: syntax error at or near ERROR = '
"test.cl", line 62: syntax error at or near ERROR = [
"test.cl", line 86: syntax error at or near ERROR = >
Compilation halted due to lex and parse errors
```
En la linea 56 se reemplazan las comillas simples por comillas dobles, ya que en cool no existen las comillas simples. En la linea 62 se reemplazan los corchetes por parentesis, ya que se está haciendo una llamada a un método. En la linea 86 hay que replantear la condición, ya que en cool no existe el '>', para llegar al mismo resultado puede negarse el '<='.

Al corregir esos errores y volver a compilar, se obtiene la siguiente salida
```
"test.cl", line 92: syntax error at or near POOL
```
Debido a que no se han cerrado correctamente unas llaves. Y al volver a compilar se obtiene un `EOF in comment`, debido a que no se ha cerrado correctamente un comentario largo en la linea 97.

Realizando esos cambios, el archivo `test.cl` ya queda listo para ser compilado y ejecutado de forma correcta.