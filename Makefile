API = api.o

run:
	as malloc.s -o malloc.o
	ld malloc.o -o malloc

main: $(API) main.c
	gcc -Wall main.c $(API) -o main

api.o: api.c api.h
	gcc -c -Wall api.c