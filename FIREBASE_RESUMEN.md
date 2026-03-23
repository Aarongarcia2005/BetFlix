# 🔥 Firebase Setup - Resumen Ejecutivo

## 📊 Tu Configuración Firebase (de las capturas)

| Propiedad | Valor |
|-----------|-------|
| **Nombre Proyecto** | betflix |
| **Project ID** | `betflix-955fc` |
| **Número Proyecto** | `279904923799` |
| **App Android** | BetFlix |
| **App ID Android** | `1:279904923799:android:c2a338013ea4457934f9d2` |
| **Package Name** | `betflix.com` |
| **Database** | `https://betflix-955fc.firebaseio.com` |
| **Storage** | `betflix-955fc.appspot.com` |

---

## ✅ Cambios Realizados en tu Proyecto

### 1. `android/build.gradle.kts` ✔️
```diff
+ plugins {
+     id("com.google.gms.google-services") version "4.4.0" apply false
+ }

  allprojects {
      repositories {
          google()
          mavenCentral()
      }
  }
```

### 2. `android/app/build.gradle.kts` ✔️
```diff
  plugins {
      id("com.android.application")
      id("kotlin-android")
+     id("com.google.gms.google-services")
      id("dev.flutter.flutter-gradle-plugin")
  }

  defaultConfig {
-     applicationId = "com.example.betflix"
+     applicationId = "betflix.com"
  }
```

### 3. `lib/firebase_options.dart` ✔️
```dart
/// Ahora apunta a Android como default
static FirebaseOptions get currentPlatform {
    return android;  // ← UPDATED
}
```

---

## 🎬 ACCIONES QUE DEBES HACER TÚ

### PASO 1️⃣: Descargar `google-services.json`

1. Abre: https://console.firebase.google.com/
2. Proyecto: **betflix-955fc**
3. Configuración Proyecto (⚙️) → Apps for Android
4. BetFlix → ⚙️ → **Descargar** `google-services.json`

### PASO 2️⃣: Copiar archivo al proyecto

```
Descargar: google-services.json
Copiar a: d:\Aaron\Projecte final\android\app\google-services.json
```

**Estructura final:**
```
android/
├── app/
│   ├── google-services.json  ← COLOCAR AQUÍ
│   ├── build.gradle.kts
│   └── ...
```

### PASO 3️⃣: Sincronizar en VS Code

```bash
cd "d:\Aaron\Projecte final"
flutter clean
flutter pub get
```

### PASO 4️⃣: Ejecutar la app

```bash
flutter run
```

---

## 📱 Resultado esperado

✅ **Sin errores de Firebase** → ¡Conectado correctamente!

```
I/flutter ( 1234): Firebase initialized
I/DartVM ( 1234): Dart VM started successfully
```

---

## 🔐 Después: Habilitar en Firebase Console

### Authentication
```
Firebase → Authentication → Sign-in method
✅ Email/Password
```

### Firestore
```
Firebase → Firestore Database → Crear DB
✅ Modo: Test (desarrollo)
```

### Security Rules
```
Firestore → Rules
```

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;  // 🚨 Solo para desarrollo
    }
  }
}
```

---

## 📂 Archivos Clave Actualizados

| Archivo | Cambio | Estado |
|---------|--------|--------|
| `android/build.gradle.kts` | Agregó plugin google-services | ✅ Listo |
| `android/app/build.gradle.kts` | Agregó plugin + cambió applicationId | ✅ Listo |
| `lib/firebase_options.dart` | Ahora usa Android como default | ✅ Listo |
| `android/app/google-services.json` | **TÚ DEBES DESCARGAR** | ⏳ Pendiente |

---

## ❓ Verificar que todo está bien

Abre VS Code y revisa:

1. **¿Existe el archivo?**
   ```
   android/app/google-services.json
   ```

2. **¿Contiene datos de Firebase?**
   ```json
   {
     "project_info": {
       "project_id": "betflix-955fc",
       ...
     }
   }
   ```

3. **¿Se ejecuta sin errores?**
   ```bash
   flutter run
   ```

---

## 🚀 El flujo resumido

```
1. Descargas google-services.json desde Firebase Console
   ↓
2. Lo colocas en android/app/
   ↓
3. Ejecutas: flutter clean && flutter pub get
   ↓
4. Ejecutas: flutter run
   ↓
5. ✅ Firebase conectado
   ↓
6. Habilitas Authentication & Firestore en Firebase Console
   ↓
7. ¡Listo para usar!
```

---

## 🆘 Si algo falla

### "Plugin not found"
→ Verifica que `android/build.gradle.kts` tenga el plugin

### "google-services.json not found"
→ Asegúrate que esté en `android/app/` (no en `android/`)

### "Package mismatch"
→ Verifica que Firebase esté registrado con `betflix.com`

---

**¿Listo para el siguiente paso?** Avísame cuando descargues el archivo y haya funcionado 🎉
