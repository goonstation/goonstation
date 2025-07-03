// FEATHERZONE
// because we all saw it coming

// TURFS
/turf/unsimulated/floor/feather
	name = "strange floor"
	icon = 'icons/misc/featherzone.dmi'
	icon_state = "floor"

/turf/unsimulated/floor/feather/broken
	name = "strange broken floor"
	icon_state = "floor-broken"

/turf/unsimulated/floor/feather/online
	name = "strange glowing floor"
	icon_state = "floor-on"


TYPEINFO_NEW(/turf/unsimulated/wall/auto/feather)
	. = ..()
	connects_to = typecacheof(list(/turf/unsimulated/wall/auto/feather, /obj/machinery/door/feather))
/turf/unsimulated/wall/auto/feather
	name = "strange glowing wall"
	icon = 'icons/misc/featherzone.dmi'
	icon_state = "0"

// DECALS/FAKEOBJS

/obj/fakeobject/brokendrone
	name = "broken heap"
	desc = "A pile of metal and glass fibre that seems to have... congealed? Weird. Also gross."
	icon = 'icons/misc/featherzone.dmi'
	icon_state = "drone-long-dead"
	anchored = ANCHORED
	density = 1

/obj/fakeobject/permanentcage
	name = "sturdy energy cage"
	desc = "A permanent cage used for keeping things in one place."
	icon = 'icons/misc/featherzone.dmi'
	icon_state = "cage"
	anchored = ANCHORED
	density = 1

	New()
		..()
		for (var/obj/O in src.loc)
			src.underlays += O
			O.set_loc(src)

	attack_hand(mob/user)
		user.visible_message(SPAN_COMBAT("<b>[user]</b> kicks [src], but it doesn't budge."), SPAN_ALERT("You kick [src], but it doesn't budge."))
