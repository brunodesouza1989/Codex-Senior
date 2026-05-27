# Story 2.2 - Criar Formulario Cliente Potencial Senior

Date: 2026-05-25

Status: deployed-layout-updated

## User Story

As a Pamela/Sales Ops,
I want ver um formulario de Cliente Potencial com dados essenciais e checklist,
So that eu qualifique leads sem procurar informacao em varias abas.

## Build Decision

Create a new Lead main form named `Cliente Potencial Senior` inside solution `nexer_senior_demo_crm_b`, using the native Sales Hub app. Do not edit the original `Sales Insights` or default `Cliente Potencial` forms.

Preferred base form:

1. `Sales Insights` Lead form, if available for Save As / clone in Maker Portal.
2. Default `Cliente Potencial` form, only if `Sales Insights` cannot be cloned.

## Implementation Result

The form clone was created without human interaction through Dataverse Web API, using the existing PAC authentication cache.

- Created form: `Cliente Potencial Senior`
- Form id: `c8e4eb26-8558-f111-bec7-7c1e526b609d`
- Source form: `Sales Insights`
- Published: yes
- Export/unpack completed: yes
- Export file: `C:\codex\senior\.deploy\nexer_senior_demo_crm_b\exports\nexer_senior_demo_crm_b_after_lead_form.zip`
- Unpacked form XML: `C:\codex\senior\.deploy\nexer_senior_demo_crm_b\unpacked\Entities\Lead\FormXml\main\{c8e4eb26-8558-f111-bec7-7c1e526b609d}.xml`

The deployed clone now contains an initial `Resumo Senior` tab inserted before the original Sales Insights content. The original cloned Sales Insights sections were preserved after the Senior tab.

Layout update automation:

- Script: `C:\codex\senior\.deploy\nexer_senior_demo_crm_b\scripts\Update-LeadSeniorFormLayout-WebApi.ps1`
- Export file: `C:\codex\senior\.deploy\nexer_senior_demo_crm_b\exports\nexer_senior_demo_crm_b_after_lead_form_layout.zip`
- Unpacked form XML: `C:\codex\senior\.deploy\nexer_senior_demo_crm_b\unpacked\Entities\Lead\FormXml\main\{c8e4eb26-8558-f111-bec7-7c1e526b609d}.xml`

## Form Metadata

- Table: Lead / Cliente Potencial (`lead`)
- Form type: Main
- Form name: `Cliente Potencial Senior`
- App usage: Sales Hub native
- Solution: `nexer_senior_demo_crm_b`
- Base/inspiration: Sales Insights

## Required First Fold

The first visible area must support a live qualification conversation without tab hopping:

| Area | Fields/components |
|---|---|
| Header | `subject`, `leadsourcecode`, `leadqualitycode`, `prioritycode`, owner |
| Identificacao | `firstname`, `lastname`, `companyname`, `jobtitle` |
| Contato | `emailaddress1`, `telephone1`, `mobilephone` |
| Qualificacao | `industrycode`, `estimatedamount`, `budgetamount`, `budgetstatus`, `purchaseprocess`, `purchasetimeframe` |
| Interesse Senior | Canonical existing field selected from `nexer_interessedocliente`, `nexer_linha_interesse`, or `new_interesse` |
| Dor/necessidade | `qualificationcomments` or `description` |
| Proxima acao | Timeline / Activities, not a new custom field |

## Tabs And Sections

### Tab: Resumo Senior

Section: Identificacao

- `firstname`
- `lastname`
- `companyname`
- `jobtitle`

Section: Contato

- `emailaddress1`
- `telephone1`
- `mobilephone`

Section: Qualificacao Comercial

- `leadsourcecode`
- `industrycode`
- `estimatedamount`
- `budgetamount`
- `budgetstatus`
- `purchaseprocess`
- `purchasetimeframe`
- `prioritycode`
- `leadqualitycode`
- canonical interest field

Section: Dor e Proxima Acao

- `qualificationcomments`
- Timeline / Activities

### Tab: Checklist De Qualificacao

Represent checklist with native fields and clear form labels:

| Checklist item | Field/control |
|---|---|
| Necessidade clara | `qualificationcomments` |
| Orcamento identificado | `budgetstatus`, `budgetamount` |
| Decisor/comite identificado | `purchaseprocess` |
| Prazo definido | `purchasetimeframe` |
| Aderencia Senior | `leadqualitycode` |
| Linha de negocio Senior | canonical interest field |

### Tab: Sales Insights

Keep Sales Insights components from the cloned form when available. If scoring fields/components are not active in the environment, do not block the demo; keep the tab hidden or omit it in the first wave.

## Choice Validation Before Build

Validate choices in Maker Portal before edits:

- `leadsourcecode`
- `industrycode`
- `prioritycode`
- `leadqualitycode`
- existing interest field selected for Senior line

Suggested Senior values should be added only when missing and safe:

- Lead source: Evento Senior, Indicacao, Campanha Digital, Parceiro Nexer, Outbound, Webinar.
- Industry/Senior segment: Tecnologia, Servicos, Manufatura, Varejo, Logistica, Agronegocio, Educacao, Saude.
- Interest/Senior line: HCM / RH, ERP / Gestao Empresarial, Logistica, Agronegocio, Manufatura, Performance Corporativa, Plataforma / Integracoes.

## Acceptance Criteria

- The form exists as `Cliente Potencial Senior` in solution `nexer_senior_demo_crm_b`.
- The original Sales Hub/Sales Insights forms remain unmodified.
- The form uses native fields for all standard Sales concepts.
- No new Lead `nexer_*` field is created in this story.
- The selected existing interest field is documented.
- The form can be opened from the native Sales Hub app for Lead records.
- After Maker changes, PAC export/unpack is executed and the deployment log is updated.

## Automated Build Steps Completed

1. Read valid Dataverse access token from local PAC MSAL cache.
2. Retrieved the Lead `Sales Insights` `systemform`.
3. Created new Lead `systemform` named `Cliente Potencial Senior`.
4. Added the form component to solution `nexer_senior_demo_crm_b` through Web API action `AddSolutionComponent`.
5. Published Lead customizations through Web API action `PublishXml`.
6. Confirmed the form through PAC FetchXML.
7. Exported and unpacked the solution.

Automation script:

- `C:\codex\senior\.deploy\nexer_senior_demo_crm_b\scripts\Create-LeadSeniorFormClone-WebApi.ps1`

## Maker Portal Build Steps

These are fallback/inspection steps only; the clone creation itself is automated.

1. Open Maker Portal in environment `c63ff97b-2372-e7a4-9cd7-0de7d609f11d`.
2. Open solution `nexer_senior_demo_crm_b`.
3. Open table `Cliente Potencial` / `Lead`.
4. Go to Forms.
5. Open the `Sales Insights` main form.
6. Use `Save as` and name it `Cliente Potencial Senior`.
7. Add/rearrange fields according to this story.
8. Validate and select the canonical Senior interest field.
9. Save and publish.
10. Confirm the form appears in Sales Hub for Lead records.
11. Run PAC export/unpack to version the deployed form.

## PAC Follow-Up Commands

After publishing in Maker Portal:

```powershell
.\.tools\pac-msi\pkg\tools\pac.exe solution export --name nexer_senior_demo_crm_b --path C:\codex\senior\.deploy\nexer_senior_demo_crm_b\exports\nexer_senior_demo_crm_b_after_lead_form.zip --managed false --overwrite
.\.tools\pac-msi\pkg\tools\pac.exe solution unpack --zipfile C:\codex\senior\.deploy\nexer_senior_demo_crm_b\exports\nexer_senior_demo_crm_b_after_lead_form.zip --folder C:\codex\senior\.deploy\nexer_senior_demo_crm_b\unpacked --packagetype Unmanaged --allowDelete
```

## Next Story

Proceed to Story 2.3: create BPF `Lead Senior` with stages Entrada, Filtro 1, Filtro 2, Agendado and Qualificado.
