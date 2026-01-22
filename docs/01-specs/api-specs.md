# API Specifications

## Purpose

This document defines the API endpoints, request/response formats, and contracts. Use this as the reference for API implementation and client integration.

---

## Base URL

<!-- TODO: Update with your base URL -->
- Local: `http://localhost:8000`
- Production: `https://api.example.com`

## Authentication

<!-- TODO: Define your authentication method -->
- Method: [Bearer token / API key / Session]
- Header: `Authorization: Bearer <token>`

---

## Endpoints

### [Resource 1]

#### List [Resources]
```
GET /api/v1/resources
```

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| page | integer | No | Page number (default: 1) |
| limit | integer | No | Items per page (default: 20, max: 100) |
| sort | string | No | Sort field |

**Response:**
```json
{
  "data": [
    {
      "id": "uuid",
      "name": "string",
      "created_at": "datetime"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 100
  }
}
```

**Status Codes:**
- 200: Success
- 401: Unauthorized
- 500: Server error

---

#### Get [Resource]
```
GET /api/v1/resources/{id}
```

**Path Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| id | UUID | Yes | Resource identifier |

**Response:**
```json
{
  "id": "uuid",
  "name": "string",
  "created_at": "datetime",
  "updated_at": "datetime"
}
```

**Status Codes:**
- 200: Success
- 404: Not found
- 401: Unauthorized

---

#### Create [Resource]
```
POST /api/v1/resources
```

**Request Body:**
```json
{
  "name": "string",
  "description": "string"
}
```

**Response:**
```json
{
  "id": "uuid",
  "name": "string",
  "created_at": "datetime"
}
```

**Status Codes:**
- 201: Created
- 400: Validation error
- 401: Unauthorized

---

#### Update [Resource]
```
PUT /api/v1/resources/{id}
```

**Request Body:**
```json
{
  "name": "string",
  "description": "string"
}
```

**Response:**
```json
{
  "id": "uuid",
  "name": "string",
  "updated_at": "datetime"
}
```

**Status Codes:**
- 200: Success
- 400: Validation error
- 404: Not found

---

#### Delete [Resource]
```
DELETE /api/v1/resources/{id}
```

**Status Codes:**
- 204: Deleted
- 404: Not found
- 401: Unauthorized

---

## Error Responses

All errors follow this format:

```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable message",
    "details": {}
  }
}
```

### Error Codes

| Code | HTTP Status | Description |
|------|-------------|-------------|
| VALIDATION_ERROR | 400 | Request validation failed |
| UNAUTHORIZED | 401 | Authentication required |
| FORBIDDEN | 403 | Permission denied |
| NOT_FOUND | 404 | Resource not found |
| INTERNAL_ERROR | 500 | Server error |

---

## WebSocket Events (if applicable)

### Connection
```
ws://localhost:8000/ws
```

### Events

#### [Event Name]
```json
{
  "type": "event_name",
  "data": {
    "field": "value"
  }
}
```

---

## Rate Limiting

<!-- TODO: Define rate limits -->
- Limit: [X] requests per [time period]
- Header: `X-RateLimit-Remaining`

---

## Related Documents

- [Functional Requirements](functional-requirements.md) - Feature requirements
- [System Overview](../02-architecture/system-overview.md) - Architecture context
