# tbballocatortest

## VM
Virtual machine (Azure through ML studio): Standard_D16as_v4 (16 cores, 64 GB RAM, 128 GB disk)

## Run1: no points.reserve()

```
No tbb allocator
Local sum 78720 computed in 268 seconds
Local sum 78200 computed in 269 seconds
Local sum 76930 computed in 269 seconds
Local sum 77243 computed in 271 seconds
Local sum 78634 computed in 271 seconds
Local sum 77385 computed in 271 seconds
Local sum 78882 computed in 271 seconds
Local sum 78000 computed in 271 seconds
Call took = 271[s]
TBB allocator!
Local sum 78527 computed in 45 seconds
Local sum 78839 computed in 45 seconds
Local sum 76330 computed in 46 seconds
Local sum 79747 computed in 46 seconds
Local sum 78872 computed in 49 seconds
Local sum 79815 computed in 49 seconds
Local sum 77998 computed in 49 seconds
Local sum 77575 computed in 49 seconds
Call took = 49[s]
```

## Run2: with points.reserve()

```
No tbb allocator
Local sum 77444 computed in 47 seconds
Local sum 78653 computed in 48 seconds
Local sum 77544 computed in 48 seconds
Local sum 78229 computed in 48 seconds
Local sum 77038 computed in 49 seconds
Local sum 76882 computed in 50 seconds
Local sum 78597 computed in 50 seconds
Local sum 78471 computed in 50 seconds
Call took = 50[s]
TBB allocator!
Local sum 78947 computed in 38 seconds
Local sum 79234 computed in 38 seconds
Local sum 78036 computed in 38 seconds
Local sum 78613 computed in 40 seconds
Local sum 77467 computed in 40 seconds
Local sum 78484 computed in 40 seconds
Local sum 77725 computed in 41 seconds
Local sum 76165 computed in 41 seconds
Call took = 41[s]
```

## Additional info

Code runs 25000000 iterations divided into 8 threads (total 16 vCPU). Each thread performs some calculations and outputs result and time. Threading itself is done through oneTBB library.


diff.txt shows the whole difference between two implementations.

Reference CPU/RAM snapshot for no TBB allocator with no vector.reserve():

```
%Cpu0  :  2.0 us,  4.3 sy,  0.0 ni, 91.7 id,  0.0 wa,  0.0 hi,  2.0 si,  0.0 st
%Cpu1  : 12.9 us, 32.2 sy,  0.0 ni, 54.9 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
%Cpu2  :  0.0 us,  0.3 sy,  0.0 ni, 99.3 id,  0.3 wa,  0.0 hi,  0.0 si,  0.0 st
%Cpu3  : 30.7 us, 58.7 sy,  0.0 ni, 10.2 id,  0.4 wa,  0.0 hi,  0.0 si,  0.0 st
%Cpu4  :  4.4 us,  8.4 sy,  0.0 ni, 87.2 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
%Cpu5  : 24.4 us, 57.1 sy,  0.0 ni, 18.4 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
%Cpu6  : 28.0 us, 58.4 sy,  0.0 ni, 13.6 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
%Cpu7  :  1.0 us,  1.3 sy, 20.2 ni, 75.5 id,  2.0 wa,  0.0 hi,  0.0 si,  0.0 st
%Cpu8  : 13.1 us, 25.2 sy,  0.0 ni, 61.7 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
%Cpu9  : 15.9 us, 35.5 sy,  0.0 ni, 48.6 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
%Cpu10 :  3.4 us,  9.3 sy,  0.0 ni, 87.3 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
%Cpu11 : 22.2 us, 57.9 sy,  0.0 ni, 19.9 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
%Cpu12 : 21.3 us, 44.1 sy,  0.0 ni, 34.6 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
%Cpu13 :  6.8 us, 10.9 sy,  0.0 ni, 82.3 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
%Cpu14 : 12.2 us, 29.4 sy,  0.0 ni, 58.4 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
%Cpu15 : 20.2 us, 46.4 sy,  0.0 ni, 33.3 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
MiB Mem :  64408.6 total,  49888.8 free,   5617.8 used,   8902.0 buff/cache
MiB Swap:  62500.0 total,  62487.7 free,     12.3 used.  58148.4 avail Mem
```

Reference CPU/RAM snapshot for no TBB allocator with vector.reserve():

```
%Cpu0  : 72.7 us,  5.5 sy,  0.0 ni, 20.8 id,  1.0 wa,  0.0 hi,  0.0 si,  0.0 st
%Cpu1  : 23.6 us,  1.7 sy,  3.7 ni, 70.7 id,  0.0 wa,  0.0 hi,  0.3 si,  0.0 st
%Cpu2  : 37.0 us,  3.3 sy,  0.0 ni, 59.0 id,  0.7 wa,  0.0 hi,  0.0 si,  0.0 st
%Cpu3  : 60.3 us,  4.4 sy,  3.7 ni, 31.2 id,  0.3 wa,  0.0 hi,  0.0 si,  0.0 st
%Cpu4  : 51.4 us,  4.4 sy,  0.0 ni, 44.3 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
%Cpu5  : 48.1 us,  4.7 sy,  8.4 ni, 37.4 id,  1.3 wa,  0.0 hi,  0.0 si,  0.0 st
%Cpu6  : 42.3 us,  4.0 sy,  0.0 ni, 53.7 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
%Cpu7  : 50.0 us,  3.7 sy,  0.0 ni, 46.3 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
%Cpu8  : 24.8 us,  3.7 sy,  0.0 ni, 71.5 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
%Cpu9  : 62.2 us,  6.1 sy,  3.1 ni, 28.2 id,  0.3 wa,  0.0 hi,  0.0 si,  0.0 st
%Cpu10 : 28.6 us,  2.4 sy,  0.0 ni, 69.0 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
%Cpu11 : 45.9 us,  4.1 sy,  0.0 ni, 50.0 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
%Cpu12 : 32.2 us,  3.7 sy,  0.0 ni, 64.1 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
%Cpu13 : 59.2 us,  5.4 sy,  0.0 ni, 35.4 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
%Cpu14 : 89.9 us,  5.7 sy,  0.0 ni,  4.4 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
%Cpu15 :  3.4 us,  1.0 sy,  0.0 ni, 95.6 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
MiB Mem :  64408.6 total,  50080.7 free,   5551.7 used,   8776.2 buff/cache
MiB Swap:  62500.0 total,  62487.7 free,     12.3 used.  58214.1 avail Mem
```

Reference CPU/RAM snapshot with TBB allocator:

```
%Cpu0  :  5.4 us,  1.0 sy, 11.1 ni, 78.9 id,  3.4 wa,  0.0 hi,  0.3 si,  0.0 st
%Cpu1  : 95.4 us,  0.0 sy,  0.0 ni,  4.6 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
%Cpu2  : 99.0 us,  0.0 sy,  0.0 ni,  1.0 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
%Cpu3  :  1.3 us,  1.0 sy,  8.0 ni, 88.0 id,  1.7 wa,  0.0 hi,  0.0 si,  0.0 st
%Cpu4  : 57.0 us,  0.7 sy,  0.0 ni, 42.4 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
%Cpu5  : 43.5 us,  0.7 sy,  0.0 ni, 46.2 id,  9.7 wa,  0.0 hi,  0.0 si,  0.0 st
%Cpu6  : 33.2 us,  0.0 sy,  0.0 ni, 66.8 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
%Cpu7  : 68.1 us,  1.7 sy,  0.0 ni, 28.6 id,  1.7 wa,  0.0 hi,  0.0 si,  0.0 st
%Cpu8  :  0.7 us,  2.3 sy,  0.0 ni, 95.4 id,  1.7 wa,  0.0 hi,  0.0 si,  0.0 st
%Cpu9  :100.0 us,  0.0 sy,  0.0 ni,  0.0 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
%Cpu10 : 64.0 us,  0.0 sy,  0.0 ni, 36.0 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
%Cpu11 : 36.7 us,  2.3 sy,  0.0 ni, 60.3 id,  0.7 wa,  0.0 hi,  0.0 si,  0.0 st
%Cpu12 : 17.8 us,  2.3 sy,  0.0 ni, 78.2 id,  1.7 wa,  0.0 hi,  0.0 si,  0.0 st
%Cpu13 : 82.7 us,  0.3 sy,  0.0 ni, 16.9 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
%Cpu14 :  1.6 us,  3.6 sy,  0.0 ni, 93.1 id,  1.3 wa,  0.0 hi,  0.3 si,  0.0 st
%Cpu15 :100.0 us,  0.0 sy,  0.0 ni,  0.0 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
MiB Mem :  64408.6 total,  50224.3 free,   5447.1 used,   8737.2 buff/cache
MiB Swap:  62500.0 total,  62487.7 free,     12.3 used.  58326.4 avail Mem
```
