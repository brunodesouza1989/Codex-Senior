# Native Field Inventory - Senior Demo CRM B

Date: 2026-05-25

Status: approved-for-build

## Purpose

Validate native Dynamics 365 Sales / Dataverse fields before creating any new `nexer_*` fields.

Rule:

- Reuse native fields when they satisfy the Senior demo requirement.
- Edit/add values to existing choices when appropriate.
- Create `nexer_*` fields only when no native field fits semantically or operationally.
- Keep all components in solution `nexer_senior_demo_crm_b`.
- Use native Sales Hub app; do not create a new model-driven app.

## Validation Sources

- Local exported solution metadata:
  - `C:\codex\senior\.deploy\nexer_senior_demo_crm_b\unpacked\Entities\Lead\Entity.xml`
  - `C:\codex\senior\.deploy\nexer_senior_demo_crm_b\unpacked\Entities\Account\Entity.xml`
  - `C:\codex\senior\.deploy\nexer_senior_demo_crm_b\unpacked\Entities\Contact\Entity.xml`
  - `C:\codex\senior\.deploy\nexer_senior_demo_crm_b\unpacked\Entities\Opportunity\Entity.xml`
- Microsoft table/entity references checked on 2026-05-25:
  - Lead: https://learn.microsoft.com/en-us/dynamics365/developer/reference/entities/lead
  - Account: https://learn.microsoft.com/en-us/power-apps/developer/data-platform/reference/entities/account
  - Contact: https://learn.microsoft.com/en-us/power-apps/developer/data-platform/reference/entities/contact
  - Opportunity: https://learn.microsoft.com/en-us/dynamics365/developer/reference/entities/opportunity

## Decision Legend

- `USE_NATIVE`: use existing native field as-is.
- `EXTEND_NATIVE_CHOICE`: use existing native choice and add/edit allowed values where safe.
- `USE_EXISTING_CUSTOM`: reuse an existing custom field already present in the environment/solution.
- `CREATE_NEXER_FIELD`: create new custom field with `nexer_` prefix.
- `NEEDS_REVIEW`: requires manual validation in Maker Portal or with business owner before build.

## Executive Decision

The first implementation wave should avoid new custom fields for common Sales concepts. Lead source, industry/segment, rating, budget, purchase timing, estimated value, probability, account revenue, contact role basics, opportunity value/date/probability/discount and pipeline phase all have native candidates.

New `nexer_*` fields should be limited to Senior-specific demo semantics that do not map cleanly to native Sales metadata, especially simulated integration statuses, approval workflow status/details, Senior solution line taxonomy if native industry/product fields are insufficient, and any demo-only checklist controls that cannot be represented by BPF steps or existing qualification fields.

## Lead (`lead`)

| Requirement | Preferred field | Decision | Notes |
|---|---|---:|---|
| Origem do lead | `leadsourcecode` | `EXTEND_NATIVE_CHOICE` | Native and already present in exported solution. Add Senior/demo sources only if existing values are insufficient. |
| Segmento/setor | `industrycode` | `EXTEND_NATIVE_CHOICE` | Native lead industry field exists per Microsoft reference. Prefer extending values for Senior verticals before creating custom field. |
| Nome, empresa, contato | `firstname`, `lastname`, `companyname`, `emailaddress1`, `telephone1`, `mobilephone`, `jobtitle` | `USE_NATIVE` | Native lead/contact capture fields. Add to new form if absent from cloned layout. |
| Potencial financeiro | `estimatedamount` | `USE_NATIVE` | Native money field for estimated lead revenue. Prefer over new value field. |
| Orçamento | `budgetamount`, `budgetstatus` | `USE_NATIVE` | Native budget amount/status. Useful for qualification checklist. |
| Prioridade | `prioritycode` | `EXTEND_NATIVE_CHOICE` | Native choice. Can be relabeled/extended cautiously for demo priority. |
| Temperatura/qualidade | `leadqualitycode` | `EXTEND_NATIVE_CHOICE` | Native Hot/Warm/Cold rating. Use for score visual or Senior fit classification when possible. |
| Processo de compra | `purchaseprocess` | `USE_NATIVE` | Native individual/committee/unknown choice. Fits B2B buying process. |
| Prazo de compra | `purchasetimeframe` | `USE_NATIVE` | Native timing field. Fits qualification gates. |
| Comentarios de qualificacao | `qualificationcomments` | `USE_NATIVE` | Native memo for qualification rationale. |
| Dor principal | `description` or `qualificationcomments` | `USE_NATIVE` | Use native memo before custom field. If the form needs a dedicated field label, consider relabeling on form only. |
| Produto/linha de interesse | `nexer_interessedocliente`, `nexer_linha_interesse`, `new_interesse` | `USE_EXISTING_CUSTOM` / `NEEDS_REVIEW` | Existing custom fields are present. Validate values and ownership before creating a new field. |
| Score preditivo/Sales Insights | `msdyn_LeadScore`, `msdyn_LeadGrade`, `msdyn_ScoreReasons` | `NEEDS_REVIEW` | Native/Sales Insights metadata exists in Microsoft reference, but not exported in current solution. Confirm enabled in this environment before use. |
| Etapas Entrada, Filtro 1, Filtro 2, Agendado, Qualificado | BPF process/stages | `USE_NATIVE` | Model as a new BPF, not as a data field. |

## Account (`account`)

| Requirement | Preferred field | Decision | Notes |
|---|---|---:|---|
| Nome da conta | `name` | `USE_NATIVE` | Native primary name. |
| Codigo/CNPJ/identificador | `accountnumber` | `USE_NATIVE` / `NEEDS_REVIEW` | Native account number supports business identifier up to 20 chars. Validate whether CNPJ mask/format is needed. |
| Setor/segmento | `industrycode` | `EXTEND_NATIVE_CHOICE` | Native account industry. Prefer Senior vertical values here. |
| Subsegmento | `nexer_subsegmento` | `USE_EXISTING_CUSTOM` | Existing custom field already present in exported solution. |
| Receita anual/faturamento | `revenue` | `USE_NATIVE` | Native annual revenue. |
| Faturamento bruto/liquido | `nexer_faturamento_bruto`, `nexer_faturamentoliquido` | `USE_EXISTING_CUSTOM` / `NEEDS_REVIEW` | Existing custom fields are present. Use only if demo needs both bruto/liquido; otherwise prefer `revenue`. |
| Classificacao/potencial da conta | `accountclassificationcode`, `accountratingcode` | `EXTEND_NATIVE_CHOICE` | Native choices. Use for ICP/potencial before new custom picklist. |
| Porte | `numberofemployees`, `revenue` | `USE_NATIVE` | Derive display from native employee/revenue fields where possible. |
| Conta pai/hierarquia | `parentaccountid` | `USE_NATIVE` | Native hierarchy field. |
| Contato principal | `primarycontactid` | `USE_NATIVE` | Native link to primary contact. |
| Customer Insights segment/profile | `msdyn_segmentid`, `msdynci_lookupfield_customerprofile` | `USE_EXISTING_CUSTOM` / `NEEDS_REVIEW` | Present in exported solution. Use only if meaningful data exists for demo. |
| Pipeline/receita negociada na conta | Rollup from opportunities; existing `nexer_pipeline_global`, `nexer_total_negociao` | `NEEDS_REVIEW` | Prefer native rollups/views/charts from Opportunity. Existing fields can support visual demo if already used. |
| Percentual de desconto na conta | `nexer_percentual_desconto` | `NEEDS_REVIEW` | Existing custom field is account-level. Discount governance should primarily live on Opportunity. |

## Contact (`contact`)

| Requirement | Preferred field | Decision | Notes |
|---|---|---:|---|
| Nome completo | `firstname`, `lastname`, `fullname` | `USE_NATIVE` | Native contact identity. |
| Cargo | `jobtitle` | `USE_NATIVE` | Native and directly fits stakeholder role title. |
| Email/telefone/celular | `emailaddress1`, `telephone1`, `mobilephone` | `USE_NATIVE` | Native contact channels. |
| Conta vinculada | `parentcustomerid` | `USE_NATIVE` | Native customer lookup to account/contact. |
| Preferencia de contato | `preferredcontactmethodcode` | `USE_NATIVE` | Native choice with email/phone/fax/mail options. |
| Origem | `leadsourcecode` | `EXTEND_NATIVE_CHOICE` | Native contact source. Use if relevant after lead qualification. |
| Responsavel preferencial | `preferredsystemuserid` | `USE_NATIVE` | Native lookup to user. |
| Papel comercial na venda | `nexer_tipodecontato`, `nexer_tipodecontatocomercial` | `USE_EXISTING_CUSTOM` / `NEEDS_REVIEW` | Existing custom choices. Validate values for decisor, influenciador, sponsor, opositor. |
| Nivel de influencia | No strong native fit | `CREATE_NEXER_FIELD` | Create only if existing `nexer_tipodecontatocomercial` cannot express influence. Suggested choice: Alta, Media, Baixa. |
| Ultima/proxima interacao | Activities/timeline, `lastusedincampaign` if campaign-specific | `USE_NATIVE` | Prefer native activities/timeline rather than custom date fields. |
| Customer Insights segment/profile | `msdyn_segmentid`, `msdynci_lookupfield_customerprofile` | `USE_EXISTING_CUSTOM` / `NEEDS_REVIEW` | Present in exported solution. Validate demo usefulness. |

## Opportunity (`opportunity`)

| Requirement | Preferred field | Decision | Notes |
|---|---|---:|---|
| Topico/nome | `name` | `USE_NATIVE` | Native and already present in exported solution. |
| Cliente | `customerid`, `parentaccountid`, `parentcontactid` | `USE_NATIVE` | Native customer/account/contact relationships. |
| Valor da oportunidade | `estimatedvalue` | `USE_NATIVE` | Native estimated revenue and already present in exported solution. |
| Data prevista | `estimatedclosedate` | `USE_NATIVE` | Native and already present in exported solution. |
| Probabilidade | `closeprobability` | `USE_NATIVE` | Native integer 0-100. Add to form/solution metadata rather than creating custom. |
| Fase/pipeline textual | `stepname` plus BPF stages | `USE_NATIVE` | Native pipeline phase field exists, but BPF should be source of demo flow. |
| Status | `statecode`, `statuscode` | `USE_NATIVE` | Native status/status reason. |
| Necessidade/dor do cliente | `customerneed`, `customerpainpoints`, `currentsituation`, `description` | `USE_NATIVE` | Native memo fields support opportunity discovery. |
| Proposta pronta/revisao interna/feedback | `developproposal`, `completeinternalreview`, `completefinalproposal`, `captureproposalfeedback` | `USE_NATIVE` | Native booleans align with proposal stage checks. |
| Desconto solicitado | `discountamount`, `discountpercentage`, `totaldiscountamount`, `totallineitemdiscountamount` | `USE_NATIVE` | Native discount fields cover amount/rate/total. |
| Status de aprovacao de desconto | No strong native fit | `CREATE_NEXER_FIELD` | Suggested `nexer_statusaprovacaodesconto` choice: Nao Solicitada, Pendente, Aprovada, Rejeitada, Escalada. |
| Aprovador/data/justificativa de desconto | No strong native fit | `CREATE_NEXER_FIELD` | Suggested lookup/date/memo fields, or a child approval table if auditability becomes important. |
| Produto/solucao Senior | Existing Product/Opportunity Product or custom choice | `NEEDS_REVIEW` | Prefer product catalog/opportunity products if demo uses items; otherwise create/extend a simple Senior solution line choice. |
| CPQ/GPS status | No native Sales fit | `CREATE_NEXER_FIELD` | Simulated integration field. Suggested choice: Nao iniciado, Enviado, Processando, Concluido, Erro simulado. |
| ERP Sapiens status | No native Sales fit | `CREATE_NEXER_FIELD` | Simulated integration field. Suggested choice mirroring CPQ/GPS status. |
| ETN acionada | No strong native fit | `CREATE_NEXER_FIELD` | Could be boolean/date/user fields or a demo activity type. Prefer simple fields for first wave. |
| Valor adquirido/vendido | `nexer_valoradquirido`, `nexer_vendido` | `USE_EXISTING_CUSTOM` / `NEEDS_REVIEW` | Existing custom fields are present. Validate if they belong to another demo/business process before reuse. |

## Existing Custom Fields Found In Export

### Lead

- `new_interesse`
- `nexer_interessedocliente`
- `nexer_linha_interesse`

### Account

- `new_customercode`
- `nexer_subsegmento`
- `nexer_tipo_conta`
- `nexer_faturamento_bruto`
- `nexer_faturamentoliquido`
- `nexer_pipeline_global`
- `nexer_total_negociao`
- `nexer_valor_total_vendas`
- `nexer_receita_conquistada`
- `nexer_receita_perdida`
- `nexer_percentual_desconto`
- Several FitBank/area/date fields likely unrelated to Senior demo and should not be reused without owner validation.

### Contact

- `nexer_tipodecontato`
- `nexer_tipodecontatocomercial`
- `nexer_corretorresponsavel`
- `parent_contactid`

### Opportunity

- `nexer_conta_avo`
- `nexer_conta_pai`
- `nexer_projeto`
- `nexer_valoradquirido`
- `nexer_vendido`
- `new_alerta_iot`
- `new_ativo`
- `new_dt_fim_subscricao`
- `new_melhordiadepagamento`

## Build Guidance For User Stories

1. Add native fields to the solution/forms before creating any `nexer_*` field.
2. When a requirement is a process step, implement it in BPF instead of a table column.
3. When a requirement is a sales metric already calculated by Opportunity/Product totals, prefer native calculated totals and dashboard charts.
4. New custom fields approved for first implementation wave:
   - Opportunity discount approval status/details.
   - Simulated CPQ/GPS integration status.
   - Simulated ERP Sapiens integration status.
   - ETN acionada/status if not represented as an activity.
   - Contact influence level only if existing contact type choices cannot cover it.
5. Fields requiring business validation before reuse:
   - Existing `nexer_*` fields that appear to come from previous demos or business domains.
   - Sales Insights scoring fields, because the environment must confirm feature availability.
   - Product/solution line modeling: decide between Product Catalog/Opportunity Products and a simplified demo choice.

## Next Story Recommendation

Proceed with Story 2.1: Lead Senior form/BPF mapping.

The Lead story should create the detailed form map using the decisions above, then implement a new Lead form in Sales Hub using native fields first, existing custom interest fields second, and no new custom Lead fields unless a gap remains after Maker Portal validation.
