with (import <nixpkgs> {});
let

  esp-toolchain = stdenv.mkDerivation rec {
    name = "esp32-toolchain";
    src = fetchurl {
      url = "https://dl.espressif.com/dl/xtensa-esp32-elf-gcc8_2_0-esp-2019r2-linux-amd64.tar.gz";
      sha256 = "1pzv1r9kzizh5gi3gsbs6jg8rs1yqnmf5rbifbivz34cplfprm76";
    };


    buildInputs = [ makeWrapper ];

    phases = [ "unpackPhase" "installPhase" ];

    installPhase = ''
      cp -r . $out
      for FILE in $(ls $out/bin); do
      FILE_PATH="$out/bin/$FILE"
      if [[ -x $FILE_PATH ]]; then
        mv $FILE_PATH $FILE_PATH-unwrapped
        makeWrapper ${fhsEnv}/bin/esp32-toolchain-env $FILE_PATH --add-flags "$FILE_PATH-unwrapped"
      fi
      done
    '';
  };

  python2o = let
    packageOverrides = self: super: {
      pyparsing = super.pyparsing.overridePythonAttrs( old: rec {
        version = "2.3.1";
        src = super.fetchPypi {
          pname="pyparsing";
          inherit version;
          sha256="66c9268862641abcac4a96ba74506e594c884e3f57690a696d21ad8210ed667a";
          };
        });
      };
  in pkgs.python2.override{inherit packageOverrides; self= python2o;};

  esp-idf = stdenv.mkDerivation rec {
    name = "esp-idf";

    src = pkgs.fetchgit {
      url = "https://github.com/espressif/esp-idf";
      rev  = "v4.1-dev";
      deepClone = true;
      sha256 = "0d1iqxz1jqz3rrk2c5dq33wp1v71d9190wv3bnigxlp5kcsj0j1w";
    };

    dontBuild = true;
    dontConfigure = true;
    buildInputs = with pkgs; [
      gawk gperf gettext automake bison flex texinfo help2man libtool autoconf ncurses5 cmake glibcLocales
      (python2o.withPackages (ppkgs: with ppkgs; [ pyserial future cryptography setuptools pyelftools ppkgs.pyparsing click ]))
      esp-toolchain
    ];

    installPhase = ''
      cp -r . $out
    '';
  };

  fhsEnv = buildFHSUserEnv {
    name = "esp32-toolchain-env";
    targetPkgs = pkgs: with pkgs; [ zlib ];
    runScript = "";
  };
in
mkShell {
  name = "wakeonlan";
  buildInputs = [ esp-idf esp-toolchain esptool cmake python2o ];
  shellHook = ''
    set -e
    export IDF_PATH=${esp-idf}
    export NIX_CFLAGS_LINK=-lncurses
    export PATH=$PATH:$IDF_PATH/tools
  '';
}
