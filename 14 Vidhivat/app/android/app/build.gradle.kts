import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// ── Release signing (→ docs/22) ─────────────────────────────────────
//
// चाबी और उसका पासवर्ड `android/key.properties` में रहते हैं, और वो
// फ़ाइल `.gitignore` में है — यानी git में कभी नहीं जाती।
//
// ⚠️ यह फ़ाइल न हो तो build **डिबग चाबी** पर लौट जाता है, ताकि
// `flutter run --release` काम करता रहे। पर उस APK को Play पर मत डालना।
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.vidhivat"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.vidhivat"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = keystoreProperties["storeFile"]?.let { file(it) }
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // ⚠️ चाबी हो तो उससे, न हो तो डिबग से — ताकि जिस डेवलपर के
            // पास चाबी नहीं है उसका `flutter run --release` न टूटे।
            //
            // Play पर जाने वाली `.aab` हमेशा उसी मशीन से बनेगी जिस पर
            // `key.properties` रखी है। जाँचने का तरीक़ा नीचे है:
            //   flutter build appbundle --release
            //   ...फिर bundletool या Play Console ख़ुद बता देगा कि
            //   किस चाबी से sign हुई है।
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
