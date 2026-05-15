# APP HUB — Documentazione

Launcher grafico per applicazioni locali, in stile terminale Fallout.  
Scritto interamente in PowerShell con WPF, senza dipendenze esterne.

---

## File inclusi

| File | Scopo |
|------|-------|
| `hub.ps1` | Script principale |
| `avvia_hub.bat` | Doppio clic per aprire l'hub |
| `config.json` | Generato automaticamente al primo avvio |

Tutti e tre i file devono stare **nella stessa cartella**.

---

## Avvio

Doppio clic su `avvia_hub.bat`.  
Il `.bat` gestisce automaticamente l'execution policy di PowerShell, quindi non serve nessuna configurazione aggiuntiva.

Al primo avvio, se `config.json` non esiste viene creato vuoto e l'hub si presenta senza app configurate.

---

## Interfaccia

La finestra è unica e scorrevole. Nella parte superiore compare la lista delle app configurate; nella parte inferiore i tre bottoni di gestione. Quando si esegue un'azione (aggiungi, modifica, rimuovi), il form relativo appare sotto i bottoni nella stessa finestra, senza aprire finestre separate.

La barra di stato sotto il titolo mostra l'ultima azione eseguita con orario.

---

## Avviare un'app

Clic sul bottone con il nome dell'app. L'app parte in background in una nuova finestra, l'hub rimane aperto.

---

## Aggiungere un'app

Clic su **[ + AGGIUNGI ]**, compilare i campi:

| Campo | Contenuto |
|-------|-----------|
| Nome | Nome visualizzato nell'hub |
| Percorso cartella | Percorso assoluto della cartella dell'app (es. `F:\MiaApp`) |
| Tipo avvio | `bat`, `ps1` oppure `npm` |
| File avvio | Nome del file `.bat` o `.ps1` (es. `avvio.bat`) — **lasciare vuoto se tipo è `npm`** |
| Descrizione | Testo opzionale mostrato sotto il nome, in colore ambra scuro |

Clic su **[ SALVA ]** per confermare, **[ ANNULLA ]** per annullare.

### Tipi di avvio

- **bat** — esegue il file `.bat` indicato nella cartella dell'app
- **ps1** — esegue il file `.ps1` indicato con `-ExecutionPolicy Bypass`
- **npm** — apre una finestra cmd, entra nella cartella e lancia `npm start`

---

## Modificare un'app

Clic su **[ ~ MODIFICA ]**, selezionare l'app dalla lista, poi scegliere cosa modificare:

| Voce | Cosa modifica |
|------|---------------|
| Nome | Il nome visualizzato nell'hub |
| Percorso | La cartella dell'app; aggiorna automaticamente anche il path del file di avvio |
| File di avvio | Il nome del file e/o il tipo di avvio |
| Descrizione | Il testo descrittivo sotto il nome |
| Tutto | Tutti i campi insieme in un unico form |

Il form mostra i valori attuali precompilati. Clic su **[ SALVA ]** per confermare.

---

## Rimuovere un'app

Clic su **[ - RIMUOVI ]**, selezionare l'app, confermare con **[ SI, RIMUOVI ]**.  
L'operazione è permanente: il record viene rimosso dal `config.json`.

---

## config.json

Le app sono salvate in un file JSON nella stessa cartella dell'hub. Struttura di ogni voce:

```json
{
  "name": "Nome App",
  "app_path": "F:\\Percorso\\App",
  "start_type": "bat",
  "start_file": "F:\\Percorso\\App\\avvio.bat",
  "description": "Descrizione opzionale"
}
```

Il file è compatibile con versioni precedenti: le voci senza il campo `description` vengono lette correttamente e il campo viene trattato come stringa vuota.

Il JSON può essere modificato manualmente se necessario — l'hub lo rilegge ad ogni avvio.

---

## Portabilità

L'hub è pensato per essere portabile: legge e scrive `config.json` sempre nella propria cartella, indipendentemente da dove viene lanciato. Per usarlo su un altro PC è sufficiente copiare la cartella intera. I percorsi delle app nel JSON sono assoluti, quindi vanno aggiornati se la struttura delle cartelle cambia (tramite Modifica → Percorso).

---

## Requisiti

- Windows con PowerShell 5.1 o superiore (incluso in Windows 10/11 di default)
- .NET Framework 4.x (incluso in Windows 10/11 di default)
- Nessuna installazione aggiuntiva richiesta
