/datum/targetable/critter/spit
	name = "Toxic Spit"
	desc = "Spit homing acid at a target."
	icon_state = "fermid_spit"
	cooldown = 30 SECONDS
	targeted = 1
	target_anything = 1
	sticky = 1
	var/substance_name = "acid"
	var/splash = FALSE
	var/reagent = "acid"
	var/range = 10

	cast(atom/target)
		if (..())
			return 1
		if (isobj(target))
			target = get_turf(target)
		if (isturf(target))
			target = locate(/mob/living) in target
			if (!target)
				boutput(holder.owner, SPAN_ALERT("We cannot spit without a target."))
				return 1
		if (target == holder.owner)
			return 1
		var/mob/MT = target
		holder.owner.visible_message(SPAN_ALERT("<b>[holder.owner] spits [substance_name] towards [target]!</b>"))
		logTheThing(LOG_COMBAT, holder.owner, "spits [substance_name] at [constructTarget(MT,"combat")] [log_loc(holder.owner)].")

		if (isliving(MT))
			MT:was_harmed(holder.owner, special = "[src.name]")

		SPAWN(0)
			var/obj/overlay/A = new /obj/overlay( holder.owner.loc )
			A.icon_state = "acidspit"
			A.icon = 'icons/obj/projectiles.dmi'
			A.name = "acid"
			A.anchored = UNANCHORED
			A.set_density(0)
			A.layer = EFFECTS_LAYER_UNDER_1
			A.flags += TABLEPASS
			A.reagents = new /datum/reagents(10)
			A.reagents.my_atom = A
			A.reagents.add_reagent(reagent, 10)
			animate_spin(A, "R", 1.4, -1)

			var/obj/overlay/B = new /obj/overlay( A.loc )
			B.icon_state = "acidspit"
			B.icon = 'icons/obj/projectiles.dmi'
			B.name = "acid"
			B.anchored = ANCHORED
			B.set_density(0)
			B.layer = OBJ_LAYER
			animate_spin(B, "R", 1.4, -1)

			for(var/i=0, i<range, i++)
				B.set_loc(A.loc)

				step_to(A,MT,0)
				if (GET_DIST(A,MT) == 0)
					for(var/mob/O in AIviewers(MT, null))
						O.show_message(SPAN_ALERT("<B>[MT.name] is hit by the [substance_name] spit!</B>"), 1)
					A.reagents.reaction(MT)
					MT.lastattacker = get_weakref(src)
					MT.lastattackertime = world.time
					qdel(A)
					qdel(B)
					return
				sleep(0.5 SECONDS)
			qdel(A)
			qdel(B)

/*
 * /datum/targetable/critter/llamaspit
 * Copyright (C) 2025 Bartimeus
 * Copyright (C) 2010,2016,2020-2025 Goonstation Contributors
 *
 * Contributed to the 35 Below Project, derived at least 14.8%
 * from code in Goonstation available through the terms of the
 * CreativeCommons BY-NC-SA 3.0 United States License ONLY.
 * Full terms available in the "LICENSE" file or at:
 * http://creativecommons.org/licenses/by-nc-sa/3.0/us/
 */

/datum/targetable/critter/llamaspit
	name = "Spit on a poor sod"
	desc = "I despise you and everything you stand for."
	icon_state = "fermid_spit"
	cooldown = 20 SECONDS
	targeted = 1
	target_anything = 0
	var/range = 10

	var/datum/projectile/pie/llama/spit_proj = new

	cast(atom/target)
		if (..())
			return 1
		if (!ismob(target))
			return 1
		if (target == holder.owner)
			return 1
		var/mob/MT = target
		var/substance_name = pick("a disgusting loogie", "a horrid glob of regurgitated plant matter", "a giant spitball", "a ball of liquid spit")
		holder.owner.visible_message(SPAN_ALERT("<b>[holder.owner] spits [substance_name] towards [target]!</b>"))
		var/obj/projectile/P = initialize_projectile_pixel_spread( holder.owner, spit_proj, MT )
		if (P)
			P.mob_shooter = holder.owner
			P.launch()
			return 0
		return 1
