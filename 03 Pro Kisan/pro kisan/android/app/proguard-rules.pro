# Flutter specific
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.embedding.engine.deferredcomponents.**

# SQLite (sqflite)
-keep class com.tekartik.sqflite.** { *; }

# Keep our models (important so JSON serialization works)
-keep class com.prokisan.app.** { *; }

# For PDF/Printing if used
-dontwarn com.itextpdf.**

# ── flutter_local_notifications ──────────────────────────────────────
#
# ⚠️ ये पंक्तियाँ हटाईं तो ऐप फिर टूटेगा — और सिर्फ़ release build में।
#
# 9 अगस्त 2026 को असली फ़ोन पर पकड़ा गया: पशु जोड़कर "सेव करें" दबाते ही
# बटन हमेशा के लिए घूमता रह जाता था। पशु database में सेव हो चुका होता,
# पर screen बंद ही नहीं होती — किसान को ऐप बंद करना पड़ता।
#
#   java.lang.RuntimeException: Missing type parameter.
#     at FlutterLocalNotificationsPlugin.loadScheduledNotifications
#     at …removeNotificationFromCache → cancelNotification → cancel
#
# वजह: यह plugin अपने रखे हुए reminder Gson के TypeToken से पढ़ता है।
# TypeToken को generic का पता `Signature` attribute से चलता है — और R8
# उसे release build में हटा देता है। तब Gson को टाइप मिलता ही नहीं।
#
# 🔴 debug build में R8 चलता ही नहीं, इसलिए यह न `flutter run` में दिखा,
#    न किसी unit test में। सिर्फ़ असली release APK पर दिखता है।
#
# इसी वजह से रोज़ के दूध वाले reminder भी चुपचाप नहीं लग रहे थे
# (`scheduleDailyReminders` भी यही अपवाद फेंक रहा था)।
-keep class com.dexterous.** { *; }
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes InnerClasses, EnclosingMethod

# Gson — TypeToken के subclass reflection से बनते हैं, इसलिए बचे रहें
-keep class com.google.gson.** { *; }
-keep class * extends com.google.gson.reflect.TypeToken
-keep public class * implements java.lang.reflect.Type
-dontwarn com.google.gson.**
