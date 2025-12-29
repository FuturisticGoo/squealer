plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "futuristicgoo.squealer"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

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
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
        }
        debug {
            applicationIdSuffix ".debug"
        }
    }

   flavorDimensions "default"
   productFlavors {
       independent {
            signingConfig signingConfigs.release
       }
       fdroid {
       }
   }



    packagingOptions {
        jniLibs {
            useLegacyPackaging = true
        }
    }
}

// See: https://developer.android.com/build/configure-apk-splits
import com.android.build.OutputFile

// Map for the version code that gives each ABI a value.
ext.abiCodes = ['armeabi-v7a': 1, 'arm64-v8a': 2, 'x86_64': 3]

android.applicationVariants.all { variant ->
  // Assigns a different version code for each output APK
  // other than the universal APK.
  variant.outputs.each { output ->
    // Determines the ABI for this variant and returns the mapped value.
    def baseAbiVersionCode = project.ext.abiCodes.get(output.getFilter(OutputFile.ABI))

    // Because abiCodes.get() returns null for ABIs that are not mapped by ext.abiCodes,
    // the following code doesn't override the version code for universal APKs.
    // However, because you want universal APKs to have the lowest version code,
    // this outcome is desirable.
    if (baseAbiVersionCode != null) {

      // Assigns the new version code to versionCodeOverride, which changes the
      // version code for only the output APK, not for the variant itself. Skipping
      // this step causes Gradle to use the value of variant.versionCode for the APK.
      output.versionCodeOverride =
            variant.versionCode * 10 + baseAbiVersionCode
    }
  }



flutter {
    source = "../.."
}
