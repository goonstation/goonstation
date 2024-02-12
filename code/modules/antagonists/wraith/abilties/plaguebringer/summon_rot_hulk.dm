/datum/targetable/wraithAbility/summon_rot_hulk
	name = "Create rot hulk"
	desc = "Assimilate the filth in an area and create an unstable servant."
	icon_state = "summongoo"
	targeted = 0
	cooldown = 90 SECONDS
	pointCost = 120
	var/const/max_decals = 40
	var/const/min_decals = 10
	var/const/strong_exploder_threshold = 30
	var/list/decal_list = list(/obj/decal/cleanable/blood,
	/obj/decal/cleanable/ketchup,
	/obj/decal/cleanable/rust,
	/obj/decal/cleanable/vomit,
	/obj/decal/cleanable/greenpuke,
	/obj/decal/cleanable/slime,
	/obj/decal/cleanable/fungus)

	cast()
		if (..())
			return 1

		var/decal_count = 0
		var/list/found_decal_list = list()
		for (var/obj/decal/cleanable/found_cleanable in range(3, get_turf(holder.owner)))
			if (istypes(found_cleanable, decal_list))
				found_decal_list += found_cleanable
				decal_count++
				if (length(found_decal_list) >= max_decals)
					break
		if (length(found_decal_list) > min_decals)
			holder.owner.playsound_local(holder.owner, "sound/voice/wraith/wraithraise[pick("1","2","3")].ogg", 80)
			var/turf/T = get_turf(holder.owner)
			T.visible_message(SPAN_ALERT("All the filth and grime around begins to writhe and move!"))
			SPAWN(0)
				for(var/obj/decal/cleanable/C in found_decal_list)
					if (!C?.loc) continue
					step_towards(C,T)
				sleep(2 SECOND)
				for(var/obj/decal/cleanable/C in found_decal_list)
					if (!C?.loc) continue
					step_towards(C,T)
				sleep(1.5 SECOND)
				for(var/obj/decal/cleanable/C in found_decal_list)
					if (!C?.loc) continue
					step_towards(C,T)
				sleep(1 SECOND)
				if (decal_count >= strong_exploder_threshold)
					var/mob/living/critter/exploder/strong/E = new /mob/living/critter/exploder/strong(T)
					animate_portal_tele(E)
					T.visible_message(SPAN_ALERT("A [E] slowly emerges from the gigantic pile of grime!"))
					boutput(holder.owner, "The great amount of filth coalesces into a rotting goliath")
				else
					var/mob/living/critter/exploder/E = new /mob/living/critter/exploder(T)
					animate_portal_tele(E)
					T.visible_message(SPAN_ALERT("A [E] slowly rises up from the coalesced filth!"))
					boutput(holder.owner, "The filth accumulates into a living bloated abomination")
				for(var/obj/decal/cleanable/C as anything in found_decal_list)
					qdel(C)
			return 0
		else
			boutput(holder.owner, SPAN_ALERT("This place is much too clean to summon a rot hulk."))
			return 1
