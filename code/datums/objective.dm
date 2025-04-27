ABSTRACT_TYPE(/datum/objective)
/datum/objective
	var/enabled = TRUE
	var/datum/mind/owner
	var/explanation_text
	var/medal_name = null // Called by ticker.mode.declare_completion().
	var/medal_announce = 1
	///Sometimes we want an objective with no mind, for conspirators etc.
	var/requires_mind = TRUE

	New(text, datum/mind/owner, datum/antagonist/antag_role)
		..()
		if(text)
			src.explanation_text = text
		if(istype(owner))
			src.owner = owner
			owner.objectives += src
			if (antag_role)
				antag_role.objectives += src
		else if (src.requires_mind)
			stack_trace("objective/New got called without a mind")
		src.set_up()

	proc/check_completion()
		return 1

	proc/set_up()
		return

	/// Checks if a mind is not considered alive for objectives.
	/// Being a silicon (cyborg or AI) does not count.
	proc/is_target_eliminated(datum/mind/M)
		if (!M?.current)
			return TRUE
		if(isdead(M.current))
			return TRUE
		if(inafterlife(M.current))
			return TRUE
		if(isVRghost(M.current))
			return TRUE
		if(isghostcritter(M.current) || isghostdrone(M.current) || issilicon(M.current))
			return TRUE
		return FALSE

///////////////////////////////////////////////////
// Regular objectives active in current gameplay //
///////////////////////////////////////////////////

/datum/objective/regular/assassinate
	var/datum/mind/target
	var/targetname

	set_up()
		var/list/possible_targets = list()

		for(var/datum/mind/possible_target in ticker.minds)
			if (possible_target && (possible_target != owner) && ishuman(possible_target.current))
				// 1) Wizard marked as another wizard's target.
				// 2) Presence of wizard is revealed to other antagonists at round start.
				// Both are bad.
				if (possible_target.special_role == ROLE_WIZARD)
					continue
				if (possible_target.current.mind && possible_target.current.mind.is_target) // Cannot read null.is_target
					continue
				if (!possible_target.current.client)
					continue
				if (isvirtual(possible_target) || istype(get_area(possible_target),/area/afterlife))
					continue
				possible_targets += possible_target

		if(length(possible_targets) > 0)
			target = pick(possible_targets)
			target.current.mind.is_target = 1

		create_objective_string(target)

		return target

	proc/find_target_by_role(role)
		for(var/datum/mind/possible_target in ticker.minds)
			if((possible_target != owner) && ishuman(possible_target.current) && (possible_target.assigned_role == role || (possible_target.assigned_role == "MODE" && possible_target.special_role == role)))
				target = possible_target
				break

		create_objective_string(target)

		return target

	check_completion()
		return src.is_target_eliminated(target)

	proc/create_objective_string(datum/mind/target)
		if(!(target?.current))
			explanation_text = "Be dastardly as heck!"
			return
		var/objective_text = "Assassinate [target.current.real_name], the [target.assigned_role == "MODE" ? target.special_role : target.assigned_role]"
		objective_text += " [create_fluff(target)]. It doesn't count if [he_or_she(target.current)] get[blank_or_s(target.current)] revived unless it's as a cyborg/AI."

		explanation_text = objective_text
		targetname = target.current.real_name

/datum/objective/regular/assassinate/bodyguard //the INVERSE of an assassin
	check_completion()
		if(target?.current)
			if(isdead(target.current) || !iscarbon(target.current) || inafterlife(target.current))
				if (in_centcom(target.current))
					return 1
				else
					return 0
			else
				return 1
		else
			return 0

	create_objective_string(datum/mind/target)
		if(!(target?.current))
			explanation_text = "Be dastardly as heck!"
			return
		var/objective_text = "Ensure that [target.current.real_name] the [target.assigned_role == "MODE" ? target.special_role : target.assigned_role] escapes on the shuttle dead or alive."

		explanation_text = objective_text
		targetname = target.current.real_name



proc/create_fluff(datum/mind/target)
	if(!istype(target)) return ""

	var/job = target.assigned_role == "MODE" ? target.special_role : target.assigned_role
	var/datum/job/J = find_job_in_controller_by_string(job)
	var/list/general_fluff = strings("assassination_fluff.txt", "general") //Get a list of objectives matching every job
	var/list/special_fluff = list()

	if(J) //Ok, we found their job - now to build a list of job-specific stuff
		special_fluff += strings("assassination_fluff.txt", ckey(J.name), 1)

		if(J.name != J.initial_name) //We got us a case of alt_names
			special_fluff += strings("assassination_fluff.txt", ckey(J.initial_name), 1)

	//Pick which flufftext we want to use
	var/flufftext
	if(general_fluff && length(special_fluff))
		flufftext = pick(prob(50) ? general_fluff : special_fluff)
	else if (general_fluff)
		flufftext = pick(general_fluff)
	else if (special_fluff.len)
		flufftext = pick(special_fluff)

	if(flufftext)
		//Add pronouns
		var/mob/M = target.current
		flufftext = replacetext(flufftext, "$HE", he_or_she(M))
		flufftext = replacetext(flufftext, "$HIMSELF", himself_or_herself(M))
		flufftext = replacetext(flufftext, "$HIM", him_or_her(M))
		flufftext = replacetext(flufftext, "$HIS", his_or_her(M))
		flufftext = replacetext(flufftext, "$JOB", job)

	return flufftext

/datum/objective/regular/steal
	var/obj/item/steal_target
	var/target_name
#ifdef MAP_OVERRIDE_MANTA
	set_up()
		var/list/items = list("Head of Security\'s beret", "prisoner\'s beret", "DetGadget hat", "horse mask", "authentication disk",
		"\'freeform\' AI module", "gene power module", "mainframe memory board", "yellow cake", "aurora MKII utility belt", "Head of Security\'s war medal", "Research Director\'s Diploma", "Medical Director\'s Medical License", "Head of Personnel\'s First Bill",
		"much coveted Gooncode")

		if(!countJob("Head of Security"))
			items.Remove("Head of Security\'s beret")
		if(!countJob("Captain"))
			items.Remove("authentication disk")
		if(!countJob("Chief Engineer"))
			items.Remove("aurora MKII utility belt")

		target_name = pick(items)
		switch(target_name)
			if("Head of Security\'s beret")
				steal_target = /obj/item/clothing/head/hos_hat
			if("prisoner\'s beret")
				steal_target = /obj/item/clothing/head/beret/prisoner
			if("DetGadget hat")
				steal_target = /obj/item/clothing/head/det_hat/gadget
			if("authentication disk")
				steal_target = /obj/item/disk/data/floppy/read_only/authentication
			if("\'freeform\' AI module")
				steal_target = /obj/item/aiModule/freeform
			if("gene power module")
				steal_target = /obj/item/cloneModule/genepowermodule
			if("mainframe memory board")
				steal_target = /obj/item/disk/data/memcard/main2
			if("yellow cake")
				steal_target = /obj/item/reagent_containers/food/snacks/yellow_cake_uranium_cake
			if("aurora MKII utility belt")
				steal_target = /obj/item/storage/belt/utility/prepared/ceshielded
			if("Head of Security\'s war medal")
				steal_target = /obj/item/clothing/suit/security_badge/hosmedal
			if("Research Director\'s Diploma")
				steal_target = /obj/item/rddiploma
			if("Medical Director\'s Medical License")
				steal_target = /obj/item/mdlicense
			if("Head of Personnel\'s First Bill")
				steal_target = /obj/item/firstbill
			if("much coveted Gooncode")
				steal_target = /obj/item/toy/gooncode
			if("horse mask")
				steal_target = /obj/item/clothing/mask/horse_mask
#else
	set_up()
		var/list/items = list("Head of Security\'s beret", "prisoner\'s beret", "DetGadget hat", "horse mask", "authentication disk",
		"\'freeform\' AI module", "gene power module", "mainframe memory board", "yellow cake", "aurora MKII utility belt", "much coveted Gooncode", "golden crayon")

		if(!countJob("Head of Security"))
			items.Remove("Head of Security\'s beret")
		if(!countJob("Captain"))
			items.Remove("authentication disk")
		if(!countJob("Chief Engineer"))
			items.Remove("aurora MKII utility belt")

		target_name = pick(items)
		switch(target_name)
			if("Head of Security\'s beret")
				steal_target = /obj/item/clothing/head/hos_hat
			if("prisoner\'s beret")
				steal_target = /obj/item/clothing/head/beret/prisoner
			if("DetGadget hat")
				steal_target = /obj/item/clothing/head/det_hat/gadget
			if("authentication disk")
				steal_target = /obj/item/disk/data/floppy/read_only/authentication
			if("\'freeform\' AI module")
				steal_target = /obj/item/aiModule/freeform
			if("gene power module")
				steal_target = /obj/item/cloneModule/genepowermodule
			if("mainframe memory board")
				steal_target = /obj/item/disk/data/memcard/main2
			if("yellow cake")
				steal_target = /obj/item/reagent_containers/food/snacks/yellow_cake_uranium_cake
			if("aurora MKII utility belt")
				steal_target = /obj/item/storage/belt/utility/prepared/ceshielded
			if("much coveted Gooncode")
				steal_target = /obj/item/toy/gooncode
			if("horse mask")
				steal_target = /obj/item/clothing/mask/horse_mask
			if("golden crayon")
				steal_target = /obj/item/pen/crayon/golden
#endif

		explanation_text = "Steal the [target_name] and have it anywhere on you at the end of the shift."
		return steal_target

	check_completion()
		if(steal_target)
			if(owner.current && owner.current.check_contents_for(steal_target, 1, 1))
				return 1
			else
				return 0

/datum/objective/regular/multigrab
	var/obj/item/multigrab_target
	var/multigrab_num

	set_up()
		var/datum/multigrab_target/target = pick(concrete_typesof(/datum/multigrab_target))
		src.multigrab_num = rand(initial(target.amt_low), initial(target.amt_high))
		src.multigrab_target = initial(target.path)
		explanation_text = "Steal [multigrab_num] [initial(target.text)] and have them all anywhere on you at the end of the shift."

		return multigrab_target

	check_completion()
		if (multigrab_target)
			if (owner.current.check_contents_for_num(multigrab_target, multigrab_num, TRUE))
				return 1
			else
				return 0
		else
			return 0

ABSTRACT_TYPE(/datum/multigrab_target)
/datum/multigrab_target
	var/path = null
	var/amt_low = 1
	var/amt_high = 1
	var/text = ""

	tasers
		text = "tasers"
		path = /obj/item/gun/energy/taser_gun
		amt_high = 2

	phasers
		text = "phasers of any size"
		path = /obj/item/gun/energy/phaser_gun
		amt_low = 2
		amt_high = 3

	eguns
		text = "energy guns"
		path = /obj/item/gun/energy/egun

	riot_shotguns
		text = "riot shotguns"
		path = /obj/item/gun/kinetic/pumpweapon/riotgun
		amt_high = 3
	cards
		text = "ID cards"
		path = /obj/item/card/id
		amt_low = 5
		amt_high = 7
	insuls
		text = "pairs of insulated gloves"
		path = /obj/item/clothing/gloves/yellow
		amt_low = 2
		amt_high = 4
	batons
		text = "stun batons"
		path = /obj/item/baton
		amt_high = 2
	sec_helmets
		text = "security helmets"
		path = /obj/item/clothing/head/helmet
		amt_low = 2
		amt_high = 3
	flashes
		text = "flashes"
		path = /obj/item/device/flash
		amt_low = 3
		amt_high = 5
	barriers
		text = "security barriers"
		path = /obj/item/barrier
		amt_low = 2
		amt_high = 3
	defibs
		text = "defibrilators"
		path = /obj/item/robodefibrillator
		amt_low = 3
		amt_high = 4
	limbs
		text = "human limbs"
		path = /obj/item/parts/human_parts
		amt_low = 4
		amt_high = 7
	butts
		text = "butts"
		path = /obj/item/clothing/head/butt
		amt_low = 3
		amt_high = 5
	hearts
		text = "hearts"
		path = /obj/item/organ/heart
		amt_low = 2
		amt_high = 4


/datum/objective/regular/gimmick
	explanation_text = "Be dastardly as heck!"

	set_up()
		var/list/gimmick_list = list("Try to frame innocent crewmembers for various crimes.",
		"Try to sabotage as much station infrastructure as possible without getting caught.",
		"Try to ruin a department's productivity with constant annoyances.",
		"Get yourself arrested, and then stage a violent jailbreak.",
		"If anyone gets arrested, try to rescue them. The Syndicate values its employees!",
		"Try to severely obstruct the flow of traffic around the station with barricades, sabotage, or construction projects.",
		"Wage a personal war against all the assistants. Try to eradicate them without attracting the attention of other departments.",
		"Play increasingly more dangerous pranks on other crew members. If confronted, insist it was just a joke.",
		"Waste Medbay's time by causing a lot of non-fatal injuries around the station.",
		"Waste Security's time by committing a lot of minor crimes.",
		"Start as many petty arguments and fistfights as possible. Be a real jerk.",
		"Try to make everyone hate a job department of your choice, through misdirection and slander.",
		"Try to make everyone hate a crew member of your choice, through misdirection and slander.",
		"Spread rumors about a crew member of your choice and ruin their reputation.",
		"Sneak into a department of your choice every once in awhile and mess with all the things inside.",
		"Try to deprive the station of medical items and objects.",
		"Try to deprive the station of tools and useful items.",
		"Try to deprive the station of their ID cards.",
		"Make the station as ugly and visually unpleasant as you can.",
		"Become a literal arms dealer. Harvest as many body parts as possible from the crew.",
		"Become a vigilante and violently harass people over the slightest suspicion.",
		"Seek out any non-security vigilantes on the station and make their life utter hell.",
		"Find another crew member's pet project and subvert it to a more violent purpose.",
		"Try to become a supervillain by using costumes, treachery, and a lot of bluster and bravado.",
		"Spy on the crew and uncover their deepest secrets.",
		"Kidnap George and hold him for ransom.",
		"Kidnap Heisenbee and hold him for ransom.",
		"Convert the bridge into your own private bar.",
		"Single out a crew member and stalk them everywhere.",
		"Be as useless and incompetent as possible without getting killed.",
		"Make as much of the station as possible accessible to the public.",
		"Try to convince your department to go on strike and refuse to do any work.",
		"Steal things from crew members and attempt to auction them off for profit.")

		explanation_text = "[pick(gimmick_list)] <i>This objective is not tracked and will automatically succeed, so just have fun with it!</i>"

		return

	check_completion()
		return 1

/datum/objective/regular/traitor_supremacy
	explanation_text = "Eliminate all other syndicate operatives, changelings and other foes on the station."
	medal_name = "Untapped Potential"

	check_completion()
		if(ticker.mode.traitors.len + length(ticker.mode.Agimmicks) <= 1)
			return 1 // Because apparently you can get this as a solo traitor aaaaaa
		for (var/datum/mind/M in ticker.mode.traitors + ticker.mode.Agimmicks)
			if(M != src.owner && src.is_target_eliminated(M))
				continue
			return 0

		return 1

/datum/objective/regular/killstirstir
	explanation_text = "Kill Monsieur Stirstir for a dead monkey can tell no secrets."

	check_completion()
		for(var/mob/living/carbon/human/npc/monkey/stirstir/M in mobs)
			if (!isdead(M))
				return 0
		return 1

/datum/objective/regular/bonsaitree
	// Brought this back as a very rare gimmick objective (Convair880).
#ifdef MAP_OVERRIDE_MANTA
	explanation_text = "Destroy the Captain's ship in a bottle."

	check_completion()
		var/area/cap_quarters = locate(/area/station/captain)
		var/obj/captain_bottleship/cap_ship

		for (var/obj/captain_bottleship/T in cap_quarters)
			cap_ship = T
		if (!cap_ship)
			return 1  // Somebody deleted it somehow, I suppose?
		else if (cap_ship?.destroyed == 1)
			return 1
		else
			return 0
#else
	explanation_text = "Destroy the Captain's prized bonsai tree."

	check_completion()
		var/area/cap_quarters = locate(/area/station/crew_quarters/captain)
		var/obj/shrub/captainshrub/our_tree

		for (var/obj/shrub/captainshrub/T in cap_quarters)
			our_tree = T
		if (!our_tree)
			return 1
		else if (our_tree?.destroyed == 1)
			return 1
		else
			return 0
#endif
///////////////////////////////////////////////////////////////
// Regular objectives not currently used in current gameplay //
///////////////////////////////////////////////////////////////

/datum/objective/regular/force_evac_time
	var/time = 45
	explanation_text = "Force the crew to evacuate the station before 45 minutes elapse."

	check_completion()
		if(round(((world.time / 10) / 60)) < time)
			return 1
		return 0

/datum/objective/regular/cash
	var/target_cash
	var/current_cash

	set_up()
		target_cash = rand(10000,80000)
		explanation_text = "Amass [target_cash] space credits."

	check_completion()
		if (!owner.current)
			return 0

		current_cash = 0

		// Tweaked to make it more reliable (Convair880).
		var/list/L = owner.current.get_all_items_on_mob()
		if (length(L))
			for (var/obj/item/card/id/C in L)
				current_cash += C.money
			for (var/obj/item/device/pda2/PDA in L)
				if (PDA.ID_card)
					current_cash += PDA.ID_card.money
			for (var/obj/item/currency/spacecash/C in L)
				current_cash += C.amount

		current_cash += data_core.bank.find_record("id", owner.current.datacore_id)?["current_money"] || 0

		if (current_cash >= target_cash)
			return 1
		else
			return 0

/datum/objective/regular/no_clones
	explanation_text = "Ensure that no cloned personnel survive. You do not need to kill yourself if cloned."

	check_completion()
		for(var/mob/living/carbon/human/H in mobs)
			if (H == owner.current)
				continue
			if (!H.bioHolder)
				continue
			if (H.bioHolder.clone_generation < 1)
				continue
			if (!isdead(H) && iscarbon(H))
				return 0

		return 1

/datum/objective/regular/kill_heads
	explanation_text = "Kill the Captain, Head of Personnel, Head of Security, Chief Engineer, Medical Director and Research Director."
	var/list/targets = list("Captain", "Head of Personnel", "Head of Security", "Chief Engineer", "Medical Director", "Research Director")

	check_completion()
		for (var/datum/mind/M in ticker.minds)
			if (!M.current)
				continue
			if (M.current == owner.current)
				continue
			if (!(M.assigned_role in targets))
				continue
			if (!isdead(M.current) && iscarbon(M.current))
				return 0

		return 1

/datum/objective/regular/job_genocide
	var/target_job = "Staff Assistant"

	set_up()
		var/list/targets = list("Staff Assistant","Medical Doctor","Engineer","Security Officer",
		"Geneticist","Scientist","Roboticist","Quartermaster","Miner","Botanist")
		target_job = pick(targets)
		explanation_text = "Kill every [target_job] on the station. You do not need to kill yourself if you are a [target_job]."

	check_completion()
		for (var/datum/mind/M in ticker.minds)
			if (!M.current)
				continue
			if (M.current == owner.current)
				continue
			if (M.assigned_role != target_job)
				continue
			if (!isdead(M.current) && iscarbon(M.current))
				return 0

		return 1

/datum/objective/regular/destroy_equipment
	var/target_equipment = null
	var/target_name

	set_up()
		var/list/choices = list("cryo cells","cloning pods","cyborg recharge stations",
		"chem dispensers","plasma canisters","nano-crucibles","plant pots","large pod vehicles")

		target_name = pick(choices)
		switch(target_name)
			if ("cryo cells")
				target_equipment = /obj/machinery/atmospherics/unary/cryo_cell
			if ("cloning pods")
				target_equipment = /obj/machinery/clonepod
			if ("cyborg recharge stations")
				target_equipment = /obj/machinery/recharge_station
			if ("chem dispensers")
				target_equipment = /obj/machinery/chem_dispenser
			if ("plasma canisters")
				target_equipment = /obj/machinery/portable_atmospherics/canister/toxins
			if ("nano-crucibles")
				target_equipment = /obj/machinery/neosmelter
			if ("plant pots")
				target_equipment = /obj/machinery/plantpot
			if ("large pod vehicles")
				target_equipment = /obj/machinery/vehicle/pod_smooth
		explanation_text = "Destroy all [target_name] on the station."

	check_completion()
		for(var/i in 1 to PROCESSING_MAX_IN_USE)
			for(var/list/machines_list in processing_machines[i])
				for(var/obj/machinery/M in machines_list)
					if (M.z != 1 || !istype(M,target_equipment) || get_area_name(M) == "Space" || get_area_name(M) == "Ocean")
						continue
					if (M.status & BROKEN)
						continue
					return 0

		return 1

/datum/objective/regular/damage_area
	var/area/target_area = null
	var/area_attempt = 0
	var/area_autopass = 0
	var/initial_value_score = 0
	var/damage_threshold = 50 // 25 was way too strict for larger rooms, causing people to fail the objective most of the time.

	set_up()
		var/list/target_areas = list(/area/station/science/chemistry,
		/area/station/science/artifact,
		/area/station/science/lab,
		/area/station/science/teleporter,
		/*/area/station/medical/medbay,*/ // On Cogmap 1, medbay is split up into three separate areas.
		/area/station/medical/research,
		/area/station/medical/robotics,
		/area/station/crew_quarters/courtroom,
		/area/station/bridge,
		/area/station/security/brig,
		/area/station/security/main,
		/area/station/crew_quarters/quarters,
		/area/station/crew_quarters/cafeteria,
		/area/station/chapel/sanctuary,
		/area/station/hydroponics,
		/area/station/quartermaster/office,
		/area/station/engine/elect,
		/area/station/engine/engineering,
		/area/station/turret_protected/ai_upload,
		/area/station/hallway/secondary/exit)

		target_area = get_area_by_type(pick(target_areas))

		while (src.area_attempt < 4 && (!target_area || !istype(target_area)))
			if (!target_area || !istype(target_area))
				target_area = get_area_by_type(pick(target_areas))
				src.area_attempt++

		if (!target_area || !istype(target_area))
			src.area_autopass = 1
			explanation_text = "Cause significant damage to...whoops, couldn't find a valid target area. Objective will succeed automatically."
		else
			initial_value_score = target_area.calculate_area_value()
			explanation_text = "Cause significant damage to [target_area]."

	check_completion()
		if (src.area_autopass == 1)
			return 1

		var/current_value_score = target_area.calculate_area_value()
		var/damage_perc = (max(1,current_value_score) / initial_value_score) * 100

		if (damage_perc <= damage_threshold)
			return 1

		return 0

ABSTRACT_TYPE(/datum/objective/madness)
/datum/objective/madness

/datum/objective/madness/hate_department
	set_up()
		src.explanation_text = "Your mind fills with a burning need to destroy [pick("Genetics", "Genetics", "Catering", "Botany", "all janitors", "Medbay", "Cargo", "the research department")]."

/datum/objective/madness/greed
	set_up()
		src.explanation_text = "You are filled with an overwhelming need for [pick("blood", "money", "sharp things", "welding fuel", "plasma")]."

/datum/objective/madness/kill
	set_up()
		var/list/valid_targets = list()
		for (var/mob/living/M in mobs)
			if (!isalive(M))
				continue
			if (istype(M, /mob/living/critter/small_animal/cat/jones))
				valid_targets |= "Jones, the captain's cat"
			else if (istype(M, /mob/living/critter/small_animal/turtle/sylvester))
				valid_targets |= "Sylvester, the HoS's turtle"
			else if (istype(M, /mob/living/critter/small_animal/opossum/morty))
				//might be a little hard to kill this one but also we're insane so it fits
				valid_targets |= "Morty, the morgue opossum"
			else if (istype(M, /mob/living/carbon/human/npc/monkey/stirstir))
				valid_targets |= "Monsieur Stirstir, security's prisoner"
			else if (istype(M, /mob/living/silicon/ai))
				var/mob/living/silicon/ai/ai = M
				if (ai.client || ai.deployed_to_eyecam || ai.deployed_shell) //they're probably logged in somewhere
					valid_targets |= "[M.real_name], the AI"
			else if (istype(M, /mob/living/carbon/human))
				if (M.job == "Captain" && M.client)
					valid_targets |= "[M.real_name], the captain"
		if (!length(valid_targets))
			valid_targets += "an innocent"
		src.explanation_text = "You see it now, the only way to prevent total calamity is to offer up the death of [pick(valid_targets)]."
/*
/datum/objective/regular/borgdeath
	explanation_text = "Deactivate or destroy all Cyborgs on the station. If you end up borged, you do not need to kill yourself or be un-borged to win."

	check_completion()
		for(var/mob/living/silicon/robot/R in mobs)
			if (owner.current == R)
				continue
			if (!isdead(R) && R.brain)
				return 0
		return 1


/datum/objective/regular/aikill
	explanation_text = "Steal the AI's neural net processor."

	check_completion()
		if(owner.current && owner.current.check_contents_for(/obj/item/organ/brain/ai))
			return 1
		else
			return 0
*/

////////////////////////////////
// Specialist role objectives //
////////////////////////////////

/datum/objective/specialist/nuclear
	explanation_text = "Destroy the station with a nuclear device."
	medal_name = "Manhattan Project"

	check_completion()
		if (ticker?.mode && istype(ticker.mode, /datum/game_mode/nuclear))
			var/datum/game_mode/nuclear/N = ticker.mode
			if (N && istype(N) && (N.finished == -1 || N.finished == -2))
				return 1
		return 0

/datum/objective/specialist/absorb
	medal_name = "Many names, many faces"
	var/absorb_count

	set_up()
		absorb_count = clamp(round((ticker.minds.len - 1) / 4), 2, 6)
		explanation_text = "Absorb the DNA of at least [absorb_count] more crew members in addition to the one you started with, and escape on the shuttle alive."

	check_completion()
		if(emergency_shuttle.location<SHUTTLE_LOC_RETURNED)
			return FALSE

		if(!owner.current || (isdead(owner.current) && !istype(src.owner.current, /mob/dead/target_observer/hivemind_observer)))
			return FALSE

		if(!in_centcom(src.owner.current))
			return FALSE

		// As the changeling's ability holder can be transferred to a member of the hivemind, access it via their antagonist datum.
		var/datum/antagonist/changeling/antag_role = src.owner.get_antagonist(ROLE_CHANGELING)
		if (antag_role?.ability_holder?.absorbtions >= absorb_count) // You start with 0 DNA these days, not 1.
			return TRUE

/datum/objective/specialist/drinkblood
	medal_name = "Dracula Jr."
	var/bloodcount

	set_up()
		bloodcount = rand(50,90) * 10
		explanation_text = "Accumulate at least [bloodcount] units of blood in total."

	check_completion()
		var/datum/antagonist/vampire/antag_datum = owner.get_antagonist(ROLE_VAMPIRE)
		return (antag_datum?.ability_holder?.get_vampire_blood(TRUE) >= bloodcount)

/datum/objective/specialist/hunter/trophy
	medal_name = "Dangerous Game"
	var/trophycount // Added a bit of randomization here (Convair880).

	set_up()
		trophycount = min(10, (ticker.minds.len - 1))
		//DEBUG_MESSAGE("Found [ticker.minds.len] minds.")
		explanation_text = "Take at least [trophycount] trophies. The skulls of worthy opponents are more valuable with regard to this objective."

	check_completion()
		var/trophyvalue = 0

		if (owner.current)
			trophyvalue = owner.current.get_skull_value()
			//DEBUG_MESSAGE("Objective: [trophycount]. Total trophy value: [trophyvalue].")

		if (trophyvalue >= trophycount)
			return 1
		else
			return 0


/datum/objective/specialist/gang
	explanation_text = "Become the biggest, baddest gang on the station!"

	check_completion()
		var/our_score = 0
		var/highest_score = 0
		for (var/datum/antagonist/gang_leader/antagonist_role as anything in get_all_antagonists(ROLE_GANG_LEADER))
			if (antagonist_role.owner == owner)
				our_score = antagonist_role.gang.gang_score()

			else if (antagonist_role.gang)
				highest_score = max(highest_score, antagonist_role.gang.gang_score())

		return (our_score >= highest_score)

/datum/objective/specialist/gang/member
	explanation_text = "Protect your boss, recruit new members, tag up the station, and beware the other gangs!."

/datum/objective/specialist/blob
	medal_name = "Blob everywhere!"
	var/blobtiletarget = 500

	set_up()
		if (ismap("DESTINY"))
			blobtiletarget = rand(35,40) * 10

		explanation_text = "Grow up to at least [blobtiletarget] tiles in size and force the evacuation of the station."

	check_completion()
		if (!owner)
			return 0
		if (!owner.current)
			return 0

		var/mob/living/intangible/blob_overmind/O = owner.current
		if (!istype(O))
			return 0

		if (length(O.blobs) >= blobtiletarget)
			return 1

/datum/objective/specialist/flock
	explanation_text = "Construct the relay and transmit The Signal."

	check_completion()
		return flock_signal_unleashed


/datum/objective/specialist/wraith
	explanation_text = "Be dastardly as heck!"

	proc/onAbsorb(mob/M)
		return
	proc/onWeakened()
		return
	proc/onBanished()
		return
	proc/Stat()
		return

	check_completion()
		return 1

/datum/objective/specialist/wraith/absorb
	var/absorbs = 0
	var/absorb_target

	onAbsorb(mob/M)
		absorbs++
	onWeakened()
		absorbs = 0
	Stat()
		stat("Currently absorbed:", "[absorbs] souls")

	set_up()
		absorb_target = clamp(round((ticker.minds.len - 5) / 2), 1, 7)
		explanation_text = "Absorb and retain the life essence of at least [absorb_target] mortal(s) that inhabit this material structure."

	check_completion()
		return absorbs >= absorb_target

/datum/objective/specialist/wraith/murder
	var/datum/mind/target
	var/targetname

	proc/setText()
		explanation_text = "We sense a large untapped astral force with the mortal [target.current.real_name], the [target.assigned_role == "MODE" ? target.special_role : target.assigned_role]. Trap them in a spiritual form and ensure that they never manifest as a corporeal being again."
		targetname = target.current.real_name

	set_up()
		var/list/possible_targets = list()

		for(var/datum/mind/possible_target in ticker.minds)
			if((possible_target != owner) && ishuman(possible_target.current))
				if(possible_target.current.mind.is_target) continue
				possible_targets += possible_target

		if(length(possible_targets) > 0)
			target = pick(possible_targets)
			target.current.mind.is_target = 1

		if(target?.current)
			setText()
		else
			explanation_text = "Be dastardly as heck!"

		return target

	proc/find_target_by_role(role)
		for(var/datum/mind/possible_target in ticker.minds)
			if((possible_target != owner) && ishuman(possible_target.current) && (possible_target.assigned_role == role || (possible_target.assigned_role == "MODE" && possible_target.special_role == role)))
				target = possible_target
				break

		if(target?.current)
			setText()
		else
			explanation_text = "Be dastardly as heck!"

		return target

	check_completion()
		if(target?.current)
			if(isdead(target.current) || !iscarbon(target.current))
				if (isobserver(target.current))
					if (!(target.current:corpse))
						return 1
			return 0
		else
			return 1

/datum/objective/specialist/wraith/murder/absorb
	var/success = 0
	setText()
		explanation_text = "[target.current.real_name], the [target.assigned_role == "MODE" ? target.special_role : target.assigned_role] is a vessel for astral energies we haven't detected before. Absorb and retain their essence at all costs!"
		targetname = target.current.real_name

	onAbsorb(mob/M)
		if (M == target.current)
			success = 1
		else if (isobserver(target.current))
			if (M == target.current:corpse)
				success = 1

	onWeakened()
		if (success)
			success = 0
			boutput(owner.current, SPAN_ALERT("You lose the astral essence of your target!"))

	check_completion()
		return success

/datum/objective/specialist/wraith/prevent
	var/max_escapees

	set_up()
		max_escapees = clamp(round(ticker.minds.len / 10), 1, 5)
		explanation_text = "Force the mortals to remain stranded on this structure. No more than [max_escapees] may escape!"

	check_completion()
		var/escapees = 0
		for (var/mob/living/carbon/player in mobs)
			if (in_centcom(player))
				escapees++

		return escapees <= max_escapees

/datum/objective/specialist/wraith/travel
	explanation_text = "Locate the hive of the mortal infestation by concealing yourself aboard the escape vehicle."
	var/failed = 0

	onBanished()
		failed = 1

	check_completion()
		if (failed)
			return 0
		if (in_centcom(owner.current))
			return 1
		return 0

/datum/objective/specialist/wraith/survive
	explanation_text = "Maintain your material presence by avoiding permanent banishment."
	var/failed = 0

	onBanished()
		failed = 1

	check_completion()
		if (failed)
			return 0
		return 1

/datum/objective/specialist/wraith/flawless
	explanation_text = "Complete your objectives without your material presence being weakened by temporary banishment."
	var/failed = 0

	onWeakened()
		failed = 1

	check_completion()
		return !failed

/datum/objective/specialist/werewolf/feed
	medal_name = "Good feasting"
	var/feed_count = 0
	var/target_feed_count
	var/list/mob/mobs_fed_on = list() // Stores bioHolder.Uid of previous victims, so we can't feed on the same person multiple times.

	set_up()
		target_feed_count = min(10, (ticker.minds.len - 1))
		explanation_text = "Feed on at least [target_feed_count] crew members."

	check_completion()
		if (feed_count >= target_feed_count)
			return 1

/datum/objective/specialist/salvager
	proc/check_on_magpie(targetType, frameType=null)
		. = 0
		for (var/turf/T in get_area_turfs(/area/salvager))
			for (var/obj/O in T.contents)
				if(istype(O, targetType))
					if(frameType && targetType == /obj/item/electronics/frame )
						var/obj/item/electronics/frame/F = O
						if (istype(F.deconstructed_thing, frameType))
							. += 1
					else
						. += 1
				else if(frameType && istype(O, frameType))
					. += 1

/datum/objective/specialist/salvager/machinery
	var/target_equipment = null
	var/target_name
	var/target_count = 1

	set_up()
		var/list/choices = list("cyborg recharge stations",
								"chem dispenser",
								"nano fabricator",
								"hydroponics tray",
								"gibber",
								"rechargers",
								"operating table",
								"toilets")

		target_name = pick(choices)
		switch(target_name)
			if ("cyborg recharge stations")
				target_equipment = /obj/machinery/recharge_station
				target_count = rand(2,3)
			if ("chem dispenser")
				target_equipment = /obj/machinery/chem_dispenser
			if ("nano fabricator")
				target_equipment = /obj/machinery/nanofab
			if ("hydroponics tray")
				target_equipment = /obj/machinery/plantpot
				target_count = rand(2,4)
			if ("gibber")
				target_equipment = /obj/machinery/gibber
			if ("rechargers")
				target_equipment = /obj/machinery/recharger
				target_count = rand(1,3)
			if ("operating table")
				target_equipment = /obj/machinery/optable
			if ("toilets")
				target_equipment = /obj/item/storage/toilet
				target_count = rand(1,2)

		if(target_count > 1)
			explanation_text = "Disassemble [target_count] [target_name] and have them anywhere on you or the Magpie at the end of the shift."
		else
			explanation_text = "Disassemble the [target_name] and have it anywhere on you or the Magpie at the end of the shift."
		return target_equipment

	check_completion()
		var/count = 0
		if(owner.current)
			var/list/L = owner.current.get_all_items_on_mob()
			if (length(L))
				for (var/obj/item/electronics/frame/F in L)
					if (istype(F.deconstructed_thing, src.target_equipment))
						count++
			count += check_on_magpie(/obj/item/electronics/frame, src.target_equipment)
			return count >= target_count
		else
			return FALSE

/datum/objective/specialist/salvager/steal
	var/target_equipment = null
	var/target_name
	var/target_count = 1

	set_up()
		var/list/choices = list(/obj/item/disk/data/floppy/read_only/authentication,
								/obj/item/disk/data/floppy/read_only/communications,
								/obj/item/reagent_containers/mender,
								/obj/item/reagent_containers/hypospray,
								/obj/item/rcd )
		target_equipment = pick(choices)
		var/atom/A = target_equipment
		target_name = initial(A.name)

		if(target_count > 1)
			explanation_text = "Steal [target_count] [target_name] and have it anywhere on you or the Magpie at the end of the shift."
		else
			explanation_text = "Steal the [target_name] and have it anywhere on you or the Magpie you at the end of the shift."
		return target_equipment

	check_completion()
		if(owner.current && owner.current.check_contents_for_num(src.target_equipment, 1, TRUE))
			return TRUE
		else if(check_on_magpie(src.target_equipment))
			return TRUE
		else
			return FALSE

/datum/objective/specialist/ruin_xmas
	explanation_text = "Ruin Spacemas for everyone! Make sure Spacemas cheer is at or below 20% when the round ends."

	check_completion()
		if (christmas_cheer <= 20)
			return 1
		else
			return 0

/datum/objective/specialist/phoenix_collect_humans
	explanation_text = "Collect 5 dead humans in your nest."

	check_completion()
		var/mob/living/critter/space_phoenix/phoenix = src.owner.current
		return length(phoenix?.collected_humans) >= 5

/datum/objective/specialist/phoenix_collect_critters
	explanation_text = "Collect 5 dead critters in your nest."

	check_completion()
		var/mob/living/critter/space_phoenix/phoenix = src.owner.current
		return length(phoenix?.collected_critters) >= 5

/datum/objective/specialist/phoenix_permafrost_areas
	explanation_text= "Use Permafrost on 5 station areas."

	check_completion()
		var/mob/living/critter/space_phoenix/phoenix = src.owner.current
		return length(phoenix?.permafrosted_areas) >= 5

/////////////////////////////
// Round-ending objectives //
/////////////////////////////

/datum/objective/escape
	explanation_text = "Escape on the shuttle alive."

	check_completion()
		if(emergency_shuttle.location<SHUTTLE_LOC_RETURNED)
			return FALSE

		if(src.is_target_eliminated(owner))
			return FALSE

		return in_centcom(src.owner.current)

/datum/objective/escape/survive
	explanation_text = "Stay alive until the end of the shift. It doesn't matter whether you're on station or not."

	check_completion()
		return !src.is_target_eliminated(owner)

/datum/objective/escape/kamikaze
	explanation_text = "Die a glorious death."

	check_completion()
		return src.is_target_eliminated(owner)

/datum/objective/escape/stirstir
	explanation_text = "Rescue Monsieur Stirstir from the brig and ensure his safety all the way to Centcom."
	medal_name = "The Syndicate Connection"

	check_completion()
		for(var/mob/living/carbon/human/npc/monkey/stirstir/M in mobs)
			if(!isdead(M) && in_centcom(M))
				return 1
		return 0

/datum/objective/escape/rescue
	var/datum/mind/target
	var/targetname

	set_up()
		var/list/possible_targets = list()

		for(var/datum/mind/possible_target in ticker.minds)
			if (possible_target && (possible_target != owner) && ishuman(possible_target.current))
				if (possible_target.special_role == ROLE_WIZARD)
					continue
				if (!possible_target.current.client)
					continue
				if (isvirtual(possible_target) || istype(get_area(possible_target),/area/afterlife))
					continue
				possible_targets += possible_target

		if(length(possible_targets) > 0)
			target = pick(possible_targets)

		if(!(target?.current))
			explanation_text = "Be dastardly as heck!"
			return

		explanation_text = "Ensure that [target.current.real_name], the [target.assigned_role], safely arrives at Centcom alive and not as a cyborg/AI."
		targetname = target.current.real_name

	check_completion()
		if(src.is_target_eliminated(target))
			return FALSE
		return in_centcom(target.current)

/datum/objective/escape/hijack_group
	explanation_text = "Hijack the emergency shuttle by escaping alone or with your accomplices. Anyone else who snuck on needs to die before you reach Centcom."
	var/list/datum/mind/accomplices = list()

	check_completion()
		if(emergency_shuttle.location < SHUTTLE_LOC_RETURNED)
			return FALSE

		if(!owner.current || isdead(owner.current))
			return FALSE

		if(isghostcritter(owner.current) || isghostdrone(owner.current))
			return FALSE

		for(var/mob/living/player in mobs)
			if (player.mind && (player.mind != owner) && !(player.mind in accomplices))
				if (!src.is_target_eliminated(player.mind) && in_centcom(player))
					return FALSE

		return TRUE

/datum/objective/escape/hijack_group/vampire
	explanation_text = "Hijack the emergency shuttle by ensuring all other living creatures on board are your thralls by the time it reaches Centcom."

	check_completion()
		var/datum/abilityHolder/vampire/vampholder = owner.current?.get_ability_holder(/datum/abilityHolder/vampire)
		for (var/mob/M in vampholder?.thralls)
			src.accomplices |= M.mind
		. = ..()

/datum/objective/escape/hijack_group/changeling
	explanation_text = "Hijack the emergency shuttle by ensuring only you and your... body parts remain alive by the time it reaches Centcom."
	check_completion()
		var/datum/abilityHolder/changeling/lingholder = owner.current?.get_ability_holder(/datum/abilityHolder/changeling)
		for (var/mob/M in lingholder?.hivemind)
			src.accomplices |= M.mind
		. = ..()

/////////////////////////////////////////////////////////
// Conspirator objectives                              //
/////////////////////////////////////////////////////////

/datum/objective/conspiracy
	requires_mind = FALSE
	explanation_text = "Lay claim to a vital area of the station, fortify it, then announce your independence. Annex as much of the station as possible."

/datum/objective/conspiracy/commune
	explanation_text = "Abolish any sort of hierarchy and start a commune."

/datum/objective/conspiracy/vandalize
	explanation_text = "Vandalize as much of the station as possible without killing anyone."

// /datum/objective/conspiracy/frame
// 	explanation_text = "Murder the diner patrons and frame a non-conspirator for it."

/datum/objective/conspiracy/quiz
	explanation_text = "Host an insane life-or-death quiz show and kidnap non-conspirators to serve as contestants."

/datum/objective/conspiracy/ransom
	explanation_text = "Kidnap a non-conspirator and hold them hostage for a ransom."

/datum/objective/conspiracy/lazy
	explanation_text = "Convice or coerce the crew to abandon their duties and be lazy."

/datum/objective/conspiracy/nt
	explanation_text = "Convince the crew to forsake Nanotrasen and join the Syndicate."

/datum/objective/conspiracy/technology
	explanation_text = "Rid the station of any sort of advanced technology and promote an austere and simple lifestyle."

// /datum/objective/conspiracy/curfew
// 	explanation_text = "Establish a curfew for the station. Those wandering outside of crew quarters after curfew must be harassed and detained."

// /datum/objective/conspiracy/party
// 	explanation_text = "Throw a surprise party for the rest of the crew."

// /datum/objective/conspiracy/birthday
// 	explanation_text = "Throw a birthday party for Shitty Bill."

// /datum/objective/conspiracy/teaparty
// 	explanation_text = "Host a murder mystery tea party."

/datum/objective/conspiracy/embezzle
	explanation_text = "Embezzle as much money as possible from the station accounts."

/datum/objective/conspiracy/swap
	set_up()
		//leaving out some of the more impossible ones like medical and security
		var/list/departments = list("Genetics", "Robotics", "Cargo", "Mining", "Engineering", "Research", "Catering", "Botany")

		var/department1 = pick(departments)
		var/department2 = pick(departments)
		while (department1 == department2)
			department2 = pick(departments)
		explanation_text = "Swap the locations of [department1] and [department2], complete with their staff and equipment."

// /datum/objective/conspiracy/jones
// 	explanation_text = "Murder Jones and frame George for it."

/datum/objective/conspiracy/remodel
	explanation_text = "Completely remodel the entire station."

/datum/objective/conspiracy/ring
	explanation_text = "Establish a super cool and exclusive drug ring."

/datum/objective/conspiracy/wrestling
	explanation_text = "Establish the station's first ever wresting championship. Coerce the crew into participating."

/datum/objective/conspiracy/liberate
	explanation_text = "Liberate all monkeys on the station and ensure that they can live peaceful lives."

/datum/objective/conspiracy/dresscode
	explanation_text = "Write up a new dress code for the station and enforce it on all crew."

// /datum/objective/conspiracy/dnd
// 	explanation_text = "Start a D&D campaign and force crewmembers to participate."

// /datum/objective/conspiracy/play
// 	explanation_text = "Organize a play or musical and persuade crewmembers to participate by offering notions of fame and grandeur."

/datum/objective/conspiracy/flat
	explanation_text = "Convince the crew that the station and in fact all of space is flat."

// /datum/objective/conspiracy/heisenbee
// 	explanation_text = "Explain to the crew how, yes, Heisenbee really was framed by the Chompski brothers."

/datum/objective/conspiracy/centcom
	explanation_text = "Convince the crew that Central Command has forsaken them."

/datum/objective/conspiracy/spacelaw
	explanation_text = "Establish and enforce a set of station protocols and policies."

/datum/objective/conspiracy/discountdan
	set_up()
		explanation_text = "Transfer ownership of the station to [pick("Discount Dan", "the Space Wizards Federation", "Bombini")]. Ensure all the crew are loyal and the station is branded correctly."

/datum/objective/conspiracy/cult
	set_up()
		//not including many of the "pets" that are often murdered immediately (Mr. Rathen, Remy etc.)
		var/list/deities = list("Heisenbee", "Morty", "Dr. Acula", "Monsieur Stirstir", "Jones the cat", "Sylvester", "Hooty McJudgementowl", "the AI", "Discount Dan")
		if (map_settings.name != "OSHAN") //pretty sure OSHAN is the only map with no engine
			deities += "the engine"
		explanation_text = "Start a cult worshipping [pick(deities)]."

/datum/objective/conspiracy/underwater
#ifdef UNDERWATER_MAP
	explanation_text = "Convince the crew that the station is in space."
#else
	explanation_text = "Convince the crew that the station is underwater."
#endif

/datum/objective/conspiracy/imposters //sus
	explanation_text = "Replace as many members of command with imposters as possible."

/datum/objective/conspiracy/crime
	explanation_text = "Set yourselves up as vigilantes and arrest people for made up crimes."

/datum/objective/conspiracy/inspectors
	explanation_text = "Pose as a team of undercover Nanotrasen inspectors and make an example out of anyone you deem incompetent or too competent at their job."

/datum/objective/conspiracy/material
	set_up()
		var/list/materials = list()
		if (rand(0,1)) //50/50 whether it's an ore material or something else
			for (var/mtype in childrentypesof(/datum/commodity/ore))
				var/datum/commodity/ore/material = new mtype
				if (material.comname == "Gold Nugget")
					materials += "Gold"
					continue
				materials += material.comname
		else
			materials += list("Glass", "Water", "Rubber", "Rock", "Flesh")
#ifdef UNDERWATER_MAP
		//but if we're underwater there's always a decent chance it's coral
		materials += list("Coral", "Coral", "Coral")
#endif
		var/material1 = pick(materials)
		var/material2 = pick(materials)
		while (material1 == material2)
			material2 = pick(materials)
		explanation_text = "Turn as much of the station as you can into [material1] and [material2], including anyone who gets in your way."

/datum/objective/conspiracy/organs
	explanation_text = "Remind the crew of their own mortality by stockpiling as many of their organs as you can."

/datum/objective/conspiracy/replace
	explanation_text = "Replace the employees of an entire department with conspirators."

/datum/objective/conspiracy/spike_food
	explanation_text = "Make sure all available food and water is chemically spiked."

/datum/objective/conspiracy/petty
	explanation_text = "Turn command against each other for petty reasons."

/datum/objective/conspiracy/framemurder
	var/datum/mind/target
	var/targetname

	set_up()
		var/list/possible_targets = list()
		for(var/datum/mind/possible_target in ticker.minds)
			if (possible_target && (possible_target != owner) && ishuman(possible_target.current))
				if (possible_target.special_role == ROLE_CONSPIRATOR)
					continue
				if (possible_target.current.mind && possible_target.current.mind.is_target) // Cannot read null.is_target
					continue
				if (!possible_target.current.client)
					continue
				if (isvirtual(possible_target) || istype(get_area(possible_target),/area/afterlife))
					continue
				possible_targets += possible_target

		if(length(possible_targets) > 0)
			target = pick(possible_targets)
			target.current.mind.is_target = 1

		create_objective_string(target)

		return target

	proc/find_target_by_role(role)
		for(var/datum/mind/possible_target in ticker.minds)
			if((possible_target != owner) && ishuman(possible_target.current) && (possible_target.assigned_role == role || (possible_target.assigned_role == "MODE" && possible_target.special_role == role)))
				target = possible_target
				break

		create_objective_string(target)
		return target

	proc/create_objective_string(datum/mind/target)
		if(!(target?.current))
			explanation_text = "Be dastardly as heck!"
			return
		var/objective_text = "Frame [target.current.real_name], the [target.assigned_role == "MODE" ? target.special_role : target.assigned_role] for murder."
		explanation_text = objective_text
		targetname = target.current.real_name


/*/datum/objective/conspiracy/escape
	explanation_text = "Survive and ensure more living conspirators escape to Centcom than non-conspirators."

	check_completion()
		if(!owner.current || isdead(owner.current)) // are we dead? that's not how you win
			return 0

		var/tally = 0
		var/area/shuttle = locate(map_settings.escape_centcom)
		for(var/mob/living/player in mobs)
			if (isblob(player))
				for (var/obj/blob/B in shuttle.contents)
					return 0 // blobs shouldn't spawn in conspiracy rounds so i'm not concerned with how little sense this will make
			else if (player.mind && !isdead(player) && player.on_centcom()) //has a mind, is not dead, is on centcom
				if (player.mind.special_role == "conspirator")
					tally++
				else
					tally--

		if (tally > 0 && emergency_shuttle.location >= 2) // more conspirators than crew, and shuttle is on z2 (ie: not a non-standard round end)
			return 1
		return 0
*/

/////////////////////////////////////////////////////////
// Spy (theft) objectives                              //
/////////////////////////////////////////////////////////

/datum/objective/spy_theft/assasinate
	explanation_text = "Eliminate all other antagonists."

	check_completion()
		for (var/datum/mind/M in ticker.mode.traitors)
			if (owner == M)
				continue
			if (!src.is_target_eliminated(M))
				return FALSE
		return TRUE

/////////////////////////////////////////////////////////
// Battle Royale objective                             //
/////////////////////////////////////////////////////////

/datum/objective/battle_royale/win
	explanation_text = "Eliminate all other battlers!"

	check_completion()
		for (var/datum/mind/M in ticker.mode.traitors)
			if (owner == M)
				continue
			if(!src.is_target_eliminated(M))
				return FALSE
		return TRUE

/////////////////////////////////////////////////////////
// Arcfiend Objectives                                 //
/////////////////////////////////////////////////////////

/datum/objective/specialist/powerdrain // this is basically just a repurposed vamp objective, but it should work.
	var/powergoal

	set_up()
		powergoal = rand(350,400) * 10
		explanation_text = "Accumulate at least [powergoal] units of charge in total."

	check_completion()
		var/datum/antagonist/arcfiend/antag_datum = owner.get_antagonist(ROLE_ARCFIEND)
		return (antag_datum?.ability_holder?.lifetime_energy >= powergoal)

/////////////////////////////////////////////////////////
// Neatly packaged objective sets for your convenience //
/////////////////////////////////////////////////////////

/datum/objective_set
	var/list/objective_list = list(/datum/objective/regular/gimmick)
	var/list/escape_choices = list(/datum/objective/escape,
	/datum/objective/escape/survive,
	/datum/objective/escape/kamikaze)

	New(datum/mind/enemy, datum/antagonist/antag_role)
		..()
		if(!istype(enemy))
			return 1

		for(var/X in objective_list)
			if (!ispath(X))
				continue
			var/datum/objective/objective = X
			if(!initial(objective.enabled))
				src.objective_list -= X
				continue
			objective = new X(null, enemy)
			if (antag_role)
				antag_role.objectives.Add(objective)

		for(var/X in escape_choices)
			var/datum/objective/objective = X
			if(!initial(objective.enabled))
				src.escape_choices -= X

		if (length(escape_choices) > 0)
			var/escape_path = pick(escape_choices)
			if (ispath(escape_path))
				var/datum/objective/objective = new escape_path(null, enemy)
				if (antag_role)
					antag_role.objectives.Add(objective)

		SPAWN(0)
			qdel(src)
		return 0

	// Misc antags

/datum/objective_set/changeling
	objective_list = list(/datum/objective/specialist/absorb)
	escape_choices = list(
		/datum/objective/escape,
#ifndef RP_MODE
		/datum/objective/escape/hijack_group/changeling
#endif
	)

/datum/objective_set/vampire
	objective_list = list(/datum/objective/specialist/drinkblood)
	escape_choices = list(
		/datum/objective/escape,
#ifndef RP_MODE
		/datum/objective/escape/hijack_group/vampire
#endif
	)

/datum/objective_set/grinch
	objective_list = list(/datum/objective/specialist/ruin_xmas)
	escape_choices = list(/datum/objective/escape,
	/datum/objective/escape/survive,
	/datum/objective/escape/kamikaze)

/datum/objective_set/hunter
	objective_list = list(/datum/objective/specialist/hunter/trophy)
	escape_choices = list(/datum/objective/escape/survive)

/datum/objective_set/werewolf
	objective_list = list(/datum/objective/specialist/werewolf/feed)
	escape_choices = list(/datum/objective/escape/survive)

/datum/objective_set/blob
	objective_list = list(/datum/objective/specialist/blob)
	escape_choices = list(/datum/objective/escape/survive)

/datum/objective_set/arcfiend
	objective_list = list(/datum/objective/specialist/powerdrain)
	escape_choices = list(/datum/objective/escape)

/datum/objective_set/salvager
	objective_list = list(/datum/objective/specialist/salvager/machinery, /datum/objective/specialist/salvager/steal)
	escape_choices = list(/datum/objective/escape/survive)

// Wraith not listed since it has its own dedicated proc

// Traitors

/datum/objective_set/traitor/triple_assassinate
	objective_list = list(/datum/objective/regular/assassinate,
	/datum/objective/regular/assassinate,
	/datum/objective/regular/assassinate)
	escape_choices = list(/datum/objective/escape,
	/datum/objective/escape/survive)

/datum/objective_set/traitor/assassinate_even_stirstir
	objective_list = list(/datum/objective/regular/killstirstir,
	/datum/objective/regular/assassinate)
	escape_choices = list(/datum/objective/escape,
	/datum/objective/escape/survive)

/datum/objective_set/traitor/supremacy
	objective_list = list(/datum/objective/regular/traitor_supremacy)
	escape_choices = list(/datum/objective/escape, /datum/objective/escape/kamikaze)

/datum/objective_set/traitor/rp_friendly/steal_a_bunch
	objective_list = list(/datum/objective/regular/steal,
	/datum/objective/regular/multigrab)
	escape_choices = list(/datum/objective/escape,
	/datum/objective/escape/survive)

/datum/objective_set/traitor/rp_friendly/gimmick
	objective_list = list(/datum/objective/regular/gimmick)
	escape_choices = list(/datum/objective/escape,
	/datum/objective/escape/survive)

/datum/objective_set/traitor/rp_friendly/gimmick_and_steal
	objective_list = list(/datum/objective/regular/gimmick,
	/datum/objective/regular/steal)
	escape_choices = list(/datum/objective/escape,
	/datum/objective/escape/survive)

/datum/objective_set/traitor/rp_friendly/gimmick_and_assassinate
	objective_list = list(/datum/objective/regular/gimmick,
	/datum/objective/regular/assassinate)
	escape_choices = list(/datum/objective/escape,
	/datum/objective/escape/survive)

/datum/objective_set/traitor/rp_friendly/gimmick_and_assassinate_stirstir
	objective_list = list(/datum/objective/regular/gimmick,
	/datum/objective/regular/killstirstir)
	escape_choices = list(/datum/objective/escape,
	/datum/objective/escape/survive)

/datum/objective_set/traitor/rp_friendly/gimmick_and_rescue
	objective_list = list(/datum/objective/regular/gimmick)
	escape_choices = list(/datum/objective/escape/rescue)

/datum/objective_set/traitor/rp_friendly/gimmick_and_rescue_stirstir
	objective_list = list(/datum/objective/regular/gimmick)
	escape_choices = list(/datum/objective/escape/stirstir)

/datum/objective_set/traitor/rp_friendly/bonsai_tree
	objective_list = list(/datum/objective/regular/bonsaitree,
	/datum/objective/regular/gimmick)
	escape_choices = list(/datum/objective/escape,
	/datum/objective/escape/survive)

/datum/objective_set/spy_theft/bodyguard_gimmick
	objective_list = list(/datum/objective/regular/assassinate/bodyguard,/datum/objective/regular/assassinate/bodyguard,/datum/objective/regular/gimmick)
	escape_choices = list(/datum/objective/escape/survive)

/datum/objective_set/spy_theft/bodyguard_steal
	objective_list = list(/datum/objective/regular/assassinate/bodyguard,/datum/objective/regular/steal)
	escape_choices = list(/datum/objective/escape)

/datum/objective_set/spy_theft/bodyguard_and_kill
	objective_list = list(/datum/objective/regular/assassinate/bodyguard,/datum/objective/regular/assassinate)
	escape_choices = list(/datum/objective/escape)

/datum/objective_set/spy_theft/assassin
	objective_list = list(/datum/objective/regular/assassinate,/datum/objective/regular/assassinate,/datum/objective/regular/assassinate)
	escape_choices = list(/datum/objective/escape)

/datum/objective_set/spy_theft/stealy
	objective_list = list(/datum/objective/regular/gimmick,/datum/objective/regular/steal)
	escape_choices = list(/datum/objective/escape)
