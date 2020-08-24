#ifdef CREW_OBJECTIVES

/datum/controller/gameticker/proc
	generate_crew_objectives()
		set background = 1
		if (master_mode == "construction")
			return
		for (var/datum/mind/crewMind in minds)
			if(prob(10)) generate_miscreant_objectives(crewMind)
			else generate_individual_objectives(crewMind)

		return

	generate_individual_objectives(var/datum/mind/crewMind)
		set background = 1
		//Requirements for individual objectives: 1) You have a mind (this eliminates 90% of our playerbase ~heh~)
												//2) You are not a traitor
		if (!crewMind)
			return
		if (!crewMind.current || !crewMind.objectives || crewMind.objectives.len || crewMind.special_role || (crewMind.assigned_role == "MODE"))
			return

		var/rolePathString = ckey(crewMind.assigned_role)
		if (!rolePathString)
			return

		rolePathString = "/datum/objective/crew/[rolePathString]"
		var/rolePath = text2path(rolePathString)
		if (isnull(rolePath))
			return

		var/list/objectiveTypes = concrete_typesof(rolePath)
		if (!objectiveTypes.len)
			return

		var/obj_count = 1
		var/assignCount = min(rand(1,3), objectiveTypes.len)
		while (assignCount && objectiveTypes.len)
			assignCount--
			var/selectedType = pick(objectiveTypes)
			var/datum/objective/crew/newObjective = new selectedType
			objectiveTypes -= newObjective.type

			newObjective.owner = crewMind
			crewMind.objectives += newObjective
			newObjective.setup()

			if (obj_count <= 1)
				boutput(crewMind.current, "<B>Your OPTIONAL Crew Objectives are as follows:</b>")
			boutput(crewMind.current, "<B>Objective #[obj_count]</B>: [newObjective.explanation_text]")
			obj_count++

		var/mob/crewmob = crewMind.current
		if (crewmob.traitHolder && crewmob.traitHolder.hasTrait("conspiracytheorist") && prob(20))
			/*var/conspiracy_text = ""
			var/noun = pick_string("conspiracy_theories.txt", "noun")
			var/conspiracy = pick_string("conspiracy_theories.txt", "conspiracy")
			var/reason = pick_string("conspiracy_theories.txt", "reason")
			var/objective = pick_string("conspiracy_theories.txt", "objective")
			conspiracy_text = "The [noun] are [conspiracy] in order to [reason]. [objective]"
			conspiracy_text = replacetext(conspiracy_text, "%THING%", pick_string("conspiracy_theories.txt", "thing"))*/
			var/conspiracy_text = pick_smart_string("conspiracy_theories.txt", "conspiracy_text")

			boutput(crewmob, "<B>Objective #[obj_count]</B>: [conspiracy_text]")

		return

/*
 *	HOW-TO: Make Crew Objectives
 *	It's literally as simple as defining an objective of type "/datum/objective/crew/[ckey(job title) goes here]/objective name"
 *	Please take note that it goes live as soon as you define it, so if it isn't ready you should probably comment it out!!
 */

ABSTRACT_TYPE(/datum/objective/crew)
/datum/objective/crew
	proc/setup()

ABSTRACT_TYPE(/datum/objective/crew/captain)
/datum/objective/crew/captain
	hat
		explanation_text = "Don't lose your hat!"
		medal_name = "Hatris"
		check_completion()
			if(owner.current && owner.current.check_contents_for(/obj/item/clothing/head/caphat || owner.current.check_contents_for(/obj/item/clothing/head/fancy/captain)))
				return 1
			else
				return 0
	drunk
		explanation_text = "Have alcohol in your bloodstream at the end of the round."
		medal_name = "Edward Smith"
		check_completion()
			if(owner.current && owner.current.reagents && owner.current.reagents.has_reagent("ethanol"))
				return 1
			else
				return 0

ABSTRACT_TYPE(/datum/objective/crew/headofsecurity)
/datum/objective/crew/headofsecurity
	hat
		explanation_text = "Don't lose your hat/beret!"
		medal_name = "Hatris"
		check_completion()
			if(owner.current && owner.current.check_contents_for(/obj/item/clothing/head/helmet/HoS))
				return 1
			else
				return 0
	brig
		explanation_text = "Have at least one antagonist cuffed in the brig at the end of the round." //can be dead as people usually suicide
		medal_name = "Suitable? How about the Oubliette?!"
		check_completion()
			for(var/datum/mind/M in ticker.minds)
				if(M.special_role && M.current && !isobserver(M.current) && istype(get_area(M.current),/area/station/security/brig) && M.current.hasStatus("handcuffed")) //think that's everything...
					return 1
			return 0
	centcom
		explanation_text = "Bring at least one antagonist back to CentCom in handcuffs for interrogation. You must accompany them on the escape shuttle." //can also be dead I guess
		medal_name = "Dead or alive, you're coming with me"
		check_completion()
			for(var/datum/mind/M in ticker.minds)
				if(M.special_role && M.current && !isobserver(M.current) && in_centcom(M.current) && M.current.hasStatus("handcuffed"))
					if(owner.current && !isdead(owner.current) && in_centcom(owner.current)) //split this up as it was long
						return 1
			return 0

	brigstir
		explanation_text = "Keep Monsieur Stirstir brigged but also make sure that he comes to absolutely no harm."
		medal_name = "Monkey Duty"
		check_completion()
			for(var/mob/living/carbon/human/npc/monkey/stirstir/M in mobs)
				if(!isdead(M) && (M.get_brute_damage() + M.get_oxygen_deprivation() + M.get_burn_damage() + M.get_toxin_damage()) == 0 && istype(get_area(M),/area/station/security/brig))
					return 1
			return 0

ABSTRACT_TYPE(/datum/objective/crew/headofpersonnel)
/datum/objective/crew/headofpersonnel
	vanish
		explanation_text = "End the round alive but not on the station or escape levels."
		medal_name = "Unperson"
		check_completion()
			if(owner.current && !isdead(owner.current) && owner.current.z != 1 && !in_centcom(owner.current)) return 1
			else return 0

ABSTRACT_TYPE(/datum/objective/crew/chiefengineer)
/datum/objective/crew/chiefengineer
	furnaces
		explanation_text = "Make sure all furnaces on the station are active at the end of the round."
		medal_name = "Slow Burn"
		check_completion()
			for(var/obj/machinery/power/furnace/F in machine_registry[MACHINES_POWER])
				if(F.z == 1 && F.active == 1)
					return 1
			return 0
	ptl
		explanation_text = "Earn at least a million credits via the PTL."
		medal_name = "1.21 Jiggawatts"
		check_completion()
			for(var/obj/machinery/power/pt_laser/P in machine_registry[MACHINES_POWER])
				if(P.lifetime_earnings >= 1 MEGA)
					return 1
			return 0

ABSTRACT_TYPE(/datum/objective/crew/securityofficer)
/datum/objective/crew/securityofficer // grabbed the HoS's two antag-related objectives cause they work just fine for regular sec too, so...?
	/*brig
		explanation_text = "Have at least one antagonist cuffed in the brig at the end of the round." //can be dead as people usually suicide
		medal_name = "Suitable? How about the Oubliette?!"
		check_completion()
			for(var/datum/mind/M in ticker.minds)
				if(M.special_role && M.current && !isobserver(M.current) && istype(get_area(M.current),/area/station/security/brig) && M.current.hasStatus("handcuffed")) //think that's everything...
					return 1
			return 0
	*/
	centcom
		explanation_text = "Bring at least one antagonist back to CentCom in handcuffs for interrogation. You must accompany them on the escape shuttle." //can also be dead I guess
		medal_name = "Dead or alive, you're coming with me"
		check_completion()
			for(var/datum/mind/M in ticker.minds)
				if(M.special_role && M.current && !isobserver(M.current) && in_centcom(M.current) && M.current.hasStatus("handcuffed"))
					if(owner.current && !isdead(owner.current) && in_centcom(owner.current)) //split this up as it was long
						return 1
			return 0
	brigstir
		explanation_text = "Keep Monsieur Stirstir brigged but also make sure that he comes to absolutely no harm."
		medal_name = "Monkey Duty"
		check_completion()
			for(var/mob/living/carbon/human/npc/monkey/stirstir/M in mobs)
				if(!isdead(M) && (M.get_brute_damage() + M.get_oxygen_deprivation() + M.get_burn_damage() + M.get_toxin_damage()) == 0 && istype(get_area(M),/area/station/security/brig))
					return 1
			return 0

ABSTRACT_TYPE(/datum/objective/crew/quartermaster)
/datum/objective/crew/quartermaster
	profit
		explanation_text = "End the round with a budget of over 50,000 credits."
		medal_name = "Tax Haven"
		check_completion()
			if(wagesystem.shipping_budget > 50000) return 1
			else return 0

ABSTRACT_TYPE(/datum/objective/crew/detective)
/datum/objective/crew/detective
	drunk
		explanation_text = "Have alcohol in your bloodstream at the end of the round."
		medal_name = "Tipsy"
		check_completion()
			if(owner.current && owner.current.reagents && owner.current.reagents.has_reagent("ethanol"))
				return 1
			else
				return 0
	gear
		explanation_text = "Ensure that you are still wearing your coat, hat and uniform at the end of the round."
		medal_name = "Neither fashionable noir stylish"
		check_completion()
			if(owner.current && ishuman(owner.current))
				var/mob/living/carbon/human/H = owner.current
				if(istype(H.w_uniform, /obj/item/clothing/under/rank/det) && istype(H.wear_suit, /obj/item/clothing/suit/det_suit) && istype(H.head, /obj/item/clothing/head/det_hat)) return 1
			return 0
	smoke
		explanation_text = "Make sure you're smoking at the end of the round."
		medal_name = "Where's the smoking gun?"
		check_completion()
			if(owner.current && istype(owner.current.wear_mask,/obj/item/clothing/mask/cigarette)) return 1
			else return 0

ABSTRACT_TYPE(/datum/objective/crew/botanist)
/datum/objective/crew/botanist
	mutantplants
		explanation_text = "Have at least three mutant plants alive at the end of the round."
		medal_name = "Bill Masen"
		check_completion()
			var/mutcount = 0
			for(var/obj/machinery/plantpot/PP in machine_registry[MACHINES_PLANTPOTS])
				if(PP.current)
					var/datum/plantgenes/DNA = PP.plantgenes
					var/datum/plantmutation/MUT = DNA.mutation
					if (MUT)
						mutcount++
						if(mutcount >= 3) return 1
			return 0
	noweed
		explanation_text = "Make sure there are no cannabis plants, seeds or products in Hydroponics at the end of the round."
		medal_name = "Reefer Madness"
		check_completion()
			for(var/obj/item/X in world)
				var/obj/item/clothing/mask/cigarette/W = X
				if (istype(W) && W.reagents && W.reagents.has_reagent("THC"))
					if (istype(get_area(W), /area/station/hydroponics))
						return 0
				var/obj/item/plant/herb/cannabis/C = X
				if (istype(C) && istype(get_area(C), /area/station/hydroponics))
					return 0
				var/obj/item/seed/cannabis/S = X
				if (istype(S) && istype(get_area(S), /area/station/hydroponics))
					return 0
			for (var/obj/machinery/plantpot/PP in machine_registry[MACHINES_PLANTPOTS])
				if (PP.current && istype(PP.current, /datum/plant/herb/cannabis))
					if (istype(get_area(PP), /area/station/hydroponics) || istype(get_area(PP), /area/station/hydroponics/lobby))
						return 0
			return 1

ABSTRACT_TYPE(/datum/objective/crew/chaplain)
/datum/objective/crew/chaplain
	funeral
		explanation_text = "Have no corpses on the station level at the end of the round."
		medal_name = "Bury the Dead"
		check_completion()
			for(var/mob/living/carbon/human/H in mobs)
				if(H.z == 1 && isdead(H))
					return 0
			return 1

ABSTRACT_TYPE(/datum/objective/crew/janitor)
/datum/objective/crew/janitor
	cleanbar
		explanation_text = "Make sure the bar is spotless at the end of the round."
		medal_name = "Spotless"
		check_completion()
			for(var/turf/T in get_area_turfs(/area/station/crew_quarters/bar, 0))
				for(var/obj/decal/cleanable/D in T)
					return 0
			return 1
	cleanmedbay
		explanation_text = "Make sure medbay is spotless at the end of the round."
		medal_name = "Spotless"
		check_completion()
			for(var/turf/T in get_area_turfs(/area/station/medical/medbay, 0))
				for(var/obj/decal/cleanable/D in T)
					return 0
			return 1
	cleanbrig
		explanation_text = "Make sure the brig is spotless at the end of the round."
		medal_name = "Spotless"
		check_completion()
			for(var/turf/T in get_area_turfs(/area/station/security/brig, 0))
				for(var/obj/decal/cleanable/D in T)
					return 0
			return 1

//	barman

//	chef

//	engineer

ABSTRACT_TYPE(/datum/objective/crew/miner)
/datum/objective/crew/miner
	// just fyi dont make a "gather ore" objective, it'd be a boring-ass grind (like mining is(dohohohoho))
	isa
		explanation_text = "Create at least three suits of Industrial Space Armor."
		medal_name = "40K"
		check_completion()
			var/suitcount = 0
			for(var/obj/item/clothing/suit/space/industrial/I in world)
				suitcount++
			if(suitcount > 2) return 1
			else return 0

ABSTRACT_TYPE(/datum/objective/crew/mechanic)
/datum/objective/crew/mechanic
	scanned
		explanation_text = "Have at least ten items scanned and researched in the ruckingenur at the end of the round."
		medal_name = "Man with a Scan"
		check_completion()
			if(mechanic_controls.scanned_items.len > 9) return 1
			else return 0
	teleporter
		explanation_text = "Ensure that there are at least two functioning command teleporter consoles, complete with portal generators and portal rings, on the station level at the end of the round."
		medal_name = "It's not 'Door to Heaven'"
		check_completion()
			var/telecount = 0
			for(var/obj/machinery/teleport/portal_generator/S in machine_registry[MACHINES_PORTALGENERATORS]) //really shitty, I know
				if(S.z != 1) continue
				for(var/obj/machinery/teleport/portal_ring/H in orange(2,S))
					for(var/obj/machinery/computer/teleporter/C in orange(2,S))
						telecount++
						break
			if(telecount > 1) return 1
			else return 0
/*
	cloner
		explanation_text = "Ensure that there are at least two cloners on the station level at the end of the round."
		check_completion()
			var/clonecount = 0
			for(var/obj/machinery/computer/cloning/C in machine_registry[MACHINES_CLONINGCONSOLES]) //ugh
				for(var/obj/machinery/dna_scannernew/D in orange(2,C))
					for(var/obj/machinery/clonepod/P in orange(2,C))
						clonecount++
						break
			if(clonecount > 1) return 1
			return 0
*/

ABSTRACT_TYPE(/datum/objective/crew/researchdirector)
/datum/objective/crew/researchdirector
	heisenbee
		explanation_text = "Ensure that Heisenbee escapes on the shuttle."
		check_completion()
			for (var/obj/critter/domestic_bee/heisenbee/H in world)
				if (in_centcom(H) && H.alive)
					return 1
			return 0
	noscorch
		explanation_text = "Ensure that the floors of the chemistry lab are not scorched at the end of the round."
		medal_name = "We didn't start the fire"
		check_completion()
			for(var/turf/simulated/floor/T in get_area_turfs(/area/station/chemistry, 0))
				if(T.burnt == 1) return 0
			return 1
	hyper
		explanation_text = "Have methamphetamine in your bloodstream at the end of the round."
		medal_name = "Meth is a hell of a drug"
		check_completion()
			if(owner.current && owner.current.reagents && owner.current.reagents.has_reagent("methamphetamine"))
				return 1
			else
				return 0
	void
		explanation_text = "Create a portal to the void using the science teleporter."
		medal_name = "Where we're going, we won't need eyes to see"
		check_completion()
			for(var/obj/dfissure_to/F in world)
				if(F.z == 1) return 1
			return 0
	onfire
		explanation_text = "Escape on the shuttle alive while on fire with silver sulfadiazine in your bloodstream."
		medal_name = "Better to burn out, than fade away"
		check_completion()
			if(owner.current && !isdead(owner.current) && ishuman(owner.current))
				var/mob/living/carbon/human/H = owner.current
				if(in_centcom(H) && H.getStatusDuration("burning") > 1 && owner.current.reagents.has_reagent("silver_sulfadiazine")) return 1
				else return 0

ABSTRACT_TYPE(/datum/objective/crew/scientist)
/datum/objective/crew/scientist
	noscorch
		explanation_text = "Ensure that the floors of the chemistry lab are not scorched at the end of the round."
		medal_name = "We didn't start the fire"
		check_completion()
			for(var/turf/simulated/floor/T in get_area_turfs(/area/station/chemistry, 0))
				if(T.burnt == 1) return 0
			return 1
	hyper
		explanation_text = "Have methamphetamine in your bloodstream at the end of the round."
		medal_name = "Meth is a hell of a drug"
		check_completion()
			if(owner.current && owner.current.reagents && owner.current.reagents.has_reagent("methamphetamine"))
				return 1
			else
				return 0
	void
		explanation_text = "Create a portal to the void using the science teleporter."
		medal_name = "Where we're going, we won't need eyes to see"
		check_completion()
			for(var/obj/dfissure_to/F in world)
				if(F.z == 1) return 1
			return 0
	onfire
		explanation_text = "Escape on the shuttle alive while on fire with silver sulfadiazine in your bloodstream."
		medal_name = "Better to burn out, than fade away"
		check_completion()
			if(owner.current && !isdead(owner.current) && ishuman(owner.current))
				var/mob/living/carbon/human/H = owner.current
				if(in_centcom(H) && H.getStatusDuration("burning") > 1 && owner.current.reagents.has_reagent("silver_sulfadiazine")) return 1
				else return 0

	/*artifact // This is going to be really fucking awkward to do so disabling for now
		explanation_text = "Activate at least one artifact on the station z level by the end of the round, excluding the test artifact."
		check_completion()
			for(var/obj/machinery/artifact/A in machines)
				if(A.z == 1 && A.activated == 1 && A.name != "Test Artifact") return 1 //someone could label it I guess but I don't want to go adding an istestartifact var just for this..
			return 0*/

ABSTRACT_TYPE(/datum/objective/crew/medicaldirector)
/datum/objective/crew/medicaldirector // so much copy/pasted stuff  :(
	dr_acula
		explanation_text = "Ensure that Dr. Acula escapes on the shuttle."
		check_completion()
			for (var/obj/critter/bat/doctor/Dr in world)
				if (in_centcom(Dr) && Dr.alive)
					return 1
			return 0

	dr_acula_feeds
		explanation_text = "Ensure that Dr. Acula survives and drinks 200 units of blood by the end of the shift."
		check_completion()
			for (var/obj/critter/bat/doctor/Dr in world)
				if (Dr.blood_volume >= 200 && Dr.alive)
					return 1
			return 0

	headsurgeon
		explanation_text = "Ensure that the Head Surgeon escapes on the shuttle."
		medal_name = "What's this box doing here?"
		check_completion()
			for (var/obj/machinery/bot/medbot/head_surgeon/H in machine_registry[MACHINES_BOTS])
				if (in_centcom(H))
					return 1
			for (var/obj/item/clothing/suit/cardboard_box/head_surgeon/H in machine_registry[MACHINES_BOTS])
				if (in_centcom(H))
					return 1
			for (var/obj/machinery/bot/medbot/head_surgeon/H in machine_registry[MACHINES_BOTS])
				if (in_centcom(H))
					return 1
			return 0
	scanned
		explanation_text = "Have at least 5 people's DNA scanned in the cloning console at the end of the round."
		medal_name = "Life, uh... finds a way"
		check_completion()
			for(var/obj/machinery/computer/cloning/C in machine_registry[MACHINES_CLONINGCONSOLES])
				if(C.records.len > 4)
					return 1
			return 0
	cyborgs
		explanation_text = "Ensure that there are at least three living cyborgs at the end of the round."
		medal_name = "Progenitor"
		check_completion()
			var/borgcount = 0
			for(var/mob/living/silicon/robot in mobs) //borgs gib when they die so no need to check stat I think
				borgcount ++
			if(borgcount > 2) return 1
			else return 0
	medibots
		explanation_text = "Have at least five medibots on the station level at the end of the round."
		medal_name = "Silent Running"
		check_completion()
			var/medbots = 0
			for (var/obj/machinery/bot/medbot/M in machine_registry[MACHINES_BOTS])
				if (M.z == 1)
					medbots++
			if (medbots > 4) return 1
			else return 0
	buttbots
		explanation_text = "Have at least five buttbots on the station level at the end of the round."
		medal_name = "Puerile humour"
		check_completion()
			var/buttbots = 0
			for(var/obj/machinery/bot/buttbot/B in machine_registry[MACHINES_BOTS])
				if(B.z == 1)
					buttbots ++
			if(buttbots > 4) return 1
			else return 0
	cryo
		explanation_text = "Ensure that both cryo cells are online and below 225K at the end of the round."
		medal_name = "It's frickin' freezing in here, Mr. Bigglesworth"
		check_completion()
			var/cryocount = 0
			for(var/obj/machinery/atmospherics/unary/cryo_cell/C in atmos_machines)
				if(C.on && C.air_contents.temperature < 225)
					cryocount ++
			if(cryocount > 1) return 1
			else return 0
	healself
		explanation_text = "Make sure you are completely unhurt when the escape shuttle leaves."
		medal_name = "Smooth Operator"
		check_completion()
			if(owner.current && !isdead(owner.current) && (owner.current.get_brute_damage() + owner.current.get_oxygen_deprivation() + owner.current.get_burn_damage() + owner.current.get_toxin_damage()) == 0)
				return 1
			else
				return 0
	heal
		var/patchesused = 0
		explanation_text = "Use at least 10 medical patches on injured people."
		medal_name = "Patchwork"
		check_completion()
			if(patchesused > 9) return 1
			else return 0
	oath
		explanation_text = "Do not commit a violent act all round - punching someone, hitting them with a weapon or shooting them with a laser will all cause you to fail."
		medal_name = "Primum non nocere"
		check_completion()
			if (owner && owner.violated_hippocratic_oath)
				return 0
			else
				return 1

ABSTRACT_TYPE(/datum/objective/crew/geneticist)
/datum/objective/crew/geneticist
	scanned
		explanation_text = "Have at least 5 people's DNA scanned in the cloning console at the end of the round."
		medal_name = "Life, uh... finds a way"
		check_completion()
			for(var/obj/machinery/computer/cloning/C in machine_registry[MACHINES_CLONINGCONSOLES])
				if(C.records.len > 4)
					return 1
			return 0

ABSTRACT_TYPE(/datum/objective/crew/roboticist)
/datum/objective/crew/roboticist
	cyborgs
		explanation_text = "Ensure that there are at least three living cyborgs at the end of the round."
		medal_name = "Progenitor"
		check_completion()
			var/borgcount = 0
			for(var/mob/living/silicon/robot in mobs) //borgs gib when they die so no need to check stat I think
				borgcount ++
			if(borgcount > 2) return 1
			else return 0

	medibots
		explanation_text = "Have at least five medibots on the station level at the end of the round."
		medal_name = "Silent Running"
		check_completion()
			var/medbots = 0
			for (var/obj/machinery/bot/medbot/M in machine_registry[MACHINES_BOTS])
				if (M.z == 1)
					medbots++
			if (medbots > 4) return 1
			else return 0
	buttbots
		explanation_text = "Have at least five buttbots on the station level at the end of the round."
		medal_name = "Puerile humour"
		check_completion()
			var/buttbots = 0
			for(var/obj/machinery/bot/buttbot/B in machine_registry[MACHINES_BOTS])
				if(B.z == 1)
					buttbots ++
			if(buttbots > 4) return 1
			else return 0

ABSTRACT_TYPE(/datum/objective/crew/medicaldoctor)
/datum/objective/crew/medicaldoctor
	cryo
		explanation_text = "Ensure that both cryo cells are online and below 225K at the end of the round."
		medal_name = "It's frickin' freezing in here, Mr. Bigglesworth"
		check_completion()
			var/cryocount = 0
			for(var/obj/machinery/atmospherics/unary/cryo_cell/C in atmos_machines)
				if(C.on && C.air_contents.temperature < 225)
					cryocount ++
			if(cryocount > 1) return 1
			else return 0
	healself
		explanation_text = "Make sure you are completely unhurt when the escape shuttle leaves."
		medal_name = "Smooth Operator"
		check_completion()
			if(owner.current && !isdead(owner.current) && (owner.current.get_brute_damage() + owner.current.get_oxygen_deprivation() + owner.current.get_burn_damage() + owner.current.get_toxin_damage()) == 0)
				return 1
			else
				return 0
	heal
		var/patchesused = 0
		explanation_text = "Use at least 10 medical patches on injured people."
		medal_name = "Patchwork"
		check_completion()
			if(patchesused > 9) return 1
			else return 0
	oath
		explanation_text = "Do not commit a violent act all round - punching someone, hitting them with a weapon or shooting them with a laser will all cause you to fail."
		medal_name = "Primum non nocere"
		check_completion()
			if (owner && owner.violated_hippocratic_oath)
				return 0
			else
				return 1

ABSTRACT_TYPE(/datum/objective/crew/staffassistant)
/datum/objective/crew/staffassistant
	butt
		explanation_text = "Have your butt removed somehow by the end of the round."
		medal_name = "I don't give a shit"
		check_completion()
			if(owner.current && ishuman(owner.current))
				var/mob/living/carbon/human/H = owner.current
				if(H.butt_op_stage == 4) return 1
			return 0
	wearbutt
		explanation_text = "Make sure that you are wearing your own butt on your head when the escape shuttle leaves."
		medal_name = "Shit for brains"
		check_completion()
			if(owner.current && !isdead(owner.current) && ishuman(owner.current))
				var/mob/living/carbon/human/H = owner.current
				if(in_centcom(H) && H.head && H.head.name == "[H.real_name]'s butt") return 1
			return 0
	promotion
		explanation_text = "Escape on the shuttle alive with a non-assistant ID registered to you."
		medal_name = "Glass ceiling"
		check_completion()
			if(owner.current && !isdead(owner.current) && ishuman(owner.current))
				var/mob/living/carbon/human/H = owner.current
				if(in_centcom(H) && H.wear_id && H.wear_id:registered == H.real_name && !(H.wear_id:assignment in list("Technical Assistant","Staff Assistant","Medical Assistant"))) return 1
				else return 0
	clown
		explanation_text = "Escape on the shuttle alive wearing at least one piece of clown clothing."
		medal_name = "honk HONK mother FU-"
		check_completion()
			if(owner.current && ishuman(owner.current))
				var/mob/living/carbon/human/H = owner.current
				if(istype(H.wear_mask,/obj/item/clothing/mask/clown_hat) || istype(H.w_uniform,/obj/item/clothing/under/misc/clown) || istype(H.shoes,/obj/item/clothing/shoes/clown_shoes)) return 1
			return 0
	chompski
		explanation_text = "Ensure that Gnome Chompski escapes on the shuttle."
		medal_name = "Guardin' gnome"
		check_completion()
			for(var/obj/item/gnomechompski/G in world)
				if (in_centcom(G)) return 1
			return 0
	mailman
		explanation_text = "Escape on the shuttle alive wearing at least one piece of mailman clothing."
		medal_name = "The mail always goes through"
		check_completion()
			if(owner.current && ishuman(owner.current))
				var/mob/living/carbon/human/H = owner.current
				if(istype(H.w_uniform,/obj/item/clothing/under/misc/mail) || istype(H.head,/obj/item/clothing/head/mailcap)) return 1
			else return 0
	spacesuit
		explanation_text = "Get your grubby hands on a spacesuit."
		medal_name = "Vacuum Sealed"
		check_completion()
			if(owner.current)
				for(var/obj/item/clothing/suit/space/S in owner.current.contents)
					return 1
			return 0
	monkey
		explanation_text = "Escape on the shuttle alive as a monkey."
		medal_name = "Primordial"
		check_completion()
			if(owner.current && !isdead(owner.current) && in_centcom(owner.current) && ismonkey(owner.current)) return 1
			else return 0

	headsurgeon
		explanation_text = "Ensure that the Head Surgeon escapes on the shuttle."
		medal_name = "What's this box doing here?"
		check_completion()
			for (var/obj/machinery/bot/medbot/head_surgeon/H in machine_registry[MACHINES_BOTS])
				if (in_centcom(H))
					return 1
			for (var/obj/item/clothing/suit/cardboard_box/head_surgeon/H in machine_registry[MACHINES_BOTS])
				if (in_centcom(H))
					return 1
			return 0

//Keeping this around just in case some idiot gets a medal in an admin gimmick or something
ABSTRACT_TYPE(/datum/objective/crew/technicalassistant)
/datum/objective/crew/technicalassistant
	wearbutt
		explanation_text = "Make sure that you are wearing your own butt on your head when the escape shuttle leaves."
		medal_name = "Shit for brains"
		check_completion()
			if(owner.current && !isdead(owner.current) && ishuman(owner.current))
				var/mob/living/carbon/human/H = owner.current
				if(in_centcom(H) && H.head && H.head.name == "[H.real_name]'s butt") return 1
			return 0
	mailman
		explanation_text = "Escape on the shuttle alive wearing at least one piece of mailman clothing."
		medal_name = "The mail always goes through"
		check_completion()
			if(owner.current && ishuman(owner.current))
				var/mob/living/carbon/human/H = owner.current
				if(istype(H.w_uniform,/obj/item/clothing/under/misc/mail) || istype(H.head,/obj/item/clothing/head/mailcap)) return 1
			else return 0
	promotion
		explanation_text = "Escape on the shuttle alive with a non-assistant ID registered to you."
		medal_name = "Glass ceiling"
		check_completion()
			if(owner.current && !isdead(owner.current) && in_centcom(owner.current)) //checking basic stuff - they escaped alive and have an ID
				var/mob/living/carbon/human/H = owner.current
				if(H.wear_id && H.wear_id:registered == H.real_name && !(H.wear_id:assignment in list("Technical Assistant","Staff Assistant","Medical Assistant"))) return 1
				else return 0
	spacesuit
		explanation_text = "Get your grubby hands on a spacesuit."
		medal_name = "Vacuum Sealed"
		check_completion()
			if(owner.current)
				for(var/obj/item/clothing/suit/space/S in owner.current.contents)
					return 1
			return 0

ABSTRACT_TYPE(/datum/objective/crew/medicalassistant)
/datum/objective/crew/medicalassistant
	monkey
		explanation_text = "Escape on the shuttle alive as a monkey."
		medal_name = "Primordial"
		check_completion()
			if(owner.current && !isdead(owner.current) && in_centcom(owner.current) && ismonkey(owner.current)) return 1
			else return 0
	promotion
		explanation_text = "Escape on the shuttle alive with a non-assistant ID registered to you."
		medal_name = "Glass ceiling"
		check_completion()
			if(owner.current && !isdead(owner.current) && in_centcom(owner.current)) //checking basic stuff - they escaped alive and have an ID
				var/mob/living/carbon/human/H = owner.current
				if(H.wear_id && H.wear_id:registered == H.real_name && !(H.wear_id:assignment in list("Technical Assistant","Staff Assistant","Medical Assistant"))) return 1
				else return 0
	healself
		explanation_text = "Make sure you are completely unhurt when the escape shuttle leaves."
		medal_name = "Smooth Operator"
		check_completion()
			if(owner.current && !isdead(owner.current) && (owner.current.get_brute_damage() + owner.current.get_oxygen_deprivation() + owner.current.get_burn_damage() + owner.current.get_toxin_damage()) == 0)
				return 1
			else
				return 0
	headsurgeon
		explanation_text = "Ensure that the Head Surgeon escapes on the shuttle."
		medal_name = "What's this box doing here?"
		check_completion()
			for (var/obj/machinery/bot/medbot/head_surgeon/H in machine_registry[MACHINES_BOTS])
				if (in_centcom(H)) return 1
			for (var/obj/item/clothing/suit/cardboard_box/head_surgeon/H in machine_registry[MACHINES_BOTS])
				if (in_centcom(H)) return 1
			return 0


//	cyborg

#endif
