# Running Tracy on a Live Server

One of the big problems with running Tracy on a live server is that it eats up a lot of RAM.
However, there exists solutions that stream the Tracy data straight to disk, uncompressed, without having to use up 64 gigs of RAM.
Essentially, you will stream this tracy Data to a file, and then read this file later in portions as to not require tons of RAM on the client.

You'll need several things:
* A copy of [Tracy](https://github.com/wolfpld/tracy) on a client computer to view traces.
* A `prof.dll/.so` produced by [para-byond-tracy](https://github.com/ParadiseSS13/byond-tracy) in the game directory.
* A compiled version of [RTracy](https://github.com/Dimach/rtracy), to stream the huge `.utracy` files.

## How 2 Do It

1. Compile the game with `#define TRACY_PROFILER_HOOK`. Or, use the `Toggle-Tracy-Profiling` verb on actual live.
2. Have prof.dll/so in the game directory.
3. Run the game.
4. The game will produce `.utracy` files inside `data/profiler/` that you'll need. They will be quite large. Expect up to 30GB.
5. Transfer the files wherever you want to view them. Likely not the game server.
6. Run `rtracy(.exe)`, with the first argument being a path to the `.utracy` file.
	1. You can provide `-p` for the port, `-s` to skip a number of frames, and `-l` to limit the number of streamed frames.
	1. For example if you want to stream 30 minutes of data after 10 minutes from start (assuming your snapshot written at 10 frames per second) run `./rtracy you_file.utracy -s 6000 -l 18000`
7. Success!
