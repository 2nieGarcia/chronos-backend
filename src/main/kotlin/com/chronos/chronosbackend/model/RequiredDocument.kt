package com.chronos.chronosbackend.model

import jakarta.persistence.*
import java.time.LocalDateTime

@Entity
@Table(name = "required_documents")
data class RequiredDocument(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "doc_id")
    val id: Int? = null,

    @Column(name = "reservation_id")
    val reservationId: Int? = null,

    @Column(name = "document_type", nullable = false)
    val documentType: String = "",

    @Column(name = "file_url")
    val fileUrl: String? = null,

    @Column(name = "file_name")
    val fileName: String? = null,

    @Column(name = "file_size")
    val fileSize: Long? = null,

    @Column(name = "uploaded_at")
    val uploadedAt: LocalDateTime = LocalDateTime.now(),

    @Column(name = "is_verified", nullable = false)
    val isVerified: Boolean = false
)
