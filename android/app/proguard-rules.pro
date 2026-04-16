## Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class com.google.firebase.** { *; }
-dontwarn io.flutter.embedding.**

## Fix for missing annotation classes (main issue)
-dontwarn com.google.j2objc.annotations.RetainedWith
-dontwarn proguard.annotation.Keep
-dontwarn proguard.annotation.KeepClassMembers
-dontwarn com.google.j2objc.annotations.**
-dontwarn proguard.annotation.**

## Razorpay specific rules
-keep class com.razorpay.** { *; }
-dontwarn com.razorpay.**
-keepattributes *Annotation*
-keepclasseswithmembers class * {
    public void onPayment*(***);
}
-optimizations !method/inlining/

## Additional missing classes fixes
-dontwarn com.google.errorprone.annotations.**
-dontwarn javax.annotation.**
-dontwarn javax.annotation.concurrent.GuardedBy

## General rules
-ignorewarnings