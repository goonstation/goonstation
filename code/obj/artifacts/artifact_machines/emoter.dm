/obj/machinery/artifact/emoter
	name = "artifact emote field"
	associated_datum = /datum/artifact/emoter
	processing_tier = PROCESSING_QUARTER

/datum/artifact/emoter
	associated_object = /obj/machinery/artifact/emoter
	type_name = "Emote-stimulation Field" //this was brown note originally
	type_size = ARTIFACT_SIZE_LARGE
	rarity_weight = 350
	validtypes = list("martian","eldritch","precursor")
	validtriggers = list(/datum/artifact_trigger/force,/datum/artifact_trigger/radiation,/datum/artifact_trigger/carbon_touch,/datum/artifact_trigger/silicon_touch,
		/datum/artifact_trigger/language)
	fault_blacklist = list(ITEM_ONLY_FAULTS,TOUCH_ONLY_FAULTS)
	activ_text = "opens up, revealing a strange horn!"
	deact_text = "closes itself up."
	react_xray = list(8,60,80,6,"TUBULAR")
	var/range
	var/picked_emote
	var/recharge_time

	post_setup()
		. = ..()

		switch(artitype.name)
			if ("martian")
				//"organic" stuff
				picked_emote = pick("scream","fart","burp","twitch_v","retch","pale","gurgle","gasp","yawn","choke","wheeze","sneeze","groan","hiccup","cough","shiver","shake","tremble","shrug","drool")
			if ("eldritch")
				//"terror"
				picked_emote = pick("scream","dance","tantrum","smug","flex","facepalm","panic","cry","rude","rage","flipout","wail","whine","sob","weep","gasp")
			else
				picked_emote = pick("scream","dance","tantrum","smug","flex","facepalm","panic","cry","rude","rage","flipout","wail","whine","sob","weep","gasp","trip","fart","burp","retch","pale","gurgle","gasp","yawn","choke","wheeze","sneeze","groan","hiccup","cough","shiver","shake","tremble","shrug","drool")

		switch(artitype.name)
			if ("precursor")
				range = rand(2,10)
				recharge_time = rand(1,20) SECONDS
			else
				recharge_time = rand(2,10) SECONDS
				range = rand(2,5)

	effect_process(var/obj/O)
		if (..())
			return
		if (ON_COOLDOWN(O, "emoter" , recharge_time))
			return

		var/turf/T = get_turf(O)
		T.visible_message("<b>[O]</b> emits a weird noise!")

		var/count = 0
		for (var/mob/living/L in range(range,O))
			if (L.hearing_check(1))
				if(count++ > 15) break
				if(picked_emote == "fart")
					if(!(locate(/obj/item/bible) in get_turf(L))) //bible fart bad
						L.emote(picked_emote, FALSE)
				else
					L.emote(picked_emote, FALSE)
