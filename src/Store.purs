-- https://github.com/bodil/purescript-store/blob/master/src/Data/Store.purs

module Data.Store
  ( createStore
  , Store
  , STORE
  ) where

import Prelude

import Control.Monad.Eff (Eff, kind Effect)
import Control.Monad.Eff.Ref (Ref, readRef, newRef, writeRef, modifyRef)
import Control.Monad.Eff.Ref.Unsafe (unsafeRunRef)
import Control.Monad.Eff.Unsafe (unsafeCoerceEff)
import Data.Generic (class Generic)
import Data.List (List(Cons, Nil))
import Data.Traversable (traverse_)

foreign import data STORE :: Effect

type Store e a s =
  { subscribe :: (s → Eff e Unit) → Eff (store :: STORE | e) Unit
  , dispatch :: a → Eff (store :: STORE | e) Unit
  }

type Store' e a s =
  { state :: Ref s
  , subscribers :: Ref (List (s → Eff e Unit))
  , update :: a → s → s
  , seed :: s
  }

subscribe :: ∀ e a s. Store' e a s → (s → Eff e Unit) → Eff (store :: STORE | e) Unit
subscribe store sub = unsafeRunRef do
  modifyRef store.subscribers (Cons sub)
  state' ← readRef store.state
  unsafeCoerceEff $ sub state'

setState :: ∀ e a s. Store' e a s → s → Eff (store :: STORE | e) Unit
setState store state' = unsafeRunRef do
  writeRef store.state state'
  subs ← readRef store.subscribers
  traverse_ (\sub → unsafeCoerceEff $ sub state') subs

dispatch :: ∀ e a s. Store' e a s → a → Eff (store :: STORE | e) Unit
dispatch store action = unsafeRunRef do
  state ← readRef store.state
  let state' = store.update action state
  unsafeCoerceEff $ setState store state'

createStore' :: ∀ e s a. Generic a ⇒ Generic s ⇒ (a → s → s) → s → Eff (store :: STORE | e) (Store' e a s)
createStore' update seed = unsafeRunRef do
  state ← newRef seed
  subscribers ← newRef (Nil :: List (s → Eff e Unit))
  let store = { state, subscribers, update, seed }
  pure store

createStore :: ∀ e s a. Generic a ⇒ Generic s ⇒ (a → s → s) → s → Eff (store :: STORE | e) (Store e a s)
createStore update seed = do
  store ← createStore' update seed
  pure { subscribe: subscribe store, dispatch: dispatch store }