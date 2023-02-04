typedef struct {
    int occupied;
    int size;
    void *p;
} Nodo_t;


void *inicioHeap;

void iniciaAlocador();

void finalizaAlocador();

void imprimeHeap();

void * firstFitMalloc(int num_bytes);

int liberaMem(void *bloco);