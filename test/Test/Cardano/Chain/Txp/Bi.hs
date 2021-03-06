{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell   #-}
{-# LANGUAGE TypeApplications  #-}

module Test.Cardano.Chain.Txp.Bi
  ( tests
  )
where

import Cardano.Prelude
import Test.Cardano.Prelude

import qualified Data.Map as M
import Data.Typeable (typeRep)
import Data.Vector (Vector)

import Hedgehog (Gen, Property)
import qualified Hedgehog as H
import qualified Hedgehog.Gen as Gen

import Cardano.Binary.Class (Bi, Case(..), LengthOf, SizeOverride(..), szCases)
import Cardano.Chain.Common
  (AddrAttributes(..), Attributes(..), Script(..), mkAttributes)
import Cardano.Chain.Txp
  (Tx(..), TxIn(..), TxInWitness(..), TxOut(..), TxSigData(..), taTx, taWitness)
import Cardano.Crypto (ProtocolMagic(..), SignTag(..), Signature, sign)

import Test.Cardano.Binary.Helpers (SizeTestConfig(..), scfg, sizeTest)
import Test.Cardano.Binary.Helpers.GoldenRoundTrip
  (goldenTestBi, roundTripsBiBuildable, roundTripsBiShow)
import Test.Cardano.Chain.Txp.Example
  ( exampleHashTx
  , exampleRedeemSignature
  , exampleTxId
  , exampleTxInList
  , exampleTxInUnknown
  , exampleTxInUtxo
  , exampleTxOut
  , exampleTxOutList
  , exampleTxProof
  , exampleTxSig
  , exampleTxSigData
  , exampleTxWitness
  )
import Test.Cardano.Chain.Txp.Gen
  ( genTx
  , genTxAttributes
  , genTxAux
  , genTxHash
  , genTxId
  , genTxIn
  , genTxInList
  , genTxInWitness
  , genTxOut
  , genTxOutList
  , genTxPayload
  , genTxProof
  , genTxSig
  , genTxSigData
  , genTxWitness
  )
import Test.Cardano.Crypto.Example
  (examplePublicKey, exampleRedeemPublicKey, exampleSecretKey)
import Test.Cardano.Crypto.Gen (feedPM)


--------------------------------------------------------------------------------
-- Tx
--------------------------------------------------------------------------------

goldenTx :: Property
goldenTx = goldenTestBi tx "test/golden/bi/txp/Tx"
  where tx = UnsafeTx exampleTxInList exampleTxOutList (mkAttributes ())

roundTripTx :: Property
roundTripTx = eachOf 50 genTx roundTripsBiBuildable

--------------------------------------------------------------------------------
-- TxAttributes
--------------------------------------------------------------------------------

goldenTxAttributes :: Property
goldenTxAttributes = goldenTestBi txA "test/golden/bi/txp/TxAttributes"
  where txA = mkAttributes ()


roundTripTxAttributes :: Property
roundTripTxAttributes = eachOf 10 genTxAttributes roundTripsBiBuildable

--------------------------------------------------------------------------------
-- TxAux
--------------------------------------------------------------------------------

roundTripTxAux :: Property
roundTripTxAux = eachOf 100 (feedPM genTxAux) roundTripsBiBuildable

--------------------------------------------------------------------------------
-- Tx Hash
--------------------------------------------------------------------------------

goldenHashTx :: Property
goldenHashTx = goldenTestBi exampleHashTx "test/golden/bi/txp/HashTx"

roundTripHashTx :: Property
roundTripHashTx = eachOf 50 genTxHash roundTripsBiBuildable

--------------------------------------------------------------------------------
-- TxIn
--------------------------------------------------------------------------------


goldenTxInUtxo :: Property
goldenTxInUtxo = goldenTestBi exampleTxInUtxo "test/golden/bi/txp/TxIn_Utxo"

goldenTxInUnknown :: Property
goldenTxInUnknown =
  goldenTestBi exampleTxInUnknown "test/golden/bi/txp/TxIn_Unknown"

roundTripTxIn :: Property
roundTripTxIn = eachOf 100 genTxIn roundTripsBiBuildable


--------------------------------------------------------------------------------
-- TxId
--------------------------------------------------------------------------------

goldenTxId :: Property
goldenTxId = goldenTestBi exampleTxId "test/golden/bi/txp/TxId"

roundTripTxId :: Property
roundTripTxId = eachOf 50 genTxId roundTripsBiBuildable

--------------------------------------------------------------------------------
-- TxInList
--------------------------------------------------------------------------------

goldenTxInList :: Property
goldenTxInList = goldenTestBi exampleTxInList "test/golden/bi/txp/TxInList"

roundTripTxInList :: Property
roundTripTxInList = eachOf 50 genTxInList roundTripsBiShow

--------------------------------------------------------------------------------
-- TxInWitness
--------------------------------------------------------------------------------

goldenPkWitness :: Property
goldenPkWitness = goldenTestBi
  pkWitness
  "test/golden/bi/txp/TxInWitness_PkWitness"
  where pkWitness = PkWitness examplePublicKey exampleTxSig

goldenScriptWitness :: Property
goldenScriptWitness = goldenTestBi
  scriptWitness
  "test/golden/bi/txp/TxInWitness_ScriptWitness"
 where
  scriptWitness   = ScriptWitness validatorScript redeemerScript
  validatorScript = Script 47 "serialized script"
  redeemerScript  = Script 47 "serialized script"

goldenRedeemWitness :: Property
goldenRedeemWitness = goldenTestBi
  redeemWitness
  "test/golden/bi/txp/TxInWitness_RedeemWitness"
 where
  redeemWitness = RedeemWitness exampleRedeemPublicKey exampleRedeemSignature

goldenUnknownWitnessType :: Property
goldenUnknownWitnessType = goldenTestBi
  unkWitType
  "test/golden/bi/txp/TxInWitness_UnknownWitnessType"
  where unkWitType = UnknownWitnessType 47 "forty seven"

roundTripTxInWitness :: Property
roundTripTxInWitness = eachOf 50 (feedPM genTxInWitness) roundTripsBiBuildable

--------------------------------------------------------------------------------
-- TxOutList
--------------------------------------------------------------------------------

goldenTxOutList :: Property
goldenTxOutList = goldenTestBi exampleTxOutList "test/golden/bi/txp/TxOutList"

roundTripTxOutList :: Property
roundTripTxOutList = eachOf 50 genTxOutList roundTripsBiShow

--------------------------------------------------------------------------------
-- TxOut
--------------------------------------------------------------------------------

goldenTxOut :: Property
goldenTxOut = goldenTestBi exampleTxOut "test/golden/bi/txp/TxOut"

roundTripTxOut :: Property
roundTripTxOut = eachOf 50 genTxOut roundTripsBiBuildable

--------------------------------------------------------------------------------
-- TxPayload
--------------------------------------------------------------------------------

roundTripTxPayload :: Property
roundTripTxPayload = eachOf 50 (feedPM genTxPayload) roundTripsBiShow

--------------------------------------------------------------------------------
-- TxProof
--------------------------------------------------------------------------------

goldenTxProof :: Property
goldenTxProof = goldenTestBi exampleTxProof "test/golden/bi/txp/TxProof"

roundTripTxProof :: Property
roundTripTxProof = eachOf 50 (feedPM genTxProof) roundTripsBiBuildable

--------------------------------------------------------------------------------
-- TxSig
--------------------------------------------------------------------------------

goldenTxSig :: Property
goldenTxSig = goldenTestBi txSigGold "test/golden/bi/txp/TxSig"
 where
  txSigGold = sign
    (ProtocolMagic 0)
    SignForTestingOnly
    exampleSecretKey
    exampleTxSigData

roundTripTxSig :: Property
roundTripTxSig = eachOf 50 (feedPM genTxSig) roundTripsBiBuildable

--------------------------------------------------------------------------------
-- TxSigData
--------------------------------------------------------------------------------

goldenTxSigData :: Property
goldenTxSigData = goldenTestBi exampleTxSigData "test/golden/bi/txp/TxSigData"

roundTripTxSigData :: Property
roundTripTxSigData = eachOf 50 genTxSigData roundTripsBiShow

--------------------------------------------------------------------------------
-- TxWitness
--------------------------------------------------------------------------------

goldenTxWitness :: Property
goldenTxWitness = goldenTestBi exampleTxWitness "test/golden/bi/txp/TxWitness"

roundTripTxWitness :: Property
roundTripTxWitness = eachOf 20 (feedPM genTxWitness) roundTripsBiShow

sizeEstimates :: H.Group
sizeEstimates
  = let
      sizeTestGen :: (Show a, Bi a) => Gen a -> Property
      sizeTestGen g = sizeTest $ scfg { gen = g }
      pm = ProtocolMagic 0
      knownTxIn (TxInUnknown _ _) = False
      knownTxIn _                 = True

      -- Explicit bounds for types, based on the generators from Gen.
      attrUnitSize = (typeRep (Proxy @(Attributes ())), SizeConstant 1)
      attrAddrSize =
        ( typeRep (Proxy @(Attributes AddrAttributes))
        , SizeConstant (szCases [Case "min" 1, Case "max" 1024])
        )
      txSigSize = (typeRep (Proxy @(Signature TxSigData)), SizeConstant 66)
      scriptSize =
        ( typeRep (Proxy @Script)
        , SizeConstant $ szCases [Case "loScript" 1, Case "hiScript" 255]
        )
    in H.Group
      "Encoded size bounds for core types."
      [ ("TxId", sizeTestGen genTxId)
      , ( "Tx"
        , sizeTest $ scfg
          { gen         = genTx
          , addlCtx     = M.fromList [attrUnitSize, attrAddrSize]
          , computedCtx = \tx -> M.fromList
            [ ( typeRep (Proxy @(LengthOf [TxIn]))
              , SizeConstant (fromIntegral $ length $ _txInputs tx)
              )
            , ( typeRep (Proxy @(LengthOf [TxOut]))
              , SizeConstant (fromIntegral $ length $ _txOutputs tx)
              )
            ]
          }
        )
      , ("TxIn", sizeTestGen (Gen.filter knownTxIn genTxIn))
      , ( "TxOut"
        , sizeTest
          $ scfg { gen = genTxOut, addlCtx = M.fromList [attrAddrSize] }
        )
      , ( "TxAux"
        , sizeTest $ scfg
          { gen         = genTxAux pm
          , addlCtx     = M.fromList
            [attrUnitSize, attrAddrSize, scriptSize, txSigSize]
          , computedCtx = \ta -> M.fromList
            [ ( typeRep (Proxy @(LengthOf [TxIn]))
              , SizeConstant (fromIntegral $ length $ _txInputs $ taTx ta)
              )
            , ( typeRep (Proxy @(LengthOf (Vector TxInWitness)))
              , SizeConstant (fromIntegral $ length $ taWitness ta)
              )
            , ( typeRep (Proxy @(LengthOf [TxOut]))
              , SizeConstant (fromIntegral $ length $ _txOutputs $ taTx ta)
              )
            ]
          }
        )
      , ( "TxInWitness"
        , sizeTest $ scfg
          { gen     = genTxInWitness pm
          , addlCtx = M.fromList [txSigSize, scriptSize]
          }
        )
      , ("TxSigData", sizeTestGen genTxSigData)
      , ( "Signature TxSigData"
        , sizeTest
          $ scfg { gen = genTxSig pm, addlCtx = M.fromList [txSigSize] }
        )
      ]

-----------------------------------------------------------------------
-- Main test export
-----------------------------------------------------------------------

tests :: IO Bool
tests = and <$> sequence
  [ H.checkSequential $$discoverGolden
  , H.checkParallel $$discoverRoundTrip
  , H.checkParallel sizeEstimates
  ]
