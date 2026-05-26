---
stepsCompleted: [1]
inputDocuments:
  - "C:/Users/Bruno Andrade/Downloads/Roteiro_Demo_Senior_D365Sales.md"
workflowType: "architecture"
project_name: "senior"
user_name: "Bruno Andrade"
date: "2026-05-25"
status: "initial-demo-architecture"
---

# Arquitetura Inicial - Senior Demo CRM B

## Contexto

Esta arquitetura orienta a construcao da demo Senior Sistemas no Dynamics 365 Sales / Dataverse, usando o roteiro compartilhado como documento de entrada.

Ambiente alvo:

- Dynamics 365 Sales: `https://nexereabrpresales.crm.dynamics.com/`
- Publisher: `nexer_`
- Solution: `nexer_senior_demo_crm_b`
- Aplicativo: Sales Hub nativo
- Tipo recomendado durante a construcao: unmanaged
- Tipo recomendado para transporte final: managed, somente depois da validacao ponta a ponta

O foco da demo e demonstrar uma jornada hands-on, com baixa friccao para o executivo comercial, evitando uma implementacao ampla demais para o prazo e para o objetivo de pre-vendas.

## Decisoes De Arquitetura

### ADR-001 - Solution Isolada Da Demo

Todas as customizacoes da demo devem entrar na solution `nexer_senior_demo_crm_b`.

Motivo:

- Evita componentes soltos na Default Solution.
- Garante prefixo `nexer_` em novos componentes.
- Facilita backup, exportacao, rollback e transporte.
- Reduz risco de afetar usuarios ou apps existentes no ambiente.

Regra operacional:

- Abrir editores de tabela/formulario sempre a partir da solution da demo.
- Nao usar "Add all assets" em tabelas padrao sem revisao.
- Nao publicar alteracoes globais do ambiente sem confirmacao.

### ADR-001A - Usar Sales Hub Nativo, Sem Criar Novo Aplicativo

A demo deve usar o aplicativo nativo Sales Hub como experiencia principal. Nao deve ser criado um novo model-driven app para a demo nesta fase.

Motivo:

- Reduz escopo e risco de configuracao.
- Mantem a experiencia proxima ao Dynamics 365 Sales padrao.
- Facilita demonstrar que a Senior pode evoluir em cima do Sales Hub sem criar uma casca paralela.
- Evita manutencao de sitemap/app module adicional.

Escopo permitido:

- Criar novos formularios Senior para Lead, Conta, Contato e Oportunidade.
- Criar novos BPFs Senior.
- Criar views, dashboards, campos e componentes dentro da solution.
- Configurar ordem/visibilidade dos novos formularios no Sales Hub somente apos validacao.

Fora de escopo nesta fase:

- Criar app `nexer_Senior Demo CRM`.
- Criar sitemap customizado.
- Substituir navegacao padrao do Sales Hub.

### ADR-002 - Formularios Sales Insights Como Base, Sem Editar Originais

Os formularios de Lead, Conta, Contato e Oportunidade devem usar os formularios Sales Insights como referencia visual e funcional, mas os originais nao devem ser alterados diretamente.

Formularios alvo:

- `nexer_Lead Sales Insights Senior Demo`
- `nexer_Account Sales Insights Senior Demo`
- `nexer_Contact Sales Insights Senior Demo`
- `nexer_Opportunity Sales Insights Senior Demo`

Estrategia:

- Criar/copiar formularios dentro da solution `nexer_senior_demo_crm_b`.
- Manter componentes nativos de Sales Insights quando funcionarem sem dependencias fragilizadas.
- Adicionar secoes Senior em areas controladas.
- Configurar uso preferencial via app/form order/role somente para a demo.

Risco:

- Formularios Sales Insights podem depender de componentes gerenciados, licencas, controles especificos, PCFs ou recursos habilitados no ambiente.

Mitigacao:

- Validar dependencias antes de publicar e exportar.
- Se algum controle nao empacotar bem, substituir por subgrid, quick view ou dashboard nativo para a demo.

### ADR-003 - Entidades Padrao Primeiro

A demo deve usar entidades padrao sempre que possivel:

- Lead
- Account
- Contact
- Opportunity
- Case / Incident
- Quote
- Product / Price List
- Order
- Activity
- Goal
- Territory

Tabelas customizadas devem ser criadas apenas quando melhorarem a narrativa ou reduzirem risco de integracao:

- `nexer_approvalrequest`
- `nexer_integrationlog`
- `nexer_cpqrequest`
- `nexer_erporderrequest`

### ADR-004 - Integracoes Demonstraveis Por Requests E Logs

GPS/CPQ, ERP Sapiens, Neoway, Customer Insights, Teams e WhatsApp devem ser modelados primeiro como integracoes demonstraveis por registros de request/log.

Motivo:

- A demo nao deve depender de APIs externas instaveis.
- Permite demonstrar payload, status, retorno e auditoria.
- Mantem o roteiro vivo mesmo se uma conexao externa falhar.

Padrao:

- Botao ou acao cria request.
- Flow atualiza status.
- Log aparece na timeline/subgrid.
- Dados de retorno simulados alimentam campos da oportunidade, cotacao ou pedido.

### ADR-005 - Dois Caminhos Comerciais Principais

A arquitetura deve suportar dois caminhos comerciais:

- Mercado Privado
- Orgao Publico

Para a demo, a recomendacao e reduzir troca de processos com dois BPFs de ponta a ponta:

- `nexer_BPF Comercial Privado`
- `nexer_BPF Comercial Governo`

O BPF privado deve evidenciar:

1. Qualificacao
2. Desenvolvimento
3. Proposta
4. Negociacao
5. Aprovacao de Desconto
6. Contrato e Assinatura
7. Fechamento

O BPF governo deve evidenciar:

1. Identificacao da Demanda
2. Qualificacao Legal
3. Proposta Tecnica
4. Proposta Comercial
5. Licitacao/Pregao
6. Adjudicacao
7. Contrato
8. Fechamento

## Componentes Da Solution

### Aplicativo

Aplicativo utilizado:

- Sales Hub nativo

Nao criar novo model-driven app nesta fase. A experiencia da demo deve ser entregue por novos formularios, BPFs, views e dashboards disponiveis dentro do Sales Hub.

### Campos Senior Prioritarios

Campos sugeridos nas tabelas padrao:

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

Choices globais sugeridos:

- Linha de Producao: HCM, ERP, Logistica, Acesso e Seguranca, CRM, GRS
- Tipo de Cliente: Privado, Governo, Canal
- Tipo de Venda: Greenfield, Base, Upgrade de Licenca
- Status de Aprovacao: Nao Solicitada, Pendente, Aprovada, Rejeitada, Escalada
- Status de Integracao: Pendente, Enviado, Processado, Erro, Simulado
- Tipo ETN: HCM, ERP, Logistica, Acesso e Seguranca, Tecnico, Comercial

### Formularios

#### Lead

Objetivo: qualificar rapido e mostrar ganho de cliques.

Header:

- Nome
- Empresa
- Status
- Score
- Origem
- Proprietario
- Proxima acao

Tabs:

- Resumo
- Qualificacao
- Campanhas
- Historico
- Senior

#### Conta

Objetivo: visao 360 em uma tela.

Header:

- Nome da conta
- CNPJ
- Segmento
- Potencial
- Status relacionamento
- Executivo owner
- Proxima acao

Tabs:

- Resumo
- Comercial
- Relacionamento
- Financeiro/Contrato
- Senior

#### Contato

Objetivo: entender papel, influencia e engajamento.

Header:

- Nome
- Cargo
- Conta
- Papel na decisao
- Influencia
- Canal preferido
- Proxima acao

Tabs:

- Resumo
- Relacionamento
- Comercial
- Consentimento
- Senior

#### Oportunidade

Objetivo: vender melhor e avancar etapa com confianca.

Header:

- Nome
- Conta
- Fase
- Valor
- Data prevista
- Probabilidade
- Proprietario
- Proxima acao

Tabs:

- Resumo
- Processo de Venda
- Produtos/Solucoes
- Stakeholders
- Historico
- Senior
- Integracoes
- Aprovacao

## Views E Dashboards

Views principais:

- Leads - Entrada
- Leads - Filtro 1
- Leads - Filtro 2
- Leads Agendados - Aguardando Feedback
- Meu Pipeline - Privado
- Pipeline - Orgao Publico
- Minhas Contas
- Acionamentos ETN
- Descontos Pendentes
- Integracoes Pendentes

Dashboards:

- Painel Smart Lead
- Painel de Pre-Vendas
- Painel Executivo - Pipeline Consolidado
- Painel de Produtividade - Vendedores
- Painel de Insights - Copilot

## Ordem Segura De Implementacao

1. Validar/criar publisher `nexer_`.
2. Criar solution unmanaged `nexer_senior_demo_crm_b`.
3. Criar choices globais e campos prioritarios.
4. Criar tabelas customizadas minimas.
5. Adicionar tabelas padrao explicitamente na solution.
6. Criar/copiar formularios de Lead, Account, Contact e Opportunity.
7. Configurar os novos formularios/BPFs para uso no Sales Hub.
8. Criar views e dashboards.
9. Criar BPFs em draft.
10. Criar flows manuais/simulados.
11. Popular dados de demo.
12. Testar roteiro privado ponta a ponta.
13. Testar roteiro governo.
14. Testar aprovacao e logs de integracao.
15. Exportar backup unmanaged.
16. Congelar versao da demo.

## Guardrails Para Deploy

Nao executar sem confirmacao explicita:

- Alterar formulario principal de usuarios existentes.
- Mudar form order global.
- Criar novo model-driven app ou sitemap customizado.
- Publicar todas as customizacoes do ambiente.
- Importar solution managed.
- Sobrescrever solution existente.
- Remover componentes.
- Alterar security roles existentes.
- Criar campos obrigatorios em tabelas padrao.
- Habilitar/desabilitar Sales Insights.
- Editar XML de formulario manualmente.

## Decisoes Pendentes

1. Confirmar se o ambiente e sandbox/pre-sales e pode receber customizacoes.
2. Confirmar se o usuario atual tem System Administrator ou System Customizer.
3. Confirmar se Sales Insights esta habilitado e quais formularios existem.
4. Confirmar se `nexer_` ja existe como publisher ou precisa ser criado.
5. Confirmar se a solution `nexer_senior_demo_crm_b` ja existe.
6. Confirmar como os novos formularios serao disponibilizados no Sales Hub: por ordem de formulario, security role ou selecao manual durante a demo.
7. Confirmar se vamos usar BPFs separados Lead/Oportunidade ou dois BPFs ponta a ponta.
8. Confirmar linhas de negocio Senior do MVP.
9. Confirmar se integracoes serao simuladas ou reais na primeira versao.
