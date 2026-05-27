# Story 5.2 - Criar Experiencia De Solicitacao De Desconto

Date: 2026-05-26

Status: partially-deployed-fields-ready

## User Story

As a executivo,
I want solicitar desconto com justificativa e status,
So that a aprovacao seja demonstravel e auditavel.

## Current Deployment

The minimum fields for a demonstrable discount approval are deployed on Opportunity:

- `discountpercentage`
- `discountamount`
- `nexer_statusaprovacaodesconto`
- `nexer_justificativadesconto`
- `nexer_dataaprovacaodesconto`

The fields are on the `Oportunidade Senior` form in the Governance and Integrations section.

## MVP Demo Behavior

- Sales executive fills discount percentage/amount.
- Sales executive sets `nexer_statusaprovacaodesconto` to `Pendente`.
- Sales executive records justification in `nexer_justificativadesconto`.
- Approver simulation sets status to `Aprovada`, `Rejeitada` or `Escalada`.
- Decision timestamp is recorded in `nexer_dataaprovacaodesconto`.

## Future Automation

- Add a Power Automate flow or command button to set `Pendente` and timestamp automatically.
- Add approver field only if the demo needs reporting/filtering by approver.

## Acceptance Criteria Status

- Status field exists: met.
- Justification field exists: met.
- Approval date field exists: met.
- Manual demo flow is possible: met.
- Automated approval routing: deferred.

