///////////////////////
// Spiker abilities
///////////////////////

/datum/targetable/critter/spiker/hook	//Projectile is referenced in spiker.dm
	name = "Tentacle hook"
	desc = "Launch a tentacle at your target and drag it to you"
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

/datum/targetable/critter/spiker/lash	//Combo it with the tentacle throw to slap someone silly
	name = "Lash"
	desc = "Go into a bloody frenzy on a weakened target and rip them to shreds."
	cooldown = 10 SECOND
	targeted = 1
	target_anything = 1
	icon_state = "frenzy"

	var/datum/projectile/slam/proj = new

	cast(atom/target)
		if (disabled && world.time > last_cast)
			disabled = 0
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
			boutput(holder.owner, __red("Nothing to lash at there."))
			return 1
		if (BOUNDS_DIST(holder.owner, target) > 0)
			boutput(holder.owner, __red("That is too far away to lash at."))
			return 1
		var/mob/MT = target
		if (!is_incapacitated(MT))
			boutput(holder.owner, __red("That is moving around far too much to immobilize."))
			return 1
		playsound(holder.owner, "sound/impast_sounds/Flesh_Stab_1.ogg", 80, 1)
		disabled = 1
		SPAWN(0)
			var/frenz = 8
			holder.owner.canmove = 0
			while (frenz > 0 && MT && !MT.disposed)
				MT.changeStatus("weakened", 2 SECONDS)
				MT.canmove = 0
				if (MT.loc && holder.owner.loc != MT.loc)
					break
				if (is_incapacitated(holder?.owner))
					break
				playsound(holder.owner, pick("sound/impact_sounds/Flesh_Tear_3.ogg", "sound/impact_sounds/Flesh_Stab_1.ogg"), 80, 1)
				holder.owner.visible_message("<span class='alert'><b>[holder.owner] [pick("lashes at", "whips", "slashes", "tears at", "lacerates")] [MT]!</b></span>")
				holder.owner.set_dir((cardinal))
				holder.owner.pixel_x = rand(-5, 5)
				holder.owner.pixel_y = rand(-5, 5)
				random_brute_damage(MT, 4,1)
				take_bleeding_damage(MT, null, 12, DAMAGE_CUT, 0, get_turf(MT))
				if(prob(33))
					bleed(MT, 5, 5, get_step(get_turf(MT), pick(alldirs)), 1)
				sleep(0.8 SECONDS)
				frenz--
			if (MT)
				MT.canmove = 1
			doCooldown()
			disabled = 0
			holder.owner.pixel_x = 0
			holder.owner.pixel_y = 0
			holder.owner.canmove = 1

		return 0
