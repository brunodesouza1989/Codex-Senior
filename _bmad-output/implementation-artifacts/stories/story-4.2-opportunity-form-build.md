# Story 4.2 - Criar Formulario Oportunidade Senior

Date: 2026-05-26

Status: deployed-layout-updated

## User Story

As a executivo de vendas,
I want visualizar fase, valor, risco e proxima acao da oportunidade,
So that eu avance a venda com menos cliques.

## Current Deployment

- Form name: `Oportunidade Senior`
- Form id: `810287da-2b59-f111-bec7-6045bdd67b7b`
- Table: `opportunity`
- Source form: `Sales Insights`
- Solution: `nexer_senior_demo_crm_b`

## Automation Result

Created through:

- `C:\codex\senior\.deploy\nexer_senior_demo_crm_b\scripts\Create-SeniorFormClone-WebApi.ps1`

Layout updated through:

- `C:\codex\senior\.deploy\nexer_senior_demo_crm_b\scripts\Update-AccountContactSeniorFormLayout-WebApi.ps1`

Actions completed:

- Cloned the native Opportunity `Sales Insights` main form.
- Added the cloned form to solution `nexer_senior_demo_crm_b`.
- Added first tab `Oportunidade Senior`.
- Added sections:
  - `senior_opp_resumo`
  - `senior_opp_valor`
  - `senior_opp_solucao`
  - `senior_opp_governanca`
  - `senior_opp_interacoes`
- Published Opportunity customizations.
- Exported and unpacked the solution.

Latest export:

- `C:\codex\senior\.deploy\nexer_senior_demo_crm_b\exports\nexer_senior_demo_crm_b_with_core_form_layouts.zip`

## Implemented Fields

- `name`
- `customerid`
- `salesstagecode`
- `ownerid`
- `estimatedvalue`
- `closeprobability`
- `estimatedclosedate`
- `discountpercentage`
- `discountamount`
- `customerneed`
- `proposedsolution`
- `currentsituation`
- `description`
- `purchaseprocess`
- `purchasetimeframe`
- `decisionmaker`
- `pricelevelid`
- `nexer_statusetn`
- `nexer_statuscpqgps`
- `nexer_statuserpsapiens`
- `nexer_statusaprovacaodesconto`
- `nexer_justificativadesconto`
- `nexer_dataaprovacaodesconto`

## Acceptance Criteria Status

- Senior Opportunity form exists: met.
- First fold shows phase, value, probability, expected close date, solution, discount, next action and owner: met.
- Area for ETN/CPQ/GPS/integrations/approval: met with minimal justified `nexer_` simulation fields.
- Native fields used for value/probability/date/owner: met.
