package com.chronos.chronosbackend.model

import jakarta.persistence.*

@Entity
@Table(name = "organizations")
data class Organization(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "org_id")
    val id: Int? = null,

    @Column(nullable = false)
    val name: String = "",

    @Column
    val description: String? = null,

    @Column(name = "contact_email")
    val contactEmail: String? = null,

    @Column
    val department: String? = null,

    @Column(name = "is_active")
    val isActive: Boolean? = true,

    @Column(name = "advisor_name")
    val advisorName: String? = null,

    @Column(name = "member_count")
    val memberCount: Int? = null
)
