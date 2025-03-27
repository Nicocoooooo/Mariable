plugins {
    id("com.android.application")
    id("kotlin-android")
    // Le plugin Flutter Gradle doit être appliqué après les plugins Android et Kotlin.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.mariable"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = "com.example.mariable"
        minSdk = flutter.minSdkVersion
        targetSdk = 34
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Pour l'instant on utilise la clé de debug pour signer la release
            signingConfig = signingConfigs.getByName("debug")
            // Désactivation du code shrinking et du shrinkResources pour éviter l'erreur
            isMinifyEnabled = false
            isShrinkResources = false
            // Si vous souhaitez activer le resource shrinking, pensez à activer minification et à configurer vos règles ProGuard.
            // isMinifyEnabled = true
            // isShrinkResources = true
            // proguardFiles(
            //    getDefaultProguardFile("proguard-android.txt"),
            //    "proguard-rules.pro"
            // )
        }
    }
}

flutter {
    source = "../.."
}