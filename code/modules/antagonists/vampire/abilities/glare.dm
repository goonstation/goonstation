/datum/targetable/vampire/glare
	name = "Glare"
	desc = "Stuns one target for a short time. Blocked by eye protection."
	icon_state = "glare"
	targeted = TRUE
	target_nodamage_check = TRUE
	max_range = 2
	cooldown = 60 SECONDS
	incapacitation_restriction = ABILITY_CAN_USE_WHEN_STUNNED
	can_cast_while_cuffed = TRUE
	sticky = TRUE

	cast(mob/target)
		var/mob/living/user = holder.owner

		if(istype(user))
			user.visible_message("<span class='alert'><B>[user]'s eyes emit a blinding flash at [target]!</B></span>")
		else
			user.visible_message("<span class='alert'><B>[user] emits a blinding flash at [target]!</B></span>")

		var/obj/itemspecialeffect/glare/E = new /obj/itemspecialeffect/glare
		E.color = "#FFFFFF"
		E.setup(user.loc)
		playsound(user.loc, 'sound/effects/glare.ogg', 50, 1, pitch = 1, extrarange = -4)

		SPAWN(1 DECI SECOND)
			var/obj/itemspecialeffect/glare/EE = new /obj/itemspecialeffect/glare
			EE.color = "#FFFFFF"
			EE.setup(target.loc)
			playsound(target.loc, 'sound/effects/glare.ogg', 50, 1, pitch = 0.8, extrarange = -4)

		if (target.bioHolder && target.traitHolder.hasTrait("training_chaplain"))
			boutput(target, "<span class='notice'>[user]'s foul gaze falters as it stares upon your righteousness!</span>")
			JOB_XP(target, "Chaplain", 2)
			target.visible_message("<span class='alert'><B>[target] glares right back at [user]!</B></span>")
		else
			target.apply_flash(3 SECONDS, 15, stamina_damage = 350)

		if (isliving(target))
			var/mob/living/L = target
			L.was_harmed(user, special = "vamp")

		logTheThing(LOG_COMBAT, user, "uses glare on [constructTarget(target,"combat")] at [log_loc(user)].")
		return FALSE

	castcheck(mob/target)
		. = ..()
		var/mob/user = src.holder.owner
		if (user == target)
			boutput(user, "<span class='alert'>Why would you want to stun yourself?</span>")
			return FALSE

		if (GET_DIST(user, target) > src.max_range)
			boutput(user, "<span class='alert'>[target] is too far away.</span>")
			return FALSE

		if (isdead(target))
			boutput(user, "<span class='alert'>It would be a waste of time to stun the dead.</span>")
			return FALSE

		if (istype(user) && !user.sight_check(TRUE))
			boutput(user, "<span class='alert'>How do you expect this to work? You can't use your eyes right now.</span>")
			return FALSE
