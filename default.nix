with (import <nixpkgs> { });

mkShell {
  buildInputs = [
    moreutils
    parted
    partimage
  ];
}