# Code Review - Senior Demo CRM B

Date: 2026-05-27

## Findings

### P1 - Opportunity approval label still has mojibake in exported metadata

File: `C:\Users\Bruno Andrade\Documents\Senior\.deploy\nexer_senior_demo_crm_b\unpacked\Entities\Opportunity\Entity.xml`

The exported label for `nexer_statusaprovacaodesconto` still appears as `Status AprovaÃ§Ã£o Desconto`. The remediation script now runs with UTF-8 BOM and sends correct labels, but the exported metadata still contains the previously double-encoded value. This should be fixed before final demo because it is visible in metadata/form surfaces and directly affects the user's concern about labels without accentuation.

Recommended fix: use Organization Service/SDK `UpdateAttributeRequest` or a Maker Portal metadata edit for this specific field label, then export/unpack again.

### P1 - Opportunity BPF workflow exists, but full Senior visual stage replacement is not complete

File: `C:\Users\Bruno Andrade\Documents\Senior\.deploy\nexer_senior_demo_crm_b\unpacked\Workflows\OportunidadeSeniorPrivado-7231FCE8-9E59-F111-BEC7-000D3A18EA46.xaml`

The workflow `Oportunidade Senior Privado` is active and exported, but the exported XAML does not contain the Senior stages. Direct XAML replacement failed with Dataverse error `0x80040216`; clientdata-only patch was accepted, but activation preserves/regenerates template XAML. This means Story 4.3 is partial, not fully demo-ready.

Recommended fix: create/publish the BPF once through the Maker Portal designer or invest in a complete Opportunity BPF XAML generator validated against the source template's structure.

### P2 - Export/unpack pulled additional solution components that may be broader than the current MVP

File: `C:\Users\Bruno Andrade\Documents\Senior\.deploy\nexer_senior_demo_crm_b\unpacked\Other\Solution.xml`

The latest export includes additional entities such as `nexer_AlcadaDesconto`, `nexer_AprovacaoDesconto`, `nexer_Canal`, `nexer_GpsProposal`, `Product` and `SystemUser`. Some may be valid dependencies, but they expand the transport surface. This should be reviewed before final managed export.

Recommended fix: inspect solution components in Maker/PAC and remove non-demo dependencies unless intentionally required for the Senior narrative.

### P2 - Dashboard stories remain specified but not deployed

Files:

- `C:\Users\Bruno Andrade\Documents\Senior\_bmad-output\implementation-artifacts\stories\story-6.2-operational-dashboard.md`
- `C:\Users\Bruno Andrade\Documents\Senior\_bmad-output\implementation-artifacts\stories\story-6.3-executive-dashboard.md`

Operational and executive dashboards are not deployed. This is intentionally blocked because interaction-centric dashboard XML requires valid chart/view dependencies; cloning or creating a blank dashboard would be misleading.

Recommended fix: create charts and dashboards via Maker Portal once, then export/unpack; or build a generator that creates savedqueryvisualizations and dashboards together.

### P3 - Web API scripts duplicate token-cache access logic

Files: `C:\Users\Bruno Andrade\Documents\Senior\.deploy\nexer_senior_demo_crm_b\scripts\*.ps1`

Most scripts duplicate PAC token-cache reading via DPAPI. This is acceptable for the current presales automation spike, but it is brittle and user-profile-specific.

Recommended fix: extract a shared helper or switch to a supported auth method for reusable pipelines, such as service principal or PAC-authenticated command wrappers.

## Positive Coverage

- Solution remains inside `nexer_senior_demo_crm_b`.
- No new model-driven app was created.
- Lead form, Lead BPF, Lead views, Account form, Contact form, Opportunity form and Opportunity views are deployed.
- Demo data now exists for a credible Sales Hub route.
- Scripts now avoid UTF-8 mojibake for form labels by using UTF-8 BOM.

