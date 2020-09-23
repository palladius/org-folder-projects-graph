
setup:
	mkdir out

cache-clean:
	rm -rf .cache/*

run:
	ruby recurse_folders.rb
