$files = Get-ChildItem -Path "test" -Recurse -Filter "*.dart"

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw

    # BloodRequestEntity fixes
    $content = $content -replace "location:\s*const\s*\{\}", "latitude: 0.0, longitude: 0.0, geohash: ''"
    $content = $content -replace "requesterId:\s*'user1',\s*patientName", "requesterId: 'user1', requesterName: 'user', requesterPhone: '123', patientName"
    $content = $content -replace "createdAt:\s*DateTime.now\(\)", "createdAt: DateTime.now(), expiresAt: DateTime.now(), isEmergency: false, respondedBy: const []"
    $content = $content -replace "requesterId:\s*'user1'\)", "requesterId: 'user1', requesterName: 'test', requesterPhone: '123', latitude: 0, longitude: 0, geohash: '', isEmergency: false, respondedBy: const [], expiresAt: DateTime.now())"

    # EmergencyAlertEntity fixes
    $content = $content -replace "reporterId:", "creatorId:"
    $content = $content -replace "reporterName:", "creatorName:"
    $content = $content -replace "respondersIds:", "responders:"
    $content = $content -replace "address:", "address: 'Address', latitude: 0.0, longitude: 0.0, geohash: '', "
    $content = $content -replace "contactPhone:\s*'123'\s*\)", "contactPhone: '123', latitude: 0.0, longitude: 0.0, geohash: '')"

    # FoodEntity fixes
    $content = $content -replace "donorId:\s*'user1',\s*title", "donorId: 'user1', donorPhone: '123', title"
    $content = $content -replace "expiryDate:", "expiresAt:"
    $content = $content -replace "status:\s*'available',\s*createdAt", "status: 'available', expiresAt: DateTime.now(), createdAt"
    
    # BloodRequestEntity fix for usecase
    $content = $content -replace "alertId:", "alertId: '1', userId: '1'"

    Set-Content -Path $file.FullName -Value $content
}
