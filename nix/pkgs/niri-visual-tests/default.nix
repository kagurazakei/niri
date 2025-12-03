{
  mkNiriDerivation,
  wrapGAppsHook4,
  libadwaita,
}:
let
  cargoToml = builtins.fromTOML (builtins.readFile ../../../niri-visual-tests/Cargo.toml);
in
mkNiriDerivation {
  pname = cargoToml.package.name;

  overrideCraneBuildArgs =
    old:
    old
    // {
      nativeBuildInputs = old.nativeBuildInputs ++ [
        wrapGAppsHook4
      ];

      buildInputs = old.buildInputs ++ [
        libadwaita
      ];
    };
}
