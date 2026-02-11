package com.chronos.chronosbackend.controller

import com.chronos.chronosbackend.model.ApprovalLog
import com.chronos.chronosbackend.model.ReservationStatus
import com.chronos.chronosbackend.service.ApprovalResult
import com.chronos.chronosbackend.service.ApprovalService
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/approvals")
class ApprovalController(
    private val approvalService: ApprovalService
) {

    /**
     * Approve a reservation (change status)
     */
    @PutMapping("/{reservationId}/approve")
    fun approveReservation(
        @PathVariable reservationId: Int,
        @RequestBody request: ApprovalRequest
    ): ResponseEntity<Any> {
        val result = approvalService.approveReservation(
            reservationId = reservationId,
            newStatus = request.newStatus,
            approvedBy = request.approvedBy,
            approverRole = request.approverRole,
            comments = request.comments
        )

        return if (result.success) {
            ResponseEntity.ok(result)
        } else {
            ResponseEntity.status(HttpStatus.BAD_REQUEST).body(
                mapOf("error" to result.message)
            )
        }
    }

    /**
     * Reject a reservation
     */
    @PutMapping("/{reservationId}/reject")
    fun rejectReservation(
        @PathVariable reservationId: Int,
        @RequestBody request: RejectRequest
    ): ResponseEntity<Any> {
        val result = approvalService.rejectReservation(
            reservationId = reservationId,
            rejectedBy = request.rejectedBy,
            rejectorRole = request.rejectorRole,
            reason = request.reason
        )

        return if (result.success) {
            ResponseEntity.ok(result)
        } else {
            ResponseEntity.status(HttpStatus.BAD_REQUEST).body(
                mapOf("error" to result.message)
            )
        }
    }

    /**
     * Cancel a reservation (student cancels their own)
     */
    @PutMapping("/{reservationId}/cancel")
    fun cancelReservation(
        @PathVariable reservationId: Int,
        @RequestBody request: CancelRequest
    ): ResponseEntity<Any> {
        val result = approvalService.cancelReservation(
            reservationId = reservationId,
            cancelledBy = request.cancelledBy
        )

        return if (result.success) {
            ResponseEntity.ok(result)
        } else {
            ResponseEntity.status(HttpStatus.BAD_REQUEST).body(
                mapOf("error" to result.message)
            )
        }
    }

    /**
     * Get approval history for a reservation
     */
    @GetMapping("/{reservationId}/history")
    fun getApprovalHistory(@PathVariable reservationId: Int): List<ApprovalLog> {
        return approvalService.getApprovalHistory(reservationId)
    }
}

// Request DTOs
data class ApprovalRequest(
    val newStatus: ReservationStatus,
    val approvedBy: String,
    val approverRole: String,
    val comments: String? = null
)

data class RejectRequest(
    val rejectedBy: String,
    val rejectorRole: String,
    val reason: String
)

data class CancelRequest(
    val cancelledBy: String
)
