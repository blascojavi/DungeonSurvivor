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

### 3.1. Tipos de Enemigos
| Monstruo | Vida Base | Velocidad | Daño Contacto | EXP | Probabilidad Oro | Comportamiento |
|---|:---:|:---:|:---:|:---:|:---:|---|
| 🦇 **Murciélago Espectral** | 20 HP | 95 px/s | 8 | 15 EXP | 25% | Muy rápido, ágil y de baja salud. Embiste en bandada. |
| 💀 **Guerrero Esqueleto** | 45 HP | 65 px/s | 14 | 30 EXP | 50% | Enemigo estándar equilibrado con ojos dorados. |
| 👹 **Bruto Demoníaco** | 120 HP | 40 px/s | 25 | 80 EXP | 90% | Minijefe pesado, resiste muchos impactos y hace gran daño. |

### 3.2. Progresión Temporal de Dificultad (Oleadas)
- Cada **45 segundos** de supervivencia, el nivel de oleada aumenta (`Oleada = (Tiempo / 45) + 1`).
- **Escalado de salud y daño de los enemigos:** `Multiplicador = 1.0 + (Oleada - 1) * 0.25` (+25% por oleada).
- **Frecuencia de generación:** El intervalo entre apariciones de monstruos se reduce gradualmente desde **2.0 segundos** hasta un límite frenético de **0.4 segundos**.

---

## 4. Botín, Gemas y Magnetismo

Al morir cualquier enemigo, no solo desaparece de pantalla sino que deja caer recursos físicos en el suelo de la mazmorra:

1. **Gemas Verdes (Experiencia):**
   - Siempre caen al derrotar a un enemigo.
   - Otorgan la cantidad de EXP asociada al tipo de monstruo.
2. **Monedas de Oro (Moneda Permanente):**
   - Tienen probabilidad de caer según el enemigo (25% murciélago, 50% esqueleto, 90% bruto).
   - Valen 5 de oro cada una.
3. **Física del Imán (*Magnet Radius*):**
   - El jugador posee un radio magnético base de **120 píxeles** (ampliable mediante mejoras).
   - Cuando una gema o moneda entra en este radio, se activa su atracción y acelera suavemente hacia el héroe (`+600 px/s²`) hasta colisionar con su cuerpo y ser recolectada.

---

## 5. Subida de Nivel y Bendiciones (*In-Run Upgrades*)

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

## 6. Economía y Taller de Mejoras Permanentes (*Meta-Progression*)

A diferencia de las bendiciones temporales de la partida, el oro acumulado **se guarda en la base de datos local SQLite** al morir o terminar la expedición:

### 4 Atributos Permanentes Disponibles en el Taller:
1. 💖 **Vitalidad Titánica:** +10% de Salud Máxima por nivel (Nivel máx: 10). Coste base: 100 oro.
2. ⚔️ **Fuerza Arcana:** +8% de Daño infligido por nivel (Nivel máx: 10). Coste base: 150 oro.
3. 👟 **Pies Alados:** +5% de Velocidad de movimiento por nivel (Nivel máx: 10). Coste base: 120 oro.
4. 🧲 **Magnetismo Áureo:** +15% de radio de absorción por nivel (Nivel máx: 10). Coste base: 80 oro.

> **Fórmula de coste escalable:** `Coste = CosteBase * (Nivel == 0 ? 1 : Multiplicador^Nivel)`. A medida que subes el nivel de una mejora, el coste en oro aumenta progresivamente.

---

## 7. Base de Datos Local y Salón de Récords

- **Arquitectura:** SQLite relacional embebido mediante **Drift** (`sqlite3_flutter_libs`), operando en un hilo de fondo dedicado.
- **Rendimiento:** 0 operaciones de I/O en disco durante el combate activo a 60 FPS; todas las transacciones de guardado se ejecutan de manera asíncrona al terminar la partida.
- **Salón de Récords:** Ordena las 10 mejores expediciones registradas según la puntuación obtenida, registrando también el tiempo sobrevivido, el total de monstruos eliminados y el oro saqueado.
