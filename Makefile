API = api.o

run:
	as -g api.s -o apiAs.o
	ld -g apiAs.o -o api -dynamic-linker /lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 \/usr/lib/x86_64-linux-gnu/crt1.o /usr/lib/x86_64-linux-gnu/crti.o \/usr/lib/x86_64-linux-gnu/crtn.o -lc

main: $(API) main.c
	gcc -g -Wall main.c $(API) -o main

api.o: api.c api.h
	gcc -g -c -Wall api.c