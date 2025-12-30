# Reglas específicas para Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Mantener clases nativas
-keepclasseswithmembernames class * {
    native <methods>;
}

# Mantener clases de la aplicación
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Application
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider

# Para plugins comunes de Flutter
-keep class com.google.android.gms.** { *; }
-keep class com.google.firebase.** { *; }
-keep class androidx.lifecycle.DefaultLifecycleObserver

# ✅ NUEVAS REGLAS PARA PLAY CORE (Solucionan tu error actual)
-keep class com.google.android.play.core.** { *; }
-keep class com.google.android.play.tasks.** { *; }
-keep class com.google.android.play.splitinstall.** { *; }
-keep class com.google.android.play.splitcompat.** { *; }

# Reglas específicas para las clases mencionadas en el error
-keep class com.google.android.play.core.splitcompat.SplitCompatApplication { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }

# Mantener todas las clases de Play Core referenciadas
-keep class com.google.android.play.** { *; }

# Please add these rules to your existing keep rules in order to suppress warnings.
# This is generated automatically by the Android Gradle plugin.
-dontwarn com.gemalto.jp2.JP2Decoder
-dontwarn com.gemalto.jp2.JP2Encoder