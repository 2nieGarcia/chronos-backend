package com.chronos.chronosbackend.controller

import com.chronos.chronosbackend.model.AcademicSchedule
import com.chronos.chronosbackend.repository.AcademicScheduleRepository
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/schedules")
class AcademicScheduleController(
    private val repository: AcademicScheduleRepository
) {

    @GetMapping
    fun getAllSchedules(): List<AcademicSchedule> {
        return repository.findAll()
    }

    @GetMapping("/room/{roomId}")
    fun getSchedulesByRoom(@PathVariable roomId: Int): List<AcademicSchedule> {
        return repository.findByRoomId(roomId)
    }
}
