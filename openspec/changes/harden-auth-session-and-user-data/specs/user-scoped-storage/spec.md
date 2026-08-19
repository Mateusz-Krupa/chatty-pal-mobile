# user-scoped-storage — Spec Delta

## ADDED Requirements

### Requirement: Per-account storage scoping

Chat history, learning stats, and word-review data SHALL be stored per account. The scope key SHALL be the signed-in username, or `guest` when no user is signed in. Different accounts on the same device MUST NOT see each other's data.

#### Scenario: Second account on a shared device
- **WHEN** user A signs out and user B signs in on the same device
- **THEN** user B's chat history, streak, and word-review list contain only user B's data

#### Scenario: Guest usage
- **WHEN** the app is used without signing in
- **THEN** all practice data is stored under the `guest` scope

### Requirement: Legacy data migration

On first load under a scoped key, existing data under the legacy unscoped key SHALL be moved to the scoped key exactly once (write to scoped key, delete legacy key). No legacy data SHALL be lost.

#### Scenario: App upgrade after login
- **WHEN** a user with legacy `learning.stats` data signs in after upgrading
- **THEN** their stats appear intact and the legacy key is removed

#### Scenario: Migration happens once
- **WHEN** the scoped key already contains data
- **THEN** the legacy key is not read and nothing is moved

### Requirement: Guest-to-user continuity on login

Practice data accumulated in the `guest` scope (chat threads, learning stats, word-review words) SHALL be carried over to the newly signed-in user's scope on first load after login, so the user's pre-login progress does not disappear.

#### Scenario: Login after chatting as guest
- **WHEN** the user chats as a guest in German B1, then signs in
- **THEN** the German B1 thread loaded for the user contains the pre-login conversation

#### Scenario: Login after guest practice
- **WHEN** the user completes a lesson and adds words as a guest, then signs in
- **THEN** the user's stats and word-review list contain the pre-login progress

### Requirement: Capture buffer thread safety

The speech capture buffer (raw PCM) SHALL be synchronized so that concurrent recording (audio tap) and stop/read on the main thread cannot corrupt the recorded audio or crash.

#### Scenario: Stop while tap is delivering
- **WHEN** `stopRecording()` runs while the audio tap is appending samples
- **THEN** the returned WAV is a consistent prefix of the capture and no crash or torn write occurs
