-- ============================================================================
-- Academic Space & Organization Management System - Comprehensive Seed Data
-- Ready-to-run PostgreSQL seed script (idempotent via ON CONFLICT on PKs)
-- ============================================================================

BEGIN;

-- ============================================================================
-- 1) BUILDINGS
-- ============================================================================
INSERT INTO buildings (building_id, name, location)
VALUES
  (1, 'Engineering Building', 'North Campus - Tech Avenue'),
  (2, 'Business Center', 'Central Campus - Finance Drive'),
  (3, 'Main Academic Hall', 'Central Campus - University Circle'),
  (4, 'Innovation Hub', 'East Campus - Research Park')
ON CONFLICT (building_id) DO UPDATE SET
  name = EXCLUDED.name,
  location = EXCLUDED.location;

-- ============================================================================
-- 2) ORGANIZATIONS
-- ============================================================================
INSERT INTO organizations (
  org_id, name, description, contact_email, department, is_active, advisor_name, member_count
)
VALUES
  (1, 'Computer Science Society', 'Student organization for software engineering, AI, and systems workshops.', 'css@university.edu', 'Computer Science', TRUE, 'Dr. Elena Ramirez', 64),
  (2, 'Engineering Guild', 'Interdisciplinary engineering community focused on innovation projects and competitions.', 'guild@university.edu', 'Engineering', TRUE, 'Prof. Marcus Tan', 58),
  (3, 'Business Leaders Association', 'Develops leadership, entrepreneurship, and industry-readiness among business students.', 'bla@university.edu', 'Business Administration', TRUE, 'Dr. Priya Sethi', 46),
  (4, 'Arts & Media Club', 'Creative organization for multimedia production, performing arts, and campus media.', 'amc@university.edu', 'Arts & Communication', TRUE, 'Dr. Elena Ramirez', 39),
  (5, 'Robotics Club', 'Hands-on robotics, embedded systems, and autonomous platforms club.', 'robotics@university.edu', 'Computer Engineering', TRUE, 'Prof. Marcus Tan', 52)
ON CONFLICT (org_id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  contact_email = EXCLUDED.contact_email,
  department = EXCLUDED.department,
  is_active = EXCLUDED.is_active,
  advisor_name = EXCLUDED.advisor_name,
  member_count = EXCLUDED.member_count;

-- ============================================================================
-- 3) USER PROFILES
-- Supabase-linked mode: uses existing auth users (FK-safe)
-- ============================================================================
INSERT INTO user_profiles (user_id, full_name, org_id, role)
VALUES
  ('7da07ce5-d2a4-4eb1-aa7c-ef7e97139528'::uuid, 'Faculty Advisor', 1, 'FACULTY_ADVISOR'),
  ('8fbcea67-7419-4694-b1ea-6dc70038eee8'::uuid, 'System Admin', NULL, 'ADMIN'),
  ('a7d9a579-9edf-4a1a-a833-60a6831c4837'::uuid, 'Student Representative', 1, 'STUDENT')
ON CONFLICT (user_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  org_id = EXCLUDED.org_id,
  role = EXCLUDED.role;

-- ============================================================================
-- 4) ROOMS (20 rooms total, mixed types/capacity/features)
-- ============================================================================
INSERT INTO rooms (
  room_id, building_id, room_number, room_type, capacity, floor, description, is_available, has_projector
)
VALUES
  (101, 1, 'E-101', 'LECTURE_HALL', 140, 1, 'Engineering flagship lecture hall', TRUE, TRUE),
  (102, 1, 'E-102', 'CLASSROOM', 48, 1, 'Flexible classroom for large sections', TRUE, TRUE),
  (103, 1, 'E-201', 'LABORATORY', 36, 2, 'Embedded systems lab', TRUE, TRUE),
  (104, 1, 'E-202', 'LABORATORY', 34, 2, 'Networks and cybersecurity lab', TRUE, TRUE),
  (105, 1, 'E-301', 'CONFERENCE_ROOM', 22, 3, 'Faculty-advisor consultation room', TRUE, TRUE),

  (106, 2, 'B-110', 'LECTURE_HALL', 120, 1, 'Business plenary hall', TRUE, TRUE),
  (107, 2, 'B-102', 'CLASSROOM', 45, 1, 'Case-study classroom', TRUE, TRUE),
  (108, 2, 'B-210', 'CONFERENCE_ROOM', 20, 2, 'Startup pitch room', TRUE, TRUE),
  (109, 2, 'B-202', 'CLASSROOM', 38, 2, 'Discussion-based classroom', TRUE, FALSE),
  (110, 2, 'B-310', 'AUDITORIUM', 260, 3, 'Business center auditorium', TRUE, TRUE),

  (111, 3, 'M-101', 'CLASSROOM', 40, 1, 'General education classroom', TRUE, FALSE),
  (112, 3, 'M-102', 'LECTURE_HALL', 130, 1, 'Main hall lecture theatre', TRUE, TRUE),
  (113, 3, 'M-201', 'CLASSROOM', 36, 2, 'Seminar classroom', TRUE, TRUE),
  (114, 3, 'M-202', 'CONFERENCE_ROOM', 18, 2, 'Student org strategy room', TRUE, TRUE),
  (115, 3, 'M-301', 'STUDY_ROOM', 16, 3, 'Collaborative study room', TRUE, FALSE),

  (116, 4, 'I-101', 'LABORATORY', 42, 1, 'AI and robotics integration lab', TRUE, TRUE),
  (117, 4, 'I-102', 'CLASSROOM', 35, 1, 'Innovation workshop room', TRUE, TRUE),
  (118, 4, 'I-201', 'CONFERENCE_ROOM', 24, 2, 'Industry mentoring room', TRUE, TRUE),
  (119, 4, 'I-202', 'AUDITORIUM', 300, 2, 'Innovation keynote auditorium', TRUE, TRUE),
  (120, 4, 'I-301', 'OTHER', 28, 3, 'Prototype testing room', TRUE, FALSE)
ON CONFLICT (room_id) DO UPDATE SET
  building_id = EXCLUDED.building_id,
  room_number = EXCLUDED.room_number,
  room_type = EXCLUDED.room_type,
  capacity = EXCLUDED.capacity,
  floor = EXCLUDED.floor,
  description = EXCLUDED.description,
  is_available = EXCLUDED.is_available,
  has_projector = EXCLUDED.has_projector;

-- ============================================================================
-- 5) ACADEMIC SCHEDULES
-- Busy Mon-Fri timetable with intentional overlaps in key rooms for conflict tests
-- ============================================================================
INSERT INTO academic_schedules (
  schedule_id, room_id, course_code, course_name, day_of_week, "day", start_time, end_time, semester, academic_year, instructor
)
SELECT
  v.schedule_id,
  v.room_id,
  v.course_code,
  v.course_name,
  v.day_of_week::day_of_week,
  v.day_of_week::day_of_week,
  v.start_time::time,
  v.end_time::time,
  v.semester,
  v.academic_year,
  v.instructor
FROM (
  VALUES
    (2001, 101, 'CS101', 'Introduction to Programming', 'MONDAY',    '08:00', '10:00', '2nd Semester', '2025-2026', 'Dr. Elena Ramirez'),
    (2002, 101, 'CS201', 'Data Structures',            'MONDAY',    '10:00', '12:00', '2nd Semester', '2025-2026', 'Dr. Elena Ramirez'),
    (2003, 101, 'CS305', 'Operating Systems',          'WEDNESDAY', '09:00', '11:00', '2nd Semester', '2025-2026', 'Prof. Marcus Tan'),

    (2004, 102, 'MATH221', 'Discrete Mathematics',     'TUESDAY',   '09:00', '11:00', '2nd Semester', '2025-2026', 'Prof. Julian Ong'),
    (2005, 102, 'CS220', 'Database Systems',           'THURSDAY',  '13:00', '15:00', '2nd Semester', '2025-2026', 'Dr. Priya Sethi'),
    (2006, 102, 'CS220-L', 'Database Systems Lab',     'THURSDAY',  '14:00', '16:00', '2nd Semester', '2025-2026', 'Dr. Priya Sethi'),

    (2007, 103, 'ECE210', 'Digital Logic Lab',         'MONDAY',    '13:00', '15:00', '2nd Semester', '2025-2026', 'Prof. Marcus Tan'),
    (2008, 103, 'ECE315', 'Microcontrollers',          'WEDNESDAY', '13:00', '15:00', '2nd Semester', '2025-2026', 'Prof. Marcus Tan'),

    (2009, 104, 'IT330', 'Network Security',           'TUESDAY',   '13:00', '15:00', '2nd Semester', '2025-2026', 'Atty. Ramon Lee'),
    (2010, 104, 'IT340', 'Cloud Infrastructure',       'FRIDAY',    '10:00', '12:00', '2nd Semester', '2025-2026', 'Atty. Ramon Lee'),

    (2011, 106, 'BUS101', 'Principles of Management',  'MONDAY',    '07:30', '09:00', '2nd Semester', '2025-2026', 'Dr. Priya Sethi'),
    (2012, 106, 'BUS205', 'Marketing Analytics',       'WEDNESDAY', '14:00', '16:00', '2nd Semester', '2025-2026', 'Dr. Priya Sethi'),

    (2013, 107, 'BUS220', 'Business Communication',    'TUESDAY',   '10:00', '12:00', '2nd Semester', '2025-2026', 'Prof. Elaine Co'),
    (2014, 107, 'BUS315', 'Corporate Finance',         'THURSDAY',  '09:00', '11:00', '2nd Semester', '2025-2026', 'Prof. Elaine Co'),

    (2015, 110, 'GEN400', 'University Assembly',       'FRIDAY',    '15:00', '17:00', '2nd Semester', '2025-2026', 'Office of the Provost'),

    (2016, 112, 'ENG101', 'Academic Writing',          'MONDAY',    '08:30', '10:30', '2nd Semester', '2025-2026', 'Prof. Leah Navarro'),
    (2017, 112, 'HIST210', 'Modern Asian History',     'WEDNESDAY', '10:00', '12:00', '2nd Semester', '2025-2026', 'Prof. Leah Navarro'),

    (2018, 113, 'SOC110', 'Introduction to Sociology', 'TUESDAY',   '08:00', '10:00', '2nd Semester', '2025-2026', 'Dr. Monica Teo'),
    (2019, 113, 'PHIL201', 'Ethics and Society',       'THURSDAY',  '10:30', '12:00', '2nd Semester', '2025-2026', 'Dr. Monica Teo'),

    (2020, 116, 'ROB201', 'Mobile Robotics',           'MONDAY',    '10:00', '12:00', '2nd Semester', '2025-2026', 'Prof. Marcus Tan'),
    (2021, 116, 'AI310', 'Applied Machine Learning',   'WEDNESDAY', '15:00', '17:00', '2nd Semester', '2025-2026', 'Dr. Elena Ramirez'),

    (2022, 117, 'ENT200', 'Design Thinking',           'TUESDAY',   '14:00', '16:00', '2nd Semester', '2025-2026', 'Dr. Priya Sethi'),
    (2023, 117, 'ENT205', 'Startup Validation',        'FRIDAY',    '09:00', '11:00', '2nd Semester', '2025-2026', 'Dr. Priya Sethi'),

    (2024, 119, 'CAP500', 'Capstone Colloquium',       'THURSDAY',  '16:00', '18:00', '2nd Semester', '2025-2026', 'Capstone Committee')
) AS v(
  schedule_id, room_id, course_code, course_name, day_of_week, start_time, end_time, semester, academic_year, instructor
)
ON CONFLICT (schedule_id) DO UPDATE SET
  room_id = EXCLUDED.room_id,
  course_code = EXCLUDED.course_code,
  course_name = EXCLUDED.course_name,
  day_of_week = EXCLUDED.day_of_week,
  "day" = EXCLUDED."day",
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  semester = EXCLUDED.semester,
  academic_year = EXCLUDED.academic_year,
  instructor = EXCLUDED.instructor;

-- ============================================================================
-- 6) EVENT RESERVATIONS (20 total)
-- Required distribution:
--   5 PENDING, 4 ADVISOR_APPROVED, 6 APPROVED, 3 REJECTED, 2 CANCELLED
-- ============================================================================
INSERT INTO event_reservations (
  reservation_id, room_id, organization_name, event_title, title,
  event_date, start_time, end_time, status,
  requested_by, requested_at, approved_by, approved_at,
  purpose, expected_attendees, document_url
)
VALUES
  -- PENDING (5)
  (1001, 101, 'Computer Science Society', 'Python Bootcamp Kickoff', 'Python Bootcamp Kickoff', '2026-03-09', '10:30', '12:30', 'PENDING', '30000000-0000-0000-0000-000000000001', '2026-02-03 09:15:00', NULL, NULL, 'Bootcamp orientation and participant onboarding', 110, NULL), -- conflicts with MONDAY class
  (1002, 107, 'Business Leaders Association', 'Case Competition Prep', 'Case Competition Prep', '2026-03-12', '14:00', '16:00', 'PENDING', '30000000-0000-0000-0000-000000000005', '2026-02-04 10:05:00', NULL, NULL, 'Preparation for interschool case competition', 42, NULL),
  (1003, 110, 'Engineering Guild', 'Industry Forum Overflow Session', 'Industry Forum Overflow Session', '2026-03-20', '15:00', '17:00', 'PENDING', '30000000-0000-0000-0000-000000000004', '2026-02-05 11:10:00', NULL, NULL, 'Forum continuation due to high registration', 210, NULL), -- overlaps with approved reservation 1012
  (1004, 114, 'Arts & Media Club', 'Podcast Production Clinic', 'Podcast Production Clinic', '2026-03-18', '13:00', '15:00', 'PENDING', '30000000-0000-0000-0000-000000000007', '2026-02-06 15:20:00', NULL, NULL, 'Audio production workshop with invited alumni', 16, NULL),
  (1005, 116, 'Robotics Club', 'Drone Safety Training', 'Drone Safety Training', '2026-03-16', '10:30', '12:00', 'PENDING', '30000000-0000-0000-0000-000000000009', '2026-02-07 08:45:00', NULL, NULL, 'Operational safety before field testing', 38, NULL), -- overlaps with MONDAY class

  -- ADVISOR_APPROVED (4)
  (1006, 102, 'Computer Science Society', 'Open Source Sprint', 'Open Source Sprint', '2026-03-26', '16:00', '18:00', 'ADVISOR_APPROVED', '30000000-0000-0000-0000-000000000002', '2026-02-01 13:00:00', '10000000-0000-0000-0000-000000000001', '2026-02-02 10:15:00', 'Collaborative sprint for student OSS contributions', 45, 'https://storage.university.edu/docs/1006/event-permit.pdf'),
  (1007, 108, 'Business Leaders Association', 'Startup Pitch Dry Run', 'Startup Pitch Dry Run', '2026-03-21', '09:00', '11:00', 'ADVISOR_APPROVED', '30000000-0000-0000-0000-000000000006', '2026-02-02 11:30:00', '10000000-0000-0000-0000-000000000003', '2026-02-03 09:40:00', 'Mock investor panel and pitch refinement', 20, 'https://storage.university.edu/docs/1007/facility-request.pdf'),
  (1008, 117, 'Engineering Guild', 'CAD Crash Course', 'CAD Crash Course', '2026-03-24', '13:00', '15:00', 'ADVISOR_APPROVED', '30000000-0000-0000-0000-000000000003', '2026-02-03 14:25:00', '10000000-0000-0000-0000-000000000002', '2026-02-04 08:55:00', 'Intro workshop for first-year engineering students', 32, 'https://storage.university.edu/docs/1008/security-clearance.pdf'),
  (1009, 115, 'Arts & Media Club', 'Visual Storytelling Session', 'Visual Storytelling Session', '2026-03-27', '14:00', '16:00', 'ADVISOR_APPROVED', '30000000-0000-0000-0000-000000000008', '2026-02-05 09:15:00', '10000000-0000-0000-0000-000000000001', '2026-02-06 11:50:00', 'Creative workshop for documentary pre-production', 14, 'https://storage.university.edu/docs/1009/waiver.pdf'),

  -- APPROVED (6)
  (1010, 112, 'Computer Science Society', 'AI in Education Summit', 'AI in Education Summit', '2026-03-28', '09:00', '12:00', 'APPROVED', '30000000-0000-0000-0000-000000000001', '2026-01-20 10:00:00', '20000000-0000-0000-0000-000000000001', '2026-01-22 09:30:00', 'Regional summit featuring student and faculty speakers', 125, 'https://storage.university.edu/docs/1010/permit-bundle.zip'),
  (1011, 103, 'Robotics Club', 'Autonomous Rover Workshop', 'Autonomous Rover Workshop', '2026-03-30', '13:00', '16:00', 'APPROVED', '30000000-0000-0000-0000-000000000010', '2026-01-22 15:45:00', '20000000-0000-0000-0000-000000000002', '2026-01-24 10:05:00', 'Hands-on build and control systems session', 34, 'https://storage.university.edu/docs/1011/insurance.pdf'),
  (1012, 110, 'Engineering Guild', 'Industry Forum 2026', 'Industry Forum 2026', '2026-03-20', '13:00', '16:00', 'APPROVED', '30000000-0000-0000-0000-000000000004', '2026-01-18 08:20:00', '20000000-0000-0000-0000-000000000001', '2026-01-20 13:10:00', 'Industry leaders panel and recruitment networking', 240, 'https://storage.university.edu/docs/1012/event-permit.pdf'), -- contributes to fully-booked scenario
  (1013, 106, 'Business Leaders Association', 'Leadership Bootcamp', 'Leadership Bootcamp', '2026-04-02', '08:30', '12:00', 'APPROVED', '30000000-0000-0000-0000-000000000005', '2026-01-25 11:00:00', '20000000-0000-0000-0000-000000000002', '2026-01-27 16:00:00', 'Leadership intensive for org officers', 95, 'https://storage.university.edu/docs/1013/safety-waiver.pdf'),
  (1014, 119, 'Arts & Media Club', 'Campus Film Showcase', 'Campus Film Showcase', '2026-04-05', '17:00', '20:00', 'APPROVED', '30000000-0000-0000-0000-000000000007', '2026-01-26 13:35:00', '20000000-0000-0000-0000-000000000001', '2026-01-29 09:45:00', 'Public screening of student-produced short films', 280, 'https://storage.university.edu/docs/1014/security-clearance.pdf'),
  (1015, 118, 'Robotics Club', 'Industry Mentorship Mixer', 'Industry Mentorship Mixer', '2026-04-08', '15:00', '17:00', 'APPROVED', '30000000-0000-0000-0000-000000000009', '2026-01-28 10:10:00', '20000000-0000-0000-0000-000000000002', '2026-01-30 14:20:00', 'Networking event with invited industry mentors', 22, 'https://storage.university.edu/docs/1015/facility-request.pdf'),

  -- REJECTED (3)
  (1016, 104, 'Computer Science Society', 'Cybersecurity Night Camp', 'Cybersecurity Night Camp', '2026-03-17', '18:00', '21:00', 'REJECTED', '30000000-0000-0000-0000-000000000002', '2026-02-02 16:40:00', '10000000-0000-0000-0000-000000000001', '2026-02-04 12:20:00', 'Evening hands-on red-team and blue-team activities', 30, NULL), -- missing required documents
  (1017, 107, 'Business Leaders Association', 'Late Filing Entrepreneurship Talk', 'Late Filing Entrepreneurship Talk', '2026-03-19', '17:00', '19:00', 'REJECTED', '30000000-0000-0000-0000-000000000006', '2026-02-03 12:10:00', '20000000-0000-0000-0000-000000000001', '2026-02-06 10:40:00', 'Guest talk with incomplete compliance requirements', 40, NULL), -- advisor-approved then rejected by admin
  (1018, 120, 'Arts & Media Club', 'Studio Lock-in Session', 'Studio Lock-in Session', '2026-03-22', '18:00', '22:00', 'REJECTED', '30000000-0000-0000-0000-000000000008', '2026-02-04 09:25:00', '10000000-0000-0000-0000-000000000001', '2026-02-05 15:00:00', 'Extended recording session requiring security permit', 24, NULL), -- rejected due to missing clearances

  -- CANCELLED (2)
  (1019, 114, 'Computer Science Society', 'Algorithms Review Session', 'Algorithms Review Session', '2026-03-25', '10:00', '12:00', 'CANCELLED', '30000000-0000-0000-0000-000000000001', '2026-02-05 08:30:00', NULL, NULL, 'Peer-led review before midterms', 18, NULL),
  (1020, 113, 'Engineering Guild', 'Prototype Design Clinic', 'Prototype Design Clinic', '2026-03-31', '14:00', '16:00', 'CANCELLED', '30000000-0000-0000-0000-000000000003', '2026-02-06 10:45:00', NULL, NULL, 'Cancelled due to resource reallocation', 30, NULL)
ON CONFLICT (reservation_id) DO UPDATE SET
  room_id = EXCLUDED.room_id,
  organization_name = EXCLUDED.organization_name,
  event_title = EXCLUDED.event_title,
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  status = EXCLUDED.status,
  requested_by = EXCLUDED.requested_by,
  requested_at = EXCLUDED.requested_at,
  approved_by = EXCLUDED.approved_by,
  approved_at = EXCLUDED.approved_at,
  purpose = EXCLUDED.purpose,
  expected_attendees = EXCLUDED.expected_attendees,
  document_url = EXCLUDED.document_url;

-- Optional compatibility block:
-- If your event_reservations table has org_id/requester_id columns, populate them.
CREATE TEMP TABLE tmp_reservation_actor_map (
  reservation_id INT PRIMARY KEY,
  org_id INT NOT NULL,
  requester_id UUID NOT NULL
) ON COMMIT DROP;

INSERT INTO tmp_reservation_actor_map (reservation_id, org_id, requester_id)
VALUES
  (1001, 1, 'a7d9a579-9edf-4a1a-a833-60a6831c4837'::uuid),
  (1002, 3, 'a7d9a579-9edf-4a1a-a833-60a6831c4837'::uuid),
  (1003, 2, 'a7d9a579-9edf-4a1a-a833-60a6831c4837'::uuid),
  (1004, 4, 'a7d9a579-9edf-4a1a-a833-60a6831c4837'::uuid),
  (1005, 5, 'a7d9a579-9edf-4a1a-a833-60a6831c4837'::uuid),
  (1006, 1, 'a7d9a579-9edf-4a1a-a833-60a6831c4837'::uuid),
  (1007, 3, 'a7d9a579-9edf-4a1a-a833-60a6831c4837'::uuid),
  (1008, 2, 'a7d9a579-9edf-4a1a-a833-60a6831c4837'::uuid),
  (1009, 4, 'a7d9a579-9edf-4a1a-a833-60a6831c4837'::uuid),
  (1010, 1, 'a7d9a579-9edf-4a1a-a833-60a6831c4837'::uuid),
  (1011, 5, 'a7d9a579-9edf-4a1a-a833-60a6831c4837'::uuid),
  (1012, 2, 'a7d9a579-9edf-4a1a-a833-60a6831c4837'::uuid),
  (1013, 3, 'a7d9a579-9edf-4a1a-a833-60a6831c4837'::uuid),
  (1014, 4, 'a7d9a579-9edf-4a1a-a833-60a6831c4837'::uuid),
  (1015, 5, 'a7d9a579-9edf-4a1a-a833-60a6831c4837'::uuid),
  (1016, 1, 'a7d9a579-9edf-4a1a-a833-60a6831c4837'::uuid),
  (1017, 3, 'a7d9a579-9edf-4a1a-a833-60a6831c4837'::uuid),
  (1018, 4, 'a7d9a579-9edf-4a1a-a833-60a6831c4837'::uuid),
  (1019, 1, 'a7d9a579-9edf-4a1a-a833-60a6831c4837'::uuid),
  (1020, 2, 'a7d9a579-9edf-4a1a-a833-60a6831c4837'::uuid);

DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_name = 'event_reservations'
      AND column_name = 'org_id'
  ) THEN
    EXECUTE '
      UPDATE event_reservations er
      SET org_id = m.org_id
      FROM tmp_reservation_actor_map m
      WHERE er.reservation_id = m.reservation_id
    ';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_name = 'event_reservations'
      AND column_name = 'requester_id'
  ) THEN
    EXECUTE '
      UPDATE event_reservations er
      SET requester_id = m.requester_id
      FROM tmp_reservation_actor_map m
      WHERE er.reservation_id = m.reservation_id
    ';
  END IF;
END
$$;

-- ============================================================================
-- 7) REQUIRED DOCUMENTS
-- 1-3 docs for selected reservations; rejected cases 1016/1018 intentionally missing
-- ============================================================================
INSERT INTO required_documents (
  doc_id, reservation_id, document_type, file_url, file_name, file_size, uploaded_at, is_verified
)
VALUES
  (3001, 1006, 'Event Permit', 'https://storage.university.edu/docs/1006/event-permit.pdf', 'event-permit-1006.pdf', 421776, '2026-02-01 14:05:00', TRUE),
  (3002, 1006, 'Facility Request Form', 'https://storage.university.edu/docs/1006/facility-form.pdf', 'facility-form-1006.pdf', 297412, '2026-02-01 14:08:00', TRUE),

  (3003, 1007, 'Facility Request Form', 'https://storage.university.edu/docs/1007/facility-form.pdf', 'facility-form-1007.pdf', 256193, '2026-02-02 12:05:00', TRUE),
  (3004, 1007, 'Health & Safety Waiver', 'https://storage.university.edu/docs/1007/safety-waiver.pdf', 'safety-waiver-1007.pdf', 188774, '2026-02-02 12:06:00', TRUE),

  (3005, 1008, 'Security Clearance', 'https://storage.university.edu/docs/1008/security-clearance.pdf', 'security-clearance-1008.pdf', 312201, '2026-02-03 15:01:00', TRUE),

  (3006, 1009, 'Health & Safety Waiver', 'https://storage.university.edu/docs/1009/waiver.pdf', 'waiver-1009.pdf', 143920, '2026-02-05 10:05:00', TRUE),
  (3007, 1009, 'Facility Request Form', 'https://storage.university.edu/docs/1009/facility-form.pdf', 'facility-form-1009.pdf', 229811, '2026-02-05 10:07:00', TRUE),

  (3008, 1010, 'Event Permit', 'https://storage.university.edu/docs/1010/event-permit.pdf', 'event-permit-1010.pdf', 498810, '2026-01-20 11:10:00', TRUE),
  (3009, 1010, 'Security Clearance', 'https://storage.university.edu/docs/1010/security-clearance.pdf', 'security-clearance-1010.pdf', 362105, '2026-01-20 11:15:00', TRUE),
  (3010, 1010, 'Insurance Certificate', 'https://storage.university.edu/docs/1010/insurance.pdf', 'insurance-1010.pdf', 551220, '2026-01-20 11:20:00', TRUE),

  (3011, 1011, 'Facility Request Form', 'https://storage.university.edu/docs/1011/facility-request.pdf', 'facility-request-1011.pdf', 273120, '2026-01-22 16:05:00', TRUE),
  (3012, 1011, 'Insurance Certificate', 'https://storage.university.edu/docs/1011/insurance.pdf', 'insurance-1011.pdf', 488102, '2026-01-22 16:10:00', TRUE),

  (3013, 1012, 'Event Permit', 'https://storage.university.edu/docs/1012/event-permit.pdf', 'event-permit-1012.pdf', 532884, '2026-01-18 09:00:00', TRUE),
  (3014, 1012, 'Security Clearance', 'https://storage.university.edu/docs/1012/security-clearance.pdf', 'security-clearance-1012.pdf', 344119, '2026-01-18 09:06:00', TRUE),

  (3015, 1013, 'Health & Safety Waiver', 'https://storage.university.edu/docs/1013/waiver.pdf', 'waiver-1013.pdf', 201337, '2026-01-25 12:10:00', TRUE),
  (3016, 1013, 'Facility Request Form', 'https://storage.university.edu/docs/1013/facility.pdf', 'facility-1013.pdf', 290812, '2026-01-25 12:12:00', TRUE),

  (3017, 1014, 'Security Clearance', 'https://storage.university.edu/docs/1014/security-clearance.pdf', 'security-clearance-1014.pdf', 378904, '2026-01-26 14:00:00', TRUE),
  (3018, 1014, 'Insurance Certificate', 'https://storage.university.edu/docs/1014/insurance.pdf', 'insurance-1014.pdf', 512440, '2026-01-26 14:02:00', TRUE),

  (3019, 1015, 'Facility Request Form', 'https://storage.university.edu/docs/1015/facility-request.pdf', 'facility-request-1015.pdf', 242994, '2026-01-28 11:01:00', TRUE),

  -- One pending request with partial documents (still pending)
  (3020, 1002, 'Facility Request Form', 'https://storage.university.edu/docs/1002/facility-draft.pdf', 'facility-draft-1002.pdf', 160555, '2026-02-04 10:40:00', FALSE),

  -- Rejected 1017 includes 1 doc but incomplete set
  (3021, 1017, 'Facility Request Form', 'https://storage.university.edu/docs/1017/facility-form.pdf', 'facility-form-1017.pdf', 202210, '2026-02-03 13:00:00', FALSE)
ON CONFLICT (doc_id) DO UPDATE SET
  reservation_id = EXCLUDED.reservation_id,
  document_type = EXCLUDED.document_type,
  file_url = EXCLUDED.file_url,
  file_name = EXCLUDED.file_name,
  file_size = EXCLUDED.file_size,
  uploaded_at = EXCLUDED.uploaded_at,
  is_verified = EXCLUDED.is_verified;

-- ============================================================================
-- 8) APPROVAL LOGS
-- For every non-pending reservation, with chronological transitions
-- ============================================================================
INSERT INTO approval_logs (
  log_id, reservation_id, previous_status, new_status, approved_by, approved_at, comments, approver_role
)
VALUES
  -- ADVISOR_APPROVED (4): PENDING -> ADVISOR_APPROVED
  (4001, 1006, 'PENDING', 'ADVISOR_APPROVED', '10000000-0000-0000-0000-000000000001', '2026-02-02 10:15:00', 'Documents complete. Endorsed for admin review.', 'FACULTY_ADVISOR'),
  (4002, 1007, 'PENDING', 'ADVISOR_APPROVED', '10000000-0000-0000-0000-000000000003', '2026-02-03 09:40:00', 'Program objective aligned with org roadmap.', 'FACULTY_ADVISOR'),
  (4003, 1008, 'PENDING', 'ADVISOR_APPROVED', '10000000-0000-0000-0000-000000000002', '2026-02-04 08:55:00', 'Capacity and room match request.', 'FACULTY_ADVISOR'),
  (4004, 1009, 'PENDING', 'ADVISOR_APPROVED', '10000000-0000-0000-0000-000000000001', '2026-02-06 11:50:00', 'Approved for final admin queue.', 'FACULTY_ADVISOR'),

  -- APPROVED (6): two-step flow PENDING -> ADVISOR_APPROVED -> APPROVED
  (4005, 1010, 'PENDING', 'ADVISOR_APPROVED', '10000000-0000-0000-0000-000000000001', '2026-01-21 09:10:00', 'Advisor endorsement completed.', 'FACULTY_ADVISOR'),
  (4006, 1010, 'ADVISOR_APPROVED', 'APPROVED', '20000000-0000-0000-0000-000000000001', '2026-01-22 09:30:00', 'Final approval granted. Security staffing confirmed.', 'ADMIN'),

  (4007, 1011, 'PENDING', 'ADVISOR_APPROVED', '10000000-0000-0000-0000-000000000002', '2026-01-23 09:00:00', 'Technically sound and compliant.', 'FACULTY_ADVISOR'),
  (4008, 1011, 'ADVISOR_APPROVED', 'APPROVED', '20000000-0000-0000-0000-000000000002', '2026-01-24 10:05:00', 'Approved with lab safety oversight.', 'ADMIN'),

  (4009, 1012, 'PENDING', 'ADVISOR_APPROVED', '10000000-0000-0000-0000-000000000002', '2026-01-19 10:20:00', 'Large venue justification accepted.', 'FACULTY_ADVISOR'),
  (4010, 1012, 'ADVISOR_APPROVED', 'APPROVED', '20000000-0000-0000-0000-000000000001', '2026-01-20 13:10:00', 'Approved after operations clearance.', 'ADMIN'),

  (4011, 1013, 'PENDING', 'ADVISOR_APPROVED', '10000000-0000-0000-0000-000000000003', '2026-01-26 10:30:00', 'Advisor approved for leadership training event.', 'FACULTY_ADVISOR'),
  (4012, 1013, 'ADVISOR_APPROVED', 'APPROVED', '20000000-0000-0000-0000-000000000002', '2026-01-27 16:00:00', 'Approved and listed in campus calendar.', 'ADMIN'),

  (4013, 1014, 'PENDING', 'ADVISOR_APPROVED', '10000000-0000-0000-0000-000000000001', '2026-01-28 11:25:00', 'All required forms received.', 'FACULTY_ADVISOR'),
  (4014, 1014, 'ADVISOR_APPROVED', 'APPROVED', '20000000-0000-0000-0000-000000000001', '2026-01-29 09:45:00', 'Approved for public audience event.', 'ADMIN'),

  (4015, 1015, 'PENDING', 'ADVISOR_APPROVED', '10000000-0000-0000-0000-000000000002', '2026-01-29 10:50:00', 'Mentorship activity validated.', 'FACULTY_ADVISOR'),
  (4016, 1015, 'ADVISOR_APPROVED', 'APPROVED', '20000000-0000-0000-0000-000000000002', '2026-01-30 14:20:00', 'Final admin approval complete.', 'ADMIN'),

  -- REJECTED (3)
  -- flow: PENDING -> REJECTED
  (4017, 1016, 'PENDING', 'REJECTED', '10000000-0000-0000-0000-000000000001', '2026-02-04 12:20:00', 'Rejected: missing Event Permit and Security Clearance.', 'FACULTY_ADVISOR'),
  -- flow: PENDING -> ADVISOR_APPROVED -> REJECTED
  (4018, 1017, 'PENDING', 'ADVISOR_APPROVED', '10000000-0000-0000-0000-000000000003', '2026-02-04 09:05:00', 'Conditionally endorsed pending compliance docs.', 'FACULTY_ADVISOR'),
  (4019, 1017, 'ADVISOR_APPROVED', 'REJECTED', '20000000-0000-0000-0000-000000000001', '2026-02-06 10:40:00', 'Rejected by admin: incomplete insurance certificate.', 'ADMIN'),
  -- flow: PENDING -> REJECTED
  (4020, 1018, 'PENDING', 'REJECTED', '10000000-0000-0000-0000-000000000001', '2026-02-05 15:00:00', 'Rejected: overnight access and security permit not provided.', 'FACULTY_ADVISOR'),

  -- CANCELLED (2)
  -- flow: PENDING -> CANCELLED
  (4021, 1019, 'PENDING', 'CANCELLED', '30000000-0000-0000-0000-000000000001', '2026-02-07 09:30:00', 'Cancelled by requester due to exam schedule conflict.', 'STUDENT'),
  (4022, 1020, 'PENDING', 'CANCELLED', '30000000-0000-0000-0000-000000000003', '2026-02-08 10:10:00', 'Cancelled by requester due to team unavailability.', 'STUDENT')
ON CONFLICT (log_id) DO UPDATE SET
  reservation_id = EXCLUDED.reservation_id,
  previous_status = EXCLUDED.previous_status,
  new_status = EXCLUDED.new_status,
  approved_by = EXCLUDED.approved_by,
  approved_at = EXCLUDED.approved_at,
  comments = EXCLUDED.comments,
  approver_role = EXCLUDED.approver_role;

-- Optional compatibility block:
-- If approval_logs.changed_by exists, mirror approved_by values into changed_by.
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_name = 'approval_logs'
      AND column_name = 'changed_by'
  ) THEN
    EXECUTE '
      UPDATE approval_logs
      SET changed_by = CASE
        WHEN approver_role = ''ADMIN'' THEN ''8fbcea67-7419-4694-b1ea-6dc70038eee8''::uuid
        WHEN approver_role = ''FACULTY_ADVISOR'' THEN ''7da07ce5-d2a4-4eb1-aa7c-ef7e97139528''::uuid
        WHEN approver_role = ''STUDENT'' THEN ''a7d9a579-9edf-4a1a-a833-60a6831c4837''::uuid
        ELSE NULL
      END
    ';
  END IF;
END
$$;

-- ============================================================================
-- Sequence synchronization (safe after explicit PK inserts)
-- ============================================================================
SELECT setval(pg_get_serial_sequence('buildings', 'building_id'), (SELECT COALESCE(MAX(building_id), 1) FROM buildings), true);
SELECT setval(pg_get_serial_sequence('organizations', 'org_id'), (SELECT COALESCE(MAX(org_id), 1) FROM organizations), true);
SELECT setval(pg_get_serial_sequence('rooms', 'room_id'), (SELECT COALESCE(MAX(room_id), 1) FROM rooms), true);
SELECT setval(pg_get_serial_sequence('academic_schedules', 'schedule_id'), (SELECT COALESCE(MAX(schedule_id), 1) FROM academic_schedules), true);
SELECT setval(pg_get_serial_sequence('event_reservations', 'reservation_id'), (SELECT COALESCE(MAX(reservation_id), 1) FROM event_reservations), true);
SELECT setval(pg_get_serial_sequence('required_documents', 'doc_id'), (SELECT COALESCE(MAX(doc_id), 1) FROM required_documents), true);
SELECT setval(pg_get_serial_sequence('approval_logs', 'log_id'), (SELECT COALESCE(MAX(log_id), 1) FROM approval_logs), true);

COMMIT;

-- ============================================================================
-- Quick validation checks (optional)
-- ============================================================================
-- SELECT status, COUNT(*) FROM event_reservations GROUP BY status ORDER BY status;
-- SELECT COUNT(*) AS pending_count FROM event_reservations WHERE status='PENDING';
-- SELECT COUNT(*) AS advisor_approved_count FROM event_reservations WHERE status='ADVISOR_APPROVED';
-- SELECT COUNT(*) AS approved_count FROM event_reservations WHERE status='APPROVED';
-- SELECT COUNT(*) AS rejected_count FROM event_reservations WHERE status='REJECTED';
-- SELECT COUNT(*) AS cancelled_count FROM event_reservations WHERE status='CANCELLED';
