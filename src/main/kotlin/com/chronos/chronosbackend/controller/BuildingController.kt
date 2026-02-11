package com.chronos.chronosbackend.controller

import com.chronos.chronosbackend.model.Building
import com.chronos.chronosbackend.repository.BuildingRepository
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/buildings")
class BuildingController(private val repository: BuildingRepository) {

    @GetMapping
    fun getAllBuildings(): List<Building> {
        return repository.findAll()
    }

    @PostMapping
    fun createBuilding(@RequestBody building: Building): Building {
        return repository.save(building)
    }
}