FROM ubuntu:22.04

RUN mkdir -p /tmp/ffmpeg-vmaf

WORKDIR /tmp/ffmpeg-vmaf

# install dependencies
RUN apt update && \
    apt install -y python3 python3-pip nasm ninja-build doxygen xxd git \ 
    nasm libx264-dev libx265-dev libnuma-dev libvpx-dev libfdk-aac-dev libgnutls28-dev \
    libopus-dev libcurl4-gnutls-dev libaom-dev libass-dev libvorbis-dev libvpx-dev libx265-dev libx264-dev && \
    pip3 install meson

# build and install libvmaf
RUN git clone https://github.com/Netflix/vmaf.git && \
    cd vmaf/libvmaf/ && \
    meson setup build -Denable_avx512=true --buildtype release && \
    ninja -vC build && \
    ninja -vC build install

# build and install ffmpeg
RUN git clone https://github.com/FFmpeg/FFmpeg.git ffmpeg && \
    cd ffmpeg && \
    ./configure --enable-nonfree --enable-gpl \
    --enable-gnutls \
    --enable-libaom \
    --enable-libass \
    --enable-libfdk-aac \
    --enable-libfreetype \
    --enable-libopus \
    --enable-libvorbis \
    --enable-libvpx \
    --enable-libx264 \
    --enable-libx265 \
    --enable-nonfree \
    --enable-libvmaf  && \
    make -j $(nproc) && \
    make install
