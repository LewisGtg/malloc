API = api.o

run:
	as -g api.s -o apiAs.o
	ld -g apiAs.o -o api

main: $(API) main.c
	gcc -g -Wall main.c $(API) -o main

api.o: api.c api.h
	gcc -g -c -Wall api.c