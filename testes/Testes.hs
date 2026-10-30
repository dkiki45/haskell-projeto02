{-# OPTIONS_GHC -Wall #-}
module Main where

import Tipos
import Dados
import Classificacao
import Leitura

-- Função auxiliar de teste
testar :: (Eq a, Show a) => String -> a -> a -> IO ()
testar nome obtido esperado
  | obtido == esperado = putStrLn ("[OK] " ++ nome)
  | otherwise          = putStrLn ("[FALHOU] " ++ nome ++ "\n  | Obtido: " ++ show obtido ++ "\n  /= Esperado: " ++ show esperado)

obterPrimeiro :: [a] -> Maybe a
obterPrimeiro [] = Nothing
obterPrimeiro (x:_) = Just x

main :: IO ()
main = do
  putStrLn "\n=== TESTES OBRIGATORIOS: CAMADA 1 ==="
  let pTeste = Partida 1 "Coritiba" 2 1 "Athletico"
  testar "resultadoPara: mandante venceu" (resultadoPara "Coritiba" pTeste) (Just Vitoria)
  testar "resultadoPara: visitante perdeu" (resultadoPara "Athletico" pTeste) (Just Derrota)
  testar "resultadoPara: time neutro (Nothing)" (resultadoPara "Parana" pTeste) Nothing

  putStrLn "\n=== TESTES OBRIGATORIOS: CAMADA 2 ==="
  testar "maiorGoleada em lista vazia -> Nothing" (maiorGoleada []) Nothing
  testar "mediaGols em lista vazia -> Nothing" (mediaGols []) Nothing
  
  testar "mediaGols campeonato (30 gols / 15 jogos = 2.0)" (mediaGols campeonatoExemplo) (Just 2.0)
  
  let tabFinal = classificacao campeonatoExemplo
  case obterPrimeiro tabFinal of
    Nothing -> putStrLn "[FALHOU] Tabela vazia"
    Just campeao -> do
      testar "Campeao da classificacao final e o Coritiba" (time campeao) "Coritiba"
      testar "Pontos do campeao Coritiba == 13" (pontosLinha campeao) 13

  let terceiro = tabFinal !! 2
      quarto   = tabFinal !! 3
  testar "Desempate por Saldo: Londrina (SG +1) a frente do Operario (SG 0) com mesmos pontos (8)"
         (pontosLinha terceiro == pontosLinha quarto, saldo terceiro > saldo quarto)
         (True, True)

  let tabR3 = classificacao (ateRodada 3 campeonatoExemplo)
  testar "Classificacao na rodada 3 difere da final" (tabR3 /= tabFinal) True

  putStrLn "\n=== TESTES OBRIGATORIOS: CAMADA 3 ==="
  let errLinha1 = "1;Coritiba;dois;1;Athletico"
  let errLinha2 = "1;Parana;1;1;Parana"
  let errLinha3 = "1;Londrina;-1;0;Operario"
  
  testar "lerPartida: Captura NumeroInvalido" (lerPartida 1 errLinha1) (Left (NumeroInvalido errLinha1))
  testar "lerPartida: Captura MesmoTime" (lerPartida 1 errLinha2) (Left (MesmoTime errLinha2))
  testar "lerPartida: Captura PlacarNegativo" (lerPartida 1 errLinha3) (Left (PlacarNegativo errLinha3))