# Security Policy

## Supported Versions

Currently supported versions with security updates:

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |

## Reporting a Vulnerability

If you discover a security vulnerability within this application, please send an email to security@your-company.com. All security vulnerabilities will be promptly addressed.

Please include the following information in your report:
- Description of the vulnerability
- Steps to reproduce the issue
- Potential impact
- Suggested fix (if any)

## Security Best Practices

### For Developers:

1. **API Keys**: Never commit API keys, tokens, or credentials to the repository
2. **Environment Variables**: Use `.env` files for sensitive configuration (listed in `.gitignore`)
3. **Dependencies**: Regularly update dependencies to patch known vulnerabilities
4. **Code Review**: All code changes must be reviewed before merging

### For Deployment:

1. **Supabase RLS**: Ensure Row Level Security policies are properly configured
2. **HTTPS Only**: Always use HTTPS for API communications
3. **Token Management**: Rotate API keys and tokens regularly
4. **Error Logging**: Use Sentry for production error tracking (don't expose sensitive data)

## Known Security Measures

- ✅ Row Level Security (RLS) enabled on all Supabase tables
- ✅ Authentication required for all API endpoints
- ✅ Sentry integration for error tracking (production)
- ✅ Secure credential storage using SharedPreferences
- ✅ HTTPS-only communication with backend

## Checklist Before Production

- [ ] Replace all placeholder API keys in configuration files
- [ ] Enable Supabase RLS policies
- [ ] Configure Sentry DSN for error tracking
- [ ] Set up proper Google Maps API key restrictions
- [ ] Review and test all authentication flows
- [ ] Enable production-grade logging
- [ ] Set up regular security audits
- [ ] Configure proper backup procedures

## Disclosure Policy

We follow a responsible disclosure policy. Security researchers who discover vulnerabilities are requested to:
1. Report the issue privately
2. Allow us reasonable time to fix the issue
3. Not publicly disclose the vulnerability until it has been addressed
