/datum/ailment/disease/water_poisoning
// bit of lore, this disease is caused by the rapid decomposition and decompression
//of the unstable quadruple water molecules, can be prevented by using stabiliser when making quadruple water
	name = "Water Poisoning"
	max_stages = 5
	stage_prob = 2
	spread = "Non-Contagious"
	cure_flags = CURE_CUSTOM
	strain_type = /datum/ailment_data/disease/water_poisoning
	cure_desc = "Pyrosium"
	reagentcure = list("pyrosium") // not sure if to keep pyrosium as cure
	recureprob = 10
	associated_reagent = "cocktail_quadruplewater"
	affected_species = ("Human, Monkey")

/datum/ailment/disease/water_poisoning/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/disease/water_poisoning/D, mult)
	if (..())
		return
	switch(D.stage)
		if(2)
			if(probmult(5))
				boutput(affected_mob, SPAN_ALERT("You think that you might have drank too much water."))
			if(probmult(2))
				boutput(affected_mob, SPAN_ALERT("You feel a bit bloated."))
			if(probmult(3))
				boutput(affected_mob, SPAN_ALERT("Your thirst has never been so quenched like right now."))
			if(probmult(3))
				affected_mob.emote("burp")
			if(probmult(0.5))
				boutput(affected_mob, SPAN_ALERT("You begin to have a feeling in your pelvic region that seems so familiar yet unrecognizable."))
				// a little reference to the fact that pissing doesnt exist anymore in the game
		if(3)
			if(probmult(4))
				boutput(affected_mob, SPAN_ALERT("Your head hurts."))
			if(probmult(3))
				boutput(affected_mob, SPAN_ALERT("You feel nauseous"))
			if(probmult(3))
				affected_mob.vomit()
				boutput(affected_mob, SPAN_ALERT("You vomit a large amount of water!"))
				var/turf/T = get_turf(affected_mob)
				T.fluid_react_single("water",10)
				affected_mob.take_toxin_damage(5)
			if(probmult(3))
				affected_mob.emote("cry")
		if(4)
			if(probmult(3))
				affected_mob.vomit()
				boutput(affected_mob, SPAN_ALERT("You vomit an EXTREME amount of water!"))
				var/turf/T = get_turf(affected_mob)
				T.fluid_react_single("water",100)
				affected_mob.take_toxin_damage(15)
			if(probmult(5))
				affected_mob.vomit()
				boutput(affected_mob, SPAN_ALERT("You vomit with a large amount of water!"))
				var/turf/T = get_turf(affected_mob)
				T.fluid_react_single("water",10)
				affected_mob.take_toxin_damage(5)
			if(probmult(4))
				boutput(affected_mob, SPAN_ALERT("Your head hurts really strong!"))
				affected_mob.setStatus("stunned", 2 SECONDS)
			if(probmult(4))
				boutput(affected_mob, SPAN_ALERT("Your muscles feel weak!"))
			if(probmult(4))
				boutput(affected_mob, SPAN_ALERT("Your skin is becoming bloated!"))
				affected_mob.emote("scream")
			if(probmult(5))
				boutput(affected_mob, SPAN_ALERT("You feel terrible!"))
				affected_mob.setStatus("slowed", 3 SECONDS)
		if(5)
			if(D.feelingfine == 0)
				boutput(affected_mob, SPAN_ALERT("You suddenly feel better..."))
				D.feelingfine += 1
			if(probmult(5) && !QDELETED(affected_mob))
				affected_mob.emote("scream")
				affected_mob.setStatus("knockdown", 15 SECONDS)
				affected_mob.make_jittery(1000)
				for(var/mob/O in viewers(affected_mob, null))
					O.show_message(SPAN_ALERT("<B>[affected_mob]'s</B> skin starts bloating rapidly!"), 1)
				SPAWN(rand(20, 100))
					if (!QDELETED(affected_mob))
						logTheThing(LOG_COMBAT, affected_mob, "was gibbed by the disease [name] at [log_loc(affected_mob)].")
						#define POP_ANIMATE_TIME 0.3 SECONDS
						playsound(affected_mob.loc, 'sound/effects/cani_suicide.ogg', 90, 0)
						affected_mob.add_filter("canister pop", 1, displacement_map_filter(icon=icon('icons/effects/distort.dmi', "canister_pop"), size=0, y=8))
						animate(affected_mob.get_filter("canister pop"), size=50, time=POP_ANIMATE_TIME, easing=SINE_EASING)
						// stuff from the gas canister suicide
						SPAWN(POP_ANIMATE_TIME)
							var/turf/T = get_turf(affected_mob)
							T.fluid_react_single("water",750)
							affected_mob.gib()
