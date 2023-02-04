API = api.o

run:
	as malloc.s -o malloc.o
	ld malloc.o -o malloc

main: $(API) main.c
	gcc -g -Wall main.c $(API) -o main

api.o: api.c api.h
	gcc -g -c -Wall api.c