# Architecture Decisions

This document records major architectural decisions made during the development of the Community Care Hub, providing rationale and context for future developers.

## 1. Why Riverpod & Streams?
**Decision:** We migrated from one-time `FutureProvider`s and `.get()` fetches to `StreamProvider`s and `.snapshots()`.
**Rationale:** A production-grade multi-user app (like Uber or WhatsApp) requires real-time synchronization. If Volunteer A accepts a task, Restaurant B's phone must update instantly without manual refreshing. `StreamProvider` handles WebSocket connections natively. We strictly enforce `.autoDispose` to prevent memory leaks when listeners are no longer on screen.

## 2. Why Firestore?
**Decision:** Google Cloud Firestore was selected for the primary database.
**Rationale:** It provides out-of-the-box offline caching and real-time streaming capabilities (`.snapshots()`), which are essential for the community-driven emergency and volunteer features.

## 3. Why Cloudinary?
**Decision:** We migrated from Firebase Storage to Cloudinary for media uploads.
**Rationale:** Cloudinary offers on-the-fly image transformations, which vastly improves bandwidth efficiency for the app's timeline and profile features.

## 4. Why Ownership Tabs?
**Decision:** Modules are structured by user responsibility (e.g., "Discover", "My Donations", "My Deliveries") rather than generic lists.
**Rationale:** Users need a clear mental model of "what they own" and "what they are participating in". History is kept outside of the active work tabs to prevent active work from disappearing into a confusing archive.

## 5. Why Explicit Transactions?
**Decision:** All multi-user mutations (like accepting a donation or responding to an emergency) are wrapped in `_firestore.runTransaction()`.
**Rationale:** Prevents race conditions. Without transactions, if two volunteers hit "Accept" simultaneously, both writes would succeed, leaving the database in an inconsistent state.
