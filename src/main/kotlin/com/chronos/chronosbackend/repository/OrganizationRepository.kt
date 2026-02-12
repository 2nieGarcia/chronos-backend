package com.chronos.chronosbackend.repository

import com.chronos.chronosbackend.model.Organization
import org.springframework.data.jpa.repository.JpaRepository

interface OrganizationRepository : JpaRepository<Organization, Int> {
    fun findByIsActiveTrue(): List<Organization>
}
