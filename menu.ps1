clear-host
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "        BIPNET - FERRAMENTAS DE SUPORTE     " -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1) Abrir Chris Titus Winutil"
Write-Host "2) Instalar Navegadores (Chrome e Brave)"
Write-Host "3) Instalar Ferramentas (7-Zip, Foxit, MicroSIP e AnyDesk)"
Write-Host "4) Aplicar Papel de Parede Padrao"
Write-Host "5) Instalacao Completa Automatizada (Opcoes 2, 3 e 4)"
Write-Host "6) Ativadores (Office e Windows)"
Write-Host "7) Sair"
Write-Host ""

$opcao = Read-Host "Digite o numero da opcao desejada"

# Bloco reutilizável para aplicar o papel de parede (usado na opção 4 e na automação)
$ScriptBlockWallpaper = {
    Write-Host "Baixando e aplicando o papel de parede..." -ForegroundColor Green
    $NomeImagem = "wallpaper.png"
    $UrlImagem = "https://absnetfibra.com.br/suporte/wallpaper.png"
    $PastaImagens = [System.IO.Path]::Combine([Environment]::GetFolderPath("MyPictures"))
    $CaminhoDestino = Join-Path $PastaImagens $NomeImagem

    try {
        $webClient = New-Object System.Net.WebClient
        $webClient.Headers.Add("user-agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36")
        $webClient.DownloadFile($UrlImagem, $CaminhoDestino)
        $webClient.Dispose()

        if ((Get-Item $CaminhoDestino).Length -lt 5120) {
            throw "O arquivo baixado está vazio ou inválido."
        }

        Write-Host "Imagem salva com sucesso em: $CaminhoDestino" -ForegroundColor Gray

        $CsharpCodigo = @"
        using System;
        using System.Runtime.InteropServices;
        public class Wallpaper {
            [DllImport("user32.dll", CharSet = CharSet.Auto)]
            public static extern int SystemParametersInfo(int uAction, int uParam, string lvParam, int fuWinIni);
        }
"@
        Add-Type -TypeDefinition $CsharpCodigo -ErrorAction SilentlyContinue
        [Wallpaper]::SystemParametersInfo(20, 0, $CaminhoDestino, 3)
        Write-Host "Papel de parede aplicado com sucesso!" -ForegroundColor Cyan
    }
    catch {
        Write-Host "Erro no papel de parede: $_" -ForegroundColor Red
    }
}

switch ($opcao) {
    1 {
        Write-Host "Iniciando Chris Titus Winutil..." -ForegroundColor Green
        irm "https://christitus.com" | iex
    }
    2 {
        Write-Host "Instalando navegadores via Winget..." -ForegroundColor Green
        winget install --id Google.Chrome -e --silent --accept-source-agreements --accept-package-agreements
        winget install --id Mozilla.Firefox -e --silent --accept-source-agreements --accept-package-agreements
    }
    3 {
        Write-Host "Instalando ferramentas..." -ForegroundColor Green
        winget install --id 7zip.7zip -e --silent --accept-source-agreements --accept-package-agreements
        winget install --id AnyDeskSoftwareGmbH.AnyDesk -e --silent --accept-source-agreements --accept-package-agreements
        winget install --id MicroSIP.MicroSIP -e --silent --accept-source-agreements --accept-package-agreements
        winget install --id Foxit.FoxitReader -e --silent --accept-source-agreements --accept-package-agreements
    }
    4 {
        & $ScriptBlockWallpaper
    }
    5 {
        Write-Host "=== INICIANDO INSTALAÇÃO AUTOMATIZADA COMPLETA ===" -ForegroundColor Yellow
        
        Write-Host "`n[1/3] Instalando Navegadores..." -ForegroundColor Magenta
        winget install --id Google.Chrome -e --silent --accept-source-agreements --accept-package-agreements
        winget install --id Brave.Brave -e --silent --accept-source-agreements --accept-package-agreements
        #winget install --id Mozilla.Firefox -e --silent --accept-source-agreements --accept-package-agreements
        
        Write-Host "`n[2/3] Instalando Ferramentas..." -ForegroundColor Magenta
        winget install --id 7zip.7zip -e --silent --accept-source-agreements --accept-package-agreements
        winget install --id AnyDeskSoftwareGmbH.AnyDesk -e --silent --accept-source-agreements --accept-package-agreements
        winget install --id MicroSIP.MicroSIP -e --silent --accept-source-agreements --accept-package-agreements
        winget install --id Foxit.FoxitReader -e --silent --accept-source-agreements --accept-package-agreements
        
        Write-Host "`n[3/3] Aplicando Identidade Visual..." -ForegroundColor Magenta
        & $ScriptBlockWallpaper

        Write-Host "`n=== PROCESSO CONCLUÍDO COM SUCESSO ===" -ForegroundColor Green
    }
    6 {
        Write-Host "Iniciando Ativadores..." -ForegroundColor Green
        irm "https://get.activated.win" | iex
    }
    7 {
        Write-Host "Saindo..." -ForegroundColor Yellow
        exit
    }
    Default {
        Write-Host "Opção inválida!" -ForegroundColor Red
    }
}
