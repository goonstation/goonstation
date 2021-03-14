/obj/artifact/healer_bio
	name = "artifact carbon healer"
	associated_datum = /datum/artifact/healer_bio

/datum/artifact/healer_bio
	associated_object = /obj/artifact/healer_bio
	type_name = "Healer"
	rarity_weight = 350
	validtypes = list("martian","precursor")
	validtriggers = list(/datum/artifact_trigger/force,/datum/artifact_trigger/electric,/datum/artifact_trigger/heat,
	/datum/artifact_trigger/radiation,/datum/artifact_trigger/carbon_touch)
	fault_blacklist = list(ITEM_ONLY_FAULTS)
	activated = 0
	activ_text = "begins to pulse softly."
	deact_text = "ceases pulsing."
	react_xray = list(11,70,90,9,"NONE")
	var/heal_amt = 20
	var/field_range = 0
	var/recharge_time = 600
	var/recharging = 0

	New()
		..()
		src.react_heat[2] = "SUPERFICIAL DAMAGE DETECTED"
		if(prob(20))
			src.field_range = rand(3,10) // range
		src.heal_amt = rand(5,75) // amount of healing
		src.recharge_time = rand(1,10) * 10
		if(prob(5))
			src.recharge_time = 0

	effect_touch(var/obj/O,var/mob/living/user)
		if (..())
			return
		if (!user)
			return
		var/turf/T = get_turf(O)
		if (recharging)
			boutput(user, "<span class='alert'>The artifact pulses briefly, but nothing else happens.</span>")
			return
		if (recharge_time > 0)
			recharging = 1
		T.visible_message("<b>[O]</b> emits a wave of energy!")
		if(iscarbon(user))
			var/mob/living/carbon/C = user
			C.HealDamage("All", heal_amt, heal_amt)
			O.ArtifactFaultUsed(C)
			boutput(C, "<span class='notice'>Soothing energy saturates your body, making you feel refreshed and healthy.</span>")
		if (field_range > 0)
			for (var/mob/living/carbon/C in range(field_range,T))
				if (C == user)
					continue
				C.HealDamage("All", heal_amt, heal_amt)
				O.ArtifactFaultUsed(C)
				boutput(C, "<span class='notice'>Waves of soothing energy wash over you, making you feel refreshed and healthy.</span>")
		SPAWN_DBG(recharge_time)
			recharging = 0
			T.visible_message("<b>[O]</b> becomes energized.")
