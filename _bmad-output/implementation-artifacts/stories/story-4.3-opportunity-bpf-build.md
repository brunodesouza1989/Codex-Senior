# Story 4.3 - Criar BPF Oportunidade Senior Privado

Date: 2026-05-26

Status: ready-for-implementation

## User Story

As a executivo de vendas,
I want seguir as etapas comerciais Senior no BPF,
So that a demo mostre venda complexa com governanca.

## Target BPF

- Name: `Oportunidade Senior Privado`
- Primary table: `opportunity`
- Solution: `nexer_senior_demo_crm_b`
- App premise: use native Sales Hub; do not create a new model-driven app.

## Stages

1. Qualificacao
2. Desenvolvimento
3. Proposta
4. Negociacao
5. Aprovacao de Desconto
6. Contrato e Assinatura
7. Fechamento

## Candidate Step Fields

| Stage | Fields |
|---|---|
| Qualificacao | `customerid`, `customerneed`, `decisionmaker`, `purchaseprocess` |
| Desenvolvimento | `proposedsolution`, `currentsituation`, `purchasetimeframe`, `ownerid` |
| Proposta | `pricelevelid`, `estimatedvalue`, `closeprobability`, `nexer_statuscpqgps` |
| Negociacao | `discountpercentage`, `discountamount`, `nexer_statusetn` |
| Aprovacao de Desconto | `nexer_statusaprovacaodesconto`, `nexer_justificativadesconto`, `nexer_dataaprovacaodesconto` |
| Contrato e Assinatura | `estimatedclosedate`, `nexer_statuserpsapiens` |
| Fechamento | `actualclosedate`, `actualvalue`, `statuscode` |

## Implementation Notes

- Prefer the Web API workflow pattern already proven for `Lead Senior`.
- Create from an existing Opportunity BPF template where possible, activate once to generate the internal BPF entity, then patch the definition and publish.
- Add generated BPF table and workflow to solution after creation.
- Export/unpack after deployment and record workflow id, generated table name and stage ids.

## Acceptance Criteria

- BPF exists in `nexer_senior_demo_crm_b`.
- Stages match the Senior privado flow.
- Native fields are used where available.
- Discount approval status is visible in the approval stage.
- No new model-driven app or sitemap is created.

