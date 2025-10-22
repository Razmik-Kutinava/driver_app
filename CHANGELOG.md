# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.1] - 2024-10-22

### Fixed
- **CRITICAL SECURITY FIX**: Replaced `serviceKey` with `anonKey` in Supabase initialization
  - Previous implementation bypassed Row Level Security
  - Now properly uses anon key with RLS policies

### Added
- Notification service with Flutter Local Notifications
- Cache service for offline data storage
- Comprehensive error handling across all services
- Unit tests for core services (auth, order, cache)
- Sentry integration for production error tracking
- CI/CD workflows for GitHub Actions
  - Automated testing and linting
  - Release builds for Android and iOS
- Security policy documentation (SECURITY.md)
- Environment variables template (.env.example)
- Enhanced .gitignore for secrets and sensitive files

### Changed
- Improved error handling in all services
- Added loading states to service operations
- Better offline support with local caching

### Security
- Fixed critical security vulnerability with service key usage
- Added proper secrets management
- Enhanced .gitignore to prevent credential leaks
- Added security documentation and best practices

## [1.0.0] - 2024-10-20

### Added
- Initial release
- Driver authentication via phone number
- Real-time GPS tracking
- Order management system
- QR code scanner for orders
- Google Maps integration
- Chat with dispatcher
- Profile management
- Driver statistics
- Supabase integration
- Material Design UI
