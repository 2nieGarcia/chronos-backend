package com.chronos.chronosbackend.repository

import com.chronos.chronosbackend.model.EventReservation
import com.chronos.chronosbackend.model.ReservationStatus
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query
import java.time.LocalDate
import java.time.LocalTime

interface EventReservationRepository : JpaRepository<EventReservation, Int> {
    
    fun findByStatus(status: ReservationStatus): List<EventReservation>
    
    fun findByOrganizationName(organizationName: String): List<EventReservation>
    
    @Query("""
        SELECT e FROM EventReservation e
        WHERE e.room.id = :roomId
        AND e.eventDate = :eventDate
        AND e.status IN ('APPROVED', 'ADVISOR_APPROVED', 'PENDING')
        AND (
            (e.startTime < :endTime AND e.endTime > :startTime)
        )
    """)
    fun findConflictingReservations(
        roomId: Int,
        eventDate: LocalDate,
        startTime: LocalTime,
        endTime: LocalTime
    ): List<EventReservation>
    
    @Query("""
        SELECT e FROM EventReservation e
        WHERE e.eventDate >= :startDate
        AND e.eventDate <= :endDate
        AND e.status IN ('APPROVED', 'ADVISOR_APPROVED')
        ORDER BY e.eventDate, e.startTime
    """)
    fun findApprovedReservationsBetween(startDate: LocalDate, endDate: LocalDate): List<EventReservation>
}
