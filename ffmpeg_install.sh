#!/bin/bash

<< comment
Instalación de ffmpeg
Script para instalar ffmpeg desde código fuente, instalando, además, las dependencias necesarias.
Se debe correr como root o ingresar credenciales de sudo durante la ejecución
comment

: '
Al final de la instalación, los archivos ejecutables estarán en la ruta:
/home/potro/bin
'

### Variables
path_dir="/home/$USER/Downloads/__For_Install/Packages/Sources/FFMPEG"
sources_path=$path_dir"/current_version"
logs_path=$path_dir"/logs"
install="sudo dnf install -y "
log_name="Installation_errors"
log_date=$(date +%y%m%d-%H%M)
log_full_path=$logs_path/$log_name.$log_date
install_error=0


### Functions
function salir {
	popd 1> /dev/null
	echo
	echo Exiting the program ...
	echo
	exit
}

function install_app {
	app_name=$1; echo "*************** Installing \"$app_name\" ***************"
	echo
	$install $1; error=$( echo $? )
	if [[ $error -ne 0 ]]; then install_error=1
	    echo; echo "ERRORS found when installing \"$app_name\""; echo; echo
	    echo >> $log_full_path; echo "ERRORS found when installing \"$app_name\"" >> $log_full_path; echo >> $log_full_path; echo >> $log_full_path
	fi
    echo; echo
}


### Begin
if [[ !$sources_path ]]; then
    mkdir -p $sources_path
fi

pushd "$sources_path" 1> /dev/null

echo -e "\t\t\t\tInstalliing FFmpeg\n"
<< comment
# Installing needed dependencies
echo; echo; echo; echo "*************** Installing needed dependencies ***************"; echo; echo
dependencies="autoconf automake bzip2 bzip2-devel cmake gcc gcc-c++ git libtool make nasm pkgconfig zlib-devel libass-devel dirac-devel faac-devel lame-devel opencv-devel openjpeg-devel  gsm-devel  xvidcore-devel"

for app in $dependencies; do
     install_app $app
done


# NASM - An assembler used by some libraries. Highly recommended or your resulting build may be very slow.
echo; echo; echo; echo "*************** Installing 'NASM' ***************"; echo
cd $sources_path
curl -O -L https://www.nasm.us/pub/nasm/releasebuilds/2.15.05/nasm-2.15.05.tar.bz2
tar xjvf nasm-2.15.05.tar.bz2
cd nasm-2.15.05
./autogen.sh
./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin"
make
sudo make install


# Yasm - is an assembler used by x264 and FFmpeg
echo; echo; echo; echo "*************** Installing 'Yasm' ***************"; echo
cd $sources_path
curl -O http://www.tortall.net/projects/yasm/releases/yasm-1.3.0.tar.gz
# if ver 1.3.0 does not work, try 1.2.0
tar xzvf yasm-1.3.0.tar.gz
cd yasm-1.3.0
./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin"
make
sudo make install
make distclean
. ~/.bash_profile


# x264 - H.264 is a video encoder.
echo; echo; echo; echo "*************** Installing 'x264' ***************"; echo
cd $sources_path
if [[ -d "x264" ]]; then
    rm -fr "x264"
fi
git clone --branch stable --depth 1 https://code.videolan.org/videolan/x264.git     # si marca algún problema, dejarlo, ya está la versión de la distro
cd x264
PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig"
./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" --enable-static
# Agregar las opciones --enable-gpl --enable-libx264 en ffmpeg .configure
make
sudo make install
make distclean


# libx265 - H.265/HEVC video encoder.
echo; echo; echo; echo "*************** Installing 'x265' ***************"; echo
cd $sources_path
git clone --branch stable --depth 2 https://bitbucket.org/multicoreware/x265_git
cd $sources_path/x265_git/build/linux
cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$HOME/ffmpeg_build" -DENABLE_SHARED:bool=off ../../source
# Agregar las opciones --enable-gpl --enable-libx265 en ffmpeg .configure
make
sudo make install


# libfdk_aac - AAC is an audio encoder.
echo; echo; echo; echo "*************** Installing 'libfdk_aac' ***************"; echo
cd $sources_path
git clone --depth 1 git://github.com/mstorsjo/fdk-aac.git
cd fdk-aac
autoreconf -fiv
./configure --prefix="$HOME/ffmpeg_build" --disable-shared
# Agregar las opciones --enable-gpl --enable-nonfree --enable-libfdk_aac en ffmpeg .configure
make
sudo make install
make distclean


# libmp3lame - is an MP3 audio encoder.
echo; echo; echo; echo "*************** Installing 'libmp3lame' ***************"; echo
cd $sources_path
curl -L -O https://sourceforge.net/projects/lame/files/lame/3.100/lame-3.100.tar.gz     # if ver 3.100 does not work, try 3.99
tar xzvf lame-3.100.tar.gz
cd lame-3.100
./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" --disable-shared --enable-nasm
# Agregar las opciones --enable-libmp3lame en ffmpeg .configure
make
sudo make install
make distclean


# libopus - Opus audio decoder and encoder.
echo; echo; echo; echo "*************** Installing 'libopus' ***************"; echo
cd $sources_path
wget http://downloads.xiph.org/releases/opus/opus-1.3.1.tar.gz    # if ver 1.3.1 does not work, try 1.0.3
tar xzvf opus-1.3.1.tar.gz
cd opus-1.3.1
#./configure --prefix="$HOME/ffmpeg_build" --disable-shared
./configure --prefix="$HOME/ffmpeg_build" --enable-shared
make
sudo make install
make distclean


# libogg - Ogg bitstream library. Required by libtheora and libvorbis.
echo; echo; echo; echo "*************** Installing 'libogg' ***************"; echo
cd $sources_path
wget http://downloads.xiph.org/releases/ogg/libogg-1.3.5.tar.gz   # if ver 1.3.5 does not work, try 1.3.1
tar xzvf libogg-1.3.5.tar.gz
cd libogg-1.3.5
./configure --prefix="$HOME/ffmpeg_build" --disable-shared
make
sudo make install
make distclean


# libvorbis - Vorbis audio encoder. Requires libogg.
echo; echo; echo; echo "*************** Installing 'libvorbis' ***************"; echo
cd $sources_path
wget http://downloads.xiph.org/releases/vorbis/libvorbis-1.3.7.tar.gz     # if ver 1.3.7 does not work, try 1.3.3
tar xzvf libvorbis-1.3.7.tar.gz
cd libvorbis-1.3.7
./configure --prefix="$HOME/ffmpeg_build" --with-ogg="$HOME/ffmpeg_build" --disable-shared
make
sudo make install
make distclean


# libvpx - VP8/VP9 video encoder.
echo; echo; echo; echo "*************** Installing 'libvpx' ***************"; echo
cd $sources_path
git clone --depth 1 https://chromium.googlesource.com/webm/libvpx
cd libvpx
./configure --prefix="$HOME/ffmpeg_build" --disable-examples
make
sudo make install
make clean


# libfreetype - Font rendering library. Required for the drawtext video filter.
#echo; echo; echo; echo "*************** Installing 'libfreetype' ***************"; echo
echo; echo; install_app freetype-devel
# Add --enable-libfreetype to your ffmpeg ./configure.


# libspeex - Speex audio decoder and encoder.
#echo; echo; echo; echo "*************** Installing 'speex-devel' ***************"; echo
install_app speex-devel
# Add --enable-libspeex to your ffmpeg ./configure.


# libtheora - Theora video encoder. Requires libogg.
echo; echo "*************** Installing 'libtheora' ***************"; echo
cd $sources_path
wget http://downloads.xiph.org/releases/theora/libtheora-1.1.1.tar.gz
tar xzvf libtheora-1.1.1.tar.gz
cd libtheora-1.1.1
./configure --prefix="$HOME/ffmpeg_build" --with-ogg="$HOME/ffmpeg_build" --disable-examples --disable-shared --disable-sdltest --disable-vorbistest
make
sudo make install
make distclean
# Add --enable-libtheora to your ffmpeg ./configure.
comment

if [[ $install_error -eq 1 ]]; then
    echo; echo; echo
    printf '*%.0s' {1..105}; echo
    echo "There were errors when installing some apps"
    echo "Please check the file \"$log_full_path\" for details"
    printf '*%.0s' {1..105}; echo
fi
salir


# FFmpeg
echo; echo; echo; echo "*************** Installing 'FFmpeg' ***************"; echo
cd $sources_path
if [[ -d "ffmpeg" ]]; then
    rm -fr "ffmpeg"
fi
git clone --depth 1 git://source.ffmpeg.org/ffmpeg
cd ffmpeg
#### ejecutar ./configure --help para ver que nuevas opciones se tienen de configurar.
PATH="$HOME/bin:$PATH" PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" \
./configure \
  --prefix="$HOME/ffmpeg_build" \
  --pkg-config-flags="--static" \
  --extra-cflags="-I$HOME/ffmpeg_build/include" \
  --extra-ldflags="-L$HOME/ffmpeg_build/lib" \
  --extra-libs=-lpthread \
  --extra-libs=-lm \
  --bindir="$HOME/bin" \
  --enable-gpl \
  --enable-libfdk_aac \
  --enable-libfreetype \
  --enable-libmp3lame \
  --enable-libopus \
  --enable-libvpx \
  --enable-libx264 \
  --enable-libx265 \
  --enable-nonfree
#PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig"
#export PKG_CONFIG_PATH
#./configure --prefix="$HOME/ffmpeg_build" --extra-cflags="-I$HOME/ffmpeg_build/include" --extra-ldflags="-L$HOME/ffmpeg_build/lib" --bindir="$HOME/bin" --extra-libs="-ldl" --enable-gpl --enable-nonfree --enable-libfdk_aac --enable-libmp3lame --enable-libopus --enable-libvorbis --enable-libvpx --enable-libx264 --enable-libfreetype --enable-libspeex --enable-libtheora
make
sudo make install
make distclean
hash -d ffmpeg
#hash -r
. ~/.bash_profile

<< comment
Updating
rm -rf ~/ffmpeg_build ~/bin/{ffmpeg,ffprobe,ffserver,lame,vsyasm,x264,yasm,ytasm}
# yum install autoconf automake gcc gcc-c++ git libtool make nasm pkgconfig zlib-devel

Update x264
cd path/to/ffmpeg_sources/x264
make distclean
git pull
# Then run ./configure, make, and make install as shown in the Install x264 section.

Update libfdk_aac
cd path/to/ffmpeg_sources/libfdk_aac
make distclean
git pull
# Then run ./configure, make, and make install as shown in the Install libfdk_aac section.

Update libvpx
cd path/to/ffmpeg_sources/libvpx
make clean
git pull
# Then run ./configure, make, and make install as shown in the Install libvpx section.

Update FFmpeg
cd path/to/ffmpeg_sources/ffmpeg
make distclean
git pull
# Then run ./configure, make, and make install as shown in the Install FFmpeg section
comment