package com.chronos.chronosbackend.dto

import java.time.LocalDate
import java.time.LocalTime

data class ConflictCheckRequest(
    val roomId: Int,
    val eventDate: LocalDate,
    val startTime: LocalTime,
    val endTime: LocalTime
)
