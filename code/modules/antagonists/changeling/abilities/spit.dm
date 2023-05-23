/datum/targetable/changeling/spit
	name = "Toxic Spit"
	desc = "Spit homing acid at a target, melting their headgear (if any) or burning their face."
	icon_state = "acid"
	cooldown = 90 SECONDS

	max_range = 10
	targeted = TRUE
	target_anything = TRUE
	target_self = FALSE
	sticky = TRUE

	cast(atom/target)
		if (isobj(target))
			target = get_turf(target)
		if (isturf(target))
			target = locate(/mob/living) in target
			if (!target)
				boutput(holder.owner, "<span class='alert'>We cannot spit without a target.</span>")
				return  TRUE
		if (target == holder.owner) // target_self = FALSE doesn't handle this because of fuckass turf targeting
			return  TRUE
		var/mob/MT = target
		holder.owner.visible_message("<span class='alert'><b>[holder.owner] spits acid towards [target]!</b></span>")
		logTheThing(LOG_COMBAT, holder.owner, "spits acid at [constructTarget(MT,"combat")] as a changeling [log_loc(holder.owner)].")

		if (isliving(MT))
			MT:was_harmed(holder.owner, special = "ling")

		// You might be wondering "hey, isn't it a bit weird that this is a bizarre overlay object with a for loop instead of a projectile?"
		// You'd be right! it is weird and terrible!
		// that's it that's the comment
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
			A.reagents.add_reagent("pacid", 10)
			animate_spin(A, "R", 1.4, -1)

			var/obj/overlay/B = new /obj/overlay( A.loc )
			B.icon_state = "acidspit"
			B.icon = 'icons/obj/projectiles.dmi'
			B.name = "acid"
			B.anchored = ANCHORED
			B.set_density(0)
			B.layer = OBJ_LAYER
			animate_spin(B, "R", 1.4, -1)

			for(var/i=0, i<20, i++)
				B.set_loc(A.loc)

				step_to(A,MT,0)
				if (GET_DIST(A,MT) == 0)
					for(var/mob/O in AIviewers(MT, null))
						O.show_message("<span class='alert'><B>[MT.name] is hit by the acid spit!</B></span>", 1)
					A.reagents.reaction(MT)
					MT.lastattacker = src
					MT.lastattackertime = world.time
					qdel(A)
					qdel(B)
					return
				sleep(0.5 SECONDS)
			qdel(A)
			qdel(B)
