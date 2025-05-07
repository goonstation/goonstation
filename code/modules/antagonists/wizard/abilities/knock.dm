/datum/targetable/spell/knock
	name = "Knock"
	desc = "Opens nearby doors."
	icon_state = "knock"
	targeted = 0
	cooldown = 100
	requires_robes = 1
	restricted_area_check = ABILITY_AREA_CHECK_ALL_RESTRICTED_Z
	voice_grim = 'sound/voice/wizard/KnockGrim.ogg'
	voice_fem = 'sound/voice/wizard/KnockFem.ogg'
	voice_other = 'sound/voice/wizard/KnockLoud.ogg'
	maptext_colors = list("#24639a", "#24bdc6", "#05bd82", "#038463")

	cast()
		if(!holder)
			return
		if(!istype(get_area(holder.owner), /area/sim/gunsim))
			holder.owner.say("AULIE OXIN FIERA", flags = SAYFLAG_IGNORE_STAMINA, message_params = list("maptext_css_values" = src.maptext_style, "maptext_animation_colours" = src.maptext_colors))
		..()

		var/SPrange = 1
		if (holder.owner.wizard_spellpower(src))
			SPrange = 5
		else
			boutput(holder.owner, SPAN_ALERT("Your spell only works at point blank without a staff to focus it!"))

		var/obj/storage/secure/locked = src.holder.owner.loc
		if (locked && istype(locked))
			locked.unlock()
			locked.open()

		for(var/obj/machinery/door/G in oview(SPrange, holder.owner))
			SPAWN(1 DECI SECOND)
				G.open()
		for(var/obj/storage/F in oview(SPrange, holder.owner))
			if (F.locked)
				F.unlock()
			SPAWN(1 DECI SECOND)
				F.open()
		for(var/mob/living/silicon/robot/E in oview(SPrange, holder.owner))
			SPAWN(1 DECI SECOND)
				E.spellopen()
		for(var/obj/machinery/bot/B in oview(SPrange, holder.owner))
			B.locked = FALSE
			B.req_access = null
