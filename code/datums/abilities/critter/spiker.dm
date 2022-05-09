/datum/targetable/critter/spiker/hook
	name = "hook"
	desc = "hook"
	icon_state = "clown_spider_bite"
	cooldown = 10 SECOND
	targeted = 1
	target_anything = 1

	cast(atom/target)
		if (..())
			return 1

		var/mob/living/critter/spiker/S = holder.owner
		var/obj/projectile/proj = initialize_projectile_ST(S, new/datum/projectile/special/tentacle, get_turf(target))
		while (!proj || proj.disposed)
			proj = initialize_projectile_ST(S, new/datum/projectile/special/tentacle, get_turf(target))

		proj.special_data["owner"] = holder.owner
		proj.targets = list(target)

		proj.launch()

/datum/targetable/critter/spiker/lash //Nerf it, make it less long
	name = "Frenzy"
	desc = "Go into a bloody frenzy on a weakened target and rip them to shreds."
	cooldown = 10 SECOND
	targeted = 1
	target_anything = 1
	icon_state = "frenzy"

	var/datum/projectile/slam/proj = new

	cast(atom/target)
		if (disabled && world.time > last_cast)
			disabled = 0 // break the deadlock
		if (disabled)
			return 1
		if (..())
			return 1
		if (isobj(target))
			target = get_turf(target)
		if (isturf(target))
			for (var/mob/living/M in target)
				if (is_incapacitated(M))
					target = M
					break
		if (target == holder.owner)
			return 1
		if (!ismob(target))
			boutput(holder.owner, __red("Nothing to frenzy at there."))
			return 1
		if (BOUNDS_DIST(holder.owner, target) > 0)
			boutput(holder.owner, __red("That is too far away to frenzy."))
			return 1
		var/mob/MT = target
		if (!is_incapacitated(MT))
			boutput(holder.owner, __red("That is moving around far too much to pounce."))
			return 1
		playsound(holder.owner, "sound/voice/animal/brullbar_roar.ogg", 80, 1)
		disabled = 1
		SPAWN(0)
			var/frenz = rand(10, 20)
			holder.owner.canmove = 0
			while (frenz > 0 && MT && !MT.disposed)
				MT.changeStatus("weakened", 2 SECONDS)
				MT.canmove = 0
				if (MT.loc)
					holder.owner.set_loc(MT.loc)
				if (is_incapacitated(holder?.owner))
					break
				playsound(holder.owner, "sound/voice/animal/brullbar_maul.ogg", 80, 1)
				holder.owner.visible_message("<span class='alert'><b>[holder.owner] [pick("mauls", "claws", "slashes", "tears at", "lacerates", "mangles")] [MT]!</b></span>")
				holder.owner.set_dir((cardinal))
				holder.owner.pixel_x = rand(-5, 5)
				holder.owner.pixel_y = rand(-5, 5)
				random_brute_damage(MT, 10,1)
				take_bleeding_damage(MT, null, 5, DAMAGE_CUT, 0, get_turf(MT))
				if(prob(33)) // don't make quite so much mess
					bleed(MT, 5, 5, get_step(get_turf(MT), pick(alldirs)), 1)
				sleep(0.4 SECONDS)
				frenz--
			if (MT)
				MT.canmove = 1
			doCooldown()
			disabled = 0
			holder.owner.pixel_x = 0
			holder.owner.pixel_y = 0
			holder.owner.canmove = 1

		return 0


/*
/datum/limb/longtentaclestun
	var/cooldown = 50
	var/next_shot_at = 0
	var/image/default_obscurer

	is_on_cooldown()
		if (ticker.round_elapsed_ticks < next_shot_at)
			return next_shot_at - ticker.round_elapsed_ticks
		return 0

	attack_range(atom/target, var/mob/user, params)
		var/turf/start = user.loc
		if (!isturf(start))
			return
		target = get_turf(target)
		if (!target)
			return
		if (target == start)
			return
		if (next_shot_at > ticker.round_elapsed_ticks)
			return
		next_shot_at = ticker.round_elapsed_ticks + cooldown

		playsound(user, "sound/misc/hastur/tentacle_hit.ogg", 50, 1)
		SPAWN(rand(1,3)) // so it might miss, sometimes, maybe
			var/obj/target_r = new/obj/tentacle_trg_dummy(target)

			playsound(user, "sound/misc/hastur/tentacle_hit.ogg", 50, 1)
			user.visible_message("<span class='alert'><B>[user] sends a grabbing tentacle flying!</B></span>")
			user.set_dir(get_dir(user, target))

			var/list/affected = DrawLine(user, target_r, /obj/line_obj/tentacle ,'icons/obj/projectiles.dmi',"WholeTentacle",1,1,"HalfStartTentacle","HalfEndTentacle",OBJ_LAYER,1)

			for(var/obj/O in affected)
				O.anchored = 1 //Proc wont spawn the right object type so lets do that here.
				O.name = "coiled tentacle"
				var/turf/src_turf = O.loc
				for(var/obj/machinery/vehicle/A in src_turf)
					if(A == O || A == user) continue
					A.meteorhit(O)
				for(var/obj/grille/A in src_turf)
					if(A == O || A == user) continue
					A.damage_blunt(10)
				for(var/obj/window/A in src_turf)
					if(A == O || A == user) continue
					A.smash()
				for(var/mob/living/M in src_turf)
					if(M == O || M == user) continue
					var/turf/destination = get_turf(user)
					if (destination)
						do_teleport(M, destination, 1, sparks=0) ///You will appear adjacent to Hastur.
						playsound(M, "sound/impact_sounds/Flesh_Stab_1.ogg", 50, 1)
						M.changeStatus("paralysis", 2 SECONDS)
						M.visible_message("<span class='alert'>[M] gets grabbed by a tentacle and dragged!</span>")


					else
						M.meteorhit(O)
				for(var/turf/T in src_turf)
					if(T == O) continue
					T.meteorhit(O)
				for(var/obj/machinery/colosseum_putt/A in src_turf)
					if (A == O || A == user) continue
					A.meteorhit(O)

			sleep(0.7 SECONDS)
			for (var/obj/O in affected)
				qdel(O)

			if(istype(target_r, /obj/tentacle_trg_dummy)) qdel(target_r)
			*/
