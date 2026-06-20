# Backend contract — Organization screen (mobile)

The mobile Organization screen reads its data from the **backend** (`backend`, Spring DDD) through the
**api-gw** (`api-gw`, NestJS) over HTTP. All requests send `Authorization: Bearer <supabase access_token>`,
which the gateway's `SupabaseAuthGuard` validates. The api-gw proxies `/api/v1/organizations/**` →
backend `/restaurant/api/v1/organizations/**`.

> Note: `profiles.id == auth.users.id`, so the mobile auth uid **is** the backend `profileId`.

The mobile code (`lib/features/organization/**`) is written against this contract. **Two additions are
required on the backend/api-gw** before the screen can load data end to end. Until then the screen shows its
loading/empty/error states.

## 1. Resolve the user's organizations — NEW (missing today)

```
GET /api/v1/organizations?memberId={profileId}
→ 200 OrganizationResponse[]
```

Returns the organizations the profile belongs to (member) or owns. The mobile app passes its own auth uid
as `memberId` and uses the first result as the primary organization.

- api-gw already proxies `organizations` and forwards the query string (`req.originalUrl`) — **no gateway
  change needed**.
- Backend: add `OrganizationMemberRepository.findAllByProfileId(...)` (+ a `ListOrganizationsByMember`
  query/handler), or expose `/organizations/mine` if the gateway is later changed to forward the requester
  id on GET.

`OrganizationResponse` (already exists) provides the fields the screen uses:
`id, name, imageUrl, addressLineOne, addressLineTwo, addressReference, ownedBy`
(GPS `latitude/longitude` are ignored by mobile — reference-point-only).

## 2. Members enriched with profile data — NEW (extend existing)

```
GET /api/v1/organizations/{organizationId}/members
→ 200 OrganizationMemberResponse[]   // with profile fields added
```

Today `OrganizationMemberResponse` returns only `id, profileId, organizationId, invitationId, joinedAt,
securityPermission, iotPermission, internalControlPermission`. **Add the member's profile data** so the list
renders in a single call (no N+1):

```jsonc
{
  "id": "…",
  "profileId": "…",
  "fullName": "Carlos Mendez",      // NEW (join profiles)
  "email": "c.mendez@soulware.com", // NEW
  "avatarUrl": null,                 // NEW (nullable)
  "securityPermission": "LIEUTENANT",
  "iotPermission": "ASSIGNEE",
  "internalControlPermission": "NONE"
}
```

The mobile badge shows the **highest** of the three permission levels
(`admin > lieutenant > assignee > none`).

## Mobile configuration

- `.env` / `.env.example`: `API_GATEWAY_URL` = base URL of the api-gw (e.g.
  `https://api.cocina360.soulware.site`). Pending a value; while empty, calls fail fast with a clear error.
- HTTP client: `lib/shared/infrastructure/remote/api_gateway_client.dart`.
- Calls: `lib/features/organization/data/services/organization_remote_service.dart`.
