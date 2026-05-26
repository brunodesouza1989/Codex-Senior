# Story 4.5 - Criar Views De Oportunidades Senior

Date: 2026-05-26

Status: deployed-automated

## Objective

Deliver FR26: views of opportunities by pipeline, stage, owner and pending action, using native Opportunity fields and the native Sales Hub app.

## Deployed Views

| View | SavedQueryId |
|---|---|
| Senior 360 \| Oportunidades - Pipeline aberto | `7efd867f-2e59-f111-bec7-6045bdd670dd` |
| Senior 360 \| Oportunidades - Minha carteira | `7c1b637f-2e59-f111-bec6-0022482557cc` |
| Senior 360 \| Oportunidades - Proposta e CPQ/GPS | `1c48dd82-2e59-f111-bec7-000d3a10f9c5` |
| Senior 360 \| Oportunidades - Desconto e aprovacao | `871b637f-2e59-f111-bec6-0022482557cc` |
| Senior 360 \| Oportunidades - Fechamento 30 dias | `fb9fde83-2e59-f111-bec7-7c1e526b609d` |
| Senior 360 \| Oportunidades - Ganhas | `1f48dd82-2e59-f111-bec7-000d3a10f9c5` |

## Automation Result

Created through:

- `C:\codex\senior\.deploy\nexer_senior_demo_crm_b\scripts\Upsert-OpportunitySeniorViews-WebApi.ps1`

Actions completed:

- Created or updated six Opportunity system views.
- Added each view to solution `nexer_senior_demo_crm_b`.
- Published Opportunity customizations.
- Exported and unpacked the solution.

Latest export:

- `C:\codex\senior\.deploy\nexer_senior_demo_crm_b\exports\nexer_senior_demo_crm_b_with_opportunity_governance.zip`

## Acceptance Criteria Status

- Views by pipeline/stage/owner/pending action exist: met.
- Views use native fields where available: met.
- No new model-driven app was created: met.
