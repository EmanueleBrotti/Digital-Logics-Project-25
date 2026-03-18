// filtro differenziale di ordine 3 senza normalizzazione
// codice di Brotti Emanuele

#include <stdio.h>
#define lenght 7 // data dalla stringa di input iniziale
#define I 2      // 2 in caso di filtro di ordine 3, 3 in caso di filtro di ordine 5

int main()
{
    int vettore[lenght] = {32, -24, -35, 0, 46, -54, -39}; // il vettore puo' essere moooolto lungo, grandezza minima 7
    int vettoreNuovo[lenght];                              // il filtro usa i valori vecchi per calcolare i nuovi, non posso cambiare un numero alla volta -> devo salvarli a parte
    int coefficienti[7] = {0, -1, 8, 0, -8, 1, 0};         // possono cambiare nella specifica

    for (int k = 0; k < lenght; k++)
    { // scorro tutti gli elementi del vettore
        int somma = 0;

        for (int j = -I; j <= I; j++)
        { // j andra' da ±I

            if (k + j >= 0 && k + j < lenght)
            {                                                  // calcola solo se il numero fa parte del vettore, altrimenti somma qualcosa * 0 (inutile)
                somma += coefficienti[3 + j] * vettore[k + j]; // 3 e' la posizione centrale dei coefficienti (il quarto), j si sposta prima a sx poi a dx
            }
        }
        vettoreNuovo[k] = somma;
    }

    // debug
    for (int k = 0; k < lenght; k++)
    {
        printf("%d ", vettoreNuovo[k]);
    }

    return 0;
}