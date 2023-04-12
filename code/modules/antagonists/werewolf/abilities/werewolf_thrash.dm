/datum/targetable/werewolf/werewolf_thrash
	name = "Thrash"
	desc = "Thrash around in a fit of lycanthropic rage! Flail your arms and legs clawing and punching anyone next to you."
	icon_state = "thrash"
	cooldown = 40 SECONDS
	incapacitation_restriction = ABILITY_CAN_USE_ALWAYS
	can_cast_while_cuffed = FALSE
	werewolf_only = TRUE

	cast(mob/target)
		. = ..()
		var/mob/living/M = holder.owner
		var/turf/thrash_loc = M.loc

		M.canmove = FALSE
		for (var/i = 0, i < 20, i++)
			if (i > 5)
				for (var/mob/T in orange(1, M))
					if (prob(40) && T.density)
						M.werewolf_attack(T, "thrash")
						M.set_dir(turn(M.dir, 90))
			M.set_dir(turn(M.dir, 90))
			M.set_loc(thrash_loc)
			playsound(M.loc, 'sound/voice/animal/werewolf_attack2.ogg', 10, TRUE, 0.1, 1.6)
			sleep (0.15 SECONDS)
		M.canmove = TRUE
