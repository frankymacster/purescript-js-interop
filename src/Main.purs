module Main where

import Control.Monad.State
import Data.List (List(..), drop, head, (:))
import Data.Maybe (Maybe)
import Prelude (Unit, bind, discard, pure, unit, ($))

import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, logShow)

pushState :: Int -> State (List Int) Unit
pushState x = modify (\s -> x : s)

popState :: State (List Int) (Maybe Int)
popState = do
    xs <- get
    modify $ drop 1
    pure $ head xs

manip :: State (List Int) Unit
manip = do
    pushState 4
    _ <- popState
    _ <- popState
    pure unit

main :: forall e. Eff (console :: CONSOLE | e) Unit
main = do
  logShow $ runState manip (3 : 2 : 1 : Nil)
  -- (Tuple unit (2 : 1 : Nil))