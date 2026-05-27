# Deployment Log - Senior Demo CRM B

Date: 2026-05-25

Environment:

- URL: `https://nexereabrpresales.crm.dynamics.com`
- Organization: `Nexer EA BR - Presales`
- Authenticated user: `bruno.andrade@nexergroup.com`

## Completed

1. Installed local PAC CLI from official NuGet package into:
   - `C:\codex\senior\.tools\pac-msi\pkg\tools\pac.exe`

2. Authenticated PAC profile:
   - Profile: `nexer-presales-senior`
   - Environment: `https://nexereabrpresales.crm.dynamics.com`

3. Created local Dataverse solution project:
   - Path: `C:\codex\senior\.deploy\nexer_senior_demo_crm_b`
   - Publisher name: `nexer`
   - Publisher prefix: `nexer`
   - Solution unique name: `nexer_senior_demo_crm_b`

4. Packed and imported unmanaged solution:
   - Solution unique name: `nexer_senior_demo_crm_b`
   - Version: `1.0`
   - Managed: `False`

5. Confirmed solution exists in Dataverse:
   - `nexer_senior_demo_crm_b`

6. Added core Sales tables to the solution through PAC:
   - `lead`
   - `account`
   - `contact`
   - `opportunity`

7. Exported and unpacked solution after adding tables:
   - Export: `C:\codex\senior\.deploy\nexer_senior_demo_crm_b\exports\nexer_senior_demo_crm_b_with_tables.zip`
   - Unpacked folder: `C:\codex\senior\.deploy\nexer_senior_demo_crm_b\unpacked`

## Existing Forms Found In Export

Lead:

- `Sales Insights`
- `Lead`
- `Information`

Account:

- `Sales Insights`
- `Account`
- `Information`
- Other existing demo/financial forms

Contact:

- `Contact`
- `Information`
- Portal/Profile forms
- No explicit Sales Insights contact form was found in the unpacked solution.

Opportunity:

- `AI for Sales`
- `Opportunity`
- `Information`
- Other contextual forms

## Blocked / Not Completed

Attempted to create cloned form XML files for:

- `nexer_Lead Sales Insights Senior Demo`
- `nexer_Account Sales Insights Senior Demo`
- `nexer_Contact Senior Demo`
- `nexer_Opportunity AI for Sales Senior Demo`

The solution pack succeeded, but Dataverse import failed with:

```text
full formXml is expected to create a form : 539fa291-fbfe-48b7-ab6d-c629b88b81e4
```

Interpretation:

- Creating new `systemform` records by copying unpacked form XML files is not reliable in this solution package shape.
- The Dataverse import expects full `formxml` payload for creating forms, not only the exported wrapper file as reconstructed by SolutionPackager.

Mitigation applied:

- Removed the attempted cloned form XML files from the local unpacked package.
- Removed their temporary root component entries from `Other\Solution.xml`.
- Did not change or delete original Sales Hub/Sales Insights forms.

Additional SDK attempt:

- Tried to connect with `Microsoft.PowerPlatform.Dataverse.Client.dll` from the PAC package.
- Connection was blocked by .NET assembly binding/dependency version conflicts in PowerShell:
  - `Microsoft.Extensions.Logging.Abstractions`
  - `Microsoft.Extensions.Options`
  - `Microsoft.Extensions.DependencyInjection.Abstractions`

## Current Safe State

The environment contains:

- Unmanaged solution `nexer_senior_demo_crm_b`
- Core Sales tables added to the solution:
  - Lead
  - Account
  - Contact
  - Opportunity

No new forms or BPFs were successfully deployed yet.

## Recommended Next Step

Use one of these paths:

1. Use PAC plus a proper Dataverse SDK executable project with app.config binding redirects to create `systemform` records through Organization Service.
2. Use a supported Power Platform Build Tools / service principal pipeline where solution XML can be generated from a real source environment.
3. Use Maker Portal once to create the four form clones, then export/unpack/version them and continue automated PAC deployment from that point onward.

## 2026-05-26 - Story 2.3 Lead BPF Automation Investigation

Objective: create `Lead Senior` BPF for `Cliente Potencial` with stages Entrada, Filtro 1, Filtro 2, Agendado and Qualificado, using the native Sales Hub app.

Actions:

- Exported existing lead BPF definitions through Dataverse Web API.
- Created draft BPF via `CreateWorkflowFromTemplate`.
- Tested activation through Web API and Organization Service SOAP `SetStateRequest`.
- Identified Dataverse activation requirement for generated BPF internal entity and `processstage` records.
- Removed the invalid draft BPF after repairing missing `processstage` references enough for deletion.
- Confirmed the solution exports successfully after cleanup.

Result:

- BPF is not deployed yet.
- No original BPF was modified.
- The solution is clean/exportable again.
- Latest stable export:
  - `C:\codex\senior\.deploy\nexer_senior_demo_crm_b\exports\nexer_senior_demo_crm_b_after_bpf_cleanup.zip`
- Unpacked folder:
  - `C:\codex\senior\.deploy\nexer_senior_demo_crm_b\unpacked`

Automation scripts and evidence are documented in:

- `C:\codex\senior\_bmad-output\implementation-artifacts\stories\story-2.3-lead-bpf-build.md`

## 2026-05-26 - Story 2.3 Lead BPF Web API Retry

Objective: retry BPF creation using Web API as the default path, with Maker Portal opened only as a validation surface.

Actions:

- Created a fresh draft BPF `Lead Senior` from template with technical name `nexer_bpf_leadsenior`.
- Created five `processstage` records through Dataverse Web API for Entrada, Filtro 1, Filtro 2, Agendado and Qualificado.
- Retried the workflow definition patch using the existing stage IDs.
- Dataverse blocked the workflow patch with duplicate internal key validation:
  - `0x80040237`
  - `A record with matching key values already exists.`
- Cleaned up the draft BPF.
- Exported the solution successfully:
  - `C:\codex\senior\.deploy\nexer_senior_demo_crm_b\exports\nexer_senior_demo_crm_b_after_bpf_retry_cleanup.zip`

Result:

- BPF still requires Maker Portal designer or a supported SDK/designer path for the first valid creation.
- The solution remains clean and exportable.
## 2026-05-25 - Story 2.2 Lead Form Clone Attempt

Objective: create `Cliente Potencial Senior` as a new Lead main form based on the existing Sales Insights form, without modifying the original Sales Hub/Sales Insights forms.

Actions:

- Identified existing Lead forms in the exported solution, including `Sales Insights`.
- Created a local cloned form XML with a new form id for `Cliente Potencial Senior`.
- Packed the unmanaged solution as `C:\codex\senior\.deploy\nexer_senior_demo_crm_b\exports\nexer_senior_demo_crm_b_lead_form_clone.zip`.
- SolutionPackager completed with warning: the new `SystemForm` root component was not fully recognized as defined in customizations.
- Attempted PAC import with publish. The command exceeded local timeout.
- Queried Dataverse `systemform` records for forms containing `Senior`; no result returned.
- Cleaned the local cloned form XML and stale root component from the unpacked solution tree.

Result:

- No deployed Lead form was confirmed.
- No original form was modified.
- Approved implementation path for Story 2.2 is Maker Portal clone/create, then PAC export/unpack for versioning.

## 2026-05-25 - Story 2.2 Lead Form Clone Automated Successfully

Objective: create `Cliente Potencial Senior` without human interaction.

Actions:

- Created automation script:
  - `C:\codex\senior\.deploy\nexer_senior_demo_crm_b\scripts\Create-LeadSeniorFormClone-WebApi.ps1`
- Reused local PAC MSAL cache to obtain a Dataverse Web API token.
- Retrieved the existing Lead `Sales Insights` form from `systemform`.
- Created new Lead main form:
  - Name: `Cliente Potencial Senior`
  - Form id: `c8e4eb26-8558-f111-bec7-7c1e526b609d`
  - Source: `Sales Insights`
- Added the form to solution `nexer_senior_demo_crm_b` through `AddSolutionComponent`.
- Published Lead customizations through `PublishXml`.
- Confirmed via PAC FetchXML:
  - `Cliente Potencial Senior`
  - `c8e4eb26-8558-f111-bec7-7c1e526b609d`
  - Table: `Cliente Potencial`
  - Type: `Principal`
- Exported solution:
  - `C:\codex\senior\.deploy\nexer_senior_demo_crm_b\exports\nexer_senior_demo_crm_b_after_lead_form.zip`
- Unpacked solution and confirmed form XML:
  - `C:\codex\senior\.deploy\nexer_senior_demo_crm_b\unpacked\Entities\Lead\FormXml\main\{c8e4eb26-8558-f111-bec7-7c1e526b609d}.xml`

Result:

- Automated clone succeeded.
- No original Sales Insights/default Lead form was modified.
- The deployed clone is ready for the next pass: update layout/fields according to Story 2.2.

## 2026-05-25 - Story 2.2 Lead Form Layout Automated Successfully

Objective: update `Cliente Potencial Senior` layout and fields according to Story 2.2 without human interaction.

Actions:

- Created automation script:
  - `C:\codex\senior\.deploy\nexer_senior_demo_crm_b\scripts\Update-LeadSeniorFormLayout-WebApi.ps1`
- Updated `systemform.formxml` through Dataverse Web API.
- Inserted a new first tab:
  - Internal name: `senior_summary`
  - Label: `Resumo Senior`
- Added sections:
  - `senior_identificacao`
  - `senior_contato`
  - `senior_qualificacao_comercial`
  - `senior_checklist_qualificacao`
  - `senior_proxima_acao`
- Added key controls:
  - `subject`
  - `firstname`
  - `lastname`
  - `companyname`
  - `jobtitle`
  - `emailaddress1`
  - `telephone1`
  - `mobilephone`
  - `leadsourcecode`
  - `industrycode`
  - `revenue`
  - `numberofemployees`
  - `budgetamount`
  - `budgetstatus`
  - `prioritycode`
  - `leadqualitycode`
  - `nexer_interessedocliente`
  - `purchaseprocess`
  - `purchasetimeframe`
  - `qualificationcomments`
  - Timeline placeholder control
- First publish attempt via Web API failed due concurrent Dataverse customization operation.
- Re-ran after wait and publish succeeded via Web API.
- Exported solution:
  - `C:\codex\senior\.deploy\nexer_senior_demo_crm_b\exports\nexer_senior_demo_crm_b_after_lead_form_layout.zip`
- Unpacked solution and validated final XML:
  - `C:\codex\senior\.deploy\nexer_senior_demo_crm_b\unpacked\Entities\Lead\FormXml\main\{c8e4eb26-8558-f111-bec7-7c1e526b609d}.xml`

Result:

- Automated layout update succeeded.
- Original Sales Insights content remains preserved after the new Senior tab.
- No new Lead `nexer_*` fields were created.

## 2026-05-26 - Story 2.3 Lead Senior BPF Automated Successfully

Objective: create and deploy `Lead Senior` BPF for `Cliente Potencial` with stages Entrada, Filtro 1, Filtro 2, Agendado and Qualificado, using the native Sales Hub app.

Actions:

- Created `Lead Senior` from an existing Lead BPF template through Dataverse Web API.
- Activated the process once so Dataverse generated the internal BPF entity.
- Added generated table `nexer_bpf_leadsenior440963552459f111bec60022482557cc` to solution `nexer_senior_demo_crm_b`.
- Deactivated `Lead Senior`, replaced workflow `clientdata/xaml` with the lead-only Senior definition, then reactivated and published it.
- Reused generated `processstageid` values because Dataverse blocks direct `processstage` update through Web API.
- Exported solution:
  - `C:\codex\senior\.deploy\nexer_senior_demo_crm_b\exports\nexer_senior_demo_crm_b_with_lead_senior_bpf.zip`
- Unpacked solution:
  - `C:\codex\senior\.deploy\nexer_senior_demo_crm_b\unpacked`

Validation:

- Web API inspection confirms workflow `42096355-2459-f111-bec6-0022482557cc` is active with state/status `1/2`.
- Verified stages:
  - Entrada: `leadsourcecode`, `companyname`, `firstname`, `lastname`, `emailaddress1`, `telephone1`
  - Filtro 1: `industrycode`, `nexer_interessedocliente`, `leadqualitycode`
  - Filtro 2: `qualificationcomments`, `budgetstatus`, `budgetamount`, `purchasetimeframe`
  - Agendado: `ownerid`, `description`
  - Qualificado: `purchaseprocess`, `revenue`, `leadqualitycode`
- Exported XAML contains the Senior stages and no longer contains the old Lead -> Opportunity BPF relationship block.

Result:

- Automated BPF deployment succeeded.
- No new model-driven app was created.
- The BPF is included in the existing solution and available for native Sales Hub usage.

## 2026-05-26 - Story 2.4 Lead Stage Views Automated Successfully

Objective: create Lead views by `Lead Senior` BPF stage for Entrada, Filtro 1, Filtro 2, Agendado and Qualificado.

Actions:

- Created script:
  - `C:\codex\senior\.deploy\nexer_senior_demo_crm_b\scripts\Upsert-LeadSeniorStageViews-WebApi.ps1`
- Created public Lead system views:
  - `Senior 360 | Leads - Entrada`
  - `Senior 360 | Leads - Filtro 1`
  - `Senior 360 | Leads - Filtro 2`
  - `Senior 360 | Leads - Agendado`
  - `Senior 360 | Leads - Qualificado`
- Filtered each view through the generated BPF table `nexer_bpf_leadsenior440963552459f111bec60022482557cc` and the respective `activestageid`.
- Added all five savedqueries to solution `nexer_senior_demo_crm_b`.
- Published Lead customizations.
- Exported solution:
  - `C:\codex\senior\.deploy\nexer_senior_demo_crm_b\exports\nexer_senior_demo_crm_b_with_lead_stage_views.zip`
- Unpacked solution:
  - `C:\codex\senior\.deploy\nexer_senior_demo_crm_b\unpacked`

Result:

- Story 2.4 deployed automatically.
- No new app was created.
- Views are available as Lead system views for use inside the native Sales Hub.

## 2026-05-26 - Stories 3.2/3.3 Account And Contact Form Clones Automated

Objective: start Epic 3 by cloning Account and Contact forms into the Senior solution without human interaction.

Actions:

- Created generic clone script:
  - `C:\codex\senior\.deploy\nexer_senior_demo_crm_b\scripts\Create-SeniorFormClone-WebApi.ps1`
- Created Account form:
  - Name: `Conta Senior`
  - Form id: `11e5cf6c-2a59-f111-bec7-6045bdd67b7b`
  - Table: `account`
  - Source: Account `Sales Insights`
- Created Contact form:
  - Name: `Contato Senior`
  - Form id: `11d2e868-2a59-f111-bec7-000d3a10f9c5`
  - Table: `contact`
  - Source: Contact `AI for Sales`
- Added both forms to solution `nexer_senior_demo_crm_b`.
- Published Account and Contact customizations.
- Exported solution:
  - `C:\codex\senior\.deploy\nexer_senior_demo_crm_b\exports\nexer_senior_demo_crm_b_with_account_contact_forms.zip`
- Unpacked solution:
  - `C:\codex\senior\.deploy\nexer_senior_demo_crm_b\unpacked`

Result:

- Account and Contact Senior form clones exist and are included in the solution.
- Layout customization for Radar da Conta and stakeholder context remains the next implementation step.

## 2026-05-26 - Core Senior Form Layouts Automated

Objective: update Account, Contact and Opportunity Senior forms with first-screen Senior demo layouts, preserving native Sales Insights/AI for Sales content.

Actions:

- Created/updated layout script:
  - `C:\codex\senior\.deploy\nexer_senior_demo_crm_b\scripts\Update-AccountContactSeniorFormLayout-WebApi.ps1`
- Updated Account form:
  - `Conta Senior`
  - Form id: `11e5cf6c-2a59-f111-bec7-6045bdd67b7b`
  - Added first tab `Radar Da Conta`
- Updated Contact form:
  - `Contato Senior`
  - Form id: `11d2e868-2a59-f111-bec7-000d3a10f9c5`
  - Added first tab `Contexto Senior`
- Created and updated Opportunity form:
  - `Oportunidade Senior`
  - Form id: `810287da-2b59-f111-bec7-6045bdd67b7b`
  - Source: Opportunity `Sales Insights`
  - Added first tab `Oportunidade Senior`
- Published Account, Contact and Opportunity customizations.
- Exported solution:
  - `C:\codex\senior\.deploy\nexer_senior_demo_crm_b\exports\nexer_senior_demo_crm_b_with_core_form_layouts.zip`
- Unpacked solution:
  - `C:\codex\senior\.deploy\nexer_senior_demo_crm_b\unpacked`

Validation:

- Exported Account form XML contains `senior_account_radar`.
- Exported Contact form XML contains `senior_contact_context`.
- Exported Opportunity form XML contains `senior_opportunity_summary`.

Result:

- Stories 3.2 and 3.3 moved to layout-updated.
- Story 4.2 first delivery deployed.
- No new model-driven app was created.

## 2026-05-26 - Opportunity Views And Governance Fields Automated

Objective: accelerate Epic 4/5 by adding Opportunity views and the minimum justified governance/integration fields for discount approval, ETN, CPQ/GPS and ERP Sapiens simulation.

Actions:

- Created Opportunity view script:
  - `C:\codex\senior\.deploy\nexer_senior_demo_crm_b\scripts\Upsert-OpportunitySeniorViews-WebApi.ps1`
- Created public Opportunity system views:
  - `Senior 360 | Oportunidades - Pipeline aberto`
  - `Senior 360 | Oportunidades - Minha carteira`
  - `Senior 360 | Oportunidades - Proposta e CPQ/GPS`
  - `Senior 360 | Oportunidades - Desconto e aprovacao`
  - `Senior 360 | Oportunidades - Fechamento 30 dias`
  - `Senior 360 | Oportunidades - Ganhas`
- Created governance field script:
  - `C:\codex\senior\.deploy\nexer_senior_demo_crm_b\scripts\Ensure-OpportunitySeniorDemoFields-WebApi.ps1`
- Created Opportunity fields:
  - `nexer_statusaprovacaodesconto`
  - `nexer_justificativadesconto`
  - `nexer_dataaprovacaodesconto`
  - `nexer_statuscpqgps`
  - `nexer_statuserpsapiens`
  - `nexer_statusetn`
- Added the new fields to solution `nexer_senior_demo_crm_b`.
- Updated `Oportunidade Senior` form to show those fields in the Governance and Integrations section.
- Exported solution:
  - `C:\codex\senior\.deploy\nexer_senior_demo_crm_b\exports\nexer_senior_demo_crm_b_with_opportunity_governance.zip`
- Unpacked solution:
  - `C:\codex\senior\.deploy\nexer_senior_demo_crm_b\unpacked`

Result:

- FR26 opportunity views are deployed.
- Story 5.1 field mapping moved to deployed minimal governance fields.
- `Oportunidade Senior` now supports ETN, CPQ/GPS, ERP Sapiens and discount approval simulation in-form.

## 2026-05-27 - Labels, Opportunity BPF Progress, Demo Data And Export

Objective: continue closing the epic backlog with autonomy, correcting visible Portuguese labels and progressing remaining MVP stories.

Actions:

- Corrected Portuguese labels with accents in scripts and Dataverse metadata/form labels.
- Converted affected PowerShell scripts to UTF-8 BOM to avoid Windows PowerShell 5.1 mojibake.
- Updated Opportunity metadata labels/options:
  - `Status Aprovação Desconto`
  - `Data Aprovação Desconto`
  - `Não Solicitada`
  - `Não Iniciado`
  - `Concluído`
  - `Não Acionada`
  - `Concluída`
- Re-published Lead, Account, Contact and Opportunity form layouts with accented labels.
- Created BPF workflow:
  - Name: `Oportunidade Senior Privado`
  - Workflow id: `7231fce8-9e59-f111-bec7-000d3a18ea46`
  - Primary entity: `opportunity`
  - State/status: active
- Created Senior process stage metadata records for Opportunity BPF.
- Direct XAML replacement for the Opportunity BPF remains blocked by Dataverse generic validation error `0x80040216`; clientdata-only patch is accepted but activation preserves/regenerates template XAML.
- Created demo data through Web API:
  - Account: `Indústrias Modelo Sul`
  - Contacts: `Marina Klein`, `Rafael Borges`
  - Lead: `Smart Lead - Evento HCM Senior - Indústrias Modelo Sul`
  - Opportunity: `Projeto HCM Senior - Rollout Nacional`
  - Task: `Preparar proposta CPQ/GPS e validação ETN - Demo Senior`
- Exported and unpacked solution:
  - `C:\Users\Bruno Andrade\Documents\Senior\.deploy\nexer_senior_demo_crm_b\exports\nexer_senior_demo_crm_b_epics_progress_20260527.zip`

Result:

- Labels are corrected for visible form/metadata usage.
- Story 6.1 demo data is deployed.
- Story 4.3 is partially deployed with workflow active but full visual stage replacement blocked.
- Superseded later the same day: dashboards were subsequently created through Web API using existing chart/view dependencies.

## 2026-05-27 - Dashboards And Export Closure

Objective: finish Epic 6 by creating actual Sales Hub dashboards and producing a clean export/unpack package.

Actions:

- Created dashboard automation script:
  - `C:\Users\Bruno Andrade\Documents\Senior\.deploy\nexer_senior_demo_crm_b\scripts\Upsert-SeniorDashboards-WebApi.ps1`
- Created and added dashboards to solution `nexer_senior_demo_crm_b`:
  - `Senior 360 | Operacional Presales`
  - `Senior 360 | Executivo Pipeline`
- Used existing Opportunity charts and deployed Opportunity views as dashboard dependencies.
- Corrected remaining Lead BPF labels:
  - `Status Do Orçamento`
  - `Orçamento`
  - `Próxima Ação`
- Added missing BPF backing entities to the solution to unblock PAC export:
  - `nexer_bpf_leadsenior440963552459f111bec60022482557cc`
  - `nexer_bpf_credenciamento`
  - `nexer_bpf_jornada_governo`
  - `nexer_bpf_aprovacaodesconto`
- Exported and unpacked solution:
  - `C:\Users\Bruno Andrade\Documents\Senior\.deploy\nexer_senior_demo_crm_b\exports\nexer_senior_demo_crm_b_epics_closed_20260527.zip`

Validation:

- PAC export succeeded.
- PAC unpack succeeded.
- Unpack includes dashboard files:
  - `Dashboards\{acd788bc-b459-f111-bec7-7c1e526b609d}.xml`
  - `Dashboards\{b5e352bb-b459-f111-bec7-6045bdd67b7b}.xml`
- Lead BPF unpack contains accented labels for `Status Do Orçamento` and `Próxima Ação`.

Residual risk:

- The local OptionSet display name for `nexer_statusaprovacaodesconto` still exports with mojibake inside the nested option set metadata, although the field display name and form label export correctly.
- `Oportunidade Senior Privado` remains active but full visual stage replacement is still blocked by Dataverse XAML validation.
