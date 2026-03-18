// codice di Brotti Emanuele

#include <stdio.h>
#define k 20      // data dalla stringa di input iniziale
#define ordine 1  // 0->3, 1->
#define sizeReg 5 // ordine 5 richiede solo i 3 precedenti, 4 posizioni. 5° per salvare l'output

int shiftreg[sizeReg] = {0, 0, 0, 0, 0};          // TODO shift reg
int shiftregRisultato[sizeReg] = {0, 0, 0, 0, 0}; // TODO valore di reset

void push() // meccanica che sposta i valori dello shiftreg
{
    for (int p = sizeReg - 1; p > 0; p--)
    {
        shiftreg[p] = shiftreg[p - 1];
    }
}

void pushRisultato()
{
    for (int p = sizeReg - 1; p > 0; p--)
    {
        shiftregRisultato[p] = shiftregRisultato[p - 1];
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

    // printf("%d ", risultato); // TODO salva in memo. il valore
    printf("%d ", valore);
}

void debug() // NON da implementare
{
    printf("\nshiftreg: ");
    for (int z = 0; z < sizeReg; z++)
    {
        printf("%d ", shiftreg[z]);
    }
    printf("\nshiftregRis: ");
    for (int z = 0; z < sizeReg; z++)
    {
        printf("%d ", shiftregRisultato[z]);
    }
    printf("\n");
}

int main()
{

    int vettore[k] = {-115, 60, -102, 14, -112, 7, -68, -122, -96, 120, 8, -101, -108, 90, 93, -47, 67, -125, -90, 23}; // puo' essere moooolto lungo, minimo 7
    // int coefficienti3[7] = {0, -1, 8, 0, -8, 1, 0};
    // int coefficienti5[7] = {1, -9, 45, 0, -45, 9, -1};

    // TODO 7 mux che confrontano uno a uno tutti i coefficienti con segnale s. 0 e 6 nel caso 3° possono usare "0" nel mux al posto dei valori reali, non vengono usati
    int coefficienti[7] = {1, -9, 45, 0, -45, 9, -1}; // possono cambiare nella specifica

    for (int p = 0; p < k + sizeReg; p++) // +sizeReg serve per processare TUTTI i numeri in ingresso. Spacca perche' vinisce con un shiftreg di soli 0
    {                                     // scorro k elementi -> //TODO contatore fino a k + 4

        push();
        if (p < k) // TODO mux
        {
            shiftreg[0] = vettore[p];
        }
        else
        {
            shiftreg[0] = 0;
        }

        if (p > sizeReg - 1) // TODO state machine che dopo tot inizia a salvare
        {                    // quando lo shiftreg e' pieno butta via dei risultati
            normalizza(shiftregRisultato[sizeReg - 1]);
        }
        pushRisultato();
        shiftregRisultato[0] = 0;

        // combinatorio, non so l'ordine
        shiftregRisultato[0] += shiftreg[0] * coefficienti[3]; // 3 e' il coefficiente centrale

        shiftregRisultato[0] += shiftreg[1] * coefficienti[2];
        shiftregRisultato[1] += shiftreg[0] * coefficienti[4];

        shiftregRisultato[0] += shiftreg[2] * coefficienti[1]; // 3-2, calcolo il coef. vecchio per quello nuovo. Lo shiftreg tiene valori vecchi piu' avanti
        shiftregRisultato[2] += shiftreg[0] * coefficienti[5];

        shiftregRisultato[0] += shiftreg[3] * coefficienti[0];
        shiftregRisultato[3] += shiftreg[0] * coefficienti[6];

        // debug();
    }

    return 0; // TODO segnale di end
}