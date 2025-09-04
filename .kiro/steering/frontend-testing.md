# Frontend Testing Guidelines

## Testing Approach for Flutter App (/app)

When working on the Flutter frontend application in the `/app` directory, follow these testing guidelines:

### DO NOT Write Tests
- **No unit tests**: Do not create or write unit test files
- **No widget tests**: Do not create widget test files  
- **No integration tests**: Do not create integration test files
- **No test code**: Avoid writing any test-related code during development

### Use Static Analysis Instead
- **Primary validation**: Use `flutter analyze` for code quality checks
- **Dart MCP server**: Leverage the Dart MCP server tools for analysis
- **Code validation**: Rely on static analysis to catch issues

### Validation Commands
```bash
# Use this for code validation
flutter analyze

# Use Dart MCP server tools when available:
# - mcp_dart_analyze_files
# - mcp_dart_dart_format  
# - mcp_dart_dart_fix
```

### Focus Areas
- **Code quality**: Ensure clean, readable code
- **Static analysis**: Fix all analyzer warnings and errors
- **Architecture**: Follow clean architecture patterns
- **Performance**: Write efficient, optimized code

### Rationale
- Faster development iteration
- Focus on implementation over test coverage
- Rely on static analysis for immediate feedback
- Use MCP tools for comprehensive code validation

This approach prioritizes rapid development while maintaining code quality through static analysis tools.