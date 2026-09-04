# PASOS PARA GENERAR EL JUEGO MÓVIL DESDE CERO HASTA LA PUBLICACIÓN

Esta guía detalla todo el proceso paso a paso para construir, probar, empaquetar y firmar el videojuego para **Android** e **iOS** utilizando **Flutter** y una **base de datos 100% local**.

---

## ÍNDICE DE FASES
1. [Fase 1: Preparación del Entorno Local en Windows](#fase-1-preparación-del-entorno-local-en-windows)
2. [Fase 2: Creación e Inicialización del Proyecto](#fase-2-creación-e-inicialización-del-proyecto)
3. [Fase 3: Configuración de Dependencias y Motor](#fase-3-configuración-de-dependencias-y-motor)
4. [Fase 4: Implementación de la Base de Datos Local](#fase-4-implementación-de-la-base-de-datos-local)
5. [Fase 5: Desarrollo de la Lógica y Mecánicas del Juego](#fase-5-desarrollo-de-la-lógica-y-mecánicas-del-juego)
6. [Fase 6: Integración de Assets, UI Adaptativa y Audio](#fase-6-integración-de-assets-ui-adaptativa-y-audio)
7. [Fase 7: Pruebas y Depuración](#fase-7-pruebas-y-depuración)
8. [Fase 8: Generación y Firma para Android (Google Play)](#fase-8-generación-y-firma-para-android-google-play)
9. [Fase 9: Generación y Firma para iOS (App Store) desde Windows](#fase-9-generación-y-firma-para-ios-app-store-desde-windows)
10. [Fase 10: Publicación en las Tiendas](#fase-10-publicación-en-las-tiendas)

---

## FASE 1: Preparación del Entorno Local en Windows

Como tu PC ya cuenta con Android Studio, Android SDK, JDK y Git, solo necesitamos añadir Flutter:

### 1.1. Instalar Flutter SDK
Abre una terminal de PowerShell y ejecuta:
```powershell
winget install Google.Flutter
```
*(O de forma alternativa: clonar en `C:\flutter` desde Git con `git clone https://github.com/flutter/flutter.git -b stable C:\flutter` y añadir `C:\flutter\bin` al PATH de Windows).*

### 1.2. Validar el entorno
Cierra y vuelve a abrir la terminal y comprueba:
```powershell
flutter doctor
```

### 1.3. Aceptar licencias de Android SDK
Si el doctor indica que faltan licencias por aceptar:
```powershell
flutter doctor --android-licenses
```
*(Acepta con `y` a todas las preguntas).*

---

## FASE 2: Creación e Inicialización del Proyecto

### 2.1. Crear el proyecto Flutter
Desde el directorio de trabajo:
```powershell
flutter create --org com.juego.javi --platforms=android,ios,windows .
```
- `--org com.juego.javi`: Define tu paquete único (Bundle ID para iOS y ApplicationId para Android).
- `--platforms=android,ios,windows`: Incluye soporte para Windows de modo que podamos ejecutar y probar el juego al instante en el escritorio sin emuladores.

---

## FASE 3: Configuración de Dependencias y Motor

Configuramos `pubspec.yaml` con las librerías óptimas para el juego y la persistencia local:

```yaml
dependencies:
  flutter:
    sdk: flutter
  # Motor de juego 2D y audio
  flame: ^1.18.0
  flame_audio: ^2.1.6
  
  # Base de datos local (SQLite tipado de alto rendimiento)
  drift: ^2.18.0
  sqlite3_flutter_libs: ^0.5.24
  path_provider: ^2.1.3
  path: ^1.9.0
  
  # Gestión de estado y utilidades
  flutter_bloc: ^8.1.6 # o provider/riverpod
  google_fonts: ^6.2.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  drift_dev: ^2.18.0
  build_runner: ^2.4.9
```

Instalar los paquetes:
```powershell
flutter pub get
```

---

## FASE 4: Implementación de la Base de Datos Local

### 4.1. Definición del Esquema (Drift / SQLite)
Creamos `lib/data/database/app_database.dart`:
- Tablas para:
  - `PlayerProfile`: Monedas, gemas, nivel general, fecha de inicio.
  - `Upgrades`: Identificador de mejora, nivel actual, coste.
  - `GameRecords`: Puntuaciones máximas, tiempo de supervivencia, oleada alcanzada.
  - `Settings`: Volumen de música, volumen de efectos, vibración activada.
  - `ActiveGameSession`: Guardado temporal por si el jugador sale de la app a mitad de una partida.

### 4.2. Generar el código de Drift
```powershell
dart run build_runner build --delete-conflicting-outputs
```

### 4.3. Implementar el Repositorio de Guardado
- Crear funciones seguras y no bloqueantes:
  - `saveGameSession()`
  - `loadGameSession()`
  - `updatePlayerCurrency()`
  - `recordHighscore()`

---

## FASE 5: Desarrollo de la Lógica y Mecánicas del Juego

### 5.1. Estructura modular del código
```
lib/
├── core/                  # Constantes, temas, utilidades
├── data/
│   ├── database/          # Drift SQLite, DAOs, migraciones
│   └── repositories/      # Repositorio local de partidas y ajustes
├── game/
│   ├── components/        # Jugador, Enemigos, Proyectiles, Coleccionables
│   ├── managers/          # Generador de oleadas, colisiones, puntuación
│   ├── overlays/          # HUD de vida, barra de exp, pausa, game over
│   └── main_game.dart     # Clase principal heredera de FlameGame
└── main.dart              # Punto de entrada de Flutter
```

### 5.2. Componentes principales del motor Flame
1. **`MainGame`**: Configura la cámara, el sistema de coordenadas lógicas y el bucle principal.
2. **`PlayerComponent`**: Maneja la posición, vida, animaciones por spritesheet e interacción con el joystick táctil.
3. **`EnemyManager`**: Instancia enemigos gradualmente según el tiempo de supervivencia.
4. **`CollisionCallbacks`**: Gestiona el impacto de proyectiles contra enemigos y del jugador con los objetos.

---

## FASE 6: Integración de Assets, UI Adaptativa y Audio

### 6.1. Organización de Assets
```
assets/
├── audio/
│   ├── sfx/               # Golpes, recolección de gemas, salto, derrota (.wav / .ogg)
│   └── bgm/               # Música de fondo en bucle (.ogg / .m4a)
├── images/
│   ├── player/            # Spritesheet de animaciones
│   ├── enemies/           # Spritesheet de enemigos
│   └── tiles/             # Suelo y entorno
└── fonts/                 # Tipografía arcade/retro
```

### 6.2. Adaptabilidad de pantalla
- Configuración de `FixedResolutionViewport` o `CameraComponent` en Flame para que el juego se vea idéntico en pantallas 16:9, 19.5:9, 20:9 y pantallas de iPad/tablets.
- Integración de `SafeArea` en los overlays de Flutter para esquivar la cámara perforada, el notch y la *Dynamic Island* de Apple.

---

## FASE 7: Pruebas y Depuración

### 7.1. Pruebas ultra-rápidas en Windows Desktop
Durante el desarrollo diario, ejecuta:
```powershell
flutter run -d windows
```
*Permite recarga en caliente en menos de 1 segundo sin necesidad de emulador.*

### 7.2. Pruebas en Android
Con tu móvil Android conectado por USB (con depuración USB activada) o un emulador de Android Studio:
```powershell
flutter run -d android
```

---

## FASE 8: Generación y Firma para Android (Google Play)

### 8.1. Generar la clave de producción (Keystore)
Ejecutamos en PowerShell:
```powershell
keytool -genkey -v -keystore c:\Users\Javi\upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```
*(Guarda la contraseña elegida en un lugar seguro).*

### 8.2. Configurar `android/key.properties`
Crea el archivo `android/key.properties` (este archivo **nunca** se sube a repositorios públicos):
```properties
storePassword=TU_CONTRASEÑA
keyPassword=TU_CONTRASEÑA
keyAlias=upload
storeFile=C:/Users/Javi/upload-keystore.jks
```

### 8.3. Configurar `android/app/build.gradle`
En la sección `signingConfigs`:
```groovy
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile file(keystoreProperties['storeFile'])
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

### 8.4. Compilar el archivo para la tienda
Ejecuta:
```powershell
flutter build appbundle --release
```
- **Resultado:** Se generará el archivo `build/app/outputs/bundle/release/app-release.aab`.
- Este archivo está **100% firmado y optimizado**, listo para ser subido directamente a Google Play Console.

---

## FASE 9: Generación y Firma para iOS (App Store) desde Windows

Dado que Windows no ejecuta Xcode directamente, utilizaremos el flujo estándar en la industria: **GitHub Actions** con una máquina virtual `macos-latest` gratuita.

### 9.1. Configurar Identificadores en Apple Developer
1. Entra en [developer.apple.com](https://developer.apple.com).
2. Crea un **App ID** (ej: `com.juego.javi`).
3. Genera un **Certificado de Distribución** (iOS Distribution Certificate) y exporta el archivo `.p12`.
4. Crea un **Provisioning Profile** de tipo *App Store Distribution*.

### 9.2. Subir Secretos a tu repositorio GitHub
En la configuración de tu repositorio (`Settings > Secrets and variables > Actions`), añade:
- `APP_STORE_CONNECT_API_KEY` (o tu certificado `.p12` en base64).
- `CERTIFICATE_PASSWORD`.
- `PROVISIONING_PROFILE_BASE64`.

### 9.3. Crear el Workflow Automatizado de Compilación
Creamos el archivo `.github/workflows/build_ios.yml`:
```yaml
name: Build & Sign iOS IPA

on:
  push:
    tags:
      - 'v*' # Se ejecuta al crear una etiqueta de versión como v1.0.0
  workflow_dispatch: # O manualmente desde la web de GitHub

jobs:
  build:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Instalar Java
        uses: actions/setup-java@v3
        with:
          distribution: 'zulu'
          java-version: '17'

      - name: Instalar Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: 'stable'

      - name: Instalar Certificados de Apple
        run: |
          # Importa el certificado .p12 y el Provisioning Profile en el llavero de macOS
          ...
          
      - name: Instalar dependencias
        run: flutter pub get

      - name: Compilar IPA firmado
        run: flutter build ipa --release --export-options-plist=ios/ExportOptions.plist

      - name: Subir artefacto IPA
        uses: actions/upload-artifact@v4
        with:
          name: app-release-signed-ipa
          path: build/ios/ipa/*.ipa
```
- **Resultado:** Con solo hacer `git push`, GitHub Actions enciende un Mac, compila el código, lo firma y te deja el archivo `.ipa` listo para descargar o subir a TestFlight.

---

## FASE 10: Publicación en las Tiendas

### Checklist para Google Play Console
1. Crear la aplicación en la consola.
2. Completar la Ficha de la tienda: Título, descripción corta (80 caracteres), descripción completa (4000 caracteres), icono de 512x512, gráfico de funciones de 1024x500 y capturas de pantalla de móvil y tablet.
3. Subir el archivo `app-release.aab`.
4. Rellenar la declaración de seguridad de los datos (indicar que **no se recopilan datos en servidores externos**, ya que todo es local).
5. Completar cuestionario de clasificación de contenido (IARC).
6. Si es cuenta personal nueva: Completar la fase de 20 testers por 14 días y solicitar acceso a producción.

### Checklist para Apple App Store Connect
1. Dar de alta la app con su SKU y Bundle ID.
2. Subir capturas requeridas para pantallas de 6.7" (iPhone 15 Pro Max) y 6.5" / 5.5".
3. Subir el archivo `.ipa` mediante TestFlight (directo desde GitHub Actions o con la app Transporter).
4. Rellenar información de privacidad (indicar "Data Not Collected").
5. Enviar a revisión de Apple.
