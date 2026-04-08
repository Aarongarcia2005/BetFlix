# Firebase Fix Rapido (Permisos e Indices)

Si aparece `permission-denied` o no cargan partidos/apuestas, sigue este orden:

## 1) Activar proveedores de Auth
En Firebase Console -> Authentication -> Sign-in method:
- Email/Password: ON
- Anonymous: ON (necesario para usuarios demo)

## 2) Publicar reglas e indices
Este repo ya incluye:
- `firestore.rules`
- `firestore.indexes.json`
- `firebase.json`

Comandos (en la raiz del proyecto):

```bash
firebase login
firebase use <tu-project-id>
firebase deploy --only firestore:rules
firebase deploy --only firestore:indexes
```

## 3) Re-login en la app
- Cierra sesion en la app
- Inicia sesion de nuevo (demo o email/password)
- Vuelve a crear partido y apostar

## 4) Si sigue fallando
Revisa en consola de Firebase:
- Firestore -> Rules
- Firestore -> Indexes (que esten `Enabled`)
- Authentication -> Users (que exista un usuario autenticado)

## 5) Mensajes tipicos
- `permission-denied`: reglas bloqueando o usuario sin auth
- `failed-precondition`: falta indice compuesto
- `unavailable`: sin conexion o Firebase no inicializado bien

## 6) Error `api-key-not-valid` (Web)
Si en login/registro aparece:
`[firebase_auth/api-key-not-valid.-please-pass-a-valid-api-key]`

Significa que el archivo `lib/firebase_options.dart` tiene claves de ejemplo o incorrectas.

### Solucion recomendada
1. Firebase Console -> Project settings -> General
2. En "Tus apps", entra en la app Web de este proyecto (`betflix-955fc`)
3. Copia la configuracion Web real (`apiKey`, `appId`, `messagingSenderId`, `projectId`, `authDomain`, `storageBucket`, `measurementId`)
4. Reemplaza esos valores en `lib/firebase_options.dart` dentro de `DefaultFirebaseOptions.web`
5. Reinicia la app Flutter Web

### Importante
- No uses valores de ejemplo como `AIza...x5L6x5...` ni `G-XXXXXXXXXX`.
- `projectId` debe ser exactamente `betflix-955fc`.
