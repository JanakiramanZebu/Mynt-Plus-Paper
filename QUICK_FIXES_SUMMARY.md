# Quick Performance Fixes - Implementation Guide

## Overview
This document provides step-by-step implementation for the quickest performance wins identified in the analysis report.

---

## 1. HTML Optimization (5 minutes) ⚡

### File: `web/index.html`

**Changes:**
- Add resource hints (preconnect, dns-prefetch)
- Add font-display strategy
- Optimize script loading
- Add performance meta tags

**Impact:** 10-15% faster initial load

---

## 2. Provider Rebuild Optimization (1 hour) ⚡⚡

### Files to Update:
- `lib/main.dart` - Theme provider
- `lib/provider/auth_provider.dart` - Login state
- `lib/screens/web/ordersbook/order_book_screen_web.dart` - Order book
- `lib/screens/web/position/position_screen_web.dart` - Positions
- `lib/screens/web/holdings/holding_screen_web.dart` - Holdings

**Pattern to Replace:**
```dart
// ❌ Before
final provider = ref.watch(someProvider);

// ✅ After
final specificValue = ref.watch(someProvider.select((p) => p.specificField));
// OR
final provider = ref.read(someProvider); // If rebuild not needed
```

**Impact:** 20-30% reduction in unnecessary rebuilds

---

## 3. Web Build Configuration (15 minutes) ⚡

### Create: `web_build_config.md` or update build script

**Add to build command:**
```bash
flutter build web --release --web-renderer canvaskit --dart-define=FLUTTER_WEB_USE_SKIA=true
```

**Or for HTML renderer (smaller bundle):**
```bash
flutter build web --release --web-renderer html
```

**Impact:** 15-25% smaller bundle size

---

## 4. RepaintBoundary Usage (30 minutes) ⚡

### Add RepaintBoundary around:
- Large tables
- Charts
- Complex widgets that rebuild frequently

**Example:**
```dart
RepaintBoundary(
  child: DataTable2(...),
)
```

**Impact:** Smoother animations, better frame rate

---

## 5. Font Loading Optimization (5 minutes) ⚡

### File: `web/index.html`

**Add:**
- Preconnect to Typekit
- Font-display: swap (via CSS)
- Consider self-hosting fonts

**Impact:** Faster text rendering, better LCP

---

## Implementation Order

1. **HTML Optimization** (5 min) - Do first
2. **Font Loading** (5 min) - Do second  
3. **Web Build Config** (15 min) - Do third
4. **RepaintBoundary** (30 min) - Do fourth
5. **Provider Optimization** (1 hour) - Do last (most impact)

**Total Time:** ~2 hours  
**Expected Improvement:** 30-40% performance gain

---

## Testing After Changes

1. Run Lighthouse audit
2. Check bundle size
3. Test on slow 3G
4. Monitor frame rate
5. Check Core Web Vitals

---

## Next Steps After Quick Wins

1. Implement progressive data loading
2. Add table pagination
3. Optimize images (WebP)
4. Implement route-based code splitting

