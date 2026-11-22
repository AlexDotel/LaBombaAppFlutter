plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "nuviapps.co.labomba"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "nuviapps.co.labomba"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
        signingConfig = signingConfigs.create("release") {
            keyAlias = "bomba-upload"
            keyPassword = "BombaUpload-e75a530345cc42ce"
            storeFile = file("../upload-keystore.jks")
            storePassword = "BombaUpload-e75a530345cc42ce"
        }
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    implementation("com.appodeal.ads.sdk:core:4.4.0")
    implementation("com.appodeal.ads.sdk.adapters:bidmachine:3.8.0.0")
    implementation("com.appodeal.ads.sdk.adapters:bidon:0.16.0.0")
    implementation("com.appodeal.ads.sdk.adapters:iab:1.8.1.1")
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
