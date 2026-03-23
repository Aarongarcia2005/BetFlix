# BetFlix - Aplicación de Apuestas Deportivas con Moneda Virtual

## 📱 Descripción del Proyecto

**BetFlix** es una innovadora aplicación de apuestas deportivas diseñada para permitir que personas de pueblos y ciudades pequeñas puedan apostar en equipos locales de sus regiones. La aplicación utiliza un **sistema de moneda virtual** (BFC - BetFlix Coins) sin dinero real, incluyendo características como:

- 💰 **Sistema de Moneda Virtual**: Usuarios comienzan con 5,000 monedas
- 🏆 **Ranking de Jugadores**: Sistema competitivo basado en monedas ganadas
- 🎯 **Retos y Desafíos**: Objetivos especiales para ganar monedas extra
- ⚽ **Apuestas en Partidos**: Crear y gestionar apuestas en equipos locales
- 📊 **Estadísticas**: Seguimiento de historial, racha ganadora y tasa de acierto
- 🎖️ **Logros**: Sistema de badges y reconocimientos

---

## 🎨 Diseño Visual

### Paleta de Colores (Basada en el Logo BetFlix)

- **Azul Primario**: `#003B7A` - Color profesional principal
- **Rojo Acento**: `#E41E3F` - Para alertas y acciones destacadas
- **Dorado/Amarillo**: `#FFD700` - Para monedas, premium y éxitos
- **Grises**: Para fondos y elementos secundarios
- **Verde**: Para estados de éxito

### Tipografía

- **Títulos**: Bold, 20-32px
- **Cuerpo**: Regular/Medium, 12-16px
- **Botones**: Bold, 16px con letter-spacing

---

## 📁 Estructura del Proyecto

```
lib/
├── main.dart                      # Punto de entrada y navegación principal
├── config/
│   ├── colors.dart               # Paleta de colores personalizada
│   ├── app_theme.dart            # Tema principal de la aplicación
│   └── app_constants.dart        # Constantes globales
├── models/
│   └── models.dart               # Modelos de datos (Match, User, Bet, Challenge, Ranking)
├── screens/
│   ├── home_screen.dart          # Pantalla principal con partidos locales
│   ├── create_bet_screen.dart    # Crear nuevas apuestas
│   ├── challenges_screen.dart    # Retos y desafíos
│   ├── ranking_screen.dart       # Ranking de jugadores
│   ├── user_profile_screen.dart  # Perfil del usuario
│   └── live_match_screen.dart    # Partido en vivo
├── widgets/
│   └── betflix_widgets.dart      # Componentes reutilizables
└── exports.dart                  # Exportación centralizada
```

---

## 🎯 Pantallas Principales

### 1. **Home Screen** (`home_screen.dart`)
- Pantalla inicial con partidos locales destacados
- Lista de retos populares
- Header profesional con perfil y monedas
- Navegación rápida a otras secciones

### 2. **Create Bet Screen** (`create_bet_screen.dart`)
- Seleccionar tipo de apuesta (Victoria Local, Empate, Victoria Visitante)
- Ingresar monto de apuesta
- Cálculo automático de ganancias potenciales
- Confirmar y crear la apuesta

### 3. **Challenges Screen** (`challenges_screen.dart`)
- Pestañas para retos activos y completados
- Tarjetas visuales de retos con progreso
- Diferentes tipos: Racha ganadora, Aciertos, Apuestas activas, etc.

### 4. **Ranking Screen** (`ranking_screen.dart`)
- Podio visual (Top 3 con medallas)
- Ranking completo con información detallada
- Monedas totales y tasa de acierto
- Badges desbloqueados

### 5. **User Profile Screen** (`user_profile_screen.dart`)
- Información del perfil con avatar
- Estadísticas detalladas (Nivel, Racha, Apuestas, Acierto)
- Galería de logros (badges)
- Opciones de acciones (Historial, Cerrar sesión)

### 6. **Live Match Screen** (`live_match_screen.dart`)
- Marcador en vivo con estadísticas
- Timeline de eventos del partido
- Apuestas en vivo con cuotas actualizadas
- Botón para crear apuestas durante el partido

---

## 🎨 Componentes de Widget Reutilizables

### MatchCard
Tarjeta profesional para mostrar partidos con:
- Equipos y logos
- Estado (EN VIVO, Próximo)
- Indicador si es equipo local
- Fecha y hora

### BetButton
Botón especializado para apuestas mostrando:
- Tipo de apuesta
- Cuota
- Estado seleccionado/no seleccionado

### CoinWidget
Visualización de monedas con:
- Emoji 💰
- Cantidad formateada
- Modo resaltado (Gold)

### BadgeWidget
Logros visibles con:
- Emoji del achievement
- Título
- Estado (desbloqueado/bloqueado)

### ChallengeCard
Tarjeta de reto con:
- Icono del reto
- Título y descripción
- Barra de progreso
- Recompensa en monedas

### ProfessionalHeader
Header personalizado con:
- Avatar del usuario
- Nombre y ranking
- Monedas totales
- Diseño degradado profesional

---

## 🔧 Configuración de Tema

El archivo `app_theme.dart` contiene:

### Light Theme
- Colores principales (Azul BetFlix)
- AppBar personalizado
- Bottom Navigation Bar
- Estilos de botones (Elevated, Outlined, Text)
- InputDecoration para formularios
- Tipografía jerarquizada (Display, Headline, Body, Label)

### Dark Theme
- Versión oscura completa
- Colores ajustados para mejor legibilidad
- Mantiene la identidad de marca

---

## 📊 Modelos de Datos

### Match
```dart
Match(
  id, homeTeam, awayTeam,
  homeScore, awayScore,
  dateTime, status, league,
  isLocal // Indicador de equipo local
)
```

### BetFlixUser
```dart
BetFlixUser(
  id, name, email, profileImageUrl,
  coins, winStreak, totalBets, correctBets,
  level, joinDate
)
```

### Bet
```dart
Bet(
  id, userId, matchId,
  betType, amount, odds,
  createdAt, status,
  potentialWinnings
)
```

### Challenge
```dart
Challenge(
  id, title, description, icon,
  rewardCoins, deadline,
  status, type,
  targetValue, currentProgress
)
```

### RankingEntry
```dart
RankingEntry(
  position, userId, userName,
  profileImageUrl, coins,
  correctBets, totalBets, badges
)
```

---

## 🚀 Características Principales

### 1. Sistema de Monedas Virtual
- Inicio con 5,000 BFC
- Ganar/perder según resultados de apuestas
- Bonificaciones por retos completados
- Sin dinero real involucrado

### 2. Apuestas Locales
- Enfoque en equipo de ciudades pequeñas
- Promoción de apoyo a deportes locales
- Liga Local Regional como categoría principal

### 3. Predicciones Múltiples
- Victoria Local
- Empate
- Victoria Visitante
- Opciones avanzadas: Over/Under

### 4. Gamificación
- Racha ganadora
- Niveles de usuario
- Badges desbloqueables
- Ranking competitivo

### 5. Estadísticas Personales
- Tasa de acierto
- Total de apuestas
- Apuestas ganadoras
- Historial completo

---

## 🎯 Flujo de Interacción

```
Inicio (Home)
    ↓
Ver Partidos Locales
    ↓
Seleccionar Partido
    ↓
Crear Apuesta
    ├─ Seleccionar tipo
    ├─ Ingresar monto
    ├─ Ver ganancias potenciales
    └─ Confirmar
    ↓
Monedas Actualizadas
    ↓
Ranking → Ver progreso
Retos → Ganar bonificaciones
Perfil → Ver estadísticas
```

---

## 🔄 Navegación

**Bottom Navigation Bar**
- 🏠 **Inicio**: Home Screen
- 🎯 **Retos**: Challenges Screen
- 🏆 **Ranking**: Ranking Screen
- 👤 **Perfil**: User Profile Screen

**Navegación por Rutas**
- `/create-bet`: Create Bet Screen
- `/challenges`: Challenges Screen
- `/ranking`: Ranking Screen
- `/profile`: User Profile Screen
- `/live-match`: Live Match Screen

---

## 🛠️ Constantes Globales

### Dimensiones
- `paddingSmall`: 8.0
- `paddingMedium`: 16.0
- `paddingLarge`: 24.0
- `borderRadiusMedium`: 12.0

### Moneda
- Símbolo: 💰
- Código: BFC (BetFlix Coins)
- Monedas iniciales: 5,000

### Animaciones
- `animationDurationShort`: 200ms
- `animationDurationMedium`: 400ms
- `animationDurationLong`: 600ms

---

## 📦 Dependencias

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
```

---

## 🎨 Tokens de Diseño

### Espaciado
- 8px, 16px, 24px, 32px

### Border Radius
- Piccolo: 8px
- Mediano: 12px
- Grande: 16px
- Extra grande: 24px

### Elevación/Sombras
- Small: 2.0
- Medium: 4.0
- Large: 8.0

---

## 🚀 Cómo Usar

1. **Clonar/Descargar** el proyecto
2. **Ejecutar** `flutter pub get`
3. **Ejecutar** `flutter run`
4. **Navegar** a través de las pestañas inferiores
5. **Crear apuestas** en partidos locales
6. **Competir** en el ranking global

---

## 💡 Funcionalidades Futuras

1. **Backend Real**
   - API REST para sincronización
   - Autenticación de usuarios
   - Base de datos de partidos en vivo
   - Notificaciones

2. **Características Avanzadas**
   - Partidos más específicos por ubicación
   - Apuestas múltiples (Parlay)
   - Sistema de amigos
   - Chat de comunidad

3. **Mejoras de UX**
   - Animaciones más fluidas
   - Transiciones mejoradas
   - Temas personalizables
   - Idiomas múltiples

4. **Análisis**
   - Estadísticas detalladas
   - Gráficos de rendimiento
   - Predicciones de IA
   - Consejos de expertosl

---

## 📝 Notas de Estilo

- Consistencia de colores en toda la app
- Espaciado uniforme usando constantes
- Tipografía jerárquica clara
- Iconos Material Design
- Componentes reutilizables y mantenibles
- Temas cohesivos de juego/apuestas

---

## 👨‍💻 Instrucciones de Desarrollo

### Agregar Nueva Pantalla
1. Crear archivo en `lib/screens/`
2. Importar dependencias necesarias
3. Usar `AppTheme` para estilos
4. Agregar a rutas en `main.dart`
5. Actualizar navegación si es necesario

### Agregar Nuevo Widget
1. Crear función/clase en `lib/widgets/betflix_widgets.dart`
2. Usar colores de `BetFlixColors`
3. Usar constantes de `AppConstants`
4. Exportar en `exports.dart`

### Agregar Nuevo Modelo
1. Crear en `lib/models/models.dart`
2. Incluir enums relacionados
3. Agregar métodos útiles (getters calculados)

---

## 📞 Soporte

Para preguntas o problemas, consulta la estructura del código y los comentarios en cada archivo.

---

**¡BetFlix - Donde los sueños locales inspiran apuestas globales! 🌟⚽💰**
