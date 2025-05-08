# SignWriter Fácil

Aplicativo para facilitar a comunicação entre surdos e ouvintes utilizando o sistema de escrita visual SignWriting.

## Sobre o Projeto

O SignWriter Fácil é um aplicativo desenvolvido para facilitar a comunicação entre surdos e ouvintes, utilizando o sistema de escrita visual SignWriting. Este sistema, criado por Valerie Sutton em 1974, permite a representação gráfica dos movimentos das mãos, expressões faciais e posturas corporais, elementos essenciais da língua de sinais.

## Principais Funcionalidades

- **Aprender e Praticar**: Módulo educacional para aprender e praticar o sistema SignWriting.
- **Escrever Sinais**: Criar e editar sinais em SignWriting.
- **Traduzir Sinais**: Conversão entre texto e SignWriting.
- **Conversar**: Interface para comunicação utilizando SignWriting.
- **Dicionário**: Banco de dados abrangente de sinais.
- **Progresso**: Acompanhamento do aprendizado e uso.

## Recursos de Acessibilidade

O aplicativo deve incluir recursos avançados de acessibilidade para garantir uma experiência inclusiva: (ainda em implementação)

- **Tamanho da Fonte Ajustável**:
  - Controle deslizante para ajustar o tamanho do texto
  - Escala de 80% a 200% do tamanho original
  - Aplicação em tempo real em todo o aplicativo

- **Contraste Configurável**:
  - Ajuste do nível de contraste das cores
  - Escala de 50% a 200% do contraste padrão
  - Otimizado para diferentes condições de visão

- **Espaçamento Personalizado**:
  - Controle do espaçamento entre elementos
  - Escala de 80% a 200% do espaçamento padrão
  - Layout adaptativo para melhor legibilidade

- **Persistência de Configurações**:
  - Salva as preferências do usuário
  - Mantém as configurações entre sessões
  - Aplica automaticamente ao iniciar o app

## Arquitetura

O aplicativo segue a arquitetura MVVM (Model-View-ViewModel):

- **Model**: Representa os dados e a lógica de negócios.
- **View**: Define a estrutura, o layout e a aparência da interface do usuário.
- **ViewModel**: Atua como uma ponte entre o Model e a View, gerenciando a lógica de apresentação.

## Tecnologias Utilizadas

- **Flutter**: Framework de desenvolvimento multiplataforma
- **Provider**: Gerenciamento de estado para MVVM
- **SharedPreferences**: Persistência de configurações de acessibilidade
- **APIs externas**: Para funcionalidades como tradução e reconhecimento de sinais (implementação futura)

## Como Executar

1. Certifique-se de ter o Flutter instalado e configurado.
2. Clone este repositório.
3. Execute `flutter pub get` para instalar as dependências.
4. Execute `flutter run` para iniciar o aplicativo.

## Estrutura do Projeto

```
lib/
  ├── models/         # Classes de dados
  ├── viewmodels/     # Lógica de apresentação e negócio
  ├── views/
  │    ├── screens/   # Telas do aplicativo
  │    ├── widgets/   # Componentes reutilizáveis
  ├── services/       # Serviços e APIs
  ├── utils/          # Utilidades e helpers
  ├── theme/          # Configurações de tema e acessibilidade
  └── main.dart       # Ponto de entrada do aplicativo
```

## Desenvolvimento Futuro

- Implementação de banco de dados local
- Integração com APIs para reconhecimento de sinais em tempo real
- Melhorias na interface e experiência do usuário
- Adicionar suporte para múltiplos idiomas
- Expandir recursos de acessibilidade:
  - Suporte a leitores de tela
  - Mais opções de contraste
  - Temas personalizados

## Contribuições

Contribuições são bem-vindas! Sinta-se à vontade para abrir issues e pull requests.
