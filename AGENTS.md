# Project Rules & Architecture - OpenCode Go Usage Plasmoid

© Mayanktaker Computers & Web Development | https://mayanktaker.com

## Code & Structure Conventions
- **Credit Header:** Every QML, JavaScript, and configuration source file must include the header:
  `// © Mayanktaker Computers & Web Development | https://mayanktaker.com`
- **Default Endpoint:** OpenCode Go usage data is retrieved via the workspace endpoint:
  `https://opencode.ai/workspace/{workspaceId}/go`
- **Response Handling:** `api.js` handles both raw JSON and HTML page payloads (e.g. Next.js `__NEXT_DATA__` script blocks or text extraction) to prevent `JSON.parse` failures.
- **Authentication:** Auth cookies are passed via `Cookie` header (`auth=<token>; session=<token>`) and `Authorization: Bearer <token>` for full compatibility with OpenAuth.
- **Error Handling:** When API errors or invalid credentials occur, the widget clears stale mock data and displays clean error messages without forcing Demo Mode.
