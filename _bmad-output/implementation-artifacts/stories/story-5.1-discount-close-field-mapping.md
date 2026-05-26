# Story 5.1 - Mapear Campos Nativos Para Desconto E Fechamento

Date: 2026-05-26

Status: deployed-minimal-governance-fields

## User Story

As a consultor funcional,
I want validar campos nativos de desconto, receita, quote/order e fechamento,
So that a demo use recursos existentes antes de criar campos novos.

## Native Fields Reused

| Requirement | Field | Decision |
|---|---|---|
| Valor/receita estimada | `estimatedvalue` | Use native |
| Valor real de fechamento | `actualvalue` | Use native |
| Data prevista | `estimatedclosedate` | Use native |
| Data real de fechamento | `actualclosedate` | Use native |
| Status de oportunidade | `statecode`, `statuscode` | Use native |
| Percentual de desconto | `discountpercentage` | Use native |
| Valor de desconto | `discountamount`, `totaldiscountamount`, `totallineitemdiscountamount` | Use native |
| Lista de precos/CPQ simples | `pricelevelid` | Use native |

## Created Minimal Governance Fields

These were created only because no strong native equivalent exists for the demo-specific approval/integration statuses:

| Field | Type | Purpose |
|---|---|---|
| `nexer_statusaprovacaodesconto` | Choice | Nao Solicitada, Pendente, Aprovada, Rejeitada, Escalada |
| `nexer_justificativadesconto` | Memo | Discount request justification |
| `nexer_dataaprovacaodesconto` | DateTime | Approval decision timestamp |
| `nexer_statuscpqgps` | Choice | Simulated CPQ/GPS status |
| `nexer_statuserpsapiens` | Choice | Simulated ERP Sapiens status |
| `nexer_statusetn` | Choice | Simulated ETN status |

## Automation Result

Created through:

- `C:\codex\senior\.deploy\nexer_senior_demo_crm_b\scripts\Ensure-OpportunitySeniorDemoFields-WebApi.ps1`

Actions completed:

- Created missing Opportunity fields.
- Added fields to solution `nexer_senior_demo_crm_b`.
- Published Opportunity metadata.
- Added the fields to the `Oportunidade Senior` form Governance and Integrations section.

## Acceptance Criteria Status

- Native discount/revenue/close/status fields mapped: met.
- Approval status gap identified and justified: met.
- Minimal custom fields deployed for approval/integration demo: met.
