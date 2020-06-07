version="$2"
shift 2
enter_remote_archive "Python-${version}" "https://www.python.org/ftp/python/3.8.3/Python-${version}.tgz" "$Python-${version}.tar.gz" "tar xf ARCHIVE_FILENAME"
build_and_install configure "$@"

