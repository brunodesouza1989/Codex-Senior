# Code Review - Senior Demo CRM B

Date: 2026-05-27

## Findings

### P1 - Opportunity approval local OptionSet label still has mojibake in exported metadata

File: `C:\Users\Bruno Andrade\Documents\Senior\.deploy\nexer_senior_demo_crm_b\unpacked\Entities\Opportunity\Entity.xml`

The exported local OptionSet display name for `nexer_statusaprovacaodesconto` still appears as mojibake inside the nested option set metadata. The field display name, field description, form labels and option values export correctly with accents, but this nested local OptionSet display name remains double-encoded even after Web API metadata updates.

Recommended fix: use Maker Portal metadata edit for this specific local choice display name or a Dataverse SDK/Organization Service path that updates the nested local `OptionSetMetadata.DisplayName`, then export/unpack again.

### P1 - Opportunity BPF workflow exists, but full Senior visual stage replacement is not complete

File: `C:\Users\Bruno Andrade\Documents\Senior\.deploy\nexer_senior_demo_crm_b\unpacked\Workflows\OportunidadeSeniorPrivado-7231FCE8-9E59-F111-BEC7-000D3A18EA46.xaml`

The workflow `Oportunidade Senior Privado` is active and exported, but the exported XAML does not contain the Senior stages. Direct XAML replacement failed with Dataverse error `0x80040216`; clientdata-only patch was accepted, but activation preserves/regenerates template XAML. This means Story 4.3 is partial, not fully demo-ready.

Recommended fix: create/publish the BPF once through the Maker Portal designer or invest in a complete Opportunity BPF XAML generator validated against the source template's structure.

### P2 - Export/unpack pulled additional solution components that may be broader than the current MVP

File: `C:\Users\Bruno Andrade\Documents\Senior\.deploy\nexer_senior_demo_crm_b\unpacked\Other\Solution.xml`

The latest export includes additional entities such as `nexer_AlcadaDesconto`, `nexer_AprovacaoDesconto`, `nexer_Canal`, `nexer_GpsProposal`, `Product`, `SystemUser` and BPF backing entities for existing Senior processes. Some may be valid dependencies, but they expand the transport surface.

Recommended fix: inspect solution components in Maker/PAC and remove non-demo dependencies unless intentionally required for the Senior narrative.

### P3 - Web API scripts duplicate token-cache access logic

Files: `C:\Users\Bruno Andrade\Documents\Senior\.deploy\nexer_senior_demo_crm_b\scripts\*.ps1`

Most scripts duplicate PAC token-cache reading via DPAPI. This is acceptable for the current presales automation spike, but it is brittle and user-profile-specific.

Recommended fix: extract a shared helper or switch to a supported auth method for reusable pipelines, such as service principal or PAC-authenticated command wrappers.

## Positive Coverage

- Solution remains inside `nexer_senior_demo_crm_b`.
- No new model-driven app was created.
- Lead form, Lead BPF, Lead views, Account form, Contact form, Opportunity form and Opportunity views are deployed.
- Operational and executive dashboards are deployed and exported:
  - `Senior 360 | Operacional Presales`
  - `Senior 360 | Executivo Pipeline`
- Demo data now exists for a credible Sales Hub route.
- Scripts now avoid UTF-8 mojibake for form labels by using UTF-8 BOM.
