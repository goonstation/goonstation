/datum/targetable/spell/doppelganger
	name = "Doppelganger"
	desc = "Creates a clone of you while temporarily making you undetectable. The clone keeps moving in whatever direction you were facing when you cast the spell."
	icon_state = "doppelganger"
	targeted = 0
	cooldown = 300
	requires_robes = 1
	restricted_area_check = 1
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

		var/obj/overlay/P = new/obj/overlay()
		P.name = holder.owner.name
		P.icon = holder.owner.icon
		P.icon_state = holder.owner.icon_state
		P.set_density(1)
		P.desc = "Wait ... that's not [P.name]!!!"

		var/obj/dummy/spell_doppel/D = new/obj/dummy/spell_doppel()

		for(var/X in holder.owner.overlays)
			var/image/I = X
			P.overlays += I

		if(!istype(get_area(holder.owner), /area/sim/gunsim))
			holder.owner.say("GIN EMUS") // ^-- No speech bubble.
		..()

		var/turf/curr_turf = get_turf(holder.owner)

		P.set_dir(the_dir)
		P.set_loc(curr_turf)
		D.set_loc(curr_turf)
		holder.owner.set_loc(D)

		if(!ground)
			SPAWN(0)
				while(P)
					step(P, the_dir)
					sleep(0.2 SECONDS)

		SPAWN(10 SECONDS)
			holder.owner.set_loc(D.loc)
			qdel(D)
			qdel(P)

/obj/dummy/spell_doppel
	name = ""
	icon = 'icons/effects/effects.dmi'
	icon_state = "nothing"
	invisibility = INVIS_ALWAYS_ISH
	var/can_move = 1
	mouse_opacity = 0
	density = 0
	anchored = 1

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
