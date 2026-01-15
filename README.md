# ✍️ SignWriter Fácil

**Facilitando a comunicação entre surdos e ouvintes com o sistema visual SignWriting.**

---

## 📌 Sobre o Projeto

O **SignWriter Fácil** é um aplicativo voltado para aproximar surdos e ouvintes por meio do sistema de escrita visual **SignWriting**. Criado por Valerie Sutton em 1974, o SignWriting permite representar graficamente os movimentos das mãos, expressões faciais e posturas corporais — elementos fundamentais da **língua de sinais**.

---

## 🚀 Funcionalidades Principais

- 📘 **Aprender e Praticar**  
  Módulo educacional interativo para dominar o SignWriting.

- ✍️ **Escrever Sinais**  
  Ferramenta para criar e editar sinais manualmente.

- 🔁 **Traduzir Sinais**  
  Conversão entre texto e escrita em SignWriting (em desenvolvimento).

- 💬 **Conversar**  
  Interface de comunicação utilizando SignWriting em tempo real.

- 📚 **Dicionário de Sinais**  
  Banco de dados abrangente e pesquisável.

- 📊 **Progresso do Usuário**  
  Acompanhamento personalizado do aprendizado e uso do app.

---

## ♿ Recursos de Acessibilidade (Em Desenvolvimento)

O aplicativo foca em **inclusão total**, com diversas opções de personalização:

- 🔠 **Tamanho da Fonte Ajustável**  
  Controle deslizante (80% – 200%) com aplicação instantânea em toda a interface.

- 🎨 **Contraste Configurável**  
  Escala personalizável (50% – 200%) para diferentes necessidades visuais.

- 📐 **Espaçamento Personalizado**  
  Ajustes de layout para melhor legibilidade (80% – 200%).

- 💾 **Persistência de Configurações**  
  Preferências do usuário salvas localmente e aplicadas automaticamente.

---

## 🧠 Arquitetura

Utilizamos a arquitetura **MVVM (Model-View-ViewModel)** para garantir modularidade, testabilidade e escalabilidade:

- 🧩 **Model** — Dados e lógica de negócio  
- 🖼️ **View** — Interface e layout  
- 🔄 **ViewModel** — Conector entre View e Model com lógica de apresentação

---

## 🛠️ Tecnologias Utilizadas

| Tecnologia         | Descrição                                      |
|--------------------|-----------------------------------------------|
| **Flutter**        | Framework multiplataforma                     |
| **Provider**       | Gerenciamento de estado (padrão MVVM)         |
| **SharedPreferences** | Persistência local de configurações       |
| **APIs Externas**  | Tradução e reconhecimento de sinais (futuro)  |

---

## 📂 Estrutura do Projeto

```
lib/
├── models/         # Classes de dados
├── viewmodels/     # Lógica de apresentação e negócios
├── views/
│   ├── screens/    # Telas do app
│   └── widgets/    # Componentes reutilizáveis
├── services/       # Conexões com APIs e serviços
├── utils/          # Helpers e funções utilitárias
├── theme/          # Temas e acessibilidade
└── main.dart       # Ponto de entrada
```

---

## 🧪 Como Executar

1. Certifique-se de ter o **Flutter** instalado.
2. Clone este repositório:  
   `git clone https://github.com/LhuanyMotta/SignWriter-Easy-App`
3. Instale as dependências:  
   `flutter pub get`
4. Configure o Supabase (obrigatório para autenticação):
   - Crie um projeto no Supabase e execute o SQL de criação da tabela `profiles` descrito em `BACKEND_SUPABASE.md`.
   - Copie a URL do projeto e a chave anônima.
5. Execute o aplicativo com as variáveis do Supabase:
   ```bash
   flutter run \
     --dart-define=SUPABASE_URL=YOUR_SUPABASE_URL \
     --dart-define=SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
   ```

---

## 🔮 Desenvolvimento Futuro

- 📦 Banco de dados local (offline-first)
- 📡 Reconhecimento de sinais em tempo real via câmera
- 🌐 Suporte multilíngue
- 🌈 Temas personalizados com mais contrastes
- 🔊 Compatibilidade com leitores de tela

---

## 🤝 Contribuições

Contribuições são **muito bem-vindas**!

---

## 👨‍💻 Desenvolvedores

- [Bruno Santos](https://github.com/Br2n0)
- [Lhuany Motta](https://github.com/LhuanyMotta)

---

## 📝 Licença

Este projeto está licenciado sob a **MIT License**.
