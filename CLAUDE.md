# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview
This repository contains build recipes for LHelper, a cross-platform package management and build system.
Each recipe is a versioned bash script (e.g., `sdl2_2.28.5+2`) and defines how to download, configure, and build a specific software package provided its dependencies are available.

## Recipe Structure and Format
Recipes are bash scripts that follow a standardized pattern:

### Recipe Components
1. **Dependency checking**: `check_commands` verifies required build tools
2. **Platform detection**: `$OSTYPE` variable used for platform-specific configuration
3. **Option management**: Arrays like `enables`, `disables`, `availables` control feature flags
4. **Dependency declaration**: `dependency` function declares package dependencies
5. **Source fetching**: `enter_archive` or `enter_git_repository` downloads source
6. **Build execution**: `build_and_install` with build system (configure, meson, cmake)

### Recipe Example Analysis (SDL2)
The SDL2 recipe (`sdl2_2.28.5+2`) demonstrates the typical structure:
- Defines available features in `availables` array (video, audio, joystick, etc.)
- Sets platform-specific defaults based on `$OSTYPE` 
- Processes command-line options to enable/disable features
- Handles cross-platform differences (Windows path fixes, Linux X11/Wayland requirements)
- Downloads source via `enter_archive` from GitHub releases
- Builds using autotools `configure` with generated option flags

Note: it is better to define disabled features *implicitly* as those feature that appears in `availables` but are not explicitly enabled.

### Option Processing Pattern
Recipes use a consistent pattern for feature management:
```bash
# Define available options
availables=(feature1 feature2 feature3)
enables=(default_feature)
# All available features not in `enables` will be disabled

# Process command line arguments
while [ ! -z ${1+x} ]; do
    case $1 in
    -feature1) enables+=(feature1) ;;
    -feature2) dependency some_lib; enables+=(feature2) ;;
    esac
    shift
done

# Convert to build system flags
for name in "${enables[@]}"; do
    options+=("--enable-$name")
done
```

### Recipe Option Design Principles

#### What Should Be an Option
Options should represent **functional capabilities** that add features to the library:
- **Feature flags**: video, audio, joystick, haptic, sensor (e.g., `-video`, `-audio`)
- **Backend choices**: x11, wayland, directx, cocoa (e.g., `-x11`, `-wayland`)
- **Optional components**: tests, examples, documentation (e.g., `-tests`, `-examples`)
- **Protocol support**: dbus, ibus, fcitx (e.g., `-dbus`, `-ibus`)

#### What Should NOT Be an Option
Technical implementation details should be decided internally based on platform:
- **Build optimizations**: assembly, SIMD instructions (SSE, AVX, NEON)
- **Linker settings**: rpath, symbol visibility
- **Platform-specific features**: clock-gettime, libc usage
- **Compiler flags**: optimization levels, debug symbols
- **Tests**: are normally skipped. It is not an option because tests does not *augment* the library features.

These should be automatically configured based on `$OSTYPE` and CPU architecture as defined by the environment variables CPU_TYPE and CPU_TARGET.

#### Library Build Type Defaults
- **Default**: Build **static library only** (`enables=(static)` if the build system treat it as an option)
- **Shared option**: `-shared` builds **shared library only** (removes static from enables)
- **Never use**: `-static` option (redundant since static is the default)

Example:
```bash
# Default behavior
enables=(static video pthreads)  # Builds static library

# With -shared option
-shared)
    enables+=(shared)
    # Remove static from enables
    enables=("${enables[@]/static}")
    ;;
```

#### Option Addition Principle
Options should **add capabilities** to make the library more functional:
- Each option enables additional features or backends
- Without the option, the library has fewer capabilities
- Example: `-audio` adds audio subsystem, `-joystick` adds joystick support
- Additional programs like demos or examples

Exceptions may exist for:
- Mutually exclusive backends (e.g., choosing between x11 and wayland)
- Build type selection (shared vs static).
  In this case we may stretch the rule and say that a shared library is more *capable* than a static one.

## Options treated by the build system

Some options like `-shared`, `-pic` and `-prefix` are directly treated by the build system and should be passed to the build function in the `options` array.
However the recipe may do additional non-standard configurations in response to one of such options.

## Build System Integration
- **Autotools**: Most common, uses `build_and_install configure "${options[@]}"`
- **Meson**: Used for modern packages like GTK-4, uses `build_and_install meson "${options[@]}"`
- **CMake**: For packages requiring CMake

## Platform Support
Recipes support multiple platforms via `$OSTYPE` detection:
- **Linux**: `linux*` - X11/Wayland video, PulseAudio, system libraries
- **Windows**: `msys*|mingw*|cygwin*` - DirectX, WASAPI, Windows-specific patches
- **macOS**: `darwin*` - Cocoa, Metal, Core Audio

## Dependencies and Package Index
- `index` file contains authoritative package list with versions
- Dependencies declared with `dependency package_name [options]`
- Package options passed as space-separated flags (e.g., `dependency cairo -zlib -glib -fontconfig`)

## Common Commands
- **Test a recipe**: Create a `.lhelper` build script and run with lhelper
- **Build with dependencies**: lhelper resolves and builds dependency chain automatically
- **Cross-platform builds**: Use Docker containers in `dockerfiles/` directory

## Docker Development Environment
Multiple Dockerfiles provided for different environments:
- `Dockerfile.debx11`: Basic Debian with X11 support
- `dockerfiles/Dockerfile.ubuntu-gtk`: Ubuntu with GTK development tools
- Build: `docker build -t name -f Dockerfile.x path`
- Run with X11: `docker run -it -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix name`

## Recipe Naming Convention
- Simple recipes: `package_version` (e.g., `zlib_1.2.11+5`)
- Patch level indicated by `+N` suffix
- Test/development recipes: `build-*.lhelper` format
- Recipe files are executable bash scripts without `.sh` extension

## Code Style
- Bash scripts use 2-space indentation
- Variables use UPPER_CASE for constants, lowercase for local variables
- Function naming uses snake_case
- Quote all variable expansions in scripts
- Maintain consistent header structure in recipe files
