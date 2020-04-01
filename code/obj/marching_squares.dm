// marching squares: easy
// this special case of marching squares: hell on earth
// I went to sleep, woke up and cant remember what most of these lookup tables do
// pray none of them are wrong

var/dirbits = list(
	list(), // 0
	list(NORTH), // 1
	list(SOUTH), // 2
	list(NORTH, SOUTH), // 3
	list(EAST), // 4
	list(NORTH, EAST), // 5
	list(SOUTH, EAST), // 6
	list(NORTH, SOUTH, EAST), // 7
	list(WEST), // 8
	list(NORTH, WEST), // 9
	list(SOUTH, WEST), // 10
	list(NORTH, SOUTH, WEST), // 11
	list(EAST, WEST), // 12
	list(NORTH, EAST, WEST), // 13
	list(SOUTH, EAST, WEST), // 14
	list(NORTH, SOUTH, EAST, WEST), // 15
)
var/corner_spill_combos = list(
	0, // 0
	0, // 1
	0, // 2
	0, // 3
	0, // 4
	NORTH, // 5
	EAST, // 6
	NORTH | EAST, // 7
	0, // 8
	WEST, // 9
	SOUTH, // 10
	SOUTH | WEST, // 11
	0, // 12
	NORTH | WEST, // 13
	SOUTH | EAST, // 14
	NORTH | SOUTH | EAST | WEST, // 15
)
var/spill_cover_bits = list(
	0,
	0,
	0,
	0,
	2 | 4, // NORTHEAST
	8 | 16, // SOUTHEAST
	0,
	0,
	1 | 128, // NORTHWEST
	32 | 64, // SOUTHWEST
)
var/cover_bit_masks = list(
	0, // 0
	1 | 2, // 1
	16 | 32, // 2
	1 | 2 | 16 | 32, // 3
	4 | 8, // 4
	1 | 2 | 4 | 8, // 5
	4 | 8 | 16 | 32, // 6
	1 | 2 | 4 | 8 | 16 | 32, // 7
	64 | 128, // 8
	1 | 2 | 64 | 128, // 9
	16 | 32 | 64 | 128, // 10
	1 | 2 | 16 | 32 | 64 | 128, // 11
	4 | 8 | 64 | 128, // 12
	1 | 2 | 4 | 8 | 64 | 128, // 13
	4 | 8 | 16 | 32 | 64 | 128, // 14
	1 | 2 | 4 | 8 | 16 | 32 | 64 | 128 // 16
)
var/spill_masks = list(0, 0, 0, 0, 0, 132, 18, 150, 0, 33, 72, 105, 0, 165, 90, 0)
var/bad_spill_dirs = list(0, 3, 12)

/obj/marching_squares
	name = "marching square test"
	icon = 'icons/obj/marching_test.dmi'
	anchored = 1

	proc/calc_spill_dirs(turf/T)
		. = 0
		for (var/dir in cardinal)
			if (locate(/obj/marching_squares/filled) in get_step(T, dir))
				. |= dir

	filled
		icon_state = "f0"

		proc/update()
			var/corners = 0
			var/spills = 0
			var/spill_bits = 0
			var/antispill = 0
			var/ordinal_corners = 0
			for (var/dir in cardinal)
				if (locate(/obj/marching_squares/filled) in get_step(src, dir))
					corners |= turn(dir, -45)
					antispill |= dir
			for (var/dir in ordinal)
				if (locate(/obj/marching_squares/filled) in get_step(src, dir))
					ordinal_corners |= turn(dir, -45)
					spills |= dir
					spill_bits |= spill_cover_bits[dir]
			corners |= ordinal_corners

			spills &= ~antispill
			if (corners == 15) // dumb corner case
				var/autojoin = antispill | corner_spill_combos[ordinal_corners+1]
				icon_state = "f15-[autojoin]-[spill_bits & ~cover_bit_masks[autojoin+1]]"
			else
				icon_state = "f[corners]-[(spill_bits | cover_bit_masks[antispill+1]) & spill_masks[corners+1]]"
			return spills

		New()
			var/obj/marching_squares/spill/extra_spill = locate() in src.loc
			if (extra_spill)
				qdel(extra_spill)

			var/spills = src.update()
			for (var/obj/marching_squares/filled/O in orange(1, src))
				O.update()
			for (var/dir in dirbits[spills+1])
				var/turf/T = get_step(src, dir)
				var/obj/marching_squares/spill/spill = locate() in T
				if (!spill)
					spill = new(T)
				spill.icon_state = "e[src.calc_spill_dirs(T)]"

	spill
