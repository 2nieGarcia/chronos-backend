package com.chronos.chronosbackend.repository

import com.chronos.chronosbackend.model.Building
import org.springframework.data.jpa.repository.JpaRepository

interface BuildingRepository : JpaRepository<Building, Int>