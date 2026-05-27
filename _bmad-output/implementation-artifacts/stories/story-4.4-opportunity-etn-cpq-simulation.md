# Story 4.4 - Simular ETN E CPQ/GPS Na Oportunidade

Date: 2026-05-26

Status: partially-deployed-fields-ready

## User Story

As a executivo de vendas,
I want acionar ETN e simular proposta CPQ/GPS,
So that eu mostre continuidade operacional sem sair da oportunidade.

## Current Deployment

The `Oportunidade Senior` form already contains simulation status fields:

- `nexer_statusetn`
- `nexer_statuscpqgps`
- `nexer_statuserpsapiens`

These fields are included in solution `nexer_senior_demo_crm_b` and displayed in the Governance and Integrations section.

## Remaining Implementation Options

### MVP Demo Path

- Use the deployed status fields directly in the opportunity form.
- Demonstrator changes status manually during the narrative:
  - ETN: `Pendente` -> `Enviado` -> `Processado` or `Simulado`
  - CPQ/GPS: `Pendente` -> `Enviado` -> `Processado` or `Simulado`

### Enhanced Automation Path

- Add command buttons or Power Automate flows later to update the status fields.
- Optionally create or relate a Case/Activity record when ETN is triggered.

## Acceptance Criteria Status

- Opportunity shows ETN status: met.
- Opportunity shows CPQ/GPS status: met.
- Opportunity supports traceable simulation without external API: met.
- Automated action button/Case creation: deferred.

