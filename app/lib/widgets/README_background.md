# Background Widget

This module provides a single, flexible background widget for the Lunanul app that handles images, videos, and gradients with theme-aware overlays.

## BackgroundWidget

A versatile background widget that automatically determines the background type based on the provided path. It supports images, videos, and gradient backgrounds with automatic theme adaptation.

### Features

- **Auto-detection**: Automatically detects background type based on file extension
- **Multi-format support**: Images (.jpg, .png, .gif), Videos (.mp4, .mov, .avi, .mkv, .webm), and Gradients
- **Theme-aware**: Automatically adjusts colors, opacity, and blend modes for light/dark themes
- **Optional animation**: Subtle gradient movement for mystical effects
- **Video support**: Looping, muted background videos with overlay
- **Fallback handling**: Gracefully falls back to gradient if media fails to load
- **Performance optimized**: Efficient rendering for all background types

### Usage Examples

#### Gradient Background (Default - Mystical Theme)
```dart
BackgroundWidget(
  animated: true,
  child: YourContentWidget(),
)
```

#### Image Background with Overlay
```dart
BackgroundWidget(
  imagePath: 'assets/images/mystical_background.jpg',
  overlayOpacity: 0.6,
  child: YourContentWidget(),
)
```

#### Video Background
```dart
BackgroundWidget(
  imagePath: 'assets/videos/mystical_background.mp4',
  overlayOpacity: 0.4,
  child: YourContentWidget(),
)
```

#### Custom Gradient Colors
```dart
BackgroundWidget(
  gradientColors: [Colors.purple, Colors.blue, Colors.black],
  animated: true,
  child: YourContentWidget(),
)
```

### Supported File Extensions

- **Images**: .jpg, .jpeg, .png, .gif, .bmp, .webp
- **Videos**: .mp4, .mov, .avi, .mkv, .webm

### Automatic Behavior

1. **With imagePath**: 
   - If path ends with video extension → Video background
   - If path ends with image extension → Image background
   - If file fails to load → Falls back to gradient

2. **Without imagePath**: 
   - Always shows gradient background
   - Can be animated with `animated: true`



## Theme Integration

Both widgets integrate seamlessly with the app's theme system:

- **Light theme**: Uses lighter overlays and blend modes for better readability
- **Dark theme**: Uses darker overlays with higher opacity for proper contrast
- **Color scheme aware**: Respects the app's primary and secondary colors

## Performance Notes

- The HomeBackgroundWidget uses a 20-second animation cycle for subtle movement
- Gradients are more performant than large background images
- All animations are optimized for smooth 60fps performance