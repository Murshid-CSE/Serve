# Real-Time Synchronization Test Matrix

Every feature developed for the Community Care Hub must satisfy this matrix before being considered "Done." Testing requires at least two physical devices (or one device and one emulator) logged into different accounts.

## Core Synchronization Principles
- **Cross-device & Cross-account:** Actions by User A must instantly reflect on User B's device.
- **Offline Recovery:** Actions performed offline must sync to the server and update other connected clients immediately upon reconnection.
- **Duplicate Listeners:** Features must clean up stream listeners (via Riverpod `.autoDispose`) when leaving screens to prevent memory leaks and redundant Firestore reads.

## 1. Food Module Matrix
| Action | Actor | Expected Observer Result | Status |
| :--- | :--- | :--- | :--- |
| **Post Food** | Restaurant | Volunteer instantly sees new post in "Discover". | ☐ |
| **Accept Food** | Volunteer | Restaurant instantly sees "Accepted" status in "My Donations". | ☐ |
| **Collect Food** | Volunteer | Restaurant instantly sees "Collected" status. | ☐ |
| **Deliver Food** | Volunteer | Restaurant instantly sees "Delivered" status. | ☐ |
| **Complete** | Restaurant | Volunteer instantly sees "Completed" in "My Deliveries" history. | ☐ |

## 2. Blood Module Matrix
| Action | Actor | Expected Observer Result | Status |
| :--- | :--- | :--- | :--- |
| **Post Request** | Requester | Donor instantly sees request in "Discover". | ☐ |
| **Respond** | Donor | Requester instantly sees Donor in "Responded By" list in "My Requests". | ☐ |
| **Close Request** | Requester | Donor instantly sees request closed/completed. | ☐ |

## 3. Volunteer Module Matrix
| Action | Actor | Expected Observer Result | Status |
| :--- | :--- | :--- | :--- |
| **Create Task** | Organizer | Volunteers instantly see task in "Discover". | ☐ |
| **Join Task** | Volunteer | Organizer instantly sees Volunteer count increment. | ☐ |
| **Leave Task** | Volunteer | Organizer instantly sees Volunteer count decrement. | ☐ |

## 4. Emergency Module Matrix
| Action | Actor | Expected Observer Result | Status |
| :--- | :--- | :--- | :--- |
| **Create Alert** | Creator | Nearby Responders instantly see alert in "Nearby". | ☐ |
| **Respond** | Responder | Creator instantly sees Responder in alert details. | ☐ |
| **Resolve** | Creator | Responder instantly sees alert removed from active list. | ☐ |
