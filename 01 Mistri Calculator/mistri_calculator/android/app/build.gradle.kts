plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.mistricalculator.mistri_calculator"
    compileSdk = flutter.compileSdkVersion
    // Pin NDK 28.2: a transitive plugin (google_mobile_ads / webview_flutter)
    // requires it, and its llvm-strip cleanly strips the large release
    // libflutter.so from ~156 MB to ~11 MB. Do NOT re-add
    // keepDebugSymbols("**/*.so") — that kept full symbols and ballooned the
    // APK to 143 MB.
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.mistricalculator.mistri_calculator"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // NOTE: The NDK (with llvm-strip) IS installed under H:\Android\Sdk\ndk,
    // so AGP strips native libs automatically. Do NOT re-add
    // jniLibs.keepDebugSymbols("**/*.so") — that kept the full debug symbols
    // and bloated libflutter.so from ~11 MB to ~164 MB per ABI (143 MB APK).

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { file("$it") }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
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

