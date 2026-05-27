---
stepsCompleted: [1, 2, 3, 4]
inputDocuments:
  - "C:/codex/senior/_bmad-output/planning-artifacts/prds/prd-senior-2026-05-25/prd.md"
  - "C:/codex/senior/_bmad-output/planning-artifacts/architecture.md"
  - "C:/codex/senior/_bmad-output/planning-artifacts/senior-demo-brainstorm.md"
  - "C:/codex/senior/_bmad-output/implementation-artifacts/deployment-log.md"
status: "approved-updated"
approved: "2026-05-25"
updated: "2026-05-26"
---

# Senior Demo CRM B - Epic Breakdown

## Overview

Este documento decompoe o PRD da demo Senior Demo CRM B em epics e user stories implementaveis para Dynamics 365 Sales / Dataverse.

Premissa transversal: antes de criar qualquer novo campo `nexer_*`, a implementacao deve validar se existe campo nativo equivalente em Lead, Account, Contact, Opportunity ou tabelas relacionadas. Quando existir campo nativo adequado, a preferencia e reutilizar o campo e, quando aplicavel, ajustar apenas valores de choices/views/forms dentro da solution `nexer_senior_demo_crm_b`.

## Requirements Inventory

### Functional Requirements

FR1. A solucao deve existir como solution unmanaged chamada `nexer_senior_demo_crm_b`.
FR2. Todos os componentes de demo devem ser criados ou adicionados dentro da solution `nexer_senior_demo_crm_b`.
FR3. A demo deve usar o Sales Hub nativo como aplicativo principal.
FR4. A solucao nao deve criar novo model-driven app nem sitemap customizado.
FR5. A solucao nao deve alterar diretamente formularios originais do Sales Hub ou Sales Insights.
FR6. O usuario deve conseguir visualizar leads por etapa de qualificacao Senior.
FR7. O formulario de Cliente Potencial deve exibir origem, segmento, porte, potencial, dor principal, produto de interesse, score/prioridade e proxima acao.
FR8. O formulario de Cliente Potencial deve conter uma area de checklist de qualificacao.
FR9. O BPF de Lead Senior deve orientar o lead pelas etapas Entrada, Filtro 1, Filtro 2, Agendado e Qualificado.
FR10. O usuario deve conseguir qualificar um lead e seguir para Conta, Contato e Oportunidade usando comportamento nativo do Dynamics.
FR11. O formulario de Conta deve oferecer uma visao 360 orientada a decisao.
FR12. O formulario de Conta deve exibir o Radar da Conta com oportunidades abertas, receita em negociacao, produtos contratados, riscos, pendencias e proxima acao.
FR13. O usuario deve conseguir identificar rapidamente decisores, oportunidades abertas e historico de interacoes da conta.
FR14. O formulario de Contato deve destacar papel na venda, nivel de influencia, preferencia de contato, ultima interacao e proxima acao.
FR15. O usuario deve conseguir associar contatos a oportunidades e identificar decisor, influenciador, sponsor ou opositor.
FR16. O formulario de Oportunidade deve exibir fase, valor, probabilidade, data prevista, produto/solucao, margem/desconto, proxima acao e responsavel.
FR17. O BPF de Oportunidade Senior Privado deve conter as etapas Qualificacao, Desenvolvimento, Proposta, Negociacao, Aprovacao de Desconto, Contrato e Assinatura, Fechamento.
FR18. O usuario deve conseguir acionar ETN a partir da oportunidade.
FR19. O usuario deve conseguir simular geracao de proposta CPQ/GPS a partir da oportunidade.
FR20. O usuario deve conseguir visualizar status de integracao CPQ/GPS e ERP Sapiens na oportunidade.
FR21. O usuario deve conseguir registrar solicitacao de desconto na oportunidade.
FR22. O sistema deve exibir status de aprovacao de desconto: Nao Solicitada, Pendente, Aprovada, Rejeitada ou Escalada.
FR23. A demo deve demonstrar aprovacao de desconto com registro de aprovador, data e justificativa.
FR24. A etapa Aprovacao de Desconto deve ser visivel no fluxo de oportunidade, salvo decisao posterior de tratar como subprocesso.
FR25. A solucao deve fornecer views de leads por etapa.
FR26. A solucao deve fornecer views de oportunidades por pipeline, etapa, executivo e pendencia.
FR27. A solucao deve fornecer dashboard operacional para pre-vendas/Sales Ops.
FR28. A solucao deve fornecer dashboard executivo de pipeline consolidado.
FR29. O dashboard executivo deve mostrar pipeline por etapa, forecast, taxa de conversao, ticket medio, oportunidades por linha de negocio e top oportunidades.
FR30. A demo deve conter dados ficticios criveis de contas, contatos, leads, oportunidades, aprovacoes e interacoes.
FR31. Deve existir pelo menos uma jornada privada completa demonstravel de lead ate fechamento.
FR32. Deve existir pelo menos um caso de desconto pendente/aprovado para demonstracao.
FR33. Deve existir pelo menos uma conta estrategica para demonstrar Radar da Conta.

### NonFunctional Requirements

NFR1. A demo deve ser executavel ao vivo no Sales Hub nativo.
NFR2. As tarefas principais devem minimizar troca de abas e navegacao entre entidades.
NFR3. Formularios devem priorizar informacoes de decisao na primeira dobra.
NFR4. A solucao deve preservar componentes originais do ambiente.
NFR5. A solution deve ser exportavel via PAC para backup e versionamento.
NFR6. A demo deve tolerar indisponibilidade de integracoes externas usando simulacoes criveis.
NFR7. A experiencia deve funcionar em tela desktop e ser demonstravel em contexto responsivo/mobile quando necessario.
NFR8. O roteiro principal deve caber em uma demonstracao hands-on sem slides durante a navegacao.
NFR9. Nomes de campos, secoes e views devem usar terminologia Senior.
NFR10. A solucao deve evitar campos obrigatorios excessivos que prejudiquem fluidez.
NFR11. Antes de criar campo customizado, deve ser validado se existe campo nativo equivalente; a preferencia e reutilizar campo nativo e editar valores existentes quando adequado.

### Additional Requirements

- Usar Sales Hub nativo, sem criar novo model-driven app.
- Manter toda customizacao dentro da solution `nexer_senior_demo_crm_b`.
- Usar PAC para export, unpack, pack, import, publish e versionamento.
- Usar Maker Portal para autoria inicial de formularios/BPFs quando o caminho XML/SDK for mais arriscado.
- Nao alterar formularios originais; criar formularios novos ou clones na solution da demo.
- Integracoes devem comecar simuladas e rastreaveis.

### UX Design Requirements

UX-DR1. Formularios devem responder rapidamente: quem e, quanto vale, onde esta, o que ameaca e o que fazer agora.
UX-DR2. Cliente Potencial deve ter area de checklist de qualificacao.
UX-DR3. Conta deve ter Radar da Conta como momento principal da demo.
UX-DR4. Contato deve destacar papel na decisao e influencia.
UX-DR5. Oportunidade deve destacar proximas acoes: acionar ETN, gerar CPQ/GPS, solicitar aprovacao, registrar reuniao.
UX-DR6. A demo deve demonstrar reducao de cliques nas tarefas principais.

## Epic List

### Epic 1: Fundacao Governada No Sales Hub

Usuarios e time de projeto conseguem trabalhar sobre uma solution isolada, usando Sales Hub nativo, com inventario de metadados para evitar customizacao desnecessaria.

**FRs covered:** FR1, FR2, FR3, FR4, FR5

### Epic 2: Qualificacao De Leads Senior

Sales Ops, LDR, SDR e BDR conseguem qualificar clientes potenciais com etapas Senior, informacoes essenciais e baixo atrito.

**FRs covered:** FR6, FR7, FR8, FR9, FR10, FR25

### Epic 3: Conta 360 E Relacionamento

Executivos e gestores conseguem abrir uma conta estrategica e entender contexto, relacionamento, oportunidades, riscos e proxima acao em uma experiencia de decisao rapida.

**FRs covered:** FR11, FR12, FR13, FR14, FR15, FR33

### Epic 4: Oportunidade Senior E Pipeline Privado

Executivos conseguem conduzir uma oportunidade privada pelo processo Senior, com dados comerciais, proximas acoes, ETN, proposta simulada e status de integracao.

**FRs covered:** FR16, FR17, FR18, FR19, FR20, FR26

### Epic 5: Governanca De Desconto E Fechamento Demonstravel

Executivos e gestores conseguem registrar, acompanhar e demonstrar aprovacao de desconto e fechamento com rastreabilidade suficiente para a demo.

**FRs covered:** FR21, FR22, FR23, FR24, FR31, FR32

### Epic 6: Dashboards, Dados De Demo E Validacao Do Roteiro

Gestao, diretoria e equipe de demo conseguem apresentar dashboards, dados demonstrativos e a jornada ponta a ponta com fluidez.

**FRs covered:** FR27, FR28, FR29, FR30

## FR Coverage Map

FR1: Epic 1 - Solution unmanaged criada.
FR2: Epic 1 - Componentes dentro da solution.
FR3: Epic 1 - Uso do Sales Hub nativo.
FR4: Epic 1 - Sem app novo/sitemap customizado.
FR5: Epic 1 - Preservacao de formularios originais.
FR6: Epic 2 - Leads por etapa.
FR7: Epic 2 - Campos essenciais no Cliente Potencial.
FR8: Epic 2 - Checklist de qualificacao.
FR9: Epic 2 - BPF Lead Senior.
FR10: Epic 2 - Qualificacao nativa para Conta/Contato/Oportunidade.
FR11: Epic 3 - Conta 360.
FR12: Epic 3 - Radar da Conta.
FR13: Epic 3 - Decisores, oportunidades e historico.
FR14: Epic 3 - Formulario Contato orientado a influencia.
FR15: Epic 3 - Associacao de contatos e papeis.
FR16: Epic 4 - Formulario Oportunidade.
FR17: Epic 4 - BPF Oportunidade Senior Privado.
FR18: Epic 4 - Acionamento ETN.
FR19: Epic 4 - Simulacao CPQ/GPS.
FR20: Epic 4 - Status de integracao.
FR21: Epic 5 - Solicitar desconto.
FR22: Epic 5 - Status de aprovacao.
FR23: Epic 5 - Registro de aprovacao.
FR24: Epic 5 - Etapa aprovacao no fluxo.
FR25: Epic 2 - Views de leads por etapa.
FR26: Epic 4 - Views de oportunidades.
FR27: Epic 6 - Dashboard operacional.
FR28: Epic 6 - Dashboard executivo.
FR29: Epic 6 - Metricas executivas.
FR30: Epic 6 - Dados ficticios criveis.
FR31: Epic 5 - Jornada privada completa.
FR32: Epic 5 - Caso de desconto.
FR33: Epic 3 - Conta estrategica para Radar da Conta.

## Implementation Status Snapshot

Last updated: 2026-05-27

| Epic | Status | Notes |
|---|---|---|
| Epic 1 - Fundacao Governada No Sales Hub | done | Solution, PAC flow, Sales Hub guardrails and native-field-first premise are established. |
| Epic 2 - Qualificacao De Leads Senior | done | Lead mapping, `Cliente Potencial Senior`, `Lead Senior` BPF and stage views are deployed. |
| Epic 3 - Conta 360 E Relacionamento | done | Account/Contact mapping and forms are deployed; demo account/contact data is available for the Radar narrative. |
| Epic 4 - Oportunidade Senior E Pipeline Privado | partially done | Opportunity mapping/form/views and ETN/CPQ status fields are deployed; Opportunity BPF workflow exists but full XAML stage replacement is blocked by Dataverse validation. |
| Epic 5 - Governanca De Desconto E Fechamento Demonstravel | mostly done | Governance fields, form area and demo data are deployed; close journey still needs live validation. |
| Epic 6 - Dashboards, Dados De Demo E Validacao Do Roteiro | mostly done | Demo data and dashboards are deployed; final browser walkthrough remains pending. |

## Story Status Matrix

| Story | Status | Artifact |
|---|---|---|
| 1.1 Validar Solution E ALM Base | done | `deployment-log.md` |
| 1.2 Inventariar Campos Nativos Antes De Customizar | done | `native-field-inventory.md` |
| 1.3 Definir Guardrails De Customizacao No Sales Hub | done | PRD, architecture and this epic document |
| 2.1 Mapear Campos Nativos De Lead | done | `story-2.1-lead-field-mapping.md` |
| 2.2 Criar Formulario Cliente Potencial Senior | deployed | `story-2.2-lead-form-build.md` |
| 2.3 Criar BPF Lead Senior | deployed | `story-2.3-lead-bpf-build.md` |
| 2.4 Criar Views De Leads Por Etapa | deployed | `story-2.4-lead-stage-views.md` |
| 3.1 Mapear Campos Nativos De Conta E Contato | documented | `story-3.1-account-contact-field-mapping.md` |
| 3.2 Criar Formulario Conta Senior Com Radar Da Conta | deployed | `story-3.2-account-form-build.md` |
| 3.3 Criar Formulario Contato Senior | deployed | `story-3.3-contact-form-build.md` |
| 4.1 Mapear Campos Nativos De Oportunidade | done | `story-4.1-opportunity-field-mapping.md` |
| 4.2 Criar Formulario Oportunidade Senior | deployed | `story-4.2-opportunity-form-build.md` |
| 4.3 Criar BPF Oportunidade Senior Privado | partially-deployed-xaml-blocked | `story-4.3-opportunity-bpf-build.md` |
| 4.4 Simular ETN E CPQ/GPS Na Oportunidade | partially-deployed | `story-4.4-opportunity-etn-cpq-simulation.md` |
| 4.5 Criar Views De Oportunidades Senior | deployed | `story-4.5-opportunity-views.md` |
| 5.1 Mapear Campos Nativos Para Desconto E Fechamento | deployed | `story-5.1-discount-close-field-mapping.md` |
| 5.2 Criar Experiencia De Solicitacao De Desconto | partially-deployed | `story-5.2-discount-request-experience.md` |
| 5.3 Demonstrar Fechamento Da Jornada Privada | ready-for-demo-data | `story-5.3-private-journey-close.md` |
| 6.1 Criar Dados Demonstrativos Criveis | deployed | `story-6.1-demo-data.md` |
| 6.2 Criar Dashboard Operacional | deployed | `story-6.2-operational-dashboard.md` |
| 6.3 Criar Dashboard Executivo | deployed | `story-6.3-executive-dashboard.md` |
| 6.4 Validar Roteiro Ponta A Ponta | package-ready-pending-live-walkthrough | `story-6.4-end-to-end-route-validation.md` |

## Recommended Execution Order

1. Resolve Story 4.3 full BPF stage rendering through Maker Portal designer or a stronger XAML generator.
2. Run Story 6.4 complete Sales Hub validation.
3. Export/unpack the final package after BPF visual validation if the Opportunity BPF is corrected.

## Epic 1: Fundacao Governada No Sales Hub

Objetivo: estabelecer uma base segura, rastreavel e aderente ao Sales Hub nativo, evitando customizacao redundante.

### Story 1.1: Validar Solution E ALM Base

As a consultor de solucao,
I want validar a solution `nexer_senior_demo_crm_b` e o fluxo PAC,
So that todas as proximas customizacoes sejam rastreaveis e exportaveis.

**Acceptance Criteria:**

- **Given** acesso autenticado ao ambiente `Nexer EA BR - Presales`
  **When** eu listar as solutions via PAC
  **Then** a solution `nexer_senior_demo_crm_b` deve existir como unmanaged.
- **Given** a solution existe
  **When** eu exportar e desempacotar via PAC
  **Then** o workspace local deve conter o pacote versionavel da solution.
- **Given** a solution existe
  **When** eu revisar componentes adicionados
  **Then** Lead, Account, Contact e Opportunity devem estar incluidos.

### Story 1.2: Inventariar Campos Nativos Antes De Customizar

As a arquiteto de Dataverse,
I want inventariar campos nativos e choices existentes nas tabelas core,
So that a demo reutilize o maximo possivel do Sales Hub antes de criar campos `nexer_*`.

**Acceptance Criteria:**

- **Given** as tabelas Lead, Account, Contact e Opportunity estao na solution
  **When** eu exportar metadata ou revisar campos existentes
  **Then** deve existir um inventario local por tabela com campos candidatos para origem, segmento, receita/potencial, status, tipo, fonte, prioridade, forecast, probabilidade, desconto e relacionamento.
- **Given** um requisito de dado da Senior
  **When** houver campo nativo semanticamente adequado
  **Then** a story de implementacao deve reutilizar esse campo em vez de criar novo campo.
- **Given** um campo nativo usa choice
  **When** os valores existentes puderem representar a necessidade Senior
  **Then** a preferencia deve ser editar/adicionar valores no choice existente, sem criar choice novo.
- **Given** nao existir campo nativo adequado
  **When** for necessario criar campo novo
  **Then** o campo deve usar prefixo `nexer_` e justificativa registrada no inventario.

### Story 1.3: Definir Guardrails De Customizacao No Sales Hub

As a responsavel tecnico da demo,
I want documentar regras de customizacao,
So that o time nao altere componentes originais nem crie app paralelo.

**Acceptance Criteria:**

- **Given** o projeto possui PRD e arquitetura
  **When** eu revisar guardrails
  **Then** deve estar explicito que nao sera criado novo app model-driven.
- **Given** formularios nativos existem
  **When** formos criar experiencia Senior
  **Then** novos formularios devem ser criados ou clonados dentro da solution, sem editar originais.
- **Given** uma alteracao manual for feita no Maker Portal
  **When** ela for concluida
  **Then** deve haver export/unpack via PAC e registro no log.

## Epic 2: Qualificacao De Leads Senior

Objetivo: permitir que Sales Ops/LDR/SDR qualifiquem leads com linguagem Senior, baixo atrito e visibilidade por etapa.

### Story 2.1: Mapear Campos Nativos De Lead Para Qualificacao Senior

As a consultor funcional,
I want mapear campos nativos de Lead para o processo Senior,
So that o formulario de Cliente Potencial use o minimo de campos customizados.

**Acceptance Criteria:**

- **Given** a tabela Lead possui campos nativos
  **When** eu mapear origem, status, fonte, rating, empresa, receita, telefone, email e cargo
  **Then** devo indicar quais requisitos do PRD sao atendidos por campos nativos.
- **Given** valores nativos de origem/status nao atendem o roteiro
  **When** for necessario ajustar choices
  **Then** devo propor edicao/adicao de valores existentes antes de criar novos choices.
- **Given** alguma informacao Senior nao possui equivalente nativo
  **When** ela for essencial ao roteiro
  **Then** devo propor campo `nexer_` com justificativa.

### Story 2.2: Criar Formulario Cliente Potencial Senior

As a Pamela/Sales Ops,
I want ver um formulario de Cliente Potencial com dados essenciais e checklist,
So that eu qualifique leads sem procurar informacao em varias abas.

**Acceptance Criteria:**

- **Given** o formulario e criado dentro da solution da demo
  **When** o usuario abre um Cliente Potencial
  **Then** a primeira dobra deve mostrar origem, segmento, porte/potencial, dor, produto de interesse, score/prioridade e proxima acao.
- **Given** campos nativos atendem ao requisito
  **When** o formulario for configurado
  **Then** os campos nativos devem ser usados antes de campos customizados.
- **Given** o lead esta em qualificacao
  **When** o usuario acessa a aba Qualificacao
  **Then** deve haver checklist com necessidade, orcamento, decisor, prazo e aderencia Senior.

### Story 2.3: Criar BPF Lead Senior

As a LDR/SDR,
I want conduzir o lead por etapas Senior,
So that a qualificacao seja padronizada e demonstravel.

**Acceptance Criteria:**

- **Given** o BPF e criado na solution
  **When** um lead entra no processo
  **Then** as etapas devem ser Entrada, Filtro 1, Filtro 2, Agendado e Qualificado.
- **Given** uma etapa exige dados
  **When** campos forem adicionados ao step
  **Then** devem priorizar campos nativos mapeados.
- **Given** o lead chega a Qualificado
  **When** o usuario qualifica o lead
  **Then** o comportamento nativo deve gerar/relacionar Conta, Contato e Oportunidade.

### Story 2.4: Criar Views De Leads Por Etapa

As a Pamela/Sales Ops,
I want ver leads por etapa e pendencia,
So that eu priorize acao rapidamente.

**Acceptance Criteria:**

- **Given** existem leads de demo
  **When** eu acessar as views de Cliente Potencial
  **Then** devo ver views para Entrada, Filtro 1, Filtro 2, Agendado e Qualificado.
- **Given** uma view exibe campos de contexto
  **When** ela for configurada
  **Then** deve mostrar nome, empresa, origem, prioridade/score, proprietario e proxima acao.

## Epic 3: Conta 360 E Relacionamento

Objetivo: entregar o momento "Radar da Conta" para Pamela e executivos.

### Story 3.1: Mapear Campos Nativos De Conta E Contato

As a consultor funcional,
I want mapear campos nativos de Account e Contact,
So that Radar da Conta e Relacionamento usem o maximo do modelo nativo.

**Acceptance Criteria:**

- **Given** Account e Contact possuem campos nativos
  **When** eu mapear receita, setor, telefone, site, endereco, owner, contatos e relacionamento
  **Then** devo indicar campos reutilizaveis antes de propor `nexer_*`.
- **Given** papel decisorio do contato nao existir nativamente
  **When** for essencial para demo
  **Then** devo justificar se usaremos campo customizado ou relacionamento existente.

### Story 3.2: Criar Formulario Conta Senior Com Radar Da Conta

As a executivo de vendas,
I want abrir uma conta e entender contexto comercial em uma tela,
So that eu decida a proxima acao sem garimpar informacao.

**Acceptance Criteria:**

- **Given** o formulario de Conta Senior existe
  **When** eu abrir uma conta estrategica
  **Then** devo ver Radar da Conta com oportunidades abertas, receita em negociacao, produtos contratados, riscos, pendencias, decisores e proxima acao.
- **Given** dados puderem vir de subgrids nativos
  **When** o formulario for configurado
  **Then** deve reutilizar subgrids/relacionamentos nativos antes de criar tabela customizada.
- **Given** algum dado de ERP/Neoway/Customer Insights for simulado
  **When** exibido na conta
  **Then** deve ser identificado como dado de demo/simulacao por campo/status apropriado.

### Story 3.3: Criar Formulario Contato Senior

As a executivo de vendas,
I want identificar o papel e influencia de cada contato,
So that eu conduza stakeholders de forma mais eficaz.

**Acceptance Criteria:**

- **Given** o formulario de Contato Senior existe
  **When** eu abrir um contato
  **Then** devo ver cargo, conta, papel na decisao, influencia, canal preferido, ultima interacao e proxima acao.
- **Given** houver campo nativo ou relacionamento existente para dados de contato
  **When** o formulario for configurado
  **Then** deve reutilizar o componente nativo.

## Epic 4: Oportunidade Senior E Pipeline Privado

Objetivo: permitir que o executivo conduza a oportunidade com clareza, ETN e integracoes simuladas.

### Story 4.1: Mapear Campos Nativos De Oportunidade

As a consultor funcional,
I want mapear campos nativos de Opportunity,
So that o formulario e BPF reaproveitem valor, probabilidade, forecast, data de fechamento, etapa e owner.

**Acceptance Criteria:**

- **Given** Opportunity possui campos nativos
  **When** eu mapear valor, probabilidade, forecast, close date, status, processo e owner
  **Then** devo indicar campos nativos a reutilizar.
- **Given** desconto, margem ou status de integracao nao tenham equivalente nativo adequado
  **When** forem essenciais para demo
  **Then** devo propor campo `nexer_` com justificativa.

### Story 4.2: Criar Formulario Oportunidade Senior

As a executivo de vendas,
I want visualizar fase, valor, risco e proxima acao da oportunidade,
So that eu avance a venda com menos cliques.

**Acceptance Criteria:**

- **Given** o formulario Oportunidade Senior existe
  **When** eu abrir uma oportunidade
  **Then** a primeira dobra deve exibir fase, valor, probabilidade, data prevista, produto/solucao, desconto/margem, proxima acao e responsavel.
- **Given** a oportunidade precisa acionar operacao
  **When** o usuario navega na oportunidade
  **Then** deve haver area para ETN, CPQ/GPS, integracoes e aprovacao.
- **Given** campos nativos atendem valor/probabilidade/data/owner
  **When** o formulario for configurado
  **Then** esses campos nativos devem ser usados.

### Story 4.3: Criar BPF Oportunidade Senior Privado

As a executivo de vendas,
I want seguir as etapas comerciais Senior no BPF,
So that a demo mostre venda complexa com governanca.

**Acceptance Criteria:**

- **Given** o BPF e criado na solution
  **When** uma oportunidade privada usa o processo
  **Then** as etapas devem ser Qualificacao, Desenvolvimento, Proposta, Negociacao, Aprovacao de Desconto, Contrato e Assinatura, Fechamento.
- **Given** campos de etapa sao configurados
  **When** houver campo nativo adequado
  **Then** o BPF deve usar campo nativo.
- **Given** a etapa Aprovacao de Desconto for mantida
  **When** a oportunidade entrar nessa etapa
  **Then** status de aprovacao deve estar visivel.

### Story 4.4: Simular ETN E CPQ/GPS Na Oportunidade

As a executivo de vendas,
I want acionar ETN e simular proposta CPQ/GPS,
So that eu mostre continuidade operacional sem sair da oportunidade.

**Acceptance Criteria:**

- **Given** a oportunidade precisa apoio tecnico
  **When** o usuario aciona ETN
  **Then** deve ser criado ou relacionado um Case/registro demonstravel com tipo ETN e status.
- **Given** o usuario simula CPQ/GPS
  **When** a acao for executada
  **Then** a oportunidade deve mostrar ID/status de proposta simulada.

### Story 4.5: Criar Views De Oportunidades Senior

As a gestor comercial,
I want visualizar oportunidades por pipeline, carteira, proposta, desconto e fechamento,
So that eu acompanhe gargalos do processo Senior dentro do Sales Hub.

**Acceptance Criteria:**

- **Given** a solution `nexer_senior_demo_crm_b` existe
  **When** views de oportunidade forem criadas
  **Then** elas devem estar adicionadas como savedqueries da solution.
- **Given** o usuario abre views de oportunidade
  **When** ele seleciona uma view Senior 360
  **Then** deve conseguir ver pipeline aberto, minha carteira, proposta/CPQ/GPS, desconto/aprovacao, fechamento em 30 dias e oportunidades ganhas.
- **Given** as views exibem contexto comercial
  **When** configuradas
  **Then** devem priorizar campos nativos de valor, cliente, owner, data prevista e status, usando campos `nexer_` apenas para status de simulacao/governanca.

## Epic 5: Governanca De Desconto E Fechamento Demonstravel

Objetivo: demonstrar alçada, aprovacao e fechamento de forma rastreavel.

### Story 5.1: Mapear Campos Nativos Para Desconto E Fechamento

As a consultor funcional,
I want validar campos nativos de desconto, receita, quote/order e fechamento,
So that a demo use recursos existentes antes de criar campos novos.

**Acceptance Criteria:**

- **Given** Opportunity/Quote possuem campos nativos
  **When** eu mapear desconto, receita, fechamento e status
  **Then** devo registrar campos reutilizaveis.
- **Given** status de aprovacao nao existir nativamente
  **When** for necessario para a demo
  **Then** devo propor choice/campo `nexer_` justificado.

### Story 5.2: Criar Experiencia De Solicitacao De Desconto

As a executivo,
I want solicitar desconto com justificativa e status,
So that a aprovacao seja demonstravel e auditavel.

**Acceptance Criteria:**

- **Given** uma oportunidade possui desconto acima da alcada
  **When** o usuario registra solicitacao
  **Then** status deve mudar para Pendente e gravar justificativa/aprovador sugerido.
- **Given** aprovacao e simulada ou real
  **When** o aprovador decide
  **Then** status deve mudar para Aprovada ou Rejeitada com data e comentario.

### Story 5.3: Demonstrar Fechamento Da Jornada Privada

As a Sales Ops,
I want fechar a oportunidade e mostrar rastreabilidade de integracao,
So that a demo complete a narrativa de lead a fechamento.

**Acceptance Criteria:**

- **Given** uma oportunidade esta aprovada
  **When** ela avancar para Contrato e Assinatura
  **Then** deve exibir status de contrato/assinatura simulado.
- **Given** a oportunidade e fechada como ganha
  **When** o fechamento e registrado
  **Then** deve haver status/log de envio ERP Sapiens simulado.

## Epic 6: Dashboards, Dados De Demo E Validacao Do Roteiro

Objetivo: permitir apresentacao ponta a ponta para gestao e diretoria.

### Story 6.1: Criar Dados Demonstrativos Criveis

As a apresentador da demo,
I want dados ficticios consistentes,
So that a narrativa pareca Senior e nao uma base generica.

**Acceptance Criteria:**

- **Given** a demo precisa de jornada completa
  **When** a massa for criada
  **Then** deve conter pelo menos uma conta estrategica, contatos, lead, oportunidade, ETN, desconto e fechamento.
- **Given** a demo usa linguagem Senior
  **When** registros forem nomeados
  **Then** devem usar termos como Filial, Linha de Producao, ETN, GPS, Smart Lead e Canal.

### Story 6.2: Criar Dashboard Operacional

As a Pamela/Sales Ops,
I want ver leads, pendencias e aprovacao em painel operacional,
So that eu acompanhe fluidez e gargalos.

**Acceptance Criteria:**

- **Given** existem dados de demo
  **When** Pamela abre dashboard operacional
  **Then** deve ver leads por etapa, leads parados, oportunidades com pendencia e aprovacoes.

### Story 6.3: Criar Dashboard Executivo

As a diretoria comercial,
I want ver pipeline consolidado e indicadores chave,
So that eu avalie previsibilidade e riscos.

**Acceptance Criteria:**

- **Given** existem oportunidades de demo
  **When** abrir dashboard executivo
  **Then** deve mostrar pipeline por etapa, forecast, taxa de conversao, ticket medio, oportunidades por linha de negocio e top oportunidades.

### Story 6.4: Validar Roteiro Ponta A Ponta

As a time de presales,
I want validar a demo de ponta a ponta,
So that a apresentacao seja fluida e confiavel.

**Acceptance Criteria:**

- **Given** todos os componentes MVP estao configurados
  **When** o roteiro for executado
  **Then** deve ser possivel demonstrar lead -> conta -> oportunidade -> ETN/CPQ -> aprovacao -> fechamento -> dashboard.
- **Given** algum componente externo falha
  **When** a demo for executada
  **Then** a simulacao deve permitir continuar sem quebrar a narrativa.
