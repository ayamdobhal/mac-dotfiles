final: prev: {
  # direnv 2.37.1's checkPhase hangs in the macOS sandbox; skip it.
  direnv = prev.direnv.overrideAttrs (_: { doCheck = false; });
}
