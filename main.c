#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "api.h"

int main(int argc, char **argv)
{
    iniciaAlocador();


    alocaMem(0);

    return (0);
}