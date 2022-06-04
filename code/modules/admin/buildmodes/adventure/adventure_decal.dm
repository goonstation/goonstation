/datum/adventure_submode/decal
	name = "Decoration"
	var/objtype = null

	click_left(atom/object, var/ctrl, var/alt, var/shift)
		var/path = objtype
		if (islist(path))
			path = pick(path)
		var/obj/O = new path(get_turf(object))
		O.set_dir(holder.dir)
		O.onVarChanged("dir", SOUTH, O.dir)
		blink(O.loc)

	click_right(atom/object, var/ctrl, var/alt, var/shift)
		if (isobj(object))
			blink(get_turf(object))
			qdel(object)

	selected()
		var/kind = input(usr, "What kind of decoration?", "Decoration type", "Skeleton") in src.decals
		objtype = src.decals[kind]
		boutput(usr, "<span class='notice'>Now placing [kind] objects in single spawn mode.</span>")

	settings(var/ctrl, var/alt, var/shift)
		selected()

	var/static/list/decals = list("Abandoned crate" = /obj/storage/crate/loot ,"Ash" = /obj/decal/cleanable/ash, "Blood" = /obj/decal/cleanable/blood, "Blood tracks" = /obj/decal/cleanable/blood/tracks, \
	"Bookcase (single, empty)" = /obj/bookcase, "Bookcase (single, full)" = /obj/bookcase/full, "Bookcase (directional, empty)" = /obj/bookcase/directional, \
	"Bookcase (directional, full)" = /obj/bookcase/directional/full, "Bookcase (triggerable button - use with connection tool)" = /obj/adventurepuzzle/triggerer/bookcase, \
	"Candle" = /obj/candle_light, "Candle (spooky)" = /obj/candle_light_2spoopy, "Chair" = /obj/stool/chair, "Chair (comfy)" = /obj/stool/chair/comfy, \
	"Chair (evil)" = /obj/stool/chair/syndicate, "Chair (office)" = /obj/stool/chair/office, "Chair (stool)" = /obj/stool, \
	"Closet" = /obj/storage/closet, "Closet (biohazard)" = /obj/storage/closet/biohazard, "Closet (emergency)" = /obj/storage/closet/emergency, "Closet (fire)" = /obj/storage/closet/fire, \
	"Cobweb (upper left)" = /obj/decal/cleanable/cobweb, "Cobweb (upper right)" = /obj/decal/cleanable/cobweb2, "Coffin" = /obj/storage/closet/coffin, "Computer frame" = /obj/computerframe, \
	"Crate" = /obj/storage/crate, "Crate (internals)" = /obj/storage/crate/internals, "Crate (gibs)" = /obj/storage/crate/haunted, "Crate (weapons)" = /obj/storage/secure/crate/weapon, "Debris" = /obj/decal/cleanable/robot_debris, \
	"Floating tile" = /obj/decal/floatingtiles, "Fungus" = /obj/decal/cleanable/fungus, "Gang tag" = /obj/decal/cleanable/gangtag, \
	"Gibs" = list(/obj/decal/cleanable/blood/gibs, /obj/decal/cleanable/blood/gibs/core, /obj/decal/cleanable/blood/gibs/body), \
	"Green Vomit" = /obj/decal/cleanable/greenpuke, "Ice (permanent)" = /obj/decal/icefloor, "Light beam" = /obj/decal/lightshaft, \
	"Martian computer" = /obj/decal/aliencomputer, "Martian crevice" = /obj/crevice, "Martian door" = /obj/machinery/door/unpowered/martian, \
	"Mushroom" = list(/obj/decal/mushrooms, /obj/decal/mushrooms/type1, /obj/decal/mushrooms/type2, /obj/decal/mushrooms/type3, /obj/decal/mushrooms/type4), \
	"Oil" = /obj/decal/cleanable/oil, "Orb of Fire" = /obj/item/orb/fire, "Orb of Lightning" = /obj/item/orb/lightning, "Pedestal" = /obj/pedestal, "Reactor core" = /obj/decal/fakeobjects/core, \
	"Rune marks" = /obj/decal/runemarks, "Showcase cover" = /obj/cover/showcase, "Skeleton" = /obj/decal/fakeobjects/skeleton, "Stalagmite" = /obj/decal/stalagmite, "Stalagtite" = /obj/decal/stalagtite, \
	"Statue" = /obj/decal/statue, "Statue (monkey)" = list(/obj/decal/statue/monkey1, /obj/decal/statue/monkey2, /obj/decal/statue/monkey3), \
	"Table (white)" = /obj/table/auto, "Table (wood)" = /obj/table/wood/auto, \
	"Vomit" = /obj/decal/cleanable/vomit, "Wizard crystal: Amethyst" = /obj/item/wizard_crystal/amethyst, \
	"Wizard crystal: Emerald" = /obj/item/wizard_crystal/emerald, "Wizard crystal: Quartz" = /obj/item/wizard_crystal/quartz, "Wizard crystal: Ruby" = /obj/item/wizard_crystal/ruby, \
	"Wizard crystal: Sapphire" = /obj/item/wizard_crystal/sapphire)
