import java.util.Properties
import java.io.FileInputStream
import com.android.build.gradle.internal.api.ApkVariantOutputImpl

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localProperties.load(FileInputStream(localPropertiesFile))
}
var flutterVersionCode = (localProperties["flutter.versionCode"] as String?)?.toIntOrNull()
if (flutterVersionCode == null) {
    flutterVersionCode = 1
}
var flutterVersionName = localProperties["flutter.versionName"] as String?
if (flutterVersionName == null) {
    flutterVersionName = "1.0"
}

android {
    namespace = "futuristicgoo.squealer"
    compileSdk = 36
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "futuristicgoo.squealer"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutterVersionCode
        versionName = flutterVersionName
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String
        }
    }
    
    buildTypes {
        debug {
            applicationIdSuffix = ".debug"
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    flavorDimensions += "default"
    productFlavors {
        create("independent") {
            dimension = "default"
            signingConfig = signingConfigs.getByName("release")
        }
        create("fdroid") {
            dimension = "default"
        }
    }

    packagingOptions {
        jniLibs {
            useLegacyPackaging = true
        }
    }
}


flutter {
    source = "../.."
}


// Map for the version code that gives each ABI a value.
val abiCodes = mapOf("armeabi-v7a" to 1, "arm64-v8a" to 2, "x86_64" to 3)


// This is the only method that works now
android.applicationVariants.configureEach {
    val variant = this
    variant.outputs.forEach { output ->
        val abiVersionCode = abiCodes[output.filters.find { it.filterType == "ABI" }?.identifier]
        if (abiVersionCode != null) {
            (output as ApkVariantOutputImpl).versionCodeOverride = variant.versionCode * 10 + abiVersionCode
        }
    }
}

// This method is mentioned in the Android documentation but because of a bug
// with Flutter and Kotlin DSL, the version code is being overriden
// https://github.com/flutter/flutter/issues/173917
// androidComponents {
//     onVariants { variant ->

//         // Assigns a different version code for each output APK
//         // other than the universal APK.
//         variant.outputs.forEach { output ->
//             val name = output.filters.find { it.filterType == ABI }?.identifier
//             // Stores the value of abiCodes that is associated with the ABI for this variant.
//             val baseAbiCode = abiCodes[name]
//             // Because abiCodes.get() returns null for ABIs that are not mapped by ext.abiCodes,
//             // the following code doesn't override the version code for universal APKs.
//             // However, because you want universal APKs to have the lowest version code,
//             // this outcome is desirable.

//             if (baseAbiCode != null) {
//                 // Assigns the new version code to output.versionCode, which changes the version code
//                 // for only the output APK, not for the variant itself.
//                 output.versionCode.set((output.versionCode.get() ?: 0) * 10 + baseAbiCode)
//             }
//         }
//     }
// }


