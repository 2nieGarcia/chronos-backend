package com.chronos.chronosbackend.config

import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.web.SecurityFilterChain

@Configuration
class SecurityConfig {

    @Bean
    fun securityFilterChain(http: HttpSecurity): SecurityFilterChain {
        http
            .csrf { it.disable() } // Disable CSRF for API endpoints
            .authorizeHttpRequests { auth ->
                // Allow public access to Swagger (optional) or Health checks
                auth.requestMatchers("/public/**").permitAll()
                // Require Authentication for everything else
                auth.anyRequest().authenticated()
            }
            .oauth2ResourceServer { oauth2 ->
                oauth2.jwt { } // Use default JWT validation (validates against Supabase URL)
            }

        return http.build()
    }
}