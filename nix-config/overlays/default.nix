final: prev: {
  # direnv 2.37.1's checkPhase hangs in the macOS sandbox; skip it.
  direnv = prev.direnv.overrideAttrs (_: { doCheck = false; });

  # python3Packages.curl-cffi 0.15.0 is broken on darwin (nixpkgs 2026-08:
  # _wrapper.abi3.so has no LC_RPATH for libcurl-impersonate). It's only
  # yt-dlp's optional browser-impersonation extra, so drop it. Remove this
  # once curl-cffi builds again.
  yt-dlp = prev.yt-dlp.overrideAttrs (old: {
    propagatedBuildInputs = builtins.filter
      (d: (d.pname or "") != "curl-cffi")
      (old.propagatedBuildInputs or [ ]);
  });
}
