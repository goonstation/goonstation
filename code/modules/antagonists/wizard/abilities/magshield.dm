/datum/targetable/spell/magshield
	name = "Spell Shield"
	desc = "Temporarily shield yourself from melee attacks, projectiles, and explosions"
	icon_state = "spellshield"
	targeted = 0
	cooldown = 600
	requires_robes = 1
	defensive = TRUE
	cooldown_staff = 1
	voice_grim = 'sound/voice/wizard/MagicShieldGrim.ogg'
	voice_fem = 'sound/voice/wizard/MagicShieldFem.ogg'
	voice_other = 'sound/voice/wizard/MagicShieldLoud.ogg'
	maptext_colors = list("#24639a", "#24bdc6")

	cast()
		if(!istype(holder?.owner, /mob/living/carbon/human))
			return

		var/mob/living/carbon/human/H = src.holder.owner
		var/obj/item/clothing/suit/wizrobe/robe = H.wear_suit

		if(istype(robe, /obj/item/clothing/suit/wizrobe) && SEND_SIGNAL(robe, COMSIG_CHECK_SHIELD_ACTIVE))
			boutput(holder.owner, SPAN_ALERT("You already have a Spell Shield active!"))
			return TRUE

		if(!istype(get_area(holder.owner), /area/sim/gunsim))
			holder.owner.say("XYZZYX", FALSE, maptext_style, maptext_colors)
		..()

		SEND_SIGNAL(robe, COMSIG_SHIELD_TOGGLE)

		SPAWN(10 SECONDS)
			if(!QDELETED(H) && !QDELETED(robe))
				if (SEND_SIGNAL(robe, COMSIG_CHECK_SHIELD_ACTIVE))
					SEND_SIGNAL(robe, COMSIG_SHIELD_TOGGLE)
