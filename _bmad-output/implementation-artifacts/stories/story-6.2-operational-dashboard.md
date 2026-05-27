# Story 6.2 - Criar Dashboard Operacional

Date: 2026-05-26

Status: deployed

## User Story

As a Pamela/Sales Ops,
I want ver leads, pendencias e aprovacao em painel operacional,
So that eu acompanhe fluidez e gargalos.

## Dashboard Scope

- Name: `Senior 360 | Operacional`
- Audience: Sales Ops, LDR, SDR, BDR
- App premise: available through native Sales Hub, no new model-driven app.

## Components

- Leads by Senior stage.
- Leads scheduled / pending action.
- Open opportunities by owner.
- Opportunities with ETN/CPQ/GPS pending.
- Opportunities with discount approval pending.

## Data Sources

- Lead savedqueries from Story 2.4.
- Opportunity savedqueries from Story 4.5.
- Native activities/timeline where possible.

## Acceptance Criteria

- Dashboard exists in solution `nexer_senior_demo_crm_b`.
- Dashboard can be opened from native Sales Hub dashboard area.
- It uses deployed views/charts and does not require external integration.

## 2026-05-27 Status

Deployed automatically through Web API.

Created dashboard:

- `Senior 360 | Operacional Presales`

The dashboard uses deployed Opportunity views and existing Opportunity charts for:

- Pipeline by stage.
- Opportunity status.
- Open pipeline grid.
- Discount and approval grid.

Validation evidence:

- Dataverse systemform id: `acd788bc-b459-f111-bec7-7c1e526b609d`
- Exported in solution folder: `C:\Users\Bruno Andrade\Documents\Senior\.deploy\nexer_senior_demo_crm_b\unpacked\Dashboards\{acd788bc-b459-f111-bec7-7c1e526b609d}.xml`
