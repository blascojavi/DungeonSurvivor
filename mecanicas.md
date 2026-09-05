# MANUAL DE MECÁNICAS Y FUNCIONAMIENTO: *SHADOW VAULT*

Este documento explica en detalle todas las reglas, sistemas, controles, economía y algoritmos que rigen el funcionamiento del videojuego **Shadow Vault**.

---

## 1. Controles y Ergonomía (Diestro y Zurdo)

### 1.1. Modos de Control Táctil
El juego cuenta con un sistema de **Joystick virtual flotante** que se adapta a las preferencias de agarre del jugador:
- **Modo Diestro (Por defecto):** El joystick táctil se ubica en la esquina **inferior izquierda** de la pantalla (`left: 40, bottom: 40`), permitiendo mover al héroe con el pulgar izquierdo mientras la mano derecha sostiene el dispositivo.
- **Modo Zurdo:** El joystick se traslada a la esquina **inferior derecha** de la pantalla (`right: 40, bottom: 40`), permitiendo el control óptimo con el pulgar derecho.

> **Persistencia:** La preferencia de zurdo/diestro se selecciona directamente en el **Taller de Mejoras** y queda grabada en la base de datos local SQLite del dispositivo, manteniéndose activa en todas las futuras sesiones.

### 1.2. Controles de Teclado (Desktop y Emuladores)
- **W / Flecha Arriba:** Mover hacia arriba.
- **S / Flecha Abajo:** Mover hacia abajo.
- **A / Flecha Izquierda:** Mover hacia la izquierda.
- **D / Flecha Derecha:** Mover hacia la derecha.

---

## 2. Bucle de Combate y Disparo Automático (*Auto-Target*)

Para ofrecer una experiencia ágil y fluida en pantallas táctiles con una sola mano:
1. **Detección Automática:** Cada `0.5 segundos` (o menos, según la cadencia mejorada), el héroe escanea un radio de visión de **450 píxeles**.
2. **Prioridad por Proximidad:** El algoritmo calcula la distancia euclidiana a todos los monstruos vivos en la sala y fija como objetivo al **enemigo más cercano**.
3. **Emisión de Proyectil:** Se dispara un orbe de energía mágica en la dirección normalizada hacia ese objetivo:
   - **Velocidad de bala:** 450 px/s.
   - **Alcance máximo:** 600 px (se destruye si no impacta).
   - **Colisión:** Al impactar con la hitbox de un enemigo, le resta vida, produce un flash visual en el monstruo y el proyectil se disipa.

---

## 3. Bestiario y Sistema de Oleadas

El juego transcurre en una arena cerrada de **1600 x 1600 píxeles** con muros perimetrales luminosos. Los monstruos aparecen alrededor del jugador desde fuera del ángulo de visión:

### 3.1. Tipos de Enemigos y Bestiario
| Monstruo | Vida Base | Velocidad | Daño Contacto | EXP | Probabilidad Oro | Comportamiento Especial |
|---|:---:|:---:|:---:|:---:|:---:|---|
| 🦇 **Murciélago Espectral** | **45 HP** | 100 px/s | 8 | 15 EXP | 25% | Muy rápido, ágil y agresivo. Embiste en bandadas masivas (25-35 simultáneos en Oleada 1). |
| 💀 **Guerrero Esqueleto** | **65 HP** | 65 px/s | 14 | 30 EXP | 50% | Infantería no-muerta equilibrada con ojos dorados (15-25 simultáneos en Oleada 1). |
| 👹 **Bruto Demoníaco** | **160 HP** | 40 px/s | 25 | 80 EXP | 90% | Minijefe tanque pesado, resiste muchos impactos y otorga gran oro (5-9 simultáneos en Oleada 1). |
| 🔮 **Mago Cultista (Oleada 3+)** | **70 HP** | 55 px/s | 12 | 40 EXP | 40% | Guarda distancia media y dispara orbes mágicos oscuros cada 2.5s. |
| 💣 **Duende Bomba (Oleada 3+)** | **55 HP** | 130 px/s | 10 | 25 EXP | 35% | Corre frenéticamente con una bomba y estalla al morir dañando en área. |
| 👑 **Lord Malakor - Señor del Abismo (Jefe)** | **780 HP** | 45 px/s | 30 | 350 EXP | 100% | Colosal demonio acorazado con cuernos ardientes. Lanza ráfagas triples de proyectiles en abanico. ¡A partir de la oleada 15 se duplica en cada aparición (x2)! |

### 3.2. Límites Simultáneos y Progresión por Oleadas
- **Límite Mínimo y Máximo Dinámico (`maxEnemies`):**
  - **Oleada 1:** Diseñada para albergar entre **25 y 35 Murciélagos**, **15 y 25 Esqueletos** y **5 y 9 Brutos** simultáneos. Capacidad total: **70 monstruos** (siempre mayor a 60).
  - **Oleada 2 (+50% simultáneos):** ~45 Murciélagos, ~30 Esqueletos y ~10 Brutos (Capacidad total: **95 monstruos**).
  - **Oleada 3 en adelante:** La composición se enriquece con Magos Cultistas y Duendes Bomba, escalando progresivamente hasta **125 monstruos simultáneos** para no saturar la GPU ni la memoria y garantizar 60/120 FPS fluidos.
- **Multiplicación de Jefes (Lord Malakor x2 desde Oleada 15):**
  - **Oleada 5:** 1 Lord Malakor (780 HP base).
  - **Oleada 10:** 1 Lord Malakor (+dificultad acumulada).
  - **Oleada 15:** ¡Se activa la multiplicación! Aparecen **2 Lord Malakors simultáneos**.
  - **Oleada 20:** Aparecen **4 Lord Malakors simultáneos** (x2).
  - **Oleada 25:** Aparecen **8 Lord Malakors simultáneos** (x2).
  - **Oleada 30:** Aparecen **16 Lord Malakors simultáneos** (x2).
  - El HUD superior muestra el nombre dinámico (*LORD MALAKOR xN - SEÑORES DEL ABISMO*) y promedia su salud total en tiempo real.

---

## 4. Habilidad Definitiva del Héroe (*Ultimate: Nova Arcana*)

1. **Carga por Eliminaciones:** Cada enemigo derrotado suma un punto al contador de la habilidad definitiva (hasta un máximo de **20 bajas**).
2. **Botón Táctil de Activación:**
   - Ubicado dinámicamente en la esquina opuesta al joystick virtual (inferior derecha para diestros, inferior izquierda para zurdos).
   - Mientras carga, muestra un medidor circular con la cuenta regresiva (`X/20`).
   - Al alcanzar las 20 eliminaciones, el botón se ilumina con una animación de pulso cian radiante (`¡NOVA!`).
3. **Efecto de la Habilidad:**
   - Desata una descarga masiva de **18 proyectiles perforantes en 360 grados** (`daño x 2.5`).
   - Genera una **onda de choque de repulsión** que empuja a todos los enemigos cercanos 90 píxeles hacia atrás y les inflige daño masivo de área.
   - Reproduce el efecto sonoro nativo sintetizado `ultimate.wav`.
   - El contador se reinicia a cero tras su uso, requiriendo otras 20 bajas para recargarse.

---

## 5. Cronograma de Oleadas y Aparición de Enemigos

Cada oleada de la mazmorra dura exactamente **45 segundos** de tiempo real:

| Oleada | Tiempo de Partida | Composición y Simultáneos | Desafíos y Jefes |
|---|:---:|---|---|
| **Oleada 1** | `00:00 - 00:45` | 25-35 Murciélagos, 15-25 Esqueletos, 5-9 Brutos | Horda inicial masiva (~57-65 en pantalla, máx 70). Gran flujo de gemas. |
| **Oleada 2** | `00:45 - 01:30` | +50% simultáneos (~45 Murciélagos, ~30 Esqueletos, ~10 Brutos) | Enjambre reforzado (~85 en pantalla, máx 95). |
| **Oleada 3** 🔥 | **`01:30`** | Se incorporan Magos Cultistas y Duendes Bomba | Ataques a distancia y explosiones en área kamikazes. |
| **Oleada 4** | `02:15 - 03:00` | Asedio táctico combinado con cultistas y bombas | Preparación para el primer jefe. |
| **Oleada 5** 👑 | **`03:00`** | **1 Lord Malakor (780 HP)** + Horda de soporte | Rugido, barra de salud superior en el HUD y ráfagas en abanico. |
| **Oleada 10** 💀 | **`06:45`** | **1 Lord Malakor Reforzado** + Horda masiva | Mayor velocidad y daño. |
| **Oleada 15** 👑👑 | **`10:30`** | **2 Lord Malakors simultáneos** | ¡Primer multiplicador de jefes! Barra combinada en el HUD. |
| **Oleada 20** 💀💀 | **`14:15`** | **4 Lord Malakors simultáneos (x2)** | Caos infernal de proyectiles en abanico y festín de gemas gigantes. |
| **Oleada 25** 🔥 | **`18:00`** | **8 Lord Malakors simultáneos (x2)** | Reto titánico extremo. |

---

## 6. El Escenario: La Mazmorra Arcana

- **Arena de Combate:** Área delimitada de **1600 x 1600 píxeles** con losas de piedra milenaria en alta definición (`dungeon_floor.png`).
- **Sello Arcano Sangriento Central:** En el centro exacto de la mazmorra reposa un círculo ceremonial de 440 px (`arcane_blood_circle.png`) con runas incandescentes cian/carmesí, pentagrama oscuro y salpicaduras de sangre ancestral.
- **Rendimiento Cero Coste (GPU Caching):** El mapa y el sello se pre-graban en memoria GPU mediante `ui.PictureRecorder` en [`DungeonMapComponent`](file:///c:/Users/Javi/AndroidStudioProjects/Juego/lib/game/components/dungeon_map_component.dart), consumiendo **0 ms en cada fotograma**.
- **Murallas de Contención:** Paredes de fortaleza perimetral con barreras rúnicas luminosas que delimitan la zona segura.

---

## 7. Botín, Gemas y Magnetismo

Al morir cualquier enemigo, deja caer recursos físicos en el suelo de la mazmorra:

1. **Gemas Verdes (Experiencia):**
   - Siempre caen al derrotar a un enemigo.
   - Otorgan la cantidad de EXP asociada al tipo de monstruo (15 a 100 EXP).
2. **Monedas de Oro (Moneda Permanente):**
   - Tienen probabilidad de caer según el enemigo (25% murciélago, 50% esqueleto, 90% bruto, 100% jefe).
   - Valen 5 de oro cada una.
3. **Física del Imán (*Magnet Radius*):**
   - El jugador posee un radio magnético base de **120 píxeles** (ampliable mediante mejoras).
   - Cuando una gema o moneda entra en este radio, se activa su atracción y acelera suavemente hacia el héroe (`+600 px/s²`) hasta colisionar con su cuerpo y ser recolectada.

---

## 8. Subida de Nivel y Bendiciones (*In-Run Upgrades*)

Al recolectar suficientes gemas de EXP para llenar la barra superior:
1. El motor del juego **se pausa de forma instantánea**.
2. Aparece el modal **Level-Up** con **3 cartas aleatorias** elegidas al azar entre las siguientes 5 bendiciones:

| Carta de Habilidad | Efecto Inmediato |
|---|---|
| 🔥 **Furia Destructiva** | **+25% de Daño** en todos los proyectiles mágicos del héroe. |
| ⚡ **Cadencia Arcana** | **+18% de Velocidad de Ataque** (dispara con mayor frecuencia). |
| 👟 **Zancada Veloz** | **+15% de Velocidad de Movimiento** para esquivar con mayor soltura. |
| 💖 **Bendición Vital** | **+25 de Salud Máxima** y regenera instantáneamente el **50% de la vida**. |
| 🧲 **Vórtice Magnético** | **+40% al Radio del Imán**, permitiendo absorber gemas desde lejos. |

3. Al pulsar una carta, el bonus se aplica en memoria y el bucle de juego se reanuda de inmediato sin tirones.

---

## 9. Economía y Taller de Mejoras Permanentes (*Meta-Progression*)

A diferencia de las bendiciones temporales de la partida, el oro acumulado **se guarda en la base de datos local SQLite** al morir o terminar la expedición:

### 4 Atributos Permanentes Disponibles en el Taller:
1. 💖 **Vitalidad Titánica:** +10% de Salud Máxima por nivel (Nivel máx: 10). Coste base: 100 oro.
2. ⚔️ **Fuerza Arcana:** +8% de Daño infligido por nivel (Nivel máx: 10). Coste base: 150 oro.
3. 👟 **Pies Alados:** +5% de Velocidad de movimiento por nivel (Nivel máx: 10). Coste base: 120 oro.
4. 🧲 **Magnetismo Áureo:** +15% de radio de absorción por nivel (Nivel máx: 10). Coste base: 80 oro.

> **Fórmula de coste escalable:** `Coste = CosteBase * (Nivel == 0 ? 1 : Multiplicador^Nivel)`. A medida que subes el nivel de una mejora, el coste en oro aumenta progresivamente.

---

## 10. Sistema de Audio y Optimización de Rendimiento

1. **Gestión de Memoria con `AudioPool`:**
   - Todos los efectos de sonido (`hit.wav`, `shoot.wav`, `gem.wav`, `levelup.wav`, `ultimate.wav`, `explosion.wav`, `enemy_shoot.wav`, `boss_roar.wav`) utilizan instancias pre-alocadas de `AudioPool` en [`AudioManager`](file:///c:/Users/Javi/AndroidStudioProjects/Juego/lib/core/audio_manager.dart).
   - Esto evita la saturación de descriptores nativos en Android y previene pausas del recolector de basura (*GC pauses*), permitiendo 60/120 FPS estables.
2. **Frecuencias de Muestreo Nativas:** Audio en formato WAV PCM a 22,050 Hz de baja latencia.

---

## 11. Base de Datos Local y Salón de Récords

- **Arquitectura:** SQLite relacional embebido mediante **Drift** (`sqlite3_flutter_libs`), operando en un hilo de fondo dedicado.
- **Rendimiento:** 0 operaciones de I/O en disco durante el combate activo a 60 FPS; todas las transacciones de guardado se ejecutan de manera asíncrona al terminar la partida.
- **Salón de Récords:** Registra las 10 mejores expediciones ordenadas por puntuación, incluyendo oleada alcanzada, enemigos eliminados y oro acumulado.
