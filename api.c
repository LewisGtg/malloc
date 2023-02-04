#include <stdio.h>
#include <unistd.h>

void *topoHeap;

void iniciaAlocador()
{
    // Recebe o topo da heap
    printf("Iniciando alocador\n");
    topoHeap = sbrk(0);
}

void finalizaAlocador()
{
    return;
}

void imprimeHeap()
{
    int *topoAtual = sbrk(0);
    int *p = (int *)topoHeap;

    while (p < topoAtual)
    {
        // printf("p: %p\ntopoAtual: %p\n", p, topoAtual);
        printf("Bloco ocupado: %d\nTamanho Bloco: %d\n\n", *p, *(p + 1));
        p += (2 + *(p + 1));
    }
}

void *firstFitMalloc(int num_bytes)
{
    int *topoAtual = sbrk(0);
    int *p = (int *)topoHeap;
    int m = 1;

    while (num_bytes + 16 > 4096 * m)
        m += 1;

    int totalBytes = 4096 * m;

    // Nenhuma memória foi alocada ainda
    if (p == topoAtual)
    {
        // Ajusta a brk
        brk(p + totalBytes);

        // Define as infos sobre o bloco requisitado e o bloco restante
        *p = 1;
        *(p + 1) = num_bytes;
        *(p + 2 + num_bytes) = 0;
        *(p + 2 + num_bytes + 1) = 4096 * m - num_bytes;
    }
    else
    {
        topoAtual = sbrk(0);
        while (p < topoAtual)
        {
            // Encontrou bloco livre
            if (*p == 0 && *(p+1) >= num_bytes)
            {
                // Perfect fit
                if (*(p+1) == num_bytes || *(p+1) < num_bytes + 16 + 1)
                {
                    *p = 1;
                    return p + 2;
                }    
                else
                {
                    int valorAntigo = *(p+1);
                    *p = 1;
                    *(p+1) = num_bytes;
                    *(p+2+num_bytes) = 0;
                    *(p+2+num_bytes + 1) = valorAntigo - num_bytes;
                    return p + 2;
                }     
            }
            p += (2 + *(p+1));
        }
        brk(p + totalBytes);

        // Define as infos sobre o bloco requisitado e o bloco restante
        *p = 1;
        *(p + 1) = num_bytes;
        *(p + 2 + num_bytes) = 0;
        *(p + 2 + num_bytes + 1) = 4096 * m - num_bytes;
    }

    return p + 2;
}

int liberaMem(void * bloco)
{
    int *p = (int *) bloco;
    *(p-2) = 0;
    return 0;
}