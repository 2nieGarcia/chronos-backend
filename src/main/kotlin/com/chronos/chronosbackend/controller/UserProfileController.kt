package com.chronos.chronosbackend.controller

import com.chronos.chronosbackend.model.UserProfile
import com.chronos.chronosbackend.repository.UserProfileRepository
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*
import java.security.Principal
import java.util.UUID

@RestController
@RequestMapping("/api/users")
class UserProfileController(
    private val repository: UserProfileRepository
) {

    @GetMapping
    fun getAllUsers(): List<UserProfile> {
        return repository.findAll()
    }

    @GetMapping("/me")
    fun getCurrentUser(principal: Principal): ResponseEntity<UserProfile> {
        val userId = UUID.fromString(principal.name)
        return repository.findById(userId)
            .map { ResponseEntity.ok(it) }
            .orElse(ResponseEntity.notFound().build())
    }

    @GetMapping("/{id}")
    fun getUserById(@PathVariable id: String): ResponseEntity<UserProfile> {
        val userId = UUID.fromString(id)
        return repository.findById(userId)
            .map { ResponseEntity.ok(it) }
            .orElse(ResponseEntity.notFound().build())
    }
}
