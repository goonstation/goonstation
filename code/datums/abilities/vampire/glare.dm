/datum/targetable/vampire/glare
	name = "Glare"
	desc = "Stuns one target for a short time. Blocked by eye protection."
	icon_state = "glare"
	targeted = 1
	target_nodamage_check = 1
	max_range = 2
	cooldown = 600
	pointCost = 0
	when_stunned = 1
	not_when_handcuffed = 0
	sticky = 1

	cast(mob/target)
		if (!holder)
			return 1

		var/mob/living/M = holder.owner

		if (!M || !target || !ismob(target))
			return 1

		if (M == target)
			boutput(M, "<span class='alert'>Why would you want to stun yourself?</span>")
			return 1

		if (GET_DIST(M, target) > src.max_range)
			boutput(M, "<span class='alert'>[target] is too far away.</span>")
			return 1

		if (isdead(target))
			boutput(M, "<span class='alert'>It would be a waste of time to stun the dead.</span>")
			return 1

		if (istype(M) && !M.sight_check(1))
			boutput(M, "<span class='alert'>How do you expect this to work? You can't use your eyes right now.</span>")
			M.visible_message("<span class='alert'>What was that? There's something odd about [M]'s eyes.</span>")
			return 0 // Cooldown because spam is bad.

		if(istype(M))
			M.visible_message("<span class='alert'><B>[M]'s eyes emit a blinding flash at [target]!</B></span>")
		else
			M.visible_message("<span class='alert'><B>[M] emits a blinding flash at [target]!</B></span>")

		var/obj/itemspecialeffect/glare/E = new /obj/itemspecialeffect/glare
		E.color = "#FFFFFF"
		E.setup(M.loc)
		playsound(M.loc, 'sound/effects/glare.ogg', 50, 1, pitch = 1, extrarange = -4)

		SPAWN(1 DECI SECOND)
			var/obj/itemspecialeffect/glare/EE = new /obj/itemspecialeffect/glare
			EE.color = "#FFFFFF"
			EE.setup(target.loc)
			playsound(target.loc, 'sound/effects/glare.ogg', 50, 1, pitch = 0.8, extrarange = -4)

		if (target.bioHolder && target.traitHolder.hasTrait("training_chaplain"))
			boutput(target, "<span class='notice'>[M]'s foul gaze falters as it stares upon your righteousness!</span>")
			JOB_XP(target, "Chaplain", 2)
			target.visible_message("<span class='alert'><B>[target] glares right back at [M]!</B></span>")
		else
			target.apply_flash(30, 15, stamina_damage = 350)

		if (isliving(target))
			target:was_harmed(M, special = "vamp")

		logTheThing(LOG_COMBAT, M, "uses glare on [constructTarget(target,"combat")] at [log_loc(M)].")
		return 0
