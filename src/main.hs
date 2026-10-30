{-# OPTIONS_GHC -Wall #-}
module Main where

import Dados (campeonatoExemplo)
import Classificacao (classificacao, ateRodada, maiorGoleada, mediaGols)
import Leitura (todosOsErros, tabelaFormatada)

-- | O main deve demonstrar, em sequência:
-- 1. A tabela final
-- 2. A tabela após uma rodada intermediária
-- 3. As estatísticas da Camada 2
-- 4. O tratamento de uma entrada com erros
main :: IO ()
main = do
  putStrLn "=============================================================="
  putStrLn " 1. TABELA FINAL DO CAMPEONATO (Camadas 1 e 2)"
  putStrLn "=============================================================="
  putStrLn $ tabelaFormatada (classificacao campeonatoExemplo)

  putStrLn "\n=============================================================="
  putStrLn " 2. TABELA APOS A 3a RODADA (Uso de filter)"
  putStrLn "=============================================================="
  putStrLn $ tabelaFormatada (classificacao (ateRodada 3 campeonatoExemplo))

  putStrLn "\n=============================================================="
  putStrLn " 3. ESTATISTICAS GERAIS (Funcoes Totais)"
  putStrLn "=============================================================="
  putStrLn $ "Maior Goleada: " ++ show (maiorGoleada campeonatoExemplo)
  putStrLn $ "Media de Gols por Partida: " ++ show (mediaGols campeonatoExemplo)

  putStrLn "\n=============================================================="
  putStrLn " 4. TRATAMENTO DE ENTRADA COM ERROS (Camada 3)"
  putStrLn "=============================================================="
  let entradaComErros = unlines 
        [ "1;Coritiba;dois;1;Athletico"
        , "1;Parana;1;1;Parana"
        , "1;Londrina;-1;0;Operario"
        , "2;Maringa;0;0;Athletico;Extra"
        , "2;Coritiba;2;0;Londrina"
        , "2;Coritiba;1;0;Operario"
        ]
  
  let erros = todosOsErros entradaComErros
  mapM_ (putStrLn . ("-> Erro capturado com seguranca: " ++) . show) erros
  putStrLn "\nDemonstracao finalizada com sucesso."