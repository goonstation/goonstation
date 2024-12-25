
/datum/targetable/critter/bury_hide
	name = "Bury Self"
	desc = "Hide yourself underground."
	cooldown = 3 SECONDS
	start_on_cooldown = 0
	icon_state = "tears"

/datum/targetable/critter/bury_hide/cast(atom/target)
	if (..())
		return 1

	var/turf/T = get_turf(holder.owner)
	if (!istype(T) || T.turf_flags & CAN_BE_SPACE_SAMPLE || T.throw_unlimited)
		boutput(holder.owner, SPAN_NOTICE("You can't bury yourself on this kind of turf!"))
		return 1
	if(T == holder.owner.loc)
		playsound(T, 'sound/effects/shovel1.ogg', 50, TRUE, 0.3)
		holder.owner.visible_message(SPAN_NOTICE("<b>[holder.owner]</b> buries themselves!"),
		                             SPAN_NOTICE("You bury yourself."))

		var/obj/overlay/tile_effect/cracks/C = new(T)
		holder.owner.set_loc(C)

/obj/overlay/tile_effect/cracks
	icon = 'icons/effects/effects.dmi'
	icon_state = "cracks"

	New()
		..()
		src.AddComponent(/datum/component/proximity)

	EnteredProximity(atom/movable/AM)
		..()
		if (isliving(AM))
			src.relaymove(AM,pick(cardinal))

	relaymove(var/mob/user, direction)
		playsound(src, 'sound/effects/shovel1.ogg', 50, TRUE, 0.3)
		for (var/mob/M in src)
			M.set_loc(src.loc)
			if (M.ai?.enabled)
				M.ai.interrupt()
		qdel(src)


	spawner
		var/spawntype = null


		EnteredProximity(atom/movable/AM)
			if (spawntype)
				new spawntype(src)
				spawntype = null
			..()

		trilobite
			spawntype = /mob/living/critter/small_animal/trilobite

		pikaia
			spawntype = /mob/living/critter/small_animal/pikaia


///obj/overlay/tile_effect/cracks/trilobite
///obj/overlay/tile_effect/cracks/pikaia
