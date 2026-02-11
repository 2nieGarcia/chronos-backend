package com.chronos.chronosbackend.model

import jakarta.persistence.*

@Entity
@Table(name = "buildings")
data class Building(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "building_id")
    // Change this from 'Long?' to 'Int?'
    val id: Int? = null,

    @Column(nullable = false)
    val name: String = "",

    @Column
    val location: String? = null
)