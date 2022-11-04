/datum/puzzlewizard/trap/lightningtrap
	name = "AB CREATE: Lightning trap"
	var/turf/target = null
	var/damage = 20
	var/stun = 6

	var/selection

	initialize()
		..()
		selection = new /obj/adventurepuzzle/marker
		damage = input("Trap damage? (500+ to gib instantly)", "Trap damage", 20) as num
		stun = input("Stun time?", "Stun time", 6) as num
		boutput(usr, "<span class='notice'>Right click to set trap target. Right click active target to clear target. Left click to place trap. Ctrl+click anywhere to finish.</span>")
		boutput(usr, "<span class='notice'>Special note: If no target is set, all mobs within 6 tiles in the line of sight of the trap will be shocked.</span>")

	disposing()
		if (target)
			target.overlays -= selection
		if (selection)
			qdel(selection)
		..()

	build_click(var/mob/user, var/datum/buildmode_holder/holder, var/list/pa, var/atom/object)
		if ("left" in pa)
			var/turf/T = get_turf(object)
			if ("ctrl" in pa)
				finished = 1
				target.overlays -= selection
				target = null
				return
			if (T)
				var/obj/adventurepuzzle/triggerable/targetable/lightningtrap/L = new /obj/adventurepuzzle/triggerable/targetable/lightningtrap(T)
				if (target)
					var/obj/adventurepuzzle/invisible/I = locate() in target
					if (!I)
						I = new /obj/adventurepuzzle/invisible(target)
					L.target = I
					L.damage = damage
					L.stun = stun
					L.trap_delay = trap_delay
		else if ("right" in pa)
			if (isturf(object))
				if (target == object)
					target.overlays -= selection
					target = null
				else
					if (target)
						target.overlays -= selection
					target = object
					target.overlays += selection

/obj/adventurepuzzle/triggerable/targetable/lightningtrap
	name = "lightning trap"
	invisibility = INVIS_ADVENTURE
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "spark"
	density = 0
	opacity = 0
	anchored = 1
	target = null
	var/range = 6
	var/trap_delay = 100
	var/next_trap = 0
	var/damage = 20
	var/stun = 6

	var/is_on = 1

	var/static/list/triggeracts = list("Activate" = "act", "Disable" = "off", "Destroy" = "del", "Do nothing" = "nop", "Enable" = "on")

	trigger_actions()
		return triggeracts

	trigger(var/act)
		switch (act)
			if ("del")
				is_on = 0
				qdel(src)
			if ("act")
				if (is_on && next_trap <= world.time)
					var/attack_amt = 0
					if (target)
						attack_amt = 1
						var/list/affected = DrawLine(target, src, /obj/line_obj/elec ,'icons/obj/projectiles.dmi',"WholeLghtn",1,1,"HalfStartLghtn","HalfEndLghtn",OBJ_LAYER,1,PreloadedIcon='icons/effects/LghtLine.dmi')
						for(var/obj/OB in affected)
							SPAWN(0.6 SECONDS)
								qdel(OB)
						for (var/mob/living/M in get_turf(target))
							if (damage < 500)
								M.TakeDamage("chest", 0, damage, 0, DAMAGE_BURN)
								M.changeStatus("stunned", stun SECONDS)
								boutput(M, "<b><span class='alert'>You feel a powerful shock course through your body!</span></b>")
							else
								if(ishuman(M))
									logTheThing(LOG_COMBAT, M, "was gibbed by [src] ([src.type]) at [log_loc(M)].")
								M:gib()
					else
						for (var/mob/living/M in view(src, range))
							attack_amt = 1
							var/list/affected = DrawLine(M, src, /obj/line_obj/elec ,'icons/obj/projectiles.dmi',"WholeLghtn",1,1,"HalfStartLghtn","HalfEndLghtn",OBJ_LAYER,1,PreloadedIcon='icons/effects/LghtLine.dmi')
							for(var/obj/OB in affected)
								SPAWN(0.6 SECONDS)
									qdel(OB)
							if (damage < 500)
								M.TakeDamage("chest", 0, damage, 0, DAMAGE_BURN)
								M.changeStatus("stunned", stun SECONDS)
								boutput(M, "<b><span class='alert'>You feel a powerful shock course through your body!</span></b>")
							else
								if(ishuman(M))
									logTheThing(LOG_COMBAT, M, "was gibbed by [src] ([src.type]) at [log_loc(M)].")
								M:gib()
					if (attack_amt)
						playsound(src, 'sound/effects/elec_bigzap.ogg', 40, 1)
					next_trap = world.time + trap_delay
			if ("off")
				is_on = 0
				return
			if ("on")
				is_on = 1
				return

	serialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		..()
		F["[path].is_on"] << is_on
		F["[path].range"] << range
		F["[path].trap_delay"] << trap_delay
		F["[path].damage"] << damage
		F["[path].stun"] << stun

		if (target)
			F["[path].has_target"] << 1
			F["[path].target"] << "ser:\ref[target]"
		else
			F["[path].has_target"] << 0


	deserialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		. = ..()
		F["[path].is_on"] >> is_on
		F["[path].range"] >> range
		F["[path].trap_delay"] >> trap_delay
		F["[path].damage"] >> damage
		F["[path].stun"] >> stun

		var/has_target
		F["[path].has_target"] >> has_target
		if (has_target)
			F["[path].target"] >> target
			. |= DESERIALIZE_NEED_POSTPROCESS

	deserialize_postprocess()
		..()
		if (target)
			target = locate(target)

	reset()
		next_trap = 0
