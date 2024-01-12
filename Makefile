all: simpleallocator tbballocator

simpleallocator:
	g++ -I/home/aej/software/onetbb/include mainsimple.cpp $(CXXFLAGS) -o simple -L/home/aej/software/onetbb/lib -ltbb

tbballocator:
	g++ -I/home/aej/software/onetbb/include mainallocator.cpp $(CXXFLAGS) -o tbb_allocator -L/home/aej/software/onetbb/lib -ltbb

clean:
	rm -f simple tbb_allocator
