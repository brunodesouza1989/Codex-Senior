# Story 5.3 - Demonstrar Fechamento Da Jornada Privada

Date: 2026-05-26

Status: ready-for-demo-data

## User Story

As a Sales Ops,
I want fechar a oportunidade e mostrar rastreabilidade de integracao,
So that a demo complete a narrativa de lead a fechamento.

## Demo Flow

1. Lead Senior reaches `Qualificado`.
2. Native qualification creates or links Account, Contact and Opportunity.
3. Account is reviewed through `Conta Senior`.
4. Opportunity is managed through `Oportunidade Senior`.
5. ETN/CPQ/GPS statuses are updated as simulated integration evidence.
6. Discount approval is set to `Aprovada`.
7. Opportunity is closed as won with native close behavior.
8. ERP Sapiens status is updated as simulated traceability.

## Fields / Components

- Native Opportunity close fields:
  - `actualvalue`
  - `actualclosedate`
  - `statecode`
  - `statuscode`
- Simulation fields:
  - `nexer_statuserpsapiens`
  - `nexer_statuscpqgps`
  - `nexer_statusetn`
  - `nexer_statusaprovacaodesconto`

## Acceptance Criteria

- At least one Opportunity can be demonstrated from qualification through close won.
- Discount approval status is visible before close.
- ERP Sapiens status can be shown as simulated after close.
- No real ERP or signing integration is required for MVP.

