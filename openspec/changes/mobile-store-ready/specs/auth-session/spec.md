# auth-session — Spec Delta

## ADDED Requirements

### Requirement: First-party authentication only in v1.0

Mobile authentication SHALL be limited to the app's own Strapi email/password flows: register, login, and forgot-password request. The app SHALL NOT present third-party identity-provider sign-in (Google, Apple, Facebook) and SHALL NOT embed any web view for authentication purposes.

#### Scenario: Login panel surface
- **WHEN** a user opens the login panel
- **THEN** only email/password register, login, and "Forgot password?" actions are available; no social sign-in button exists

#### Scenario: No web view in the auth path
- **WHEN** any authentication flow runs
- **THEN** no `WKWebView` (or other embedded browser) is instantiated by the app

#### Scenario: Google-only web account on mobile
- **WHEN** a user whose web account was created via Google attempts email/password login on mobile
- **THEN** the normal server "invalid credentials" error is shown (no mobile-side account creation for that email is attempted by this app version)
