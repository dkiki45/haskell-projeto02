{-# OPTIONS_GHC -Wall #-}
module Main where

import Data.List (nub, sort, sortBy)
import Data.Ord (comparing, Down(..))
import Text.Read (readMaybe)

-- ==========================================
-- CAMADA 1: TIPOS E CONSULTAS BÁSICAS
-- ==========================================
type Time = String

data Resultado = Vitoria | Empate | Derrota deriving (Show, Eq)

data Partida = Partida
  { rodada        :: Int
  , mandante      :: Time
  , golsMandante  :: Int
  , golsVisitante :: Int
  , visitante     :: Time
  } deriving (Show, Eq)

data Linha = Linha
  { time        :: Time
  , jogos       :: Int
  , vitorias    :: Int
  , empates     :: Int
  , derrotas    :: Int
  , golsPro     :: Int
  , golsContra  :: Int
  } deriving (Show, Eq)

participou :: Time -> Partida -> Bool
participou t p = t == mandante p || t == visitante p

resultadoPara :: Time -> Partida -> Maybe Resultado
resultadoPara t p
  | t == mandante p = Just $ case compare (golsMandante p) (golsVisitante p) of
                               GT -> Vitoria
                               EQ -> Empate
                               LT -> Derrota
  | t == visitante p = Just $ case compare (golsVisitante p) (golsMandante p) of
                               GT -> Vitoria
                               EQ -> Empate
                               LT -> Derrota
  | otherwise        = Nothing

times :: [Partida] -> [Time]
times ps = sort . nub $ concatMap (\p -> [mandante p, visitante p]) ps


-- ==========================================
-- DADOS DO CAMPEONATO DE TESTE
-- ==========================================
campeonatoExemplo :: [Partida]
campeonatoExemplo =
  [ Partida 1 "Coritiba"    3 2 "Athletico"
  , Partida 1 "Operario"    0 0 "Londrina"      
  , Partida 1 "Maringa"     0 2 "Parana"
  , Partida 2 "Athletico"   3 0 "Parana"
  , Partida 2 "Londrina"    1 1 "Coritiba"
  , Partida 2 "Operario"    1 0 "Maringa"
  , Partida 3 "Londrina"    0 2 "Athletico"
  , Partida 3 "Parana"      0 1 "Operario"
  , Partida 3 "Coritiba"    3 0 "Maringa"       
  , Partida 4 "Athletico"   2 0 "Maringa"
  , Partida 4 "Operario"    0 2 "Coritiba"
  , Partida 4 "Parana"      0 1 "Londrina"
  , Partida 5 "Operario"    1 1 "Athletico"
  , Partida 5 "Parana"      0 2 "Coritiba"      
  , Partida 5 "Londrina"    2 0 "Maringa"
  ]


-- ==========================================
-- CAMADA 2: CLASSIFICAÇÃO E ORDEM SUPERIOR
-- ==========================================
pontos :: Resultado -> Int
pontos Vitoria = 3
pontos Empate  = 1
pontos Derrota = 0

saldo :: Linha -> Int
saldo l = golsPro l - golsContra l

pontosLinha :: Linha -> Int
pontosLinha l = (vitorias l * 3) + empates l

aproveitamento :: Linha -> Double
aproveitamento l
  | jogos l == 0 = 0.0
  | otherwise    = (fromIntegral (pontosLinha l) / fromIntegral (jogos l * 3)) * 100.0

linhaDoTime :: [Partida] -> Time -> Linha
linhaDoTime ps t = foldl' acumular linhaInicial ps
  where
    linhaInicial = Linha t 0 0 0 0 0 0
    acumular acc p
      | t == mandante p = acc
          { jogos = jogos acc + 1, vitorias = vitorias acc + (if golsMandante p > golsVisitante p then 1 else 0)
          , empates = empates acc + (if golsMandante p == golsVisitante p then 1 else 0), derrotas = derrotas acc + (if golsMandante p < golsVisitante p then 1 else 0)
          , golsPro = golsPro acc + golsMandante p, golsContra = golsContra acc + golsVisitante p }
      | t == visitante p = acc
          { jogos = jogos acc + 1, vitorias = vitorias acc + (if golsVisitante p > golsMandante p then 1 else 0)
          , empates = empates acc + (if golsVisitante p == golsMandante p then 1 else 0), derrotas = derrotas acc + (if golsVisitante p < golsMandante p then 1 else 0)
          , golsPro = golsPro acc + golsVisitante p, golsContra = golsContra acc + golsMandante p }
      | otherwise = acc

classificacao :: [Partida] -> [Linha]
classificacao ps = sortBy criterioDesempate (map (linhaDoTime ps) (times ps))
  where criterioDesempate = comparing (Down . pontosLinha) <> comparing (Down . vitorias) <> comparing (Down . saldo) <> comparing (Down . golsPro) <> comparing time

ateRodada :: Int -> [Partida] -> [Partida]
ateRodada r = filter (\p -> rodada p <= r)

diferencaGols :: Partida -> Int
diferencaGols p = abs (golsMandante p - golsVisitante p)

maiorGoleada :: [Partida] -> Maybe Partida
maiorGoleada = foldr escolherMelhor Nothing
  where
    escolherMelhor p Nothing  = Just p
    escolherMelhor p (Just m)
      | diferencaGols p > diferencaGols m = Just p
      | otherwise                         = Just m

mediaGols :: [Partida] -> Maybe Double
mediaGols [] = Nothing
mediaGols ps = Just (fromIntegral totalGols / fromIntegral totalPartidas)
  where
    totalPartidas = length ps
    totalGols     = foldl' (\acc p -> acc + golsMandante p + golsVisitante p) 0 ps


-- ==========================================
-- CAMADA 3: LEITURA E VALIDAÇÃO
-- ==========================================
data Erro 
  = CamposInvalidos String
  | NumeroInvalido String
  | PlacarNegativo String
  | MesmoTime String
  | TimeRepetidoNaRodada Int
  deriving (Show, Eq)

separar :: Char -> String -> [String]
separar _ "" = []
separar c s = let (palavra, resto) = break (== c) s
              in palavra : case resto of
                             [] -> []
                             (_:xs) -> separar c xs

lerPartida :: Int -> String -> Either Erro Partida
lerPartida _ linha = do
  let partes = separar ';' linha
  case partes of
    [rStr, mand, gMandStr, gVisStr, vis] -> do
      r  <- maybe (Left $ NumeroInvalido linha) Right (readMaybe rStr)
      gm <- maybe (Left $ NumeroInvalido linha) Right (readMaybe gMandStr)
      gv <- maybe (Left $ NumeroInvalido linha) Right (readMaybe gVisStr)
      
      if gm < 0 || gv < 0 then Left (PlacarNegativo linha)
      else if mand == vis then Left (MesmoTime linha)
      else Right (Partida r mand gm gv vis)
    _ -> Left (CamposInvalidos linha)

validarRodadas :: [Partida] -> Either Erro [Partida]
validarRodadas ps = foldl' checar (Right ps) rodadas
  where
    rodadas = nub (map rodada ps)
    checar (Left e) _ = Left e
    checar (Right pss) r = 
      let pR = filter (\p -> rodada p == r) pss
          timesR = concatMap (\p -> [mandante p, visitante p]) pR
      in if length timesR /= length (nub timesR) then Left (TimeRepetidoNaRodada r) else Right pss

-- Função segura com pattern matching para verificar se a linha é válida
linhaValida :: String -> Bool
linhaValida "" = False
linhaValida ('#':_) = False
linhaValida _ = True

lerCampeonato :: String -> Either Erro [Partida]
lerCampeonato texto = do
  let linhas = filter linhaValida (lines texto)
  partidas <- traverse (\(i, l) -> lerPartida i l) (zip [(1::Int)..] linhas)
  validarRodadas partidas

todosOsErros :: String -> [Erro]
todosOsErros texto = 
  let linhas = filter linhaValida (lines texto)
      resultados = map (\(i, l) -> lerPartida i l) (zip [(1::Int)..] linhas)
      errosLinha = [e | Left e <- resultados]
  in case validarRodadas [p | Right p <- resultados] of
       Left e -> errosLinha ++ [e]
       Right _ -> errosLinha

tabelaFormatada :: [Linha] -> String
tabelaFormatada linhas =
  let cabecalho = "Pos | Time       | Pts | J | V | E | D | GP | GC | SG | % \n--------------------------------------------------------------"
      formatar (i, l) = 
        pad 3 (show i) ++ " | " ++ pad 10 (time l) ++ " | " ++ pad 3 (show $ pontosLinha l) ++ " | " ++ 
        pad 1 (show $ jogos l) ++ " | " ++ pad 1 (show $ vitorias l) ++ " | " ++ pad 1 (show $ empates l) ++ " | " ++ 
        pad 1 (show $ derrotas l) ++ " | " ++ pad 2 (show $ golsPro l) ++ " | " ++ pad 2 (show $ golsContra l) ++ " | " ++ 
        pad 2 (show $ saldo l) ++ " | " ++ show (round (aproveitamento l) :: Int) ++ "%"
  in unlines (cabecalho : map formatar (zip [(1::Int)..] linhas))
  where pad n s = take n (s ++ repeat ' ')


-- ==========================================
-- DADOS EMBUTIDOS PARA TESTE DA CAMADA 3
-- ==========================================
dadosValidos :: String
dadosValidos = unlines 
  [ "# rodada; mandante; gols mandante; gols visitante; visitante"
  , "1;Coritiba;3;2;Athletico"
  , "1;Operario;0;0;Londrina"
  , "1;Maringa;0;2;Parana"
  , "2;Athletico;3;0;Parana"
  , "2;Londrina;1;1;Coritiba"
  , "2;Operario;1;0;Maringa"
  , "3;Londrina;0;2;Athletico"
  , "3;Parana;0;1;Operario"
  , "3;Coritiba;3;0;Maringa"
  , "4;Athletico;2;0;Maringa"
  , "4;Operario;0;2;Coritiba"
  , "4;Parana;0;1;Londrina"
  , "5;Operario;1;1;Athletico"
  , "5;Parana;0;2;Coritiba"
  , "5;Londrina;2;0;Maringa"
  ]

dadosComErros :: String
dadosComErros = unlines
  [ "1;Coritiba;dois;1;Athletico"
  , "1;Parana;1;1;Parana"
  , "1;Londrina;-1;0;Operario"
  , "2;Maringa;0;0;Athletico;Extra"
  , "2;Coritiba;2;0;Londrina"
  , "2;Coritiba;1;0;Operario"
  ]


-- ==========================================
-- EXECUÇÃO PRINCIPAL E BATERIA DE TESTES
-- ==========================================
testar :: (Eq a, Show a) => String -> a -> a -> IO ()
testar nome obtido esperado
  | obtido == esperado = putStrLn ("[OK] " ++ nome)
  | otherwise          = putStrLn ("[FALHOU] " ++ nome ++ "\n  | Obtido: " ++ show obtido ++ "\n  /= Esperado: " ++ show esperado)

obterPrimeiro :: [a] -> Maybe a
obterPrimeiro []    = Nothing
obterPrimeiro (x:_) = Just x

main :: IO ()
main = do
  putStrLn "=============================================================="
  putStrLn " 1. TABELA FINAL DO CAMPEONATO (Camadas 1 e 2)"
  putStrLn "=============================================================="
  case lerCampeonato dadosValidos of
    Left erro -> putStrLn $ "Erro fatal: " ++ show erro
    Right partidas -> putStrLn $ tabelaFormatada (classificacao partidas)

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
  let erros = todosOsErros dadosComErros
  mapM_ (putStrLn . ("-> Erro capturado com seguranca: " ++) . show) erros

  putStrLn "\n=============================================================="
  putStrLn " 5. BATERIA DE TESTES AUTOMATIZADOS"
  putStrLn "=============================================================="
  testar "maiorGoleada em lista vazia -> Nothing" (maiorGoleada []) Nothing
  testar "mediaGols em lista vazia -> Nothing" (mediaGols []) Nothing
  
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
         
  putStrLn "\nDemonstracao finalizada com sucesso."