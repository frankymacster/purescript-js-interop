module Main where

import Data.Ring ((+), (-))
import Data.Generic (class Generic)
import Data.Store (createStore)


type State = Int

seedState :: State
seedState = 0


data Action = Pred | Succ
derive instance genericAction :: Generic Action

update :: Action → State → State
update Pred n = n - 1
update Succ n = n + 1


store = createStore update seedState
