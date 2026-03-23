# 🎨 Guía de Estilo Visual - BetFlix

## Sistema de Diseño

### 🎯 Principios de Diseño

1. **Claridad**: Información clara y accesible
2. **Profesionalismo**: Aspecto de casa de apuestas legítima
3. **Engagement**: Elementos gamificados y motivadores
4. **Consistencia**: Diseño uniforme en toda la app
5. **Accesibilidad**: Colores y tipografía accesibles

---

## 🌈 Paleta de Colores Definitiva

### Colores Primarios

```
Azul Prestige (Primario)
Hex: #003B7A
RGB: 0, 59, 122
Uso: Componentes principales, AppBar, botones

Rojo Intenso (Secundario/Acento)
Hex: #E41E3F
RGB: 228, 30, 63
Uso: Alertas, acciones críticas, ganancias/premios

Dorado Premium (Terciario)
Hex: #FFD700
RGB: 255, 215, 0
Uso: Monedas, logros, elementos premiums
```

### Colores Neutrales

```
Negro Profundo
Hex: #1A1A1A
RGB: 26, 26, 26
Uso: Texto principal

Gris Oscuro
Hex: #6B7280
RGB: 107, 114, 128
Uso: Texto secundario

Gris Claro
Hex: #F3F4F6
RGB: 243, 244, 246
Uso: Fondos y superficies

Blanco Puro
Hex: #FFFFFF
RGB: 255, 255, 255
Uso: Fondos principales, cards
```

### Colores Semánticos

```
Verde Éxito: #10B981 (Green-500)
Rojo Error: #EF4444 (Red-500)
Naranja Warning: #F59E0B (Amber-500)
Azul Info: #3B82F6 (Blue-500)
```

---

## 📧 Tipografía

### Familias
- **Primary**: Sistema (Roboto en Android, San Francisco en iOS)
- **Fallback**: Helvetica Neue, Arial

### Escala de Tamaños

```
Display Large    → 32px | Bold    | -0.5 letter-spacing
Display Medium   → 28px | Bold    | -0.5 letter-spacing
Display Small    → 24px | Bold    | 0 letter-spacing
Headline Large   → 22px | Bold    | 0 letter-spacing
Headline Medium  → 20px | W700    | 0 letter-spacing
Headline Small   → 18px | W700    | 0 letter-spacing
Title Large      → 16px | W600    | 0 letter-spacing
Title Medium     → 14px | W600    | 0 letter-spacing
Title Small      → 12px | W600    | 0.4 letter-spacing
Body Large       → 16px | W500    | 1.5 line-height
Body Medium      → 14px | W500    | 1.5 line-height
Body Small       → 12px | W500    | 1.4 line-height
Label Large      → 14px | W600    | 0.4 letter-spacing
Label Medium     → 12px | W600    | 0.4 letter-spacing
Label Small      → 10px | W600    | 0.3 letter-spacing
```

---

## 📐 Componentes

### Botones

#### Elevated Button
- Background: Primary Blue
- Text Color: White
- Padding: 24px horizontal, 12px vertical
- Border Radius: 12px
- Elevation: 4
- Font: Bold 16px

#### Outlined Button
- Border: 2px Primary Blue
- Text Color: Primary Blue
- Padding: 24px horizontal, 12px vertical
- Border Radius: 12px
- Font: Bold 16px

#### Text Button
- Text Color: Primary Blue
- Padding: 16px horizontal, 8px vertical
- Font: Bold 14px

---

### Cards

- **Border Radius**: 16px
- **Elevation**: 2
- **Background**: White
- **Padding**: 16px
- **Border**: 1px Light Grey (opcional)

---

### Input Fields

- **Border Radius**: 12px
- **Background**: Light Grey (#F3F4F6)
- **Border**: 1px Light Grey
- **Focused Border**: 2px Primary Blue
- **Padding**: 16px horizontal, 12px vertical
- **Font**: Medium 14px

---

## 🎨 Composiciones Visuales

### Match Card

```
┌─────────────────────────┐
│ Liga | 🌟 | EN VIVO     │
├─────────────────────────┤
│     🔵        VS        ⚫  │
│  Equipo A            Equipo B │
├─────────────────────────┤
│  🕐 Hoy · 15:30        │
└─────────────────────────┘
```

### Coin Widget

```
┌──────────────┐
│ 💰 3,200 FBC │
└──────────────┘
(Con gradiente dorado si es resaltado)
```

### Challenge Card

```
┌─────────────────────────┐
│ 🎯      🏆              │
│ Reto 1 vs 1             │
│ Acertá 3 partidos       │
│ ▓▓░░░░░░░░ 67%         │
│ 💰 500 | Deadline: 7d  │
└─────────────────────────┘
```

### Professional Header

```
┌─────────────────────────┐
│ ☉ Carlos G. | 🏆 #1 | 💰 3,200 │
└─────────────────────────┘
(Con gradiente azul)
```

---

## 🎯 Estados Interactivos

### Hover
- Reducir 2% de opacity
- Elevar ligeramente (shadow)

### Pressed
- Reducir 5% de opacity
- Escala 0.98x

### Disabled
- Opacity: 50%
- Cursor: not-allowed
- Color: Grey

### Focus
- Border: Primary Blue (2px)
- Outline: Primary Blue (4px outer)

---

## 📏 Espaciado

### Spacing Scale
```
4px   - XS
8px   - S
12px  - SM
16px  - M
24px  - L
32px  - XL
48px  - 2XL
64px  - 3XL
```

### Componentes

**Button Padding**
- Horizontal: 24px
- Vertical: 12px

**Card Padding**
- Uniforme: 16px

**Screen Padding**
- Horizontal: 16px
- Top/Bottom: 24px

---

## 🔄 Animaciones

```
Corta (entrada/salida rápida):  200ms (Cubic.easeInOut)
Media (transiciones):           400ms (Cubic.easeInOut)
Larga (revelaciones):           600ms (Cubic.easeOutCubic)
```

---

## 🎲 Gradientes

### Primary Gradient
```
Top Left: #003B7A (Blue)
Bottom Right: #002552 (Dark Blue)
```

### Success Gradient
```
Top: #10B981 (Green)
Bottom: #059669 (Dark Green)
```

### Premium Gradient
```
Top: #FFD700 (Gold)
Bottom: #FFA500 (Orange)
```

---

## 📱 Responsive Design

### Breakpoints
```
Mobile: < 600px
Tablet: 600px - 960px
Desktop: > 960px
```

### Adaptaciones
- **Cards**: Full width en mobile, máximo 400px en tablet
- **Grids**: 1 columna en mobile, 2 en tablet, 3+ en desktop
- **Padding**: Reducir 25% en mobile pequeños

---

## ♿ Accesibilidad

### Contraste
- Tipo/Fondo: Mínimo 4.5:1
- Interfaz: Mínimo 3:1

### Tamaño de Touch
- Mínimo: 48x48px
- Ideal: 56x56px

### Textos Alternativos
- Todos los iconos: tooltips o labels
- Imágenes: descripciones claras

---

## 🎨 Casos de Uso Visuales

### Apuesta Ganadora
- Fondo: Éxito Verde sutil
- Border: Verde intenso
- Icono: ✅

### Apuesta Perdida
- Fondo: Error Rojo sutil
- Border: Rojo intenso
- Icono: ❌

### Apuesta Pendiente
- Fondo: Info Azul sutil
- Border: Azul intenso
- Icono: ⏳

### Premium/VIP
- Fondo: Dorado
- Border: Dorado intenso
- Sombra: Dorado translúcido

---

## 📊 Indicadores Visuales

### Racha Ganadora
- Indicador: Icono 🔥
- Color: Rojo Intenso
- Animación: Pulse suave

### Top 3 Ranking
- 🥇 Dorado
- 🥈 Plata/Azul
- 🥉 Bronce/Naranja

### Badges Desbloqueados
- Saturado, con shadow dorado

### Badges Bloqueados
- Desaturado (50% opacity)
- Sin shadow

---

## 🔍 Dark Mode (Futuro)

```
Primary: #1A6FBF (Lighter Blue)
Background: #000000
Surface: #1A1A1A
Text: #FFFFFF
Subtitle: #B0B0B0
```

---

## 📋 Checklist de Implementación

- [ ] Colores exactos en recursos
- [ ] Tipografía cargada o sistema
- [ ] Iconos Material Design 3
- [ ] Espaciado consistente
- [ ] Estados hover/active/disabled
- [ ] Animaciones suaves
- [ ] Responsive en todos los breakpoints
- [ ] Tema oscuro (futuro)
- [ ] Accesibilidad verificada
- [ ] Testing de contraste

---

**Versión**: 1.0.0
**Último actualizado**: 2026-03-23
**Diseñador**: BetFlix Design System
