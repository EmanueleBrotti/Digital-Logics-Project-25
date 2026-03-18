// codice di Brotti Emanuele

#include <stdio.h>
#define k 7      // data dalla stringa di input iniziale
#define ordine 1 // 0->3, 1->

#define sizeReg 7 // salvo 7 elementi alla volta, elaboro quello centrale

int shiftreg[sizeReg] = {0, 0, 0, 0, 0, 0, 0}; // TODO shift reg
int regRis = 0;

void push() // meccanica che sposta i valori dello shiftreg
{
    for (int p = sizeReg - 1; p > 0; p--)
    {
        shiftreg[p] = shiftreg[p - 1];
    }
}

void normalizza(int valore)
{
    int risultato = 0;

    // divisione per 60 approssimata
    risultato += valore / 64 + valore / 1024; // TODO visto che sono bitshifts dovrai fare un mux che aggiunge +1 se il numero e' negativo, 0 altrimenti

    if (!ordine)
    { // la divisione per 12 (ordine 3) aggiunge piu' valori //TODO mux che altrimenti aggiunge 0
        risultato += valore / 16 + valore / 256;
    }

    // printf("%d ", risultato); // TODO salva in memo. il valore, sono sfasati rispetto a p di 3
    printf("%d ", valore);
}

void debug() // NON da implementare
{
    printf("\nshiftreg: ");
    for (int z = 0; z < sizeReg; z++)
    {
        printf("%d ", shiftreg[z]);
    }
    printf("\n");
}

int main()
{

    int vettore[k] = {1, 0, 0, 2, 3, 0, 4}; // puo' essere moooolto lungo, minimo 7
    // int coefficienti3[7] = {0, -1, 8, 0, -8, 1, 0};
    // int coefficienti5[7] = {1, -9, 45, 0, -45, 9, -1};

    // TODO 7 mux che confrontano uno a uno tutti i coefficienti con segnale s. 0 e 6 nel caso 3° possono usare "0" nel mux al posto dei valori reali, non vengono usati
    int coefficienti[7] = {0, -1, 8, 0, -8, 1, 0}; // possono cambiare nella specifica

    for (int p = 0; p < k + 3; p++)
    { // +3 per spostare il primo elemento al centro a inizio loop, in modo tale da iniziare i calcoli //TODO contatore fino a k + 3

        push();
        if (p < k) // TODO mux
        {
            shiftreg[0] = vettore[p];
        }
        else
        {
            shiftreg[0] = 0;
        }

        regRis = 0; // non esiste nel circuito logico, assume direttamente un valore

        // combinatorio, non so l'ordine

        regRis += shiftreg[0] * coefficienti[6]; // il piu' recente e' il primo nello shiftreg -> il successivo maggiore -> coefficiente piu' alto
        regRis += shiftreg[1] * coefficienti[5];
        regRis += shiftreg[2] * coefficienti[4];

        regRis += shiftreg[3] * coefficienti[3]; // 3 e' il coefficiente centrale

        regRis += shiftreg[4] * coefficienti[2];
        regRis += shiftreg[5] * coefficienti[1];
        regRis += shiftreg[6] * coefficienti[0];

        if (p > 2)              // alla 3° ho il valore giusto
        {                       // p non e' uno dei primi zeri //TODO fsa
            normalizza(regRis); // TODO salvato in un registro a parte
        }

        // debug();
    }

    // TODO alla fine devo ripulire lo shiftreg. Ho un elemento centrale e 3 zeri a sx

    for (int p = 0; p < 4; p++)
    {
        push();
        shiftreg[0] = 0;
    }

    return 0; // TODO segnale di end
}