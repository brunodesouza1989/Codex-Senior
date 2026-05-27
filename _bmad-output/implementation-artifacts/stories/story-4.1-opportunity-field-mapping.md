# Story 4.1 - Mapear Campos Nativos De Oportunidade

Date: 2026-05-26

Status: implemented-with-governance-gaps

## User Story

As a consultor funcional,
I want mapear campos nativos de Opportunity,
So that o formulario e BPF reaproveitem valor, probabilidade, forecast, data de fechamento, etapa e owner.

## Native Fields Reused

| Requirement | Field | Decision |
|---|---|---|
| Nome/topico da oportunidade | `name` | Use native |
| Cliente | `customerid`, `parentaccountid`, `parentcontactid` | Use native |
| Valor | `estimatedvalue`, `actualvalue`, `totalamount` | Use native |
| Probabilidade | `closeprobability` | Use native |
| Data prevista | `estimatedclosedate` | Use native |
| Fechamento real | `actualclosedate` | Use native |
| Fase/pipeline | `salesstagecode`, BPF stages | Use native/BPF |
| Owner/responsavel | `ownerid` | Use native |
| Status | `statecode`, `statuscode` | Use native |
| Necessidade/risco/proxima acao | `customerneed`, `customerpainpoints`, `currentsituation`, `description` | Use native |
| Proposta/revisao/feedback | `developproposal`, `completeinternalreview`, `completefinalproposal`, `captureproposalfeedback` | Use native |
| Desconto | `discountpercentage`, `discountamount`, `totaldiscountamount`, `totallineitemdiscountamount` | Use native |

## Gaps With Custom Fields

The following gaps do not have strong native Sales fields and were created with publisher prefix `nexer_` for the demo:

- `nexer_statusaprovacaodesconto`
- `nexer_justificativadesconto`
- `nexer_dataaprovacaodesconto`
- `nexer_statuscpqgps`
- `nexer_statuserpsapiens`
- `nexer_statusetn`

## Acceptance Criteria Status

- Native value/probability/forecast/date/status/owner fields mapped: met.
- Discount/margin/integration gaps identified before creating fields: met.
- New `nexer_` fields justified only for approval/integration simulation: met.
