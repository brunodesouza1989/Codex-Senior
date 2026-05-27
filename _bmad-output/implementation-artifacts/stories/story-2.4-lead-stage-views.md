# Story 2.4 - Criar Views De Leads Por Etapa

Date: 2026-05-26

Status: deployed-automated

## User Story

As a Pamela/Sales Ops,
I want ver leads por etapa e pendencia,
So that eu priorize acao rapidamente.

## Deployed Views

| View | SavedQueryId |
|---|---|
| Senior 360 \| Leads - Entrada | `009d77e9-2959-f111-bec7-7c1e526b609d` |
| Senior 360 \| Leads - Filtro 1 | `418393ee-2959-f111-bec7-000d3a10f9c5` |
| Senior 360 \| Leads - Filtro 2 | `2f04b7f0-2959-f111-bec7-7c1e526b609d` |
| Senior 360 \| Leads - Agendado | `498393ee-2959-f111-bec7-000d3a10f9c5` |
| Senior 360 \| Leads - Qualificado | `4c8393ee-2959-f111-bec7-000d3a10f9c5` |

## View Design

Each view is a public Lead system view filtered by the active stage of the `Lead Senior` BPF.

Base filter:

- `lead.statecode = 0`
- linked internal BPF table: `nexer_bpf_leadsenior440963552459f111bec60022482557cc`
- BPF instance `statecode = 0`
- BPF instance `statuscode = 1`
- BPF `activestageid` equals the target stage.

Displayed columns:

- `fullname`
- `companyname`
- `leadsourcecode`
- `prioritycode`
- `msdyncrm_scores`
- `ownerid`
- `description`
- `nexer_interessedocliente`
- `createdon`

## Automation Result

Created script:

- `C:\codex\senior\.deploy\nexer_senior_demo_crm_b\scripts\Upsert-LeadSeniorStageViews-WebApi.ps1`

Actions completed:

- Created or updated the five Lead stage views.
- Added each view to solution `nexer_senior_demo_crm_b`.
- Published Lead customizations.
- Exported the solution.
- Unpacked the solution and verified the view XML files.

Latest export:

- `C:\codex\senior\.deploy\nexer_senior_demo_crm_b\exports\nexer_senior_demo_crm_b_with_lead_stage_views.zip`

Latest unpacked folder:

- `C:\codex\senior\.deploy\nexer_senior_demo_crm_b\unpacked`

## Acceptance Criteria Status

- Views for Entrada, Filtro 1, Filtro 2, Agendado and Qualificado exist: met.
- Views show context fields for name, company, source, priority/score, owner and next action: met.
- No new model-driven app was created: met.
