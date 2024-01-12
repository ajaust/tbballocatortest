FROM alpine:latest
RUN apk --no-cache add \
    boost-dev \
    g++ \
    gcc \
    make \
    cmake \
    git \
    binutils \
    perf \
    valgrind
#FROM ubuntu:latest
#RUN apt upgrade && apt update && apt install -y \
#    libboost-dev \
#    g++ \
#    gcc \
#    make \
#    cmake \
#    git \
#    && apt clean
#ENV LD_LIBRARY_PATH=/usr/local/lib:${LD_LIBRARY_PATH}


WORKDIR /
RUN git clone https://github.com/oneapi-src/oneTBB.git
WORKDIR /oneTBB
RUN git checkout v2021.10.0
RUN cmake -S . -B build -DTBB_TEST=OFF
RUN cmake --build build   --config Release  --target install  -j 8 --verbose

WORKDIR /src/tbb_allocator
COPY . .
ARG CXXFLAGS="-O0 -DNDEBUG"
RUN CXXFLAGS=$CXXFLAGS make -j2

ENTRYPOINT ["/bin/sh", "-c" , "/src/tbb_allocator/simple && sleep 5 && /src/tbb_allocator/tbb_allocator"]
