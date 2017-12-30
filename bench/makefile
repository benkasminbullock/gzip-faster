all: short.output long.output

short.output: benchmark.pl module
	./benchmark.pl > $@

long.output: benchmark.pl module
	./benchmark.pl --input chinese > $@

module: ../gzip-faster-perl.c ../Faster.xs ../lib/Gzip/Faster.pm
	cd ..;./build.pl
