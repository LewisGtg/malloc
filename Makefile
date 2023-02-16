API = api.o

run:
	as -g api.s -o apiAs.o
	gcc -c main.c -o main.o -g
	gcc -static apiAs.o main.o -o main

main: $(API) main.c
	gcc -g -Wall main.c $(API) -o main

api.o: api.c api.h
	gcc -g -c -Wall api.c
