version="$2"
enter_remote_archive "zlib-${version}" "https://www.zlib.net/zlib-${version}.tar.gz" "zlib-${version}.tar.gz" "tar xf ARCHIVE_FILENAME"

use_static="yes"
while [ ! -z ${3+x} ]; do
    case $3 in
        -shared)
            use_static="no"
            ;;
        -pic)
            CFLAGS+=" -fPIC"
            ;;
        *)
            echo "error: unknown option \"$3\" in package recipe"
            exit 1
            ;;
    esac
    shift
done
zlib_options=("--prefix" "$INSTALL_PREFIX")
if [[ "$use_static" == "yes" ]]; then
    zlib_options+=("--static")
fi
add_build_type_compiler_flags "$BUILD_TYPE"

./configure "${zlib_options[@]}"
make
make install
