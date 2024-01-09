FROM golang:1.20-alpine3.16
RUN apk --no-cache add \
    boost-dev \
    g++ \
    gcc \
    make \
    cmake \
    git

WORKDIR /
RUN git clone https://github.com/oneapi-src/oneTBB.git
WORKDIR /oneTBB
RUN git checkout v2021.10.0
RUN cmake -S . -B build -DTBB_TEST=OFF
RUN cmake --build build   --config Release  --target install  -j 8 --verbose

WORKDIR /src
WORKDIR /src/tbb_allocator
COPY . .
RUN g++ mainsimple.cpp -o simple.out -ltbb
RUN g++ mainallocator.cpp -o tbb_allocator.out -ltbb

ENTRYPOINT ["/bin/sh", "-c" , "/src/tbb_allocator/simple.out && sleep 5 && /src/tbb_allocator/tbb_allocator.out"]
