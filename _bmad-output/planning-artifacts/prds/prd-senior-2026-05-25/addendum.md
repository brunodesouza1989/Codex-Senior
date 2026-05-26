# Addendum - Senior Demo CRM B

## Contexto Tecnico

A solution `nexer_senior_demo_crm_b` ja foi criada no ambiente `Nexer EA BR - Presales` via PAC CLI e contem as tabelas `lead`, `account`, `contact` e `opportunity`.

Tentativa de criar clones de formularios diretamente por Solution XML falhou com:

```text
full formXml is expected to create a form
```

Recomendacao tecnica atual:

- Usar Maker Portal para autoria visual inicial de formularios e BPFs.
- Exportar/unpack via PAC apos autoria.
- Usar PAC para ALM, backup e deploy.

## Fontes De Entrada

- `C:/Users/Bruno Andrade/Downloads/Roteiro_Demo_Senior_D365Sales.md`
- `C:/codex/senior/_bmad-output/planning-artifacts/architecture.md`
- `C:/codex/senior/_bmad-output/planning-artifacts/senior-demo-brainstorm.md`
- `C:/codex/senior/_bmad-output/implementation-artifacts/deployment-log.md`

