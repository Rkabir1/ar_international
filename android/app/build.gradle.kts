plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.ar_international"
android {
    // এখানে namespace পরিবর্তন করুন
    namespace = "com.ar_international.app" 
    compileSdk = flutter.compileSdkVersion

    defaultConfig {
        // এখানে applicationId পরিবর্তন করুন
        applicationId = "com.ar_international.app" 
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
    // বাকি অংশ আগের মতোই থাকবে...
}

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
