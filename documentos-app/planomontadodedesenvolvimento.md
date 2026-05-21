Plano de desenvolvimento (MVP) — SignWriter Fácil
Objetivo do MVP

Entregar um app que permita:

Biblioteca de sinais reais (inclusive os de TI do seu material)

Criar/editar sinais no editor (canvas) com arrastar/zoom/rotacionar

Criar textos (sequência de sinais) e salvar

Busca simples por nome/categoria

Funcionar offline com banco local (SQLite já existe)

Acessibilidade básica (o que você já fez)

ETAPA 0 — Alinhamento de escopo (1 sessão)

Baseado no seu status atual:

Você está forte em Arquitetura (90%) e UI/Navegação (85%)

Fraco no “core”: Editor + Conteúdo real + Banco populado

✅ Decisão do MVP:

Conversão texto→sinais vira “modo simples”: mapeamento por palavras-chave/tokens para sinais existentes (sem ML).

Criação/edição de sinais será via editor de símbolos/figuras (não desenho com IA).

Banco real será abastecido com seus sinais em assets + metadados.

ETAPA 1 — Conteúdo real (bloqueador #1) (2–4 dias)

Meta: ter sinais reais no app.

1.1 Extrair e organizar sinais do seu material

Converter páginas do material em imagens

Recortar cada sinal em PNG

Nomear padrão: ti_001.png, ti_002.png, etc.

Estrutura:

assets/signs/ti/

assets/signs/geral/ (se tiver)

assets/signs/favoritos/ (opcional)

1.2 Criar catálogo local (JSON ou lista fixa)

Crie um arquivo assets/signs_catalog.json com:

id

name (nome do sinal)

category

tags (palavras para busca)

assetPath

✅ Resultado: você tem um “SignBank próprio” local (simples, mas real).

Entrega da Etapa 1:

Biblioteca já mostra cards com sinais reais

Busca por nome/tags funciona (mesmo simples)

ETAPA 2 — Banco local populado (bloqueador #2) (1–3 dias)

Você já tem SQLite e modelos (20%). Agora falta popular e usar de verdade.

2.1 Implementar importação inicial (seed)

Na primeira execução:

ler o signs_catalog.json

inserir no SQLite se a tabela estiver vazia

2.2 CRUD mínimo de sinais

Listar sinais (por categoria)

Detalhes do sinal

Favoritar (opcional)

Editar metadados (nome/tags) — opcional (não precisa agora)

✅ Busca simples:

LIKE no nome/tags

filtro por categoria

Entrega da Etapa 2:

Banco local cheio de sinais reais

Tela “Banco de Sinais” deixa de ser vazia

ETAPA 3 — Editor de criação/edição de sinais (core do app) (3–7 dias)

Seu status aqui era 15% (estrutura). Agora vira funcional.

3.1 Modelo “PlacedSymbol”

Cada item no canvas precisa de:

id (uuid)

assetPath

x, y

scale

rotation

zIndex (opcional)

3.2 Canvas funcional

Tela de editor:

botão Adicionar (abre biblioteca/modal de sinais)

ao escolher um sinal → adiciona no canvas

gestos no item:

arrastar

zoom (pinch)

rotacionar

excluir

botão Salvar Sinal Montado

✅ Como salvar:

salvar uma entidade “SignComposition”

name

lista de PlacedSymbol (serializada em JSON no SQLite)

thumbnail (opcional)

Thumbnail pode ficar para depois. MVP salva só o “projeto” e renderiza quando abrir.

3.3 Editar sinal montado

abrir composição

permitir modificar e salvar de novo

Entrega da Etapa 3:

Você realmente “cria SignWriting” dentro do app (via composição)

Isso vira o diferencial principal do projeto

ETAPA 4 — Textos em SignWriting (sequência) (2–4 dias)

Você já tem tela/estrutura (20%). Agora completa.

4.1 Modelo “TextDoc”

id

title

signCompositionIds[] (lista ordenada)

createdAt

4.2 Criar texto

selecionar composições salvas

ordenar (arrastar pra reorganizar — opcional)

salvar

4.3 Visualizar texto

renderizar lista/coluna dos sinais montados (cada um é uma composição)

opção “modo leitura”

Entrega da Etapa 4:

App faz “documentos” em SignWriting

Funciona offline e é demonstrável

ETAPA 5 — Conversão texto→sinais (versão simples, realista) (1–3 dias)

Seu status era 25% (simulado). Agora vira “funcional básico” sem ML.

5.1 Implementar “mapeamento por palavras”

usuário digita uma frase

você quebra em tokens (palavras)

tenta encontrar sinais no banco por:

nome

tags

retorna uma sequência sugerida

Exemplo:

“computador” → sinal computador

“internet” → sinal internet
Se não encontrar:

mostrar “não encontrado” e sugerir busca manual

✅ Isso é o suficiente para dizer que há uma conversão básica.

Entrega da Etapa 5:

A tela deixa de ser simulação e vira “conversor simples”

ETAPA 6 — Ajustes finais + qualidade (2–4 dias)

Baseado no que você já tem:

6.1 Acessibilidade (você já tem ~60%)

garantir que todas as telas respeitem fonte/contraste/espaçamento

labels/semantics básicos nos botões principais

6.2 Revisão geral

remover telas “fake”/botões que não fazem nada

mensagens de erro claras

loading states

6.3 Teste de apresentação

roteiro de demo:

abrir app

buscar sinal de TI

criar sinal montado no editor

salvar

criar texto com 3 sinais

usar conversão texto→sequência (modo simples)

Ordem de prioridade (curto e certeiro)

Conteúdo real (assets + catálogo)

Banco populado (seed + listagem + busca)

Editor (canvas) funcionando + salvar composição

Textos (sequência de composições) + salvar

Conversão simples texto→sinais (mapeamento)

Polimento e demo

Resultado esperado

Com esse plano, você elimina os “gaps core” sem entrar em coisas avançadas e sai com um app:

real, offline, útil

com sinais de TI implementados

com editor e textos funcionando

com conversão simples (sem prometer IA)