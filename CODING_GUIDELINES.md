# Guías de Estilo de Código - Ojo Ciudadano Admin

Este documento contiene las guías de estilo y mejores prácticas para el desarrollo del proyecto Ojo Ciudadano Admin.

## Índice

1. [Convenciones generales](#convenciones-generales)
2. [Manejo de colores y opacidad](#manejo-de-colores-y-opacidad)
3. [Estructura de archivos](#estructura-de-archivos)
4. [Widgets](#widgets)

## Convenciones generales

- Usar `camelCase` para variables y funciones
- Usar `PascalCase` para clases, enums y tipos
- Usar `snake_case` para nombres de archivos
- Mantener los archivos por debajo de 300 líneas cuando sea posible
- Documentar todas las clases y métodos públicos

## Manejo de colores y opacidad

### Uso de `withAlpha` en lugar de `withOpacity`

**IMPORTANTE**: El método `withOpacity` está obsoleto. Siempre usar `withAlpha` para modificar la transparencia de los colores.

```dart
// ❌ NO USAR
color: Colors.black.withOpacity(0.5);

// ✅ USAR
color: Colors.black.withAlpha(128);
```

Para facilitar la transición, hemos creado una extensión `ColorExtensions` que proporciona métodos de utilidad:

```dart
import 'package:ojo_ciudadano_admin/core/utils/color_extensions.dart';

// Si necesitas trabajar con valores de opacidad (0.0 - 1.0)
color: Colors.black.withOpacityValue(0.5); // Internamente usa withAlpha

// Para convertir un valor de opacidad a alpha
int alpha = ColorExtensions.opacityToAlpha(0.5); // Devuelve 128
color: Colors.black.withAlpha(alpha);
```

### Tabla de conversión de opacidad a alpha

| Opacidad | Alpha |
|----------|-------|
| 0.05     | 13    |
| 0.1      | 26    |
| 0.2      | 51    |
| 0.3      | 77    |
| 0.4      | 102   |
| 0.5      | 128   |
| 0.6      | 153   |
| 0.7      | 179   |
| 0.8      | 204   |
| 0.9      | 230   |
| 1.0      | 255   |

## Estructura de archivos

Seguimos una arquitectura limpia con la siguiente estructura:

- `lib/core/`: Utilidades, constantes, temas y componentes base
- `lib/data/`: Implementaciones de repositorios, modelos y fuentes de datos
- `lib/domain/`: Entidades, casos de uso e interfaces de repositorios
- `lib/presentation/`: Widgets, páginas y gestión de estado (BLoC)

## Widgets

- Preferir StatelessWidget cuando sea posible
- Extraer widgets reutilizables a archivos separados
- Usar BLoC para la gestión de estado en páginas complejas
- Implementar widgets responsivos que se adapten a diferentes tamaños de pantalla
