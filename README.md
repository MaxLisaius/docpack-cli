# docpack CLI

Prebuilt binaries of `docpack`, the command-line tool behind [docpack.dev](https://docpack.dev): documentation your agents can trust. It turns the Markdown in your repo into a docpack, checks it, and keeps every page's trust status honest.

This repository holds release binaries and install scripts only.

## Install

macOS and Linux:

```sh
curl -fsSL https://raw.githubusercontent.com/MaxLisaius/docpack-cli/main/install.sh | sh
```

Windows (PowerShell):

```powershell
irm https://raw.githubusercontent.com/MaxLisaius/docpack-cli/main/install.ps1 | iex
```

Both scripts download the latest release for your platform, verify it against `checksums.txt`, and install a single binary. Set `DOCPACK_VERSION=v0.1.0` to pin a release, or `DOCPACK_INSTALL_DIR` to choose where it goes.

Prefer to do it by hand? Download the archive for your platform from [Releases](https://github.com/MaxLisaius/docpack-cli/releases), check it against `checksums.txt`, and put `docpack` on your `PATH` (on macOS and Linux, run `chmod +x docpack` first).

Check it worked:

```sh
docpack --version
```

## Next

Start with the [docs](https://docpack.dev/docs/). Or ask your coding agent to set it up: install the [GitHub App](https://github.com/apps/documenteverything/installations/new) and copy the setup prompt from your dashboard.

## License

Apache License 2.0. See [LICENSE](LICENSE).
