---
title: "PRD - Senior Demo CRM B"
status: "draft"
created: "2026-05-25"
updated: "2026-05-25"
project_name: "senior"
product: "Dynamics 365 Sales Demo for Senior Sistemas"
solution: "nexer_senior_demo_crm_b"
environment: "https://nexereabrpresales.crm.dynamics.com"
---

# PRD - Senior Demo CRM B

## 1. Resumo

Este PRD define o escopo da demo presales da Senior Sistemas no Dynamics 365 Sales, usando o Sales Hub nativo como experiencia principal.

A demo deve demonstrar, ao vivo e sem depender de slides durante a navegacao, uma jornada comercial ponta a ponta: geracao de demanda, qualificacao, venda, acionamento tecnico, proposta, aprovacao de desconto, fechamento e visibilidade executiva.

O objetivo nao e entregar uma implantacao produtiva completa da Senior. O objetivo e construir uma experiencia demonstravel, fluida e governada, mostrando como a Senior pode operar vendas complexas em um fluxo nativo do Dynamics 365 Sales com linguagem, processos e dados proximos do negocio Senior.

## 2. Problema

A Senior precisa visualizar como o Dynamics 365 Sales pode melhorar a operacao comercial atual, especialmente em usabilidade, governanca e visibilidade.

A dor mais critica vem de Pamela Rosa, Sales Operations:

> Preciso ver o mao na massa do executivo... a responsividade, tempo de troca, quantos cliques ele tem que fazer.

O risco da demo e parecer generica ou pesada, repetindo a experiencia de um CRM onde o usuario precisa procurar informacao em muitas abas, sistemas e planilhas. A demo precisa provar que o executivo e a gestao conseguem trabalhar melhor dentro do Sales Hub.

## 3. Objetivos

1. Demonstrar a jornada comercial Senior dentro do Sales Hub nativo.
2. Reduzir friccao percebida em tarefas do executivo, Sales Ops e gestao.
3. Apresentar formularios Senior focados em decisao rapida, inspirados em Sales Insights.
4. Mostrar BPFs novos para qualificacao de lead e pipeline de oportunidade.
5. Simular integracoes relevantes com rastreabilidade, sem depender de APIs externas instaveis.
6. Demonstrar governanca de desconto via fluxo controlado.
7. Dar visibilidade executiva de pipeline, forecast, gargalos e produtividade.

## 4. Nao Objetivos

1. Criar um novo model-driven app.
2. Substituir o Sales Hub nativo.
3. Criar sitemap customizado nesta fase.
4. Implementar CPQ completo.
5. Implementar integracao real obrigatoria com ERP Sapiens, GPS, Neoway, assinatura ou WhatsApp.
6. Construir IA customizada.
7. Cobrir todos os processos produtivos da Senior com profundidade final.
8. Alterar formularios originais ou componentes nativos sem isolamento na solution da demo.

## 5. Publico-Alvo E Personas

### Pamela Rosa - Sales Operations

Foco: usabilidade, reducao de cliques, responsividade, padronizacao e fluidez operacional.

Sucesso para Pamela:

- O executivo entende o que fazer sem procurar informacao.
- A qualificacao e o avanco de oportunidades exigem menos cliques.
- A demo mostra tempo de troca e navegacao real no Sales Hub.

### Marcia Vieira - Diretoria Comercial

Foco: visao estrategica, pipeline consolidado, white space, insights e previsibilidade.

Sucesso para Marcia:

- Enxerga pipeline por etapa, filial, linha de negocio e trimestre.
- Identifica oportunidades de cross-sell e riscos comerciais.

### Marlus Moraes - Gestao de Vendas

Foco: dashboards, IA, produtividade, aging e proximas acoes.

Sucesso para Marlus:

- Consegue ver gargalos, oportunidades paradas e produtividade por executivo.
- Ve insights proativos e sinais de risco.

### Juliana Felipe / Sara Cristina - Marketing / Smart Lead

Foco: geracao de demanda, inbound, eventos, segmentos e transicao para vendas.

Sucesso para Marketing:

- Leads entram no CRM com origem, interesse e contexto.
- A equipe acompanha conversao MQL -> SQL -> oportunidade -> venda.

### Herminio Gastaldi - VP Comercial

Foco: ROI, alçadas, governanca e visao executiva.

Sucesso para Herminio:

- Ve uma venda complexa com controle, aprovacao e visibilidade.
- Entende como a solucao reduz retrabalho e melhora previsibilidade.

## 6. Principios De Produto

1. Sales Hub nativo primeiro.
2. Demonstrar valor de negocio, nao configuracao administrativa.
3. Formularios como cockpit de decisao, nao cadastro extenso.
4. Integracoes simuladas precisam parecer rastreaveis e criveis.
5. Poucos campos obrigatorios.
6. Cada tela da demo deve responder: quem e, quanto vale, onde esta, o que ameaca e o que fazer agora.
7. Toda customizacao deve estar contida na solution `nexer_senior_demo_crm_b`.

## 7. Escopo MVP

### Incluido

- Solution unmanaged `nexer_senior_demo_crm_b`.
- Uso do Sales Hub nativo.
- Tabelas base na solution:
  - Lead
  - Account
  - Contact
  - Opportunity
- Formularios Senior novos para:
  - Cliente Potencial
  - Conta
  - Contato
  - Oportunidade
- BPF Lead Senior.
- BPF Oportunidade Senior Privado.
- Campos customizados minimos para segmentacao, linha de negocio, integracao, score e aprovacao.
- Views por persona.
- Dashboards operacional e executivo.
- Fluxo simples de aprovacao de desconto.
- Dados demonstrativos para uma narrativa ponta a ponta.
- Simulacao de integracoes GPS/CPQ, ERP Sapiens, Neoway e Customer Insights por campos/logs/status.

### Fora Do MVP

- BPF completo de Governo, exceto se for necessario para a demo final. [ASSUMPTION]
- Portal Power Pages para canal.
- Customer Insights real conectado.
- Copilot Studio real para WhatsApp/audio.
- CPQ real.
- Integracao real ERP Sapiens.
- Security model completo por filial/canal.

## 8. Jornada Da Demo

### Ato 1 - Geracao De Demanda

Marketing gera ou importa leads de evento, formulario ou outbound. O lead entra com origem, interesse, segmento, linha de negocio e score/prioridade.

### Ato 2 - Qualificacao De Leads

Pamela/Sales Ops/LDR visualiza leads por etapa, valida dados, enriquece informacoes simuladas e move o lead no BPF.

Etapas do Lead Senior:

- Entrada
- Filtro 1
- Filtro 2
- Agendado
- Qualificado

### Ato 3 - Executivo De Vendas

O executivo acessa Conta 360, entende o Radar da Conta, cria ou assume uma oportunidade e avanca pelo BPF de oportunidade.

Etapas da Oportunidade Senior Privado:

- Qualificacao
- Desenvolvimento
- Proposta
- Negociacao
- Aprovacao de Desconto
- Contrato e Assinatura
- Fechamento

### Ato 4 - ETN E Proposta

A oportunidade envolve necessidade tecnica. O executivo aciona ETN via Case ou registro relacionado e gera simulacao de proposta CPQ/GPS.

### Ato 5 - Aprovacao De Desconto

O executivo solicita desconto acima da alcada. O fluxo registra solicitacao, justificativa, aprovador, status e decisao.

### Ato 6 - Fechamento

A oportunidade avanca para contrato/assinatura e fechamento. A integracao com ERP Sapiens e assinatura pode ser representada por status/logs simulados.

### Ato 7 - Gestao E Diretoria

Gestao visualiza pipeline, produtividade, forecast, oportunidades paradas, aprovacoes e oportunidades de cross-sell.

## 9. Requisitos Funcionais

### Solution E Governanca

FR1. A solucao deve existir como solution unmanaged chamada `nexer_senior_demo_crm_b`.

FR2. Todos os componentes de demo devem ser criados ou adicionados dentro da solution `nexer_senior_demo_crm_b`.

FR3. A demo deve usar o Sales Hub nativo como aplicativo principal.

FR4. A solucao nao deve criar novo model-driven app nem sitemap customizado.

FR5. A solucao nao deve alterar diretamente formularios originais do Sales Hub ou Sales Insights.

### Cliente Potencial

FR6. O usuario deve conseguir visualizar leads por etapa de qualificacao Senior.

FR7. O formulario de Cliente Potencial deve exibir origem, segmento, porte, potencial, dor principal, produto de interesse, score/prioridade e proxima acao.

FR8. O formulario de Cliente Potencial deve conter uma area de checklist de qualificacao.

FR9. O BPF de Lead Senior deve orientar o lead pelas etapas Entrada, Filtro 1, Filtro 2, Agendado e Qualificado.

FR10. O usuario deve conseguir qualificar um lead e seguir para Conta, Contato e Oportunidade usando comportamento nativo do Dynamics.

### Conta

FR11. O formulario de Conta deve oferecer uma visao 360 orientada a decisao.

FR12. O formulario de Conta deve exibir o Radar da Conta com oportunidades abertas, receita em negociacao, produtos contratados, riscos, pendencias e proxima acao.

FR13. O usuario deve conseguir identificar rapidamente decisores, oportunidades abertas e historico de interacoes da conta.

### Contato

FR14. O formulario de Contato deve destacar papel na venda, nivel de influencia, preferencia de contato, ultima interacao e proxima acao.

FR15. O usuario deve conseguir associar contatos a oportunidades e identificar decisor, influenciador, sponsor ou opositor. [ASSUMPTION]

### Oportunidade

FR16. O formulario de Oportunidade deve exibir fase, valor, probabilidade, data prevista, produto/solucao, margem/desconto, proxima acao e responsavel.

FR17. O BPF de Oportunidade Senior Privado deve conter as etapas Qualificacao, Desenvolvimento, Proposta, Negociacao, Aprovacao de Desconto, Contrato e Assinatura, Fechamento.

FR18. O usuario deve conseguir acionar ETN a partir da oportunidade.

FR19. O usuario deve conseguir simular geracao de proposta CPQ/GPS a partir da oportunidade.

FR20. O usuario deve conseguir visualizar status de integracao CPQ/GPS e ERP Sapiens na oportunidade.

### Aprovacao De Desconto

FR21. O usuario deve conseguir registrar solicitacao de desconto na oportunidade.

FR22. O sistema deve exibir status de aprovacao de desconto: Nao Solicitada, Pendente, Aprovada, Rejeitada ou Escalada.

FR23. A demo deve demonstrar aprovacao de desconto com registro de aprovador, data e justificativa.

FR24. A etapa Aprovacao de Desconto deve ser visivel no fluxo de oportunidade, salvo decisao posterior de tratar como subprocesso. [ASSUMPTION]

### Views E Dashboards

FR25. A solucao deve fornecer views de leads por etapa.

FR26. A solucao deve fornecer views de oportunidades por pipeline, etapa, executivo e pendencia.

FR27. A solucao deve fornecer dashboard operacional para pre-vendas/Sales Ops.

FR28. A solucao deve fornecer dashboard executivo de pipeline consolidado.

FR29. O dashboard executivo deve mostrar pipeline por etapa, forecast, taxa de conversao, ticket medio, oportunidades por linha de negocio e top oportunidades.

### Dados De Demo

FR30. A demo deve conter dados ficticios criveis de contas, contatos, leads, oportunidades, aprovacoes e interacoes.

FR31. Deve existir pelo menos uma jornada privada completa demonstravel de lead ate fechamento.

FR32. Deve existir pelo menos um caso de desconto pendente/aprovado para demonstracao.

FR33. Deve existir pelo menos uma conta estrategica para demonstrar Radar da Conta.

## 10. Requisitos Nao Funcionais

NFR1. A demo deve ser executavel ao vivo no Sales Hub nativo.

NFR2. As tarefas principais devem minimizar troca de abas e navegacao entre entidades.

NFR3. Formularios devem priorizar informacoes de decisao na primeira dobra.

NFR4. A solucao deve preservar componentes originais do ambiente.

NFR5. A solution deve ser exportavel via PAC para backup e versionamento.

NFR6. A demo deve tolerar indisponibilidade de integracoes externas usando simulacoes criveis.

NFR7. A experiencia deve funcionar em tela desktop e ser demonstravel em contexto responsivo/mobile quando necessario.

NFR8. O roteiro principal deve caber em uma demonstracao hands-on sem slides durante a navegacao.

NFR9. Nomes de campos, secoes e views devem usar terminologia Senior: Filial, Canal de Distribuicao, ETN, GPS, Linha de Producao, Atuacao Conjunta, Smart Lead, LDR, SDR e BDR.

NFR10. A solucao deve evitar campos obrigatorios excessivos que prejudiquem fluidez.

## 11. UX E Experiencia

### Meta De Experiencia

O usuario deve sentir que o formulario ja sabe o que ele precisa fazer em seguida.

### Ganhos De Clique A Demonstrar

| Tarefa | Antes | Depois | Ganho Alvo |
|---|---:|---:|---:|
| Entender conta | 10 cliques | 3 cliques | -70% |
| Qualificar lead | 8 cliques | 2 cliques | -75% |
| Solicitar desconto | 6 acoes | 2 acoes | -67% |
| Preparar reuniao | 5 buscas | 1 resumo | -80% |

### Estrutura Dos Formularios

Todos os formularios devem priorizar:

1. Identidade
2. Valor
3. Status
4. Risco
5. Proxima acao

## 12. Requisitos De Dados

Campos e choices sugeridos:

- Linha de Producao: HCM, ERP, Logistica, Acesso e Seguranca, CRM, GRS.
- Tipo de Cliente: Privado, Governo, Canal.
- Tipo de Venda: Greenfield, Base, Upgrade de Licenca.
- Status de Aprovacao: Nao Solicitada, Pendente, Aprovada, Rejeitada, Escalada.
- Status de Integracao: Pendente, Enviado, Processado, Erro, Simulado.
- Tipo ETN: HCM, ERP, Logistica, Acesso e Seguranca, Tecnico, Comercial.

Campos prioritarios:

- `nexer_linha_producao`
- `nexer_segmento`
- `nexer_tipo_cliente`
- `nexer_filial_responsavel`
- `nexer_cnpj`
- `nexer_porte`
- `nexer_faturamento_estimado`
- `nexer_colaboradores`
- `nexer_status_neoway`
- `nexer_cliente_senior`
- `nexer_produtos_contratados`
- `nexer_adimplencia`
- `nexer_score_relacionamento`
- `nexer_requer_aprovacao`
- `nexer_status_aprovacao`
- `nexer_id_gps_cpq`
- `nexer_id_sapiens`
- `nexer_data_envio_erp`

## 13. Requisitos De ALM E Deploy

1. PAC CLI deve ser usado para auth, export, unpack, pack, import e versionamento sempre que possivel.
2. Maker Portal pode ser usado uma vez para autoria inicial visual de formularios e BPFs.
3. Toda alteracao manual deve ser seguida de export/unpack para versionamento.
4. A solution deve permanecer unmanaged durante construcao.
5. Export managed deve ocorrer apenas apos validacao ponta a ponta.

## 14. Metricas De Sucesso

1. Pamela valida que a navegacao do executivo esta clara e fluida.
2. A demo executa a jornada principal sem depender de slides durante o fluxo.
3. Conta 360/Radar da Conta demonstra reducao de busca e troca de tela.
4. Oportunidade demonstra avanco de etapa, ETN, proposta e aprovacao.
5. Dashboards respondem a perguntas de gestao e diretoria.
6. A solution pode ser exportada e versionada via PAC.

## 15. Riscos

1. Tentativa de automatizar formularios complexos via XML incompleto pode falhar.
2. BPFs demais podem tornar a demo longa e pesada.
3. Integracoes reais podem introduzir instabilidade.
4. Excesso de campos obrigatorios pode prejudicar a narrativa de usabilidade.
5. Alteracoes fora da solution podem comprometer ALM.
6. Sales Insights pode conter dependencias/licencas que dificultem clonagem fiel.

## 16. Decisoes Em Aberto

1. Lead deve ou nao ter etapa "Vendido"?
2. Governo entra no MVP como BPF proprio ou apenas como campo/view?
3. Aprovacao de desconto sera Power Automate Approvals real ou simulacao controlada?
4. Customer Insights sera real ou representado por campos simulados?
5. ETN bloqueia avanco da oportunidade ou apenas sinaliza risco?
6. Fechamento cria Quote/Order ou apenas fecha Opportunity como Won?
7. Quais usuarios/personas serao usados durante a demo?

