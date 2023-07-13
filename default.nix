with (import <nixpkgs> { });

mkShell {
  buildInputs = [
    moreutils
    partimage
    parted
  ];
}