---
title: Testing time needed for memory allocations
---

## Thread-safety of `std::rand`

Both, `glibc` and `musl libc`, appear to have a thread-safe implementation of
`rand`. This affects the results of the test since the majority of the
execution time might be spent in locking and unlocking the mutex.

Note, that there is a random number generator called `rand_r` for
multi-threaded environments. However, it seems to be badly designed and is
rarely implemented, see [note in glibc
documentation](https://www.gnu.org/software/libc/manual/html_node/ISO-Random.html).

### glibc

Method `rand` calls `__random`
```c
int
rand (void)
{
  return (int) __random ();
}
```

[Source](https://sourceware.org/git/?p=glibc.git;a=blob;f=stdlib/rand.c;h=30caa49e21cc6644bba68ef63b51b68813a4b1ff;hb=HEAD)

which seems to be a thread-safe call to `__random_r`

```c
long int
__random (void)
{
  int32_t retval;

  __libc_lock_lock (lock);

  (void) __random_r (&unsafe_state, &retval);

  __libc_lock_unlock (lock);

  return retval;
}
```

[Source](https://sourceware.org/git/?p=glibc.git;a=blob;f=stdlib/random.c;h=6da39d45a347ca90078da85582e9a231378e79cd;hb=HEAD#l286)

### musl libc

[musl libc git repository](https://git.musl-libc.org/cgit/musl)


The function call to `random` uses a lock

```c
long random(void) {
    long k;

    LOCK(lock);
    if (n == 0) {
        k = x[0] = lcg31(x[0]);
        goto end;
    }
    x[i] += x[j];
    k = x[i]>>1;
    if (++i == n)
        i = 0;
    if (++j == n)
        j = 0;
end:
    UNLOCK(lock);
    return k;
}
```

[Source](https://git.musl-libc.org/cgit/musl/tree/src/prng/random.c)


## Runtime results

Ubuntu is a `glibc` based operating system while Alpine uses `musl libc`. The
reported times are in **milliseconds** `ms`. The numbers here have **not** been
rigorously collected, i.e., I did not run the tests several times at several
days and do any proper averaging.

The tests were carried out on an Azure "Standard D8s v3" VM (`vm-alex`) that
runs the `20_04-lts-gen2` image. `cat /proc/cpuinfo` reports a `Intel(R)
Xeon(R) CPU E5-2673 v4 @ 2.30GHz` CPU.

| Operating system              | Without optimisation | TBB w/o optimisation | With optimisation  | TBB with optimisation |
| ----------------------------- | -------------------- | -------------------- | ------------------ | --------------------- |
| Ubuntu 20.04 (VM)             |                18210 |                32079 |               2265 |                  2839 |
| Ubuntu latest (Docker, VM)    |                23331 |                37847 |               2235 |                  3002 |
| Alpine latest (Docker, VM)    |               149625 |                37259 |             136567 |                  2752 |
| MacOS (native)                |                14362 |                12415 |               2373 |                  1344 |
| MacOS (Docker, Ubuntu, arm64) |                 5058 |              Error 1 |               1607 |               Error 1 |
| MacOS (Docker, Alpine, arm64) |               126310 |              Error 2 |             120447 |               Error 2 |

- Without optimisation: `-O0 -DNDEBUG`
- With optimisation: `-O3 -DNDEBUG`
- oneTBB is always build using the `Release` target which implies optimisations
  within oneTBB.
- For MacOS tests `native` indicates that the tests have been run with Arm64
  executables and containers. The platform emulation later Rosetta was not
  used.

### Errors

Error messages observed when measuring the runtime. The errors all hint to some
incompatibility of the TBB allocator with MacOS on Arm64.

#### Error 1

Some fill text to fix PDF formatting.

```text
/bin/sh: 1: /src/tbb_allocator/tbb_allocator: Exec format error
```

#### Error 2

Some fill text to fix PDF formatting.

```text
/src/tbb_allocator/tbb_allocator: line 1: syntax error: unexpected word (expecting ")")
```

## Valgind investigation

I also did a short investigation to get the number of memory allocations and
instructions. All tests using `valgrind` were run on the Azure VM. Running them
in the Docker container led to unknown symbols.

### Memcheck

[Memcheck](https://valgrind.org/docs/manual/mc-manual.html) is a tool from the
[Valgrind toolbox](https://valgrind.org). It describes itself as

> Memcheck is a memory error detector.

We run Memcheck to get an idea about the memory allocations carried out by the
program.

#### Call

The call simply calls `valgrind` with default parameters

```text
valgrind EXECUTABLE
```

#### With optimisation

One can observe much more heap allocations if the standard allocator is used.
This might imply that the TBB allocator uses a memory pool or the TBB allocator
is not tracked by `valgrind`.

Default allocator:

```text
[...]
==725815== HEAP SUMMARY:
==725815==     in use at exit: 3,848 bytes in 13 blocks
==725815==   total heap usage: 175,000,044 allocs, 175,000,031 frees, 25,400,088,836 bytes allocated
==725815==
==725815== LEAK SUMMARY:
==725815==    definitely lost: 0 bytes in 0 blocks
==725815==    indirectly lost: 0 bytes in 0 blocks
==725815==      possibly lost: 2,016 bytes in 7 blocks
==725815==    still reachable: 1,832 bytes in 6 blocks
==725815==         suppressed: 0 bytes in 0 blocks
==725815== Rerun with --leak-check=full to see details of leaked memory
==725815==
==725815== For lists of detected and suppressed errors, rerun with: -s
==725815== ERROR SUMMARY: 0 errors from 0 contexts (suppressed: 0 from 0)
```

TBB allocator:

```text
[...]
==724381== HEAP SUMMARY:
==724381==     in use at exit: 3,848 bytes in 13 blocks
==724381==   total heap usage: 44 allocs, 31 frees, 88,836 bytes allocated
==724381==
==724381== LEAK SUMMARY:
==724381==    definitely lost: 0 bytes in 0 blocks
==724381==    indirectly lost: 0 bytes in 0 blocks
==724381==      possibly lost: 2,016 bytes in 7 blocks
==724381==    still reachable: 1,832 bytes in 6 blocks
==724381==         suppressed: 0 bytes in 0 blocks
==724381== Rerun with --leak-check=full to see details of leaked memory
==724381==
==724381== For lists of detected and suppressed errors, rerun with: -s
==724381== ERROR SUMMARY: 0 errors from 0 contexts (suppressed: 0 from 0)
```

#### Without optimisation

Not done yet as it is unclear if measuring the build without optimisation has
any benefits.

### Cachegrind

[Cachegrind](https://valgrind.org/docs/manual/cg-manual.html) is a tool from
the [Valgrind toolbox](https://valgrind.org). It describes itself as

> Cachegrind is a high-precision tracing profiler. It runs slowly, but collects
> precise and reproducible profiling data. It can merge and diff data from
> different runs. To expand on these characteristics:

We use Cachegrind to get an idea about the function calls that read and write
memory. It should also give an idea on how many instructions executed as the
documentation states

> I cache reads (Ir, which equals the number of instructions executed), I1
> cache read misses (I1mr) and LL cache instruction read misses (ILmr).

The results indicate that the oneTBB implementation does more reads, i.e., `I`
events, which also indicates additional instructions. This may explain the
runtime differences observed between the standard and the TBB allocator on
Ubuntu and the VM.

#### Calls

Performance stats are collected with

```text
valgrind --tool=cachegrind EXECUTABLE
```

which will create a file like `cachegrind.out.PID` with some process id (PID).
The report is created using `cg_annotate` as

```text
cg_annotage cacheground.out.PID
```

#### With optimisation

The **defaul allocator* reports the following numbers

```text
==727257==
==727257== I   refs:      62,512,825,377
==727257== I1  misses:             5,295
==727257== LLi misses:             3,421
==727257== I1  miss rate:           0.00%
==727257== LLi miss rate:           0.00%
==727257==
==727257== D   refs:      22,929,309,690  (15,178,920,563 rd   + 7,750,389,127 wr)
==727257== D1  misses:            28,338  (        20,870 rd   +         7,468 wr)
==727257== LLd misses:            15,765  (         9,862 rd   +         5,903 wr)
==727257== D1  miss rate:            0.0% (           0.0%     +           0.0%  )
==727257== LLd miss rate:            0.0% (           0.0%     +           0.0%  )
==727257==
==727257== LL refs:               33,633  (        26,165 rd   +         7,468 wr)
==727257== LL misses:             19,186  (        13,283 rd   +         5,903 wr)
==727257== LL miss rate:             0.0% (           0.0%     +           0.0%  )
```

and the annotated output of the **default allocator** gives

```text
--------------------------------------------------------------------------------
I1 cache:         32768 B, 64 B, 8-way associative
D1 cache:         32768 B, 64 B, 8-way associative
LL cache:         52428800 B, 64 B, 25-way associative
Command:          ./simpleallocator_O3
Data file:        cachegrind.out.727257
Events recorded:  Ir I1mr ILmr Dr D1mr DLmr Dw D1mw DLmw
Events shown:     Ir I1mr ILmr Dr D1mr DLmr Dw D1mw DLmw
Event sort order: Ir I1mr ILmr Dr D1mr DLmr Dw D1mw DLmw
Thresholds:       0.1 100 100 100 100 100 100 100 100
Include dirs:
User annotated:
Auto-annotation:  off

--------------------------------------------------------------------------------
Ir             I1mr  ILmr  Dr             D1mr   DLmr  Dw            D1mw  DLmw
--------------------------------------------------------------------------------
62,512,825,377 5,295 3,421 15,178,920,563 20,870 9,862 7,750,389,127 7,468 5,903  PROGRAM TOTALS

--------------------------------------------------------------------------------
Ir             I1mr ILmr Dr            D1mr  DLmr  Dw            D1mw  DLmw   file:function
--------------------------------------------------------------------------------
30,700,001,057   43   19 6,825,000,246    82     0 3,825,000,313   119    46  ???:tbb::detail::d1::start_for<tbb::detail::d1::blocked_range<unsigned long>, TBBTest, tbb::detail::d1::simple_partitioner const>::execute(tbb::detail::d1::execution_data&)
10,675,001,494   37   13 3,150,000,440    41     0 1,925,000,263     9     0  /build/glibc-wuryBv/glibc-2.31/malloc/malloc.c:_int_free
 7,250,003,225   32   11 2,100,000,837   124     0 1,050,000,060     4     3  /build/glibc-wuryBv/glibc-2.31/malloc/malloc.c:malloc
 4,134,375,639    6    3 1,028,125,161    32     0             0     0     0  /build/glibc-wuryBv/glibc-2.31/malloc/malloc.c:free
 2,700,002,990   35    6   750,000,723    27     0   600,000,531    93    40  /build/glibc-wuryBv/glibc-2.31/string/../sysdeps/x86_64/multiarch/memmove-vec-unaligned-erms.S:__memcpy_avx_unaligned_erms
 2,700,000,000   11    5    50,000,000     5     1             0     0     0  /build/glibc-wuryBv/glibc-2.31/math/../sysdeps/ieee754/dbl-64/wordsize-64/e_fmod.c:__fmod_finite@GLIBC_2.15
 1,925,000,088    5    1   350,000,016     4     0   350,000,016     8     0  ???:operator new(unsigned long)
 1,750,009,879  588  387   875,004,041   377     7           723    24    13  ???:???
   350,000,014    1    1             0     0     0             0     0     0  ???:operator delete(void*)
   325,000,000    2    2    50,000,000     2     2             0     0     0  /build/glibc-wuryBv/glibc-2.31/math/w_fmod_compat.c:fmod
```

The **TBB allocator** reports the following numbers

```text
==726625==
==726625== I   refs:      79,465,943,685
==726625== I1  misses:             5,186
==726625== LLi misses:             3,432
==726625== I1  miss rate:           0.00%
==726625== LLi miss rate:           0.00%
==726625==
==726625== D   refs:      25,676,182,769  (16,613,295,005 rd   + 9,062,887,764 wr)
==726625== D1  misses:            28,595  (        21,123 rd   +         7,472 wr)
==726625== LLd misses:            15,627  (         9,892 rd   +         5,735 wr)
==726625== D1  miss rate:            0.0% (           0.0%     +           0.0%  )
==726625== LLd miss rate:            0.0% (           0.0%     +           0.0%  )
==726625==
==726625== LL refs:               33,781  (        26,309 rd   +         7,472 wr)
==726625== LL misses:             19,059  (        13,324 rd   +         5,735 wr)
==726625== LL miss rate:             0.0% (           0.0%     +           0.0%  )
```

and the annotated output for the **TBB allocator** gives

```text
--------------------------------------------------------------------------------
I1 cache:         32768 B, 64 B, 8-way associative
D1 cache:         32768 B, 64 B, 8-way associative
LL cache:         52428800 B, 64 B, 25-way associative
Command:          ./tbballocator_03
Data file:        cachegrind.out.726625
Events recorded:  Ir I1mr ILmr Dr D1mr DLmr Dw D1mw DLmw
Events shown:     Ir I1mr ILmr Dr D1mr DLmr Dw D1mw DLmw
Event sort order: Ir I1mr ILmr Dr D1mr DLmr Dw D1mw DLmw
Thresholds:       0.1 100 100 100 100 100 100 100 100
Include dirs:
User annotated:
Auto-annotation:  off

--------------------------------------------------------------------------------
Ir             I1mr  ILmr  Dr             D1mr   DLmr  Dw            D1mw  DLmw
--------------------------------------------------------------------------------
79,465,943,685 5,186 3,432 16,613,295,005 21,123 9,892 9,062,887,764 7,472 5,735  PROGRAM TOTALS

--------------------------------------------------------------------------------
Ir             I1mr ILmr Dr            D1mr  DLmr  Dw            D1mw  DLmw   file:function
--------------------------------------------------------------------------------
38,825,001,073   44   23 7,025,000,254   122     0 4,500,000,329   317   111  ???:tbb::detail::d1::start_for<tbb::detail::d1::blocked_range<unsigned long>, TBBTest, tbb::detail::d1::simple_partitioner const>::execute(tbb::detail::d1::execution_data&)
10,462,507,889   26   15 2,112,501,377   208     0 1,750,001,106    60     4  ???:rml::internal::internalPoolMalloc(rml::internal::MemoryPool*, unsigned long) [clone .lto_priv.0]
 8,425,000,440   29   12 2,475,000,140   184    40 1,587,500,060    27     0  ???:scalable_aligned_free
 4,375,002,516    6    4   700,000,403     1     1   525,000,304     4     4  ???:rml::internal::allocateAligned(rml::internal::MemoryPool*, unsigned long, unsigned long) [clone .lto_priv.0]
 3,325,002,841    5    2   875,000,743    16     0             0     0     0  /build/glibc-wuryBv/glibc-2.31/nptl/pthread_getspecific.c:pthread_getspecific
 3,325,001,900    3    2   525,000,300     6     0   350,000,200     3     0  ???:scalable_aligned_malloc
 2,975,001,700    3    1   525,000,300    10     0   350,000,200    14     0  ???:tbb::detail::r1::cache_aligned_allocate(unsigned long)
 2,700,000,000   10    5    50,000,000     9     1             0     0     0  /build/glibc-wuryBv/glibc-2.31/math/../sysdeps/ieee754/dbl-64/wordsize-64/e_fmod.c:__fmod_finite@GLIBC_2.15
 2,150,009,929  562  388 1,075,004,066   381     7           723    24    13  ???:???
 1,050,000,000    4    1   350,000,000     2     0             0     0     0  ???:tbb::detail::r1::cache_line_size()
   650,000,000    4    2   325,000,000     0     0             0     0     0  ???:rml::internal::Block::adjustPositionInBin(rml::internal::Bin*)
   525,000,126    4    1   350,000,084    11     0             0     0     0  /build/glibc-wuryBv/glibc-2.31/nptl/pthread_self.c:pthread_self
   350,000,020    1    1   175,000,010     1     0             0     0     0  ???:tbb::detail::r1::cache_aligned_deallocate(void*)
   325,000,000    2    2    50,000,000     2     2             0     0     0  /build/glibc-wuryBv/glibc-2.31/math/w_fmod_compat.c:fmod
```

#### Without optimisation

Not done yet as it is unclear if measuring the build without optimisation has
any benefits.
