package com.chronos.chronosbackend.repository

import com.chronos.chronosbackend.model.RequiredDocument
import org.springframework.data.jpa.repository.JpaRepository

interface RequiredDocumentRepository : JpaRepository<RequiredDocument, Int> {
    fun findByReservationId(reservationId: Int): List<RequiredDocument>
}
