#include <stdio.h>
#include <unistd.h>

void *heapBegin = NULL;
void *validAdress = NULL;
void *lastAddress = NULL;

void iniciaAlocador()
{
    // Printf inicial para não ter problemas com endereço da heap
    printf("Iniciando alocador\n");
    heapBegin = sbrk(0);
    validAdress = heapBegin;
    lastAddress = heapBegin;
}

void finalizaAlocador()
{
    return;
}

void imprimeHeap()
{
    int *currentTop = sbrk(0);
    int *p = (int *)heapBegin;

    while (p < currentTop)
    {
        // printf("p: %p\ncurrentTop: %p\n", p, currentTop);
        printf("Bloco ocupado: %d\nTamanho Bloco: %d\n\n", *p, *(p + 1));
        p += (2 + *(p + 1));
    }
}

void imprimeMapa()
{
    int *currentTop = sbrk(0);
    int *p = (int *)heapBegin;
    printf("\nmapa:\n");
    while (p < currentTop)
    {
        int filledBlock = *p;
        int blockSize = *(p + 1);
        printf("################");
        char blockChar = ' ';
        if (filledBlock != 0)
            blockChar = '-';
        else
            blockChar = '+';
        for (int i = 0; i < blockSize; i++)
            putchar(blockChar);
        p += (2 + blockSize);
    }
}

void setNext(void *block, int totalAllocated)
{
    void *heapTop = sbrk(0);
    int *p = (int *)block;
    int blockSize = *(p + 1);
    int *blockBegin = p + 2;

    if (blockBegin + blockSize >= (int *)validAdress && blockBegin + blockSize < (int *)heapTop)
    {
        *(blockBegin + blockSize) = 0;
        *(blockBegin + blockSize + 1) = totalAllocated - blockSize;
        validAdress = blockBegin + blockSize;
    }
}

void *nextFitMalloc(int num_bytes) 
{
    int *currentTop = sbrk(0);
    int *p = (int *)lastAddress;
    int m = 1;

    while (num_bytes + 16 > 4096 * m)
        m += 1;

    int totalBytes = 4096 * m;

    int lap = 0;

    while (p < (int *)validAdress && lap == 0)
    {
        // Encontrou bloco livre
        if (*p == 0 && *(p + 1) >= num_bytes)
        {
            *p = 1;

            // Memória que ainda não foi utilizada
            if ((int *)validAdress <= p)
            {
                int oldValue = *(p + 1);
                *(p + 1) = num_bytes;
                setNext(p, oldValue);
            }

            lastAddress = p;
            return p + 2;
        }
        p += (2 + *(p + 1));

        if (p >= (int *)validAdress && lap == 0)
        {
            p = heapBegin;
            lap = 1;
        }
    }

    // Nenhuma memória foi alocada ainda, ou falta memória
    if ((int *)validAdress + num_bytes + 2 >= currentTop)
    {
        p = validAdress;

        // Ajusta a brk
        brk(p + totalBytes);
        // Define as infos sobre o bloco requisitado e o bloco restante
        *p = 1;
        *(p + 1) = num_bytes;
        setNext(p, totalBytes);
    }
    else
    {
        p = (int *)validAdress;
        int oldValue = *(p + 1);
        *p = 1;
        *(p + 1) = num_bytes;
        setNext(p, oldValue);
    }

    lastAddress = p;
    return p + 2;


}

void *bestFitMalloc(int num_bytes)
{
    int *currentTop = sbrk(0);
    int *p = (int *)heapBegin;
    int m = 1;
    int bestFit = 0;
    int *bestPlace = NULL;

    while (num_bytes + 16 > 4096 * m)
        m += 1;

    int totalBytes = 4096 * m;

    while (p < (int *)validAdress)
    {
        if ((*p == 0 && *(p + 1) >= num_bytes && *(p + 1) < bestFit) || (*p == 0 && *(p + 1) >= num_bytes && bestFit == 0))
        {
            bestFit = *(p + 1);
            bestPlace = p;
        }
        p += (2 + *(p + 1));
    }

    // Não achou lugar
    if (!bestPlace)
    {
        // Verifica se ainda há espaço válido na heap
        if ((int *)validAdress + num_bytes + 2 < currentTop)
        {
            p = (int *)validAdress;
            int oldValue = *(p + 1);
            *p = 1;
            *(p + 1) = num_bytes;
            setNext(p, oldValue);
        }
        else
        {
            p = (int *)validAdress;

            // Ajusta a brk
            brk(p + totalBytes);
            // Define as infos sobre o bloco requisitado e o bloco restante
            *p = 1;
            *(p + 1) = num_bytes;
            setNext(p, totalBytes);
        }

        return p + 2;
    }

    *bestPlace = 1;
    return bestPlace + 2;
}

void *firstFitMalloc(int num_bytes)
{
    int *currentTop = sbrk(0);
    int *p = (int *)heapBegin;
    int m = 1;

    while (num_bytes + 16 > 4096 * m)
        m += 1;

    int totalBytes = 4096 * m;

    while (p < (int *)validAdress)
    {
        // Encontrou bloco livre
        if (*p == 0 && *(p + 1) >= num_bytes)
        {
            *p = 1;

            // Memória que ainda não foi utilizada
            if ((int *)validAdress <= p)
            {
                int oldValue = *(p + 1);
                *(p + 1) = num_bytes;
                setNext(p, oldValue);
            }
            return p + 2;
        }
        p += (2 + *(p + 1));
    }

    // Nenhuma memória foi alocada ainda, ou falta memória
    if ((int *)validAdress + num_bytes + 2 >= currentTop)
    {
        p = validAdress;

        // Ajusta a brk
        brk(p + totalBytes);
        // Define as infos sobre o bloco requisitado e o bloco restante
        *p = 1;
        *(p + 1) = num_bytes;
        setNext(p, totalBytes);
    }
    else
    {
        p = (int *)validAdress;
        int oldValue = *(p + 1);
        *p = 1;
        *(p + 1) = num_bytes;
        setNext(p, oldValue);
    }

    return p + 2;
}

void *worstFitMalloc(int num_bytes)
{
    int *currentTop = sbrk(0);
    int *p = (int *)heapBegin;
    int m = 1;
    int worstFit = 0;
    int *worstPlace = NULL;

    while (num_bytes + 16 > 4096 * m)
        m += 1;

    int totalBytes = 4096 * m;

    while (p < (int *)validAdress)
    {
        int fits = *p == 0 && *(p + 1) >= num_bytes;
        if (fits && (*(p + 1) > worstFit || worstFit == 0))
        {
            worstFit = *(p + 1);
            worstPlace = p;
        }
        p += (2 + *(p + 1));
    }

    // Não achou lugar
    if (!worstPlace)
    {
        // Verifica se ainda há espaço válido na heap
        if ((int *)validAdress + num_bytes + 2 < currentTop)
        {
            p = (int *)validAdress;
            int oldValue = *(p + 1);
            *p = 1;
            *(p + 1) = num_bytes;
            setNext(p, oldValue);
        }
        else
        {
            p = (int *)validAdress;

            // Ajusta a brk
            brk(p + totalBytes);
            // Define as infos sobre o bloco requisitado e o bloco restante
            *p = 1;
            *(p + 1) = num_bytes;
            setNext(p, totalBytes);
        }

        return p + 2;
    }

    *worstPlace = 1;
    return worstPlace + 2;
}

int liberaMem(void *bloco)
{
    int *p = (int *)bloco;
    *(p - 2) = 0;
    return 0;
}

int bestliberaMem(void *bloco)
{
    int *p = (int *)bloco - 2;
    *p = 0;

    int tamanho = *(p+1);

    if (*(tamanho + p + 2) == 0 && tamanho + p + 2 < (int *)validAdress) {
        printf("%d\n", *(tamanho + p + 3));
        int novoTam = tamanho + *(tamanho + p + 3) + 16;

        *(p+1) = novoTam;

        
        // if(tamanho + p >= (int *)validAdress) validAdress -= 16;
    }

    return 0;
}