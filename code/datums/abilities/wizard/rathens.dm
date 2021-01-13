/datum/targetable/spell/rathens
	name = "Rathen's Secret"
	desc = "Summons a powerful shockwave around you that tears the arses and limbs off of enemies."
	icon_state = "arsenath"
	targeted = 0
	cooldown = 500
	requires_robes = 1
	offensive = 1
	voice_grim = "sound/voice/wizard/RathensSecretGrim.ogg"
	voice_fem = "sound/voice/wizard/RathensSecretFem.ogg"
	voice_other = "sound/voice/wizard/RathensSecretLoud.ogg"

	cast()
		if(!holder)
			return
		holder.owner.say("ARSE NATH!")
		..()

		playsound(holder.owner, "sound/voice/farts/superfart.ogg", 25, 1)

		for (var/mob/*living/carbon/human*//H in oview(holder.owner))
			if (H.traitHolder.hasTrait("training_chaplain"))
				boutput(usr, "<span class='alert'>[H]'s butt has divine protection from magic.</span>")
				H.visible_message("<span class='alert'>The spell fails to work on [H]!</span>")
				JOB_XP(H, "Chaplain", 2)
				continue
			if (iswizard(H))
				H.visible_message("<span class='alert'>[H] magically farts the spell away!</span>")
				playsound(H, 'sound/vox/poo.ogg', 25, 1)
				continue
			var/datum/effects/system/harmless_smoke_spread/smoke = new /datum/effects/system/harmless_smoke_spread()
			smoke.set_up(5, 0, H:loc)
			smoke.attach(H)
			smoke.start()
			ass_explosion(H, 1, 30)
// See bigfart.dm for the ass_explosion() proc. The third value represents the probability of limb loss in percent.
