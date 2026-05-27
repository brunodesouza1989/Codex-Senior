# Story 6.1 - Criar Dados Demonstrativos Criveis

Date: 2026-05-26

Status: deployed

## User Story

As a apresentador da demo,
I want dados ficticios consistentes,
So that a narrativa pareca Senior e nao uma base generica.

## Required Demo Records

- One strategic Account with Senior terminology and commercial context.
- At least two Contacts:
  - decision maker
  - influencer or sponsor
- One Lead tied to Smart Lead / campaign / event origin.
- One Opportunity with:
  - value
  - probability
  - expected close date
  - ETN status
  - CPQ/GPS status
  - discount approval status
  - ERP Sapiens status
- Activities/tasks to support next action narrative.

## Suggested Narrative Data

- Account: `Industrias Modelo Sul`
- Lead source: `Smart Lead - Evento HCM`
- Solution interest: `HCM + ERP Senior`
- Opportunity: `Projeto HCM Senior - Rollout Nacional`
- ETN status: `Processado` or `Simulado`
- CPQ/GPS status: `Processado` or `Simulado`
- Discount approval: `Aprovada`
- ERP Sapiens: `Pendente` before close, `Enviado` after close.

## Acceptance Criteria

- Demo data supports lead -> account -> contact -> opportunity -> approval -> close.
- Names and fields use Senior business language.
- Data is clearly fictitious and safe for presales demo.

## 2026-05-27 Deployment Result

Created through:

- `C:\Users\Bruno Andrade\Documents\Senior\.deploy\nexer_senior_demo_crm_b\scripts\Create-SeniorDemoData-WebApi.ps1`

Records created/validated:

- Account: `Indústrias Modelo Sul`
- Contacts:
  - `Marina Klein`
  - `Rafael Borges`
- Lead: `Smart Lead - Evento HCM Senior - Indústrias Modelo Sul`
- Opportunity: `Projeto HCM Senior - Rollout Nacional`
- Task: `Preparar proposta CPQ/GPS e validação ETN - Demo Senior`

The opportunity includes ETN, CPQ/GPS, ERP Sapiens and discount approval simulation statuses.
