# Brainstorm BMAD - Senior Demo CRM B

Data: 2026-05-25

## Norte Da Demo

A demo nao deve parecer "um CRM configurado". Ela deve parecer que o dia de trabalho da Senior ficou mais leve, mais governado e mais previsivel dentro do Sales Hub nativo.

Frase guia:

> A Senior conduz a venda de ponta a ponta com menos esforco, mais contexto e mais governanca.

## Premissas Confirmadas

- Usar Sales Hub nativo.
- Nao criar novo model-driven app.
- Usar a solution `nexer_senior_demo_crm_b`.
- Publisher/prefixo: `nexer`.
- Criar novos formularios e BPFs.
- Nao alterar formularios originais.
- Usar Sales Insights como inspiracao visual e funcional.
- Integracoes podem ser simuladas com rastreabilidade.

## Narrativa Principal

1. Marketing gera demanda.
2. Pamela/Sales Ops organiza e qualifica.
3. Executivo assume oportunidade.
4. ETN e operacao entram sem quebrar o fluxo comercial.
5. CPQ/GPS e ERP Sapiens aparecem como integracoes demonstraveis.
6. Desconto passa por governanca.
7. Diretoria acompanha pipeline, forecast e gargalos.

## MVP Recomendado

- Formularios Senior para:
  - Cliente Potencial
  - Conta
  - Contato
  - Oportunidade
- BPF de Lead Senior.
- BPF de Oportunidade Senior Privado.
- Campos minimos para:
  - Origem
  - Segmento
  - Linha de negocio
  - Produto/solucao de interesse
  - Score/prioridade
  - Status de integracao
  - Desconto solicitado
  - Status de aprovacao
- Views por persona.
- Dashboard operacional e executivo.
- Fluxo simples de aprovacao de desconto.
- Massa de dados demonstrativa.

## O Que Cortar Do MVP

- Novo app model-driven.
- Sitemap customizado.
- CPQ completo.
- Integracao real obrigatoria com ERP, assinatura, marketing ou BI externo.
- Automacao excessiva.
- IA customizada.
- Muitos campos obrigatorios.
- Muitos BPFs.
- Tour administrativo durante a demo.

## UX Dos Formularios

Ordem mental do topo de cada formulario:

1. Quem e?
2. Quanto vale?
3. Onde esta?
4. O que ameaca?
5. O que faco agora?

### Cliente Potencial

Objetivo: qualificar rapido e converter sem friccao.

Primeira dobra:

- Nome/empresa
- Origem
- Segmento
- Porte
- Potencial
- Dor principal
- Produto de interesse
- Fit Senior
- Score/prioridade
- Proxima acao

Checklist de qualificacao:

- Necessidade clara
- Orcamento
- Decisor identificado
- Prazo
- Aderencia Senior

### Conta

Objetivo: visao 360.

Bloco-chave: Radar da Conta.

- Oportunidades abertas
- Receita em negociacao
- Contratos ativos
- Pendencias criticas
- Decisores-chave
- Risco comercial
- Produtos contratados
- Espaco para expansao

### Contato

Objetivo: influencia e relacionamento, nao cadastro.

- Papel na venda
- Nivel de influencia
- Preferencia de contato
- Ultima interacao
- Sentimento/engajamento
- Canal preferido
- Proxima acao

### Oportunidade

Objetivo: vender melhor, avancar etapa e acionar operacao.

Primeira dobra:

- Nome
- Conta
- Fase
- Valor
- Probabilidade
- Data prevista
- Produto/solucao
- Margem/desconto
- Proxima acao
- Responsavel

Acoes visiveis:

- Acionar ETN
- Gerar proposta CPQ/GPS
- Solicitar aprovacao
- Registrar reuniao
- Atualizar proximo passo

## Ganho De Cliques

| Tarefa | Antes | Depois | Ganho |
|---|---:|---:|---:|
| Entender conta | 10 cliques | 3 cliques | -70% |
| Qualificar lead | 8 cliques | 2 cliques | -75% |
| Solicitar desconto | 6 acoes | 2 acoes | -67% |
| Preparar reuniao | 5 buscas | 1 resumo | -80% |

## Arquitetura Recomendada

Camadas:

- Core Sales: Lead, Account, Contact, Opportunity, Activity.
- Processo: BPFs, regras e aprovacao.
- ETN: Case relacionado a Conta/Oportunidade.
- Integracoes: CPQ/GPS, ERP Sapiens, Neoway, Customer Insights como simulacoes rastreaveis.
- Experiencia: formularios, views e dashboards no Sales Hub.

## BPFs

### Lead Senior

- Entrada
- Filtro 1
- Filtro 2
- Agendado
- Qualificado

Observacao:

- "Vendido" deve ficar preferencialmente na Oportunidade, nao no Lead, para respeitar a modelagem nativa.

### Oportunidade Senior Privado

- Qualificacao
- Desenvolvimento
- Proposta
- Negociacao
- Aprovacao de Desconto
- Contrato e Assinatura
- Fechamento

Decisao pendente:

- Aprovacao de Desconto sera etapa do BPF ou subprocesso dentro de Negociacao?

## Estrategia Tecnica

O caminho recomendado e hibrido:

- PAC para auth, solution, export, unpack, pack, import, publish e versionamento.
- Maker Portal uma vez para autoria inicial de formularios/BPFs visuais.
- Export/unpack apos autoria para tornar a solution rastreavel.
- SDK/Web API apenas onde houver ganho claro e baixo risco.

O que automatizar via PAC:

- Backup/export.
- Unpack/pack.
- Import.
- Publish.
- Versionamento.
- Web resources.
- Validacao de existencia da solution.

O que provavelmente precisa Maker Portal inicialmente:

- Clonagem/criacao dos formularios.
- Layout visual dos formularios.
- BPFs e estagios.
- Ordem de formularios no Sales Hub.
- Validacao visual da experiencia.

## Perguntas Que Precisam Ser Respondidas

1. "Vendido" fica no BPF de Lead ou apenas na Oportunidade?
2. Governo usa BPF proprio ou mesmo BPF com campo de pipeline?
3. Aprovação de desconto sera real via Power Automate Approvals ou simulada?
4. Quais integracoes serao reais e quais serao mockadas?
5. Customer Insights sera real, embedded/linkado ou simulado em campos?
6. ETN bloqueia a oportunidade ou apenas gera alerta/risco?
7. Quais campos sao obrigatorios por etapa?
8. Quais usuarios/personas serao usados na demo?
9. Havera security roles reais ou usuario unico de demo?
10. Fechamento gera Quote/Order ou apenas fecha Opportunity como Won?
11. Qual e o "momento uau" esperado pela Pamela?

## Recomendacao Do Time

Construir uma demo curta, nativa e fluida. A estrela nao e a customizacao; e a Senior percebendo que consegue operar demanda, qualificacao, venda, aprovacao e gestao comercial em um unico fluxo governado dentro do Sales Hub.

