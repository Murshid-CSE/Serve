# Production Readiness Checklist

Before any sprint or feature is considered "Done", it must pass this production checklist to ensure it scales safely across the entire user base.

## 1. Real-Time Synchronization
- [ ] Streams are used instead of one-time fetches (`.snapshots()` instead of `.get()`).
- [ ] Streams are disposed when leaving screens (`.autoDispose` in Riverpod).
- [ ] Cross-device interactions instantly update without manual pull-to-refresh.
- [ ] The feature passes all tests in `realtime_test_matrix.md`.

## 2. Security & Transactions
- [ ] Array updates (`arrayUnion`/`arrayRemove`) are protected by explicit ownership checks in `firestore.rules`.
- [ ] Document field overwrites are strictly limited by `affectedKeys().hasOnly([...])` in `firestore.rules`.
- [ ] Multi-user mutations (e.g., accepting a task, fulfilling a request) are wrapped in `_firestore.runTransaction()` to prevent race conditions.

## 3. Database Indexing & Scalability
- [ ] Any compound query (`where()` + `orderBy()`) has an explicit index defined in `firestore.indexes.json`.
- [ ] Arrays searched via `arrayContains` have proper indexing if combined with ordering.
- [ ] (Future) Pagination is implemented for collections exceeding 100 documents.

## 4. Resilience & Error Handling
- [ ] Firestore Streams gracefully handle offline behavior (caching enabled).
- [ ] Exceptions are caught and displayed via user-friendly `ErrorState` UI.
- [ ] Network drops during transactions present clear "No Connection" messages rather than generic Firebase exceptions.
