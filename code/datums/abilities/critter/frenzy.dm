// --------------------
// Wendigo style frenzy
// --------------------
/datum/targetable/critter/frenzy
	name = "Frenzy"
	desc = "Go into a bloody frenzy on a weakened target and rip them to shreds."
	cooldown = 350
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
				if (M.hasStatus(list("paralysis", "stunned", "weakened")))
					target = M
					break
		if (target == holder.owner)
			return 1
		if (!ismob(target))
			boutput(holder.owner, __red("Nothing to frenzy at there."))
			return 1
		if (get_dist(holder.owner, target) > 1)
			boutput(holder.owner, __red("That is too far away to frenzy."))
			return 1
		var/mob/MT = target
		if (!MT.hasStatus(list("paralysis", "stunned", "weakened")))
			boutput(holder.owner, __red("That is moving around far too much to pounce."))
			return 1
		playsound(get_turf(holder.owner), "sound/voice/animal/wendigo_roar.ogg", 80, 1)
		disabled = 1
		SPAWN_DBG(0)
			var/frenz = rand(10, 20)
			holder.owner.canmove = 0
			while (frenz > 0 && MT && !MT.disposed)
				MT.changeStatus("weakened", 2 SECONDS)
				MT.canmove = 0
				if (MT.loc)
					holder.owner.set_loc(MT.loc)
				if (holder?.owner.hasStatus(list("paralysis", "stunned", "weakened")))
					break
				playsound(get_turf(holder.owner), "sound/voice/animal/wendigo_maul.ogg", 80, 1)
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
