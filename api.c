#include <stdio.h>
#include <unistd.h>

void * topoHeap;

void iniciaAlocador() { 
    // Recebe o topo da heap
    topoHeap = sbrk(0);
}


void finalizaAlocador() {
    return ;
}

void * alocaMem(int num_bytes) {
    int * topoAtual = sbrk(0);
    int *intP = (int *) topoHeap;
    int m = 1;

    while (num_bytes > 4096 * m)
        m+=1;

    if (topoHeap == topoAtual) {
       brk(4096 * m);
       *p = 1;
       *(p + 1) = num_bytes; 
       topoAtual = sbrk(0);
    }
    
    

    printf("%p\n", p);
    return ; 
}

int liberaMem(void *bloco) {
    return 0;
}