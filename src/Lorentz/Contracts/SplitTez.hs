{-# LANGUAGE RebindableSyntax #-}

{-# OPTIONS -Wno-missing-export-lists #-}
{-# OPTIONS -Wno-orphans #-}
{-# OPTIONS -Wno-unused-do-bind #-}

module Lorentz.Contracts.SplitTez where

-- import Data.Bool
-- import Data.Function
import Data.Maybe
import System.IO
import Text.Show
import Text.Read (read)
import GHC.Enum

-- import Michelson.Text
import Tezos.Crypto.Orphans ()
import Lorentz
import Lorentz.Entrypoints ()

import qualified Data.Text.Lazy.IO as TL
import qualified Data.Text.Lazy.IO.Utf8 as Utf8

type ToFlush = Natural

type User = Address
type UserShares = Natural
type UserFlushed = Natural
type NewUserFlushed = Natural
type TotalShares = Natural
type TotalBalance = Natural
type AccessibleMutez = Natural
type UserAccessibleMutez = Natural
type Ledger = BigMap User (UserShares, UserFlushed)

data Storage = Storage
  { totalBalance :: TotalBalance
  , ledger :: Ledger
  -- , totalShares :: TotalShares
  -- , delegateAdmin :: Address
  }
  deriving stock Generic
  deriving stock Show
  deriving anyclass IsoValue

unStorage :: Storage & s :-> (TotalBalance, Ledger) & s
unStorage = forcedCoerce_

toStorage :: (TotalBalance, Ledger) & s :-> Storage & s
toStorage = forcedCoerce_

data SplitParam
  = Default
  | Flush [(ToFlush, User)]
  deriving stock Generic
  deriving stock Show
  deriving anyclass IsoValue

data Parameter
  = SetDelegate (Maybe KeyHash)
  | Split SplitParam
  deriving stock Generic
  deriving stock Show
  deriving anyclass IsoValue

instance ParameterHasEntrypoints SplitParam where
  type ParameterEntrypointsDerivation SplitParam = EpdPlain

instance ParameterHasEntrypoints Parameter where
  type ParameterEntrypointsDerivation Parameter = EpdRecursive

splitTezContract :: Natural -> Address -> ContractCode Parameter Storage
splitTezContract totalShares delegateAdmin = do
  unpair
  caseT @Parameter
    ( #cSetDelegate /-> do
      sender
      push delegateAdmin
      ifEq
       (do
         setDelegate
         nil
         swap
         cons
       )
       failWith

    , #cSplit /-> do
      caseT @SplitParam
        ( #cDefault /-> do
          unStorage
          unpair
          balance
          push @Mutez (toEnum 1)
          ediv
          ifNone
            failWith
            (do
              -- (amount / 1, amount % 1)
              car
              add
              pair
              toStorage
              nil
            )

        , #cFlush /-> do
          swap
          unStorage
          unpair
          stackType @(TotalBalance & Ledger & [(ToFlush, User)] & '[])
          dup
          dip
            (do
              push totalShares
              ediv
              ifNone
                (unit >> failWith)
                (do
                  car
                  swap
                  dig @2
                  map
                    (do
                      dup
                      unpair
                      push @Mutez (toEnum 1)
                      mul
                      swap
                      contract @()
                      ifNone
                        failWith
                        (do
                          swap
                          unit
                          transferTokens @()
                          dip
                            (do
                              unpair
                              swap
                              dup
                              dip
                                (do
                                  dip
                                    (do
                                      swap
                                      dup
                                    )
                                  get
                                  ifNone
                                    (unit >> failWith)
                                    (do
                                      unpair
                                      dup
                                      dip
                                        (do
                                          stackType @(UserShares & UserFlushed & Ledger & ToFlush & AccessibleMutez & '[])
                                          dig @4
                                          dup
                                          dip
                                            (do
                                              stackType @(AccessibleMutez & UserShares & UserFlushed & Ledger & ToFlush & '[])
                                              mul
                                              stackType @(UserAccessibleMutez & UserFlushed & Ledger & ToFlush & '[])
                                              swap
                                              stackType @(UserFlushed & UserAccessibleMutez & Ledger & ToFlush & '[])
                                              dig @3
                                              stackType @(ToFlush & UserFlushed & UserAccessibleMutez & Ledger & '[])
                                              add
                                              stackType @(NewUserFlushed & UserAccessibleMutez & Ledger & '[])
                                              dup
                                              stackType @(NewUserFlushed & NewUserFlushed & UserAccessibleMutez & Ledger & '[])
                                              dip
                                                (do
                                                  stackType @(NewUserFlushed & UserAccessibleMutez & Ledger & '[])
                                                  ifLe
                                                    nop
                                                    (unit >> failWith)
                                                )
                                            )
                                          stackType @(AccessibleMutez & NewUserFlushed & Ledger & '[])
                                          dug @2
                                        )
                                      pair
                                      some
                                    )
                                )
                              update @Ledger
                            )
                        )
                    )
                  dig @2
                  drop
                  swap
                )
           )
          stackType @(TotalBalance & Ledger & [Operation] & '[])
          pair
          toStorage
          swap
        )
    )
  pair

--   - get (UserShares, UserFlushed) from Ledger
--   - then we have:
--     + User/Ledger
--     + ToFlush
--     + AccessibleMutez = TotalBalance / TotalShares
--     + UserShares
--     + UserFlushed
--     + UserAccessibleMutez = AccessibleMutez * UserShares
--     + NewUserFlushed = ToFlush + UserFlushed
--   - assert: UserAccessibleMutez >= NewUserFlushed
--   - transfer ToFlush to User
--   - NewLedger = Update(User, Just (UserShares, NewUserFlushed), Ledger)

-- (unit %default)

-- Callable by any SENDER
-- Increment the historical_balance by the number of mutez sent

-- (list %flush (pair (mutez %to_flush) (address %user_address))
-- Callable by any SENDER
-- For each to_flush, user_address pair:
-- Lookup user_address in the ledger, getting the user's (nat %shares) and (mutez %flushed)
-- Assert that: (historical_balance / total_shares) * shares >= flushed + to_flush
-- Since (/) is integer division, the remainder will not be flushable
-- user_can_flush = (historical_balance / total_shares) * shares, so subtracting flushed gives an upper bound on to_flush
-- While the R.H.S. is a nat, the L.H.S. is a mutez, limiting it to ~2^63. If a user could be expected to flush more than that many tez in their lifetime, flushed can be stored as a nat
-- Increment the user's flushed "balance" in the ledger by to_flush, i.e. new_flushed := flushed + to_flush


instance HasAnnotation Storage

printSplitTezContract :: Natural -> Address -> Maybe FilePath -> Bool -> IO ()
printSplitTezContract totalShares delegateAdmin mOutput forceOneLine' =
  maybe TL.putStrLn Utf8.writeFile mOutput $
  printLorentzContract forceOneLine' $
    (defaultContract (splitTezContract totalShares delegateAdmin))
      { cDisableInitialCast = True }

printExampleSplitTez :: IO ()
printExampleSplitTez =
  printSplitTezContract
  0
  (read "tz1QS8VYYVDjv7iReBzXeheL6x63A1oATTj8")
  (Just "split_tez.tz")
  False

