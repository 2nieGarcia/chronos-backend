package com.chronos.chronosbackend.repository

import com.chronos.chronosbackend.model.UserProfile
import org.springframework.data.jpa.repository.JpaRepository
import java.util.UUID

interface UserProfileRepository : JpaRepository<UserProfile, UUID>
