module Main where

import Data.Ring ((+), (-))
import Data.Semigroup ((<>))
import Prelude (bind, discard, show)

import Data.Generic (class Generic)
import Control.Monad.Eff.Console (log)

import Data.Store (createStore)

type State = Int

seedState :: State
seedState = 0

data Action = Pred | Succ
derive instance genericAction :: Generic Action

update :: Action → State → State
update Pred n = n - 1
update Succ n = n + 1

main = do
  store ← createStore update seedState

  store.subscribe \n → log ("The number is " <> show n)
  -- prints "The number is 0" to the console.

  store.dispatch Succ
  -- prints "The number is 1" to the console.

  store.dispatch Pred
  -- prints "The number is 0" to the console.
