#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "api.h"

int main(int argc, char **argv)
{
    void *a;
    void *b;
    int i;

    for (i = 0; i < 20; i++)
    {
        a = malloc(100);
        b = malloc(200);
        strcpy(a, "A");
        printf("%p %s\n", a, (char *)a);
        strcpy(b, "B");
        printf("%p %s\n", b, (char *)b);
        free(a);
        free(b);
    }
    return (0);
}