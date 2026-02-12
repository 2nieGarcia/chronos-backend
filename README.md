# CHRONOS - Room Reservation System

**Spring Boot 4.0.2 + Kotlin 2.2.21 + PostgreSQL (Supabase)**

## 🏗️ Architecture

```
Controller → Service → Repository → Entity
```

## ✅ Completed Features

### Phase 1-2: Building Management
- ✅ Building entity with basic CRUD
- ✅ PostgreSQL database via Supabase

### Phase 3: Room Scheduling & Conflict Detection
- ✅ **Room** - Classrooms, labs, auditoriums with capacity tracking
- ✅ **AcademicSchedule** - Recurring weekly class schedules
- ✅ **EventReservation** - One-time event bookings
- ✅ **ConflictService** - Two-tier conflict detection (academic + events)
- ✅ **RoomAvailabilityService** - Smart room search with filters

### Phase 4: Approval Workflow
- ✅ **ApprovalLog** - Audit trail for all status changes
- ✅ **ApprovalService** - State machine with role-based permissions
- ✅ Status flow: PENDING → ADVISOR_APPROVED → APPROVED
- ✅ Rejection/cancellation support

## 🗄️ Database Schema

### Buildings
- `building_id`, `name`, `location`

### Rooms
- `room_id`, `building_id` (FK), `room_number`, `room_type`, `capacity`, `floor`, `description`, `is_available`

### Academic Schedules
- `schedule_id`, `room_id` (FK), `course_code`, `course_name`, `day`, `start_time`, `end_time`, `semester`, `academic_year`, `instructor`

### Event Reservations
- `reservation_id`, `room_id` (FK), `organization_name`, `event_title`, `event_date`, `start_time`, `end_time`, `status`, `requested_by`, `requested_at`, `approved_by`, `approved_at`, `purpose`, `expected_attendees`, `document_url`

### Approval Logs
- `log_id`, `reservation_id` (FK), `previous_status`, `new_status`, `approved_by`, `approved_at`, `comments`, `timestampe`

## 🚀 Quick Start

### 1. Database Setup
Run `COMPLETE_SETUP.sql` in Supabase SQL Editor to populate sample data.

### 2. Environment Configuration
Create `.env` file:
```properties
DB_URL=jdbc:postgresql://aws-0-us-east-1.pooler.supabase.com:6543/postgres
DB_USERNAME=your_username
DB_PASSWORD=your_password
```

### 3. Run Application
```bash
# IntelliJ IDEA (recommended)
./gradlew bootRun

# Or directly
java -jar build/libs/chronos-backend-0.0.1-SNAPSHOT.jar
```

Application runs on: `http://localhost:8080`

## 📡 API Endpoints

### Room Availability
```http
GET /api/rooms/available?date=2026-02-15&startTime=10:00&endTime=12:00&capacity=30&buildingId=1&roomType=CLASSROOM
GET /api/rooms/{id}/availability?date=2026-02-15
```

### Event Reservations
```http
POST /api/reservations
POST /api/reservations/check-conflicts
```

### Approval Workflow
```http
PUT /api/approvals/{id}/approve
PUT /api/approvals/{id}/reject
PUT /api/approvals/{id}/cancel
GET /api/approvals/{id}/history
```

## 🔑 Approval State Machine

| From | To | Role Required |
|------|----|--------------| 
| PENDING | ADVISOR_APPROVED | Advisor |
| ADVISOR_APPROVED | APPROVED | Admin |
| Any | REJECTED | Advisor/Admin |
| Any | CANCELLED | Requestor/Admin |

## 📊 Sample Data

- **Buildings**: 4 (Engineering, Science, Business, Library)
- **Rooms**: 13 across all buildings
- **Academic Schedules**: 11 recurring classes
- **Event Reservations**: 6 sample events (various statuses)

## 🛠️ Tech Stack

- **Backend**: Spring Boot 4.0.2, Kotlin 2.2.21
- **Database**: PostgreSQL 17 (Supabase)
- **ORM**: JPA/Hibernate 7.2.1
- **Build**: Gradle 9.3.0
- **Runtime**: Java 21

## 📝 Next Steps

- [ ] Phase 5: Document Upload (Supabase Storage)
- [ ] Phase 6: React Frontend Dashboard
