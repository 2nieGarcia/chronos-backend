package com.chronos.chronosbackend.repository

import com.chronos.chronosbackend.model.ApprovalLog
import org.springframework.data.jpa.repository.JpaRepository

interface ApprovalLogRepository : JpaRepository<ApprovalLog, Int> {
    
    fun findByReservationIdOrderByApprovedAtDesc(reservationId: Int): List<ApprovalLog>
    
    fun findByApprovedBy(approvedBy: String): List<ApprovalLog>
}
