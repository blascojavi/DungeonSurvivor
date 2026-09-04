# ⚔️ SHADOW VAULT

[![Flutter](https://img.shields.io/badge/Flutter-3.47.2-02569B?logo=flutter)](https://flutter.dev)
[![Flame Engine](https://img.shields.io/badge/Flame_Engine-2D_Roguelite-FF6F00)](https://flame-engine.org)
[![SQLite](https://img.shields.io/badge/Database-SQLite_(Drift)-003B57?logo=sqlite)](https://drift.simonbinder.eu/)
[![Platform](https://img.shields.io/badge/Platforms-Android%20%7C%20iOS%20%7C%20Windows-brightgreen)](#)
[![License](https://img.shields.io/badge/Status-100%25_Offline-blue)](#)

> **Videojuego Roguelite de Supervivencia 2D para móviles**, construido con **Flutter**, **Flame Engine** y **SQLite local (Drift)**. 
> Diseñado para partidas trepidantes de 3 a 10 minutos a **60/120 FPS** con controles ergonómicos adaptables para diestros y zurdos.

---

## 🎮 Características Principales

* ⚡ **Combate Ágil y Fluido:** Auto-apuntado inteligente al enemigo más cercano dentro de 450 px con cadencia y daño mejorables.
* 💥 **Habilidad Definitiva (*Nova Arcana*):** Acumula 20 eliminaciones para recargar un botón táctil pulsante en el HUD. Al activarlo, libera 18 proyectiles perforantes en 360° y una onda expansiva de repulsión masiva.
* 👹 **Bestiario Variado y Jefes Colosales:**
  * 🦇 *Murciélagos Espectrales* (rápidos en manada).
  * 💀 *Guerreros Esqueleto* (equilibrados con ojos de oro).
  * 👹 *Brutos Demoníacos* (tanques resistentes).
  * 🔮 *Magos Cultistas* (Oleada 3+, proyectiles a distancia).
  * 💣 *Duendes Bomba* (Oleada 3+, suicidas con explosión de área).
  * 👑 *Lord Malakor - Señor del Abismo* (Oleadas 5 y 10, barra de vida en HUD y ráfagas triples).
* 🏰 **Mazmorra Rúnica:** Arena de 1600x1600 px con baldosas de piedra milenaria y un sello rúnico ceremonial con sangre pre-renderizado en GPU (0 ms overhead).
* 🧲 **Absorción Magnética:** Gemas de experiencia y monedas de oro con física de aceleración atractiva hacia el héroe.
* 🛡️ **Meta-Progresión (Taller):** Gasta el oro acumulado en mejoras permanentes de Salud Titánica, Fuerza Arcana, Velocidad y Rango de Imán.
* 🤚 **Ergonomía Completa:** Selección en cualquier momento de **Modo Diestro** (joystick a la izquierda, definitiva a la derecha) o **Modo Zurdo** (joystick a la derecha, definitiva a la izquierda).
* 💾 **100% Offline y Seguro:** Base de datos relacional SQLite embebida con **Drift**, sin dependencia de servidores, sin costes de nube y con cero lag.

---

## ⏱️ Cronograma de Oleadas

| Oleada | Tiempo | Monstruos y Desafíos |
|:---:|:---:|---|
| **Oleada 1** | `00:00 - 00:45` | Murciélagos espectrales y Esqueletos iniciales. |
| **Oleada 2** | `00:45 - 01:30` | Primeros Brutos Demoníacos y mayor densidad. |
| **Oleada 3** 🔥 | **`01:30`** | **Desbloqueo de Magos Cultistas (distancia) y Duendes Bomba (explosión).** |
| **Oleada 4** | `02:15 - 03:00` | Asedio táctico combinado. |
| **Oleada 5** 👑 | **`03:00`** | **Aparición de Lord Malakor (Jefe con barra superior de salud).** |
| **Oleada 10** 💀 | **`06:45`** | **Lord Malakor Enfurecido (+50% vida y velocidad).** |

---

## 📂 Documentación del Proyecto

| Documento | Descripción |
|---|---|
| 📖 [mecanicas.md](mecanicas.md) | Manual completo de combate, fórmulas matemáticas, bestiario, oleadas y bendiciones. |
| 🏗️ [juego.md](juego.md) | Documento de Diseño del Juego (GDD), bucles de juego, arquitectura y esquema de tablas SQLite. |
| 🛠️ [notas.md](notas.md) | Diagnóstico del entorno, comparativa tecnológica y notas de optimización a 120 FPS. |
| 🚀 [pasos.md](pasos.md) | Hoja de ruta completa: desde la preparación hasta la firma y publicación en Google Play y App Store. |
| 🌐 [index.html](index.html) | Landing page web moderna lista para hospedar en GitHub Pages. |

---

## 🚀 Cómo Ejecutar y Probar

### 1. Pruebas Rápidas en Windows Desktop
```powershell
flutter run -d windows
```
*Disfruta de recarga en caliente en menos de 1 segundo.*

### 2. Probar en Móvil Android o Emulador
```powershell
flutter run -d android
```

### 3. Compilar APK de Depuración
```powershell
flutter build apk --debug
```
*Ubicación del binario:* `build/app/outputs/flutter-apk/app-debug.apk`

### 4. Compilar Bundle de Producción para Google Play
```powershell
flutter build appbundle --release
```
*Ubicación del binario:* `build/app/outputs/bundle/release/app-release.aab`

---

## 🕹️ Controles

* **Móvil:** Joystick táctil virtual dinámico con el pulgar + botón de Habilidad Definitiva (*Nova Arcana*).
* **Teclado (Desktop/Emulador):** `W`, `A`, `S`, `D` o flechas de dirección para moverse.

---

© 2026 Shadow Vault. Desarrollado con Flutter y Flame Engine.
