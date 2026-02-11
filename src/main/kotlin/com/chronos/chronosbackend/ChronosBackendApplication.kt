package com.chronos.chronosbackend

import io.github.cdimascio.dotenv.Dotenv
import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication
class ChronosBackendApplication

fun main(args: Array<String>) {
    // 1. Force load the .env file
    try {
        val dotenv = Dotenv.configure()
            .directory("./") // Look in project root
            .ignoreIfMissing()
            .load()

        // 2. Inject them into System Properties so application.properties can read them
        dotenv.entries().forEach { entry ->
            System.setProperty(entry.key, entry.value)
        }
        println("✅ Loaded .env variables successfully")
    } catch (e: Exception) {
        println("⚠️ Could not load .env file (Ignore this if on Render Production)")
    }

    // 3. Start Spring Boot
    runApplication<ChronosBackendApplication>(*args)
}