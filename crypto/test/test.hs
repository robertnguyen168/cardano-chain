import Cardano.Prelude
import Test.Cardano.Prelude

import System.Environment (withArgs)

import Test.Hspec (hspec)

import Spec (spec)

import qualified Test.Cardano.Crypto.Bi


-- | Main testing action
--
--   We use 'withArgs' to swallow common testing arguments that we want to parse
--   with `optparse-applicative`. This is only temporary until we remove
--   `hspec`, which is interfering.
main :: IO ()
main = withArgs [] $ do
  hspec spec
  runTests [Test.Cardano.Crypto.Bi.tests]
