#!/bin/sh
# Install the docpack CLI from https://github.com/MaxLisaius/docpack-cli/releases
#
#   curl -fsSL https://raw.githubusercontent.com/MaxLisaius/docpack-cli/main/install.sh | sh
#
# Options (environment variables):
#   DOCPACK_VERSION=v0.1.0      install that release instead of the latest
#   DOCPACK_INSTALL_DIR=<dir>   where the binary goes (default: ~/.local/bin)
#   DOCPACK_OS / DOCPACK_ARCH   override detection (linux|darwin, amd64|arm64)
set -eu

repo="MaxLisaius/docpack-cli"
version="${DOCPACK_VERSION:-latest}"
dir="${DOCPACK_INSTALL_DIR:-$HOME/.local/bin}"

os="${DOCPACK_OS:-$(uname -s | tr '[:upper:]' '[:lower:]')}"
case "$os" in
  linux|darwin) ;;
  *) echo "docpack: unsupported OS '$os'. On Windows, use install.ps1." >&2; exit 1 ;;
esac

arch="${DOCPACK_ARCH:-$(uname -m)}"
case "$arch" in
  x86_64|amd64) arch=amd64 ;;
  arm64|aarch64) arch=arm64 ;;
  *) echo "docpack: unsupported architecture '$arch'." >&2; exit 1 ;;
esac

if [ "$version" = latest ]; then
  version=$(curl -fsSL "https://api.github.com/repos/$repo/releases/latest" |
    sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p' | head -n 1)
  if [ -z "$version" ]; then
    echo "docpack: could not find the latest release of $repo." >&2
    exit 1
  fi
fi

file="docpack_${version#v}_${os}_${arch}.tar.gz"
base="https://github.com/$repo/releases/download/$version"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

curl -fsSL -o "$tmp/$file" "$base/$file"
curl -fsSL -o "$tmp/checksums.txt" "$base/checksums.txt"

want=$(grep " $file\$" "$tmp/checksums.txt" | cut -d ' ' -f 1)
if command -v sha256sum >/dev/null 2>&1; then
  got=$(sha256sum "$tmp/$file" | cut -d ' ' -f 1)
else
  got=$(shasum -a 256 "$tmp/$file" | cut -d ' ' -f 1)
fi
if [ -z "$want" ] || [ "$want" != "$got" ]; then
  echo "docpack: checksum mismatch for $file; nothing was installed." >&2
  exit 1
fi

tar -xzf "$tmp/$file" -C "$tmp"
mkdir -p "$dir"
cp "$tmp/docpack" "$dir/docpack"
chmod 0755 "$dir/docpack"

echo "docpack $version installed to $dir/docpack"
case ":$PATH:" in
  *":$dir:"*) ;;
  *) echo "Add $dir to your PATH to run docpack." ;;
esac
