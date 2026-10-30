# Decisões de Modelagem e Limitações - PjBL2

Este documento justifica as escolhas técnicas adotadas durante o desenvolvimento das três camadas do projeto de classificação do campeonato em Haskell, enfatizando a robustez, a tipagem estrita e o uso de funções totais.

## 1. Camada 1: Tipos e Modelagem de Dados
- **Record Syntax para `Partida` e `Linha`**: Evitou-se o uso de tuplas genéricas. Tuplas deixam margem para erros silenciosos (ex: inverter os gols do mandante e do visitante). Os records garantem acesso seguro e legível aos dados.
- **Tipo Soma `Resultado`**: O uso de `data Resultado = Vitoria | Empate | Derrota` fecha o domínio de valores possíveis, impedindo a injeção de strings ou inteiros mágicos. O compilador garante a exaustão de padrões com `-Wall`.
- **Totalidade em `resultadoPara`**: Ao invés de lançar uma exceção (função parcial) quando o clube não jogou a partida solicitada, adotou-se o tipo de retorno `Maybe Resultado`, forçando o consumidor da função a tratar o caso `Nothing`.
- **Campeonato Fechado**: Modelado em turno único estrito com 6 clubes (15 jogos únicos, sem duplicidade na rodada, média matemática precisa de 2.0 gols/partida), assegurando empate por pontos validado por Saldo de Gols.

## 2. Camada 2: Ordem Superior e Ausência de Recursão
- **Zero Recursão Explícita**: Todo o processamento foi delegado a funções de alta ordem do `Prelude`:
  - `map`: Conversão de uma lista de nomes em estatísticas tabulares.
  - `filter`: Secionamento do campeonato na função `ateRodada`.
  - `foldl'`: Dobra estrita à esquerda para acumulação otimizada e livre de vazamento de memória (thunks) durante o cálculo dos pontos e gols (`linhaDoTime` e `mediaGols`).
  - `foldr`: Varredura segura na busca pela `maiorGoleada`.
- **Funções Totais Seguras**: Funções parciais que causam travamentos (`head`, `maximum`, `foldr1`) foram abolidas. Requisições em listas vazias (`[]`) retornam `Nothing` de forma limpa.
- **Ordenação via Monoid**: O desempate multicritério foi construído combinando `comparing` com o operador monoidal `<>` de `Ordering`. Essa estrutura avalia os critérios em cascata (Pontos > Vitórias > Saldo > Gols Pró > Ordem Alfabética) em uma única varredura.

## 3. Camada 3: Parsing, Monadas e Tratamento de Erros
- **Abolição de `read` e `getLine`**: Para evitar exceções de *"Prelude.read: no parse"* e o erro de *"hGetLine: end of file"* em ambientes não-interativos, utilizou-se `readMaybe` aliado à injeção pura de Strings na arquitetura, separando estritamente I/O de lógicas puras.
- **Either e Notação `do`**: A validação das linhas foi encapsulada na mônada `Either Erro Partida`. A notação `do` foi usada para evitar escadas infinitas de `case` e `pattern matching`. O combinador `maybe (Left ...) Right` fez a transição idiomática do Funtor `Maybe` para a Mônada `Either`.
- **Agregação Monádica (`traverse`)**: O processamento sequencial de linhas textuais valeu-se de `traverse`, abortando e empacotando o circuito assim que o primeiro erro de digitação fosse identificado, preservando a coerência do compilador.
- **Limitações Conhecidas**: Para manter a restrição de domínio imposta pela disciplina, a validação de *"mesmo time jogando duas vezes na mesma rodada"* consolida o erro unificado `TimeRepetidoNaRodada Int`, não especificando visualmente *qual* clube causou a sobreposição no print terminal, apenas indicando a rodada violada para correção manual nos dados.