
/datum/lifeprocess/blood
	/// if during the last tick of the process, the owner's blood was in the baseline range
	var/last_tick_regular_blood_range = FALSE

	process(var/datum/gas_mixture/environment)
		if (!blood_system) // I dunno if this'll do what I want but hopefully it will
			return ..()

		if (isdead(owner) || owner.nodamage || !owner.can_bleed || isvampire(owner))
			if (owner.bleeding)
				owner.bleeding = 0
			return ..()

		var/mult = get_multiplier()

		// early return for a majority this proc is ran
		if (src.owner.blood_volume == 500 && src.last_tick_regular_blood_range && src.owner.reagents?.total_volume <= 0)
			src.calc_bloodpressure(500)
			return

		var/anticoag_amt = 0
		var/coag_amt = 0
		if (owner.reagents?.total_volume > 0)
			anticoag_amt = owner.reagents.get_reagent_amount("heparin")
			coag_amt = owner.reagents.get_reagent_amount("proconvertin")

		if (owner.bleeding)
			/// odds that your bleeding naturally heals
			var/decrease_chance = 0
			var/surgery_increase_chance = 5 //likelihood we bleed more bc we are being surgeried or have open cuts

			if (owner.bleeding < 4) //let small bleeds passively heal
				decrease_chance += 3
			else
				surgery_increase_chance += 10


			if (anticoag_amt) // anticoagulant
				decrease_chance -= 5
			if (coag_amt) // coagulant
				decrease_chance += 5

			if (owner.get_surgery_status())
				decrease_chance -= 1

			if (probmult(decrease_chance))
				owner.bleeding -= 1
				boutput(owner, SPAN_NOTICE("Your wounds feel [pick("better", "like they're healing a bit", "a little better", "itchy", "less tender", "less painful", "like they're closing", "like they're closing up a bit", "like they're closing up a little")]."))

			if (probmult(surgery_increase_chance) && owner.get_surgery_status())
				owner.bleeding += 1

			owner.bleeding = clamp(owner.bleeding, 0, 5)

			if (owner.blood_volume)
				var/final_bleed = clamp(owner.bleeding, 0, 5)
				if (anticoag_amt)
					final_bleed += round(clamp((anticoag_amt / 10), 0, 2), 1)
				if (owner.blood_volume < 200)
					final_bleed *= 0.25 // this guy's basically dead anyway. more bleed just means its less likely they get a transfusion
				else if (owner.blood_volume < 300)
					final_bleed *= 0.75 // less blood to bleed. negative blood fx taking place
				if (istype(owner.loc, /obj/machinery/atmospherics/unary/cryo_cell))
					var/obj/machinery/atmospherics/unary/cryo_cell/cryo = owner.loc
					if (cryo.air_contents.temperature < 210)
						final_bleed = 0 // wounds frozen shut, but aren't healing
				final_bleed *= mult
				if (prob(clamp(final_bleed, 0, 10) * 5)) // up to 50% chance to make a big bloodsplatter
					bleed(owner, final_bleed, 5)

				else
					switch (owner.bleeding)
						if (1)
							bleed(owner, final_bleed, 1) // this proc creates a bloodsplatter on src's tile
						if (2)
							bleed(owner, final_bleed, 2) // it takes care of removing blood, and transferring reagents, color and ling status to the blood
						if (3 to 4)
							bleed(owner, final_bleed, 3) // see blood_system.dm for the proc
						if (5)
							bleed(owner, final_bleed, 4)

		if (critter_owner)
			if (critter_owner.blood_volume < 500 && critter_owner.blood_volume > 0) // if we're full or empty, don't bother v
				if (prob(66))
					critter_owner.blood_volume += 1 * mult // maybe get a little blood back ^
			else if (critter_owner.blood_volume > 500)
				if (prob(20))
					critter_owner.blood_volume -= 1 * mult

		owner.blood_volume = max(0, owner.blood_volume) //clean up negative blood amounts here. Lazy fix, but easier than cleaning up every place that blood is removed
		var/current_blood_amt = owner.blood_volume
		if (owner.reagents?.total_volume > 0)
			current_blood_amt += owner.reagents.total_volume / 4 // dropping how much reagents count so that people stop going hypertensive at the drop of a hat
			var/cho_amt = owner.reagents.get_reagent_amount("cholesterol")
			var/gnesis_amt = owner.reagents.get_reagent_amount("flockdrone_fluid")
			if (anticoag_amt)
				current_blood_amt -= ((anticoag_amt / 4) + anticoag_amt) * mult// set the total back to what it would be without the heparin, then remove the total of the heparin
			if (coag_amt)
				current_blood_amt -= (coag_amt / 4) * mult // set the blood total to what it would be without the proconvertin in it
				current_blood_amt += coag_amt * mult// then add the actual total of the proconvertin back so it counts for 4x what the other chems do
			if (cho_amt)
				current_blood_amt -= (cho_amt / 4) * mult // same as proconvertin above
				current_blood_amt += cho_amt * mult
			if (gnesis_amt)
				current_blood_amt -= (gnesis_amt / 4) * mult
				current_blood_amt += (gnesis_amt / 2) * mult //makes it stay somewhat constant with regular spleen and conversion so you wont feel the effects of blood loss. since gnesis is flock blood and this is human blood so it must be similar right?
		current_blood_amt = round(current_blood_amt, 1)

		// very low (70/50 or lower) (<300u)
		// low (100/65) (<415u)
		// normal (120/80) (500u)
		// high (stage 1) (140/90 or higher) (>585u)
		// very high (stage 2) (160/100 or higher) (>666u)
		// dangerously high (urgency) (180/110 or higher) (>750u)
		src.calc_bloodpressure(current_blood_amt)

		if (ischangeling(owner))
			return ..()

		//special case
		if (current_blood_amt >= 1000 && !HAS_ATOM_PROPERTY(owner, PROP_MOB_BLOODGIB_IMMUNE))
			if (prob(clamp((current_blood_amt - 1000)/10, 0, 100))) //0% at 1000, 100% at 2000, linear scaling
				owner.visible_message(SPAN_ALERT("<b>[owner] bursts like a bloody balloon! Holy fucking shit!!</b>"))
				logTheThing(LOG_COMBAT, owner, "gibbed due to having over 1000 units of blood at [log_loc(src)].")
				owner.gib(TRUE) // :v
				return ..()

		if (isdead(owner))
			return ..()

		if (current_blood_amt >= 415 && current_blood_amt <= 585)
			if (src.last_tick_regular_blood_range)
				return ..()
			REMOVE_ATOM_PROPERTY(owner, PROP_MOB_STAMINA_REGEN_BONUS, "hypertension")
			REMOVE_ATOM_PROPERTY(owner, PROP_MOB_STAMINA_REGEN_BONUS, "hypotension")
			owner.remove_stam_mod_max("hypertension")
			owner.remove_stam_mod_max("hypotension")
			src.last_tick_regular_blood_range = TRUE
			return ..()
		else
			last_tick_regular_blood_range = FALSE
			switch (current_blood_amt)
				if (-INFINITY to 1) // welp
					owner.take_oxygen_deprivation(1 * mult)
					owner.change_eye_blurry(7, 7)
					owner.take_brain_damage(2 * mult)
					owner.losebreath += (1 * mult)
					owner.setStatus("drowsy", rand(15, 20) SECONDS)
					if (prob(10))
						owner.change_misstep_chance(rand(3,4) * mult)
					if (prob(10))
						owner.emote(pick("faint", "collapse", "pale", "shudder", "shiver", "gasp", "moan"))
					if (prob(18))
						var/extreme = pick("", "really ", "very ", "extremely ", "terribly ", "insanely ")
						var/feeling = pick("[extreme]ill", "[extreme]sick", "[extreme]numb", "[extreme]cold", "[extreme]dizzy", "[extreme]out of it", "[extreme]confused", "[extreme]off-balance", "[extreme]terrible", "[extreme]awful", "like death", "like you're dying", "[extreme]tingly", "like you're going to pass out", "[extreme]faint")
						boutput(owner, SPAN_ALERT("<b>You feel [feeling]!</b>"))
						owner.changeStatus("knockdown", 4 SECONDS * mult)
					if (prob(30))
						owner.changeStatus("shivering", 6 SECONDS)
					owner.contract_disease(/datum/ailment/malady/shock, null, null, 1) // if you have no blood you're gunna be in shock
					APPLY_ATOM_PROPERTY(owner, PROP_MOB_STAMINA_REGEN_BONUS, "hypotension", -3)
					owner.add_stam_mod_max("hypotension", -15)

				if (1 to 300) // very low (70/50)
					owner.take_oxygen_deprivation(0.8 * mult)
					owner.take_brain_damage(0.8 * mult)
					owner.losebreath += (0.8 * mult)
					owner.change_eye_blurry(5, 5)
					owner.setStatus("drowsy", rand(5, 10) SECONDS)
					if (prob(6))
						owner.change_misstep_chance(rand(1,2) * mult)
					if (prob(8))
						owner.emote(pick("faint", "collapse", "pale", "shudder", "gasp", "moan"))
					if (prob(14))
						var/extreme = pick("", "really ", "very ", "extremely ", "terribly ", "insanely ")
						var/feeling = pick("[extreme]ill", "[extreme]sick", "[extreme]numb", "[extreme]cold", "[extreme]dizzy", "[extreme]out of it", "[extreme]confused", "[extreme]off-balance", "[extreme]terrible", "[extreme]awful", "like death", "like you're dying", "[extreme]tingly", "like you're going to pass out", "[extreme]faint")
						boutput(owner, SPAN_ALERT("<b>You feel [feeling]!</b>"))
						owner.changeStatus("knockdown", 3 SECONDS * mult)
					if (prob(25))
						owner.changeStatus("shivering", 6 SECONDS) // Getting very cold (same duration as shivers from cold)
					if (prob(25))
						owner.contract_disease(/datum/ailment/malady/shock, null, null, 1)
					APPLY_ATOM_PROPERTY(owner, PROP_MOB_STAMINA_REGEN_BONUS, "hypotension", -2)
					owner.add_stam_mod_max("hypotension", -10)

				if (300 to 415) // low (100/65)
					if (prob(2))
						owner.emote(pick("pale", "shudder")) // Additional shivers handled by the status effect
					if (prob(5))
						var/extreme = pick("", "kinda ", "a little ", "sorta ", "a bit ")
						var/feeling = pick("ill", "sick", "numb", "cold", "dizzy", "out of it", "confused", "off-balance", "tingly", "faint")
						boutput(owner, SPAN_ALERT("<b>You feel [extreme][feeling]!</b>"))
					if (prob(5))
						owner.contract_disease(/datum/ailment/malady/shock, null, null, 1)
					if (prob(15))
						owner.setStatus("drowsy", 6 SECONDS * mult) // Drowsiness and stuttering
						owner.stuttering += rand(6,10)
					else if (probmult(20))
						owner.changeStatus("shivering", 6 SECONDS) // Feeling cold from low blood pressure
						owner.change_eye_blurry(5, 5)
					APPLY_ATOM_PROPERTY(owner, PROP_MOB_STAMINA_REGEN_BONUS, "hypotension", -1)
					owner.add_stam_mod_max("hypotension", -5)

				//if (415 to 585) // normal (120/80)
				// note: covered first for performance, before the switch

				if (585 to 666) // high (140/90)
					if (prob(2))
						var/msg = pick("You feel kinda sweaty",\
						"You can feel your heart beat loudly in your chest",\
						"Your head hurts")
						boutput(owner, SPAN_ALERT("[msg]."))
					if (prob(1))
						owner.losebreath += (1 * mult)
					if (prob(1))
						owner.emote("gasp")
					if (prob(1) && prob(10))
						owner.contract_disease(/datum/ailment/malady/heartdisease,null,null,1)
					APPLY_ATOM_PROPERTY(owner, PROP_MOB_STAMINA_REGEN_BONUS, "hypertension", -1)
					owner.add_stam_mod_max("hypertension", -5)

				if (666 to 750) // very high (160/100)
					if (prob(2))
						var/msg = pick("You feel sweaty",\
						"Your heart beats rapidly",\
						"Your head hurts badly",\
						"Your chest hurts")
						boutput(owner, SPAN_ALERT("[msg]."))
					if (prob(3))
						owner.losebreath += (1 * mult)
					if (prob(2))
						owner.emote("gasp")
					if (prob(1))
						owner.contract_disease(/datum/ailment/malady/heartdisease,null,null,1)
					APPLY_ATOM_PROPERTY(owner, PROP_MOB_STAMINA_REGEN_BONUS, "hypertension", -2)
					owner.add_stam_mod_max("hypertension", -10)

				if (750 to INFINITY) // critically high (180/110)
					if (prob(5))
						var/msg = pick("You feel really sweaty",\
						"Your heart pounds in your chest",\
						"Your head pounds with pain",\
						"Your chest hurts badly",\
						"It's hard to breathe")
						boutput(owner, SPAN_ALERT("[msg]!"))
					if (prob(5))
						owner.losebreath += (1 * mult)
					if (prob(2))
						owner.take_eye_damage(1)
					if (prob(3))
						owner.emote("gasp")
					if (prob(5))
						owner.contract_disease(/datum/ailment/malady/heartdisease,null,null,1)
					if (prob(2))
						owner.visible_message(SPAN_ALERT("[owner] coughs up a little blood!"))
						playsound(owner, 'sound/impact_sounds/Slimy_Splat_1.ogg', 30, TRUE)
						bleed(owner, rand(1,2) * mult, 1)
					APPLY_ATOM_PROPERTY(owner, PROP_MOB_STAMINA_REGEN_BONUS, "hypertension", -3)
					owner.add_stam_mod_max("hypertension", -15)

		..()

	proc/calc_bloodpressure(current_blood_amt)
		var/current_systolic = round((current_blood_amt * 0.24), 1)
		var/current_diastolic = round((current_blood_amt * 0.16), 1)
		owner.blood_pressure["systolic"] = current_systolic
		owner.blood_pressure["diastolic"] = current_diastolic
		owner.blood_pressure["rendered"] = "[max(rand(current_systolic - 5,current_systolic + 5), 0)]/[max(rand(current_diastolic - 2,current_diastolic + 2), 0)]"
		owner.blood_pressure["total"] = current_blood_amt
		owner.blood_pressure["status"] = (current_blood_amt < 415) ? "HYPOTENSIVE" : (current_blood_amt > 584) ? "HYPERTENSIVE" : "NORMAL"
