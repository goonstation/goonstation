/datum/targetable/spell/bullcharge
	name = "Bull's Charge"
	desc = "Records the casters movement for 4 seconds after which the spell will fire and throw & heavily damage everyone in it's recorded Path."
	icon_state = "bullc" // Vaguely matching placeholder.
	targeted = 0
	cooldown = 150
	requires_robes = 1
	requires_being_on_turf = TRUE
	offensive = 1
	voice_grim = 'sound/voice/wizard/BullChargeGrim.ogg'
	voice_fem = 'sound/voice/wizard/BullChargeFem.ogg'
	voice_other = 'sound/voice/wizard/BullChargeLoud.ogg'
	maptext_colors = list("#24639a", "#24bdc6", "#55eec2", "#24bdc6")

	cast()
		if(!holder)
			return
		if(!istype(get_area(holder.owner), /area/sim/gunsim))
			holder.owner.say("RAMI TIN", FALSE, maptext_style, maptext_colors)
		..()

		var/list/path = list()
		var/turf/first = holder.owner.loc
		var/turf/prev = first
		for(var/i = 0, i < 40, i++)
			var/turf/curr = holder.owner.loc
			animate_bullspellground(curr, "#aaddff")
			if(prev != curr)
				path += curr
				prev = curr
			sleep(0.1 SECONDS)

		playsound(holder.owner.loc, 'sound/voice/animal/bull.ogg', 25, 1, -1)

		var/list/affected = list()
		var/obj/effects/bullshead/B = new/obj/effects/bullshead(first)
		for(var/turf/T in path)
			B.set_dir(get_dir(B, T))
			B.set_loc(T)
			animate_bullspellground(T, "#5599ff")
			for (var/atom/movable/M in T)
				if (M.anchored || affected.Find(M) || M == holder.owner)
					continue
				if (ismob(M))
					var/mob/some_idiot = M
					if(some_idiot?.traitHolder?.hasTrait("training_chaplain"))
						continue
					some_idiot.changeStatus("weakened", 3 SECONDS)
					some_idiot.TakeDamage("chest", 33, 0, 0, DAMAGE_BLUNT)//it's magic. no armor 4 u
				affected += M
				M.throw_at(get_edge_cheap(T, B.dir), 30, 1)
			sleep(0.1 SECONDS)

		qdel(B)

/obj/effects/bullshead
	name = "magic"
	desc = "i aint gotta explain shit"
	density = 0
	opacity = 0
	anchored = ANCHORED
	pixel_x = -32
	pixel_y = -32
	icon = 'icons/effects/96x96.dmi'
	icon_state = "bull"

	New()
		..()
		src.alpha = 245
		animate(src, alpha = 1, time = 30)
