package com.chronos.chronosbackend.service

import com.chronos.chronosbackend.model.Room
import com.chronos.chronosbackend.model.RoomType
import com.chronos.chronosbackend.repository.RoomRepository
import org.springframework.stereotype.Service
import java.time.LocalDate
import java.time.LocalTime

@Service
class RoomAvailabilityService(
    private val roomRepository: RoomRepository,
    private val conflictService: ConflictService
) {

    /**
     * Find all rooms that are free at a specific date and time
     * This is the "Which rooms are free next Monday at 2 PM?" API
     */
    fun findAvailableRooms(
        date: LocalDate,
        startTime: LocalTime,
        endTime: LocalTime,
        minCapacity: Int? = null,
        roomType: RoomType? = null,
        buildingId: Int? = null
    ): List<AvailableRoomInfo> {
        // Get candidate rooms based on filters
        val candidateRooms = getCandidateRooms(minCapacity, roomType, buildingId)

        // Filter out rooms that have conflicts
        return candidateRooms
            .filter { room -> 
                !conflictService.hasConflict(
                    roomId = room.id!!,
                    requestedDate = date,
                    startTime = startTime,
                    endTime = endTime
                )
            }
            .map { room ->
                AvailableRoomInfo(
                    roomId = room.id!!,
                    roomNumber = room.roomNumber,
                    buildingName = room.building.name,
                    roomType = room.roomType,
                    capacity = room.capacity,
                    floor = room.floor,
                    description = room.description
                )
            }
    }

    /**
     * Check if a specific room is available
     */
    fun isRoomAvailable(
        roomId: Int,
        date: LocalDate,
        startTime: LocalTime,
        endTime: LocalTime
    ): RoomAvailabilityStatus {
        val room = roomRepository.findById(roomId).orElse(null)
            ?: return RoomAvailabilityStatus(
                isAvailable = false,
                reason = "Room not found"
            )

        if (!room.isAvailable) {
            return RoomAvailabilityStatus(
                isAvailable = false,
                reason = "Room is marked as unavailable"
            )
        }

        val conflictResult = conflictService.findConflicts(roomId, date, startTime, endTime)

        return if (conflictResult.hasConflict) {
            RoomAvailabilityStatus(
                isAvailable = false,
                reason = "Room has conflicts",
                conflicts = conflictResult.academicConflicts + conflictResult.reservationConflicts
            )
        } else {
            RoomAvailabilityStatus(isAvailable = true)
        }
    }

    private fun getCandidateRooms(
        minCapacity: Int?,
        roomType: RoomType?,
        buildingId: Int?
    ): List<Room> {
        return when {
            buildingId != null && roomType != null -> 
                roomRepository.findAvailableRoomsByBuildingAndType(buildingId, roomType)
            
            buildingId != null -> 
                roomRepository.findByBuildingIdAndIsAvailableTrue(buildingId)
            
            roomType != null -> 
                roomRepository.findByRoomTypeAndIsAvailableTrue(roomType)
            
            minCapacity != null -> 
                roomRepository.findByCapacityGreaterThanEqualAndIsAvailableTrue(minCapacity)
            
            else -> 
                roomRepository.findByIsAvailableTrue()
        }
    }
}

data class AvailableRoomInfo(
    val roomId: Int,
    val roomNumber: String,
    val buildingName: String,
    val roomType: RoomType,
    val capacity: Int?,
    val floor: Int?,
    val description: String?
)

data class RoomAvailabilityStatus(
    val isAvailable: Boolean,
    val reason: String? = null,
    val conflicts: List<String> = emptyList()
)
