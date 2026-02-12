package com.chronos.chronosbackend.controller

import com.chronos.chronosbackend.model.Organization
import com.chronos.chronosbackend.repository.OrganizationRepository
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/organizations")
class OrganizationController(
    private val repository: OrganizationRepository
) {

    @GetMapping
    fun getAllOrganizations(): List<Organization> {
        return repository.findAll()
    }

    @GetMapping("/{id}")
    fun getOrganizationById(@PathVariable id: Int): ResponseEntity<Organization> {
        return repository.findById(id)
            .map { ResponseEntity.ok(it) }
            .orElse(ResponseEntity.notFound().build())
    }
}
