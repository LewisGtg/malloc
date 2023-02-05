#include <stdio.h>
#include <unistd.h>

void * topoHeap = NULL; 
void * validAdress = NULL;

void iniciaAlocador()
{
    // Printf inicial para não ter problemas com endereço da heap
    printf("Iniciando alocador\n");
    topoHeap = sbrk(0);
    validAdress = topoHeap;
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

void setNext(void * block, int totalAllocated) 
{
    void * heapTop = sbrk(0);
    int * p = (int *) block;
    int blockSize = *(p + 1);
    int * blockBegin = p + 2;

    if (blockBegin + blockSize >= (int *) validAdress && blockBegin + blockSize < (int *) heapTop) 
    {
        *(blockBegin + blockSize) = 0;
        *(blockBegin + blockSize + 1) = totalAllocated - blockSize;
        validAdress = blockBegin + blockSize;
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

    // Nenhuma memória foi alocada ainda, ou falta memória
    if ((int *) validAdress + num_bytes + 2>= topoAtual)
    {
        p = validAdress;

        // Ajusta a brk
        brk(p + totalBytes);
        // Define as infos sobre o bloco requisitado e o bloco restante
        *p = 1;
        *(p+1) = num_bytes;
        setNext(p, totalBytes);
    }
    else
    {
        while (p < topoAtual)
        {
            // Encontrou bloco livre
            if (*p == 0 && *(p+1) >= num_bytes)
            {
                *p = 1;

                // Memória que ainda não foi utilizada
                if ((int *) validAdress <= p)
                {
                    int oldValue = *(p+1);
                    *(p+1) = num_bytes;
                    setNext(p, oldValue);
                }
                return p + 2;
            }
            p += (2 + *(p+1));
        }
    }

    return p + 2;
}

int liberaMem(void * bloco)
{
    int *p = (int *) bloco;
    *(p-2) = 0;
    return 0;
}