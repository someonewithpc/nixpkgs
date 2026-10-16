{
  lib,
  callPackage,
  cmake,
  coin3d,
  doxygen,
  eigen,
  fetchFromGitHub,
  fetchpatch,
  fmt,
  graphviz,
  gts,
  hdf5,
  libGLU,
  libredwg,
  libspnav,
  libxmu,
  medfile,
  mpi,
  ninja,
  ode,
  opencascade-occt_8,
  microsoft-gsl,
  pkg-config,
  python3Packages,
  stdenv,
  swig,
  xercesc,
  yaml-cpp,
  zlib,
  qt6,
  nix-update-script,
  gmsh,
  which,
  gtk3,
  gsettings-desktop-schemas,
  versionCheckHook,
  writeShellScript,
}:
let
  pythonDeps = with python3Packages; [
    boost
    gitpython # for addon manager
    ifcopenshell
    matplotlib
    opencamlib
    pivy
    ply # for openSCAD file support
    pybind11
    pycollada
    pyside6
    python
    pyyaml # (at least for) PyrateWorkbench
    scipy
    shiboken6
    vtk
    networkx # for sheetmetal plugin
  ];

  # OCCT 8 support from FreeCAD main, which 1.1.x does not have
  occt8Patches =
    map
      (
        { rev, hash }:
        fetchpatch {
          url = "https://github.com/FreeCAD/FreeCAD/commit/${rev}.patch";
          inherit hash;
        }
      )
      [
        # SMESH: Make common between OCCT 7 and 8
        {
          rev = "50aaaebea006fb17b9f20de894eead9938513c03";
          hash = "sha256-+8kxMMVILgwDD228k+TL7yuoMABN5PQyAFEVH00dWgI=";
        }
        # SMESH: Add guards for OCCT 8
        {
          rev = "93c1be3d53a30f45fbf0c91473895d7a51a636c6";
          hash = "sha256-dx4yPg9zhAITMnn7vMrogYwns3eHgAUOAS9q5hvpGa8=";
        }
        # Part: Make common between OCCT 7 and 8
        {
          rev = "7f56f0c9e5681a619f68b9314f453de5490976c9";
          hash = "sha256-/rGytDtJmIQkaKST0+LaNHkPT4vAgJKqCTdclhZtzHI=";
        }
        # Part: Add guards for OCCT 8
        {
          rev = "2cafeb808933cba231bc466791e91abe4dec2ef6";
          hash = "sha256-JcvFQzFuY+Vpn943dVUNOonJrmZupzHUeuXItEpLNn0=";
        }
        # Import: Make common between OCC 7 and 8
        {
          rev = "e7db87b5a3a9a976b439fd658e91474a6bd6fa76";
          hash = "sha256-gLYoe2UjIjZ/Ld5iZ+C/DwtOMCfH0KwYihWb0XUipSI=";
        }
        # PartDesign: Make common between OCCT 7 and OCCT 8
        {
          rev = "10256c109cb38117d87c35b0641061e509071e49";
          hash = "sha256-CCh2yekgLm7AUEMiI2OAew8w8F1If1lEbr5SyklgqLU=";
        }
        # Sketcher: Make common between OCCT 7 and OCCT 8
        {
          rev = "160db2afd6f52db37038dfeda6fdec5367d51bc7";
          hash = "sha256-v4pkP3cMLEU0Vov3+a5wuRMBUdnsz/AECYTsxWD+9E0=";
        }
        # TechDraw: Make common between OCCT 7 and 8
        {
          rev = "0e766249a65e47404425788e1b701898fb2b1c07";
          hash = "sha256-u/0Tc64puOjaNEK+rMX962eTEZdpWESG9ZJ6YxOGAOI=";
        }
        # Surface: Make common between OCCT 7 and 8
        {
          rev = "49a714f115b64997d61862ac37cdd55b02000e25";
          hash = "sha256-XMtxB/wMvPnln6wN8RlPSVIFAXWfi0l1fF04Vtk6vcM=";
        }
        # ReverseEngineering: Make common between OCCT 7 and 8
        {
          rev = "e753c1dcd417e72597b927d78d79263926430de9";
          hash = "sha256-Rai3k0Lum67Vqjz+nDbyn9xMtbS9/JuUo+30Chkxd1Q=";
        }
        # ReverseEngineering: Add guards for OCCT 8
        {
          rev = "e323d093a2322170d5535ec717a78ea684f7a876";
          hash = "sha256-cst7EluzDsMLDG70UPMwuKVLxGE4M4b9OsbnRzu4QXI=";
        }
        # CAM: Make common between OCCT 7 and 8
        {
          rev = "2f3e392ac936c1b6628b009c749ce3523ef30bb6";
          hash = "sha256-CljbZRjvgdbzxUwxfuO2VDX30H8cMvSvwdX4qG51KAk=";
        }
        # Inspection: Make common between OCCT 7 and 8
        {
          rev = "9d2fe6e351eced57fe504829d94dfbb2ee8489ce";
          hash = "sha256-YjZS7jmltdHS6TINSoOurW0DEMgt8hVtts+r3TLh194=";
        }
        # SMESH: Enable use of OCCT 8.0
        {
          rev = "4af38275a34a5fb39be25408aba100458318a8b7";
          hash = "sha256-o5ha8YoZZpLu450T0XdUZOYvA2PiptpKzmnSA3TIw+E=";
        }
        # Surface: Fix pre-compiled headers for OCCT 8.0
        {
          rev = "7cbb6b0e0c1319aa52d32c6ce288300cf0d8690b";
          hash = "sha256-rzXohyC9U2nIbFdxRPOMWxRWqKtmrJjD/2aoTcdoteo=";
        }
        # Part: Add guards for faulty exceptions in OCCT 8
        {
          rev = "31ed5bc31eb4d54839ffcaefd1137b69fd7e8b8f";
          hash = "sha256-gzQYSF7DPko2w+C5RTPhXSXmOkGTqv1SruEq/C9aXYc=";
        }
        # TechDraw: fix bad result with OCCT 8.0.1 (#33214)
        {
          rev = "b5e2b5b8554d2ea3be71459e7bc7edd78b999332";
          hash = "sha256-pv82Kt+mGcvLWC7NPZyIjbtzfboqj03YAmSN4RkbbgE=";
        }
      ];

  freecad-utils = callPackage ./freecad-utils.nix { inherit (python3Packages) python; };
in
freecad-utils.makeCustomizable (
  stdenv.mkDerivation (finalAttrs: {
    pname = "freecad";
    version = "1.1.4";

    src = fetchFromGitHub {
      owner = "FreeCAD";
      repo = "FreeCAD";
      tag = finalAttrs.version;
      hash = "sha256-VB2jxacRtpLeVaCMuHqGDzNZKx5wqOJXYlbJEpDXB70=";
      fetchSubmodules = true;
    };

    nativeBuildInputs = [
      cmake
      ninja
      pkg-config
      swig
      doxygen
      qt6.wrapQtAppsHook
    ];

    buildInputs = [
      coin3d
      eigen
      fmt
      gts
      hdf5
      libGLU
      libxmu
      libspnav
      medfile
      mpi
      ode
      xercesc
      yaml-cpp
      zlib
      opencascade-occt_8
      microsoft-gsl
      qt6.qtbase
      qt6.qtsvg
      qt6.qttools
      qt6.qtwayland
      qt6.qtwebengine
    ]
    ++ pythonDeps;

    patches = [ ./0001-NIXOS-don-t-ignore-PYTHONPATH.patch ] ++ occt8Patches;

    postPatch = ''
      substituteInPlace src/Mod/Fem/femmesh/gmshtools.py \
        --replace-fail 'self.gmsh_bin = ""' 'self.gmsh_bin = "${lib.getExe gmsh}"'
    '';

    cmakeFlags = [
      "-Wno-dev" # turns off warnings which otherwise makes it hard to see what is going on
      (lib.cmakeBool "BUILD_DRAWING" true)
      (lib.cmakeBool "BUILD_FLAT_MESH" true)
      (lib.cmakeBool "INSTALL_TO_SITEPACKAGES" false)
      (lib.cmakeBool "FREECAD_USE_PYBIND11" true)
      (lib.cmakeBool "BUILD_QT5" false)
      (lib.cmakeBool "BUILD_QT6" true)
    ];

    qtWrapperArgs =
      let
        binPath = lib.makeBinPath [
          graphviz
          libredwg
          which # for locating tools
        ];
      in
      [
        "--set COIN_GL_NO_CURRENT_CONTEXT_CHECK 1"
        "--prefix PATH : ${binPath}"
        "--prefix PYTHONPATH : ${python3Packages.makePythonPath pythonDeps}"
        "--prefix XDG_DATA_DIRS : ${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}:${gtk3}/share/gsettings-schemas/${gtk3.name}"
      ];

    postFixup = ''
      mv $out/share/doc $out
      ln -s $out/doc $out/share/doc
      ln -s $out/bin/FreeCAD $out/bin/freecad
      ln -s $out/bin/FreeCADCmd $out/bin/freecadcmd
    '';

    passthru = {
      tests = callPackage ./tests { };
      updateScript = nix-update-script {
        extraArgs = [
          "--version-regex"
          "([0-9.]+)"
        ];
      };
    };

    nativeInstallCheckInputs = [ versionCheckHook ];
    doInstallCheck = true;

    versionCheckProgram = writeShellScript "version-check.sh" ''
      # As of 2026-07-26, the way FreeCAD handles `--version` is awful.
      # - The main program, `freecad`, opens a GUI prompt for `--version`,
      # unless `--console` is also given.
      # - Even with `--version --console`, `freecad` crashes if there is no
      # display server, so we need to use `freecadcmd` instead, which is a
      # separate binary, for unknown reasons.
      # - `freecadcmd --version` crashes if it cannot create a directory under
      # `$HOME/.local/share/FreeCAD/`
      #   Adding `--safe-mode` appears to fix this, but `versionCheckProgramArg`
      #  only allows for a single argument (as a list gets concaternated),
      #  so we need this script.

      # The path to `freecadcmd` gets passed in via $1, to allow the `out`
      # placeholder to function properly
      exec "$1" --version --safe-mode
    '';
    versionCheckProgramArg = "${placeholder "out"}/bin/freecadcmd";

    # 6.9k object files, cuts down build time from 2-3 hours to 15 minutes
    requiredSystemFeatures = [ "big-parallel" ];

    meta = {
      homepage = "https://www.freecad.org";
      description = "General purpose Open Source 3D CAD/MCAD/CAx/CAE/PLM modeler";
      longDescription = ''
        FreeCAD is an open-source parametric 3D modeler made primarily to design
        real-life objects of any size. Parametric modeling allows you to easily
        modify your design by going back into your model history and changing its
        parameters.

        FreeCAD allows you to sketch geometry constrained 2D shapes and use them
        as a base to build other objects. It contains many components to adjust
        dimensions or extract design details from 3D models to create high quality
        production ready drawings.

        FreeCAD is designed to fit a wide range of uses including product design,
        mechanical engineering and architecture. Whether you are a hobbyist, a
        programmer, an experienced CAD user, a student or a teacher, you will feel
        right at home with FreeCAD.
      '';
      license = lib.licenses.lgpl2Plus;
      maintainers = with lib.maintainers; [
        srounce
        grimmauld
        acuteaangle
      ];
      platforms = lib.platforms.linux;
      mainProgram = "freecad";
      # repology claims `freecadweb` as vendor, but newer CVEs (e.g. CVE-2026-73235) are listed with freecad/freecad
      identifiers.cpeParts = lib.meta.cpeFullVersionWithVendor "freecad" finalAttrs.version;
    };
  })
)
