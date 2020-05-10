check_commands make gcc

# Options in the array below will be disabled unless they are
# explicitly enabled.
availables=( \
    video render audio joystick haptic hidapi sensor power \
    filesystem threads timers file cpuinfo)

# Problem: when loadso is not activated, like below, when compiling
# using "sdl2-config" --libs to link we get the error:
# libSDL2.a(SDL_dynapi.o): undefined reference to symbol 'dlopen@@GLIBC_2.1'
# The problem is the option -ldl is required but not included by sdl2-config.
#
# In addition, when using an OPENGL window, if the loadso is not available
# the following error is given at runtime:
#
# Could not create window: Failed loading libGL.so.1: SDL_LoadObject() not implemented
#
# We activate therefore the loadso module as it seems required for opengl.

# By default we build video, render and events modules
enables=(video render events loadso sdl2-config)

disables=(atomic dbus ibus ime fcitx input-tslib)
audio_disables=(arts nas sndio fusionsound diskaudio dummyaudio libsamplerate)
video_disables=(video-{directfb,dummy,opengles,opengles1,opengles2,vivante})
if [[ "$OSTYPE" == "linux"* ]]; then
    os_audio_enables=(pulseaudio)
    os_audio_disables=(oss esd "${audio_disables[@]}")
    enables+=(video-{x11,opengl} video-x11-{xcursor,xrandr})
    disables+=(
        "${video_disables[@]}" video-vulkan render-metal \
        video-{metal,wayland} \
        video-x11-{xdbe,xinerama,scrnsaver,xshape,vm})
elif [[ "$OSTYPE" == "msys"* || "$OSTYPE" == "mingw"* ]]; then
    os_audio_enables=(wasapi)
    os_audio_disables=("${audio_disables[@]}")
    enables+=(directx render-d3d)
    disables+=("${video_disables[@]}")
elif [[ "$OSTYPE" == "darwin"* ]]; then
    enables+=(cocoa video-metal render-metal)
    disables+=("${video_disables[@]}")
fi

# TODO: handle options for other modules like haptic and others.
options=()
while [ ! -z ${3+x} ]; do
    case $3 in
    -audio)
        enables+=(audio "${os_audio_enables[@]}")
        disables+=("${os_audio_disables[@]}")
        ;;
    -threads)
        enables+=(threads)
        ;;
    -joystick)
        enables+=(joystick)
        ;;
    -filesystem)
        enables+=(filesystem)
        ;;            
    *)
        options+=("$3")
        ;;
    esac
    shift
done

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

SDL_ARCHIVE_NAME=SDL2-"$2"
enter_remote_archive "$SDL_ARCHIVE_NAME" "http://libsdl.org/release/${SDL_ARCHIVE_NAME}.tar.gz" "${SDL_ARCHIVE_NAME}.tar.gz" "tar xzf ARCHIVE_FILENAME"
build_and_install configure "${options[@]}"
