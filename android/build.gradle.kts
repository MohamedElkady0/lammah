allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

// --- بداية كود الإصلاح الذكي ---
subprojects {
    // تعريف وظيفة التعديل
    val fixCompileSdk = { proj: Project ->
        if (proj.plugins.hasPlugin("com.android.library") || proj.plugins.hasPlugin("com.android.application")) {
            try {
                val android = proj.extensions.getByName("android")
                // المحاولة الأولى: الطريقة القديمة (الأكثر شيوعاً)
                val setCompileSdkVersion = android.javaClass.getMethod("setCompileSdkVersion", Int::class.javaPrimitiveType)
                setCompileSdkVersion.invoke(android, 36)
                println("✅ Forced compileSdkVersion to 36 for: ${proj.name}")
            } catch (e: Exception) {
                // المحاولة الثانية: الطريقة الجديدة
                try {
                    val android = proj.extensions.getByName("android")
                    val setCompileSdk = android.javaClass.getMethod("setCompileSdk", Int::class.javaPrimitiveType)
                    setCompileSdk.invoke(android, 36)
                    println("✅ Forced compileSdk to 36 for: ${proj.name}")
                } catch (e2: Exception) {
                    // فشل صامت
                }
            }
        }
    }

    // التحقق الذكي من حالة المشروع لتجنب خطأ already evaluated
    if (project.state.executed) {
        fixCompileSdk(project)
    } else {
        project.afterEvaluate {
            fixCompileSdk(project)
        }
    }
}
// --- نهاية كود الإصلاح ---

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}