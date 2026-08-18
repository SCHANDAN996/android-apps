import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Load key.properties (kept out of git). Missing file → debug signing (dev only).
val keystoreProperties = Properties().apply {
    val f = rootProject.file("key.properties")
    if (f.exists()) load(FileInputStream(f))
}

android {
    namespace = "com.prokisan.app"
    compileSdk = 36
    ndkVersion = "28.2.13676358"

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        // tflite_flutter का Kotlin JVM 17 माँगता है — पूरा project उसी पर।
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.prokisan.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Flutter का gradle plugin defaultConfig के abiFilters को override कर देता है,
    // इसलिए x86/x86_64 (सिर्फ़ emulator के काम के) यहाँ से हटाते हैं — यह तरीक़ा
    // deterministic है। इससे APK ~25 MB हल्का हो जाता है और किसी असली फ़ोन पर
    // कोई फ़र्क़ नहीं पड़ता।
    packaging {
        jniLibs {
            excludes += setOf(
                "lib/x86/**",
                "lib/x86_64/**"
            )
            // ⚠️ यहाँ `keepDebugSymbols += setOf("**/*.so")` कभी मत लिखना।
            // उसका मतलब है "native library के debug symbols मत हटाओ" — तब
            // Flutter का engine (libflutter.so) 9 MB की जगह **156 MB** का
            // पैक होता है और APK 65 MB से बढ़कर 355 MB हो जाता है।
            // (यह दो बार हो चुका है — इसीलिए यह चेतावनी यहाँ लिखी है।)
            // crash-report के symbols build/ में अलग बनते हैं और Play Console
            // पर अलग से चढ़ाए जाते हैं — APK में भेजने की ज़रूरत नहीं।
        }
    }

    signingConfigs {
        create("release") {
            if (keystoreProperties.isNotEmpty()) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                // path in key.properties is relative to the `android/` folder
                storeFile = rootProject.file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (keystoreProperties.isNotEmpty())
                signingConfigs.getByName("release")
            else
                signingConfigs.getByName("debug")

            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
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

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
