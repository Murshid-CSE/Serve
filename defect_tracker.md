# Defect Tracker

| Issue ID | Severity | Location | Root Cause | Fix | Verification | Regression Status |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| SEC-01 | CRITICAL | `firestore.rules` | `validUser()` allowed arbitrary strings for role mapping. | Enforced array of fixed strings `['donor', 'volunteer', 'ngo', 'recipient', 'hospital']`. | Code review. | PASS |
| SEC-02 | HIGH | `EmergencyAlertEntity` | Anonymous payload allowed identity spoofing. | Added `creatorId` binding to Firebase Auth state on creation. | Code review. | PASS |
| SEC-03 | HIGH | `firestore.rules` | `/emergency_requests` allowed non-creators to spoof. | `request.resource.data.creatorId == request.auth.uid` enforced. | Code review. | PASS |
| LINT-01 | MEDIUM | Workspace | >100 `const` and formatting violations. | `dart fix --apply`. | Static analysis. | PASS |
| TST-01 | HIGH | Test Suite | Integration Tests completely missing. | Scheduled Phase 8. | Pending | PENDING |
| TST-02 | HIGH | Test Suite | Widget Tests missing `ProviderScope` mocking. | Scheduled Phase 7. | Pending | PENDING |
