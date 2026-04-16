# Web Build Optimization Guide

## Recommended Build Commands

### Option 1: CanvasKit Renderer (Better compatibility, larger bundle)
```bash
flutter build web --release --web-renderer canvaskit --dart-define=FLUTTER_WEB_USE_SKIA=true
```

### Option 2: HTML Renderer (Smaller bundle, better performance)
```bash
flutter build web --release --web-renderer html
```

### Option 3: Optimized CanvasKit (Balanced)
```bash
flutter build web --release \
  --web-renderer canvaskit \
  --dart-define=FLUTTER_WEB_USE_SKIA=true \
  --dart-define=FLUTTER_WEB_AUTO_DETECT=true
```

## Build Script

Create a file `build_web.sh` (Linux/Mac) or `build_web.bat` (Windows):

### Windows (build_web.bat):
```batch
@echo off
echo Building MYNT Plus Web App (Optimized)...
flutter clean
flutter pub get
flutter build web --release --web-renderer html
echo Build complete! Output: build/web
pause
```

### Linux/Mac (build_web.sh):
```bash
#!/bin/bash
echo "Building MYNT Plus Web App (Optimized)..."
flutter clean
flutter pub get
flutter build web --release --web-renderer html
echo "Build complete! Output: build/web"
```

## Performance Comparison

| Renderer | Bundle Size | Performance | Compatibility |
|----------|-------------|-------------|---------------|
| HTML     | ~1-2 MB     | Excellent   | Modern browsers |
| CanvasKit| ~3-5 MB     | Good        | All browsers |

## Additional Optimizations

### 1. Enable Tree Shaking
Already enabled by default in release builds.

### 2. Minify JavaScript
Already enabled in release builds.

### 3. Compress Assets
Add to `pubspec.yaml`:
```yaml
flutter:
  assets:
    # ... existing assets
  # Consider compressing images before adding
```

### 4. Analyze Bundle Size
```bash
flutter build web --release --analyze-size
```

## Deployment Recommendations

1. **Use CDN** for static assets
2. **Enable Gzip/Brotli** compression on server
3. **Set proper cache headers** for assets
4. **Use HTTP/2** for better multiplexing
5. **Implement service worker caching** (already present)

## Monitoring

After deployment, monitor:
- Bundle size
- Load time
- Core Web Vitals (LCP, FID, CLS)
- First Contentful Paint (FCP)
- Time to Interactive (TTI)

