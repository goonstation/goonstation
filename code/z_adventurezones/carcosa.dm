/**
Unused Carcosa Area Stuff
Contents:
Statues
Trees
Walls
Arch
Grass
Rubble
Plants
Dirt
**/
/obj/decal/fakeobjects/carcosa/statue
	name = "statue"
	desc = "A statue of some ominous looking, robed, figure. There's barely a scratch on it."
	icon = 'icons/obj/large/64x64.dmi'
	icon_state = "statue"
	anchored = ANCHORED
	density = 1
	layer = 4
	bound_height = 32
	bound_width = 64
/obj/decal/fakeobjects/carcosa/statue/broken
	name = "broken statue"
	desc = "A statue of some ominous looking, robed, figure. It's badly damaged."
	icon_state = "statue_broken"

/obj/tree/carcosa
	name = "tree"
	desc = "A dead tree."
	icon = 'icons/obj/large/64x64.dmi'
	icon_state = "tree1"
	bound_height = 32
	bound_width = 64
/obj/tree/carcosa/one
	icon_state = "tree1"
/obj/tree/carcosa/two
	icon_state = "planthuge1"
/obj/tree/carcosa/three
	icon_state = "planthuge2"
/obj/tree/carcosa/four
	icon_state = "planthuge3"
/obj/tree/carcosa/five
	icon_state = "planthuge4"

/obj/decal/fakeobjects/carcosa/brokenwall
	name = "broken wall"
	desc = "A broken wall."
	icon = 'icons/obj/large/64x64.dmi'
	icon_state = "cwall1"
	anchored = ANCHORED
	density = 1
	bound_height = 32
	bound_width = 64
/obj/decal/fakeobjects/carcosa/brokenwall/one
	icon_state = "cwall1"
/obj/decal/fakeobjects/carcosa/brokenwall/two
	icon_state = "cwall2"
/obj/decal/fakeobjects/carcosa/brokenwall/three
	icon_state = "cwall3"
/obj/decal/fakeobjects/carcosa/brokenwall/four
	icon_state = "cwall4"

/obj/decal/fakeobjects/carcosa/brokenwall/up_one
	icon_state = "wallcont1"
	bound_height = 64
	bound_width = 32
	bound_x = 32

/obj/decal/fakeobjects/carcosa/brokenwall/up_two
	icon_state = "wallcont2"
	bound_height = 64
	bound_width = 32

/obj/decal/fakeobjects/carcosa/brokenwall/ruined_one
	icon_state = "wallruin1"
	bound_height = 32
	bound_width = 32

/obj/decal/fakeobjects/carcosa/brokenwall/ruined_two
	icon_state = "wallruin2"
	bound_height = 32
	bound_width = 32
	bound_x = 32

/obj/decal/fakeobjects/carcosa/brokenwall/arch_one
	icon_state = "carch1"
	name = "crumbling arches"
	desc = "An archway, It's a bit crumbly."
	density = 0

/obj/decal/fakeobjects/carcosa/grtrans
	name = ""
	desc = ""
	icon = 'icons/misc/exploration.dmi'
	icon_state = "empty"
	anchored = ANCHORED
	density = 0
/obj/decal/fakeobjects/carcosa/grtrans/west
	icon_state = "grtransW"
/obj/decal/fakeobjects/carcosa/grtrans/east
	icon_state = "grtransE"
/obj/decal/fakeobjects/carcosa/grtrans/north
	icon_state = "grtransN"
/obj/decal/fakeobjects/carcosa/grtrans/south
	icon_state = "grtransS"
/obj/decal/fakeobjects/carcosa/grtrans/northeast
	icon_state = "grtransNE"
/obj/decal/fakeobjects/carcosa/grtrans/southeast
	icon_state = "grtransSE"
/obj/decal/fakeobjects/carcosa/grtrans/southwest
	icon_state = "grtransSW"
/obj/decal/fakeobjects/carcosa/grtrans/northwest
	icon_state = "grtransNW"

/obj/decal/fakeobjects/carcosa/rubble
	name = "rubble"
	desc = "Bits of stone and various other debris."
	icon = 'icons/obj/large/64x64.dmi'
	icon_state = "empty"
	anchored = ANCHORED
	density = 0

/obj/decal/fakeobjects/carcosa/rubble/one
	icon_state = "crubble1"
/obj/decal/fakeobjects/carcosa/rubble/two
	icon_state = "crubble2"
/obj/decal/fakeobjects/carcosa/rubble/three
	icon_state = "crubble3"

/obj/decal/fakeobjects/carcosa/carcosa_plant
	name = "alien plant"
	desc = "A strange looking plant."
	icon = 'icons/misc/exploration.dmi'
	icon_state = "empty"
	anchored = ANCHORED
	density = 0
/obj/decal/fakeobjects/carcosa/carcosa_plant/one
	icon_state = "aplant1"
/obj/decal/fakeobjects/carcosa/carcosa_plant/two
	icon_state = "aplant2"
/obj/decal/fakeobjects/carcosa/carcosa_plant/three
	icon_state = "aplant3"
/obj/decal/fakeobjects/carcosa/carcosa_plant/four
	icon_state = "aplant4"
/obj/decal/fakeobjects/carcosa/carcosa_plant/five
	icon_state = "aplant5"
/obj/decal/fakeobjects/carcosa/carcosa_plant/six
	icon_state = "aplant6"

/turf/simulated/floor/carcosa/carcosa_dirt
	name = "dirt"
	desc = "It's just some odd looking dirt."
	icon = 'icons/misc/exploration.dmi'
	icon_state = "aground"
	step_material = "step_outdoors"
	step_priority = STEP_PRIORITY_MED

	ex_act(severity)
		return

/turf/simulated/floor/carcosa/carcosa_dirt_inner
	name = "dirt"
	desc = "It's just some odd looking dirt."
	icon = 'icons/misc/exploration.dmi'
	icon_state = "aground_inner4"
	step_material = "step_outdoors"
	step_priority = STEP_PRIORITY_MED

	ex_act(severity)
		return


// cognote: large adventure areas should probably mostly use unsimulated turfs. i'll leave your simulated versions in for now so i don't break your local files

/turf/unsimulated/floor/setpieces/carcosa/carcosa_dirt
	name = "dirt"
	desc = "It's just some odd looking dirt."
	icon = 'icons/misc/exploration.dmi'
	icon_state = "aground"

	ex_act(severity)
		return

/turf/unsimulated/floor/setpieces/carcosa/carcosa_dirt_inner
	name = "dirt"
	desc = "It's just some odd looking dirt."
	icon = 'icons/misc/exploration.dmi'
	icon_state = "aground_inner4"

	ex_act(severity)
		return
