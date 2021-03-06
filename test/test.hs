import Cardano.Prelude
import Test.Cardano.Prelude

import Options.Applicative (execParser)

import Test.Options (Opts(..), optsParser)

import qualified Test.Cardano.Chain.Block.Bi
import qualified Test.Cardano.Chain.Delegation.Bi
import qualified Test.Cardano.Chain.Epoch.File
import qualified Test.Cardano.Chain.Genesis.Json
import qualified Test.Cardano.Chain.Ssc.Bi
import qualified Test.Cardano.Chain.Txp.Bi
import qualified Test.Cardano.Chain.Txp.Json
import qualified Test.Cardano.Chain.Txp.Validation
import qualified Test.Cardano.Chain.Update.Bi
import qualified Test.Cardano.Chain.Update.Json

main :: IO ()
main = do
  opts <- execParser optsParser
  runTests
    [ Test.Cardano.Chain.Block.Bi.tests
    , Test.Cardano.Chain.Delegation.Bi.tests
    , Test.Cardano.Chain.Epoch.File.tests
    , Test.Cardano.Chain.Genesis.Json.tests
    , Test.Cardano.Chain.Ssc.Bi.tests
    , Test.Cardano.Chain.Txp.Bi.tests
    , Test.Cardano.Chain.Txp.Json.tests
    , Test.Cardano.Chain.Txp.Validation.tests $ optsTestScenario opts
    , Test.Cardano.Chain.Update.Bi.tests
    , Test.Cardano.Chain.Update.Json.tests
    ]
