package com.chronos.chronosbackend.model

import jakarta.persistence.*
import java.time.LocalTime

@Entity
@Table(name = "academic_schedules")
data class AcademicSchedule(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "schedule_id")
    val id: Int? = null,

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "room_id", nullable = false)
    val room: Room,

    @Column(name = "course_code", nullable = false)
    val courseCode: String,

    @Column(name = "course_name")
    val courseName: String? = null,

    @Enumerated(EnumType.STRING)
    @Column(name = "day_of_week", nullable = false)
    val dayOfWeek: DayOfWeek,

    @Column(name = "start_time", nullable = false)
    val startTime: LocalTime,

    @Column(name = "end_time", nullable = false)
    val endTime: LocalTime,

    @Column
    val semester: String? = null,

    @Column(name = "academic_year")
    val academicYear: String? = null,

    @Column
    val instructor: String? = null
)
