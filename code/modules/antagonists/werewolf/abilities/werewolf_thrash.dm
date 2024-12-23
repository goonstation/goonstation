/datum/targetable/werewolf/werewolf_thrash
	name = "Thrash"
	desc = "Thrash around in a fit of lycanthropic rage! Flail your arms and legs clawing and punching anyone next to you."
	icon_state = "thrash"
	targeted = 0
	target_nodamage_check = 0
	max_range = 0
	cooldown = 400
	pointCost = 0
	when_stunned = 2
	not_when_handcuffed = 1
	werewolf_only = 1
	cast(mob/target)
		if (!holder)
			return 1
		var/mob/living/M = holder.owner
		if (!M)
			return 1
		. = ..()
		var/turf/thrash_loc = M.loc
		M.canmove = 0
		for (var/i = 0, i < 20, i++)
			if (i > 5)
				for (var/mob/T in range(1))
					if (prob(40) && T.density)
						M.werewolf_attack(T, "thrash")
						M.set_dir(turn(M.dir, 90))
			if (M)
				M.set_dir(turn(M.dir, 90))
				M.set_loc(thrash_loc)
				playsound(M.loc, 'sound/voice/animal/werewolf_attack2.ogg', 10, 1, 0.1, 1.6)
			else
				return 0
			sleep (1.5)
		M.canmove = 1
