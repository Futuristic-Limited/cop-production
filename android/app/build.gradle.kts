plugins {
    id("com.android.application")
    id("com.google.gms.google-services") // FlutterFire Configuration
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin") // Must come after Android/Kotlin plugins
}

android {
    namespace = "com.aphrc.futuristic"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.aphrc.futuristic"
        minSdk = 21 // unified for Kotlin DSL
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    lint {
        checkReleaseBuilds = false
        abortOnError = false
    }

    packagingOptions {
        resources.excludes.add("META-INF/*")
    }
}

flutter {
    source = "../.."
}
