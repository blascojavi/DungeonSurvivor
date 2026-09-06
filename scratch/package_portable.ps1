$src = "build\windows\x64\runner\Release"
$dest = "ShadowVault_Windows_Portable"

if (Test-Path $dest) {
    Remove-Item -Recurse -Force $dest
}
New-Item -ItemType Directory -Path $dest | Out-Null
Copy-Item -Path "$src\*" -Destination $dest -Recurse -Force
Copy-Item -Path "$dest\juego.exe" -Destination "$dest\ShadowVault.exe" -Force

$readme = @"
==================================================
        SHADOW VAULT: DUNGEON SURVIVOR 2D
               VERSION PORTABLE PARA PC
==================================================

INSTRUCCIONES DE JUEGO:
1. Haz doble clic sobre 'ShadowVault.exe' para iniciar el juego.
2. No requiere instalacion previa ni permisos de administrador.

CONTROLES:
- Mover al heroe: Teclas W, A, S, D  o  Flechas de direccion.
- Menus, Tienda y Ajustes: Clic con el raton.
- Habilidad Definitiva (Nova): Clic en el boton NOVA cuando cargue.
- Pausa en combate: Clic en el boton de pausa (arriba a la derecha).

¡A DISFRUTAR DE LA MAZMORRA!
"@

[System.IO.File]::WriteAllText("$dest\LEEME_JUGAR.txt", $readme, [System.Text.Encoding]::UTF8)

if (Test-Path "ShadowVault_Windows_Portable.zip") {
    Remove-Item -Force "ShadowVault_Windows_Portable.zip"
}
Compress-Archive -Path $dest -DestinationPath "ShadowVault_Windows_Portable.zip" -Force
Copy-Item -Path "ShadowVault_Windows_Portable.zip" -Destination "downloads\ShadowVault_Windows_Portable.zip" -Force

Get-Item "ShadowVault_Windows_Portable.zip", "downloads\ShadowVault_Windows_Portable.zip" | Select-Object FullName, Length, LastWriteTime
