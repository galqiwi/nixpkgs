{
  lib,
  stdenv,
  fetchurl,
  makeBinaryWrapper,
  ripgrep,
  versionCheckHook,
}:
let
  version = "0.101.0";
  sources = {
    "x86_64-linux" = {
      url = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-x86_64-unknown-linux-musl.tar.gz";
      hash = "sha256-/zY/hZfb8Dg8F2WefJJzW6qZG+irmflnxcw8aLMpJ3w=";
      binary = "codex-x86_64-unknown-linux-musl";
    };
    "aarch64-linux" = {
      url = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-aarch64-unknown-linux-musl.tar.gz";
      hash = "sha256-9cSxFHMyocxBCLd2x1nue0CdNl5YMKTllmfh+cfm2mA=";
      binary = "codex-aarch64-unknown-linux-musl";
    };
    "x86_64-darwin" = {
      url = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-x86_64-apple-darwin.tar.gz";
      hash = "sha256-UdTjUXx18JMxMr4zZfM7CANtQ9PCBpKzD1zDbdPqw+k=";
      binary = "codex-x86_64-apple-darwin";
    };
    "aarch64-darwin" = {
      url = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-aarch64-apple-darwin.tar.gz";
      hash = "sha256-/Ah+kAK+DhcL/qonZZ43eCHhWrl4tKSQde+V21+CB/g=";
      binary = "codex-aarch64-apple-darwin";
    };
  };
  srcInfo = sources.${stdenv.hostPlatform.system} or (throw "unsupported platform ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation {
  pname = "codex";
  inherit version;

  src = fetchurl {
    inherit (srcInfo) url hash;
  };

  nativeBuildInputs = [
    makeBinaryWrapper
  ];

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    tar -xzf $src
    install -m755 ${srcInfo.binary} $out/bin/codex
    runHook postInstall
  '';

  postFixup = ''
    wrapProgram $out/bin/codex --prefix PATH : ${lib.makeBinPath [ ripgrep ]}
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  meta = {
    description = "Lightweight coding agent that runs in your terminal";
    homepage = "https://github.com/openai/codex";
    changelog = "https://raw.githubusercontent.com/openai/codex/refs/tags/rust-v${version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    mainProgram = "codex";
    maintainers = with lib.maintainers; [
      malo
      delafthi
    ];
    platforms = lib.platforms.unix;
  };
}
