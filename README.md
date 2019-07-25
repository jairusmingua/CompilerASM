# Syntax error detector using 8086 asm 
An asm implementation of syntax error detector

## This repository contains..
* compiler.asm - main application
* moving.asm - graphics application for the main application
* iostream.inc - macros for the application

## How to use the program
Simple steps to implement the application in 8086

## Prerequisites
*Dosbox - to emulate a 8086 environment and run the application
*emu8086 - to view and debug the source code

## Syntax
*Place the files on to the root folder of 8086

* Open any text editor and write this sample code and save the file on the root folder of 8086 

```
myAge=20;
otherAge=5;
?mother=0;
myAge=myAge++;
multiAge=500*sojj;
isAgeValid=multiAge<=100;
printf "isAgeValid";

```
* Run tasm and linker writing
```
tasm compiler+moving;
link compiler+moving;
```

*Run the file

