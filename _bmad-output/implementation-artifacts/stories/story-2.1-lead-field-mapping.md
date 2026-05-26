# Story 2.1 - Mapear Campos Nativos De Lead Para Qualificacao Senior

Date: 2026-05-25

Status: ready-for-implementation

## User Story

As a consultor funcional,
I want mapear campos nativos de Lead para o processo Senior,
So that o formulario de Cliente Potencial use o minimo de campos customizados.

## Inputs

- PRD: `C:\codex\senior\_bmad-output\planning-artifacts\prds\prd-senior-2026-05-25\prd.md`
- Epics/stories approved: `C:\codex\senior\_bmad-output\planning-artifacts\epics.md`
- Native field inventory: `C:\codex\senior\_bmad-output\implementation-artifacts\native-field-inventory.md`
- Target solution: `nexer_senior_demo_crm_b`
- Target app: native Sales Hub
- Target table: Lead / Cliente Potencial (`lead`)

## Scope

This story defines the field mapping and build decisions for the Senior Lead qualification experience. It does not create a new model-driven app and does not alter original Sales Hub/Sales Insights forms directly.

## Lead Field Mapping

| Senior demo need | Field to use first | Type | Decision | Build note |
|---|---|---|---:|---|
| Origem | `leadsourcecode` | Native choice | `EXTEND_NATIVE_CHOICE` | Already present in exported solution. Add Senior demo values only if current list is insufficient. |
| Segmento/setor | `industrycode` | Native choice | `EXTEND_NATIVE_CHOICE` | Add Senior verticals if needed: RH, ERP/Gestao Empresarial, Logistica, Agronegocio, Manufatura, Servicos. |
| Nome do contato | `firstname`, `lastname` | Native text | `USE_NATIVE` | Use native qualification behavior to carry into Contact. |
| Empresa | `companyname` | Native text | `USE_NATIVE` | Use native qualification behavior to carry into Account. |
| Cargo | `jobtitle` | Native text | `USE_NATIVE` | Required for stakeholder context. |
| Email | `emailaddress1` | Native email | `USE_NATIVE` | Keep near phone in first fold. |
| Telefone/celular | `telephone1`, `mobilephone` | Native phone | `USE_NATIVE` | Use one primary visible field and one secondary field. |
| Potencial financeiro | `estimatedamount` | Native money | `USE_NATIVE` | Prefer over custom value field. |
| Orcamento | `budgetamount`, `budgetstatus` | Native money/choice | `USE_NATIVE` | Use in qualification checklist. |
| Prioridade | `prioritycode` | Native choice | `EXTEND_NATIVE_CHOICE` | Use for operating priority, not lead score. |
| Temperatura/fit | `leadqualitycode` | Native choice | `EXTEND_NATIVE_CHOICE` | Use Hot/Warm/Cold labels or relabel values on form if safe. |
| Processo de compra | `purchaseprocess` | Native choice | `USE_NATIVE` | Supports committee/individual qualification. |
| Prazo de compra | `purchasetimeframe` | Native choice | `USE_NATIVE` | Supports urgency qualification. |
| Dor principal | `description` or `qualificationcomments` | Native memo | `USE_NATIVE` | Prefer `qualificationcomments` for qualification-specific notes. |
| Produto/linha Senior | `nexer_interessedocliente` or `nexer_linha_interesse` | Existing custom | `USE_EXISTING_CUSTOM` / `NEEDS_REVIEW` | Existing fields found. Validate choice values before creating anything new. |
| Score/Sales Insights | `msdyn_LeadScore`, `msdyn_LeadGrade`, `msdyn_ScoreReasons` | Sales Insights | `NEEDS_REVIEW` | Use only if enabled in the environment. Do not block the first form on this. |
| Proxima acao | Activities/timeline, task due date | Native activities | `USE_NATIVE` | Prefer a task/activity instead of a custom text/date field. |

## Proposed Lead Form Layout

Form name: `Cliente Potencial Senior`

### Header

- `subject`
- `leadsourcecode`
- `leadqualitycode`
- `prioritycode`
- Owner

### Tab: Resumo Senior

Section: Identificacao

- `firstname`
- `lastname`
- `companyname`
- `jobtitle`
- `emailaddress1`
- `telephone1`
- `mobilephone`

Section: Qualificacao Comercial

- `industrycode`
- `estimatedamount`
- `budgetamount`
- `budgetstatus`
- `purchaseprocess`
- `purchasetimeframe`
- `nexer_interessedocliente` or `nexer_linha_interesse`

Section: Dor e Proxima Acao

- `qualificationcomments`
- Timeline / Activities

### Tab: Checklist De Qualificacao

Use native fields and BPF steps to represent checklist gates:

- Necessidade clara: `qualificationcomments`
- Orcamento identificado: `budgetamount` / `budgetstatus`
- Decisor ou comite: `purchaseprocess`
- Prazo: `purchasetimeframe`
- Aderencia Senior: `leadqualitycode`
- Produto/linha: existing interest field after validation

## Proposed BPF Mapping

BPF name: `Lead Senior`

| Stage | Purpose | Fields/steps |
|---|---|---|
| Entrada | Capture basic source and identity. | `leadsourcecode`, `companyname`, `firstname`, `lastname`, `emailaddress1`, `telephone1` |
| Filtro 1 | Validate segment and interest. | `industrycode`, interest field, `leadqualitycode` |
| Filtro 2 | Validate need, budget and timing. | `qualificationcomments`, `budgetstatus`, `budgetamount`, `purchasetimeframe` |
| Agendado | Confirm next action using activity timeline. | Required open appointment/task, owner |
| Qualificado | Confirm conversion readiness. | `purchaseprocess`, `estimatedamount`, `leadqualitycode` |

## Choice Value Recommendations

### `leadsourcecode`

Validate current values first. Suggested additions only if missing:

- Evento Senior
- Indicacao
- Campanha Digital
- Parceiro Nexer
- Outbound
- Webinar

### `industrycode`

Validate reuse of existing native industry values first. Suggested Senior-friendly values only if allowed:

- Tecnologia
- Servicos
- Manufatura
- Varejo
- Logistica
- Agronegocio
- Educacao
- Saude

### Existing Interest Field

Validate whether `nexer_interessedocliente`, `nexer_linha_interesse` or `new_interesse` is the right existing field. Suggested Senior solution values:

- HCM / RH
- ERP / Gestao Empresarial
- Logistica
- Agronegocio
- Manufatura
- Performance Corporativa
- Plataforma / Integracoes

## Acceptance Criteria Trace

- AC1: Native fields mapped for origem, status/rating, fonte, empresa, receita, telefone, email and cargo.
- AC2: Choice edits proposed before creating new choices.
- AC3: New `nexer_` Lead fields are not recommended for first implementation wave; existing custom interest fields must be reviewed first.

## Implementation Tasks

1. Open solution `nexer_senior_demo_crm_b` in Maker Portal.
2. Add required native Lead columns to the solution if missing from solution metadata.
3. Validate existing choice values for `leadsourcecode`, `industrycode`, `prioritycode`, `leadqualitycode`.
4. Validate existing interest custom fields and choose one canonical field for the demo.
5. Create or clone new form `Cliente Potencial Senior`.
6. Add form layout sections as defined above.
7. Create BPF `Lead Senior` with the proposed stages.
8. Publish customizations.
9. Export/unpack solution via PAC and update deployment log.

## Out Of Scope

- Creating a new model-driven app.
- Editing original Sales Hub/Sales Insights forms directly.
- Creating new custom Lead fields before existing/native options are validated in Maker Portal.
- Building Account, Contact or Opportunity forms.

## Next Story

Proceed to Story 2.2 after Maker Portal validation of choice values and the canonical interest field.
