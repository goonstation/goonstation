

datum/pathogeneffects
	var/name
	var/desc
	var/infect_type = 0

	var/spread = SPREAD_FACE | SPREAD_BODY | SPREAD_HANDS | SPREAD_AIR

	var/rarity = RARITY_ABSTRACT
	var/infect_message = null
	var/infect_attempt_message = null // shown to person when an attempt to directly infect them is made

	var/beneficial = 0

	// This is a list of mutual exclusive symptom TYPES.
	// If this contains any symptoms, none of these symptoms will be picked upon mutation or initial raffle.
	// Mutexes cut the ENTIRE object tree - for example, if symptoms a/b, a/c and a/d all exist, then mutexing
	// symptom a will also mutex b, c and d.
	var/list/mutex = list()

	// A symptom might not always infect everyone around. This is a flat probability: 0 means never infect to 1 means always infect. This is checked PER MOB, not per infect call.
	var/infection_coefficient = 1

	// disease_act(mob, datum/pathogen) : void
	// This is the center of pathogen symptoms.
	// On every Life() tick, this will be called for every symptom attached to the pathogen. Most pathogens should express their malevolence here, unless they are specifically tailored
	// to only work on events like human interaction or external effects. A symptom therefore should override this proc.
	// disease_act is also responsible for handling the symptom's ability to suppress the pathogen. Check the documentation on suppression in pathogen.dm.
	// OVERRIDE: A subclass (direct or otherwise) is expected to override this.
	proc/disease_act(var/mob/M as mob, var/datum/pathogen/origin)

	// disease_act_dead(mob, datum/pathogen) : void
	// This functions identically to disease_act, except it is only called when the mob is dead. (disease_act is not called if that is the case.)
	// OVERRIDE: Only override this if if it needed for the symptom.
	proc/disease_act_dead(var/mob/M as mob, var/datum/pathogen/origin)

	// does an infectious snap
	// makes others snap, should possibly infect you in the future if you are made to snap a certain amount of times
	proc/infect_snap(var/mob/M as mob, var/datum/pathogen/origin, var/range = 5)
		for (var/mob/I in view(range, M.loc))
			if (I != M && ((isturf(I.loc) && isturf(M.loc) && can_line_airborne(get_turf(M), I, 5)) || I.loc == M.loc))
				if(istype(M, /mob/living/carbon/human))
					var/mob/living/carbon/human/H = I
					if(prob(100-H.get_disease_protection()))
						SPAWN_DBG(rand(0.5,2) SECONDS)
							H.show_message("Pretty catchy tune...")
							H.emote("snap") // consider yourself lucky I haven't implemented snap infection yet, human

	// creates an infective cloud
	// this should give people better feedback about how be infected and how to avoid it
	proc/infect_cloud(var/mob/M as mob, var/datum/pathogen/origin, var/amount = 5)
		var/turf/T = get_turf(M)
		var/datum/reagent/blood/pathogen/Q = new /datum/reagent/blood/pathogen()
		var/datum/reagents/R = new /datum/reagents(amount)
		Q.volume = amount
		Q.pathogens += origin.pathogen_uid
		Q.pathogens[origin.pathogen_uid] = origin
		R.reagent_list += "pathogen"
		R.reagent_list["pathogen"] = Q
		Q.holder = R
		R.update_total()
		T.fluid_react(R, amount, airborne = 1)

	// creates an infective puddle
	// this should give people better feedback about how be infected and how to avoid it
	proc/infect_puddle(var/mob/M as mob, var/datum/pathogen/origin, var/amount = 5)
		var/turf/T = get_turf(M)
		var/datum/reagent/blood/pathogen/Q = new /datum/reagent/blood/pathogen()
		var/datum/reagents/R = new /datum/reagents(amount)
		Q.volume = amount
		Q.pathogens += origin.pathogen_uid
		Q.pathogens[origin.pathogen_uid] = origin
		R.reagent_list += "pathogen"
		R.reagent_list["pathogen"] = Q
		Q.holder = R
		R.update_total()
		R.trans_to(T, amount)

	// infect_direct(mob, datum/pathogen) : void
	// This is the proc that handles direct transmission of the pathogen from one mob to another. This should be called in particular infection scenarios. For example, a sweating person
	// gets his bodily fluids onto another when they directly disarm, punch, or grab a person.
	// For INFECT_TOUCH diseases this is automatically called on a successful disarm, punch or grab. When overriding any of these events, use ..() to keep this behaviour.
	// OVERRIDE: Generally, you do not need to override this.
	proc/infect_direct(var/mob/target as mob, var/datum/pathogen/origin, contact_type = "touch")
		if (infect_attempt_message)
			target.show_message(infect_attempt_message)
		if(istype(target, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = target
			if(prob(100-H.get_disease_protection()))
				if (target.infected(origin))
					if (infect_message)
						target.show_message(infect_message)
					logTheThing("pathology", origin.infected, target, "infects %target% with [origin.name] due to symptom [name] through direct contact ([contact_type]).")
					return 1

	proc/onadd(var/datum/pathogen/origin)
		return

	// ====
	// Events from this point on. Their exact behaviour is documented in pathogen.dm. Please do not add any event definitions outside this block.
	// ondisarm(mob, mob, boolean, datum/pathogen) : float
	// OVERRIDE: Overriding this is situational. ..() is expected to be called.
	proc/ondisarm(var/mob/M as mob, var/mob/V as mob, isPushDown, var/datum/pathogen/origin)
		if (infect_type == INFECT_TOUCH)
			infect_direct(V, origin, "disarm")
		return 1

	// onpunch(mob, mob, string, datum/pathogen) : float
	// OVERRIDE: Overriding this is situational. ..() is expected to be called.
	proc/onpunch(var/mob/M as mob, var/mob/V as mob, zone, var/datum/pathogen/origin)
		if (infect_type == INFECT_TOUCH)
			infect_direct(V, origin, "punching")
		return 1

	// onpunched(mob, mob, string, datum/pathogen) : float
	// OVERRIDE: Overriding this is situational. ..() is expected to be called.
	proc/onpunched(var/mob/M as mob, var/mob/A as mob, zone, var/datum/pathogen/origin)
		if (infect_type == INFECT_TOUCH)
			infect_direct(A, origin, "being punched")
		return 1

	// onshocked(mob, mob, datum/shockparam, datum/pathogen) : datum/shockparam
	// OVERRIDE: Overriding this is situational.
	proc/onshocked(var/mob/M as mob, var/datum/shockparam/ret, var/datum/pathogen/origin)
		return ret

	// ongrab(mob, mob, datum/pathogen) : void
	// TODO: Make this a veto event.
	// OVERRIDE: Overriding this is situational. ..() is expected to be called.
	proc/ongrab(var/mob/M as mob, var/mob/V as mob, var/datum/pathogen/origin)
		if (infect_type == INFECT_TOUCH)
			infect_direct(V, origin, "grab")
		return

	// onsay(mob, string, datum/pathogen) : string
	// OVERRIDE: Overriding this is situational.
	proc/onsay(var/mob/M as mob, message, var/datum/pathogen/origin)
		return message

	// onemote(mob, string, number, datum/pathogen) : string
	// OVERRIDE: Overriding this is situational.
	proc/onemote(var/mob/M as mob, act, voluntary, var/datum/pathogen/P)
		return 1

	// ondeath(mob, datum/pathogen) : void
	// OVERRIDE: Overriding this is situational.
	proc/ondeath(var/mob/M as mob, var/datum/pathogen/origin)
		return

	// oncured(mob, datum/pathogen) : void
	// OVERRIDE: Overriding this is situational.
	proc/oncured(var/mob/M as mob, var/datum/pathogen/origin)
		return


	// End of events: please do not add any event definitions outside this block.
	// ====

	// may_react_to() : string | null
	// A set of features that you can observe through a microscope and what it might suggest.
	// This will be used to NARROW DOWN what chemicals the pathogen might react to, so that you only need to try a finite set of reagents to determine exactly what symptoms the pathogen has.
	// As this is for narrowing down only, it is encouraged to include false positives.
	// Omitting some reagents from this is also okay - if, say, a family of similar symptoms react to a single reagent in a similar way but each one of them also reacts to (an)other reagent(s)
	// in fundamentally different ways, the latter reagent(s) may be omitted. In the end, this all is up to you though.
	// If the symptom provides no hints, null should be returned.
	//
	// DO RECYCLING!
	// Hints SHOULD be reused moderately often, in order to keep experienced pathologists from immediately identifying the pathogen without testing.
	//
	// Examples of a return value:
	// Non-hint: "There is a fever-inducing gland on the pathogen."
	// Trivial, common symptoms should have this for easy identifiability. Preferrably matching on a few of them, so it takes some work to figure out which it is.
	// Outright tells: "The pathogen appears to collect toxin molecules."
	// - this is very particular, no false positives. Only do this if the hinted reagent does not exactly reveal what the symptom is.
	// Concrete hints: "The pathogen appears to have glands which indicate that they might be receptive to phlogiston, infernite and cryostylane."
	// - this is fairly particular. It is fine but to make it more interesting, most of the symptoms should have a bit more obscure hints.
	// Slightly obscure hints: "The pathogen's behaviour patterns appear to heavily depend on external temperature."
	// - meaning anything that might be hot or cold. This hints at about 3 or 4 different reagents without particularly naming them. This is what we should be mostly aiming for.
	//   Note that this does not necessarily have to mean multiple different reagents. Anything in fits in this category as long as it's not general enough to point at multiple
	//   chemicals, but requires a good knowledge of chemistry to work out. For example, "The pathogen's structure indicates that it may react to chemicals known to induce heart disease."
	//   is clearly initro for someone with chems knowledge, but still is an excellent hint as it's not an outright tell and it does not even name the chemical that should be used.
	// More obscure hints: "The pathogen appears to be receptive to compounds with a single hydroxyl group."
	// - meaning anything that contains or derives from alcohol. This hints at a large family of reagents (all booze and cocktails). This is also fine as long as it's not a riddle
	//   and it is particularly scientific.
	// Very obscure "hint": "The pathogen reacts with chemicals."
	// - well fuck you too, that's very useful, microscope. Do not do this.
	// OVERRIDE: A subclass is expected to override this.
	proc/may_react_to()
		return null

	// react_to(string, int) : string | null
	// How a pathogen with this symptom reacts to a reagent being introduced to it.
	// This is:
	// (1) Not continuous - it is only called once.
	// (2) Not active - it is not called when the pathogen is acting in a mob, only when research is being done on a pathogen culture.
	// It must return null if it does not react to the reagent, or text event of an event that is happening (eg. "The pathogens are attempting to escape the space yeti!") if it reacts.
	// The zoom parameter determines the zoom level at which the pathogen is being viewed. The possible values are 0 and 1.
	// Ideally what is visible at zoom level 0: a behaviour pattern for the pathogen.
	//                         at zoom level 1: the reagent's effect on arbitrary imaginary scientific sounding (hexamelone gland, vascular protomembrane) appendage of a pathogen.
	// At least one of the zoom levels should be a good enough hint at what the symptom might do.
	// NOTE: Conforming with the new reagent system, R is now a reagent ID, not a reagent instance.
	// OVERRIDE: A subclass is expected to override this.
	proc/react_to(var/R, var/zoom)
		return null

datum/pathogeneffects/malevolent
	name = "Malevolent"
	rarity = RARITY_ABSTRACT

// The following lines are the probably undocumented (well at least my part - Marq) hell of the default symptoms.
datum/pathogeneffects/malevolent/coughing
	name = "Coughing"
	desc = "Violent coughing occasionally plagues the infected."
	rarity = RARITY_COMMON

	disease_act(var/mob/M as mob, var/datum/pathogen/origin)
		if (!origin.symptomatic)
			return
		switch (origin.stage)
			if (1)
				if (prob(3))
					M.show_message("<span class='alert'>You cough.</span>")
					src.infect_cloud(M, origin)
			if (2)
				if (prob(5))
					M.visible_message("<span class='alert'>[M] coughs!</span>", "<span class='alert'>You cough.</span>", "<span class='alert'>You hear someone coughing.</span>")
					src.infect_cloud(M, origin)
			if (3)
				if (prob(7))
					M.visible_message("<span class='alert'>[M] coughs violently!</span>", "<span class='alert'>You cough violently!</span>", "<span class='alert'>You hear someone cough violently!</span>")
					src.infect_cloud(M, origin)
			if (4)
				if (prob(10))
					M.visible_message("<span class='alert'>[M] coughs violently!</span>", "<span class='alert'>You cough violently!</span>", "<span class='alert'>You hear someone cough violently!</span>")
					M.TakeDamage("chest", 1, 0)
					src.infect_cloud(M, origin)
			if (5)
				if (prob(10))
					M.visible_message("<span class='alert'>[M] coughs very violently!</span>", "<span class='alert'>You cough very violently!</span>", "<span class='alert'>You hear someone cough very violently!</span>")
					M.TakeDamage("chest", 2, 0)
					src.infect_cloud(M, origin)

	may_react_to()
		return "The pathogen appears to generate a high amount of fluids."

datum/pathogeneffects/malevolent/indigestion
	name = "Indigestion"
	desc = "A bad case of indigestion which occasionally cramps the infected."
	rarity = RARITY_VERY_COMMON

	disease_act(var/mob/M as mob, var/datum/pathogen/origin)
		if (!origin.symptomatic)
			return
		switch (origin.stage)
			if (1 to 3)
				if (prob(5))
					M.take_toxin_damage(origin.stage - 2)
					M.show_message("<span class='alert'>Your stomach hurts.</span>")
			if (4 to 5)
				if (prob(8))
					M.take_toxin_damage(2)
					M.show_message("<span class='alert'>Your stomach hurts.</span>")

	react_to(var/R, var/zoom)
		if (R == "saline")
			if (zoom)
				return "One of the glands of the pathogen seems to shut down in the presence of the solution."

	may_react_to()
		return "The pathogen appears to react to hydrating agents."

datum/pathogeneffects/malevolent/muscleache
	name = "Muscle Ache"
	desc = "The infected feels a slight, constant aching of muscles."
	rarity = RARITY_COMMON

	disease_act(var/mob/M as mob, var/datum/pathogen/origin)
		if (!origin.symptomatic)
			return
		switch (origin.stage)
			if (1 to 3)
				if (prob(5))
					M.show_message("<span class='alert'>Your muscles ache.</span>")
			if (4 to 5)
				if (prob(8))
					M.show_message("<span class='alert'>Your muscles ache.</span>")
					if (prob(15))
						M.TakeDamage("All", origin.stage-3, 0)

	react_to(var/R, var/zoom)
		if (R == "saline")
			if (zoom)
				return "One of the glands of the pathogen seems to shut down in the presence of the solution."

	may_react_to()
		return "The pathogen appears to react to hydrating agents."

datum/pathogeneffects/malevolent/sneezing
	name = "Sneezing"
	desc = "The infected sneezes frequently."
	rarity = RARITY_COMMON

	disease_act(var/mob/M as mob, var/datum/pathogen/origin)
		if (!origin.symptomatic)
			return
		switch (origin.stage)
			if (1)
				if (prob(10))
					M.visible_message("<span class='alert'>[M] sneezes!</span>", "<span class='alert'>You sneeze.</span>", "<span class='alert'>You hear someone sneezing.</span>")
					src.infect_cloud(M, origin)
			if (2)
				if (prob(12))
					M.visible_message("<span class='alert'>[M] sneezes!</span>", "<span class='alert'>You sneeze.</span>", "<span class='alert'>You hear someone sneezing.</span>")
					src.infect_cloud(M, origin)
			if (3)
				if (prob(15))
					M.visible_message("<span class='alert'>[M] sneezes!</span>", "<span class='alert'>You sneeze.</span>", "<span class='alert'>You hear someone sneezing.</span>")
					src.infect_cloud(M, origin)

			if (4)
				if (prob(20))
					M.visible_message("<span class='alert'>[M] sneezes!</span>", "<span class='alert'>You sneeze.</span>", "<span class='alert'>You hear someone sneezing.</span>")
					src.infect_cloud(M, origin)

			if (5)
				if (prob(20))
					M.visible_message("<span class='alert'>[M] sneezes!</span>", "<span class='alert'>You sneeze.</span>", "<span class='alert'>You hear someone sneezing.</span>")
					src.infect_cloud(M, origin)

	may_react_to()
		return "The pathogen appears to generate a high amount of fluids."

	react_to(var/R, var/zoom)
		if (R == "pepper")
			return "The pathogen violently discharges fluids when coming in contact with pepper."

datum/pathogeneffects/malevolent/gasping
	name = "Gasping"
	desc = "The infected has trouble breathing.."
	infect_type = INFECT_NONE
	rarity = RARITY_VERY_COMMON
	disease_act(var/mob/M as mob, var/datum/pathogen/origin)
		if (!origin.symptomatic)
			return
		switch (origin.stage)
			if (1)
				if (prob(3))
					M.emote("gasp")
			if (2)
				if (prob(5))
					M.emote("gasp")
					M.take_oxygen_deprivation(1)
			if (3)
				if (prob(7))
					M.emote("gasp")
					M.take_oxygen_deprivation(1)

			if (4)
				if (prob(10))
					M.emote("gasp")
					M.take_oxygen_deprivation(1)

			if (5)
				if (prob(10))
					M.emote("gasp")
					M.take_oxygen_deprivation(1)
					M.losebreath += 1

	may_react_to()
		return "The pathogen appears to create bubbles of vacuum around its affected area."

/*datum/pathogeneffects/malevolent/moaning
	name = "Moaning"
	desc = "This is literally pointless."
	infect_type = INFECT_NONE
	rarity = RARITY_VERY_COMMON
	disease_act(var/mob/M as mob, var/datum/pathogen/origin)
		if (!origin.symptomatic)
			return
		switch (origin.stage)
			if (1)
				if (prob(10))
					M:emote("moan")

			if (2)
				if (prob(12))
					M:emote("moan")

			if (3)
				if (prob(14))
					M:emote("moan")

			if (4)
				if (prob(16))
					M:emote("moan")

			if (5)
				if (prob(18))
					M:emote("moan")

	may_react_to()
		return "The pathogen appears to be rather displeased."

datum/pathogeneffects/malevolent/hiccups
	name = "Hiccups"
	desc = "This is literally pointless."
	infect_type = INFECT_NONE
	rarity = RARITY_VERY_COMMON
	disease_act(var/mob/M as mob, var/datum/pathogen/origin)
		if (!origin.symptomatic)
			return
		switch (origin.stage)
			if (1)
				if (prob(1))
					M:emote("hiccup")

			if (2)
				if (prob(2))
					M:emote("hiccup")

			if (3)
				if (prob(4))
					M:emote("hiccup")

			if (4)
				if (prob(8))
					M:emote("hiccup")

			if (5)
				if (prob(16))
					M:emote("hiccup")

	may_react_to()
		return "The pathogen appears to be violently... hiccuping?"*/

datum/pathogeneffects/malevolent/shivering
	name = "Shivering"
	desc = "This is literally pointless."
	infect_type = INFECT_NONE
	rarity = RARITY_VERY_COMMON
	disease_act(var/mob/M as mob, var/datum/pathogen/origin)
		if (!origin.symptomatic)
			return
		switch (origin.stage)
			if (1)
				if (prob(10))
					M:emote("shiver")

			if (2)
				if (prob(12))
					M:emote("shiver")

			if (3)
				if (prob(14))
					M:emote("shiver")

			if (4)
				if (prob(16))
					M:emote("shiver")

			if (5)
				if (prob(18))
					M:emote("shiver")

	may_react_to()
		return "The pathogen appears to be shivering."

datum/pathogeneffects/malevolent/deathgasping
	name = "Deathgasping"
	desc = "This is literally pointless."
	infect_type = INFECT_NONE
	rarity = RARITY_UNCOMMON
	disease_act(var/mob/M as mob, var/datum/pathogen/origin)
		if (!origin.symptomatic)
			return
		switch (origin.stage)
			if (1)
				if (prob(10))
					M:emote("deathgasp")

			if (2)
				if (prob(12))
					M:emote("deathgasp")

			if (3)
				if (prob(14))
					M:emote("deathgasp")

			if (4)
				if (prob(16))
					M:emote("deathgasp")

			if (5)
				if (prob(18))
					M:emote("deathgasp")

	may_react_to()
		return "The pathogen appears to be.. sort of dead?"

datum/pathogeneffects/malevolent/sweating
	name = "Sweating"
	desc = "The infected person sweats like a fucking pig."
	infect_type = INFECT_TOUCH
	rarity = RARITY_VERY_COMMON
	spread = SPREAD_HANDS | SPREAD_BODY
	infect_attempt_message = "Ew, their hands feel really gross and sweaty!"
	disease_act(var/mob/M as mob, var/datum/pathogen/origin)
		switch (origin.stage)
			if (1)
				if (prob(5) && origin.symptomatic)
					M.show_message("<span class='alert'>You feel a bit warm.</span>")
				if (prob(40))
					src.infect_puddle(M, origin)

			if (2)
				if (prob(5) && origin.symptomatic)
					M.show_message("<span class='alert'>You feel rather warm.</span>")
				if (prob(40))
					src.infect_puddle(M, origin)

			if (3)
				if (prob(5) && origin.symptomatic)
					M.show_message("<span class='alert'>You're sweating heavily.</span>")
				if (prob(40))
					src.infect_puddle(M, origin)

			if (4)
				if (prob(5) && origin.symptomatic)
					M.show_message("<span class='alert'>You're soaked in your own sweat.</span>")
				if (prob(40))
					src.infect_puddle(M, origin)

			if (5)
				if (prob(5) && origin.symptomatic)
					M.show_message("<span class='alert'>You're soaked in your own sweat.</span>")
				if (prob(40))
					src.infect_puddle(M, origin)

	may_react_to()
		return "The pathogen appears to generate a high amount of fluids."

	react_to(var/R, zoom)
		if (R == "cryostylane")
			return "The cold substance appears to affect the fluid generation of the pathogen."

datum/pathogeneffects/malevolent/disorientation
	name = "Disorientation"
	desc = "The infected occasionally gets disoriented."
	infect_type = INFECT_NONE
	rarity = RARITY_UNCOMMON
	disease_act(var/mob/M as mob, var/datum/pathogen/origin)
		if (!origin.symptomatic)
			return
		switch (origin.stage)
			if (1)
				if (prob(10))
					boutput(M, "<span class='alert'>You feel a bit disoriented.</span>")
					M.change_misstep_chance(10)

			if (2)
				if (prob(12))
					boutput(M, "<span class='alert'>You feel a bit disoriented.</span>")
					M.change_misstep_chance(10)

			if (3)
				if (prob(14))
					boutput(M, "<span class='alert'>You feel a bit disoriented.</span>")
					M.change_misstep_chance(20)

			if (4)
				if (prob(16))
					boutput(M, "<span class='alert'>You feel rather disoriented.</span>")
					M.change_misstep_chance(20)

			if (5)
				if (prob(18))
					boutput(M, "<span class='alert'>You feel rather disoriented.</span>")
					M.change_misstep_chance(30)
					M.take_brain_damage(1)
	may_react_to()
		return "A glimpse at the pathogen's exterior indicates it could affect the central nervous system. "

	react_to(var/R, zoom)
		if (R == "mannitol")
			return "The pathogen appears to have trouble cultivating in the areas affected by the mannitol."

obj/hallucinated_item
	icon = null
	icon_state = null
	name = ""
	desc = ""
	anchored = 1
	density = 0
	opacity = 0
	var/mob/owner = null

	New(myloc, myowner, var/obj/prototype)
		..()
		myowner = owner
		name = prototype.name
		desc = prototype.desc

	attack_hand(var/mob/M)
		if (M == owner)
			M.show_message("<span class='alert'>[src] slips through your hands!</span>")
			if (prob(10))
				M.show_message("<span class='alert'>[src] disappears!</span>")
				qdel(src)

datum/pathogeneffects/malevolent/serious_paranoia
	name = "Serious Paranoia"
	desc = "The infected is seriously suspicious of others, to the point where they might see others do traitorous things."
	infect_type = INFECT_NONE
	rarity = RARITY_RARE
	var/static/list/hallucinated_images = list(/obj/item/sword, /obj/item/card/emag, /obj/item/cloaking_device)
	var/static/list/traitor_items = list("cyalume saber", "Electromagnetic Card", "pen", "mini rad-poison crossbow", "cloaking device", "revolver", "butcher's knife", "amplified vuvuzela", "power gloves", "signal jammer")

	proc/trader(var/mob/M as mob, var/mob/living/O as mob)
		var/action = "says"
		if (issilicon(O))
			action = "states"
		var/what = pick("I am the traitor.", "I will kill you.", "You will die, [M].")
		if (prob(50))
			boutput(M, "<B>[O]</B> points at [M].")
			var/point = new /obj/decal/point(get_turf(M))
			SPAWN_DBG(3 SECONDS)
				qdel(point)
		boutput(M, "<B>[O]</B> [action], \"[what]\"")

	proc/backpack(var/mob/M, var/mob/living/O)
		var/item = pick(traitor_items)
		boutput(M, "<span class='notice'>[O] has added the [item] to the backpack!</span>")
		logTheThing("pathology", M, O, "saw a fake message about an %target% adding [item] to their backpacks due to Serious Paranoia symptom.")

	proc/acidspit(var/mob/M, var/mob/living/O, var/mob/living/O2)
		if (O2)
			boutput(M, "<span class='alert'><B>[O] spits acid at [O2]!</B></span>")
		else
			boutput(M, "<span class='alert'><B>[O] spits acid at you!</B></span>")
		logTheThing("pathology", M, O, "saw a fake message about an %target% spitting acid due to Serious Paranoia symptom.")

	proc/vampirebite(var/mob/M, var/mob/living/O, var/mob/living/O2)
		if (O2)
			boutput(M, "<span class='alert'><B>[O] bites [O2]!</B></span>")
		else
			boutput(M, "<span class='alert'><B>[O] bites you!</B></span>")
		logTheThing("pathology", M, O, "saw a fake message about an %target% biting someone due to Serious Paranoia symptom.")

	proc/floor_in_view(var/mob/M)
		var/list/ret = list()
		for (var/turf/simulated/floor/T in view(M, 7))
			ret += T
		return ret

	proc/hallucinate_item(var/mob/M)
		var/item = pick(hallucinated_images)
		var/obj/item_inst = new item()
		var/list/LF = floor_in_view(M)
		if(!LF.len) return
		var/obj/hallucinated_item/H = new /obj/hallucinated_item(pick(floor_in_view(M)), M, item_inst)
		var/image/hallucinated_image = image(item_inst, H)
		M << hallucinated_image

	may_react_to()
		return "The pathogen appears to be wilder than usual, perhaps sedatives or psychoactive substances might affect its behaviour."

	react_to(var/R, var/zoom)
		if (zoom == 1)
			if (R == "morphine" || R == "ketamine")
				return "The pathogens near the sedative appear to be in stasis."
		if (R == "LSD")
			return "The pathogen appears to be strangely unaffected by the LSD."

	disease_act(var/mob/M as mob, var/datum/pathogen/origin)
		if (!origin.symptomatic)
			return
		switch (origin.stage)
			if (1)
				if (prob(10))
					for (var/mob/living/O in oview(7, M))
						trader(M, O)
						return

			if (2)
				if (prob(12))
					for (var/mob/living/O in oview(7, M))
						if (prob(50))
							trader(M, O)
						else
							boutput(M, "<span class='notice'>[O] has added the suspicious item to the backpack!</span>")
						return

			if (3)
				if (prob(14))
					for (var/mob/living/O in oview(7, M))
						if (prob(50))
							trader(M, O)
						else
							backpack(M, O)
						return

			if (4)
				if (prob(16))
					var/list/mob/living/OL = list()
					for (var/mob/living/O in oview(7, M))
						OL += O
					if (OL.len == 0)
						return
					var/event = pick(list(1, 2, 3, 4, 5, 6))
					switch (event)
						if (1)
							trader(M, pick(OL))
						if (2)
							backpack(M, pick(OL))
						if (3)
							var/M1 = pick(OL)
							OL -= M1
							if (OL.len)
								acidspit(M, M1, pick(OL))
							else
								acidspit(M, M1, null)
						if (4)
							var/M1 = pick(OL)
							OL -= M1
							if (OL.len)
								vampirebite(M, M1, pick(OL))
							else
								vampirebite(M, M1, null)
						if (5)
							hallucinate_item(M)
						if (6)
							M.flash(3 SECONDS)
							var/sound/S = sound(pick('sound/effects/Explosion1.ogg','sound/effects/Explosion1.ogg'), repeat=0, wait=0, volume=50)
							S.frequency = rand(32000, 55000)
							M << S
					return

			if (5)
				if (prob(18))
					var/list/mob/living/OL = list()
					for (var/mob/living/O in oview(7, M))
						OL += O
					if (OL.len == 0)
						return
					var/event = pick(list(1, 2, 3, 4, 5, 6))
					switch (event)
						if (1)
							trader(M, pick(OL))
						if (2)
							backpack(M, pick(OL))
						if (3)
							var/M1 = pick(OL)
							OL -= M1
							if (OL.len)
								acidspit(M, M1, pick(OL))
							else
								acidspit(M, M1, null)
						if (4)
							var/M1 = pick(OL)
							OL -= M1
							if (OL.len)
								vampirebite(M, M1, pick(OL))
							else
								vampirebite(M, M1, null)
						if (5)
							hallucinate_item(M)
						if (6)
							M.flash(3 SECONDS)
							var/sound/S = sound(pick('sound/effects/Explosion1.ogg','sound/effects/Explosion1.ogg'), repeat=0, wait=0, volume=50)
							S.frequency = rand(32000, 55000)
							M << S
					return

datum/pathogeneffects/malevolent/serious_paranoia/mild
	name = "Paranoia"
	desc = "The infected is suspicious of others, to the point where they might see others do traitorous things."
	infect_type = INFECT_NONE
	rarity = RARITY_UNCOMMON

	may_react_to()
		return "The pathogen appears to be wilder than usual, perhaps sedatives or psychoactive substances might affect its behaviour."

	react_to(var/R, var/zoom)
		if (zoom == 1)
			if (R == "morphine" || R == "ketamine")
				return "The pathogens near the sedative appear to be in stasis."
		if (R == "LSD")
			return "The pathogen appears to be barely affected by the LSD."

	disease_act(var/mob/M as mob, var/datum/pathogen/origin)
		if (!origin.symptomatic)
			return
		switch (origin.stage)
			if (1)
				if (prob(10))
					for (var/mob/living/O in oview(7, M))
						trader(M, O)
						return

			if (2)
				if (prob(12))
					for (var/mob/living/O in oview(7, M))
						if (prob(50))
							trader(M, O)
						else
							boutput(M, "<span class='notice'>[O] has added the suspicious item to the backpack!</span>")
						return

			if (3)
				if (prob(14))
					for (var/mob/living/O in oview(7, M))
						if (prob(50))
							trader(M, O)
						else
							backpack(M, O)
						return

			if (4)
				if (prob(16))
					var/list/mob/living/OL = list()
					for (var/mob/living/O in oview(7, M))
						OL += O
					if (OL.len == 0)
						return
					var/event = pick(list(1, 2, 3))
					switch (event)
						if (1)
							trader(M, pick(OL))
						if (2)
							backpack(M, pick(OL))
						if (3)
							hallucinate_item(M)
					return

			if (5)
				if (prob(18))
					var/list/mob/living/OL = list()
					for (var/mob/living/O in oview(7, M))
						OL += O
					if (OL.len == 0)
						return
					var/event = pick(list(1, 2, 3))
					switch (event)
						if (1)
							trader(M, pick(OL))
						if (2)
							backpack(M, pick(OL))
						if (3)
							hallucinate_item(M)
					return

datum/pathogeneffects/malevolent/teleportation
	name = "Teleportation"
	desc = "The infected exists in a twisted spacetime."
	infect_type = INFECT_NONE
	rarity = RARITY_RARE
	disease_act(var/mob/M as mob, var/datum/pathogen/origin)
		if (!origin.symptomatic)
			return
		if (origin.stage >= 3)
			if (isrestrictedz(M.z))
				return
		switch (origin.stage)
			if (1)
				if (prob(6))
					M.show_message("<span class='alert'>You feel space warping around you.</span>")

			if (2)
				if (prob(6))
					M.show_message("<span class='alert'>You feel space warping around you.</span>")

			if (3)
				if (prob(8))
					M.show_message("<span class='alert'>You are suddenly zapped elsewhere!</span>")
					var/turf/T = pick(orange(7, M.loc))
					do_teleport(M, T, 1)

			if (4)
				if (prob(10))
					M.show_message("<span class='alert'>You are suddenly zapped elsewhere!</span>")
					var/turf/T = pick(orange(11, M.loc))
					do_teleport(M, T, 2)

			if (5)
				if (prob(15))
					M.show_message("<span class='alert'>You are suddenly zapped elsewhere!</span>")
					var/turf/T = pick(orange(15, M.loc))
					do_teleport(M, T, 3)

	may_react_to()
		return "A glimpse at an irregular nerve center of the pathogen indicates that it might react to psychoactive substances."

	react_to(var/R, var/zoom)
		if (R == "LSD")
			if (zoom)
				return "Upon closer examination, the pathogens appear to be shifting through space, instantly disappearing and reappearing."
			else
				return "The pathogens appear to be rapidly moving around the LSD-filled dish."
		else return null

datum/pathogeneffects/malevolent/gibbing
	name = "Gibbing"
	desc = "The infected person may spontaneously gib."
	rarity = RARITY_VERY_RARE
	spread = SPREAD_FACE | SPREAD_HANDS | SPREAD_AIR | SPREAD_BODY
	disease_act(var/mob/M as mob, var/datum/pathogen/origin)
		if (!origin.symptomatic)
			return
		switch (origin.stage)
			if (1)
				if (prob(5))
					M.show_message("<span class='alert'>Your body feels a bit tight.</span>")

			if (2)
				if (prob(5))
					M.show_message("<span class='alert'>Your body feels a bit tight.</span>")

			if (3)
				if (prob(10))
					M.show_message("<span class='alert'>Your body feels too tight to hold your organs inside.</span>")

			if (4)
				if (prob(20))
					M.show_message("<span class='alert'>Your body feels too tight to hold your organs inside.</span>")
				else if (prob(20))
					M.show_message("<span class='alert'>You feel like you could explode at any time.</span>")

			if (5)
				if (prob(1))
					if (ishuman(M))
						// it's funnier if their organs actually do burst out.
						var/mob/living/carbon/human/H = M
						H.dump_contents_chance = 100
					M.show_message("<span class='alert'>Your organs burst out of your body!</span>")
					src.infect_cloud(M, origin, 20)
					logTheThing("pathology", M, null, "gibbed due to Gibbing symptom in [origin].")
					M.gib()
				else if (prob(30))
					M.show_message("<span class='alert'>Your body feels too tight to hold your organs inside.</span>")
				else if (prob(30))
					M.show_message("<span class='alert'>You feel like you could explode at any time.</span>")

	may_react_to()
		return "The culture appears to process proteins at an irregular speed."

	react_to(var/R, var/zoom)
		if (R == "synthflesh")
			if (zoom)
				return "There are stray synthflesh pieces all over the dish."
			else
				return "Pathogens appear to be storming the synthflesh chunks and through an extreme conversion of energy, bursting them into smaller, more processible chunks."
		else return null

datum/pathogeneffects/malevolent/shakespeare
	name = "Shakespeare"
	desc = "The infected has an urge to begin reciting shakespearean poetry."
	infect_type = INFECT_NONE
	rarity = RARITY_VERY_COMMON
	var/static/list/shk = list("Expectation is the root of all heartache.",
"A fool thinks himself to be wise, but a wise man knows himself to be a fool.",
"Love all, trust a few, do wrong to none.",
"Hell is empty and all the devils are here.",
"Better a witty fool than a foolish wit.",
"The course of true love never did run smooth.",
"Come, gentlemen, I hope we shall drink down all unkindness.",
"Suspicion always haunts the guilty mind.",
"No legacy is so rich as honesty.",
"Alas, I am a woman friendless, hopeless!",
"The empty vessel makes the loudest sound.",
"Words without thoughts never to heaven go.",
"This above all; to thine own self be true.",
"An overflow of good converts to bad.",
"It is a wise father that knows his own child.",
"Listen to many, speak to a few.",
"Boldness be my friend.",
"Speak low, if you speak love.",
"Give thy thoughts no tongue.",
"The devil can cite Scripture for his purpose.",
"In time we hate that which we often fear.",
"The lady doth protest too much, methinks.")

	onsay(var/mob/M as mob, message, var/datum/pathogen/origin)
		if (!(message in shk))
			return shakespearify(message)

	disease_act(var/mob/M as mob, var/datum/pathogen/origin)
		if (!origin.symptomatic)
			return
		if (prob(origin.stage)) // 3. holy shit shut up shUT UP
			M.say(pick(shk))

	may_react_to()
		return "The culture appears to be quite dramatic."

datum/pathogeneffects/malevolent/fluent
	name = "Fluent Speech"
	desc = "The infection has a serious excess of saliva."
	infect_type = INFECT_AREA
	spread = SPREAD_FACE
	infect_message = "<span class='alert'>A drop of saliva lands on your face.</span>"
	rarity = RARITY_UNCOMMON
	disease_act(var/mob/M as mob, var/datum/pathogen/origin)
		return

	onsay(var/mob/M as mob, message, var/datum/pathogen/origin)
		if (!origin.symptomatic)
			return message
		switch (origin.stage)
			if (1 to 3)
				if (prob(origin.stage * 2))
					src.infect_cloud(M, origin)

			if (4 to 5)
				if (prob(origin.stage * 5))
					src.infect_cloud(M, origin)
		return message

	may_react_to()
		return "The pathogen appears to generate a high amount of fluids."

	react_to(var/R, var/zoom)
		if (R == "salt")
			return "The pathogen stops generating fluids when coming in contact with salt."

datum/pathogeneffects/malevolent/capacitor
	name = "Capacitor"
	desc = "The infected is involuntarily electrokinetic."
	rarity = RARITY_VERY_RARE
	var/static/capacity = 1e7
	proc/electrocute(var/mob/V as mob, var/shock_load)
		V.shock(src, shock_load, "chest", 1, 0.5)

		var/datum/effects/system/spark_spread/s = unpool(/datum/effects/system/spark_spread)
		s.set_up(3, 1, V)
		s.start()

	proc/discharge(var/mob/M as mob, var/datum/pathogen/origin)
		var/load = origin.symptom_data["capacitor"]
		if (load == 0)
			return
		var/datum/effects/system/spark_spread/s = unpool(/datum/effects/system/spark_spread)
		s.set_up(3, 1, M)
		s.start()
		if (load > 4e6)
			M.visible_message("<span class='alert'>[M] releases a burst of lightning into the air!</span>", "<span class='alert'>You discharge your energy into the air. It leaves your skin burned to a fine crisp.</span>", "<span class='alert'>You hear a burst of electricity.</span>")
			M.TakeDamage("chest", 0, 30)
			M.changeStatus("stunned", 1 SECOND)
			for (var/mob/V in orange(4, M))
				electrocute(V, load / 10)
		else if (load > 1e6)
			M.visible_message("<span class='alert'>[M] releases a burst of lightning into the air!</span>", "<span class='alert'>You discharge your energy into the air. It leaves your skin burned to a fine crisp.</span>", "<span class='alert'>You hear a burst of electricity.</span>")
			M.TakeDamage("chest", 0, 20)
			M.changeStatus("stunned", 7 SECONDS)
			for (var/mob/V in orange(4, M))
				electrocute(V, load / 10)
		else if (load > 50000)
			M.visible_message("<span class='alert'>[M] releases a considerable amount of electricity into the air!</span>", "<span class='alert'>You discharge your energy into the air. It leaves your skin burned heavily.</span>", "<span class='alert'>You hear a burst of electricity.</span>")
			M.TakeDamage("chest", 0, 15)
			M.changeStatus("stunned", 4 SECONDS)
			for (var/mob/V in orange(3, M))
				electrocute(V, load / 10)
		else if (load > 20000)
			M.visible_message("<span class='alert'>[M] releases a bolt of lightning into the air!</span>", "<span class='alert'>You discharge your energy into the air. It leaves your skin burned lightly.</span>", "<span class='alert'>You hear a burst of electricity.</span>")
			M.TakeDamage("chest", 0, 10)
			M.changeStatus("stunned", 2 SECONDS)
			for (var/mob/V in orange(2, M))
				electrocute(V, load / 10)
		else if (load > 5000)
			M.changeStatus("stunned", 1 SECOND)
			M.visible_message("<span class='alert'>[M] releases a few sparks into the air.</span>", "<span class='alert'>You discharge your energy into the air.</span>", "<span class='alert'>You hear a burst of electricity.</span>")
			for (var/mob/V in orange(1, M))
				electrocute(V, load / 10)
		else if (load > 0)
			M.show_message("<span class='notice'>You feel discharged.</span>")
		origin.symptom_data["capacitor"] = 0

	proc/load_check(var/mob/M as mob, var/datum/pathogen/origin)
		var/load = origin.symptom_data["capacitor"]
		if (load > capacity)
			M.show_message("<span class='alert'>You burst into several, shocking pieces.</span>")
			src.infect_cloud(M, origin, 20)
			explosion(M, M.loc,1,2,3,4)
		else if (load > capacity * 0.9)
			M.show_message("<span class='alert'>You are severely overcharged. It feels like the voltage could burst your body at any moment.</span>")
		else if (load > capacity * 0.8)
			M.show_message("<span class='alert'>You are beginning to feel overcharged.</span>")

	onadd(var/datum/pathogen/origin)
		origin.symptom_data["capacitor"] = 0

	onshocked(var/mob/M as mob, var/datum/shockparam/ret, var/datum/pathogen/origin)
		var/amt = ret.amt
		var/wattage = ret.wattage
		if (wattage > 45000)
			origin.symptom_data["capacitor"] += wattage
			amt /= 2
			ret.skipsupp = 1
			M.show_message("<span class='notice'>You absorb a portion of the electric shock!</span>")
		else
			amt = 0
			ret.skipsupp = 1
			M.show_message("<span class='notice'>You absorb the electric shock!</span>")
		load_check(M, origin)
		return ret

	ondisarm(var/mob/M as mob, var/mob/V as mob, isPushDown, var/datum/pathogen/origin)
		var/load = origin.symptom_data["capacitor"]
		if (load > 1e6 && isPushDown)
			if (prob(25))
				M.visible_message("<span class='alert'>[M]'s hands are glowing in a blue color.</span>", "<span class='notice'>You discharge yourself onto your opponent with your hands!</span>", "<span class='alert'>You hear someone getting defibrillated.</span>")
				electrocute(V, load / 10)
				if (prob(50))
					M.show_message("<span class='alert'>Your shock jumps back onto you!</span>")
					electrocute(M, load / 10)
				origin.symptom_data["capacitor"] = 0
		return 1

	onpunch(var/mob/M as mob, var/mob/V as mob, zone, var/datum/pathogen/origin)
		var/load = origin.symptom_data["capacitor"]
		if (load > 2e6)
			if (prob(25))
				M.visible_message("<span class='alert'>[M]'s fists are covered in electric arcs.</span>", "<span class='notice'>You supercharge your punch.</span>", "<span class='alert'>You hear a huge electric crackle.</span>")
				electrocute(V, load / 10)
				if (prob(50))
					M.show_message("<span class='alert'>Your shock jumps back onto you!</span>")
					electrocute(M, load / 10)
				origin.symptom_data["capacitor"] /= 2
		else if (load > 500000)
			if (prob(20))
				M.visible_message("<span class='alert'>[M]'s fists spark electric arcs.</span>", "<span class='notice'>You overcharge your punch.</span>", "<span class='alert'>You hear a large electric crackle.</span>")
				electrocute(V, load / 10)
				if (prob(50))
					M.show_message("<span class='alert'>Your shock jumps back onto you!</span>")
					electrocute(M, load / 10)
				origin.symptom_data["capacitor"] /= 2
		else if (load > 200000)
			if (prob(15))
				M.visible_message("<span class='alert'>[M]'s fists throw sparks.</span>", "<span class='notice'>You charge your punch.</span>", "<span class='alert'>You hear an electric crackle.</span>")
				electrocute(V, load / 10)
				if (prob(50))
					M.show_message("<span class='alert'>Your shock jumps back onto you!</span>")
					electrocute(M, load / 10)
				origin.symptom_data["capacitor"] /= 2
		return 1

	onpunched(var/mob/M as mob, var/mob/A as mob, zone, var/datum/pathogen/origin)
		var/load = origin.symptom_data["capacitor"]
		if (load > 5000)
			if (prob(25))
				M.visible_message("<span class='alert'>[M] loses control and discharges his energy!</span>", "<span class='alert'>You flinch and discharge.</span>", "<span class='alert'>You hear someone getting shocked.</span>")
				discharge(M, origin)
		return 1

	disease_act(var/mob/M as mob, var/datum/pathogen/origin)
		if (!origin.symptomatic)
			return
		var/load = origin.symptom_data["capacitor"]
		switch (origin.stage)
			if (1)
				if (prob(9))
					var/obj/cable/C = locate() in range(3, M)
					var/datum/powernet/PN
					if (C)
						PN = C.get_powernet()
					if (C && PN.avail > 0)
						var/datum/effects/system/spark_spread/s = unpool(/datum/effects/system/spark_spread)
						s.set_up(3, 1, C)
						s.start()
						M.visible_message("<span class='alert'>A spark jumps from the power cable at [M].</span>", "<span class='alert'>A spark jumps at you from a nearby cable.</span>", "<span class='alert'>You hear something spark.</span>")

			if (2)
				if (prob(9))
					var/obj/cable/C = locate() in range(3, M)
					var/datum/powernet/PN
					if (C)
						PN = C.get_powernet()
					if (C && PN.avail > 0)
						var/datum/effects/system/spark_spread/s = unpool(/datum/effects/system/spark_spread)
						s.set_up(3, 1, C)
						s.start()
						M.visible_message("<span class='alert'>A spark jumps from the power cable at [M].</span>", "<span class='alert'>A spark jumps at you from a nearby cable.</span>", "<span class='alert'>You hear something spark.</span>")
						var/amt = max(250000, PN.avail)
						PN.newload -= amt
						origin.symptom_data["capacitor"] += amt
						if (amt > 2500 && load > 5000)
							M.show_message("<span class='notice'>You feel energized.</span>")
						load_check(M, origin)
				else if (prob(6))
					if (load > 0)
						discharge(M, origin)

			if (3)
				if (prob(10))
					var/obj/cable/C = locate() in range(4, M)
					var/datum/powernet/PN
					if (C)
						PN = C.get_powernet()
					if (C && PN.avail > 0)
						var/datum/effects/system/spark_spread/s = unpool(/datum/effects/system/spark_spread)
						s.set_up(3, 1, C)
						s.start()
						M.visible_message("<span class='alert'>A bolt of electricity jumps at [M].</span>", "<span class='alert'>A bolt of electricity jumps at you from a nearby cable. It burns!</span>", "<span class='alert'>You hear something spark.</span>")
						M.TakeDamage("chest", 0, 3)
						var/amt = max(1e6, PN.avail)
						PN.newload -= amt
						origin.symptom_data["capacitor"] += amt
						if (amt > 5000 && load > 5000)
							M.show_message("<span class='notice'>You feel energized.</span>")
						load_check(M, origin)
				else if (prob(6))
					if (load > 0)
						discharge(M, origin)

			if (4)
				if (prob(15))
					var/obj/machinery/power/smes/S = locate() in range(4, M)
					if (S && S.charge > 0) // Look for active SMES first
						var/datum/effects/system/spark_spread/s = unpool(/datum/effects/system/spark_spread)
						s.set_up(3, 1, S)
						s.start()
						M.visible_message("<span class='alert'>A burst of lightning jumps at [M] from [S].</span>", "<span class='alert'>A burst of lightning jumps at you from [S]. It burns!</span>", "<span class='alert'>You hear something spark.</span>")
						M.TakeDamage("chest", 0, 15)
						var/amt = S.charge
						S.charge -= amt
						origin.symptom_data["capacitor"] += amt
						if (amt > 5000 && load > 5000)
							M.show_message("<span class='notice'>You feel energized.</span>")
						load_check(M, origin)
					else
						var/obj/machinery/power/apc/A = locate() in view(4, M)
						if (A && A.cell && A.cell.charge > 0)
							var/datum/effects/system/spark_spread/s = unpool(/datum/effects/system/spark_spread)
							s.set_up(3, 1, A)
							s.start()
							M.visible_message("<span class='alert'>A burst of lightning jumps at [M] from [A].</span>", "<span class='alert'>A burst of lightning jumps at you from [A]. It burns!</span>", "<span class='alert'>You hear something spark.</span>")
							M.TakeDamage("chest", 0, 5)
							var/amt  = A.cell.charge / 6
							A.cell.charge -= amt
							origin.symptom_data["capacitor"] += amt * 50
							if (amt > 5000 && load > 5000)
								M.show_message("<span class='notice'>You feel energized.</span>")
							load_check(M, origin, origin)
						else
							var/obj/cable/C = locate() in range(4, M)
							var/datum/powernet/PN
							if (C)
								PN = C.get_powernet()
							if (C && PN.avail > 0)
								var/datum/effects/system/spark_spread/s = unpool(/datum/effects/system/spark_spread)
								s.set_up(3, 1, C)
								s.start()
								M.visible_message("<span class='alert'>A burst of lightning jumps at [M].</span>", "<span class='alert'>A burst of lightning jumps at you from a nearby cable. It burns!</span>", "<span class='alert'>You hear something spark.</span>")
								M.TakeDamage("chest", 0, 5)
								var/amt = max(3e6, PN.avail)
								PN.newload -= amt
								origin.symptom_data["capacitor"] += amt * 2
								if (amt > 5000 && load > 5000)
									M.show_message("<span class='notice'>You feel energized.</span>")
								load_check(M, origin)
				else if (prob(6))
					if (load > 0)
						discharge(M, origin)
			if (5)
				if (prob(15))
					var/obj/machinery/power/smes/S = locate() in range(4, M)
					if (S && S.charge > 0) // Look for active SMES first
						var/datum/effects/system/spark_spread/s = unpool(/datum/effects/system/spark_spread)
						s.set_up(3, 1, S)
						s.start()
						M.visible_message("<span class='alert'>A burst of lightning jumps at [M] from [S].</span>", "<span class='alert'>A burst of lightning jumps at you from [S]. It burns!</span>", "<span class='alert'>You hear something spark.</span>")
						M.TakeDamage("chest", 0, 15)
						var/amt = S.charge
						S.charge -= amt
						origin.symptom_data["capacitor"] += amt
						if (amt > 5000 && load > 5000)
							M.show_message("<span class='notice'>You feel energized.</span>")
						load_check(M, origin)
					else
						var/obj/machinery/power/apc/A = locate() in view(4, M)
						if (A && A.cell && A.cell.charge > 0)
							var/datum/effects/system/spark_spread/s = unpool(/datum/effects/system/spark_spread)
							s.set_up(3, 1, A)
							s.start()
							M.visible_message("<span class='alert'>A burst of lightning jumps at [M] from [A].</span>", "<span class='alert'>A burst of lightning jumps at you from [A]. It burns!</span>", "<span class='alert'>You hear something spark.</span>")
							M.TakeDamage("chest", 0, 5)
							var/amt = A.cell.charge / 5 // apcs have a weirdly low capacity.
							A.cell.charge -= amt
							origin.symptom_data["capacitor"] += amt * 50
							if (amt > 5000 && load > 5000)
								M.show_message("<span class='notice'>You feel energized.</span>")
							load_check(M, origin)
						else // Then a power cable if not found
							var/obj/cable/C = locate() in range(4, M)
							var/datum/powernet/PN
							if (C)
								PN = C.get_powernet()
							if (C && PN.avail > 0)
								var/datum/effects/system/spark_spread/s = unpool(/datum/effects/system/spark_spread)
								s.set_up(3, 1, C)
								s.start()
								M.visible_message("<span class='alert'>A burst of lightning jumps at [M].</span>", "<span class='alert'>A burst of lightning jumps at you from a nearby cable. It burns!</span>", "<span class='alert'>You hear something spark.</span>")
								M.TakeDamage("chest", 0, 5)
								var/amt = PN.avail
								PN.newload += amt
								origin.symptom_data["capacitor"] += amt * 3
								if (amt > 5000 && load > 5000)
									M.show_message("<span class='notice'>You feel energized.</span>")
								load_check(M, origin)
				else if (prob(1))
					if (load > 0)
						discharge(M, origin)

	may_react_to()
		return "The culture appears to have an irregular lack of liquids, but a very high amount of hydrogen and oxygen."

	react_to(var/R, var/zoom)
		if (R == "water")
			if (zoom)
				return "The water inside the petri dish appears to be breaking down into hydrogen and oxygen."
			else
				return "The water near the pathogen is rapidly disappearing."
		if (R == "voltagen")
			return "Bits of pathogen violently explode when coming into contact with the voltagen."
		else return null

datum/pathogeneffects/malevolent/capacitor/unlimited
	name = "Unlimited Capacitor"

	load_check(var/mob/M as mob, var/datum/pathogen/origin)
		return null

	react_to(var/R, var/zoom)
		if (R == "voltagen")
			return "The pathogen appears to have the ability to infinitely absorb the voltagen."

datum/pathogeneffects/malevolent/liverdamage
	name = "Hepatomegaly"
	desc = "The infected has an inflamed liver."
	infect_type = INFECT_NONE
	rarity = RARITY_UNCOMMON
	disease_act(var/mob/M as mob, var/datum/pathogen/origin)
		if (!origin.symptomatic)
			return
		switch (origin.stage)
			if (1)
				if (prob(4) && M.reagents.has_reagent("ethanol"))
					M.show_message("<span class='alert'>You feel a slight burning in your gut.</span>")
					M.take_toxin_damage(3)
			if (2)
				if (prob(6) && M.reagents.has_reagent("ethanol"))
					M.show_message("<span class='alert'>You feel a burning sensation in your gut.</span>")
					M.take_toxin_damage(4)
			if (3)
				if (prob(8) && M.reagents.has_reagent("ethanol"))
					M.visible_message("[M] clutches their chest in pain!","<span class='alert'>You feel a searing pain in your chest!</span>")
					M.take_toxin_damage(5)
					M.changeStatus("stunned", 2 SECONDS)
			if (4)
				if (prob(10) && M.reagents.has_reagent("ethanol"))
					M.visible_message("[M] clutches their chest in pain!","<span class='alert'>You feel a horrible pain in your chest!</span>")
					M.take_toxin_damage(8)
					M.changeStatus("stunned", 2 SECONDS)
			if (5)
				if (prob(12) && M.reagents.has_reagent("ethanol"))
					M.visible_message("[M] falls to the ground, clutching their chest!", "<span class='alert'>The pain overwhelms you!</span>", "<span class='alert'>You hear someone fall.</span>")
					M.take_toxin_damage(5)
					M.changeStatus("weakened", 400)

	may_react_to()
		return "The pathogen appears to be capable of processing certain beverages."

	react_to(var/R, var/zoom)
		var/alcoholic = 0
		if (R == "ethanol")
			alcoholic = "ethanol"
		else
			var/datum/reagents/H = new /datum/reagents(5)
			H.add_reagent(R, 5)
			var/RE = H.get_reagent(R)
			if (istype(RE, /datum/reagent/fooddrink/alcoholic))
				alcoholic = RE:name
		if (alcoholic)
			return "The pathogen appears to react violently to the [alcoholic]."

datum/pathogeneffects/malevolent/fever
	name = "Fever"
	desc = "The body temperature of the infected individual slightly increases."
	infect_type = INFECT_NONE
	rarity = RARITY_COMMON

	disease_act(var/mob/M as mob, var/datum/pathogen/origin)
		if (!origin.symptomatic)
			return
		switch (origin.stage)
			if (1 to 3)
				if (prob(2 * origin.stage + 3))
					M.bodytemperature += origin.stage
					M.show_message("<span class='alert'>You feel a bit hot.</span>")
			if (4)
				if (prob(11))
					M.bodytemperature += 4
					M.TakeDamage("chest", 0, 1)
					M.show_message("<span class='alert'>You feel hot.</span>")
			if (4)
				if (prob(13))
					M.bodytemperature += 6
					M.TakeDamage("chest", 0, 1)
					if (prob(40))
						M.take_toxin_damage(1)
					M.show_message("<span class='alert'>You feel hot.</span>")


	may_react_to()
		return "The pathogen appears to be creating a constant field of radiating heat. The relevant membranes look like they might be affected by painkillers."

	react_to(var/R, var/zoom)
		if (R == "salicylic_acid")
			return "The heat emission of the pathogen is completely shut down by the painkillers."

datum/pathogeneffects/malevolent/acutefever
	name = "Acute Fever"
	desc = "The body temperature of the infected individual seriously increases and may spontaneously combust."
	infect_type = INFECT_NONE
	rarity = RARITY_RARE

	disease_act(var/mob/M as mob, var/datum/pathogen/origin)
		if (!origin.symptomatic)
			return
		var/mob/living/carbon/human/H = M
		switch (origin.stage)
			if (1 to 3)
				if (prob(2 * origin.stage + 3))
					M.bodytemperature += origin.stage * 2
					M.show_message("<span class='alert'>You feel a bit hot.</span>")
			if (4)
				if (prob(11))
					M.bodytemperature += 11
					M.TakeDamage("chest", 0, 1)
					M.show_message("<span class='alert'>You feel hot.</span>")
				if (prob(2))
					H.update_burning(15)
					M.show_message("<span class='alert'>You spontaneously combust!</span>")
					if (istype(M.loc, /obj/icecube))
						var/IC = M.loc
						M.set_loc(get_turf(M))
						qdel(IC)

			if (5)
				if (prob(15))
					M.bodytemperature += 17
					M.TakeDamage("chest", 0, 2)
					M.show_message("<span class='alert'>You feel rather hot.</span>")
				if (prob(3))
					H.update_burning(25)
					M.show_message("<span class='alert'>You spontaneously combust!</span>")
					if (istype(M.loc, /obj/icecube))
						var/IC = M.loc
						M.set_loc(get_turf(M))
						qdel(IC)

	may_react_to()
		return "The pathogen appears to be creating a constant field of radiating heat. The relevant membranes look like they might be affected by painkillers."

	react_to(var/R, var/zoom)
		if (R == "salicylic_acid")
			return "The heat emission of the pathogen is barely affected by the painkillers."

datum/pathogeneffects/malevolent/ultimatefever
	name = "Dragon Fever"
	desc = "The body temperature of the infected individual seriously increases and may spontaneously combust. Or worse."
	infect_type = INFECT_NONE
	rarity = RARITY_VERY_RARE

	disease_act(var/mob/M as mob, var/datum/pathogen/origin)
		if (!origin.symptomatic)
			return
		var/mob/living/carbon/human/H = M
		switch (origin.stage)
			if (1 to 3)
				if (prob(4 * origin.stage))
					M.bodytemperature += origin.stage * 4
					M.show_message("<span class='alert'>You feel [pick("a bit ", "rather ", "")]hot.</span>")
			if (4)
				if (prob(12))
					M.bodytemperature += 20
					M.TakeDamage("chest", 0, 2)
					M.show_message("<span class='alert'>You feel extremely hot.</span>")
				if (prob(5))
					H.update_burning(25)
					M.show_message("<span class='alert'>You spontaneously combust!</span>")
					if (istype(M.loc, /obj/icecube))
						var/IC = M.loc
						M.set_loc(get_turf(M))
						qdel(IC)

			if (5)
				if (prob(17))
					M.bodytemperature += 25
					M.TakeDamage("chest", 0, 2)
					M.show_message("<span class='alert'>You feel rather hot.</span>")
				if (prob(5))
					H.update_burning(35)
					M.show_message("<span class='alert'>You spontaneously combust!</span>")
					if (istype(M.loc, /obj/icecube))
						var/IC = M.loc
						M.set_loc(get_turf(M))
						qdel(IC)
				if (prob(1) && !M.bioHolder.HasOneOfTheseEffects("fire_resist","thermal_resist"))
					M.show_message("<span class='alert'>You completely burn up!</span>")
					logTheThing("pathology", M, null, " is firegibbed due to symptom [src].")
					M.firegib()

	may_react_to()
		return "The pathogen appears to be creating a constant field of radiating heat. The relevant membranes look like they might be affected by painkillers."

	react_to(var/R, var/zoom)
		if (R == "salicylic_acid")
			return "The heat emission of the pathogen is completely unaffected by the painkillers and continues to radiate heat at an intense rate."

datum/pathogeneffects/malevolent/chills
	name = "Common Chills"
	desc = "The infected feels the sensation of lowered body temperature."
	infect_type = INFECT_NONE
	rarity = RARITY_COMMON
	disease_act(var/mob/M as mob, var/datum/pathogen/origin)
		if (!origin.symptomatic)
			return
		switch (origin.stage)
			if (1)
				if (prob(5))
					M.bodytemperature -= 1
					M.show_message("<span class='alert'>You feel a little cold.</span>")
			if (2)
				if (prob(9))
					M.bodytemperature -= 2
					M.show_message("<span class='alert'>You feel cold.</span>")
			if (3)
				if (prob(11))
					M.bodytemperature -= 4
					M.show_message("<span class='alert'>You feel cold.</span>")
					M.emote("shiver")
			if (4)
				if (prob(13))
					M.bodytemperature -= 8
					M.show_message("<span class='alert'>You feel cold.</span>")
					M.emote("shiver")
			if (5)
				if (prob(15))
					M.bodytemperature -= 12
					M.show_message("<span class='alert'>You feel rather cold.</span>")
					M.emote("shiver")
		if (M.bodytemperature < 0)
			M.bodytemperature = 0

	may_react_to()
		return "The pathogen is producing a trail of ice. Perhaps something hot might affect it."

	react_to(var/R, var/zoom)
		if (R == "phlogiston" || R == "infernite")
			return "The hot reagent melts the trail of ice completely."

datum/pathogeneffects/malevolent/seriouschills
	name = "Acute Chills"
	desc = "The infected feels the sensation of seriously lowered body temperature."
	infect_type = INFECT_NONE
	rarity = RARITY_RARE

	proc/create_icing(var/mob/M)
		var/obj/decal/icefloor/I = unpool(/obj/decal/icefloor)
		I.loc = get_turf(M)
		SPAWN_DBG (300)
			pool(I)

	disease_act(var/mob/M as mob, var/datum/pathogen/origin)
		if (!origin.symptomatic)
			return
		switch (origin.stage)
			if (1)
				if (prob(5))
					M.bodytemperature -= 2
					M.show_message("<span class='alert'>You feel a little cold.</span>")
			if (2)
				if (prob(9))
					M.bodytemperature -= 4
					M.show_message("<span class='alert'>You feel cold.</span>")
			if (3)
				if (prob(11))
					M.bodytemperature -= 12
					M.show_message("<span class='alert'>You feel rather cold.</span>")
					M.emote("shiver")
				if (prob(1) && isturf(M.loc))
					M.show_message("<span class='alert'>You spontaneously freeze!</span>")
					M.bodytemperature -= 16
					new /obj/icecube(get_turf(M), M)
			if (4)
				if (prob(50))
					create_icing(M)
				if (prob(13))
					if (prob(15) && isturf(M.loc))
						M.delStatus("burning")
						M.show_message("<span class='alert'>You spontaneously freeze!</span>")
						M.bodytemperature -= 20
						new /obj/icecube(get_turf(M), M)
					else
						M.bodytemperature -= 20
						M.show_message("<span class='alert'>You feel pretty damn cold.</span>")
						M.changeStatus("stunned", 1 SECOND)
						M.emote("shiver")

			if (5)
				if (prob(50))
					create_icing(M)
				if (prob(15))
					if (prob(25) && isturf(M.loc))
						M.delStatus("burning")
						M.show_message("<span class='alert'>You spontaneously freeze!</span>")
						M.bodytemperature -= 23
						new /obj/icecube(get_turf(M), M)
					else
						M.bodytemperature -= 23
						M.show_message("<span class='alert'>You're freezing!</span>")
						M.changeStatus("stunned", 2 SECONDS)
						M.emote("shiver")
		if (M.bodytemperature < 0)
			M.bodytemperature = 0

	may_react_to()
		return "The pathogen is producing a trail of ice. Perhaps something hot might affect it."

	react_to(var/R, var/zoom)
		if (R == "phlogiston" || R == "infernite")
			return "The hot reagent barely melts the trail of ice."

datum/pathogeneffects/malevolent/seriouschills/ultimate
	name = "Arctic Chills"
	desc = "The infected feels the sensation of seriously lowered body temperature. And might spontaneously become an ice statue."
	infect_type = INFECT_NONE
	rarity = RARITY_VERY_RARE

	disease_act(var/mob/M as mob, var/datum/pathogen/origin)
		if (!origin.symptomatic)
			return
		switch (origin.stage)
			if (1 to 3)
				if (prob(origin.stage * 4))
					M.bodytemperature -= rand(origin.stage * 5)
					M.show_message("<span class='alert'>You feel [pick("a little ", "a bit ", "rather ", "")] cold.</span>")
				if (prob(origin.stage - 1) && isturf(M.loc))
					M.show_message("<span class='alert'>You spontaneously freeze!</span>")
					M.bodytemperature -= 25
					new /obj/icecube(get_turf(M), M)
			if (4)
				if (prob(50))
					create_icing(M)
				if (prob(13))
					if (prob(15) && isturf(M.loc))
						M.delStatus("burning")
						M.show_message("<span class='alert'>You spontaneously freeze!</span>")
						M.bodytemperature -= 30
						new /obj/icecube(get_turf(M), M)
					else
						M.bodytemperature -= 30
						M.show_message("<span class='alert'>You pretty damn cold.</span>")
						M.changeStatus("stunned", 1 SECOND)
						M.emote("shiver")

			if (5)
				if (prob(50))
					create_icing(M)
				if (prob(15))
					if (prob(25) && isturf(M.loc))
						M.delStatus("burning")
						M.show_message("<span class='alert'>You spontaneously freeze!</span>")
						M.bodytemperature -= 30
						new /obj/icecube(get_turf(M), M)
					else
						M.bodytemperature -= 50
						M.show_message("<span class='alert'>[pick("You're freezing!", "You're getting cold...", "So very cold...", "You feel your skin turning into ice...")]</span>")
						M.changeStatus("stunned", 3 SECONDS)
						M.emote("shiver")
				if (prob(1) && !M.bioHolder.HasOneOfTheseEffects("cold_resist","thermal_resist"))
					M.show_message("<span class='alert'>You freeze completely!</span>")
					logTheThing("pathology", usr, null, "was ice statuified by symptom [src].")
					M:become_ice_statue()
		if (M.bodytemperature < 0)
			M.bodytemperature = 0

	may_react_to()
		return "The pathogen is producing a trail of ice. Perhaps something hot might affect it."

	react_to(var/R, var/zoom)
		if (R == "phlogiston" || R == "infernite")
			return "The hot reagent doesn't affect the trail of ice at all!"

datum/pathogeneffects/malevolent/farts
	name = "Farts"
	desc = "The infected individual occasionally farts."
	infect_type = INFECT_AREA
	spread = SPREAD_AIR
	rarity = RARITY_VERY_COMMON
	var/cooldown = 50 // we just use the name of the symptom to keep track of different fart effects, so their cooldowns do not interfere
	var/doInfect = 1 // smoke farts were just too good

	proc/fart(var/mob/M, var/datum/pathogen/origin, var/voluntary)
		if(doInfect)
			infect_cloud(M, origin)
		if(voluntary)
			origin.symptom_data[name] = TIME

	onemote(mob/M as mob, act, voluntary, datum/pathogen/P)
		// involuntary farts are free, but the others use the cooldown
		if(voluntary && TIME-P.symptom_data[name] < cooldown)
			return
		if(act == "fart")
			fart(M, P, voluntary)

	disease_act(var/mob/M, var/datum/pathogen/origin)
		if (!origin.symptomatic)
			return
		if (prob(origin.stage * 3))
			M.emote("fart")

	may_react_to()
		return "The pathogen appears to produce a large volume of gas."

datum/pathogeneffects/malevolent/farts/smoke
	name = "Smoke Farts"
	desc = "The infected individual occasionally farts reagent smoke."
	rarity = RARITY_RARE
	cooldown = 600
	doInfect = 0 // the whole point is to not instantly infect a huge area, that's what got us into this mess >.>

	fart(var/mob/M, var/datum/pathogen/origin, var/voluntary)
		if (M.reagents.total_volume)
			smoke_reaction(M.reagents, origin.stage, get_turf(M))
			..()			// only trigger if we actually have chems, else no infection or cooldown

	may_react_to()
		return "The pathogen appears to produce a large volume of gas."

	react_to(var/R, var/zoom)
		var/datum/reagents/H = new /datum/reagents(5)
		H.add_reagent(R, 5)
		var/datum/reagent/RE = H.get_reagent(R)
		return "The [RE.name] violently explodes into a puff of smoke when coming into contact with the pathogen."

datum/pathogeneffects/malevolent/farts/plasma
	name = "Plasma Farts"
	desc = "The infected individual occasionally farts. Plasma."
	rarity = RARITY_UNCOMMON
	cooldown = 600

	fart(var/mob/M, var/datum/pathogen/origin, var/voluntary)
		..()
		var/turf/T = get_turf(M)
		var/datum/gas_mixture/gas = unpool(/datum/gas_mixture)
		gas.zero()
		gas.toxins = origin.stage * (voluntary ? 0.6 : 3) // only a fifth for voluntary farts
		gas.temperature = T20C
		gas.volume = R_IDEAL_GAS_EQUATION * T20C / 1000
		if (T)
			T.assume_air(gas)

	disease_act(var/mob/M, var/datum/pathogen/origin)
		if (!origin.symptomatic)
			return
		..()
		if (origin.stage > 2 && prob(origin.stage * 3))
			M.take_toxin_damage(1)
			M.take_oxygen_deprivation(4)

	react_to(var/R, var/zoom)
		if (R == "infernite" || R == "phlogiston")
			return "The gas lights up in a puff of flame."

datum/pathogeneffects/malevolent/farts/co2
	name = "CO2 Farts"
	desc = "The infected individual occasionally farts. Carbon dioxide."
	rarity = RARITY_RARE
	cooldown = 600

	fart(var/mob/M, var/datum/pathogen/origin, var/voluntary)
		..()
		var/turf/T = get_turf(M)
		var/datum/gas_mixture/gas = unpool(/datum/gas_mixture)
		gas.zero()
		gas.carbon_dioxide = origin.stage * (voluntary ? 1.4 : 7) // only a fifth for voluntary farts
		gas.temperature = T20C
		gas.volume = R_IDEAL_GAS_EQUATION * T20C / 1000
		if (T)
			T.assume_air(gas)

	disease_act(var/mob/M, var/datum/pathogen/origin)
		if (!origin.symptomatic)
			return
		..()
		if (origin.stage > 2 && prob(origin.stage * 3))
			M.take_toxin_damage(1)
			M.take_oxygen_deprivation(4)

	react_to(var/R, var/zoom)
		if (R == "infernite" || R == "phlogiston")
			return "The flame of the hot reagents is snuffed by the gas."


datum/pathogeneffects/malevolent/farts/o2
	name = "O2 Farts"
	desc = "The infected individual occasionally farts. Pure oxygen."
	rarity = RARITY_COMMON
	beneficial = 1
	cooldown = 50
	// ahahahah this is so stupid
	// i have no idea what these numbers mean but i hope it's funny

	fart(var/mob/M, var/datum/pathogen/origin, var/voluntary)
		..()
		var/turf/T = get_turf(M)
		var/datum/gas_mixture/gas = unpool(/datum/gas_mixture)
		gas.zero()
		gas.oxygen = origin.stage * (voluntary ? 20 : 2) // ten times as much for voluntary farts
		gas.temperature = T20C
		gas.volume = R_IDEAL_GAS_EQUATION * T20C / 1000
		if (T)
			T.assume_air(gas)

	react_to(var/R, var/zoom)
		if (R == "infernite" || R == "phlogiston")
			return "The flame of the hot reagents is oxidized by the gas."

datum/pathogeneffects/malevolent/leprosy
	name = "Leprosy"
	desc = "The infected individual is losing limbs."
	rarity = RARITY_VERY_RARE

	disease_act(var/mob/living/carbon/human/M, var/datum/pathogen/origin)
		if (origin.stage < 3 || !origin.symptomatic)
			return
		switch (origin.stage)
			if (3)
				if (prob(15))
					M.show_message(pick("<span class='alert'>You feel a bit loose...</span>", "<span class='alert'>You feel like you're falling apart.</span>"))
			if (4 to 5)
				if (prob(2 + origin.stage))
					var/limb_name = pick("l_arm","r_arm","l_leg","r_leg")
					var/obj/item/parts/limb = M.limbs.vars[limb_name]
					if (istype(limb))
						if (limb.remove_stage < 2)
							limb.remove_stage = 2
							M.show_message("<span class='alert'>Your [limb] comes loose!</span>")
							SPAWN_DBG(rand(150, 200))
								if (limb.remove_stage == 2)
									limb.remove(0)
	may_react_to()
		return "The pathogen appears to be rapidly breaking down certain materials around it."

datum/pathogeneffects/malevolent/senility
	name = "Senility"
	desc = "Infection damages nerve cells in the host's brain."
	rarity = RARITY_RARE
	infect_type = INFECT_NONE
	disease_act(var/mob/M as mob, var/datum/pathogen/origin)
		if (!origin.symptomatic)
			return
		switch (origin.stage)
			if (1)
				if (prob(10))
					M.show_message("<span class='alert'>You feel a little confused.</span>")
			if (2)
				if (prob(5))
					M.show_message("<span class='alert'>Your head hurts. You're not sure what's going on.</span>")
					M.take_brain_damage(1)
			if (3)
				if (prob(40))
					M.emote("drool")
				if (prob(20))
					M.show_message("<span class='alert'>... huh?</span>")
					M.take_brain_damage(2)
			if (4)
				if (prob(30))
					M.emote("drool")
				else if (prob(30))
					M.emote("nosepick")
				if (prob(20))
					M.show_message("<span class='alert'>You feel... unsmart.</span>")
					M.take_brain_damage(3)
			if (5)
				if (prob(10))
					M.show_message("<span class='alert'>You completely forget what you were doing.</span>")
					M.drop_item()
					M.take_brain_damage(4)
	may_react_to()
		return "The pathogen appears to have a gland that may affect neural functions."

datum/pathogeneffects/malevolent/beesneeze
	name = "Projectile Bee Egg Sneezing"
	desc = "The infected sneezes bee eggs frequently."
	rarity = RARITY_UNCOMMON

	proc/sneeze(var/mob/M, var/datum/pathogen/origin)
		if (!M || !origin)
			return
		var/turf/T = get_turf(M)
		var/flyroll = rand(10)
		var/turf/target = locate(M.x,M.y,M.z)
		var/chosen_phrase = pick("<B><span class='alert'>W</span><span class='notice'>H</span>A<span class='alert'>T</span><span class='notice'>.</span></B>","<span class='alert'><B>What the [pick("hell","fuck","christ","shit")]?!</B></span>","<span class='alert'><B>Uhhhh. Uhhhhhhhhhhhhhhhhhhhh.</B></span>","<span class='alert'><B>Oh [pick("no","dear","god","dear god","sweet merciful [pick("neptune","poseidon")]")]!</B></span>")
		switch (M.dir)
			if (NORTH)
				target = locate(M.x, M.y+flyroll, M.z)
			if (SOUTH)
				target = locate(M.x, M.y-flyroll, M.z)
			if (EAST)
				target = locate(M.x+flyroll, M.y, M.z)
			if (WEST)
				target = locate(M.x-flyroll, M.y, M.z)
		var/obj/item/reagent_containers/food/snacks/ingredient/egg/bee/toThrow = new /obj/item/reagent_containers/food/snacks/ingredient/egg/bee(T)
		M.visible_message("<span class='alert'>[M] sneezes out a space bee egg!</span> [chosen_phrase]", "<span class='alert'>You sneeze out a bee egg!</span> [chosen_phrase]", "<span class='alert'>You hear someone sneezing.</span>")
		toThrow.throw_at(target, 6, 1)
		src.infect_cloud(M, origin, 10)

	disease_act(var/mob/M as mob, var/datum/pathogen/origin)
		if (!origin.symptomatic)
			return
		switch (origin.stage)
			if (1)
				if (prob(4))
					sneeze(M, origin)
			if (2)
				if (prob(6))
					sneeze(M, origin)
			if (3)
				if (prob(8))
					sneeze(M, origin)
			if (4)
				if (prob(10))
					sneeze(M, origin)
			if (5)
				if (prob(12))
					sneeze(M, origin)

	may_react_to()
		return "The pathogen appears to generate a high amount of fluids. Honey, to be more specific."

	react_to(var/R, var/zoom)
		if (R == "pepper")
			return "The pathogen violently discharges honey when coming in contact with pepper."

datum/pathogeneffects/malevolent/mutation
	name = "Random Mutations"
	desc = "The infected individual occasionally mutates wildly!"
	infect_type = INFECT_NONE
	rarity = RARITY_VERY_RARE

	//multiply origin.stage by this number to get the percent probability of a mutation occurring per disease_act
	//please keep it between 1 and 20, inclusive, if possible.
	var/mut_prob_mult = 4

	//this sets the kind of mutations we can pick from: "good" for good mutations, "bad" for bad mutations, "either" for both
	var/mutation_type = "either"

	//set this to 1 to pick mutations weighted by their rarities, set it to 0 to pick with equal weighting
	var/respect_probability = 1

	//probability in percent form (1-100) of a chromosome being applied to a mutation
	var/chrom_prob = 50

	//list of valid chromosome types to pick from. In this case, all extant ones except the weakener
	var/list/chrom_types = list(/datum/dna_chromosome, /datum/dna_chromosome/anti_mutadone, /datum/dna_chromosome/stealth, /datum/dna_chromosome/power_enhancer, /datum/dna_chromosome/cooldown_reducer, /datum/dna_chromosome/safety)

	proc/mutate(var/mob/M, var/datum/pathogen/origin)
		if (M.bioHolder)
			if(prob(chrom_prob))
				var/type_to_make = pick(chrom_types)
				var/datum/dna_chromosome/C = new type_to_make()
				M.bioHolder.RandomEffect(mutation_type, respect_probability, C)
			else
				M.bioHolder.RandomEffect(mutation_type, respect_probability)

	disease_act(var/mob/M, var/datum/pathogen/origin)
		if (!origin.symptomatic)
			return
		if (prob(origin.stage * mut_prob_mult))
			mutate(M, origin)

	may_react_to()
		return "The pathogen appears to be shifting and distorting its genetic structure rapidly."

	react_to(var/R, var/zoom)
		if (R == "mutadone")
			if (zoom)
				return "Approximately 82.7% of the individual microbodies appear to have returned to genetic normalcy."
			else
				return "The pathogen appears to have settled down significantly in the presence of the mutadone."

datum/pathogeneffects/malevolent/mutation/reinforced
	name = "Random Reinforced Mutations"
	desc = "The infected individual occasionally mutates wildly and permanently!"
	mut_prob_mult = 3
	chrom_prob = 100 //guaranteed chromosome application
	chrom_types = list(/datum/dna_chromosome/anti_mutadone) //reinforcer chromosome

	react_to(var/R, var/zoom)
		if (R == "mutadone")
			if (zoom)
				return "Approximately 0.00% of the individual microbodies appear to have returned to genetic normalcy."
			else
				return "The pathogen seems to have developed a resistance to the mutadone."

//Technically, this SHOULD be under datum/pathogeneffects/benevolent, but doing it this way avoids duplicating code.
//Plus, it's not exactly unprecedented for a malevolent effect to actually be beneficial.
//Just look at the sunglass gland symptom
datum/pathogeneffects/malevolent/mutation/beneficial
	name = "Random Good and Stable Mutations"
	desc = "The infected individual occasionally mutates wildly and beneficially!"
	mut_prob_mult = 3
	mutation_type = "good"
	chrom_prob = 100 //guranteed chromosome application
	chrom_types = list(/datum/dna_chromosome) //stabilizer, no instability caused
	beneficial = 1

	react_to(var/R, var/zoom)
		if (R == "mutadone")
			if (zoom)
				return "Approximately 99.82% of the individual microbodies appear to have returned to genetic normalcy. Approximately 100.00% of the individual microbodies appear disappointed about that."
			else
				return "The pathogen seems to have reluctantly settled down in the presence of the mutadone."

datum/pathogeneffects/malevolent/radiation
	name = "Radioactive Infection"
	desc = "Infection irradiates the host's cells."
	infect_type = INFECT_NONE
	rarity = RARITY_RARE

	disease_act(var/mob/M as mob, var/datum/pathogen/origin)
		if (!origin.symptomatic)
			return
		switch (origin.stage)
			if (1 to 3)
				if (prob(5 * origin.stage + 3))
					M.changeStatus("radiation", origin.stage)
					boutput(M,"<span class='alert'>You feel sick.</span>")
			if (4)
				if (prob(13))
					M.changeStatus("radiation", 30)
					boutput(M,"<span class='alert'>You feel very sick!</span>")
				else if (prob(26))
					M.changeStatus("radiation", 2 SECONDS)
					boutput(M,"<span class='alert'>You feel sick.</span>")
			if (5)
				if (prob(15))
					M.changeStatus("radiation", rand(20,40))
					boutput(M,"<span class='alert'>You feel extremely sick!!</span>")
				else if (prob(20))
					M.changeStatus("radiation", 30)
					boutput(M,"<span class='alert'>You feel very sick!</span>")
				else if (prob(40))
					M.changeStatus("radiation", 2 SECONDS)
					boutput(M,"<span class='alert'>You feel sick.</span>")


	may_react_to()
		return "A curiously shaped gland on the pathogen is emitting an unearthly blue glow." //Cherenkov radiation

	react_to(var/R, var/zoom)
		if (R == "silver")
			return "The silver appears to be moderating the reaction within the pathogen's gland." //neutron capture

datum/pathogeneffects/malevolent/snaps
	name = "Snaps"
	desc = "The infection forces its host's fingers to occasionally snap."
	infect_type = INFECT_AREA
	spread = SPREAD_FACE | SPREAD_HANDS | SPREAD_AIR | SPREAD_BODY
	infect_message = "<span class='alert'>That's a pretty catchy groove...</span>" //you might even say it's infectious
	rarity = RARITY_COMMON

	proc/snap(var/mob/M, var/datum/pathogen/origin)
		M.emote("snap")
		if(prob(20))  // an infectious sou- wait fuck someone made that joke already 5 lines above
			src.infect_snap(M, origin)

	disease_act(var/mob/M, var/datum/pathogen/origin)
		if (!origin.symptomatic)
			return
		if (prob(origin.stage * 3))
			snap(M, origin)

	may_react_to()
		return "The pathogen seems like it might respond to strong sonic impulses."

	react_to(var/R, var/zoom)
		if (R == "sonicpowder")
			if (zoom)
				return "The individual microbodies appear to be forming a very simplistic rhythm with their explosive snaps."
			else
				return "The pathogen appears to be using the powder granules as microscopic musical instruments."

datum/pathogeneffects/malevolent/snaps/jazz
	name = "Jazz Snaps"
	desc = "The infection forces its host's fingers to occasionally snap. Also, it transforms the host into a jazz musician."
	rarity = RARITY_RARE

	proc/jazz(var/mob/living/carbon/human/H as mob)
		H.show_message("<span class='notice'>[pick("You feel cooler!", "You feel smooth and laid-back!", "You feel jazzy!", "A sudden soulfulness fills your spirit!")]</span>")
		if (!(H.w_uniform && istype(H.w_uniform, /obj/item/clothing/under/misc/syndicate)))
			var/obj/item/clothing/under/misc/syndicate/T = new /obj/item/clothing/under/misc/syndicate(H)
			T.name = "Jazzy Turtleneck"
			if (H.w_uniform)
				H.u_equip(H.w_uniform)
			H.equip_if_possible(T, H.slot_w_uniform)
		if (!(H.head && istype(H.head, /obj/item/clothing/head/flatcap)))
			var/obj/item/clothing/head/flatcap/F = new /obj/item/clothing/head/flatcap(H)
			if (H.head)
				H.u_equip(H.head)
			H.equip_if_possible(F, H.slot_head)

		if (!H.find_type_in_hand(/obj/item/instrument/saxophone))
			var/obj/item/instrument/saxophone/D = new /obj/item/instrument/saxophone(H)
			if(!(H.put_in_hand(D) == 1))
				var/drophand = (H.hand == 0 ? H.slot_r_hand : H.slot_l_hand) //basically works like a derringer
				H.drop_item()
				D.set_loc(H)
				H.equip_if_possible(D, drophand)
		H.set_clothing_icon_dirty()

	snap(var/mob/M, var/datum/pathogen/origin)
		..()
		if (ishuman(M))
			var/mob/living/carbon/human/H = M
			if (H.find_type_in_hand(/obj/item/instrument/saxophone)) //bonus saxophone playing capability that doesn't count toward sax cooldown
				var/obj/item/instrument/saxophone/sax = H.find_type_in_hand(/obj/item/instrument/saxophone)
				var/list/aud = sax.sounds_instrument
				playsound(get_turf(H), pick(aud), 50, 1)

	disease_act(var/mob/M, var/datum/pathogen/origin)
		if (!origin.symptomatic)
			return
		if(prob(origin.stage*5))
			switch(origin.stage)
				if (1 to 2)
					snap(M, origin)
				if (3 to 5)
					if (prob(origin.stage*3)) // jazz first so we can jam right away
						if (ishuman(M))
							var/mob/living/carbon/human/H = M
							jazz(H)
					snap(M, origin)

	may_react_to()
		return "The pathogen seems like it might respond to strong sonic impulses."

	react_to(var/R, var/zoom)
		if (R == "sonicpowder")
			if (zoom)
				return "The individual microbodies appear to be playing smooth jazz."
			else
				return "The pathogen appears to be using the powder granules to make microscopic... saxophones???"

datum/pathogeneffects/malevolent/snaps/wild
	name = "Wild Snaps"
	desc = "The infection forces its host's fingers to constantly and painfully snap. Highly contagious."
	rarity = RARITY_VERY_RARE


	proc/snap_arm(var/mob/M, var/datum/pathogen/origin)
		if (!origin.symptomatic)
			return
		else if(ishuman(M))
			var/mob/living/carbon/human/H = M

			var/list/possible_limbs = list()

			if (H.limbs.l_arm)
				possible_limbs += H.limbs.l_arm
			if (H.limbs.r_arm)
				possible_limbs += H.limbs.r_arm

			if (possible_limbs.len)
				var/obj/item/parts/P = pick(possible_limbs)
				H.visible_message("<span class='alert'>[H.name] violently swings [his_or_her(H)] [initial(P.name)] to provide the necessary energy for producing a thunderously loud finger snap!</span>", "<span class='alert'>You violently swing your [initial(P.name)] to provide the necessary energy for producing a thunderously loud finger snap!</span>")
				playsound(H.loc, H.sound_snap, 200, 1, 5910) //5910 is approximately the same extra range from which you could hear a max-power artifact bomb
				playsound(H.loc, "explosion", 200, 1, 5910)
				P.sever()
				random_brute_damage(H, 40) //makes it equivalent to damage from 2 excessive fingersnap triggers

	snap(var/mob/M, var/datum/pathogen/origin)
		if(prob((origin.stage-3)*3))
			snap_arm(M, origin)
			src.infect_snap(M, origin, 9)
			return
		else
			// no fuck this we are not snapping 25 times, it kills people's byond and eardrums
			// TODO: make cool echo snap sound?
			M.emote("snap")
			playsound(M.loc, 'sound/effects/fingersnap_echo.ogg', 150, 1, 2000)
			src.infect_snap(M, origin, 9)

	disease_act(var/mob/M, var/datum/pathogen/origin)
		if (!origin.symptomatic)
			return
		if (prob((origin.stage * origin.stage)+5))
			snap(M, origin)

	may_react_to()
		return "The pathogen seems like it might respond to strong sonic impulses."

	react_to(var/R, var/zoom)
		if (R == "sonicpowder")
			if (zoom)
				return "The individual microbodies appear to be playing some form of freeform jazz. They are clearly off-key."
			else
				return "The pathogen appears to be using the powder granules to make microscopic... saxophones???"


datum/pathogeneffects/malevolent/detonation
	name = "Necrotic Detonation"
	desc = "The pathogen will cause you to violently explode upon death."
	rarity = RARITY_VERY_RARE

	may_react_to()
		return "Some of the pathogen's dead cells seem to remain active."

	ondeath(mob/M as mob, var/datum/pathogen/origin)
		if (!origin.symptomatic)
			return
		explosion_new(M, get_turf(M), origin.stage*5, origin.stage/2.5)

	react_to(var/R, var/zoom)
		if (R == "synthflesh")
			return "There are stray synthflesh pieces all over the dish."

