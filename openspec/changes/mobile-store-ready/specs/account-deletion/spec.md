# account-deletion — Spec Delta

## ADDED Requirements

### Requirement: Verified server-side deletion contract

Before the in-app deletion feature is enabled, the deployment SHALL be verified (read-only) that the Strapi endpoint used for self-deletion enforces own-account-only removal for authenticated callers and that related user data (homework, chat records) is removed or anonymized server-side. If verification fails, a CMS companion change (self-deletion endpoint deriving the id from the authenticated session) SHALL land and deploy before the mobile deletion entry point ships.

#### Scenario: Foreign-id deletion is impossible
- **WHEN** an authenticated user attempts deletion targeting another account's id
- **THEN** the other account remains intact and still authenticates (the endpoint may reject the call or ignore the supplied id; the expected response for the selected endpoint is documented by the contract verification)

#### Scenario: Unauthenticated deletion is impossible
- **WHEN** a request without a valid JWT is sent to the deletion endpoint
- **THEN** the server refuses it and the targeted account remains intact

#### Scenario: Proven on the real server before submission
- **WHEN** release validation runs against disposable staging accounts A and B, in order: B attempts to delete A while A exists (A remains intact and authenticates afterwards); unauthenticated attempt while A exists (A intact); A deletes itself (succeeds, related-data disposition verified, re-login fails cleanly)
- **THEN** all three outcomes hold for the endpoint selected by the server-contract verification — stub-level tests alone do not satisfy this gate

### Requirement: In-app permanent account deletion

Signed-in users SHALL be able to permanently delete their account from Settings via a destructive action with one explicit confirmation. On confirmation the app sends the verified deletion request with the stored JWT. HTTP 401 routes to the existing session-expired flow; any other non-2xx (including 403) shows a readable error and is NOT treated as session expiry. Local data is removed only after server success.

#### Scenario: Deletion succeeds
- **WHEN** the user confirms and the server responds successfully
- **THEN** the app clears the Keychain JWT and profile fields (`authUsername`, `authEmail`, `authRole`, `authUserId`) and signs out to the guest chat

#### Scenario: Server refused with non-401
- **WHEN** the endpoint returns any error status other than 401 (including 403)
- **THEN** no local data changes and the user stays signed in

#### Scenario: Server answers 401 during deletion
- **WHEN** the deletion request returns 401
- **THEN** the existing session-expired flow runs (signed out, banner with re-auth), deletion is NOT claimed, and no account-scoped local data is wiped — persisted learning data stays intact for the re-authenticated session

#### Scenario: Confirmation cancelled
- **WHEN** the user opens the confirmation and cancels
- **THEN** no request is sent and nothing changes

### Requirement: Scope-safe local wipe

Successful deletion SHALL remove exactly the deleted account's local data: the app captures the account's `DataScope` (derived from the username at capture time — not after sign-out retargets it to `guest`) before clearing profile fields, removes all account-scoped stores for that captured scope (conversations, bot memory, homework caches, learning stats, word review, campaign progress, role-play cache), and preserves other accounts' and the guest scope's data. In-flight chat/profile tasks are cancelled or invalidated so late responses cannot recreate state for the deleted account.

#### Scenario: Guest data survives account deletion
- **WHEN** a device has guest chat history and a signed-in account, and the account is deleted
- **THEN** guest-scoped data is intact and the deleted account's keys are gone on app restart

#### Scenario: Late network completion after deletion
- **WHEN** an already-sent bot/profile response arrives after deletion completed
- **THEN** it is discarded and does not recreate any store for the deleted account

### Requirement: User id available for the deletion call

The app SHALL persist the Strapi numeric user id (`authUserId`) on login, on registration, and via the once-per-launch profile fetch (covering sessions created by older builds), and SHALL use it — never a username-derived value — as the deletion target.

#### Scenario: Older session deletes account
- **WHEN** a user signed in with a previous app build deletes their account after upgrading
- **THEN** the launch profile fetch has supplied the id and deletion proceeds normally
