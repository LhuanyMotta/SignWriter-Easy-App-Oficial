import pandas as pd

CSV_PATH = "mapeamento_dicionario.csv"

def definir_categoria(title, image_name):
    texto = str(title).lower()

    numero = int(
        ''.join(filter(str.isdigit, image_name)) or 0
    )

    if any(p in texto for p in [
        "comunicação", "email", "e-mail", "videoconferência",
        "rede", "resposta", "acessibilidade", "tempo", "local"
    ]):
        return "Comunicação"

    if any(p in texto for p in [
        "automação", "automatizar", "processo", "sistema",
        "empresa", "cliente", "rotina", "erro", "estratégia"
    ]):
        return "Automação de Processos"

    if any(p in texto for p in [
        "dados", "análise", "analisar", "armazenar",
        "comportamento", "informações", "estratégia negócio"
    ]):
        return "Análise de Dados"

    if any(p in texto for p in [
        "segurança", "informação", "hacker", "proteção",
        "cliente confiar", "acesso"
    ]):
        return "Segurança da Informação"

    if any(p in texto for p in [
        "educação", "capacitação", "aprender", "ensinar",
        "plataforma", "conhecimento", "habilidade"
    ]):
        return "Educação e Capacitação"

    if any(p in texto for p in [
        "inovação", "desenvolvimento", "tecnológico",
        "inteligência artificial", "internet", "nuvem",
        "qualidade de vida"
    ]):
        return "Inovação Tecnológica"

    if numero <= 40:
        return "Introdução à TI"
    elif numero <= 75:
        return "Importância da TI"
    elif numero <= 105:
        return "Comunicação"
    elif numero <= 135:
        return "Automação de Processos"
    elif numero <= 160:
        return "Análise de Dados"
    elif numero <= 180:
        return "Segurança da Informação"
    elif numero <= 200:
        return "Educação e Capacitação"
    else:
        return "Inovação Tecnológica"


df = pd.read_csv(CSV_PATH)

df["category"] = df.apply(
    lambda row: definir_categoria(row.get("title", ""), row.get("image_name", "")),
    axis=1
)

df.to_csv(CSV_PATH, index=False, encoding="utf-8-sig")

print("✅ Categorias atualizadas no mapeamento_dicionario.csv")