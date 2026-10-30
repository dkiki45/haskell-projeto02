module Dados
  ( campeonatoExemplo
  ) where

import Tipos

campeonatoExemplo :: [Partida]
campeonatoExemplo =
  -- Rodada 1
  [ Partida 1 "Coritiba"    2 1 "Athletico"
  , Partida 1 "Operario"    0 0 "Londrina"     
  , Partida 1 "Maringa"     1 2 "Parana"
  
  -- Rodada 2
  , Partida 2 "Athletico"   3 1 "Operario"
  , Partida 2 "Londrina"    1 1 "Coritiba"
  , Partida 2 "Parana"      0 1 "Maringa"
  
  -- Rodada 3
  , Partida 3 "Coritiba"    3 1 "Operario"
  , Partida 3 "Londrina"    0 2 "Athletico"
  , Partida 3 "Maringa"     2 0 "Parana"
  
  -- Rodada 4
  , Partida 4 "Coritiba"    4 0 "Maringa"       
  , Partida 4 "Operario"    2 0 "Parana"
  , Partida 4 "Athletico"   2 0 "Londrina"
  
  -- Rodada 5
  , Partida 5 "Athletico"   1 1 "Coritiba"      
  , Partida 5 "Londrina"    3 1 "Maringa"
  , Partida 5 "Operario"    2 1 "Parana"
  ]