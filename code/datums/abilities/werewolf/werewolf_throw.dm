/datum/targetable/werewolf/werewolf_throw
	name = "Throw"
	desc = "Spin a grabbed opponent around and throw them."
	icon_state = "throw"
	targeted = 1
	target_anything = 0
	target_nodamage_check = 0
	target_selection_check = 0
	max_range = 1
	cooldown = 300
	pointCost = 0
	when_stunned = 0
	not_when_handcuffed = 1
	//throw mostly stolen from macho man. Doesn't spin as fast and doesn't deal with grabs, it's just a targetable ability.
	cast(mob/target)
		if (!holder)
			return 1
		var/mob/living/M = holder.owner
		var/mob/living/HH = target
		if (!M || !HH)
			return 1
		if (M == target)
			boutput(M, __red("You can't throw yourself."))
			return 1
		HH.set_loc(M.loc)
		HH.dir = get_dir(HH, M)
		HH.changeStatus("stunned",40)
		M.visible_message("<span class='alert'><B>[M] starts flinging [HH] around like a ragdoll!</B></span>")
		M.emote("scream")
		for (var/i = 0, i < 10, i++)
			var/delay = 3
			switch (i)
				if (9 to 25)
					delay = 1
				if (5 to 8)
					delay = 2
				if (0 to 4)
					delay = 3
			if (M && HH)
				if (get_dist(M, HH) > max_range)
					boutput(M, __red("[HH] is too far away!"))
					return 0
				if (!isturf(M.loc) || !isturf(HH.loc))
					boutput(M, __red("You can't throw [HH] from here!"))
					return 0
				M.dir = turn(M.dir, 90)
				var/turf/T = get_step(M, M.dir)
				var/turf/S = HH.loc
				if ((S && isturf(S) && S.Exit(HH)) && (T && isturf(T) && T.Enter(HH)))
					HH.set_loc(T)
					HH.dir = get_dir(HH, M)
			else
				return 0
			sleep (delay)
		if (M && HH)
			if (get_dist(M, HH) > max_range)
				boutput(M, __red("[HH] is too far away!"))
				return 0
			if (!isturf(M.loc) || !isturf(HH.loc))
				boutput(M, __red("You can't throw [HH] from here!"))
				return 0
			HH.set_loc(M.loc) // Maybe this will help with the wallthrowing bug.
			M.visible_message("<span class='alert'><B>[M] throws [HH]!</B></span>")
			playsound(M.loc, "swing_hit", 50, 1)
			var/turf/T = get_edge_target_turf(M, M.dir)
			if (T && isturf(T))
				if (HH.stat != 2)
					HH.emote("scream")
				HH.throw_at(T, 10, 4)
				HH.changeStatus("weakened",20)
				HH.change_misstep_chance(33)
			logTheThing("combat", M, HH, "uses the throw werewolf move on [constructTarget(HH,"combat")] at [log_loc(M)].")
		return 0
