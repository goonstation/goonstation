/datum/targetable/spell/warp
	name = "Warp"
	desc = "Teleports a foe away."
	icon_state = "warp"
	targeted = 1
	cooldown = 100
	requires_robes = 1
	offensive = 1
	restricted_area_check = 1
	sticky = 1
	voice_grim = "sound/voice/wizard/WarpGrim.ogg"
	voice_fem = "sound/voice/wizard/WarpFem.ogg"
	voice_other = "sound/voice/wizard/WarpLoud.ogg"

	cast(mob/target)
		if(!holder)
			return

		holder.owner.say("GHEIT AUT")
		..()

		if (target.traitHolder.hasTrait("training_chaplain"))
			boutput(holder.owner, "<span class='alert'>[target] has divine protection from magic.</span>")
			playsound(target.loc, "sound/effects/mag_warp.ogg", 25, 1, -1)
			target.visible_message("<span class='alert'>The spell fails to work on [target]!</span>")
			JOB_XP(target, "Chaplain", 2)
			return

		if (iswizard(target))
			target.visible_message("<span class='alert'>The spell fails to work on [target]!</span>")
			playsound(target.loc, "sound/effects/mag_warp.ogg", 25, 1, -1)
			return

		var/telerange = 10
		if (holder.owner.wizard_spellpower(src))
			telerange = 25
		else
			boutput(holder.owner, "<span class='alert'>Your spell is weak without a staff to focus it!</span>")


		if (isrestrictedz(holder.owner.z))
			boutput(holder.owner, "<span class='notice'>You feel guilty for trying to use that spell here.</span>")
			return


		elecflash(target)
		var/list/randomturfs = new/list()
		for(var/turf/T in orange(target, telerange))
			if(istype(T, /turf/space) || T.density) continue
			randomturfs.Add(T)
		boutput(target, "<span class='notice'>You are caught in a magical warp field!</span>")
		animate_blink(target)
		target.visible_message("<span class='alert'>[target] is warped away!</span>")
		playsound(target.loc, "sound/effects/mag_warp.ogg", 25, 1, -1)
		target.set_loc(pick(randomturfs))
