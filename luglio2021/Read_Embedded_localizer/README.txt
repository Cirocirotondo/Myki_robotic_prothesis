NB! 
Per fare ordine ho raccolto le funzioni necessarie ai vari script nelle cartelle "functions_RUN", "functions_SETUP" e "functions_VALERIO".
Le cartelle con le funzioni necessarie vanno quindi aggiunte al path all'inizio degli script!

SETUP_SIMONE:
codice che ottiene le traiettorie su cui si muovono i magneti. 
Si collega alle boards del mockup e dei servo, e fa muovere i magneti da un finecorsa all'altro, salvandosi le posizioni dei magneti.
Poi, da queste posizioni ottiene le traiettorie.

MOVIMENTO_MOTORI:
Nel caso di script che non gestiscono il movimento dei motori (ad esempio "RUN_SIMONE"), si può usare questo script.


REMINDER: I magneti non sono automaticamente associati alle traiettorie!! Stacci attento!
Ad esempio, mentre stavo valutando il problema si aveva:

Nelle matrici di positions: (codice di RUN)
1a riga = muscolo 6
2a riga = muscolo 12
3a riga = muscolo 10
4a riga = muscolo 5

Traiettorie:
1a riga = muscolo 1
2a riga = muscolo 10
3a riga = muscolo 12
4a riga = muscolo 5

La funzione "reorder_trajectories" serve a questo -> farla runnare 1 volta all'inizio della fase di Run, quando il mockup ancora non è stato spostato troppo


