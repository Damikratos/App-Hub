# APP HUB

Launcher grafico per applicazioni locali, scritto interamente in PowerShell con WPF.  
Nessuna dipendenza esterna, nessuna installazione — basta copiare la cartella e avviare.

![Stile terminale ambra su sfondo nero, ispirato al Pip-Boy di Fallout]

---

## Caratteristiche

- Interfaccia grafica in stile terminale (tema ambra su nero, font monospaziato)
- Aggiunta, modifica e rimozione di app dalla GUI, senza toccare file di configurazione manualmente
- Supporto per app avviate tramite `.bat`, `.ps1` o `npm start`
- Descrizione opzionale per ogni app, visibile sotto il nome
- Lista ordinata alfabeticamente automaticamente
- Configurazione salvata in un `config.json` portabile nella stessa cartella
- Avvio silenzioso tramite `.vbs`, senza finestre cmd visibili

---

## Struttura del progetto

```
hub/
├── hub.ps1              # Script principale
├── avvia_hub.vbs        # Avvio normale (nessuna finestra cmd)
├── avvia_hub.bat        # Avvio alternativo, utile per debug
├── config.json          # Generato automaticamente al primo avvio
└── README.md
```

---

## Requisiti

- Windows 10 o 11
- PowerShell 5.1 (incluso di default in Windows 10/11)
- .NET Framework 4.x (incluso di default in Windows 10/11)

Nessun altro requisito. Per app di tipo `npm` è necessario che `node` e `npm` siano installati e nel PATH di sistema.

---

## Installazione

1. Scaricare o clonare la repository
2. Copiare la cartella dove si preferisce
3. Doppio clic su `avvia_hub.vbs`

Al primo avvio, `config.json` viene creato automaticamente nella stessa cartella.

> **Nota:** `avvia_hub.bat` è incluso come strumento di debug — apre una finestra cmd che mostra eventuali errori PowerShell. Per uso normale preferire il `.vbs`.

---

## Avvio rapido

Doppio clic su **`avvia_hub.vbs`** — l'hub si apre direttamente senza finestre di supporto visibili.

---

## Utilizzo

### Avviare un'app

Clic sul bottone con il nome dell'app. L'app parte in una nuova finestra in background, l'hub rimane aperto. L'orario di avvio viene mostrato nella barra di stato.

### Aggiungere un'app

Clic su **[ + AGGIUNGI ]** e compilare i campi:

| Campo | Descrizione |
|-------|-------------|
| Nome | Nome visualizzato nell'hub |
| Percorso cartella | Percorso assoluto della cartella dell'app (es. `F:\MiaApp`) |
| Tipo avvio | `bat`, `ps1` oppure `npm` |
| File avvio | Nome del file `.bat` o `.ps1` (es. `avvio.bat`) — **lasciare vuoto se tipo è `npm`** |
| Descrizione | Testo opzionale mostrato sotto il nome |

#### Tipi di avvio supportati

| Tipo | Comportamento |
|------|---------------|
| `bat` | Esegue il file `.bat` nella cartella dell'app |
| `ps1` | Esegue il file `.ps1` con `-ExecutionPolicy Bypass` |
| `npm` | Apre una finestra cmd, entra nella cartella e lancia `npm start` |

### Modificare un'app

Clic su **[ ~ MODIFICA ]**, selezionare l'app, poi scegliere cosa modificare:

| Voce | Cosa cambia |
|------|-------------|
| Nome | Il nome visualizzato nell'hub |
| Percorso | La cartella dell'app; aggiorna automaticamente il path del file di avvio |
| File di avvio | Il nome del file e/o il tipo di avvio |
| Descrizione | Il testo sotto il nome |
| Tutto | Tutti i campi in un unico form |

I campi vengono precompilati con i valori attuali.

### Rimuovere un'app

Clic su **[ - RIMUOVI ]**, selezionare l'app e confermare. L'operazione è permanente.

---

## config.json

Le app sono salvate in formato JSON nella stessa cartella dell'hub. Struttura di ogni voce:

```json
{
  "name": "Nome App",
  "app_path": "F:\\Percorso\\App",
  "start_type": "bat",
  "start_file": "F:\\Percorso\\App\\avvio.bat",
  "description": "Descrizione opzionale"
}
```

Il file può essere modificato manualmente se necessario — viene riletto ad ogni avvio.  
Le voci senza il campo `description` sono compatibili e vengono gestite correttamente.

---

## Portabilità

L'hub legge e scrive sempre nella propria cartella, indipendentemente da dove viene lanciato. Per spostarlo o condividerlo è sufficiente copiare la cartella intera.

I percorsi nel `config.json` sono assoluti: se la struttura delle cartelle cambia, aggiornarli tramite **Modifica → Percorso**.

---

## Licenza

MIT
