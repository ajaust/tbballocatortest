#include <chrono>
#include <iostream>
#include <random>

#include "oneapi/tbb.h"

using namespace oneapi::tbb;

class TBBTest {
public:
    void operator()(const blocked_range<size_t>& r) const {
        std::chrono::steady_clock::time_point before_call = std::chrono::steady_clock::now();
        auto sum = 0;
        for (int i = r.begin(); i != r.end(); ++i) {
            std::vector<double, cache_aligned_allocator<double>> points;
            points.reserve(44);
            for (int i = 0; i < 44; ++i) {
                points.push_back(std::rand());
            };
            sum += std::fmod(std::accumulate(points.begin(), points.end(), 0), 2);
        }
        std::chrono::steady_clock::time_point after_call = std::chrono::steady_clock::now();
        std::cout << "Local sum " << sum << " computed in " << std::chrono::duration_cast<std::chrono::seconds>(after_call - before_call).count() << " seconds" << std::endl;
    }
};

void tbbtest() {
    //int iterations = 25000000;
    int iterations = 2500000;
    int chunk_size = iterations / 8;
    std::chrono::steady_clock::time_point before_call = std::chrono::steady_clock::now();
    parallel_for(blocked_range<size_t>(0, iterations, chunk_size), TBBTest(), simple_partitioner());
    std::chrono::steady_clock::time_point after_call = std::chrono::steady_clock::now();
    std::cout << "Call took = " << std::chrono::duration_cast<std::chrono::seconds>(after_call - before_call).count() << "[s]" << std::endl;
}

int main() {
    std::cout << "TBB allocator!" << std::endl;
    tbbtest();

    return 0;
}
