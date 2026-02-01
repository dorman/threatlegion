# Contributing to ThreatLegion

Thank you for your interest in contributing to ThreatLegion! This document provides guidelines and instructions for contributing.

## Code of Conduct

Be respectful, inclusive, and professional in all interactions.

## How to Contribute

### Reporting Bugs

1. Check if the bug has already been reported in Issues
2. If not, create a new issue with:
   - Clear title and description
   - Steps to reproduce
   - Expected vs actual behavior
   - System information (OS, Ruby version, etc.)
   - Screenshots if applicable

### Suggesting Features

1. Check if the feature has been suggested
2. Create a new issue with:
   - Clear description of the feature
   - Use cases and benefits
   - Potential implementation approach

### Pull Requests

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Write or update tests
5. Ensure all tests pass (`rails test`)
6. Run RuboCop (`rubocop`)
7. Commit your changes (`git commit -m 'Add amazing feature'`)
8. Push to your branch (`git push origin feature/amazing-feature`)
9. Open a Pull Request

## Development Setup

See SETUP.md for detailed setup instructions.

## Coding Standards

### Ruby Style Guide

- Follow the Ruby Style Guide
- Use RuboCop for linting
- Run `rubocop -a` to auto-fix issues

### Commit Messages

- Use present tense ("Add feature" not "Added feature")
- Use imperative mood ("Move cursor to..." not "Moves cursor to...")
- Limit first line to 72 characters
- Reference issues and pull requests

Example:
```
Add MITRE ATT&CK technique validation

- Validate technique ID format
- Add error messages for invalid IDs
- Update tests

Fixes #123
```

## Testing

- Write tests for new features
- Ensure existing tests pass
- Aim for good test coverage

```bash
# Run all tests
rails test

# Run specific test file
rails test test/models/threat_test.rb
```

## Documentation

- Update README.md for user-facing changes
- Add inline comments for complex logic
- Update API documentation
- Include examples in documentation

## Security

- Never commit sensitive data (API keys, passwords, etc.)
- Report security vulnerabilities privately to security@threatlegion.local
- Follow secure coding practices

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
