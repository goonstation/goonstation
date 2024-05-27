/datum/targetable/spell/rathens
	name = "Rathen's Secret"
	desc = "Summons a powerful shockwave around you that tears the arses and limbs off of enemies."
	icon_state = "arsenath"
	targeted = 0
	cooldown = 500
	requires_robes = 1
	offensive = 1
	voice_grim = 'sound/voice/wizard/RathensSecretGrim.ogg'
	voice_fem = 'sound/voice/wizard/RathensSecretFem.ogg'
	voice_other = 'sound/voice/wizard/RathensSecretLoud.ogg'
	maptext_colors = list("#d73715", "#d73715", "#fcf574")

	cast()
		if(!holder)
			return
		if(!istype(get_area(holder.owner), /area/sim/gunsim))
			holder.owner.say("ARSE NATH", flags = SAYFLAG_IGNORE_STAMINA, message_params = list("maptext_css_values" = src.maptext_style, "maptext_animation_colours" = src.maptext_colors))
		..()

		playsound(holder.owner, 'sound/voice/farts/superfart.ogg', 25, 1)

		for (var/mob/*living/carbon/human*//H in oview(holder.owner))
			if (H.traitHolder.hasTrait("training_chaplain"))
				boutput(usr, SPAN_ALERT("[H]'s butt has divine protection from magic."))
				H.visible_message(SPAN_ALERT("The spell fails to work on [H]!"))
				JOB_XP(H, "Chaplain", 2)
				continue
			if (iswizard(H))
				H.visible_message(SPAN_ALERT("[H] magically farts the spell away!"))
				playsound(H, 'sound/vox/poo.ogg', 25, TRUE)
				continue
			ass_explosion(H, 1, 30)
// See bigfart.dm for the ass_explosion() proc. The third value represents the probability of limb loss in percent.
