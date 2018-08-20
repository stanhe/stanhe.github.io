---
title: Gradle.build
date: 2016-10-20 21:13:01
tags: gradle
---
![Gradle](http://oanvj2lsv.bkt.clouddn.com/gradle/gradle.png)
<center> gradle-config </center >
<!---more--->
### Android studio gradle config.
### Module:app
```
//内部顶层基本设置
buildscript {
    repositories {
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:0.14.+'
    }
}
// 依赖仓库
repositories {
    maven { url "https://jitpack.io" }
    mavenCentral()
    jcenter()
    maven { url 'https://maven.fabric.io/public' }
}

apply plugin: 'com.android.application'
//android 标签下的设置会在build的时候以hardcode形式生成,所以内部方法只在build的时候调用一次.
android {
    compileSdkVersion 21
    buildToolsVersion "21.1.0"
    defaultConfig {
        minSdkVersion 9
        targetSdkVersion 21
        versionCode appVersionCode
        versionName "1.1.1"
        multiDexEnabled false
        manifestPlaceholders = [ UMENG_CHANNEL_VALUE:"default_channel" ]
        buildConfigField "boolean", "ISDEBUG", "true"
    }
    //拓展最大堆内存
    dexOptions {
        javaMaxHeapSize "4g"
    }
    //跳过错误
    lintOptions {
        disable 'InvalidPackage'
        checkReleaseBuilds false
        // Or, if you prefer, you can continue to check for errors in release builds,
        // but continue the build even when errors are found:
        abortOnError false
    }
    //签名
    signingConfigs {
        debug {
            //storeFile file("../myKey/debug.keystore")
        }
        //你自己的keystore信息
        release {
            //storeFile file("../myKey/appKey.keystore") // `../`开始表示当前包目录下
            //storePassword ""
            //keyAlias "sam"
            //keyPassword ""
        }
    }
    buildTypes {
        debug {
            signingConfig signingConfigs.debug
            buildConfigField "boolean", "ISDEBUG", "true"
            manifestPlaceholders = [facebook_id_key: "1715761408682261", facebook_id_key_string: "@string/facebook_app_id_test"]
        }
        release {
            buildConfigField "boolean", "ISDEBUG", "true"
            signingConfig signingConfigs.release
            manifestPlaceholders = [facebook_id_key: "1715761408682261", facebook_id_key_string: "@string/facebook_app_id_test"]
            minifyEnabled true
            zipAlignEnabled true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.txt'
        }
    }
    //渠道Flavors，我这里写了一些常用的，自己改
    productFlavors {
        //GooglePlay{}
        //NDuo{}
        xiaomi {}
        umeng {}
    }
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_7
        targetCompatibility JavaVersion.VERSION_1_7
    }
    productFlavors.all { flavor ->
        flavor.manifestPlaceholders = [ UMENG_CHANNEL_VALUE:name ]
    }
    applicationVariants.all { variant ->
        variant.outputs.each { output ->
            def outputFile = output.outputFile
            if (outputFile != null && outputFile.name.endsWith('.apk')) {
                 def fileName = outputFile.name.replace(".apk", "-v${defaultConfig.versionName}(${defaultConfig.versionCode}).apk")
                 //def fileName = outputFile.name.replace("app","you app name").replace(".apk","-v${defaultConfig.versionName}(${defaultConfig.versionCode}).apk");
               // def apkName = "you app name" + android.defaultConfig.versionName;
               //apkName += "_" + variant.buildType.name + "_" + android.defaultConfig.versionCode+".apk"
               //output.outputFile = file("$project.buildDir/apk/" + apkName)
                output.outputFile = new File("$project.buildDir/apk/", fileName)
            }
        }
    }
    // 相同包冲突
     configurations.all {
        resolutionStrategy {
            force 'com.android.support:design:23.4.0'
            force 'com.android.support:support-v4:23.4.0'
            force 'com.android.support:appcompat-v7:23.4.0'
        }
    }
}
dependencies {
    compile fileTree(dir: 'libs', include: ['*.jar'])
    compile 'com.android.support:appcompat-v7:21.+'
    compile 'com.android.support:support-v4:21.+'
    compile 'com.android.support:cardview-v7:21.+'
    compile 'com.android.support:recyclerview-v7:21.+'
}

//下面的选一个就好.

//versionnumberautoincrement — mainifest
import java.util.regex.Pattern

task('increaseVersionCode') << {
    def manifestFile = file("src/main/AndroidManifest.xml")
    def pattern = Pattern.compile("versionCode=\"(\\d+)\"")
    def manifestText = manifestFile.getText()
    def matcher = pattern.matcher(manifestText)
    matcher.find()
    def versionCode = Integer.parseInt(matcher.group(1))
    def manifestContent = matcher.replaceAll("versionCode=\"" + ++versionCode + "\"")
    manifestFile.write(manifestContent)
}
tasks.whenTaskAdded { task ->
    if (task.name == 'generateReleaseBuildConfig') {
        task.dependsOn 'increaseVersionCode'
    }
}

//versionnumberautoincrement — gradle
import java.util.regex.Pattern
task('increaseVersionCode') << {
    def manifestFile = file("build.gradle")
    def manifestText = manifestFile.getText()
    def matcher = Pattern.compile("versionCode (\\d+)").matcher(manifestText)
    matcher.find()
    def versionCode = Integer.parseInt(matcher.group(1))
    def manifestContent = matcher.replaceAll("versionCode " + ++versionCode)
    manifestFile.write(manifestContent)
}
tasks.whenTaskAdded { task ->
    if (task.name == 'generateReleaseBuildConfig') {
        task.dependsOn 'increaseVersionCode'
    }
}

```

### Project:XXX      //project的build.gradle

```
// add properties appVersionCode = manifest.versionCode+1
ext.appVersionCode = initVersionCode()
import java.util.regex.Pattern
def initVersionCode(){
    def manifestFile = file("jancartui2/src/main/AndroidManifest.xml")//或者从build.gradle下拿.
    def manifestText = manifestFile.getText()
    def matcher = Pattern.compile("versionCode=\"(\\d+)\"").matcher(manifestText)
    def versionCode = -2;
    try{
        matcher.find()
        versionCode = Integer.parseInt(matcher.group(1))+1
    }catch (Exception e){e.printStackTrace()}
    println(" --------->  current versionCode : "+versionCode)
    if (versionCode==-1)
        throw Exception("can't get versionCode");
    return versionCode
}
```

### Init properties
#### local.properties
add properties
```
#Wed Jun 29 22:33:01 CST 2016
sdk.dir=C\:\\Users\\stan\\AppData\\Local\\Android\\Sdk
app.api=api-23-5.0
app.author = stan
```
#### rootDir/setting.gradle
```
include ':app'
def initSettingsEnv(){
    Properties properties = new Properties()
    String path = rootDir.getAbsolutePath()+"/local.properties"
    File propertiesFile = new File(path)
    properties.load(propertiesFile.newDataInputStream())
    gradle.ext.api = properties.getProperty("app.api")
    gradle.ext.author = properties.getProperty("app.author")
}

initSettingsEnv()
```
and then we can get the property with gradle.api/gradle.author
