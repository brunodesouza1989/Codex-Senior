# Story 4.3 - Criar BPF Oportunidade Senior Privado

Date: 2026-05-26

Status: partially-deployed-xaml-blocked

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

## 2026-05-27 Implementation Result

- Created BPF workflow `Oportunidade Senior Privado`.
- Workflow id: `7231fce8-9e59-f111-bec7-000d3a18ea46`.
- Primary entity: `opportunity`.
- State/status: active.
- Added workflow to solution and confirmed it exports/unpacks under Workflows.
- Created Senior process stage metadata records for:
  - Qualificação
  - Desenvolvimento
  - Proposta
  - Negociação
  - Aprovação de Desconto
  - Contrato e Assinatura
  - Fechamento

## Technical Constraint

Dataverse accepted `clientdata` patching but rejected direct XAML replacement with generic `0x80040216`. When activated, the platform regenerates/retains XAML from the source template. This means the workflow component is deployed and active, but the full visual stage replacement still needs a supported designer path or a more complete XAML generation path.

Decision: keep the BPF workflow in the solution as a partial deliverable, avoid unsafe XML guessing, and proceed with demo data/forms/views that carry the end-to-end narrative.
