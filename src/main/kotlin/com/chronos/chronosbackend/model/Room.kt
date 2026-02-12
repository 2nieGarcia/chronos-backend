package com.chronos.chronosbackend.model

import jakarta.persistence.*

@Entity
@Table(name = "rooms")
data class Room(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "room_id")
    val id: Int? = null,

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "building_id", nullable = false)
    val building: Building = Building(),

    @Column(name = "room_number", nullable = false)
    val roomNumber: String = "",

    @Enumerated(EnumType.STRING)
    @Column(name = "room_type", nullable = false)
    val roomType: RoomType = RoomType.CLASSROOM,

    @Column
    val capacity: Int? = null,

    @Column
    val floor: Int? = null,

    @Column
    val description: String? = null,

    @Column(name = "is_available", nullable = false)
    val isAvailable: Boolean = true,

    @Column(name = "has_projector", nullable = false)
    val hasProjector: Boolean = false
)
