# ── Flutter Engine ──────────────────────────────────────────────────
-keep class io.flutter.** { *; }
-keep class io.flutter.app.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.view.** { *; }
-dontwarn io.flutter.**

# ── Google Mobile Ads (AdMob) ────────────────────────────────────────
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.ads.** { *; }
-keep class com.google.android.gms.** { *; }
-keep class com.google.firebase.** { *; }
-dontwarn com.google.**

# ── Kotlin ──────────────────────────────────────────────────────────
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-keepclassmembers class kotlin.Metadata { *; }
-keepclassmembers class **$WhenMappings { *; }
-keepclassmembers class kotlin.coroutines.** { *; }
-dontwarn kotlin.**

# ── AndroidX / Jetpack ──────────────────────────────────────────────
-keep class androidx.** { *; }
-keep interface androidx.** { *; }
-dontwarn androidx.**

# ── JNI / Native methods ─────────────────────────────────────────────
-keepclasseswithmembernames class * {
    native <methods>;
}

# ── Parcelable ───────────────────────────────────────────────────────
-keepclassmembers class * implements android.os.Parcelable {
    static ** CREATOR;
}

# ── Serializable ─────────────────────────────────────────────────────
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# ── Suppress notes/warnings ──────────────────────────────────────────
-dontnote **
-ignorewarnings
