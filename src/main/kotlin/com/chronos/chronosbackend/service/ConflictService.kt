package com.chronos.chronosbackend.service

import com.chronos.chronosbackend.model.DayOfWeek
import com.chronos.chronosbackend.repository.AcademicScheduleRepository
import com.chronos.chronosbackend.repository.EventReservationRepository
import org.springframework.stereotype.Service
import java.time.LocalDate
import java.time.LocalTime

@Service
class ConflictService(
    private val academicScheduleRepository: AcademicScheduleRepository,
    private val eventReservationRepository: EventReservationRepository
) {

    /**
     * The Core Conflict Detection Algorithm
     * 
     * Checks if a room is available for a specific date and time by:
     * 1. Converting the date to a day of week
     * 2. Checking against recurring academic schedules
     * 3. Checking against one-time event reservations
     * 
     * Returns true if there's a conflict, false if the room is free
     */
    fun hasConflict(
        roomId: Int,
        requestedDate: LocalDate,
        startTime: LocalTime,
        endTime: LocalTime
    ): Boolean {
        // Validate time range
        require(startTime < endTime) { "Start time must be before end time" }

        // Step 1: Check against recurring academic schedules
        val dayOfWeek = convertToDayOfWeek(requestedDate)
        val academicConflicts = academicScheduleRepository.findConflictingSchedules(
            roomId = roomId,
            dayOfWeek = dayOfWeek,
            startTime = startTime,
            endTime = endTime
        )

        if (academicConflicts.isNotEmpty()) {
            return true // Conflict with academic schedule
        }

        // Step 2: Check against one-time event reservations
        val reservationConflicts = eventReservationRepository.findConflictingReservations(
            roomId = roomId,
            eventDate = requestedDate,
            startTime = startTime,
            endTime = endTime
        )

        return reservationConflicts.isNotEmpty()
    }

    /**
     * Find all conflicts for a given time slot
     * Returns detailed information about what's conflicting
     */
    fun findConflicts(
        roomId: Int,
        requestedDate: LocalDate,
        startTime: LocalTime,
        endTime: LocalTime
    ): ConflictResult {
        val dayOfWeek = convertToDayOfWeek(requestedDate)
        
        val academicConflicts = academicScheduleRepository.findConflictingSchedules(
            roomId, dayOfWeek, startTime, endTime
        )
        
        val reservationConflicts = eventReservationRepository.findConflictingReservations(
            roomId, requestedDate, startTime, endTime
        )

        return ConflictResult(
            hasConflict = academicConflicts.isNotEmpty() || reservationConflicts.isNotEmpty(),
            academicConflicts = academicConflicts.map { 
                "Course ${it.courseCode} on ${it.dayOfWeek} from ${it.startTime} to ${it.endTime}"
            },
            reservationConflicts = reservationConflicts.map {
                "${it.eventTitle} by ${it.organizationName} on ${it.eventDate} from ${it.startTime} to ${it.endTime} (${it.status})"
            }
        )
    }

    /**
     * Convert Java LocalDate to our DayOfWeek enum
     */
    private fun convertToDayOfWeek(date: LocalDate): DayOfWeek {
        return when (date.dayOfWeek) {
            java.time.DayOfWeek.MONDAY -> DayOfWeek.MONDAY
            java.time.DayOfWeek.TUESDAY -> DayOfWeek.TUESDAY
            java.time.DayOfWeek.WEDNESDAY -> DayOfWeek.WEDNESDAY
            java.time.DayOfWeek.THURSDAY -> DayOfWeek.THURSDAY
            java.time.DayOfWeek.FRIDAY -> DayOfWeek.FRIDAY
            java.time.DayOfWeek.SATURDAY -> DayOfWeek.SATURDAY
            java.time.DayOfWeek.SUNDAY -> DayOfWeek.SUNDAY
        }
    }
}

data class ConflictResult(
    val hasConflict: Boolean,
    val academicConflicts: List<String>,
    val reservationConflicts: List<String>
)
