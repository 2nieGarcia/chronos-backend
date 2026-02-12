package com.chronos.chronosbackend.model

import jakarta.persistence.*
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.LocalTime

@Entity
@Table(name = "event_reservations")
data class EventReservation(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "reservation_id")
    val id: Int? = null,

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "room_id", nullable = false)
    val room: Room,

    @Column(name = "organization_name", nullable = false)
    val organizationName: String,

    @Column(name = "event_title", nullable = false)
    val eventTitle: String = "",

    @Column(name = "event_date", nullable = false)
    val eventDate: LocalDate,

    @Column(name = "start_time", nullable = false)
    val startTime: LocalTime,

    @Column(name = "end_time", nullable = false)
    val endTime: LocalTime,

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    val status: ReservationStatus = ReservationStatus.PENDING,

    @Column(name = "requested_by")
    val requestedBy: String? = null,

    @Column(name = "requested_at", nullable = false)
    val requestedAt: LocalDateTime = LocalDateTime.now(),

    @Column(name = "approved_by")
    val approvedBy: String? = null,

    @Column(name = "approved_at")
    val approvedAt: LocalDateTime? = null,

    @Column
    val purpose: String? = null,

    @Column(name = "expected_attendees")
    val expectedAttendees: Int? = null,

    @Column(name = "document_url")
    val documentUrl: String? = null
)
