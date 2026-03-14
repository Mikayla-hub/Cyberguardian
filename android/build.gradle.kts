allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://jitpack.io") }
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

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

subprojects {
    fun setNamespace() {
        val android = extensions.findByName("android")
        if (android != null) {
            val getNamespace = android.javaClass.getMethod("getNamespace")
            if (getNamespace.invoke(android) == null) {
                android.javaClass.getMethod("setNamespace", String::class.java).invoke(android, project.group.toString())
            }
        }
    }

    if (project.state.executed) {
        setNamespace()
    } else {
        afterEvaluate {
            setNamespace()
        }
    }

    project.configurations.all {
        resolutionStrategy.eachDependency {
            if (requested.group == "com.github.scottyab" && requested.name == "rootbeer") {
                useTarget("com.scottyab:rootbeer-lib:0.1.0")
            }
        }
    }
}
