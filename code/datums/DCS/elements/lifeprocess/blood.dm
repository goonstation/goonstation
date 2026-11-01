/datum/element/lifeprocess/blood/process(mob/living/target, datum/gas_mixture/environment)
	if (!global.blood_system)
		return

	if (isdead(target) || target.nodamage || !target.can_bleed || isvampire(target))
		target.bleeding = 0
		return

	var/datum/reagents/reagents = target.reagents
	var/mult = src.get_multiplier(target)

	// This early return fires for the majority of the time this proc is called.
	if (target.last_tick_regular_blood_range && (target.blood_volume == 500) && (reagents?.total_volume <= 0))
		src.calc_bloodpressure(target, 500)
		return

	var/anticoag_amt = 0
	var/coag_amt = 0
	if (reagents?.total_volume > 0)
		anticoag_amt = reagents.get_reagent_amount("heparin") + (reagents.get_reagent_amount("acetylsalicylic_acid") / 2) + (reagents.get_reagent_amount("ginger") / 3)
		coag_amt = reagents.get_reagent_amount("proconvertin")

	//------------ Bleeding Handling ------------//
	if (target.bleeding)
		// Odds that a mob's bleeding naturally heals.
		var/decrease_chance = 0
		// Odds that a mob's bleeding gets worse due to open cuts or surgury.
		var/surgery_increase_chance = 5

		// Small bleeds passively heal. Critters always passively heal.
		if ((target.bleeding < 4) || iscritter(target))
			decrease_chance += 3
		else
			surgery_increase_chance += 10

		// Coagulants and anticoagulants.
		if (anticoag_amt)
			decrease_chance -= 5
		if (coag_amt)
			decrease_chance += 5

		if (target.get_surgery_status())
			decrease_chance -= 1

			if (probmult(surgery_increase_chance))
				target.bleeding += 1

		// Low gravity reduces bleed chance.
		if ((target.gforce < 1) && !target.is_spacefaring())
			decrease_chance -= round(3 * (1 - target.gforce))

		if (probmult(decrease_chance))
			target.bleeding -= 1
			var/feeling = pick(
				"better",
				"like they're healing a bit",
				"a little better",
				"itchy",
				"less tender",
				"less painful",
				"like they're closing",
				"like they're closing up a bit",
				"like they're closing up a little",
			)
			boutput(target, SPAN_NOTICE("Your wounds feel [feeling]."))

		target.bleeding = clamp(target.bleeding, 0, 5)

		if (target.blood_volume)
			var/final_bleed = target.bleeding
			if (anticoag_amt)
				final_bleed += round(clamp((anticoag_amt / 10), 0, 2), 1)

			// Very little blood left. More bleed just means it's less likely they get a transfusion.
			if (target.blood_volume < 200)
				final_bleed *= 0.25
			// Less blood to bleed.
			else if (target.blood_volume < 300)
				final_bleed *= 0.75

			// Low gravity increases blood volume loss.
			if (target.gforce < 1)
				final_bleed *= (2 - target.gforce)

			final_bleed *= mult

			// Up to a 50% chance to make a large bloodsplatter.
			var/vis_amount = 0
			if (prob(clamp(final_bleed, 0, 10) * 5))
				vis_amount = 5
			else switch (target.bleeding)
				if (1)
					vis_amount = 1
				if (2)
					vis_amount = 2
				if (3 to 4)
					vis_amount = 3
				if (5)
					vis_amount = 4

			global.bleed(target, final_bleed, vis_amount)

	if (iscritter(target) && !HAS_ATOM_PROPERTY(target, PROP_MOB_NO_BLOOD_REGEN))
		// Gain a little if under-pressure.
		if ((target.blood_volume > 0) && (target.blood_volume < 500))
			target.blood_volume += 2 * mult
		// Lose a little if over-pressure.
		else if ((target.blood_volume > 500) && prob(20))
			target.blood_volume -= 1 * mult

	//------------ Blood Pressure Handling ------------//
	// Clean up negative blood amounts and start calculating effective blood levels. Done *after* bleeding.
	var/blood_amt = target.blood_volume = max(target.blood_volume, 0)

	if (reagents?.total_volume > 0)
		var/cholesterol_amt = reagents.get_reagent_amount("cholesterol")
		var/gnesis_amt = reagents.get_reagent_amount("flockdrone_fluid")

		/*
			Add a quarter of total reagent volume to the effective blood amount, excluding coagulants, anticoagulants,
			cholesterol, and gnesis.
			Coagulants, cholesterol, and gnesis count towards the effective volume, while anticoagulants count against it.
		*/
		var/inert_volume = reagents.total_volume - ((anticoag_amt + coag_amt + cholesterol_amt + gnesis_amt) * mult)
		blood_amt += inert_volume / 4
		blood_amt += (coag_amt + cholesterol_amt + (gnesis_amt / 2) - anticoag_amt) * mult

	blood_amt = round(blood_amt, 1)
	src.calc_bloodpressure(target, blood_amt)

	// Changelings care not for blood pressure effects.
	if (ischangeling(target))
		return

	// Handle bloodgibbing. 0% change at 1000u, 100% at 2000u, linear scaling.
	if ((blood_amt >= 1000) && !HAS_ATOM_PROPERTY(target, PROP_MOB_BLOODGIB_IMMUNE) && prob((blood_amt - 1000) / 10))
		target.visible_message(SPAN_ALERT("<b>[target] bursts like a bloody balloon! Holy fucking shit!!</b>"))
		logTheThing(LOG_COMBAT, target, "gibbed due to having over 1000 units of blood at [log_loc(target)].")
		target.gib(TRUE)
		return

	switch (blood_amt)
		// Negative blood. Somehow.
		if (-INFINITY to 1)
			target.take_oxygen_deprivation(1 * mult)
			target.change_eye_blurry(7, 7)
			target.take_brain_damage(2 * mult)
			target.losebreath += (1 * mult)
			target.setStatus("drowsy", rand(15, 20) SECONDS)

			if (prob(10))
				target.change_misstep_chance(rand(3, 4) * mult)
			if (prob(10))
				target.emote(pick("faint", "collapse", "pale", "shudder", "shiver", "gasp", "moan"))
			if (prob(18))
				var/extreme = pick("", "really ", "very ", "extremely ", "terribly ", "insanely ")
				var/feeling = pick("[extreme]ill", "[extreme]sick", "[extreme]numb", "[extreme]cold", "[extreme]dizzy", "[extreme]out of it", "[extreme]confused", "[extreme]off-balance", "[extreme]terrible", "[extreme]awful", "like death", "like you're dying", "[extreme]tingly", "like you're going to pass out", "[extreme]faint")
				boutput(target, SPAN_ALERT("<b>You feel [feeling]!</b>"))
				target.changeStatus("knockdown", 4 SECONDS * mult)
			if (prob(30))
				target.changeStatus("shivering", 6 SECONDS)

			// If the target has no blood, they're going to be in shock.
			target.contract_disease(/datum/ailment/malady/shock, null, null, 1)
			APPLY_ATOM_PROPERTY(target, PROP_MOB_STAMINA_REGEN_BONUS, "hypotension", -3)
			target.add_stam_mod_max("hypotension", -15)

		// Very low: (70/50)
		if (1 to 300)
			target.take_oxygen_deprivation(0.8 * mult)
			target.take_brain_damage(0.8 * mult)
			target.losebreath += (0.8 * mult)
			target.change_eye_blurry(5, 5)
			target.setStatus("drowsy", rand(5, 10) SECONDS)

			if (prob(6))
				target.change_misstep_chance(rand(1, 2) * mult)
			if (prob(8))
				target.emote(pick("faint", "collapse", "pale", "shudder", "gasp", "moan"))
			if (prob(14))
				var/extreme = pick("", "really ", "very ", "extremely ", "terribly ", "insanely ")
				var/feeling = pick("[extreme]ill", "[extreme]sick", "[extreme]numb", "[extreme]cold", "[extreme]dizzy", "[extreme]out of it", "[extreme]confused", "[extreme]off-balance", "[extreme]terrible", "[extreme]awful", "like death", "like you're dying", "[extreme]tingly", "like you're going to pass out", "[extreme]faint")
				boutput(target, SPAN_ALERT("<b>You feel [feeling]!</b>"))
				target.changeStatus("knockdown", 3 SECONDS * mult)
			if (prob(25))
				// Getting very cold (same duration as shivers from cold).
				target.changeStatus("shivering", 6 SECONDS)
			if (prob(25))
				target.contract_disease(/datum/ailment/malady/shock, null, null, 1)

			APPLY_ATOM_PROPERTY(target, PROP_MOB_STAMINA_REGEN_BONUS, "hypotension", -2)
			target.add_stam_mod_max("hypotension", -10)

		// Low: (100/65)
		if (300 to 415)
			if (prob(2))
				// Additional shivers handled by the status effect.
				target.emote(pick("pale", "shudder"))
			if (prob(5))
				var/extreme = pick("", "kinda ", "a little ", "sorta ", "a bit ")
				var/feeling = pick("ill", "sick", "numb", "cold", "dizzy", "out of it", "confused", "off-balance", "tingly", "faint")
				boutput(target, SPAN_ALERT("<b>You feel [extreme][feeling]!</b>"))
			if (prob(5))
				target.contract_disease(/datum/ailment/malady/shock, null, null, 1)
			if (prob(15))
				// Drowsiness and stuttering.
				target.setStatus("drowsy", 6 SECONDS * mult)
				target.stuttering += rand(6,10)
			else if (probmult(20))
				// Feeling cold from low blood pressure
				target.changeStatus("shivering", 6 SECONDS)
				target.change_eye_blurry(5, 5)

			APPLY_ATOM_PROPERTY(target, PROP_MOB_STAMINA_REGEN_BONUS, "hypotension", -1)
			target.add_stam_mod_max("hypotension", -5)

		// Normal: (120/80)
		if (415 to 585)
			if (target.last_tick_regular_blood_range)
				return

			REMOVE_ATOM_PROPERTY(target, PROP_MOB_STAMINA_REGEN_BONUS, "hypertension")
			REMOVE_ATOM_PROPERTY(target, PROP_MOB_STAMINA_REGEN_BONUS, "hypotension")
			target.remove_stam_mod_max("hypertension")
			target.remove_stam_mod_max("hypotension")

			target.last_tick_regular_blood_range = TRUE
			return

		// High: (140/90)
		if (585 to 666)
			if (prob(2))
				boutput(target, SPAN_ALERT(pick(
					"You feel kinda sweaty.",
					"You can feel your heart beat loudly in your chest.",
					"Your head hurts.",
				)))
			if (prob(1))
				target.losebreath += (1 * mult)
			if (prob(1))
				target.emote("gasp")
			if (prob(1) && prob(10))
				target.contract_disease(/datum/ailment/malady/heartdisease, null, null, 1)

			APPLY_ATOM_PROPERTY(target, PROP_MOB_STAMINA_REGEN_BONUS, "hypertension", -1)
			target.add_stam_mod_max("hypertension", -5)

		// Very high: (160/100)
		if (666 to 750)
			if (prob(2))
				boutput(target, SPAN_ALERT(pick(
					"You feel sweaty.",
					"Your heart beats rapidly.",
					"Your head hurts badly.",
					"Your chest hurts.",
				)))
			if (prob(3))
				target.losebreath += (1 * mult)
			if (prob(2))
				target.emote("gasp")
			if (prob(1))
				target.contract_disease(/datum/ailment/malady/heartdisease, null, null, 1)

			APPLY_ATOM_PROPERTY(target, PROP_MOB_STAMINA_REGEN_BONUS, "hypertension", -2)
			target.add_stam_mod_max("hypertension", -10)

		// Critically high: (180/110)
		if (750 to INFINITY)
			if (prob(5))
				boutput(target, SPAN_ALERT(pick(
					"You feel really sweaty.",
					"Your heart pounds in your chest.",
					"Your head pounds with pain.",
					"Your chest hurts badly.",
					"It's hard to breathe.",
				)))
			if (prob(5))
				target.losebreath += (1 * mult)
			if (prob(2))
				target.take_eye_damage(1)
			if (prob(3))
				target.emote("gasp")
			if (prob(5))
				target.contract_disease(/datum/ailment/malady/heartdisease, null, null, 1)
			if (prob(2))
				target.visible_message(SPAN_ALERT("[target] coughs up a little blood!"))
				playsound(target, 'sound/impact_sounds/Slimy_Splat_1.ogg', 30, TRUE)
				global.bleed(target, rand(1, 2) * mult, 1)

			APPLY_ATOM_PROPERTY(target, PROP_MOB_STAMINA_REGEN_BONUS, "hypertension", -3)
			target.add_stam_mod_max("hypertension", -15)

	target.last_tick_regular_blood_range = FALSE

/// Calculate blood pressure readout statistics for a target.
/datum/element/lifeprocess/blood/proc/calc_bloodpressure(mob/living/target, blood_amt)
	var/systolic = round((blood_amt * 0.24), 1)
	var/diastolic = round((blood_amt * 0.16), 1)

	var/status = null
	if (blood_amt < 415)
		status = "HYPOTENSIVE"
	else if (blood_amt > 584)
		status = "HYPERTENSIVE"
	else
		status = "NORMAL"

	target.blood_pressure = list(
		"systolic"	= systolic,
		"diastolic"	= diastolic,
		"rendered"	= "[max(systolic + rand(-5, 5), 0)]/[max(diastolic + rand(-2, 2), 0)]",
		"total"		= blood_amt,
		"status"	= status,
	)
