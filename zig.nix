  llvm-xtensa = stdenv.mkDerivation rec {
    pname = "llvm-xtensa";
    version = "master";
    src = fetchFromGitHub {
      owner = "espressif";
      repo = "llvm-project";
      sha256 = "13kgdvabxniac9w6lfgfikgykbjb6zda441mfbrnwgzihi5h8j74";
      rev = "72de7ca254b47a76ff7f34202cfb4cc73c288301";
    };

    nativeBuildInputs = [ cmake gcc ninja python2 ];

    configurePhase = ''
      mkdir build && cd build
      cmake -G "Ninja" -DCMAKE_INSTALL_PREFIX="<LLVM install directory>" -DCMAKE_BUILD_TYPE=Release -DLLVM_EXPERIMENTAL_TARGETS_TO_BUILD="Xtensa" -DLLVM_ENABLE_PROJECTS="clang;lld" ../llvm
    '';

    buildPhase = ''
      cmake --build .
    '';

    installPhase = ''
      cmake --install . --prefix $out
    '';
  };


  zig-xtensa = stdenv.mkDerivation rec {
    pname = "zig-esp32";
    version = "master";
    src = fetchFromGitHub {
      owner = "INetBowser";
      repo = "zig-xtensa";
      sha256 = "17gd1z6wpwqjzqnjvd21cbvpwp41w1nk2j82bgqhv66k7k9633jx";
      rev = "ccd1bd8dfb955c76301961b0be38717ec17f5713";
    };

    nativeBuildInputs = [ cmake clang gnumake python2 ];
    buildInputs = [ llvm-xtensa ];

    configurePhase = ''
      mkdir build && cd build
      cmake -DCMAKE_PREFIX_PATH="${llvm-xtensa.out}" -DCMAKE_INSTALL_PREFIX="$out" -DCMAKE_BUILD_TYPE=Release ..
    '';

    buildPhase = ''
      make -j10
    '';

    installPhase = ''
      mkdir -p $out
      # make install
      # mkdir -p $out/lib
      mkdir -p $out/bin
      cp -r ../lib $out/lib
      cp -av zig $out/bin
    '';
  };

