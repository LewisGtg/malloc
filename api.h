typedef struct
{
    int occupied;
    int size;
    void *p;
} Nodo_t;

void *inicioHeap;

void iniciaAlocador();

void finalizaAlocador();

void imprimeHeap();

void imprimeMapa();

void *firstFitMalloc(int num_bytes);

void *bestFitMalloc(int num_bytes);

void *worstFitMalloc(int num_bytes);

void *nextFitMalloc(int num_bytes);

int liberaMem(void *bloco);

int bestliberaMem(void *bloco);