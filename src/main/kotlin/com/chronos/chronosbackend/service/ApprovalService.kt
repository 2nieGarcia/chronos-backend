package com.chronos.chronosbackend.service

import com.chronos.chronosbackend.model.ApprovalLog
import com.chronos.chronosbackend.model.EventReservation
import com.chronos.chronosbackend.model.ReservationStatus
import com.chronos.chronosbackend.repository.ApprovalLogRepository
import com.chronos.chronosbackend.repository.EventReservationRepository
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.LocalDateTime

@Service
class ApprovalService(
    private val reservationRepository: EventReservationRepository,
    private val approvalLogRepository: ApprovalLogRepository
) {

    /**
     * Approve a reservation (change status with validation)
     */
    @Transactional
    fun approveReservation(
        reservationId: Int,
        newStatus: ReservationStatus,
        approvedBy: String,
        approverRole: String,
        comments: String? = null
    ): ApprovalResult {
        val reservation = reservationRepository.findById(reservationId).orElseThrow {
            IllegalArgumentException("Reservation not found: $reservationId")
        }

        // Validate status transition
        val validationResult = validateStatusTransition(reservation.status, newStatus, approverRole)
        if (!validationResult.isValid) {
            return ApprovalResult(
                success = false,
                message = validationResult.errorMessage!!,
                reservation = null
            )
        }

        val previousStatus = reservation.status

        // Update reservation
        val updatedReservation = reservation.copy(
            status = newStatus,
            approvedBy = if (newStatus == ReservationStatus.APPROVED) approvedBy else reservation.approvedBy,
            approvedAt = if (newStatus == ReservationStatus.APPROVED) LocalDateTime.now() else reservation.approvedAt
        )

        val saved = reservationRepository.save(updatedReservation)

        // Create approval log
        val log = ApprovalLog(
            reservation = saved,
            previousStatus = previousStatus,
            newStatus = newStatus,
            approvedBy = approvedBy,
            approvedAt = LocalDateTime.now(),
            comments = comments,
            approverRole = approverRole
        )
        approvalLogRepository.save(log)

        return ApprovalResult(
            success = true,
            message = "Status changed from $previousStatus to $newStatus",
            reservation = saved
        )
    }

    /**
     * Reject a reservation
     */
    @Transactional
    fun rejectReservation(
        reservationId: Int,
        rejectedBy: String,
        rejectorRole: String,
        reason: String
    ): ApprovalResult {
        return approveReservation(
            reservationId = reservationId,
            newStatus = ReservationStatus.REJECTED,
            approvedBy = rejectedBy,
            approverRole = rejectorRole,
            comments = "REJECTED: $reason"
        )
    }

    /**
     * Cancel a reservation (student can cancel their own)
     */
    @Transactional
    fun cancelReservation(
        reservationId: Int,
        cancelledBy: String
    ): ApprovalResult {
        return approveReservation(
            reservationId = reservationId,
            newStatus = ReservationStatus.CANCELLED,
            approvedBy = cancelledBy,
            approverRole = "STUDENT",
            comments = "Cancelled by requester"
        )
    }

    /**
     * Get approval history for a reservation
     */
    fun getApprovalHistory(reservationId: Int): List<ApprovalLog> {
        return approvalLogRepository.findByReservationIdOrderByApprovedAtDesc(reservationId)
    }

    /**
     * Validate if a status transition is allowed
     */
    private fun validateStatusTransition(
        currentStatus: ReservationStatus,
        newStatus: ReservationStatus,
        approverRole: String
    ): ValidationResult {
        // Define valid transitions
        val validTransitions = mapOf(
            ReservationStatus.PENDING to setOf(
                ReservationStatus.ADVISOR_APPROVED,
                ReservationStatus.REJECTED,
                ReservationStatus.CANCELLED
            ),
            ReservationStatus.ADVISOR_APPROVED to setOf(
                ReservationStatus.APPROVED,
                ReservationStatus.REJECTED
            ),
            ReservationStatus.APPROVED to setOf(
                ReservationStatus.CANCELLED
            )
        )

        // Check if transition is valid
        if (newStatus !in validTransitions[currentStatus].orEmpty()) {
            return ValidationResult(
                isValid = false,
                errorMessage = "Invalid status transition: $currentStatus → $newStatus"
            )
        }

        // Check role permissions
        val hasPermission = when (newStatus) {
            ReservationStatus.ADVISOR_APPROVED -> approverRole in setOf("ADVISOR", "ADMIN")
            ReservationStatus.APPROVED -> approverRole == "ADMIN"
            ReservationStatus.REJECTED -> approverRole in setOf("ADVISOR", "ADMIN")
            ReservationStatus.CANCELLED -> approverRole in setOf("STUDENT", "ADMIN")
            else -> false
        }

        if (!hasPermission) {
            return ValidationResult(
                isValid = false,
                errorMessage = "Role '$approverRole' cannot transition to $newStatus"
            )
        }

        return ValidationResult(isValid = true)
    }
}

data class ApprovalResult(
    val success: Boolean,
    val message: String,
    val reservation: EventReservation?
)

data class ValidationResult(
    val isValid: Boolean,
    val errorMessage: String? = null
)
