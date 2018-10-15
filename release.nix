let
  tryImport = p: d: if builtins.pathExists p then import p else d;
in
{ nixpkgs ? <nixpkgs>
, supportedSystems ? [ "x86_64-linux" "x86_64-darwin"]
, scrubJobs ? true
, nixpkgsArgs ? {
    # pass `nixpkgs` explicitly as `nixpkgsArgs` here
    # thus the `release-lib.nix` will pass it to the
    # packageSet (./.) as well, and we have a consistent
    # nixpkgs in the `release.nix` and `default.nix`.
    inherit nixpkgs;
    config = tryImport ./config.nix {}
          // { allowUnfree = false; inHydra = true; };
  }
}:
# we are going to re-use the release-lib from nixpkgs
# this will provide us with `mapTestsOn` to test on
# multiple platforms easily.
with (import (nixpkgs + "/pkgs/top-level/release-lib.nix") {
  inherit supportedSystems scrubJobs nixpkgsArgs;
  packageSet = import ./.;
});
let
  # platform selection. If we want to allow a package to
  # be only built on a subset of platforms we could customize
  # this here by setting that platform only. E.g. [ "x86_64-linux" ];
  platforms = {
    cardano-binary  = supportedSystems;
    cardano-crypto  = supportedSystems;
    cardano-prelude = supportedSystems;
  };

in
  mapTestOn platforms
