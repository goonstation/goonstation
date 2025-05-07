/datum/targetable/spell/magshield
	name = "Spell Shield"
	desc = "Temporarily shield yourself from melee attacks and projectiles. It also absorbs some of the blast of explosions."
	icon_state = "spellshield"
	targeted = 0
	cooldown = 600
	requires_robes = 1
	cooldown_staff = 1
	voice_grim = 'sound/voice/wizard/MagicShieldGrim.ogg'
	voice_fem = 'sound/voice/wizard/MagicShieldFem.ogg'
	voice_other = 'sound/voice/wizard/MagicShieldLoud.ogg'
	maptext_colors = list("#24639a", "#24bdc6")

	cast()
		if(!holder)
			return
		if(holder.owner.hasStatus("spellshield"))
			boutput(holder.owner, SPAN_ALERT("You already have a Spell Shield active!"))
			return

		if(!istype(get_area(holder.owner), /area/sim/gunsim))
			holder.owner.say("XYZZYX", flags = SAYFLAG_IGNORE_STAMINA, message_params = list("maptext_css_values" = src.maptext_style, "maptext_animation_colours" = src.maptext_colors))
		..()

		holder.owner.setStatus("spellshield", 10 SECONDS)
