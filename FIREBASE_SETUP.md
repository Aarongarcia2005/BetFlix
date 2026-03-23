# Configuración de Firebase en BetFlix

## ℹ️ Información del Proyecto Firebase
- **Nombre del proyecto**: betflix
- **ID del proyecto**: betflix-955fc
- **Número del proyecto (Sender ID)**: 279904923799
- **App Android**: BetFlix
- **ID App Android**: 1:279904923799:android:c2a338013ea4457934f9d2
- **Package Name**: betflix.com

---

## 📋 Pasos para Configurar Firebase

### 1️⃣ Descargar archivo `google-services.json`
1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona el proyecto **betflix-955fc**
3. En la sección **Apps for Android**, busca la app **BetFlix**
4. Haz clic en el **⚙️ (icono de configuración)** junto a la app
5. En la pestaña **General**, descarga el archivo **google-services.json**

### 2️⃣ Colocar el archivo en el proyecto
1. Descarga el archivo `google-services.json`
2. Colócalo en: `android/app/`
3. La ruta correcta debe ser: `android/app/google-services.json`

### 3️⃣ Configurar `build.gradle` en el proyecto

**Archivo**: `android/build.gradle.kts`

Asegúrate que tenga la dependencia de Google Services:

```kotlin
plugins {
    id("com.google.gms.google-services") version "4.4.0" apply false
}
```

### 4️⃣ Configurar `build.gradle` en la app

**Archivo**: `android/app/build.gradle.kts`

Asegúrate que tenga:

```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services") // ⬅️ AGREGAR ESTA LÍNEA
}
```

### 5️⃣ Obtener y configurar las API Keys

Desde Firebase Console → Proyecto **betflix-955fc** → **SDK Configuration**:

Las keys que necesitas están en el archivo `google-services.json` que descargues. 

**Los datos que vemos en las capturas ya están correctos:**
- Project ID: `betflix-955fc`
- Sender ID: `279904923799`
- Android App ID: `1:279904923799:android:c2a338013ea4457934f9d2`

---

## 📝 Archivo de configuración Firebase en Flutter

**El archivo `lib/firebase_options.dart` ya está cargado** con los datos del proyecto.

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'OBTENER_DE_google-services.json',
  appId: '1:279904923799:android:c2a338013ea4457934f9d2',
  messagingSenderId: '279904923799',
  projectId: 'betflix-955fc',
  databaseURL: 'https://betflix-955fc.firebaseio.com',
  storageBucket: 'betflix-955fc.appspot.com',
);
```

> **Nota**: La `apiKey` será generada automáticamente por Google Services cuando coloques el `google-services.json`.

---

## 🔗 Verificar la Conexión

Una vez configurado todo, ejecuta:

```bash
flutter clean
flutter pub get
flutter run
```

Si ves que la app inicia sin errores de Firebase → ¡Está conectado! ✅

---

## 🔑 Resumen de archivos necesarios

| Archivo | Ubicación | Acción |
|---------|-----------|--------|
| `google-services.json` | `android/app/` | ⬇️ Descargar de Firebase |
| `build.gradle.kts` | `android/` | ✔️ Ya debe tener el plugin |
| `build.gradle.kts` | `android/app/` | ✔️ Se agregó el plugin |
| `firebase_options.dart` | `lib/` | ✔️ Ya está configurado |

---

## ✨ Próximos pasos

Una vez Firebase esté conectado:
1. ✅ Authentication → Habilitar Email/Password
2. ✅ Firestore Database → Crear base de datos
3. ✅ Security Rules → Configurar permisos

**¿Necesitas ayuda con estos pasos?** 🚀
