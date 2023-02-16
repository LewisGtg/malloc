#include <stdio.h>
#include "api.h"

int main () {
  void *a,*b,*c,*d,*e;

  iniciaAlocador(); 
  imprimeMapa();
  // 0) estado inicial

  a=(void *) bestFitMalloc(100);
  imprimeMapa();
  b=(void *) bestFitMalloc(130);
  imprimeMapa();
  c=(void *) bestFitMalloc(120);
  imprimeMapa();
  d=(void *) bestFitMalloc(110);
  imprimeMapa();
  // 1) Espero ver quatro segmentos ocupados

  liberaMem(b);
  imprimeMapa(); 
  liberaMem(d);
  imprimeMapa(); 
  // 2) Espero ver quatro segmentos alternando
  //    ocupados e livres

  b=(void *) bestFitMalloc(50);
  imprimeMapa();
  d=(void *) bestFitMalloc(90);
  imprimeMapa();
  e=(void *) bestFitMalloc(40);
  imprimeMapa();
  // 3) Deduzam
	
  liberaMem(c);
  imprimeMapa(); 
  liberaMem(a);
  imprimeMapa();
  liberaMem(b);
  imprimeMapa();
  liberaMem(d);
  imprimeMapa();
  liberaMem(e);
  imprimeMapa();
   // 4) volta ao estado inicial

  finalizaAlocador();
}