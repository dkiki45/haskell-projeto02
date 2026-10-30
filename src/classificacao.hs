module Classificacao
    ( pontos
    , saldo
    , pontosLinha
    , aproveitamento
    , linhaDoTime
    , classificacao
    , ateRodada
    , maiorGoleada
    , mediaGols
    ) where

import Tipos 
import Data.List(foldl', sortBy)
import Data.Ord(comparing, Down(..))

-- descricao pontuacao
pontos :: Resultado -> Int
pontos Vitoria = 3
pontos Empate  = 1
pontos Derrota = 0

-- saldo de gols
saldo :: Linha ->  Int
saldo l = golsPro l - golsContra l

-- total de pontos de uma linha na tabela
pontosLinha :: Linha -> Int
pontosLinha l = (vitorias l * 3) + empates l

-- aproveitamento dos jogos
aproveitamento :: Linha -> Double
aproveitamento l
    | jogos l == 0  = 0.0
    | otherwise     = (fromIntegral (pontosLinha l) / fromIntegral (jogos l * 3)) * 100.0

-- acumula partidas do time usando foldl'
linhaDoTime :: [Partida] -> Time -> Linha
linhaDoTime ps t = foldl' acumular linhaInicial ps
  where
    linhaInicial = Linha t 0 0 0 0 0 0
    acumular acc p
      | t == mandante p = acc
          { jogos      = jogos acc + 1
          , vitorias   = vitorias acc + if golsMandante p > golsVisitante p then 1 else 0
          , empates    = empates acc  + if golsMandante p == golsVisitante p then 1 else 0
          , derrotas   = derrotas acc + if golsMandante p < golsVisitante p then 1 else 0
          , golsPro    = golsPro acc + golsMandante p
          , golsContra = golsContra acc + golsVisitante p
          }
      | t == visitante p = acc
          { jogos      = jogos acc + 1
          , vitorias   = vitorias acc + if golsVisitante p > golsMandante p then 1 else 0
          , empates    = empates acc  + if golsVisitante p == golsMandante p then 1 else 0
          , derrotas   = derrotas acc + if golsVisitante p < golsMandante p then 1 else 0
          , golsPro    = golsPro acc + golsVisitante p
          , golsContra = golsContra acc + golsMandante p
          }
      | otherwise = acc

-- tabela de classificacao ordenada pelos criterios de desempate
classificacao :: [Partida] -> [Linha]
classificacao ps = sortBy criterioDesempate linhas
  where
    linhas = map (linhaDoTime ps) (times ps)
    criterioDesempate =
      comparing (Down . pontosLinha)
      <> comparing (Down . vitorias)
      <> comparing (Down . saldo)
      <> comparing (Down . golsPro)
      <> comparing time

-- | filtra apenas partidas realizadas até determinada rodada
ateRodada :: Int -> [Partida] -> [Partida]
ateRodada r = filter (\p -> rodada p <= r)

-- | Diferença absoluta de gols em uma partida
diferencaGols :: Partida -> Int
diferencaGols p = abs (golsMandante p - golsVisitante p)

-- | partida com a maior diferença de gols (função total com foldr)
maiorGoleada :: [Partida] -> Maybe Partida
maiorGoleada = foldr escolherMelhor Nothing
  where
    escolherMelhor p Nothing  = Just p
    escolherMelhor p (Just m)
      | diferencaGols p > diferencaGols m = Just p
      | otherwise                         = Just m

-- | media de gols por partida
mediaGols :: [Partida] -> Maybe Double
mediaGols [] = Nothing
mediaGols ps = Just (fromIntegral totalGols / fromIntegral totalPartidas)
  where
    totalPartidas = length ps
    totalGols     = foldl' (\acc p -> acc + golsMandante p + golsVisitante p) 0 ps