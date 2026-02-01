# ThreatLegion API Documentation

## Base URL

```
http://localhost:3000/api/v1
```

## Authentication

All API endpoints require authentication using Bearer tokens.

### Get API Token

**Endpoint:** `POST /api/v1/auth/login`

**Request:**
```json
{
  "email": "admin@threatlegion.local",
  "password": "changeme123"
}
```

**Response:**
```json
{
  "api_token": "a1b2c3d4e5f6...",
  "user": {
    "id": 1,
    "email": "admin@threatlegion.local",
    "role": "admin"
  }
}
```

### Regenerate Token

**Endpoint:** `POST /api/v1/auth/regenerate_token`

**Headers:**
```
Authorization: Bearer YOUR_TOKEN
```

**Response:**
```json
{
  "api_token": "new_token_here"
}
```

## Threats

### List Threats

**Endpoint:** `GET /api/v1/threats`

**Query Parameters:**
- `page` - Page number (default: 1)
- `per_page` - Items per page (default: 25)
- `q[name_cont]` - Search by name
- `q[threat_type_eq]` - Filter by type
- `q[severity_eq]` - Filter by severity
- `q[status_eq]` - Filter by status

**Example:**
```bash
curl http://localhost:3000/api/v1/threats?page=1&per_page=10 \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Response:**
```json
{
  "threats": [
    {
      "id": 1,
      "name": "APT29 Phishing Campaign",
      "threat_type": "apt",
      "severity": "critical",
      "status": "active",
      "description": "...",
      "confidence_score": 95,
      "first_seen": "2026-01-01T00:00:00.000Z",
      "last_seen": "2026-01-29T00:00:00.000Z",
      "created_at": "2026-01-30T00:00:00.000Z",
      "updated_at": "2026-01-30T00:00:00.000Z",
      "user_id": 1,
      "indicators": [...],
      "mitre_attacks": [...],
      "vulnerabilities": [...]
    }
  ],
  "meta": {
    "current_page": 1,
    "total_pages": 5,
    "total_count": 123
  }
}
```

### Get Threat

**Endpoint:** `GET /api/v1/threats/:id`

**Example:**
```bash
curl http://localhost:3000/api/v1/threats/1 \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Create Threat

**Endpoint:** `POST /api/v1/threats`

**Request:**
```json
{
  "threat": {
    "name": "New Threat",
    "threat_type": "malware",
    "severity": "high",
    "status": "active",
    "description": "Detailed description",
    "confidence_score": 85,
    "first_seen": "2026-01-30T00:00:00Z",
    "last_seen": "2026-01-30T12:00:00Z"
  }
}
```

**Response:**
```json
{
  "id": 2,
  "name": "New Threat",
  ...
}
```

### Update Threat

**Endpoint:** `PUT /api/v1/threats/:id`

**Request:**
```json
{
  "threat": {
    "status": "mitigated",
    "description": "Updated description"
  }
}
```

### Delete Threat

**Endpoint:** `DELETE /api/v1/threats/:id`

**Response:** `204 No Content`

## Indicators

### List Indicators

**Endpoint:** `GET /api/v1/indicators`

**Query Parameters:**
- `page` - Page number
- `per_page` - Items per page (default: 50)
- `q[indicator_type_eq]` - Filter by type (ip, domain, url, hash, email, file_path, registry_key)
- `q[value_cont]` - Search by value

**Example:**
```bash
curl http://localhost:3000/api/v1/indicators?q[indicator_type_eq]=ip \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Get Indicator

**Endpoint:** `GET /api/v1/indicators/:id`

### Create Indicator

**Endpoint:** `POST /api/v1/indicators`

**Request:**
```json
{
  "indicator": {
    "indicator_type": "ip",
    "value": "192.168.1.100",
    "threat_id": 1,
    "confidence": 90,
    "source": "Internal Analysis",
    "first_seen": "2026-01-30T00:00:00Z",
    "last_seen": "2026-01-30T12:00:00Z",
    "tags": ["malicious", "c2"]
  }
}
```

### Update Indicator

**Endpoint:** `PUT /api/v1/indicators/:id`

### Delete Indicator

**Endpoint:** `DELETE /api/v1/indicators/:id`

### Search Indicators

**Endpoint:** `GET /api/v1/indicators/search?value=192.168`

**Response:**
```json
[
  {
    "id": 1,
    "indicator_type": "ip",
    "value": "192.168.1.100",
    ...
  }
]
```

## Vulnerabilities

### List Vulnerabilities

**Endpoint:** `GET /api/v1/vulnerabilities`

**Query Parameters:**
- `page` - Page number
- `per_page` - Items per page (default: 25)

### Get Vulnerability

**Endpoint:** `GET /api/v1/vulnerabilities/:id`

**Response:**
```json
{
  "id": 1,
  "cve_id": "CVE-2024-1234",
  "cvss_score": 9.8,
  "description": "Critical RCE vulnerability",
  "published_date": "2026-01-20T00:00:00.000Z",
  "affected_products": "Product 1.x, Product 2.x",
  "threat_id": 1,
  "severity_level": "Critical",
  "created_at": "2026-01-30T00:00:00.000Z",
  "updated_at": "2026-01-30T00:00:00.000Z"
}
```

### Create Vulnerability

**Endpoint:** `POST /api/v1/vulnerabilities`

**Request:**
```json
{
  "vulnerability": {
    "cve_id": "CVE-2024-5678",
    "cvss_score": 7.5,
    "description": "High severity vulnerability",
    "published_date": "2026-01-25T00:00:00Z",
    "affected_products": "Application 3.x",
    "threat_id": 1
  }
}
```

## MITRE ATT&CK

### List MITRE ATT&CK Techniques

**Endpoint:** `GET /api/v1/mitre_attacks`

### Create MITRE ATT&CK Mapping

**Endpoint:** `POST /api/v1/mitre_attacks`

**Request:**
```json
{
  "mitre_attack": {
    "threat_id": 1,
    "tactic": "Initial Access",
    "technique": "Spearphishing Attachment",
    "technique_id": "T1566.001",
    "description": "Adversaries send spearphishing emails..."
  }
}
```

## Error Responses

### 401 Unauthorized

```json
{
  "error": "Unauthorized"
}
```

### 422 Unprocessable Entity

```json
{
  "errors": [
    "Name can't be blank",
    "Severity is not included in the list"
  ]
}
```

### 404 Not Found

```json
{
  "error": "Record not found"
}
```

## Rate Limiting

Currently no rate limiting is implemented. This may be added in future versions.

## Pagination

All list endpoints support pagination:

- `page` - Current page number (starts at 1)
- `per_page` - Number of items per page

Response includes metadata:
```json
{
  "data": [...],
  "meta": {
    "current_page": 1,
    "total_pages": 10,
    "total_count": 250
  }
}
```

## Filtering and Search

Use Ransack query parameters for advanced filtering:

- `q[field_cont]` - Contains
- `q[field_eq]` - Equals
- `q[field_gt]` - Greater than
- `q[field_lt]` - Less than
- `q[field_gteq]` - Greater than or equal
- `q[field_lteq]` - Less than or equal

Example:
```bash
curl "http://localhost:3000/api/v1/threats?q[name_cont]=APT&q[severity_eq]=critical" \
  -H "Authorization: Bearer YOUR_TOKEN"
```
