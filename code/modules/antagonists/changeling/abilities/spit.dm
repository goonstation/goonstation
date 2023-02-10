/datum/targetable/changeling/spit
	name = "Toxic Spit"
	desc = "Spit homing acid at a target, melting their headgear (if any) or burning their face."
	icon_state = "acid"
	cooldown = 900
	targeted = 1
	target_anything = 1
	sticky = 1

	cast(atom/target)
		if (..())
			return 1
		if (isobj(target))
			target = get_turf(target)
		if (isturf(target))
			target = locate(/mob/living) in target
			if (!target)
				boutput(holder.owner, "<span class='alert'>We cannot spit without a target.</span>")
				return 1
		if (target == holder.owner)
			return 1
		var/mob/MT = target
		holder.owner.visible_message("<span class='alert'><b>[holder.owner] spits acid towards [target]!</b></span>")
		logTheThing(LOG_COMBAT, holder.owner, "spits acid at [constructTarget(MT,"combat")] as a changeling [log_loc(holder.owner)].")

		if (isliving(MT))
			MT:was_harmed(holder.owner, special = "ling")

		SPAWN(0)
			var/obj/overlay/A = new /obj/overlay( holder.owner.loc )
			A.icon_state = "acidspit"
			A.icon = 'icons/obj/projectiles.dmi'
			A.name = "acid"
			A.anchored = 0
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
			B.anchored = 1
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
