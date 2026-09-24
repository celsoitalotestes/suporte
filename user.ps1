# Garante que o script está rodando como Administrador
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Por favor, execute este script como Administrador!"
    Exit
}

# Obtém automaticamente o nome do usuário logado na sessão atual
$usuarioAtual = [Environment]::UserName
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host " Gerenciador de Usuário - Usuário Atual: $usuarioAtual" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

# Menu de Opções
Write-Host "1. Mudar o nome de login do usuário"
Write-Host "2. Mudar o tipo de permissão (Grupo)"
Write-Host "3. Remover a senha da conta"
Write-Host "4. Sair"
Write-Host ""

$opcao = Read-Host "Escolha uma opção (1-4)"

switch ($opcao) {
    "1" {
        # Alterar Nome
        $novoNome = Read-Host "Digite o novo nome de login para a conta"
        if (-not [string]::IsNullOrWhiteSpace($novoNome)) {
            try {
                Rename-LocalUser -Name $usuarioAtual -NewName $novoNome
                Write-Host "Sucesso! O usuário '$usuarioAtual' agora se chama '$novoNome'." -ForegroundColor Green
                Write-Host "Atenção: Na próxima execução, use o novo nome." -ForegroundColor Yellow
            } catch {
                Write-Error "Erro ao alterar o nome: $_"
            }
        } else {
            Write-Warning "Nome inválido. Operação cancelada."
        }
    }
    
    "2" {
        # Alterar Permissões (Grupos)
        # Identifica o idioma do sistema para usar o nome correto do grupo Administradores
        $grupoAdmin = (Get-LocalGroup -SID "S-1-5-32-544").Name
        $grupoUsuarios = (Get-LocalGroup -SID "S-1-5-32-545").Name

        Write-Host ""
        Write-Host "Escolha o novo nível de permissão:" -ForegroundColor Cyan
        Write-Host "A. Administrador (Acesso total ao sistema)"
        Write-Host "B. Usuário Padrão (Acesso limitado)"
        
        $perm = Read-Host "Escolha uma opção (A ou B)"
        
        try {
            if ($perm -eq "A" -or $perm -eq "a") {
                # Adiciona ao grupo Admin e remove do grupo padrão para limpar o perfil
                Add-LocalGroupMember -Group $grupoAdmin -Member $usuarioAtual
                Remove-LocalGroupMember -Group $grupoUsuarios -Member $usuarioAtual -ErrorAction SilentlyContinue
                Write-Host "Usuário '$usuarioAtual' promovido a Administrador com sucesso!" -ForegroundColor Green
            } 
            elseif ($perm -eq "B" -or $perm -eq "b") {
                # Adiciona ao grupo padrão e remove do grupo Admin
                Add-LocalGroupMember -Group $grupoUsuarios -Member $usuarioAtual -ErrorAction SilentlyContinue
                Remove-LocalGroupMember -Group $grupoAdmin -Member $usuarioAtual
                Write-Host "Usuário '$usuarioAtual' rebaixado para Usuário Padrão com sucesso!" -ForegroundColor Green
            } 
            else {
                Write-Warning "Opção inválida. Operação cancelada."
            }
        } catch {
            Write-Error "Erro ao alterar permissões: $_. Verifique se o usuário já não possui essa permissão."
        }
    }
    
    "3" {
        # Remover Senha
        $confirmar = Read-Host "Tem certeza que deseja remover a senha de '$usuarioAtual'? (S/N)"
        if ($confirmar -eq "S" -or $confirmar -eq "s") {
            try {
                Set-LocalUser -Name $usuarioAtual -Password (New-Object System.Security.SecureString)
                Write-Host "Senha removida com sucesso! O usuário '$usuarioAtual' agora não possui senha." -ForegroundColor Green
            } catch {
                Write-Error "Erro ao remover a senha: $_"
            }
        } else {
            Write-Host "Operação cancelada." -ForegroundColor Yellow
        }
    }
    
    "4" {
        Write-Host "Saindo..." -ForegroundColor Yellow
        Exit
    }
    
    Default {
        Write-Warning "Opção inválida de menu."
    }
}

Write-Host ""
Read-Host "Pressione Enter para fechar"
