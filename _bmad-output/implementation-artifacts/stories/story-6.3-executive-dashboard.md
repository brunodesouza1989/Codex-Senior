# Story 6.3 - Criar Dashboard Executivo

Date: 2026-05-26

Status: deployed

## User Story

As a diretoria comercial,
I want ver pipeline consolidado e indicadores chave,
So that eu avalie previsibilidade e riscos.

## Dashboard Scope

- Name: `Senior 360 | Executivo`
- Audience: Diretoria comercial, VP Comercial, Gestao de Vendas

## Components

- Pipeline by stage.
- Forecast by expected close period.
- Top opportunities.
- Opportunities by line of business / solution interest where available.
- Discount approvals pending/escalated.
- Simulated integration health: ETN, CPQ/GPS, ERP Sapiens.

## MVP Metrics

- Total open pipeline: native `estimatedvalue`.
- Weighted pipeline: native `estimatedvalue` + `closeprobability` where chart support allows.
- Close forecast: native `estimatedclosedate`.
- Won opportunities: native state/status and actual value.

## Acceptance Criteria

- Dashboard exists in solution `nexer_senior_demo_crm_b`.
- Dashboard answers pipeline, forecast, risk and governance questions.
- It uses native Opportunity data and existing custom status fields only where justified.

## 2026-05-27 Status

Deployed automatically through Web API.

Created dashboard:

- `Senior 360 | Executivo Pipeline`

The dashboard uses deployed Opportunity views and existing Opportunity charts for:

- Forecast by expected close month.
- Pipeline by business unit.
- Closing in 30 days.
- Won opportunities.

Validation evidence:

- Dataverse systemform id: `b5e352bb-b459-f111-bec7-6045bdd67b7b`
- Exported in solution folder: `C:\Users\Bruno Andrade\Documents\Senior\.deploy\nexer_senior_demo_crm_b\unpacked\Dashboards\{b5e352bb-b459-f111-bec7-6045bdd67b7b}.xml`
