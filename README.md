# PjBL2 - Tabela de Classificação (Haskell)

Projeto focado em programação funcional livre de recursão explícita, uso de funções totais (sem exceções em tempo de execução) e validação de texto via mônadas (Either).

**Estrutura principal:**
* **`src/Main.hs`**: Executa a demonstração visual da tabela, estatísticas e tratamento de erros.
* **`tests/Testes.hs`**: Bateria de testes automatizados cobrindo as três camadas.
* **`docs/decisoes.md`**: Justificativas arquiteturais e de modelagem.

**Execução:**
Código compatível e livre de avisos (`-Wall`) tanto no GHC local via terminal quanto no `play.haskell.org`.