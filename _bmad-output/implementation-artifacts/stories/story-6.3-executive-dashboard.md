# Story 6.3 - Criar Dashboard Executivo

Date: 2026-05-26

Status: ready-for-implementation

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

