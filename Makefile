
help:
	cat Makefile

#setup:
#	mkdir -p out

cache-clean:
	rm -rf .cache/*

run:
	ruby recurse_folders.rb

run-all:
	./recurse_all.sh