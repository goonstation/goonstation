/datum/targetable/spell/animatedead
	name = "Animate Dead"
	desc = "Turns a human corpse into a skeletal minion."
	icon_state = "pet"
	targeted = TRUE
	max_range = 1
	cooldown = 850
	requires_robes = TRUE
	requires_being_on_turf = TRUE
	offensive = TRUE
	cooldown_staff = TRUE
	sticky = TRUE
	voice_grim = 'sound/voice/wizard/AnimateDeadGrim.ogg'
	voice_fem = 'sound/voice/wizard/AnimateDeadFem.ogg'
	voice_other = 'sound/voice/wizard/AnimateDeadLoud.ogg'
	maptext_colors = list("#5a1d8a", "#790c4f", "#9f0b2d")

	cast(mob/target)
		if(!holder)
			return
		if(!isdead(target))
			boutput(holder.owner, "<span class='alert'>That person is still alive! Find a corpse.</span>")
			return TRUE // No cooldown when it fails.
		if(!istype(get_area(holder.owner), /area/sim/gunsim))
			holder.owner.say("EI NECRIS", FALSE, maptext_style, maptext_colors)
		..()

		var/mob/living/critter/skeleton/skeleton = new /mob/living/critter/skeleton/(get_turf(target))
		skeleton.CustomiseSkeleton(target.real_name, ismonkey(target))

		boutput(holder.owner, "<span class='notice'>You saturate [target] with dark magic!</span>")
		holder.owner.visible_message("<span class='alert'>[holder.owner] rips the skeleton from [target]'s corpse!</span>")

		for(var/obj/item/I in target)
			if(isitem(target))
				target.u_equip(I)
				if(I)
					I.set_loc(target.loc)
					I.dropped(target)
		target.gib(TRUE)
