{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = [
    (pkgs.python313.withPackages (ps: with ps; [
      (ps.opencv4.override {
        enableGtk3 = true;
      })
      ipykernel
      matplotlib
    ]))
  ];
}
