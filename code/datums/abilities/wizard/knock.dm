/datum/targetable/spell/knock
	name = "Knock"
	desc = "Opens nearby doors."
	icon_state = "knock"
	targeted = 0
	cooldown = 100
	requires_robes = 1
	restricted_area_check = 1
	voice_grim = 'sound/voice/wizard/KnockGrim.ogg'
	voice_fem = 'sound/voice/wizard/KnockFem.ogg'
	voice_other = 'sound/voice/wizard/KnockLoud.ogg'
	maptext_colors = list("#24639a", "#24bdc6", "#05bd82", "#038463")

	cast()
		if(!holder)
			return
		if(!istype(get_area(holder.owner), /area/sim/gunsim))
			holder.owner.say("AULIE OXIN FIERA", FALSE, maptext_style, maptext_colors)
		..()

		var/SPrange = 1
		if (holder.owner.wizard_spellpower(src))
			SPrange = 5
		else
			boutput(holder.owner, "<span class='alert'>Your spell only works at point blank without a staff to focus it!</span>")
		for(var/obj/machinery/door/G in oview(SPrange, holder.owner))
			SPAWN(1 DECI SECOND)
				G.open()
		for(var/obj/storage/F in oview(SPrange, holder.owner))
			if (F.locked)
				F.locked = 0
			SPAWN(1 DECI SECOND)
				F.open()
		for(var/mob/living/silicon/robot/E in oview(SPrange, holder.owner))
			SPAWN(1 DECI SECOND)
				E.spellopen()
		for(var/obj/machinery/bot/B in oview(SPrange, holder.owner))
			B.locked = 0
			B.req_access = null
