
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
	if(T == holder.owner.loc)
		playsound(T, 'sound/effects/shovel1.ogg', 50, 1, 0.3)
		holder.owner.visible_message("<span class='notice'><b>[holder.owner]</b> buries themselves!</span>",
		                             "<span class='notice'>You bury yourself.</span>")

		var/obj/overlay/tile_effect/cracks/C = new(T)
		holder.owner.set_loc(C)

		if (holder.owner.ai)
			holder.owner.ai.enabled = 0
			holder.owner.ai.stop_move()


/obj/overlay/tile_effect/cracks
	icon = 'icons/effects/effects.dmi'
	icon_state = "cracks"
	event_handler_flags = USE_PROXIMITY

	HasProximity(atom/movable/AM)
		..()
		if (isliving(AM))
			src.relaymove(AM,pick(cardinal))

	relaymove(var/mob/user, direction)
		playsound(src, 'sound/effects/shovel1.ogg', 50, 1, 0.3)
		for (var/mob/M in src)
			if (M.ai)
				M.ai.enabled = 1
			M.set_loc(src.loc)
		qdel(src)


	spawner
		var/spawntype = null


		HasProximity(atom/movable/AM)
			if (spawntype)
				new spawntype(src)
				spawntype = null
			..()

		trilobite
			spawntype = /mob/living/critter/small_animal/trilobite/ai_controlled

		pikaia
			spawntype = /mob/living/critter/small_animal/pikaia/ai_controlled


///obj/overlay/tile_effect/cracks/trilobite
///obj/overlay/tile_effect/cracks/pikaia
