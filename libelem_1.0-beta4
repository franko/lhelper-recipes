enter_git_repository elementary-plotlib https://github.com/franko/elementary-plotlib.git "v$2"

options=("-Dfox=false" "-Dlua=false" "-Dtests=false")
while [ ! -z ${3+x} ]; do
    case $3 in
        -fox)
            options[0]="-Dfox=true"
            ;;
	-lua)
	    options[1]="-Dlua=true"
	    ;;
	*)
	    options+=("$3")
    esac
    shift
done

build_and_install meson "${options[@]}"
