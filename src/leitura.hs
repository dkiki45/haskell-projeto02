module Leitura
    ( Erro(..)
    , separar
    , lerPartida
    , lerCampeonato
    , todosOsErros
    , tabelaFormatada
    ) where

import Tipos
import Classificacao(pontosLinha, saldo, aproveitamento)
import Text.Read(readMaybe)
import Data.List(nub)

-- tipo soma com cenarios de falha na entrada
data Erro 
  = CamposInvalidos String
  | NumeroInvalido String
  | PlacarNegativo String
  | MesmoTime String
  | TimeRepetidoNaRodada Int
  deriving (Show, Eq)

-- | Quebra uma string num caractere delimitador (sem usar splitOn)
separar :: Char -> String -> [String]
separar _ "" = []
separar c s = let (palavra, resto) = break (== c) s
              in palavra : case resto of
                             [] -> []
                             (_:xs) -> separar c xs

-- | Converte linha textual para Partida usando notação do na mônada Either
lerPartida :: Int -> String -> Either Erro Partida
lerPartida _ linha = do
  let partes = separar ';' linha
  case partes of
    [rStr, mand, gMandStr, gVisStr, vis] -> do
      -- Uso do maybe como combinador para transitar de Maybe para Either
      r  <- maybe (Left $ NumeroInvalido linha) Right (readMaybe rStr)
      gm <- maybe (Left $ NumeroInvalido linha) Right (readMaybe gMandStr)
      gv <- maybe (Left $ NumeroInvalido linha) Right (readMaybe gVisStr)
      
      if gm < 0 || gv < 0 then Left (PlacarNegativo linha)
      else if mand == vis then Left (MesmoTime linha)
      else Right (Partida r mand gm gv vis)
    _ -> Left (CamposInvalidos linha)

-- | Valida a restrição de times duplicados por rodada
validarRodadas :: [Partida] -> Either Erro [Partida]
validarRodadas ps = foldl' checar (Right ps) rodadas
  where
    rodadas = nub (map rodada ps)
    checar (Left e) _ = Left e
    checar (Right pss) r = 
      let pR = filter (\p -> rodada p == r) pss
          timesR = concatMap (\p -> [mandante p, visitante p]) pR
      in if length timesR /= length (nub timesR)
         then Left (TimeRepetidoNaRodada r)
         else Right pss

-- | Verifica com segurança se uma linha de texto deve ser processada
linhaValida :: String -> Bool
linhaValida "" = False
linhaValida ('#':_) = False
linhaValida _ = True

-- | Lê o texto integral, interrompendo no primeiro erro via traverse
lerCampeonato :: String -> Either Erro [Partida]
lerCampeonato texto = do
  let linhas = filter linhaValida (lines texto)
  partidas <- traverse (\(i, l) -> lerPartida i l) (zip [(1::Int)..] linhas)
  validarRodadas partidas

-- | Relatório exaustivo de erros de um ficheiro textual
todosOsErros :: String -> [Erro]
todosOsErros texto = 
  let linhas = filter linhaValida (lines texto)
      resultados = map (\(i, l) -> lerPartida i l) (zip [(1::Int)..] linhas)
      errosLinha = [e | Left e <- resultados]
      partidasValidas = [p | Right p <- resultados]
  in case validarRodadas partidasValidas of
       Left e -> errosLinha ++ [e]
       Right _ -> errosLinha

-- | Geração visual da classificação em caracteres tabulares
tabelaFormatada :: [Linha] -> String
tabelaFormatada linhas =
  let cabecalho = "Pos | Time       | Pts | J | V | E | D | GP | GC | SG | % \n--------------------------------------------------------------"
      formatar (i, l) = 
        pad 3 (show i) ++ " | " ++ 
        pad 10 (time l) ++ " | " ++ 
        pad 3 (show $ pontosLinha l) ++ " | " ++ 
        pad 1 (show $ jogos l) ++ " | " ++ 
        pad 1 (show $ vitorias l) ++ " | " ++ 
        pad 1 (show $ empates l) ++ " | " ++ 
        pad 1 (show $ derrotas l) ++ " | " ++ 
        pad 2 (show $ golsPro l) ++ " | " ++ 
        pad 2 (show $ golsContra l) ++ " | " ++ 
        pad 2 (show $ saldo l) ++ " | " ++ 
        show (round (aproveitamento l) :: Int) ++ "%"
  in unlines (cabecalho : map formatar (zip [(1::Int)..] linhas))
  where pad n s = take n (s ++ repeat ' ')
