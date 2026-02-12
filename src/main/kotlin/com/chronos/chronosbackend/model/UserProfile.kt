package com.chronos.chronosbackend.model

import jakarta.persistence.*
import java.util.UUID

@Entity
@Table(name = "user_profiles")
data class UserProfile(
    @Id
    @Column(name = "user_id", columnDefinition = "uuid")
    val id: UUID = UUID.randomUUID(),

    @Column(name = "full_name")
    val fullName: String? = null,

    @Column(name = "org_id")
    val orgId: Int? = null,

    @Column
    val role: String? = null
)
