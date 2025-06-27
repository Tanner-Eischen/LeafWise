# Theme Rules & Visual Style Guide

Comprehensive visual styling guidelines for our plant-focused Snapchat clone, defining colors, typography, spacing, and visual elements to ensure consistent theming across all platforms and features.

---

## Design System Overview

### Theme Philosophy: "Glass Garden Minimalism"

**Core Concept**: Botanical minimalism enhanced with strategic glassmorphic elements
**Visual Identity**: Clean, nature-inspired aesthetics with modern technological sophistication
**Brand Personality**: Nurturing, knowledgeable, approachable, and growth-oriented

---

## Color Palette

### Primary Colors

**Forest Green** - `#2D5A27`
- **Usage**: Primary brand color, navigation highlights, expert badges
- **Accessibility**: WCAG AA compliant with white text
- **Semantic**: Trust, expertise, deep plant knowledge
- **Applications**: Headers, primary buttons, active states

**Sage Green** - `#87A96B`
- **Usage**: Secondary actions, learning indicators, growth progress
- **Accessibility**: WCAG AA compliant with dark text
- **Semantic**: Growth, learning, community connection
- **Applications**: Secondary buttons, progress bars, badges

**Cream White** - `#F7F5F3`
- **Usage**: Primary background, content areas, card backgrounds
- **Accessibility**: High contrast base for all text colors
- **Semantic**: Clean slate, new growth, fresh start
- **Applications**: Main backgrounds, card surfaces, input fields

**Earth Brown** - `#8B4513`
- **Usage**: Grounding elements, soil references, stability indicators
- **Accessibility**: WCAG AA compliant with light backgrounds
- **Semantic**: Foundation, stability, natural grounding
- **Applications**: Icons, borders, subtle accents

### Accent Colors

**Sunset Orange** - `#FF6B35`
- **Usage**: Urgent notifications, care alerts, warning states
- **Accessibility**: High contrast for attention-grabbing elements
- **Semantic**: Urgency, attention, immediate action needed
- **Applications**: Error states, urgent care reminders, alerts

**Sky Blue** - `#87CEEB`
- **Usage**: Water-related care tips, calm interactions, info states
- **Accessibility**: WCAG AA compliant with dark text
- **Semantic**: Calm, water, peaceful growth
- **Applications**: Info messages, water care indicators, calm states

**Warm Yellow** - `#F4D03F`
- **Usage**: Achievements, successful growth, positive feedback
- **Accessibility**: Requires dark text for proper contrast
- **Semantic**: Success, achievement, sunny growth
- **Applications**: Success states, achievements, positive notifications

### Glassmorphic Color Variations

**Light Glass** - `rgba(247, 245, 243, 0.15)`
- **Usage**: Subtle overlays, gentle backgrounds
- **Applications**: Camera interface overlays, subtle cards

**Medium Glass** - `rgba(247, 245, 243, 0.25)`
- **Usage**: Prominent cards, modal backgrounds
- **Applications**: RAG content cards, modal dialogs

**Accent Glass** - `rgba(135, 169, 107, 0.12)`
- **Usage**: Botanical-tinted glass effects
- **Applications**: Plant identification overlays, nature-themed cards

**Alert Glass** - `rgba(255, 107, 53, 0.15)`
- **Usage**: Urgent care notifications with glass effect
- **Applications**: Emergency plant care alerts, warning overlays

### Semantic Color System

**Success States**
- Primary: `#87A96B` (Sage Green)
- Background: `rgba(135, 169, 107, 0.1)`
- Border: `rgba(135, 169, 107, 0.3)`

**Warning States**
- Primary: `#F4D03F` (Warm Yellow)
- Background: `rgba(244, 208, 63, 0.1)`
- Border: `rgba(244, 208, 63, 0.3)`

**Error States**
- Primary: `#FF6B35` (Sunset Orange)
- Background: `rgba(255, 107, 53, 0.1)`
- Border: `rgba(255, 107, 53, 0.3)`

**Info States**
- Primary: `#87CEEB` (Sky Blue)
- Background: `rgba(135, 206, 235, 0.1)`
- Border: `rgba(135, 206, 235, 0.3)`

### Seasonal Color Adaptations

**Spring Theme** (March - May)
- Accent: Light green tints `#A8D5A8`
- Glass: Warmer, lighter glass effects
- Mood: Fresh, new growth, optimistic

**Summer Theme** (June - August)
- Accent: Brighter, more saturated greens `#6B8E23`
- Glass: Clearer, more vibrant effects
- Mood: Abundant, thriving, energetic

**Fall Theme** (September - November)
- Accent: Warm orange and brown tints `#CD853F`
- Glass: Warmer, amber-tinted effects
- Mood: Harvest, preparation, cozy

**Winter Theme** (December - February)
- Accent: Cooler blue-green tints `#5F8A8B`
- Glass: Cooler, more muted effects
- Mood: Rest, planning, contemplative

---

## Typography

### Font Families

**Primary Font: Inter**
- **Usage**: Body text, UI elements, buttons, navigation
- **Weights**: 300 (Light), 400 (Regular), 500 (Medium), 600 (SemiBold), 700 (Bold)
- **Characteristics**: Clean, readable, modern, excellent mobile performance
- **Accessibility**: High legibility at all sizes, dyslexia-friendly

**Accent Font: Playfair Display**
- **Usage**: Headers, plant names, special emphasis
- **Weights**: 400 (Regular), 600 (SemiBold), 700 (Bold)
- **Characteristics**: Elegant serif, botanical feel, distinctive personality
- **Applications**: Page titles, plant species names, featured content

### Typography Scale

**Display Large** - 32px / 40px line height
- Font: Playfair Display Bold
- Usage: Main page headers, welcome screens
- Color: Forest Green `#2D5A27`

**Display Medium** - 28px / 36px line height
- Font: Playfair Display SemiBold
- Usage: Section headers, plant species names
- Color: Forest Green `#2D5A27`

**Heading Large** - 24px / 32px line height
- Font: Inter SemiBold
- Usage: Card headers, modal titles
- Color: Forest Green `#2D5A27`

**Heading Medium** - 20px / 28px line height
- Font: Inter Medium
- Usage: Subsection headers, feature titles
- Color: Earth Brown `#8B4513`

**Heading Small** - 18px / 24px line height
- Font: Inter Medium
- Usage: List headers, category labels
- Color: Earth Brown `#8B4513`

**Body Large** - 16px / 24px line height
- Font: Inter Regular
- Usage: Primary body text, descriptions
- Color: `#2C2C2C` (Dark gray for readability)

**Body Medium** - 14px / 20px line height
- Font: Inter Regular
- Usage: Secondary text, captions
- Color: `#5A5A5A` (Medium gray)

**Body Small** - 12px / 16px line height
- Font: Inter Regular
- Usage: Labels, metadata, timestamps
- Color: `#8A8A8A` (Light gray)

**Caption** - 11px / 14px line height
- Font: Inter Medium
- Usage: Fine print, legal text, tiny labels
- Color: `#A0A0A0` (Very light gray)

### Typography Usage Guidelines

**Plant Care Instructions**
- Headers: Heading Medium (Inter Medium)
- Steps: Body Large with numbered lists
- Tips: Body Medium with italic emphasis
- Warnings: Body Large with Sunset Orange color

**User Interface Elements**
- Button text: Body Medium (Inter Medium)
- Navigation labels: Body Small (Inter Medium)
- Input labels: Body Small (Inter Medium)
- Error messages: Body Medium with error color

**Content Hierarchy**
- Plant names: Display Medium (Playfair Display)
- Care categories: Heading Small (Inter Medium)
- Descriptions: Body Large (Inter Regular)
- Metadata: Body Small (Inter Regular)

---

## Spacing and Layout

### Spacing Scale (8px base unit)

**Micro Spacing**
- `4px` - Icon padding, fine adjustments
- `8px` - Base unit, small gaps
- `12px` - Compact spacing, tight layouts

**Standard Spacing**
- `16px` - Default spacing, comfortable gaps
- `24px` - Section spacing, card padding
- `32px` - Large spacing, major sections

**Macro Spacing**
- `48px` - Page margins, major separations
- `64px` - Screen sections, hero spacing
- `96px` - Dramatic spacing, special layouts

### Layout Grid System

**Mobile Grid** (375px base)
- Margins: 16px
- Gutters: 16px
- Columns: 4 columns
- Column width: ~71px

**Tablet Grid** (768px base)
- Margins: 24px
- Gutters: 24px
- Columns: 8 columns
- Column width: ~81px

**Component Spacing Rules**

**Cards and Containers**
- Internal padding: 16px (mobile), 24px (tablet+)
- Between cards: 16px vertical spacing
- Card corner radius: 12px (standard), 20px (prominent)

**Text Spacing**
- Paragraph spacing: 16px
- List item spacing: 8px
- Section spacing: 32px
- Header to content: 16px

**Interactive Elements**
- Button padding: 12px horizontal, 8px vertical
- Input padding: 16px horizontal, 12px vertical
- Touch target minimum: 44px × 44px
- Between buttons: 16px horizontal, 12px vertical

---

## Visual Effects and Styling

### Glassmorphic Effects

**Standard Glass Effect**
```css
.botanical-glass {
  background: rgba(247, 245, 243, 0.2);
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
  border: 1px solid rgba(135, 169, 107, 0.18);
  border-radius: 16px;
  box-shadow: 0 8px 32px rgba(45, 90, 39, 0.08);
}
```

**Prominent Glass Effect**
```css
.prominent-glass {
  background: rgba(247, 245, 243, 0.3);
  backdrop-filter: blur(15px);
  border: 1px solid rgba(135, 169, 107, 0.25);
  border-radius: 20px;
  box-shadow: 0 12px 40px rgba(45, 90, 39, 0.12);
}
```

**Subtle Glass Effect**
```css
.subtle-glass {
  background: rgba(247, 245, 243, 0.1);
  backdrop-filter: blur(6px);
  border: 1px solid rgba(135, 169, 107, 0.1);
  border-radius: 12px;
  box-shadow: 0 4px 20px rgba(45, 90, 39, 0.04);
}
```

### Shadow System

**Elevation Levels**

**Level 1** - Subtle elevation
- Shadow: `0 2px 8px rgba(45, 90, 39, 0.06)`
- Usage: Cards, buttons in default state

**Level 2** - Standard elevation
- Shadow: `0 4px 16px rgba(45, 90, 39, 0.08)`
- Usage: Floating elements, modals

**Level 3** - Prominent elevation
- Shadow: `0 8px 32px rgba(45, 90, 39, 0.12)`
- Usage: Important overlays, primary actions

**Level 4** - Maximum elevation
- Shadow: `0 16px 48px rgba(45, 90, 39, 0.16)`
- Usage: Tooltips, dropdowns, critical alerts

### Border Radius System

**Micro Radius** - `4px`
- Usage: Small elements, badges, chips

**Standard Radius** - `8px`
- Usage: Buttons, inputs, small cards

**Medium Radius** - `12px`
- Usage: Cards, containers, panels

**Large Radius** - `16px`
- Usage: Prominent cards, modal dialogs

**Extra Large Radius** - `20px`
- Usage: Hero elements, special containers

**Organic Radius** - `24px+`
- Usage: Botanical-inspired elements, special features

---

## Iconography

### Icon Style Guidelines

**Design Principles**
- Outlined style with 2px stroke weight
- Botanical inspiration where appropriate
- 24px × 24px standard size
- Consistent visual weight across icon set
- Rounded line caps for organic feel

**Icon Categories**

**Navigation Icons**
- Camera: Botanical camera with leaf accent
- Chat: Speech bubble with plant motif
- Discover: Magnifying glass with leaf
- Stories: Circle with growth rings
- Profile: User silhouette with plant crown

**Action Icons**
- Add: Plus sign with organic curves
- Share: Arrow with leaf trail
- Save: Bookmark with botanical accent
- Like: Heart with leaf detail
- Comment: Speech bubble with natural curves

**Plant Care Icons**
- Water: Droplet with natural curves
- Light: Sun with organic rays
- Temperature: Thermometer with plant accent
- Fertilizer: Bottle with leaf label
- Pruning: Scissors with botanical handles

**Status Icons**
- Success: Checkmark with leaf flourish
- Warning: Triangle with plant accent
- Error: X with organic curves
- Info: Circle with leaf detail
- Loading: Spinner with growth animation

### Icon Color Usage

**Default State**
- Color: `#8A8A8A` (Light gray)
- Usage: Inactive navigation, secondary actions

**Active State**
- Color: `#2D5A27` (Forest Green)
- Usage: Active navigation, primary actions

**Accent State**
- Color: `#87A96B` (Sage Green)
- Usage: Highlighted features, special states

**Alert State**
- Color: `#FF6B35` (Sunset Orange)
- Usage: Warnings, urgent notifications

---

## Component Styling

### Buttons

**Primary Button**
```css
.btn-primary {
  background: #2D5A27;
  color: #FFFFFF;
  border: none;
  border-radius: 8px;
  padding: 12px 24px;
  font: 500 14px Inter;
  box-shadow: 0 2px 8px rgba(45, 90, 39, 0.2);
}

.btn-primary:hover {
  background: #1F3E1B;
  box-shadow: 0 4px 16px rgba(45, 90, 39, 0.3);
}
```

**Secondary Button**
```css
.btn-secondary {
  background: transparent;
  color: #2D5A27;
  border: 1px solid #87A96B;
  border-radius: 8px;
  padding: 12px 24px;
  font: 500 14px Inter;
}

.btn-secondary:hover {
  background: rgba(135, 169, 107, 0.1);
  border-color: #2D5A27;
}
```

**Glass Button**
```css
.btn-glass {
  background: rgba(247, 245, 243, 0.2);
  backdrop-filter: blur(10px);
  color: #2D5A27;
  border: 1px solid rgba(135, 169, 107, 0.3);
  border-radius: 12px;
  padding: 12px 24px;
  font: 500 14px Inter;
}
```

### Input Fields

**Standard Input**
```css
.input-standard {
  background: #FFFFFF;
  border: 1px solid #E0E0E0;
  border-radius: 8px;
  padding: 16px;
  font: 400 16px Inter;
  color: #2C2C2C;
}

.input-standard:focus {
  border-color: #87A96B;
  box-shadow: 0 0 0 3px rgba(135, 169, 107, 0.1);
}
```

**Glass Input**
```css
.input-glass {
  background: rgba(247, 245, 243, 0.15);
  backdrop-filter: blur(8px);
  border: 1px solid rgba(135, 169, 107, 0.2);
  border-radius: 12px;
  padding: 16px;
  font: 400 16px Inter;
  color: #2C2C2C;
}
```

### Cards

**Standard Card**
```css
.card-standard {
  background: #FFFFFF;
  border-radius: 12px;
  padding: 24px;
  box-shadow: 0 2px 8px rgba(45, 90, 39, 0.06);
  border: 1px solid #F0F0F0;
}
```

**Glass Card**
```css
.card-glass {
  background: rgba(247, 245, 243, 0.2);
  backdrop-filter: blur(10px);
  border-radius: 16px;
  padding: 24px;
  border: 1px solid rgba(135, 169, 107, 0.18);
  box-shadow: 0 8px 32px rgba(45, 90, 39, 0.08);
}
```

---

## Animation and Transitions

### Timing Functions

**Standard Ease** - `cubic-bezier(0.4, 0.0, 0.2, 1)`
- Usage: General UI transitions, button states
- Duration: 200ms

**Organic Ease** - `cubic-bezier(0.25, 0.46, 0.45, 0.94)`
- Usage: Plant-inspired animations, growth effects
- Duration: 300ms

**Bounce Ease** - `cubic-bezier(0.68, -0.55, 0.265, 1.55)`
- Usage: Success states, positive feedback
- Duration: 400ms

**Slow Ease** - `cubic-bezier(0.25, 0.1, 0.25, 1)`
- Usage: Large content transitions, page changes
- Duration: 500ms

### Animation Patterns

**Fade Transitions**
- Opacity: 0 → 1
- Duration: 200ms
- Easing: Standard ease

**Slide Transitions**
- Transform: translateY(20px) → translateY(0)
- Duration: 300ms
- Easing: Organic ease

**Scale Transitions**
- Transform: scale(0.95) → scale(1)
- Duration: 200ms
- Easing: Standard ease

**Growth Animations**
- Transform: scale(0) → scale(1)
- Duration: 400ms
- Easing: Bounce ease

---

## Dark Mode Adaptations

### Dark Mode Color Palette

**Primary Background** - `#1A1A1A`
**Secondary Background** - `#2D2D2D`
**Card Background** - `#3A3A3A`
**Text Primary** - `#FFFFFF`
**Text Secondary** - `#B0B0B0`
**Text Tertiary** - `#808080`

**Botanical Colors (Adjusted)**
- Forest Green: `#4A8B3A` (Lighter for contrast)
- Sage Green: `#A5C99B` (Maintained visibility)
- Earth Brown: `#B8956A` (Warmed for dark backgrounds)

**Glass Effects (Dark Mode)**
```css
.dark-glass {
  background: rgba(58, 58, 58, 0.3);
  backdrop-filter: blur(12px);
  border: 1px solid rgba(165, 201, 155, 0.2);
}
```

---

## Implementation Guidelines

### CSS Custom Properties

```css
:root {
  /* Primary Colors */
  --color-forest-green: #2D5A27;
  --color-sage-green: #87A96B;
  --color-cream-white: #F7F5F3;
  --color-earth-brown: #8B4513;
  
  /* Accent Colors */
  --color-sunset-orange: #FF6B35;
  --color-sky-blue: #87CEEB;
  --color-warm-yellow: #F4D03F;
  
  /* Glass Effects */
  --glass-light: rgba(247, 245, 243, 0.15);
  --glass-medium: rgba(247, 245, 243, 0.25);
  --glass-accent: rgba(135, 169, 107, 0.12);
  
  /* Typography */
  --font-primary: 'Inter', sans-serif;
  --font-accent: 'Playfair Display', serif;
  
  /* Spacing */
  --space-xs: 4px;
  --space-sm: 8px;
  --space-md: 16px;
  --space-lg: 24px;
  --space-xl: 32px;
  
  /* Shadows */
  --shadow-sm: 0 2px 8px rgba(45, 90, 39, 0.06);
  --shadow-md: 0 4px 16px rgba(45, 90, 39, 0.08);
  --shadow-lg: 0 8px 32px rgba(45, 90, 39, 0.12);
}
```

### Flutter Theme Implementation

```dart
class BotanicalTheme {
  static const Color forestGreen = Color(0xFF2D5A27);
  static const Color sageGreen = Color(0xFF87A96B);
  static const Color creamWhite = Color(0xFFF7F5F3);
  static const Color earthBrown = Color(0xFF8B4513);
  
  static ThemeData get lightTheme => ThemeData(
    primarySwatch: MaterialColor(0xFF2D5A27, {
      50: Color(0xFFE8F5E8),
      100: Color(0xFFC5E4C5),
      // ... other shades
    }),
    fontFamily: 'Inter',
    // ... other theme properties
  );
}
```

This comprehensive theme guide ensures visual consistency and brand coherence across all aspects of our plant-focused social platform, supporting both the botanical aesthetic and modern technological features.