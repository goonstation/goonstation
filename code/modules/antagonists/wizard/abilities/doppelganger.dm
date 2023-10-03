/datum/targetable/spell/doppelganger
	name = "Doppelganger"
	desc = "Creates a clone of you while temporarily making you undetectable. The clone keeps moving in whatever direction you were facing when you cast the spell."
	icon_state = "doppelganger"
	targeted = 0
	cooldown = 300
	requires_robes = 1
	restricted_area_check = ABILITY_AREA_CHECK_ALL_RESTRICTED_Z
	voice_grim = 'sound/voice/wizard/DopplegangerGrim.ogg'
	voice_fem = 'sound/voice/wizard/DopplegangerFem.ogg'
	voice_other = 'sound/voice/wizard/DopplegangerLoud.ogg'

	cast()
		if(!holder)
			return
		var/the_dir = holder.owner.dir
		var/ground = 0

		if (!isturf(holder.owner.loc))
			return 1

		ground = holder.owner.lying

		// This is the dummy people actually see
		var/obj/overlay/doppel = new/obj/overlay()
		doppel.name = holder.owner.name
		doppel.icon = holder.owner.icon
		doppel.icon_state = holder.owner.icon_state
		doppel.set_density(1)
		doppel.desc = "Wait ... that's not [doppel.name]!!!"

		// This is the dummy the player controls to move
		var/obj/dummy/spell_doppel/mover = new/obj/dummy/spell_doppel()

		for(var/X in holder.owner.overlays)
			var/image/I = X
			doppel.overlays += I

		if(!istype(get_area(holder.owner), /area/sim/gunsim))
			holder.owner.say("GIN EMUS") // ^-- No speech bubble.
		..()

		var/turf/curr_turf = get_turf(holder.owner)

		doppel.set_dir(the_dir)
		doppel.set_loc(curr_turf)
		mover.set_loc(curr_turf)
		holder.owner.set_loc(mover)

		if(!ground)
			SPAWN(0)
				while(doppel)
					step(doppel, the_dir)
					sleep(0.2 SECONDS)

		SPAWN(10 SECONDS)
			holder.owner.set_loc(mover.loc)
			for (var/obj/junk_to_dump in mover.contents)
				junk_to_dump.set_loc(get_turf(holder.owner))
			qdel(mover)
			qdel(doppel)

/obj/dummy/spell_doppel
	name = ""
	icon = 'icons/effects/effects.dmi'
	icon_state = "nothing"
	invisibility = INVIS_ALWAYS_ISH
	var/can_move = 1
	mouse_opacity = 0
	density = 0
	anchored = ANCHORED

/obj/dummy/spell_doppel/relaymove(var/mob/user, direction)
	if (!src.can_move) return

	var/turf/newloc = get_step(src, direction)
	if (newloc.density) return

	switch(direction)
		if(NORTH)
			src.y++
		if(SOUTH)
			src.y--
		if(EAST)
			src.x++
		if(WEST)
			src.x--
		if(NORTHEAST)
			src.y++
			src.x++
		if(NORTHWEST)
			src.y++
			src.x--
		if(SOUTHEAST)
			src.y--
			src.x++
		if(SOUTHWEST)
			src.y--
			src.x--

	src.can_move = 0
	SPAWN(0.2 SECONDS) src.can_move = 1
