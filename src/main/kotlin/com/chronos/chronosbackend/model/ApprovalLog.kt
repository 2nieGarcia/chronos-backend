package com.chronos.chronosbackend.model

import jakarta.persistence.*
import java.time.LocalDateTime

@Entity
@Table(name = "approval_logs")
data class ApprovalLog(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "log_id")
    val id: Int? = null,

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "reservation_id", nullable = false)
    val reservation: EventReservation,

    @Column(name = "previous_status", nullable = false)
    @Enumerated(EnumType.STRING)
    val previousStatus: ReservationStatus,

    @Column(name = "new_status", nullable = false)
    @Enumerated(EnumType.STRING)
    val newStatus: ReservationStatus,

    @Column(name = "approved_by")
    val approvedBy: String? = null,

    @Column(name = "approved_at", nullable = false)
    val approvedAt: LocalDateTime = LocalDateTime.now(),

    @Column
    val comments: String? = null,

    @Column(name = "approver_role")
    val approverRole: String? = null
)
