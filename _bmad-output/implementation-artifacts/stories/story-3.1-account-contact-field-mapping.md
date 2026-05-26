# Story 3.1 - Mapear Campos Nativos De Conta E Contato

Date: 2026-05-26

Status: documented-for-validation

## User Story

As a consultor funcional,
I want mapear campos nativos de Account e Contact,
So that Radar da Conta e Relacionamento usem o maximo do modelo nativo.

## Native Fields To Reuse

### Account

| Requirement | Native field/component | Decision |
|---|---|---|
| Nome da conta | `name` | Use native |
| Codigo/identificador | `accountnumber` | Use native when available |
| Site | `websiteurl` | Use native |
| Telefone | `telephone1` | Use native |
| Segmento/setor | `industrycode` | Use native choice before creating `nexer_segmento` |
| Receita/potencial | `revenue` | Use native |
| Porte | `numberofemployees`, `accountclassificationcode`, `accountratingcode` | Use native first |
| Conta matriz/grupo | `parentaccountid` | Use native |
| Contato principal | `primarycontactid` | Use native |
| Responsavel | `ownerid` | Use native |
| Contexto e riscos | `description` | Use native for demo notes before custom memo |
| Oportunidades abertas | Native Account -> Opportunity relationship/subgrid | Use native subgrid |
| Contatos/decisores | Native Account -> Contact relationship/subgrid | Use native subgrid |
| Atividades/proxima acao | Timeline/activities | Use native |

### Contact

| Requirement | Native field/component | Decision |
|---|---|---|
| Nome | `firstname`, `lastname`, `fullname` | Use native |
| Cargo | `jobtitle` | Use native |
| Conta | `parentcustomerid` | Use native |
| Email | `emailaddress1` | Use native |
| Telefone/celular | `telephone1`, `mobilephone` | Use native |
| Preferencia de contato | `preferredcontactmethodcode` | Use native |
| Responsavel | `ownerid` | Use native |
| Contexto de relacionamento | `description` | Use native for demo notes |
| Interacoes | Timeline/activities | Use native |

## Gaps / Senior-Specific Semantics

- Papel na decisao, influencia, sponsor/opositor and stakeholder stance do not have a strong single native field in Contact.
- MVP recommendation: represent these with native `description`/timeline and opportunity-contact relationship notes in the first demo iteration.
- If the demo requires filtering/reporting by stakeholder role, create a justified `nexer_` choice in a later story.

## Acceptance Criteria Status

- Native Account/Contact fields identified: met.
- Native relationships/subgrids prioritized: met.
- Custom field gap for stakeholder role documented: met.

