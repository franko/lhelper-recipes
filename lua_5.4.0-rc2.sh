enter_git_repository lua https://github.com/franko/lua.git "v$2"

# Currently the shared and static library are always both compiled
# and the lua executable is linked to the shared library.
build_and_install meson "${@:3}"
