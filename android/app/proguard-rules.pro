# Flutter engine and plugin embedding — required, R8 must not strip these.
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-dontwarn io.flutter.embedding.**

# Firebase / Google Play Services — reflection-based init breaks under R8 without this.
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Play Integrity API used by Firebase App Check.
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# Firestore/Auth model (de)serialization relies on these attributes.
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses
