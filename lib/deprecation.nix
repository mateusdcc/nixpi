{ lib }:

{
  warn =
    {
      old,
      replacement,
      supportedThrough ? "1.x",
    }:
    value:
    lib.warn "nixpi: `${old}` is deprecated; use `${replacement}`. It remains available throughout ${supportedThrough}." value;

  inherit (lib)
    mkAliasOptionModule
    mkRemovedOptionModule
    mkRenamedOptionModule
    ;
}
