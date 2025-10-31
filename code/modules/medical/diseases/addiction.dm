// Addiction with comically-exaggerated withdrawal effects!

/datum/ailment/addiction
	name = "reagent addiction"
	scantype = "Chemical Dependency"
	max_stages = 5
	stage_prob = 3
	cure_flags = CURE_CUSTOM
	cure_desc = "Time, moderation, therapy"
	affected_species = list("Human")
	strain_type = /datum/ailment_data/addiction

	setup_strain(var/reagent, var/mob/living/target, var/severity_override = null)
		var/datum/ailment_data/addiction/addiction = ..()
		if (!addiction)
			return
		var/datum/reagent/rgnt
		if (istype(reagent, /datum/reagent))
			rgnt = reagent
		else if (istext(reagent))
			rgnt = reagents_cache[reagent]
		if (!rgnt) // if something isn't right, we have to fall back on a default in order to return something
			stack_trace("Addiction failed to find reagent \"[reagent]\" (type: [string_type_of_anything(reagent)]) when setting up for \
							[target] ([target?.ckey || "no ckey"]). Falling back to a default.")
			rgnt = reagents_cache["gcheese"]
			addiction.name = "[rgnt.name] addiction (This addiction has bugged)"
		else
			addiction.name = "[rgnt.name] addiction"

		addiction.associated_reagent = rgnt.name
		addiction.last_reagent_dose = TIME
		addiction.severity = isnull(severity_override) ? rgnt.addiction_severity : severity_override
		addiction.addiction_meter = max(target?.reagents?.addiction_tally[rgnt.id], 10)
		addiction.depletion_rate = addiction.depletion_rate ? addiction.depletion_rate : generate_depletion_rate(rgnt)
		return addiction

	/// Generate a depletion rate for the addiction based on the associated reagent.
	proc/generate_depletion_rate(var/datum/reagent/rgnt)
		// with a default of 0.4, this'll deplete at 3 points every minute. A 15-unit addiction will last 5 minutes, a 100-unit addiction would last
		// around half an hour.
		return max(0.01, rgnt.depletion_rate * 0.25)


	stage_act(var/mob/living/affected_mob, var/datum/ailment_data/addiction/D, mult)
		if (..())
			return
		D.addiction_meter -= D.depletion_rate * mult
		if (D.addiction_meter <= 0)
			boutput(affected_mob, SPAN_NOTICE("You no longer feel reliant on [D.associated_reagent]!"))
			affected_mob.ailments -= D
			qdel(D)
			return
		switch(D.stage)
			if (2)
				stage_two_effects(affected_mob, D)
			if (3)
				stage_three_effects(affected_mob, D)
			if (4)
				stage_four_effects(affected_mob, D)
			if (5)
				stage_five_effects(affected_mob, D)

	proc/stage_two_effects(var/mob/living/affected_mob, var/datum/ailment_data/addiction/D)
		if (prob(8))
			affected_mob.emote("shiver")
		if (prob(8))
			affected_mob.emote("sneeze")
		if (prob(4))
			boutput(affected_mob, SPAN_NOTICE("You feel a dull headache."))

	proc/stage_three_effects(var/mob/living/affected_mob, var/datum/ailment_data/addiction/D)
		if (prob(8))
			affected_mob.emote("twitch_s")
		if (prob(8))
			affected_mob.emote("shiver")
		if (prob(4))
			boutput(affected_mob, SPAN_ALERT("Your head hurts."))
		if (prob(4))
			boutput(affected_mob, SPAN_ALERT("You begin craving [D.associated_reagent]!"))

	proc/stage_four_effects(var/mob/living/affected_mob, var/datum/ailment_data/addiction/D)
		if (prob(8))
			affected_mob.emote("twitch")
		if (prob(4))
			boutput(affected_mob, SPAN_ALERT("You have a pounding headache."))
		if (prob(4))
			boutput(affected_mob, SPAN_ALERT("You have the strong urge for some [D.associated_reagent]!"))
		else if (prob(4))
			boutput(affected_mob, SPAN_ALERT("You REALLY crave some [D.associated_reagent]!"))

	proc/stage_five_effects(var/mob/living/affected_mob, var/datum/ailment_data/addiction/D)
		if (D.severity == LOW_ADDICTION_SEVERITY)
			if (prob(5))
				affected_mob.changeStatus("slowed", 3 SECONDS)
				boutput(affected_mob, SPAN_ALERT("You feel [pick("tired", "exhausted", "sluggish")]."))
		else // D.max_severity is HIGH or whatever
			if (prob(5) && !affected_mob.hasStatus("slowed"))
				affected_mob.changeStatus("slowed", 6 SECONDS)
				boutput(affected_mob, SPAN_ALERT("You feel [pick("tired", "exhausted", "sluggish")]."))
			else if (prob(4))
				affected_mob.change_eye_blurry(rand(7, 10))
				boutput(affected_mob, SPAN_ALERT("Your vision blurs, you REALLY need some [D.associated_reagent]."))
			else if (prob(20))
				affected_mob.nauseate(1)
		if (prob(8))
			affected_mob.emote(pick("twitch", "twitch_s", "shiver"))
		if (prob(4))
			boutput(affected_mob, SPAN_ALERT("Your head is killing you!"))
		if (prob(5))
			boutput(affected_mob, SPAN_ALERT("You feel like you can't live without [D.associated_reagent]!"))
		else if (prob(5))
			boutput(affected_mob, SPAN_ALERT("You would DIE for some [D.associated_reagent] right now!!"))
