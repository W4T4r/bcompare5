{
  description = "Beyond Compare 5 Flake for Home Manager and NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      lib = pkgs.lib;
    in
    {
      packages.${system} = rec {
        bcompare = pkgs.stdenv.mkDerivation rec {
          pname = "bcompare5";
          version = "5.2.0.31950";

          src = pkgs.fetchurl {
            url = "https://www.scootersoftware.com/files/bcompare-${version}.x86_64.tar.gz";
            sha256 = "1dbkkwb077gql3gs69whdcf90llw82cwvypaqz04a8s66w59ss7l";
          };

          nativeBuildInputs = [
            pkgs.autoPatchelfHook
            pkgs.makeWrapper
          ];

          buildInputs = [
            pkgs.stdenv.cc.cc.lib
            pkgs.libX11
            pkgs.libXext
            pkgs.libXrender
            pkgs.libice
            pkgs.libsm
            pkgs.dbus
            pkgs.zlib
            pkgs.bzip2
            pkgs.fontconfig
            pkgs.freetype
            pkgs.libxcrypt-legacy
            pkgs.qt6.qtbase
          ];

          dontWrapQtApps = true;

          autoPatchelfIgnoreMissingDeps = [
            "libKF6KIOWidgets.so.6"
            "libKF6KIOGui.so.6"
            "libKF6KIOCore.so.6"
            "libKF6I18n.so.6"
            "libKF6CoreAddons.so.6"
            "libKF5KIOWidgets.so.5"
            "libKF5KIOGui.so.5"
            "libKF5KIOCore.so.5"
            "libKF5I18n.so.5"
            "libKF5CoreAddons.so.5"
            "libQt5Widgets.so.5"
            "libQt5Gui.so.5"
            "libQt5Core.so.5"
            "libkio.so.5"
            "libQtGui.so.4"
            "libkdecore.so.5"
            "libQtCore.so.4"
          ];

          installPhase = ''
            runHook preInstall

            mkdir -p $out/bin $out/lib/bcompare $out/share/applications $out/share/pixmaps

            cp -r * $out/lib/bcompare/

            ln -s $out/lib/bcompare/BCompare $out/bin/bcompare

            if [ -f bcompare.desktop ]; then
              cp bcompare.desktop $out/share/applications/
              substituteInPlace $out/share/applications/bcompare.desktop \
                --replace "Exec=/usr/bin/bcompare" "Exec=$out/bin/bcompare" \
                --replace "Icon=bcompare" "Icon=bcompare"
            fi
            cp bcompare.png $out/share/pixmaps/

            runHook postInstall
          '';

          meta = with lib; {
            description = "Beyond Compare 5 - Powerful File and Folder Comparison";
            homepage = "https://www.scootersoftware.com/";
            license = licenses.unfree;
            platforms = platforms.linux;
          };
        };

        default = bcompare;
      };
    };
}
