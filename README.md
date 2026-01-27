# niri-bootc

A Podman-based, reproducible container environment for building and testing the Niri boot component (toolchain, bootloader, and helper scripts).

## Table of Contents

- Overview
- Features
- Prerequisites
- Quick start
  - Build the image
  - Run the container
- Usage
- Configuration
- Development
- Testing
- Troubleshooting
- Contributing
- License
- Maintainers / Contact

## Overview

niri-bootc packages a reproducible container environment (originally Dockerfile-compatible) that can be built and run with Podman. The image contains the toolchain and helper scripts needed to build and test the Niri boot component so contributors and CI can run builds without installing native toolchains on the host.

## Features

- Single Dockerfile-compatible container definition (buildable with Podman)
- Shell helper scripts for common tasks
- Reproducible development and CI environment
- Small, focused image intended for build and test tasks

## Prerequisites

- Podman installed (tested with Podman >= 3.0). On macOS/Windows use Podman Desktop or a Podman machine.
- Git to clone the repository (optional but recommended).
- For rootless Podman and bind mounts, ensure /etc/subuid and /etc/subgid are configured for your user if necessary.

## Quick start

### Build the image

From the project root (where the Dockerfile lives):

```bash
podman build -t zpeppler/niri-bootc:local .
```

Replace the image name and tag as desired.

### Run an interactive container

Mount the working copy and open a shell:

```bash
podman run --rm -it \
  -v "$(pwd)":/workspace:Z \
  -w /workspace \
  zpeppler/niri-bootc:local \
  /bin/bash
```

Notes:
- Use the `:Z` (or `:z`) mount option to set SELinux labels when SELinux is enabled.
- On macOS/Windows start a podman machine first (podman machine init && podman machine start).
- For rootless Podman, if you see permission issues with mounts, see Troubleshooting.

## Usage

Common example workflows (replace script names with the actual scripts in this repo):

- Build inside the container:

```bash
podman run --rm -it -v "$(pwd)":/workspace:Z -w /workspace zpeppler/niri-bootc:local ./build.sh
```

- Run tests:

```bash
podman run --rm -it -v "$(pwd)":/workspace:Z -w /workspace zpeppler/niri-bootc:local ./test.sh
```

- Pass environment variables:

```bash
podman run --rm -e NIRI_TARGET=arm -v "$(pwd)":/workspace:Z -w /workspace zpeppler/niri-bootc:local ./build.sh
```

## Configuration

Common environment variables (examples — update to match repository scripts):

- NIRI_TARGET — target architecture (default: x86_64)
- NIRI_BUILD_TYPE — `debug` or `release` (default: `debug`)

You can pass variables via `-e VAR=value` or `--env-file ./env.list`.

## Development

- Edit source files on the host and run build/test commands inside the container for consistent results.
- For a persistent dev container, start it in detached mode and `podman exec -it` into it:

```bash
podman run -d --name niri-dev -v "$(pwd)":/workspace:Z -w /workspace zpeppler/niri-bootc:local tail -f /dev/null
podman exec -it niri-dev /bin/bash
```

## Testing

Run the project's test scripts inside the container. Example:

```bash
podman run --rm -v "$(pwd)":/workspace:Z -w /workspace zpeppler/niri-bootc:local ./run-tests.sh
```

For CI, either use runners that support Podman or install Podman in the job. There are community GitHub Actions that install Podman or use a container with Podman preinstalled.

## Troubleshooting

- Permission errors with rootless Podman and bind mounts:
  - Use `--userns=keep-id` to preserve host UID/GID inside the container.
  - Adjust your `/etc/subuid` and `/etc/subgid` mappings, or use `podman unshare chown` to change ownership inside the user namespace.

- SELinux errors on mounts:
  - Add `:Z` (or `:z`) to the mount flag: `-v "$(pwd)":/workspace:Z`.

- Need hardware/device access:
  - Podman supports `--privileged` and `--device` flags; rootless Podman has limitations. Consider a rootful Podman session if device passthrough is required.

- Pushing images to registries:
  - Log in before pushing: `podman login docker.io`
  - Push using an explicit transport: `podman push zpeppler/niri-bootc:local docker://docker.io/zpeppler/niri-bootc:local`

## Contributing

Contributions are welcome. Please:

1. Fork the repository
2. Create a branch for your change: `git checkout -b feature/my-change`
3. Run tests locally with Podman
4. Open a pull request with a clear description of your change

Please follow any repository-specific contribution guidelines if present.

## License

This repository does not currently specify a license in this README. Add a LICENSE file or change this section to indicate the intended license (for example MIT or Apache-2.0).

## Maintainers / Contact

- Owner: @ZPeppler


---

(This README was replaced via an automated update requested by the repository owner.)