module Dados
  ( campeonatoExemplo
  ) where

import Tipos

campeonatoExemplo :: [Partida]
campeonatoExemplo =
  -- Rodada 1 
  [ Partida 1 "Coritiba"    3 2 "Athletico"
  , Partida 1 "Operario"    0 0 "Londrina"      
  , Partida 1 "Maringa"     0 2 "Parana"
  
  -- Rodada 2 
  , Partida 2 "Athletico"   3 0 "Parana"
  , Partida 2 "Londrina"    1 1 "Coritiba"
  , Partida 2 "Operario"    1 0 "Maringa"
  
  -- Rodada 3 
  , Partida 3 "Londrina"    0 2 "Athletico"
  , Partida 3 "Parana"      0 1 "Operario"
  , Partida 3 "Coritiba"    3 0 "Maringa"       
  
  -- Rodada 4 
  , Partida 4 "Athletico"   2 0 "Maringa"
  , Partida 4 "Operario"    0 2 "Coritiba"
  , Partida 4 "Parana"      0 1 "Londrina"
  
  -- Rodada 5 
  , Partida 5 "Operario"    1 1 "Athletico"
  , Partida 5 "Parana"      0 2 "Coritiba"      
  , Partida 5 "Londrina"    2 0 "Maringa"
  ]