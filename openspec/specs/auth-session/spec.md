# auth-session Specification

## Purpose
TBD - created by archiving change harden-auth-session-and-user-data. Update Purpose after archive.
## Requirements
### Requirement: Expired session handling

When the app cannot verify the stored session (profile fetch `GET /users/me` returns 401 or 403), the app SHALL sign the user out AND display a session-expired banner with a sign-in action. The app SHALL NOT clear the logged-in profile state silently without informing the user.

#### Scenario: Expired token at app launch
- **WHEN** the app starts with a stored JWT and the profile fetch returns 401
- **THEN** the user is signed out and a banner is shown offering to sign in again

#### Scenario: Dismiss and re-authenticate
- **WHEN** the user taps "Sign in" on the session-expired banner
- **THEN** the login sheet opens and a successful login clears the banner and restores the profile

#### Scenario: Non-auth profile failure
- **WHEN** the profile fetch fails with a non-401/403 error (network, timeout)
- **THEN** the app keeps the current local state and does not sign the user out

### Requirement: Login does not switch the active chat

Signing in (or re-loading the profile) SHALL NOT change the user's active chat language or level. The profile's languages SHALL remain available for selection in the menu, but the current chat thread MUST stay visible and intact.

#### Scenario: Login while chatting in another language
- **WHEN** the user is practicing German B1 and signs in with a profile whose primary language is English A2
- **THEN** the German B1 thread remains loaded and the English A2 chat is available as a menu entry

### Requirement: Profile fetch frequency

The profile fetch SHALL run once per app launch when a session exists, and once after a successful login. It SHALL NOT run again on subsequent view appearances (e.g. returning from a pushed screen).

#### Scenario: Navigate back to chat
- **WHEN** the user opens Homework and returns to the chat screen
- **THEN** no additional profile fetch is performed

### Requirement: Password recovery

The login panel SHALL offer a "Forgot password?" flow that sends a reset link via the Strapi `auth/local/forgot-password` endpoint for the given email.

#### Scenario: Request reset link
- **WHEN** the user taps "Forgot password?", enters their email, and confirms
- **THEN** the app calls the forgot-password endpoint and shows a confirmation message that a reset link was sent if an account exists

### Requirement: Readable auth errors

Login/register errors returned by Strapi SHALL display the server-provided message when present, instead of a generic "Login failed (status)" string.

#### Scenario: Invalid credentials
- **WHEN** the user submits an invalid password and Strapi responds with `{"message":[{"messages":[{"message":"Invalid identifier or password"}]}]}`
- **THEN** the login panel shows "Invalid identifier or password"

#### Scenario: Unparseable body
- **WHEN** the error body contains no recognizable message
- **THEN** the panel falls back to "Login failed (status)"

