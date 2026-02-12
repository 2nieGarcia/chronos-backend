$ErrorActionPreference = 'Stop'

function Get-RequiredEnv {
  param([string]$Name)

  $value = [Environment]::GetEnvironmentVariable($Name)
  if ([string]::IsNullOrWhiteSpace($value)) {
    throw "Missing required environment variable: $Name"
  }

  return $value
}

function Invoke-Test {
  param(
    [string]$Name,
    [string]$Method,
    [string]$Url,
    [hashtable]$Headers,
    [string]$Body = $null,
    [int[]]$Expected = @(200)
  )

  try {
    if (-not [string]::IsNullOrWhiteSpace($Body)) {
      $resp = Invoke-WebRequest -UseBasicParsing -Method $Method -Uri $Url -Headers $Headers -Body $Body -ContentType 'application/json'
    } else {
      $resp = Invoke-WebRequest -UseBasicParsing -Method $Method -Uri $Url -Headers $Headers
    }

    $code = [int]$resp.StatusCode
    $ok = $Expected -contains $code
    return [PSCustomObject]@{ Name = $Name; Method = $Method; Code = $code; Pass = $ok; Url = $Url }
  }
  catch {
    $code = 0
    $errorText = $_.Exception.Message
    if ($_.Exception.Response) {
      if ($_.Exception.Response.StatusCode) {
        $code = [int]$_.Exception.Response.StatusCode.value__
      }
    }
    $ok = $Expected -contains $code
    return [PSCustomObject]@{ Name = $Name; Method = $Method; Code = $code; Pass = $ok; Url = $Url; Error = $errorText }
  }
}

$base = 'http://localhost:8080/api'

$unauth = Invoke-Test -Name 'Unauthorized check /buildings' -Method 'GET' -Url "$base/buildings" -Headers @{} -Expected @(401, 403)

$supabaseUrl = Get-RequiredEnv -Name 'SUPABASE_URL'
$supabaseAnonKey = Get-RequiredEnv -Name 'SUPABASE_ANON_KEY'
$testEmail = Get-RequiredEnv -Name 'QA_TEST_EMAIL'
$testPassword = Get-RequiredEnv -Name 'QA_TEST_PASSWORD'

$loginBody = (@{ email = $testEmail; password = $testPassword } | ConvertTo-Json)
$tokenEndpoint = "$supabaseUrl/auth/v1/token?grant_type=password"
$tokenResp = Invoke-RestMethod -Method Post -Uri $tokenEndpoint -Headers @{ apikey = $supabaseAnonKey } -Body $loginBody -ContentType 'application/json'
$token = $tokenResp.access_token
if (-not $token) {
  throw 'Failed to acquire JWT token from Supabase'
}

$authHeaders = @{ Authorization = "Bearer $token" }

$rooms = Invoke-RestMethod -Method Get -Uri "$base/rooms" -Headers $authHeaders
$roomId = if ($rooms.Count -gt 0) { [int]$rooms[0].id } else { 1 }

$reservations = Invoke-RestMethod -Method Get -Uri "$base/reservations" -Headers $authHeaders
$reservationId = if ($reservations.Count -gt 0) { [int]$reservations[0].id } else { 1 }

$timestamp = Get-Date -Format 'yyyyMMddHHmmss'
$eventDate = (Get-Date).AddDays(10).ToString('yyyy-MM-dd')
$orgPath = [System.Uri]::EscapeDataString('ACM Student Chapter')

$existingReservation = Invoke-RestMethod -Method Get -Uri "$base/reservations/$reservationId" -Headers $authHeaders
$putRoomId = if ($existingReservation.room -and $existingReservation.room.id) { [int]$existingReservation.room.id } else { $roomId }
$putOrganizationName = if ($existingReservation.organizationName) { $existingReservation.organizationName } else { "QA Org $timestamp" }
$putRequestedBy = if ($existingReservation.requestedBy) { $existingReservation.requestedBy } else { 'qa@university.edu' }
$putStatus = if ($existingReservation.status) { $existingReservation.status } else { 'PENDING' }
$putLegacyTitle = if ($existingReservation.legacyTitle) { $existingReservation.legacyTitle } else { 'Legacy Title' }

$putBodyObj = [ordered]@{
  id = $reservationId
  room = @{ id = $putRoomId }
  organizationName = $putOrganizationName
  eventTitle = 'Updated by QA'
  legacyTitle = $putLegacyTitle
  eventDate = '2026-02-20'
  startTime = '15:00'
  endTime = '17:00'
  status = $putStatus
  requestedBy = $putRequestedBy
  requestedAt = $existingReservation.requestedAt
  approvedBy = $existingReservation.approvedBy
  approvedAt = $existingReservation.approvedAt
  purpose = 'Updated'
  expectedAttendees = 99
  documentUrl = $existingReservation.documentUrl
}
$putReservationBody = ($putBodyObj | ConvertTo-Json -Depth 6)

$tests = @()

$tests += Invoke-Test -Name 'POST admin fix-sequences' -Method 'POST' -Url "$base/admin/fix-sequences" -Headers $authHeaders -Expected @(200)

$tests += Invoke-Test -Name 'GET buildings' -Method 'GET' -Url "$base/buildings" -Headers $authHeaders -Expected @(200)
$tests += Invoke-Test -Name 'POST buildings' -Method 'POST' -Url "$base/buildings" -Headers $authHeaders -Body ('{"name":"QA Building ' + $timestamp + '","location":"QA"}') -Expected @(200)

$tests += Invoke-Test -Name 'GET rooms' -Method 'GET' -Url "$base/rooms" -Headers $authHeaders -Expected @(200)
$tests += Invoke-Test -Name 'GET room by id' -Method 'GET' -Url "$base/rooms/$roomId" -Headers $authHeaders -Expected @(200)
$tests += Invoke-Test -Name 'GET rooms by building' -Method 'GET' -Url "$base/rooms/by-building/1" -Headers $authHeaders -Expected @(200)
$tests += Invoke-Test -Name 'GET rooms by type' -Method 'GET' -Url "$base/rooms/by-type/CLASSROOM" -Headers $authHeaders -Expected @(200)
$tests += Invoke-Test -Name 'GET rooms available' -Method 'GET' -Url "$base/rooms/available?date=2026-02-17&startTime=14:00&endTime=16:00" -Headers $authHeaders -Expected @(200)
$tests += Invoke-Test -Name 'GET room availability' -Method 'GET' -Url "$base/rooms/$roomId/availability?date=2026-02-17&startTime=14:00&endTime=16:00" -Headers $authHeaders -Expected @(200)
$tests += Invoke-Test -Name 'POST room' -Method 'POST' -Url "$base/rooms" -Headers $authHeaders -Body ('{"building":{"id":1},"roomNumber":"QA-' + $timestamp + '","roomType":"CLASSROOM","capacity":30,"floor":1,"description":"qa","isAvailable":true}') -Expected @(200)

$tests += Invoke-Test -Name 'GET reservations' -Method 'GET' -Url "$base/reservations" -Headers $authHeaders -Expected @(200)
$tests += Invoke-Test -Name 'GET reservation by id' -Method 'GET' -Url "$base/reservations/$reservationId" -Headers $authHeaders -Expected @(200)
$tests += Invoke-Test -Name 'GET reservations by status' -Method 'GET' -Url "$base/reservations/status/PENDING" -Headers $authHeaders -Expected @(200)
$tests += Invoke-Test -Name 'GET reservations by org' -Method 'GET' -Url "$base/reservations/organization/$orgPath" -Headers $authHeaders -Expected @(200)
$tests += Invoke-Test -Name 'GET upcoming reservations' -Method 'GET' -Url "$base/reservations/upcoming?startDate=2026-02-11&endDate=2026-02-28" -Headers $authHeaders -Expected @(200)
$tests += Invoke-Test -Name 'POST check conflicts' -Method 'POST' -Url "$base/reservations/check-conflicts" -Headers $authHeaders -Body '{"roomId":1,"eventDate":"2026-02-17","startTime":"14:00","endTime":"16:00"}' -Expected @(200)
$tests += Invoke-Test -Name 'POST reservation' -Method 'POST' -Url "$base/reservations" -Headers $authHeaders -Body ('{"room":{"id":' + $roomId + '},"organizationName":"QA Org ' + $timestamp + '","eventTitle":"QA Event ' + $timestamp + '","eventDate":"' + $eventDate + '","startTime":"10:00","endTime":"11:00","requestedBy":"qa@university.edu","purpose":"qa","expectedAttendees":20}') -Expected @(201, 409)
$tests += Invoke-Test -Name 'PUT reservation' -Method 'PUT' -Url "$base/reservations/$reservationId" -Headers $authHeaders -Body $putReservationBody -Expected @(200)
$tests += Invoke-Test -Name 'DELETE reservation missing' -Method 'DELETE' -Url "$base/reservations/999999" -Headers $authHeaders -Expected @(404)

$tests += Invoke-Test -Name 'GET approval history' -Method 'GET' -Url "$base/approvals/$reservationId/history" -Headers $authHeaders -Expected @(200)
$tests += Invoke-Test -Name 'PUT approve' -Method 'PUT' -Url "$base/approvals/$reservationId/approve" -Headers $authHeaders -Body '{"newStatus":"ADVISOR_APPROVED","approvedBy":"advisor@university.edu","approverRole":"ADVISOR","comments":"qa"}' -Expected @(200, 400)
$tests += Invoke-Test -Name 'PUT reject' -Method 'PUT' -Url "$base/approvals/$reservationId/reject" -Headers $authHeaders -Body '{"rejectedBy":"advisor@university.edu","rejectorRole":"ADVISOR","reason":"qa"}' -Expected @(200, 400)
$tests += Invoke-Test -Name 'PUT cancel' -Method 'PUT' -Url "$base/approvals/$reservationId/cancel" -Headers $authHeaders -Body '{"cancelledBy":"student@university.edu"}' -Expected @(200, 400)

$all = @($unauth) + $tests
$all | Sort-Object Name | Format-Table -AutoSize

$passed = @($all | Where-Object { $_.Pass }).Count
$total = $all.Count
$failed = @($all | Where-Object { -not $_.Pass }).Count

Write-Output "PASSED: $passed / $total"
Write-Output "FAILED: $failed"

if ($failed -gt 0) {
  Write-Output 'Failing tests:'
  $all | Where-Object { -not $_.Pass } | Select-Object Name, Method, Code, Url, Error | Format-List
}
