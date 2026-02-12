package com.chronos.chronosbackend.controller

import com.chronos.chronosbackend.model.RequiredDocument
import com.chronos.chronosbackend.repository.RequiredDocumentRepository
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/documents")
class RequiredDocumentController(
    private val repository: RequiredDocumentRepository
) {

    @GetMapping
    fun getAllDocuments(): List<RequiredDocument> {
        return repository.findAll()
    }

    @GetMapping("/reservation/{reservationId}")
    fun getDocumentsByReservation(@PathVariable reservationId: Int): List<RequiredDocument> {
        return repository.findByReservationId(reservationId)
    }

    @PostMapping
    fun createDocument(@RequestBody document: RequiredDocument): ResponseEntity<RequiredDocument> {
        val saved = repository.save(document)
        return ResponseEntity.status(HttpStatus.CREATED).body(saved)
    }

    @DeleteMapping("/{id}")
    fun deleteDocument(@PathVariable id: Int): ResponseEntity<Void> {
        return if (repository.existsById(id)) {
            repository.deleteById(id)
            ResponseEntity.noContent().build()
        } else {
            ResponseEntity.notFound().build()
        }
    }
}
