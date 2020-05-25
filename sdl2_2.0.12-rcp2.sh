package=$1
version=${2%-rcp*}
shift 2

check_commands make gcc

# Options in the array below will be disabled unless they are
# explicitly enabled.
availables=( \
    video video-opengl loadso render audio joystick haptic hidapi sensor power \
    filesystem threads timers file cpuinfo)

# Notes about the activation of loadso
#
# When loadso is not activated, when compiling
# using "sdl2-config" --libs to link we get the error:
# libSDL2.a(SDL_dynapi.o): undefined reference to symbol 'dlopen@@GLIBC_2.1'
# The problem is the option -ldl is required but not included by sdl2-config.
#
# In addition, when using an OPENGL window, if the loadso is not available
# the following error is given at runtime:
#
# Could not create window: Failed loading libGL.so.1: SDL_LoadObject() not implemented
#
# We activate therefore the loadso module when opengl is enabled.

# By default we build video, render and events modules
enables=(video render events sdl2-config)

needs_loadso=no

disables=(atomic dbus ibus ime fcitx input-tslib render-metal)
audio_disables=(jack arts nas sndio fusionsound diskaudio dummyaudio libsamplerate)
video_disables=(video-{vulkan,metal,directfb,dummy,opengles,opengles1,opengles2,vivante})
if [[ "$OSTYPE" == "linux"* ]]; then
    os_audio_enables=(pulseaudio)
    os_audio_disables=(oss esd "${audio_disables[@]}")
    enables+=(video-x11 video-x11-{xcursor,xrandr})
    disables+=(
        "${video_disables[@]}" video-wayland \
        video-x11-{xdbe,xinerama,scrnsaver,xshape,vm})
elif [[ "$OSTYPE" == "msys"* || "$OSTYPE" == "mingw"* ]]; then
    os_audio_enables=(wasapi)
    os_audio_disables=("${audio_disables[@]}")
    # On windows the default video driver is directx but windib will
    # be used if directx is disabled. Windib is based on GDI32 and doesn't
    # need to be explicitly enabled with configure.
    disables+=(directx render-d3d "${video_disables[@]}")
elif [[ "$OSTYPE" == "darwin"* ]]; then
    enables+=(cocoa)
    disables+=("${video_disables[@]}")
fi

options=()
while [ ! -z ${1+x} ]; do
    case $1 in
    -audio)
        enables+=(audio "${os_audio_enables[@]}")
        disables+=("${os_audio_disables[@]}")
        ;;
    -opengl)
        enables+=(video-opengl)
        needs_loadso=yes
        ;;
    -threads)
        enables+=(threads)
        ;;
    -joystick)
        enables+=(joystick)
        ;;
    -loadso)
        needs_loadso=yes
        ;;
    -filesystem)
        enables+=(filesystem)
        ;;
    -file)
        enables+=(file)
        ;;
    -threads)
        enables+=(threads)
        ;;
    -cpuinfo)
        enables+=(cpuinfo)
        ;;
    -timers)
	enables+=(timers)
	;;
    *)
        options+=("$1")
        ;;
    esac
    shift
done

if [[ $needs_loadso == yes ]]; then
    enables+=(loadso)
fi

all_enables="${enables[*]}"
for opt in "${availables[@]}"; do
    if [[ " $all_enables " != *" $opt "* ]]; then
        disables+=("$opt")
    fi
done

for name in "${enables[@]}"; do
    options+=("--enable-$name")
done
for name in "${disables[@]}"; do
    options+=("--disable-$name")
done

SDL_ARCHIVE_NAME="SDL2-$version"
enter_remote_archive "$SDL_ARCHIVE_NAME" "http://libsdl.org/release/${SDL_ARCHIVE_NAME}.tar.gz" "${SDL_ARCHIVE_NAME}.tar.gz" "tar xzf ARCHIVE_FILENAME"
build_and_install configure "${options[@]}"