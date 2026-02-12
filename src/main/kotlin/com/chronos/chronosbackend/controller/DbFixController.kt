package com.chronos.chronosbackend.controller

import jakarta.persistence.EntityManager
import jakarta.persistence.PersistenceContext
import org.springframework.http.ResponseEntity
import org.springframework.transaction.annotation.Transactional
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/api/admin")
class DbFixController {

    @PersistenceContext
    private lateinit var entityManager: EntityManager

    @PostMapping("/fix-sequences")
    @Transactional
    fun fixSequences(): ResponseEntity<String> {
        // Fix for 'rooms' table sequence
        val queryRooms = entityManager.createNativeQuery(
            "SELECT setval('rooms_room_id_seq', (SELECT MAX(room_id) FROM rooms) + 1)"
        )
        queryRooms.resultList
        
        // Fix for 'event_reservations' table sequence just in case
        val queryReservations = entityManager.createNativeQuery(
             "SELECT setval('event_reservations_reservation_id_seq', COALESCE((SELECT MAX(reservation_id) FROM event_reservations), 0) + 1)"
        )
        queryReservations.resultList

        return ResponseEntity.ok("Sequences updated successfully")
    }
}
