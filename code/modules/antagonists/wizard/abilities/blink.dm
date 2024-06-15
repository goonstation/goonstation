/datum/targetable/spell/blink
	name = "Blink"
	desc = "Teleport randomly to a nearby tile."
	icon_state = "blink"
	targeted = 0
	cooldown = 100
	requires_robes = 1
	restricted_area_check = ABILITY_AREA_CHECK_ALL_RESTRICTED_Z
	voice_grim = 'sound/voice/wizard/BlinkGrim.ogg'
	voice_fem = 'sound/voice/wizard/BlinkFem.ogg'
	voice_other = 'sound/voice/wizard/BlinkLoud.ogg'
	maptext_colors = list("#24639a", "#24bdc6", "#55eec2", "#24bdc6")

	cast()
		if(!holder)
			return

		if(!istype(get_area(holder.owner), /area/sim/gunsim))
			holder.owner.say("SYCAR TYN", flags = SAYFLAG_IGNORE_STAMINA, message_params = list("maptext_css_values" = src.maptext_style, "maptext_animation_colours" = src.maptext_colors))
		..()

		var/accuracy = 3
		if(holder.owner.wizard_spellpower(src))
			accuracy = 1
		else
			boutput(holder.owner, SPAN_ALERT("Your spell is weak without a staff to focus it!"))

		if(holder.owner.getStatusDuration("burning"))
			boutput(holder.owner, SPAN_NOTICE("The flames sputter out as you blink away."))
			holder.owner.delStatus("burning")

		var/targetx = holder.owner.x
		var/targety = holder.owner.y

		if(holder.owner.dir == 1)
			targety = holder.owner.y + 4
			targetx = holder.owner.x
		else if(holder.owner.dir == 4)
			targetx = holder.owner.x + 4
			targety = holder.owner.y
		else if(holder.owner.dir == 2)
			targety = holder.owner.y - 4
			targetx = holder.owner.x
		else if(holder.owner.dir == 8)
			targetx = holder.owner.x - 4
			targety = holder.owner.y

		var/turf/targetturf = locate(targetx, targety, holder.owner.z)

		if(isrestrictedz(holder.owner.z) && !istype(get_area(targetturf), /area/wizard_station))
			boutput(holder.owner, SPAN_ALERT("It's too dangerous to blink there!"))
			return

		playsound(holder.owner.loc, 'sound/effects/mag_teleport.ogg', 25, 1, -1)

		var/list/turfs = new/list()
		for(var/turf/T in orange(accuracy,targetturf))
			if(istype(T,/turf/space)) continue
			if(T.density) continue
			if(T.x>world.maxx-4 || T.x<4)	continue	//putting them at the edge is dumb
			if(T.y>world.maxy-4 || T.y<4)	continue
			turfs += T
		var/datum/effects/system/harmless_smoke_spread/smoke = new /datum/effects/system/harmless_smoke_spread()
		smoke.set_up(10, 0, holder.owner.loc)
		smoke.start()
		var/turf/picked = null
		if (turfs.len) picked = pick(turfs)
		if(!isturf(picked))
			boutput(holder.owner, SPAN_ALERT("It's too dangerous to blink there!"))
			return
		animate_blink(holder.owner)
		holder.owner.set_loc(picked)
