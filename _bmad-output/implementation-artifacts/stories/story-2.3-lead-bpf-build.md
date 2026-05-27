# Story 2.3 - Criar BPF Lead Senior

Date: 2026-05-26

Status: deployed-automated

## User Story

As a Pamela/Sales Ops,
I want um fluxo de processo de Cliente Potencial orientado ao roteiro Senior,
So that a qualificacao siga as etapas Entrada, Filtro 1, Filtro 2, Agendado e Qualificado dentro do Sales Hub nativo.

## Architecture Decision

Create a new Business Process Flow for `lead` named `Lead Senior` in solution `nexer_senior_demo_crm_b`.

Do not create a new model-driven app. The BPF must be used from the native Sales Hub.

## Deployed BPF

- Display name: `Lead Senior`
- Workflow id: `42096355-2459-f111-bec6-0022482557cc`
- Unique name: `nexer_bpf_leadsenior440963552459f111bec60022482557cc`
- Primary entity: `lead`
- State/status: active, `1/2`
- Internal BPF table: `nexer_bpf_leadsenior440963552459f111bec60022482557cc`
- Solution: `nexer_senior_demo_crm_b`

## Deployed Stages

| Stage | Fields |
|---|---|
| Entrada | `leadsourcecode`, `companyname`, `firstname`, `lastname`, `emailaddress1`, `telephone1` |
| Filtro 1 | `industrycode`, `nexer_interessedocliente`, `leadqualitycode` |
| Filtro 2 | `qualificationcomments`, `budgetstatus`, `budgetamount`, `purchasetimeframe` |
| Agendado | `ownerid`, `description` |
| Qualificado | `purchaseprocess`, `revenue`, `leadqualitycode` |

## Automation Result

The BPF was created and deployed without human interaction by combining Maker-compatible template creation with Dataverse Web API/PAC automation.

What worked:

- Created `Lead Senior` from an existing lead BPF template.
- Activated the BPF once so Dataverse generated the internal BPF entity.
- Added the generated internal BPF table to solution `nexer_senior_demo_crm_b`.
- Deactivated the BPF through Web API.
- Replaced the workflow `clientdata` and `xaml` with the lead-only Senior definition.
- Reused Dataverse-generated `processstageid` values to avoid duplicate-key collisions.
- Reactivated and published the BPF through Web API.
- Exported and unpacked the solution with PAC.

Important implementation note:

- Dataverse does not support updating `processstage` records directly through Web API. The successful route was to reuse existing generated stage IDs in the workflow definition and update the BPF `clientdata/xaml`.

## Validation

Verified through `Inspect-LeadSeniorBpf-WebApi.ps1`:

- BPF exists in Dataverse.
- BPF is active.
- Primary entity is `lead`.
- Stages and fields match the intended Story 2.3 mapping.

Verified through exported solution XML:

- `Workflows\LeadSenior-42096355-2459-F111-BEC6-0022482557CC.xaml` contains `Entrada`, `Filtro 1`, `Filtro 2`, `Agendado` and `Qualificado`.
- The old Lead -> Opportunity relationship block is absent from the exported BPF XAML.

Latest export:

- `C:\codex\senior\.deploy\nexer_senior_demo_crm_b\exports\nexer_senior_demo_crm_b_with_lead_senior_bpf.zip`

Latest unpacked folder:

- `C:\codex\senior\.deploy\nexer_senior_demo_crm_b\unpacked`

## Scripts Created Or Updated

- `C:\codex\senior\.deploy\nexer_senior_demo_crm_b\scripts\Export-LeadBpfDefinitions-WebApi.ps1`
- `C:\codex\senior\.deploy\nexer_senior_demo_crm_b\scripts\Create-LeadSeniorBpf-FromTemplate-WebApi.ps1`
- `C:\codex\senior\.deploy\nexer_senior_demo_crm_b\scripts\Update-LeadSeniorBpfDefinition-WebApi.ps1`
- `C:\codex\senior\.deploy\nexer_senior_demo_crm_b\scripts\Set-LeadSeniorBpfState-WebApi.ps1`
- `C:\codex\senior\.deploy\nexer_senior_demo_crm_b\scripts\Activate-LeadSeniorBpf-WebApi.ps1`
- `C:\codex\senior\.deploy\nexer_senior_demo_crm_b\scripts\Inspect-LeadSeniorBpf-WebApi.ps1`

## Acceptance Criteria Status

- New BPF exists in solution: met.
- Original BPFs remain unmodified: met.
- No new app is created: met.
- Uses existing/native fields where possible: met.
- Solution can export/unpack cleanly: met.
