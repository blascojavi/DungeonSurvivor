# NOTAS TÉCNICAS: DESARROLLO DE JUEGO MÓVIL (ANDROID E IPHONE)

Documento técnico de análisis, viabilidad, diagnóstico del entorno local y respuestas a los requisitos del proyecto.

---

## 1. Respuestas Directas a tus Preguntas

### ¿Se puede desarrollar el juego completo desde Antigravity?
**SÍ, rotundamente.**
Desde Antigravity podemos:
- Crear la estructura completa del proyecto (Flutter o Kotlin Multiplatform).
- Escribir todo el código fuente: bucle de juego (*game loop*), renderizado de sprites, físicas, controles táctiles, interfaz gráfica (UI/HUD), lógica de colisiones y efectos sonoros.
- Configurar e implementar la base de datos local (Drift/SQLite o Room) sin depender de servicios en la nube.
- Ejecutar comandos de terminal, gestionar paquetes y dependencias, compilar y probar.
- Configurar los scripts de compilación, claves de firmado (*keystores*), optimizadores (R8/Proguard) y manifiestos para ambas plataformas.

---

### ¿Podemos sacar los archivos firmados listos para subir a las Stores?

#### Para Android (Google Play Store): **SÍ, 100% en local desde tu equipo Windows**
- Podemos generar el archivo de claves de producción (`.jks` / `.keystore`) directamente desde la consola con la herramienta `keytool`.
- Configuramos las variables de firmado seguras en `key.properties` y `build.gradle`.
- Generamos el archivo **`.aab` (Android App Bundle)** o **`.apk` de producción** mediante el comando de compilación optimizado (`flutter build appbundle --release`).
- Este archivo `.aab` es el formato oficial y definitivo que se sube directamente a **Google Play Console**.

#### Para iPhone (Apple App Store): **SÍ, pero mediante un flujo adaptado a Windows**
- **Restricción de Apple:** Apple exige obligatoriamente las herramientas nativas de **Xcode**, las cuales solo se ejecutan en un sistema operativo **macOS**, para compilar el binario final de iOS y firmarlo criptográficamente con los certificados de distribución de Apple.
- **¿Cómo lo solucionamos desde Windows con Antigravity sin necesidad de comprar un Mac?**
  1. **Desarrollo 100% en Windows:** Desarrollamos todo el juego aquí. El código de Flutter o KMP se compila igual para ambas plataformas.
  2. **Compilación y firma automática en la Nube (CI/CD Gratuito):** Dejamos configurado un flujo de trabajo de **GitHub Actions** con una máquina virtual `macos-latest` (Apple Silicon en la nube de GitHub) o mediante **Codemagic**.
  3. Al subir un cambio o crear una etiqueta de versión (*tag*), la máquina Mac en la nube compila el proyecto, aplica tus certificados y perfiles de aprovisionamiento de Apple (que se configuran como secretos en el repositorio) y genera el archivo **`.ipa` firmado** o lo envía directamente a **TestFlight / App Store Connect**.
  4. *Opción alternativa:* Si en algún momento tienes acceso a cualquier ordenador Mac (propio, de un amigo o en un servidor), solo tienes que clonar el proyecto y ejecutar `flutter build ipa`.

---

## 2. Diagnóstico del Entorno en tu PC

Hemos analizado las herramientas instaladas en tu sistema Windows (`c:\Users\Javi`):

| Herramienta | Estado | Detalles detectados |
|---|:---:|---|
| **Sistema Operativo** | ✅ Listo | Windows 10 Pro (PowerShell) |
| **Java / JDK** | ✅ Listo | JDK 22 en PATH y **OpenJDK 17 LTS** en `C:\Program Files\Android\Android Studio\jbr` |
| **Android Studio** | ✅ Listo | Instalado en `C:\Program Files\Android\Android Studio` |
| **Android SDK** | ✅ Listo | Instalado en `C:\Users\Javi\AppData\Local\Android\Sdk` (versión 36.0.0) |
| **Android cmdline-tools** | ✅ Listo | Instalado en `Sdk\cmdline-tools\latest` |
| **Licencias Android SDK** | ✅ Listo | Todas las licencias aceptadas |
| **Git** | ✅ Listo | `C:\Program Files\Git\cmd\git.exe` |
| **Flutter SDK** | ✅ Listo | **Flutter 3.47.2 (Canal Stable)** instalado en `C:\Users\Javi\flutter` |
| **Emuladores Android** | ✅ Listo | 5 emuladores disponibles (`pixel_7_-_api_35`, `Medium_Phone_API_34`, etc.) |

> **Conclusión del diagnóstico:** ¡Entorno 100% completado y verificado! Todo está listo para crear el proyecto del juego, compilar en local y lanzar en emuladores o dispositivos físicos.

---

## 3. Elección Tecnológica: Flutter vs Kotlin Multiplatform (KMP)

Para el objetivo específico de **hacer un videojuego 2D/isométrico para Android e iPhone con base de datos local**:

### Comparativa directa

| Criterio | Flutter (Flame Engine) | Kotlin Multiplatform (KMP) |
|---|---|---|
| **Especialización en Juegos** | **Sobresaliente.** El motor **Flame Engine** está maduro y diseñado expresamente para juegos 2D: game loop, componentes ECS, spritesheets, animaciones, partículas, audio y colisiones. | **Complejo.** KMP está diseñado para compartir lógica de negocio y UI de aplicaciones. Para juegos se usan librerías como KorGE o LibGDX modificadas, cuya integración en iOS es más frágil. |
| **Rendimiento Gráfico** | **Excelente.** Utiliza el motor gráfico **Impeller** (Metal en iOS, Vulkan en Android), garantizando 60 o 120 FPS estables sin tirones. | **Variable.** Compose Multiplatform utiliza Skia, pero carece de un ecosistema nativo de videojuegos 2D consolidado. |
| **BBDD en Local (Offline)** | **Excelente.** **Drift** (SQLite relacional tipado y reactivo) o **Isar / Hive** (NoSQL embebidas ultrarrápidas ideales para juegos). | **Muy bueno.** SQLDelight o Room KMP funcionan de forma sólida. |
| **Velocidad de Desarrollo** | **Muy rápida.** Recarga en caliente (*Hot Reload*), ejecución inmediata en Windows Desktop o Web para probar el juego en 1 segundo sin abrir emuladores pesados. | **Media.** Tiempos de compilación de Gradle más largos en cada cambio. |
| **Soporte iOS desde Windows** | Ambos requieren macOS para el binario final, pero Flutter tiene una integración de CI/CD (GitHub Actions / Codemagic) extremadamente probada y documentada. | Similar, aunque la configuración de CocoaPods / SPM en KMP puede ser más intrincada. |

### Recomendación Técnica: **Flutter + Flame Engine + Drift (SQLite)**
- **¿Por qué?** Porque te da un ecosistema de videojuegos real, ligero, con documentación masiva, control total de frames por segundo, manejo de audio impecable y soporte offline garantizado sin depender de servicios externos.

---

## 4. Estrategia de Base de Datos: 100% Local (Sin Firebase ni Nube)

Has especificado explícitamente **no usar Firebase ni ninguna base de datos remota**. Esta es una excelente decisión para un videojuego que prioriza:
1. **Disponibilidad 100% Offline:** El jugador puede jugar en el metro, avión o sin cobertura.
2. **Cero Costes de Mantenimiento:** No hay cuotas mensuales de servidores, Firebase ni AWS.
3. **Latencia Cero:** Las consultas y guardados son instantáneos en la memoria flash del teléfono.
4. **Privacidad Total:** No se requiere consentimiento de cookies ni recolección de datos personales de servidores externos.

### Librerías recomendadas para Flutter:
1. **Drift (SQLite embebido fuertemente tipado):**
   - Utiliza el motor SQLite nativo de Android e iOS.
   - Seguridad tipada en tiempo de compilación.
   - Permite consultas complejas, migraciones de versión seguras si añades nuevas mecánicas en futuras actualizaciones, y almacenamiento de registros históricos, mejoras y configuraciones.
2. **SharedPreferences / HydratedStorage (Para configuraciones ligeras):**
   - Para guardar volumen de sonido, idioma y ajustes gráficos simples.

---

## 5. Requisitos y Costes de las Stores Oficiales

Para publicar en tiendas oficiales cuando el juego esté terminado:

### Google Play Store (Android)
- **Cuenta de Desarrollador:** Pago único de **25 USD** de por vida.
- **Requisito especial (Cuentas personales creadas después de Nov 2023):** Google exige pasar por una fase de *Pruebas Cerradas* con al menos **20 testers durante 14 días** antes de poder habilitar la publicación en producción. Si la cuenta es de tipo Organización/Empresa con D-U-N-S, no aplica este requisito.
- **Formato requerido:** Android App Bundle (`.aab`) firmado con clave RSA de 2048 o 4096 bits.

### Apple App Store (iPhone / iPad)
- **Cuenta de Desarrollador (Apple Developer Program):** **99 USD al año**.
- **Requisitos:** Necesitas un Apple ID con autenticación de doble factor, D-U-N-S si es empresa o datos fiscales personales.
- **Formato requerido:** Archivo `.ipa` firmado con certificado de Distribución de Apple y perfil de aprovisionamiento de App Store.
- **Revisión:** Apple tiene un proceso de revisión manual riguroso (guías de diseño, no cierres inesperados, soporte para diferentes tamaños de pantalla, respeto de la zona segura / notch / Dynamic Island).

---

## 6. Siguientes Archivos Generados

De acuerdo a tus instrucciones, se han generado también:
1. [pasos.md](file:///c:/Users/Javi/AndroidStudioProjects/Juego/pasos.md): La hoja de ruta paso a paso desde cero (instalación de herramientas, código, BBDD, hasta la compilación y firma para ambas tiendas).
2. [juego.md](file:///c:/Users/Javi/AndroidStudioProjects/Juego/juego.md): El documento de diseño completo del juego (GDD), mecánicas, arquitectura del código, esquema de la base de datos local y sistema de guardado seguro.
