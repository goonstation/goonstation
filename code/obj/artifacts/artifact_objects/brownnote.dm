/obj/artifact/brownnote
	name = "artifact brownnote"
	associated_datum = /datum/artifact/brownnote

/datum/artifact/brownnote
	associated_object = /obj/artifact/brownnote
	type_name = "Brown Note"
	rarity_weight = 350
	validtypes = list("martian","eldritch","precursor")
	validtriggers = list(/datum/artifact_trigger/force,/datum/artifact_trigger/radiation,/datum/artifact_trigger/carbon_touch,/datum/artifact_trigger/silicon_touch)
	fault_blacklist = list(ITEM_ONLY_FAULTS)
	activ_text = "opens up, revealing a strange horn!"
	deact_text = "closes itself up."
	react_xray = list(8,60,80,6,"TUBULAR")
	var/fart_range = 10
	var/recharge_time = 10 SECONDS

	post_setup()
		. = ..()
		switch(artitype.name)
			if ("precursor")
				fart_range = rand(2,30) // What could possibly go wrong?
			else
				fart_range = rand(5,10)

	effect_touch(var/obj/O,var/mob/living/user)
		if (..())
			return
		var/turf/T = get_turf(O)
		if (ON_COOLDOWN(O, "brownnote_art" , recharge_time))
			boutput(user, "<span class='alert'>The artifact emits a weak toot, but nothing else happens.</span>")
			return
		T.visible_message("<b>[O]</b> emits a weird noise!")
		playsound(O.loc, 'sound/musical_instruments/WeirdHorn_0.ogg', 50, 0)
		var/count = 0
		for (var/mob/living/L in range(7,O))
			if (L.hearing_check(1))
				if(count++ > 15) break
				if(!(locate(/obj/item/storage/bible) in get_turf(L)))
					L.emote("fart")
		O.ArtifactFaultUsed(user)
