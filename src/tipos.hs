module Tipos
    ( Time
    , Resultado(..)
    , Partida(..)
    , Linha(..)
    , participou
    , resultadoPara
    , times
    ) where 

import Data.List(nub, sort)

-- identificao string do time
type Time = String

-- tipos de resultados
data Resultado = Vitoria | Empate | Derrota
    deriving(Show, Eq)

-- sintaxe da partida 
data Partida = Partida
    { rodada :: Int
    , mandante :: Time
    , golsMandante :: Int
    , golsVisitante :: Int
    , visitante :: Time
    } deriving(Show, Eq)

-- estasticas da tabela classificacao
data Linha = Linha
    { time :: Time
    , jogos :: Int
    , vitorias :: Int
    , empates :: Int
    , derrotas :: Int
    , golsPro :: Int
    , golsContra :: Int
    } deriving(Show, Eq)

-- verifica se o time participou da partida (como mandante ou visitante)
participou :: Time -> Partida -> Bool
participou t p = t == mandante p || t == visitante p

-- Retorna o resultado da partida sob a perpectiva do time consultado
-- Retorna nothing caso o time nao tenha participado da partida 
resultadoPara :: Time -> Partida -> Maybe Resultado
resultadoPara t p 
    | t == mandante p = Just $ case compare (golsMandante p) (golsVisitante p) of
                                    GT -> Vitoria
                                    EQ -> Empate
                                    LT -> Derrota
    | t == visitante p = Just $ case compare (golsMandante p) (golsVisitante p) of
                                    GT -> Vitoria
                                    EQ -> Empate
                                    LT -> Derrota
    | otherwise         = Nothing

-- retorna todos os times que disputaram pelo menos uma partida sem repetir e em ordem alfabetica
times :: [Partida] -> [Time]
times ps = sort . nub $ concatMap (\p -> [mandante p, visitante p]) ps