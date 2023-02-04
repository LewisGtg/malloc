#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "api.h"

int main(int argc, char **argv)
{
    int *p;
    iniciaAlocador();

    for (int i = 0; i < 41; ++i)
    {
        p = firstFitMalloc(1000);
    }
    
    p = firstFitMalloc(10);
    liberaMem(p);

    p = firstFitMalloc(30);
    p = firstFitMalloc(50);

    imprimeHeap();
    return (0);
}