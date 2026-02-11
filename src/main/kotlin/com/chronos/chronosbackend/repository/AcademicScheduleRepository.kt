package com.chronos.chronosbackend.repository

import com.chronos.chronosbackend.model.AcademicSchedule
import com.chronos.chronosbackend.model.DayOfWeek
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query
import java.time.LocalTime

interface AcademicScheduleRepository : JpaRepository<AcademicSchedule, Int> {
    
    fun findByRoomId(roomId: Int): List<AcademicSchedule>
    
    fun findByDayOfWeek(dayOfWeek: DayOfWeek): List<AcademicSchedule>
    
    @Query("""
        SELECT s FROM AcademicSchedule s
        WHERE s.room.id = :roomId
        AND s.dayOfWeek = :dayOfWeek
        AND (
            (s.startTime < :endTime AND s.endTime > :startTime)
        )
    """)
    fun findConflictingSchedules(
        roomId: Int,
        dayOfWeek: DayOfWeek,
        startTime: LocalTime,
        endTime: LocalTime
    ): List<AcademicSchedule>
}
