# Guía Paso a Paso: Conectar Firebase a BetFlix

## 📱 Tu Configuración Firebase

```
Proyecto: betflix
Project ID: betflix-955fc
Sender ID: 279904923799
Package Android: betflix.com
```

---

## 🚀 PASO 1: Descargar `google-services.json`

### Desde Firebase Console en el navegador:

1. **Abre Firebase Console**: https://console.firebase.google.com/
2. **Selecciona proyecto**: `betflix-955fc`
3. **Ve a**: Proyecto > (icono ⚙️ Configuración del Proyecto) > `Apps for Android`
4. **Busca**: La app "BetFlix"
5. **Haz clic en el ⚙️** junto a BetFlix
6. **Descarga**: `google-services.json`

![Ubicación del botón descargar](https://imgur.com/placeholder.png)

---

## 📂 PASO 2: Colocar el archivo en el proyecto

### Ruta exacta donde debe ir el archivo:

```
Tu_Proyecto/
├── android/
│   ├── app/
│   │   └── google-services.json  ⬅️ COLOCAR AQUÍ
│   ├── build.gradle.kts
│   └── ...
├── ios/
├── lib/
└── pubspec.yaml
```

**Ruta completa**: `d:\Aaron\Projecte final\android\app\google-services.json`

### Pasos:
1. Descarga el archivo `google-services.json`
2. Abre la carpeta `android/app/` en tu proyecto
3. **Pega** el archivo aquí

---

## ✅ PASO 3: Verificar configuración de Android

### Archivo: `android/app/build.gradle.kts`

Verifica que contenga estas líneas:

```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")  ⬅️ DEBE ESTAR
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.betflix"
    
    defaultConfig {
        applicationId = "betflix.com"  ⬅️ DEBE COINCIDIR CON FIREBASE
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
}
```

**✅ YA ESTÁ ACTUALIZADO** en tu proyecto.

---

## 🔧 PASO 4: Limpiar y sincronizar

Abre una terminal en VS Code y ejecuta:

```bash
flutter clean
flutter pub get
```

Esto descargará y sincronizará todas las dependencias con el nuevo archivo de configuración.

---

## ▶️ PASO 5: Ejecutar la app

```bash
flutter run
```

### Si ves:
- ✅ **La app inicia sin errores** → Firebase está conectado
- ❌ **Error de Firebase** → Revisa que `google-services.json` esté en la carpeta correcta

---

## 🔑 Después: Configuración Necesaria en Firebase Console

Una vez que la app se conecte, debes habilitar:

### 1. **Authentication**
```
Firebase Console → Authentication → Providers
✅ Habilitar: Email/Password
```

### 2. **Firestore Database**
```
Firebase Console → Firestore Database
✅ Crear una nueva base de datos
✅ Modo: Test (para desarrollo)
```

### 3. **Security Rules**
```
Firestore → Rules
```

Aquí te paso las reglas para desarrollo (NOTA: ⚠️ NO usar en PRODUCCIÓN):

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Para desarrollo - permite todo
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

---

## 📋 Checklist de Configuración

- [ ] Descargué el `google-services.json`
- [ ] Lo coloqué en `android/app/`
- [ ] Verifiqué que `build.gradle.kts` tiene `id("com.google.gms.google-services")`
- [ ] Ejecuté `flutter clean && flutter pub get`
- [ ] Ejecuté `flutter run` sin errores
- [ ] Habilité **Authentication** en Firebase
- [ ] Creé **Firestore Database** en Firebase
- [ ] Configuré las **Security Rules**

---

## 🆘 Solución de problemas

### Error: "Plugin with id 'com.google.gms.google-services' not found"
→ El plugin NO está en `build.gradle.kts`
→ Solución: Asegúrate de que está en `android/build.gradle.kts` y `android/app/build.gradle.kts`

### Error: "google-services.json not found"
→ El archivo no está en `android/app/`
→ Solución: Coloca el archivo exactamente en esa ruta

### Error: "Package name mismatch"
→ El `applicationId` en Firebase no coincide con `build.gradle.kts`
→ Solución: Asegúrate que `applicationId = "betflix.com"` en `android/app/build.gradle.kts`

---

## 📞 ¿Necesitas ayuda?

Si después de descargar el archivo `google-services.json` tienes problemas, comparte:
- El error exacto que ves
- El contenido de las primeras líneas del `google-services.json` (sin keys sensibles)

**¡Estoy aquí para ayudarte!** 🚀
