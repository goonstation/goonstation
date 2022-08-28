/datum/targetable/spell/warp
	name = "Warp"
	desc = "Teleports a foe away."
	icon_state = "warp"
	targeted = 1
	cooldown = 100
	requires_robes = 1
	requires_being_on_turf = TRUE
	offensive = 1
	restricted_area_check = 1
	sticky = 1
	voice_grim = 'sound/voice/wizard/WarpGrim.ogg'
	voice_fem = 'sound/voice/wizard/WarpFem.ogg'
	voice_other = 'sound/voice/wizard/WarpLoud.ogg'
	maptext_colors = list("#5cde24", "#167935", "#084623", "#0167935")

	cast(mob/target)
		if(!holder)
			return 1

		if(!istype(target))
			target = locate(/mob) in get_turf(target)
		if(!istype(target))
			return 1

		if (holder.owner == target)
			boutput(holder.owner, "<span class='alert'>You can't warp yourself!</span>")
			return 1

		if(!istype(get_area(holder.owner), /area/sim/gunsim))
			holder.owner.say("GHEIT AUT", FALSE, maptext_style, maptext_colors)
		..()

		if (target.traitHolder.hasTrait("training_chaplain"))
			boutput(holder.owner, "<span class='alert'>[target] has divine protection from magic.</span>")
			playsound(target.loc, 'sound/effects/mag_warp.ogg', 25, 1, -1)
			target.visible_message("<span class='alert'>The spell fails to work on [target]!</span>")
			JOB_XP(target, "Chaplain", 2)
			return

		if (iswizard(target))
			target.visible_message("<span class='alert'>The spell fails to work on [target]!</span>")
			playsound(target.loc, 'sound/effects/mag_warp.ogg', 25, 1, -1)
			return 1

		var/telerange = 10
		if (holder.owner.wizard_spellpower(src))
			telerange = 25
		else
			boutput(holder.owner, "<span class='alert'>Your spell is weak without a staff to focus it!</span>")


		if (isrestrictedz(holder.owner.z))
			boutput(holder.owner, "<span class='notice'>You feel guilty for trying to use that spell here.</span>")
			return 1


		elecflash(target)
		var/list/randomturfs = new/list()
		for(var/turf/T in orange(target, telerange))
			if(istype(T, /turf/space) || T.density) continue
			randomturfs.Add(T)
		boutput(target, "<span class='notice'>You are caught in a magical warp field!</span>")
		animate_blink(target)
		target.visible_message("<span class='alert'>[target] is warped away!</span>")
		playsound(target.loc, 'sound/effects/mag_warp.ogg', 25, 1, -1)
		var/turf/destination = pick(randomturfs)
		logTheThing(LOG_COMBAT, holder.owner, "warped [constructTarget(target,"combat")] from [log_loc(target)] to [log_loc(destination)].")
		target.set_loc(destination)
