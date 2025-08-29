# Keep Razorpay classes
-keep class com.razorpay.** { *; }
-dontwarn com.razorpay.**

# Keep ProGuard annotations
-keep class proguard.annotation.** { *; }
-dontwarn proguard.annotation.**

# Keep classes that use @Keep annotation
-keep @proguard.annotation.Keep class * { *; }
-keepclassmembers class * {
    @proguard.annotation.Keep *;
}

# Keep classes that use @KeepClassMembers annotation
-keep @proguard.annotation.KeepClassMembers class * { *; }

# Additional Flutter rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }