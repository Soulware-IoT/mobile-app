allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// stripe_android's compileOnly dependency on stripe-android-issuing-push-
// provisioning (tap-to-pay card issuing — unused by this app) itself pulls in
// com.google.android.gms:play-services-tapandpay, an artifact that isn't
// published on any public Maven repo (Google restricts it to enrolled
// partners). Compiling stripe_android's Kotlin sources doesn't actually need
// it, but the release lint task's stricter classpath resolution does — so
// drop only that one transitive dependency, keeping the Stripe issuing
// module itself intact.
subprojects {
    configurations.all {
        exclude(group = "com.google.android.gms", module = "play-services-tapandpay")
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
