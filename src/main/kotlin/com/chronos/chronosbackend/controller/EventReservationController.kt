package com.chronos.chronosbackend.controller

import com.chronos.chronosbackend.dto.ConflictCheckRequest
import com.chronos.chronosbackend.model.EventReservation
import com.chronos.chronosbackend.model.ReservationStatus
import com.chronos.chronosbackend.repository.EventReservationRepository
import com.chronos.chronosbackend.repository.RoomRepository
import com.chronos.chronosbackend.service.ConflictResult
import com.chronos.chronosbackend.service.ConflictService
import java.time.LocalDate
import org.springframework.format.annotation.DateTimeFormat
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/reservations")
class EventReservationController(
    private val reservationRepository: EventReservationRepository,
    private val conflictService: ConflictService,
    private val roomRepository: RoomRepository
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
        val roomId = request.room.id
        if (roomId == null) {
            return ResponseEntity.badRequest().body(mapOf("error" to "Room ID is required"))
        }

        // Fetch real room entity. This prevents TransientPropertyValueException
        val room = roomRepository.findById(roomId).orElse(null)
            ?: return ResponseEntity.badRequest().body(mapOf("error" to "Room not found"))

        // Check for conflicts
        val conflicts = conflictService.findConflicts(
            roomId = roomId,
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

        // Create a copy of the request with the managed Room entity
        val reservationToSave = request.copy(room = room)

        val saved = reservationRepository.save(reservationToSave)
        return ResponseEntity.status(HttpStatus.CREATED).body(saved)
    }

    /**
     * Check for conflicts before creating a reservation
     */
    @PostMapping("/check-conflicts")
    fun checkConflicts(@RequestBody request: ConflictCheckRequest): ConflictResult {
        return conflictService.findConflicts(
            roomId = request.roomId,
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

    @PutMapping("/{id}/approve")
    fun approveReservation(
        @PathVariable id: Int,
        @RequestBody request: Map<String, String>
    ): ResponseEntity<EventReservation> {
        return reservationRepository.findById(id)
            .map { reservation ->
                val updated = reservation.copy(
                    status = ReservationStatus.APPROVED,
                    approvedBy = request["approved_by"] ?: "System",
                    approvedAt = java.time.LocalDateTime.now()
                )
                ResponseEntity.ok(reservationRepository.save(updated))
            }
            .orElse(ResponseEntity.notFound().build())
    }

    @PutMapping("/{id}/reject")
    fun rejectReservation(
        @PathVariable id: Int,
        @RequestBody request: Map<String, String>
    ): ResponseEntity<EventReservation> {
        return reservationRepository.findById(id)
            .map { reservation ->
                val updated = reservation.copy(
                    status = ReservationStatus.REJECTED,
                    rejectedBy = request["rejected_by"] ?: "System",
                    rejectedAt = java.time.LocalDateTime.now(),
                    rejectionReason = request["comments"]
                )
                ResponseEntity.ok(reservationRepository.save(updated))
            }
            .orElse(ResponseEntity.notFound().build())
    }
}
