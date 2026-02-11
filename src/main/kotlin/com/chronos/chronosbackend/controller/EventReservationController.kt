package com.chronos.chronosbackend.controller

import com.chronos.chronosbackend.model.EventReservation
import com.chronos.chronosbackend.model.ReservationStatus
import com.chronos.chronosbackend.repository.EventReservationRepository
import com.chronos.chronosbackend.service.ConflictResult
import com.chronos.chronosbackend.service.ConflictService
import org.springframework.format.annotation.DateTimeFormat
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*
import java.time.LocalDate

@RestController
@RequestMapping("/api/reservations")
class EventReservationController(
    private val reservationRepository: EventReservationRepository,
    private val conflictService: ConflictService
) {

    @GetMapping
    fun getAllReservations(): List<EventReservation> {
        return reservationRepository.findAll()
    }

    @GetMapping("/{id}")
    fun getReservationById(@PathVariable id: Int): ResponseEntity<EventReservation> {
        return reservationRepository.findById(id)
            .map { ResponseEntity.ok(it) }
            .orElse(ResponseEntity.notFound().build())
    }

    @GetMapping("/status/{status}")
    fun getReservationsByStatus(@PathVariable status: ReservationStatus): List<EventReservation> {
        return reservationRepository.findByStatus(status)
    }

    @GetMapping("/organization/{organizationName}")
    fun getReservationsByOrganization(@PathVariable organizationName: String): List<EventReservation> {
        return reservationRepository.findByOrganizationName(organizationName)
    }

    @GetMapping("/upcoming")
    fun getUpcomingReservations(
        @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) startDate: LocalDate,
        @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) endDate: LocalDate
    ): List<EventReservation> {
        return reservationRepository.findApprovedReservationsBetween(startDate, endDate)
    }

    /**
     * Create a new reservation request
     * Automatically checks for conflicts before saving
     */
    @PostMapping
    fun createReservation(@RequestBody request: EventReservation): ResponseEntity<Any> {
        // Check for conflicts
        val conflicts = conflictService.findConflicts(
            roomId = request.room.id!!,
            requestedDate = request.eventDate,
            startTime = request.startTime,
            endTime = request.endTime
        )

        if (conflicts.hasConflict) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body(
                mapOf(
                    "error" to "Room is not available at the requested time",
                    "conflicts" to conflicts
                )
            )
        }

        val saved = reservationRepository.save(request)
        return ResponseEntity.status(HttpStatus.CREATED).body(saved)
    }

    /**
     * Check for conflicts before creating a reservation
     */
    @PostMapping("/check-conflicts")
    fun checkConflicts(@RequestBody request: EventReservation): ConflictResult {
        return conflictService.findConflicts(
            roomId = request.room.id!!,
            requestedDate = request.eventDate,
            startTime = request.startTime,
            endTime = request.endTime
        )
    }

    @PutMapping("/{id}")
    fun updateReservation(
        @PathVariable id: Int,
        @RequestBody updates: EventReservation
    ): ResponseEntity<EventReservation> {
        return reservationRepository.findById(id)
            .map { existing ->
                val updated = existing.copy(
                    eventTitle = updates.eventTitle,
                    eventDate = updates.eventDate,
                    startTime = updates.startTime,
                    endTime = updates.endTime,
                    purpose = updates.purpose,
                    expectedAttendees = updates.expectedAttendees
                )
                ResponseEntity.ok(reservationRepository.save(updated))
            }
            .orElse(ResponseEntity.notFound().build())
    }

    @DeleteMapping("/{id}")
    fun deleteReservation(@PathVariable id: Int): ResponseEntity<Void> {
        return if (reservationRepository.existsById(id)) {
            reservationRepository.deleteById(id)
            ResponseEntity.noContent().build()
        } else {
            ResponseEntity.notFound().build()
        }
    }
}
