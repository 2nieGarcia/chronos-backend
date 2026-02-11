package com.chronos.chronosbackend.repository

import com.chronos.chronosbackend.model.Room
import com.chronos.chronosbackend.model.RoomType
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query

interface RoomRepository : JpaRepository<Room, Int> {
    
    fun findByIsAvailableTrue(): List<Room>
    
    fun findByBuildingIdAndIsAvailableTrue(buildingId: Int): List<Room>
    
    fun findByRoomTypeAndIsAvailableTrue(roomType: RoomType): List<Room>
    
    fun findByCapacityGreaterThanEqualAndIsAvailableTrue(minCapacity: Int): List<Room>
    
    @Query("""
        SELECT r FROM Room r 
        WHERE r.building.id = :buildingId 
        AND r.roomType = :roomType 
        AND r.isAvailable = true
    """)
    fun findAvailableRoomsByBuildingAndType(buildingId: Int, roomType: RoomType): List<Room>
}
