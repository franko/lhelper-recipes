version="${2%-netlib*}"
enter_remote_archive "BLAS-${version}" "http://www.netlib.org/blas/blas-${version}.tgz" "blas-${version}.tar.gz" "tar xf ARCHIVE_FILENAME"
options=()
while [ ! -z ${3+x} ]; do
    case $3 in
        -shared)
            echo "error: -shared option not supported"
            exit 1
            ;;
        -pic)
            options+=("-fPIC")
            ;;
        *)
            echo "error: unknown option \"$3\" in package recipe"
            exit 1
            ;;
    esac
    shift
done
if [[ "${BUILD_TYPE,,}" == "release" ]]; then
    options+=("-O3")
else
    options+=("-g")
fi
echo "using make command: " make "OPTS=${options[*]}" "BLASLIB=libblas.a" double complex16

make OPTS="${options[*]}" BLASLIB="libblas.a" double complex16


mkdir -p "${INSTALL_PREFIX}/lib"
cp libblas.a "${INSTALL_PREFIX}/lib"
pkgname=blas

# Warning, since the 'EOF' below in unquoted shell variables substitutions
# will be done on the text body. The '$' should be therefore escaped to
# avoid shell substitution when needed.
cat << EOF > "${pkgname}.pc"
prefix=${WIN_INSTALL_PREFIX}

Name: Blas
Description: Netlib BLAS library
Version: ${version}
Libs: -L\${prefix}/lib -lblas
Cflags: 
EOF

install_pkgconfig_file "${pkgname}.pc"
