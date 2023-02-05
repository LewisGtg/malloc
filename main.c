#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "api.h"

int main(int argc, char **argv)
{
    void * a;
    iniciaAlocador();

    for (int i = 0; i < 100; ++i)
    {
        a = firstFitMalloc(100);
        strcpy(a, "TESTE");
        printf("%p %s\n", a, (char *) a);
        liberaMem(a);
    }
    
    // imprimeHeap();
    return (0);
}