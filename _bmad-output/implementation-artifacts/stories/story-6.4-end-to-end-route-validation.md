# Story 6.4 - Validar Roteiro Ponta A Ponta

Date: 2026-05-26

Status: package-ready-pending-live-walkthrough

## User Story

As a time de presales,
I want validar a demo de ponta a ponta,
So that a apresentacao seja fluida e confiavel.

## Validation Route

1. Open native Sales Hub.
2. Open Lead view `Senior 360 | Leads - Entrada`.
3. Open `Cliente Potencial Senior`.
4. Move through `Lead Senior` BPF stages.
5. Qualify lead using native Dynamics behavior.
6. Open generated/linked Account in `Conta Senior`.
7. Open Contact in `Contato Senior`.
8. Open Opportunity in `Oportunidade Senior`.
9. Demonstrate ETN, CPQ/GPS and ERP Sapiens simulation fields.
10. Demonstrate discount request and approval status.
11. Close opportunity as won.
12. Open operational and executive dashboards.

## Acceptance Criteria

- Route can be executed without creating a new model-driven app.
- Presenter can complete the story without relying on external integrations.
- Any manual demo step is documented as simulation.
- Final package is exported/unpacked and versioned after validation.

## 2026-05-27 Status

Partially ready:

- Sales Hub native premise remains intact.
- Lead form/BPF/views are deployed.
- Account, Contact and Opportunity Senior forms are deployed.
- Opportunity views and governance fields are deployed.
- Demo data for the narrative is deployed.
- Operational and executive dashboards are deployed.
- Final export/unpack was generated:
  - `C:\Users\Bruno Andrade\Documents\Senior\.deploy\nexer_senior_demo_crm_b\exports\nexer_senior_demo_crm_b_epics_closed_20260527.zip`

Remaining validation gaps:

- Full visual replacement for `Oportunidade Senior Privado` BPF stages.
- Live Sales Hub walkthrough in the browser with the presenter route.
