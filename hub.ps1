# ============================================================
#  HUB APPLICAZIONI - hub.ps1  (WPF Single-Window Edition)
#  Avviare con: avvia_hub.bat
# ============================================================

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

$ScriptDir  = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ConfigFile = Join-Path $ScriptDir "config.json"

# ── Config I/O ───────────────────────────────────────────────
function Load-Config {
    $list = [System.Collections.ArrayList]::new()
    if (-not (Test-Path $ConfigFile)) { return $list }
    $raw = Get-Content $ConfigFile -Raw -Encoding UTF8
    if ([string]::IsNullOrWhiteSpace($raw)) { return $list }
    $parsed = $raw | ConvertFrom-Json
    if ($null -eq $parsed) { return $list }
    foreach ($item in @($parsed)) {
        $obj = [PSCustomObject]@{
            name        = if ($item.PSObject.Properties["name"])        { "$($item.name)" }        else { "" }
            app_path    = if ($item.PSObject.Properties["app_path"])    { "$($item.app_path)" }    else { "" }
            start_type  = if ($item.PSObject.Properties["start_type"])  { "$($item.start_type)" }  else { "" }
            start_file  = if ($item.PSObject.Properties["start_file"])  { "$($item.start_file)" }  else { "" }
            description = if ($item.PSObject.Properties["description"]) { "$($item.description)" } else { "" }
        }
        $list.Add($obj) | Out-Null
    }
    return $list
}

function Save-Config {
    param($Apps)
    $Apps | ConvertTo-Json -Depth 5 | Set-Content $ConfigFile -Encoding UTF8
}

# Crea il file config se non esiste ancora
if (-not (Test-Path $ConfigFile)) {
    "[]" | Set-Content $ConfigFile -Encoding UTF8
}

# ── Lancio app ───────────────────────────────────────────────
function Start-App {
    param($App)
    switch ($App.start_type) {
        "bat" { Start-Process cmd        -ArgumentList "/c `"$($App.start_file)`""                            -WorkingDirectory $App.app_path }
        "ps1" { Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$($App.start_file)`"" -WorkingDirectory $App.app_path }
        "npm" { Start-Process cmd        -ArgumentList "/k cd /d `"$($App.app_path)`" && npm start" }
        "exe" { Start-Process $App.start_file                                                                 -WorkingDirectory $App.app_path }
    }
}

# ── Colori ───────────────────────────────────────────────────
$C_AMBER  = [System.Windows.Media.SolidColorBrush][System.Windows.Media.Color]::FromRgb(0xD4,0x87,0x0A)
$C_DIM    = [System.Windows.Media.SolidColorBrush][System.Windows.Media.Color]::FromRgb(0x8B,0x5A,0x00)
$C_DIMMER = [System.Windows.Media.SolidColorBrush][System.Windows.Media.Color]::FromRgb(0x4A,0x30,0x00)
$C_DESC   = [System.Windows.Media.SolidColorBrush][System.Windows.Media.Color]::FromRgb(0x7A,0x50,0x10)
$C_GHOST  = [System.Windows.Media.SolidColorBrush][System.Windows.Media.Color]::FromRgb(0x5A,0x3A,0x00)
$C_BG     = [System.Windows.Media.SolidColorBrush][System.Windows.Media.Color]::FromRgb(0x0A,0x0A,0x0A)
$C_BTN    = [System.Windows.Media.SolidColorBrush][System.Windows.Media.Color]::FromRgb(0x1A,0x1A,0x1A)
$C_STATUS = [System.Windows.Media.SolidColorBrush][System.Windows.Media.Color]::FromRgb(0x6B,0x6B,0x6B)
$C_INPUT  = [System.Windows.Media.SolidColorBrush][System.Windows.Media.Color]::FromRgb(0x12,0x12,0x12)
$C_RED    = [System.Windows.Media.SolidColorBrush][System.Windows.Media.Color]::FromRgb(0xCC,0x44,0x00)
$F_MONO   = [System.Windows.Media.FontFamily]::new("Courier New")

# ── Helper costruzione controlli ──────────────────────────────
function New-TB { # TextBlock
    param([string]$Text, $Fg = $C_AMBER, [double]$Size = 13, [bool]$Bold = $false)
    $tb = [System.Windows.Controls.TextBlock]::new()
    $tb.Text       = $Text
    $tb.Foreground = $Fg
    $tb.FontSize   = $Size
    $tb.FontFamily = $F_MONO
    if ($Bold) { $tb.FontWeight = [System.Windows.FontWeights]::Bold }
    return $tb
}

function New-Input {
    param([string]$Value = "", [bool]$ReadOnly = $false)
    $tb = [System.Windows.Controls.TextBox]::new()
    $tb.Text        = $Value
    $tb.IsReadOnly  = $ReadOnly
    $tb.Background  = $C_INPUT
    $tb.Foreground  = if ($ReadOnly) { $C_GHOST } else { $C_AMBER }
    $tb.BorderBrush = $C_DIMMER
    $tb.CaretBrush  = $C_AMBER
    $tb.Padding     = [System.Windows.Thickness]::new(6,4,6,4)
    $tb.Margin      = [System.Windows.Thickness]::new(0,4,0,8)
    $tb.FontFamily  = $F_MONO
    $tb.FontSize    = 12
    return $tb
}

function New-Btn {
    param([string]$Label, [bool]$Accent = $false)
    $btn = [System.Windows.Controls.Button]::new()
    $btn.Content         = $Label
    $btn.Background      = $C_BTN
    $btn.Foreground      = if ($Accent) { $C_AMBER } else { $C_DIM }
    $btn.BorderBrush     = if ($Accent) { $C_DIM }   else { $C_DIMMER }
    $btn.BorderThickness = [System.Windows.Thickness]::new(1)
    $btn.Padding         = [System.Windows.Thickness]::new(12,7,12,7)
    $btn.Margin          = [System.Windows.Thickness]::new(4,0,4,0)
    $btn.Cursor          = [System.Windows.Input.Cursors]::Hand
    $btn.FontFamily      = $F_MONO
    $btn.FontSize        = 12
    return $btn
}

function New-Separator {
    $tb = [System.Windows.Controls.TextBlock]::new()
    $tb.Text       = [string]([char]0x2500) * 44
    $tb.Foreground = $C_DIMMER
    $tb.FontFamily = $F_MONO
    $tb.Margin     = [System.Windows.Thickness]::new(0,8,0,8)
    return $tb
}

# ============================================================
#  COSTRUZIONE FINESTRA MANUALE (no XAML secondario)
# ============================================================

# -- Finestra principale
$window                  = [System.Windows.Window]::new()
$window.Title            = "// APP HUB //"
$window.Width            = 560
$window.Height           = 640
$window.MinWidth         = 440
$window.MinHeight        = 480
$window.Background       = $C_BG
$window.FontFamily       = $F_MONO
$window.WindowStartupLocation = [System.Windows.WindowStartupLocation]::CenterScreen
$window.ResizeMode       = [System.Windows.ResizeMode]::CanResize

# -- Root ScrollViewer > StackPanel
$rootScroll              = [System.Windows.Controls.ScrollViewer]::new()
$rootScroll.VerticalScrollBarVisibility = [System.Windows.Controls.ScrollBarVisibility]::Auto
$rootScroll.Background   = $C_BG
$rootScroll.Padding      = [System.Windows.Thickness]::new(20)

$root                    = [System.Windows.Controls.StackPanel]::new()
$rootScroll.Content      = $root
$window.Content          = $rootScroll

# -- Header
$header                  = New-TB "$(([string][char]0x2593)*2)  APP HUB  $(([string][char]0x2593)*2)" $C_AMBER 22 $true
$header.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Center
$root.Children.Add($header) | Out-Null
$root.Children.Add((New-Separator)) | Out-Null

# -- Status bar
$StatusText              = New-TB "Seleziona una applicazione da avviare." $C_STATUS 11
$StatusText.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Center
$StatusText.Margin       = [System.Windows.Thickness]::new(0,0,0,12)
$root.Children.Add($StatusText) | Out-Null

# -- Label sezione app
$root.Children.Add((New-TB "[ APPLICAZIONI ]" $C_GHOST 11)) | Out-Null

# -- Contenitore lista app
$AppList                 = [System.Windows.Controls.StackPanel]::new()
$AppList.Margin          = [System.Windows.Thickness]::new(0,4,0,4)
$root.Children.Add($AppList) | Out-Null

$root.Children.Add((New-Separator)) | Out-Null

# -- Bottoni azione principali
$actionRow               = [System.Windows.Controls.StackPanel]::new()
$actionRow.Orientation   = [System.Windows.Controls.Orientation]::Horizontal
$actionRow.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Center
$actionRow.Margin        = [System.Windows.Thickness]::new(0,0,0,16)

$BtnAdd                  = New-Btn "[ + AGGIUNGI ]" $false
$BtnEdit                 = New-Btn "[ ~ MODIFICA ]" $false
$BtnRemove               = New-Btn "[ - RIMUOVI ]"  $false
$actionRow.Children.Add($BtnAdd)    | Out-Null
$actionRow.Children.Add($BtnEdit)   | Out-Null
$actionRow.Children.Add($BtnRemove) | Out-Null
$root.Children.Add($actionRow) | Out-Null

# -- Pannello form (nascosto di default)
$FormPanel               = [System.Windows.Controls.StackPanel]::new()
$FormPanel.Visibility    = [System.Windows.Visibility]::Collapsed
$FormPanel.Margin        = [System.Windows.Thickness]::new(0,0,0,12)
$root.Children.Add($FormPanel) | Out-Null

$script:apps = [System.Collections.ArrayList]::new()
$loaded = Load-Config
if ($null -ne $loaded) { foreach ($a in $loaded) { $script:apps.Add($a) | Out-Null } }

# ── Helper: mostra/nascondi form ──────────────────────────────
function Show-Form  { $FormPanel.Visibility = [System.Windows.Visibility]::Visible }
function Hide-Form  {
    $FormPanel.Visibility = [System.Windows.Visibility]::Collapsed
    $FormPanel.Children.Clear()
}

# ── Helper indice reale ───────────────────────────────────────
function Get-RealIndex {
    param([string]$AppName)
    for ($i = 0; $i -lt $script:apps.Count; $i++) {
        if ($script:apps[$i].name -eq $AppName) { return $i }
    }
    return -1
}

# ── Aggiunge riga label + input al FormPanel ──────────────────
function Add-FormRow {
    param([System.Windows.Controls.StackPanel]$Panel, [string]$Label, [string]$Value = "", [bool]$ReadOnly = $false)
    $Panel.Children.Add((New-TB ($Label + " :") $C_DIM 11)) | Out-Null
    $tb = New-Input $Value $ReadOnly
    $Panel.Children.Add($tb) | Out-Null
    return $tb
}

# ── Refresh lista app ─────────────────────────────────────────
function Refresh-AppList {
    $AppList.Children.Clear()
    $sorted = $script:apps | Sort-Object { $_.name }

    foreach ($app in $sorted) {
        $inner             = [System.Windows.Controls.StackPanel]::new()
        $inner.Orientation = [System.Windows.Controls.Orientation]::Vertical

        $nameTb            = New-TB ([char]0x25B6 + "  " + $app.name) $C_AMBER 14 $true
        $inner.Children.Add($nameTb) | Out-Null

        if ($app.description -and $app.description.Trim() -ne "") {
            $descTb        = New-TB ("   " + $app.description) $C_DESC 11
            $descTb.Margin = [System.Windows.Thickness]::new(0,2,0,0)
            $inner.Children.Add($descTb) | Out-Null
        }

        $btn                     = [System.Windows.Controls.Button]::new()
        $btn.Content             = $inner
        $btn.Background          = $C_BTN
        $btn.Foreground          = $C_AMBER
        $btn.BorderBrush         = $C_DIM
        $btn.BorderThickness     = [System.Windows.Thickness]::new(1)
        $btn.Padding             = [System.Windows.Thickness]::new(12,10,12,10)
        $btn.Margin              = [System.Windows.Thickness]::new(0,3,0,3)
        $btn.Cursor              = [System.Windows.Input.Cursors]::Hand
        $btn.HorizontalContentAlignment = [System.Windows.HorizontalAlignment]::Left
        $btn.Tag                 = $app.name

        $btn.Add_Click({
            param($s,$e)
            $appName = $s.Tag
            $idx = Get-RealIndex $appName
            if ($idx -ge 0) {
                Start-App -App $script:apps[$idx]
                $time = Get-Date -Format "HH:mm:ss"
                $StatusText.Text = "Avviato: " + $appName + "   [" + $time + "]"
            }
        })

        $AppList.Children.Add($btn) | Out-Null
    }
}

# ============================================================
#  AGGIUNGI
# ============================================================
$BtnAdd.Add_Click({
    Hide-Form
    $FormPanel.Children.Add((New-TB "[ + NUOVA APPLICAZIONE ]" $C_AMBER 13 $true)) | Out-Null
    $FormPanel.Children.Add((New-Separator)) | Out-Null

    $script:tbNome  = Add-FormRow $FormPanel "Nome"
    $script:tbPath  = Add-FormRow $FormPanel "Percorso cartella" "F:\"
    $script:tbTipo  = Add-FormRow $FormPanel "Tipo avvio: bat, ps1, npm oppure exe"
    $script:tbFile  = Add-FormRow $FormPanel "File avvio (es. avvio.bat, app.exe) -- lascia vuoto se npm"
    $script:tbDesc  = Add-FormRow $FormPanel "Descrizione (opzionale)"

    $row     = [System.Windows.Controls.StackPanel]::new()
    $row.Orientation = [System.Windows.Controls.Orientation]::Horizontal
    $row.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Right
    $row.Margin = [System.Windows.Thickness]::new(0,8,0,0)

    $btnOk  = New-Btn "[ SALVA ]"   $true
    $btnNo  = New-Btn "[ ANNULLA ]" $false
    $row.Children.Add($btnOk)  | Out-Null
    $row.Children.Add($btnNo)  | Out-Null
    $FormPanel.Children.Add($row) | Out-Null

    Show-Form
    $rootScroll.ScrollToBottom()

    $btnNo.Add_Click({ Hide-Form; $StatusText.Text = "Operazione annullata." })

    $btnOk.Add_Click({
        $name = $script:tbNome.Text.Trim()
        $path = $script:tbPath.Text.Trim()
        $type = $script:tbTipo.Text.Trim().ToLower()
        $file = $script:tbFile.Text.Trim()
        $desc = $script:tbDesc.Text.Trim()

        if (-not $name -or -not $path -or -not $type) {
            $StatusText.Text = "ERRORE: Nome, Percorso e Tipo sono obbligatori."
            return
        }

        $startFile = ""
        if ($file -and $type -ne "npm") { $startFile = Join-Path $path $file }

        $newApp = [PSCustomObject]@{
            name        = $name
            app_path    = $path
            start_type  = $type
            start_file  = $startFile
            description = $desc
        }

        $script:apps.Add($newApp) | Out-Null
        Save-Config $script:apps
        Refresh-AppList
        Hide-Form
        $StatusText.Text = "App aggiunta: " + $name
    })
})

# ============================================================
#  MODIFICA - step 1: selezione app
# ============================================================
$BtnEdit.Add_Click({
    if ($script:apps.Count -eq 0) {
        $StatusText.Text = "Nessuna app configurata."
        return
    }

    Hide-Form
    $FormPanel.Children.Add((New-TB "[ ~ MODIFICA - Seleziona app ]" $C_AMBER 13 $true)) | Out-Null
    $FormPanel.Children.Add((New-Separator)) | Out-Null

    $sorted = $script:apps | Sort-Object { $_.name }
    foreach ($a in $sorted) {
        $b     = New-Btn ("  " + $a.name) $false
        $b.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Stretch
        $b.HorizontalContentAlignment = [System.Windows.HorizontalAlignment]::Left
        $b.Margin = [System.Windows.Thickness]::new(0,3,0,3)
        $b.Tag    = $a.name
        $b.Add_Click({
            param($s,$e)
            $selectedName = $s.Tag
            Show-EditSubMenu -AppName $selectedName
        })
        $FormPanel.Children.Add($b) | Out-Null
    }

    $btnNo = New-Btn "[ ANNULLA ]" $false
    $btnNo.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Right
    $btnNo.Margin = [System.Windows.Thickness]::new(0,12,0,0)
    $btnNo.Add_Click({ Hide-Form; $StatusText.Text = "Operazione annullata." })
    $FormPanel.Children.Add($btnNo) | Out-Null

    Show-Form
    $rootScroll.ScrollToBottom()
})

# ── Sotto-menu modifica (step 2) ──────────────────────────────
function Show-EditSubMenu {
    param([string]$AppName)

    Hide-Form
    $FormPanel.Children.Add((New-TB ("[ ~ MODIFICA -- " + $AppName + " ]") $C_AMBER 13 $true)) | Out-Null
    $FormPanel.Children.Add((New-Separator)) | Out-Null
    $FormPanel.Children.Add((New-TB "Cosa vuoi modificare?" $C_DIM 11)) | Out-Null
    $FormPanel.Children.Add([System.Windows.Controls.TextBlock]::new()) | Out-Null  # spacer

    $choices = @(
        @{ Label = "[ 1 ]  Nome";          Key = "nome" },
        @{ Label = "[ 2 ]  Percorso";      Key = "percorso" },
        @{ Label = "[ 3 ]  File di avvio"; Key = "file" },
        @{ Label = "[ 4 ]  Descrizione";   Key = "descrizione" },
        @{ Label = "[ 5 ]  Tutto";         Key = "tutto" }
    )

    foreach ($c in $choices) {
        $b = New-Btn $c.Label $false
        $b.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Stretch
        $b.HorizontalContentAlignment = [System.Windows.HorizontalAlignment]::Left
        $b.Margin = [System.Windows.Thickness]::new(0,3,0,3)
        $b.Tag    = $AppName + "|" + $c.Key
        $b.Add_Click({
            param($s,$e)
            $parts = $s.Tag.Split("|")
            Show-EditField -AppName $parts[0] -Field $parts[1]
        })
        $FormPanel.Children.Add($b) | Out-Null
    }

    $btnNo = New-Btn "[ ANNULLA ]" $false
    $btnNo.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Right
    $btnNo.Margin = [System.Windows.Thickness]::new(0,12,0,0)
    $btnNo.Add_Click({ Hide-Form; $StatusText.Text = "Operazione annullata." })
    $FormPanel.Children.Add($btnNo) | Out-Null

    Show-Form
    $rootScroll.ScrollToBottom()
}

# ── Form modifica campi (step 3) ──────────────────────────────
function Show-EditField {
    param([string]$AppName, [string]$Field)

    $realIdx   = Get-RealIndex $AppName
    if ($realIdx -lt 0) { $StatusText.Text = "App non trovata."; Hide-Form; return }
    $targetApp = $script:apps[$realIdx]

    Hide-Form
    $FormPanel.Children.Add((New-TB ("[ ~ " + $Field.ToUpper() + " -- " + $AppName + " ]") $C_AMBER 13 $true)) | Out-Null
    $FormPanel.Children.Add((New-Separator)) | Out-Null

    $script:efInputs    = @{}
    $script:efField     = $Field
    $script:efRealIdx   = $realIdx
    $script:efTargetApp = $targetApp

    if ($Field -eq "nome") {
        $FormPanel.Children.Add((New-TB "Nome attuale :" $C_GHOST 11)) | Out-Null
        $FormPanel.Children.Add((New-Input $targetApp.name $true)) | Out-Null
        $script:efInputs["nome"] = Add-FormRow $FormPanel "Nuovo nome" $targetApp.name
    }

    if ($Field -eq "percorso") {
        $FormPanel.Children.Add((New-TB "Percorso attuale :" $C_GHOST 11)) | Out-Null
        $FormPanel.Children.Add((New-Input $targetApp.app_path $true)) | Out-Null
        $script:efInputs["percorso"] = Add-FormRow $FormPanel "Nuovo percorso" $targetApp.app_path
    }

    if ($Field -eq "file") {
        $currentFile = if ($targetApp.start_file) { Split-Path -Leaf $targetApp.start_file } else { "" }
        $FormPanel.Children.Add((New-TB "File attuale :" $C_GHOST 11)) | Out-Null
        $FormPanel.Children.Add((New-Input $currentFile $true)) | Out-Null
        $script:efInputs["file"] = Add-FormRow $FormPanel "Nuovo file (es. avvio.bat, app.exe) -- lascia vuoto se npm" $currentFile
        $script:efInputs["tipo"] = Add-FormRow $FormPanel "Tipo avvio: bat, ps1, npm oppure exe" $targetApp.start_type
    }

    if ($Field -eq "descrizione") {
        $script:efInputs["descrizione"] = Add-FormRow $FormPanel "Descrizione" $targetApp.description
    }

    if ($Field -eq "tutto") {
        $currentFile = if ($targetApp.start_file) { Split-Path -Leaf $targetApp.start_file } else { "" }
        $script:efInputs["nome"]        = Add-FormRow $FormPanel "Nome"               $targetApp.name
        $script:efInputs["percorso"]    = Add-FormRow $FormPanel "Percorso"           $targetApp.app_path
        $script:efInputs["tipo"]        = Add-FormRow $FormPanel "Tipo avvio: bat, ps1, npm oppure exe" $targetApp.start_type
        $script:efInputs["file"]        = Add-FormRow $FormPanel "File avvio (es. avvio.bat, app.exe) -- lascia vuoto se npm" $currentFile
        $script:efInputs["descrizione"] = Add-FormRow $FormPanel "Descrizione"        $targetApp.description
    }

    $row = [System.Windows.Controls.StackPanel]::new()
    $row.Orientation = [System.Windows.Controls.Orientation]::Horizontal
    $row.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Right
    $row.Margin = [System.Windows.Thickness]::new(0,8,0,0)

    $btnOk = New-Btn "[ SALVA ]"   $true
    $btnNo = New-Btn "[ ANNULLA ]" $false
    $row.Children.Add($btnOk) | Out-Null
    $row.Children.Add($btnNo) | Out-Null
    $FormPanel.Children.Add($row) | Out-Null

    Show-Form
    $rootScroll.ScrollToBottom()

    $btnNo.Add_Click({ Hide-Form; $StatusText.Text = "Operazione annullata." })

    $btnOk.Add_Click({
        $f   = $script:efField
        $idx = $script:efRealIdx
        $tgt = $script:efTargetApp
        $inp = $script:efInputs

        if ($f -eq "nome") {
            $script:apps[$idx].name = $inp["nome"].Text.Trim()
        }
        if ($f -eq "percorso") {
            $newPath = $inp["percorso"].Text.Trim()
            $script:apps[$idx].app_path = $newPath
            if ($tgt.start_file) {
                $script:apps[$idx].start_file = Join-Path $newPath (Split-Path -Leaf $tgt.start_file)
            }
        }
        if ($f -eq "file") {
            $newType = $inp["tipo"].Text.Trim().ToLower()
            $newFile = $inp["file"].Text.Trim()
            $script:apps[$idx].start_type = $newType
            $script:apps[$idx].start_file = if ($newFile -and $newType -ne "npm") { Join-Path $tgt.app_path $newFile } else { "" }
        }
        if ($f -eq "descrizione") {
            $script:apps[$idx].description = $inp["descrizione"].Text.Trim()
        }
        if ($f -eq "tutto") {
            $newPath = $inp["percorso"].Text.Trim()
            $newType = $inp["tipo"].Text.Trim().ToLower()
            $newFile = $inp["file"].Text.Trim()
            $script:apps[$idx].name        = $inp["nome"].Text.Trim()
            $script:apps[$idx].app_path    = $newPath
            $script:apps[$idx].start_type  = $newType
            $script:apps[$idx].description = $inp["descrizione"].Text.Trim()
            $script:apps[$idx].start_file  = if ($newFile -and $newType -ne "npm") { Join-Path $newPath $newFile } else { "" }
        }

        Save-Config $script:apps
        Refresh-AppList
        Hide-Form
        $StatusText.Text = "Aggiornata: " + $script:apps[$idx].name
    })
}

# ============================================================
#  RIMUOVI
# ============================================================
$BtnRemove.Add_Click({
    if ($script:apps.Count -eq 0) {
        $StatusText.Text = "Nessuna app configurata."
        return
    }

    Hide-Form
    $FormPanel.Children.Add((New-TB "[ - RIMUOVI - Seleziona app ]" $C_RED 13 $true)) | Out-Null
    $FormPanel.Children.Add((New-Separator)) | Out-Null

    $sorted = $script:apps | Sort-Object { $_.name }
    foreach ($a in $sorted) {
        $b = New-Btn ("  " + $a.name) $false
        $b.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Stretch
        $b.HorizontalContentAlignment = [System.Windows.HorizontalAlignment]::Left
        $b.Margin = [System.Windows.Thickness]::new(0,3,0,3)
        $b.Tag    = $a.name
        $b.Add_Click({
            param($s,$e)
            $selectedName = $s.Tag

            Hide-Form
            $FormPanel.Children.Add((New-TB "[ - CONFERMA RIMOZIONE ]" $C_RED 13 $true)) | Out-Null
            $FormPanel.Children.Add((New-Separator)) | Out-Null
            $FormPanel.Children.Add((New-TB ("Rimuovere: " + $selectedName + " ?") $C_AMBER 12)) | Out-Null
            $FormPanel.Children.Add((New-TB "Operazione non reversibile." $C_DIM 11)) | Out-Null

            $row = [System.Windows.Controls.StackPanel]::new()
            $row.Orientation = [System.Windows.Controls.Orientation]::Horizontal
            $row.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Right
            $row.Margin = [System.Windows.Thickness]::new(0,12,0,0)

            $btnSi = New-Btn "[ SI, RIMUOVI ]" $false
            $btnSi.Foreground = $C_RED
            $btnNo = New-Btn "[ ANNULLA ]"     $false
            $row.Children.Add($btnSi) | Out-Null
            $row.Children.Add($btnNo) | Out-Null
            $FormPanel.Children.Add($row) | Out-Null

            Show-Form
            $rootScroll.ScrollToBottom()

            $btnNo.Add_Click({ Hide-Form; $StatusText.Text = "Operazione annullata." })
            $script:removeTarget = $selectedName
            $btnSi.Add_Click({
                $idx = Get-RealIndex $script:removeTarget
                if ($idx -ge 0) {
                    $script:apps.RemoveAt($idx)
                    Save-Config $script:apps
                    Refresh-AppList
                }
                Hide-Form
                $StatusText.Text = "Rimossa: " + $script:removeTarget
            })
        })
        $FormPanel.Children.Add($b) | Out-Null
    }

    $btnNo = New-Btn "[ ANNULLA ]" $false
    $btnNo.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Right
    $btnNo.Margin = [System.Windows.Thickness]::new(0,12,0,0)
    $btnNo.Add_Click({ Hide-Form; $StatusText.Text = "Operazione annullata." })
    $FormPanel.Children.Add($btnNo) | Out-Null

    Show-Form
    $rootScroll.ScrollToBottom()
})

# ── Avvio ─────────────────────────────────────────────────────
Refresh-AppList

if ($script:apps.Count -eq 0) {
    $StatusText.Text = "Nessuna app configurata. Usa [ + AGGIUNGI ] per iniziare."
}

$window.ShowDialog() | Out-Null
