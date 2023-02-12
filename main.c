#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "api.h"

int main(int argc, char **argv)
{
    void *a;
    void *b;
    iniciaAlocador();

    a = firstFitMalloc(100);
    b = firstFitMalloc(300);
    a = firstFitMalloc(200);
    liberaMem(b);
    liberaMem(a);
    imprimeMapa();
    b = worstFitMalloc(50);
    imprimeMapa();
    liberaMem(b);
    // imprimeMapa();

    // imprimeHeap();
    return (0);
}