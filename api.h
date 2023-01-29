typedef struct {
    int occupied;
    int size;
    void *p;
} Nodo_t;


void *topoHeap;

void iniciaAlocador();

void finalizaAlocador();

void *alocaMem(int num_bytes);

int liberaMem(void *bloco);