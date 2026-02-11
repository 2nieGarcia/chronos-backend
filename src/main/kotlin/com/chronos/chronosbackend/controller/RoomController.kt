package com.chronos.chronosbackend.controller

import com.chronos.chronosbackend.model.Room
import com.chronos.chronosbackend.model.RoomType
import com.chronos.chronosbackend.repository.RoomRepository
import com.chronos.chronosbackend.service.AvailableRoomInfo
import com.chronos.chronosbackend.service.RoomAvailabilityService
import com.chronos.chronosbackend.service.RoomAvailabilityStatus
import org.springframework.format.annotation.DateTimeFormat
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*
import java.time.LocalDate
import java.time.LocalTime

@RestController
@RequestMapping("/api/rooms")
class RoomController(
    private val roomRepository: RoomRepository,
    private val availabilityService: RoomAvailabilityService
) {

    @GetMapping
    fun getAllRooms(): List<Room> {
        return roomRepository.findAll()
    }

    @GetMapping("/{id}")
    fun getRoomById(@PathVariable id: Int): ResponseEntity<Room> {
        return roomRepository.findById(id)
            .map { ResponseEntity.ok(it) }
            .orElse(ResponseEntity.notFound().build())
    }

    @PostMapping
    fun createRoom(@RequestBody room: Room): Room {
        return roomRepository.save(room)
    }

    /**
     * The "Room Search API" - Find available rooms for a specific time slot
     * 
     * Example: GET /api/rooms/available?date=2026-02-17&startTime=14:00&endTime=16:00&minCapacity=50
     */
    @GetMapping("/available")
    fun findAvailableRooms(
        @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) date: LocalDate,
        @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.TIME) startTime: LocalTime,
        @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.TIME) endTime: LocalTime,
        @RequestParam(required = false) minCapacity: Int?,
        @RequestParam(required = false) roomType: RoomType?,
        @RequestParam(required = false) buildingId: Int?
    ): List<AvailableRoomInfo> {
        return availabilityService.findAvailableRooms(
            date = date,
            startTime = startTime,
            endTime = endTime,
            minCapacity = minCapacity,
            roomType = roomType,
            buildingId = buildingId
        )
    }

    /**
     * Check if a specific room is available
     * 
     * Example: GET /api/rooms/1/availability?date=2026-02-17&startTime=14:00&endTime=16:00
     */
    @GetMapping("/{id}/availability")
    fun checkRoomAvailability(
        @PathVariable id: Int,
        @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) date: LocalDate,
        @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.TIME) startTime: LocalTime,
        @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.TIME) endTime: LocalTime
    ): RoomAvailabilityStatus {
        return availabilityService.isRoomAvailable(id, date, startTime, endTime)
    }

    @GetMapping("/by-building/{buildingId}")
    fun getRoomsByBuilding(@PathVariable buildingId: Int): List<Room> {
        return roomRepository.findByBuildingIdAndIsAvailableTrue(buildingId)
    }

    @GetMapping("/by-type/{roomType}")
    fun getRoomsByType(@PathVariable roomType: RoomType): List<Room> {
        return roomRepository.findByRoomTypeAndIsAvailableTrue(roomType)
    }
}
