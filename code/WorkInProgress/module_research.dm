/datum/module_tech
	var/name = "Item name"
	var/desc = "Item description"
	var/cost = 250
	var/size = 1
	var/list/research_requirements = list()
	var/list/additional_requirements = list()
	var/item_path = /obj/item
	var/hidden = 0

	crowbar
		name = "Crowbar"
		desc = "A sturdy crowbar."
		cost = 25
		size = 1
		research_requirements = list("tools" = 15, "metals" = 5)
		additional_requirements = list("subtype" = list(/obj/item/crowbar = "Crowbar"))
		item_path = /obj/item/crowbar

	weldingtool
		name = "Weldingtool"
		desc = "A welding tool."
		cost = 25
		size = 2
		research_requirements = list("tools" = 15, "metals" = 5, "fuels" = 15)
		additional_requirements = list("subtype" = list(/obj/item/weldingtool = "Weldingtool"))
		item_path = /obj/item/weldingtool

	screwdriver
		name = "Screwdriver"
		desc = "A screwdriver."
		cost = 25
		size = 0.75
		research_requirements = list("tools" = 15, "metals" = 5)
		additional_requirements = list("subtype" = list(/obj/item/screwdriver = "Screwdriver"))
		item_path = /obj/item/screwdriver

	wrench
		name = "Wrench"
		desc = "A wrench."
		cost = 25
		size = 1.5
		research_requirements = list("tools" = 15, "metals" = 5)
		additional_requirements = list("subtype" = list(/obj/item/wrench = "Wrench"))
		item_path = /obj/item/wrench

	wirecutters
		name = "Wirecutters"
		desc = "Wirecutters!"
		cost = 25
		size = 1
		research_requirements = list("tools" = 15, "metals" = 5)
		additional_requirements = list("subtype" = list(/obj/item/wirecutters = "Wirecutters"))
		item_path = /obj/item/wirecutters

	multitool
		name = "Multitool"
		desc = "A tiny device. It does everything."
		cost = 50
		size = 1
		research_requirements = list("tools" = 15, "devices" = 5)
		additional_requirements = list("subtype" = list(/obj/item/device/multitool = "Multitool"))
		item_path = /obj/item/device/multitool

	flash
		name = "Flash"
		desc = "A tiny attacker control device. This one is hardwired into the cyborg, thus cannot burn out. It has a recharge time, though."
		cost = 125
		size = 1
		research_requirements = list("energy" = 2, "devices" = 10)
		item_path = /obj/item/device/flash/cyborg

	baton
		name = "Stun Baton"
		desc = "An efficient stun weapon. This one draws power from the internal cell of the cyborg."
		cost = 250
		size = 1
		research_requirements = list("energy" = 30, "devices" = 5, "weapons" = 20)
		item_path = /obj/item/baton/secbot

	taser
		name = "Taser Gun"
		desc = "A taser gun. It contains a slow, self-recharging battery."
		cost = 400
		size = 2
		research_requirements = list("energy" = 70, "weapons" = 35)
		item_path = /obj/item/gun/energy/taser_gun/borg

	syringe
		name = "Syringe"
		desc = "A medical tool capable of transferring reagents into humans."
		cost = 20
		size = 0.75
		research_requirements = list("tools" = 10, "medicine" = 8)
		item_path = /obj/item/reagent_containers/syringe

	electrum
		name = "Electrum Sheet"
		desc = "A matter created through energy conversion. It is relatively weak, but at least it seals breaches."
		cost = 200
		size = 3
		research_requirements = list("metals" = 25)
		item_path = /obj/item/sheet/electrum

	hypospray
		name = "Hypospray"
		desc = "A medical tool capable of transferring reagents into humans."
		cost = 100
		size = 1.5
		research_requirements = list("tools" = 20, "medicine" = 15, "devices" = 5, "science" = 3)
		item_path = /obj/item/reagent_containers/hypospray

	hypospray_e
		name = "Hypospray (malfunctioning)"
		desc = "A medical tool capable of transferring reagents into humans. It has no failsafes for dangerous reagents."
		cost = 250
		size = 1.5
		research_requirements = list("tools" = 20, "medicine" = 15, "devices" = 5, "science" = 3, "malfunction" = 20)
		item_path = /obj/item/reagent_containers/hypospray/emagged
		hidden = 1

	scalpel
		name = "Scalpel"
		desc = "A common medical tool."
		cost = 50
		size = 1
		research_requirements = list("tools" = 10, "medicine" = 5)
		item_path = /obj/item/scalpel

	circular_saw
		name = "Circular Saw"
		desc = "A common medical tool."
		cost = 50
		size = 1
		research_requirements = list("tools" = 10, "medicine" = 5)
		item_path = /obj/item/circular_saw

	beaker
		name = "Beaker"
		desc = "A standard 50 unit reagent container."
		cost = 70
		size = 1.5
		research_requirements = list("tools" = 7, "medicine" = 5, "science" = 5)
		item_path = /obj/item/reagent_containers/glass/beaker

	beaker_large
		name = "Large Beaker"
		desc = "A standard 100 unit reagent container."
		cost = 100
		size = 2
		research_requirements = list("tools" = 11, "medicine" = 8, "science" = 8)
		item_path = /obj/item/reagent_containers/glass/beaker/large

	pickaxe
		name = "Pickaxe"
		desc = "A weak mining tool."
		cost = 25
		size = 1.25
		research_requirements = list("tools" = 15, "engineering" = 2, "mining" = 1)
		item_path = /obj/item/mining_tool

	power_pick
		name = "Power Pick"
		desc = "A sturdy pickaxe. This one runs off the internal battery."
		cost = 50
		size = 1.25
		research_requirements = list("tools" = 25, "engineering" = 4, "mining" = 5)
		item_path = /obj/item/mining_tool/power_pick/borg

	drill
		name = "Laser Drill"
		desc = "A low consumption mining tool."
		cost = 85
		size = 1.5
		research_requirements = list("tools" = 40, "engineering" = 6, "mining" = 10)
		item_path = /obj/item/mining_tool/drill

	power_hammer
		name = "Power Hammer"
		desc = "A very sturdy powered hammer. It can pummel any rock into submission. Runs off the internal battery."
		cost = 200
		size = 2
		research_requirements = list("tools" = 40, "engineering" = 8, "mining" = 15)
		item_path = /obj/item/mining_tool/powerhammer/borg

	vuvuzela
		name = "Vuvuzela"
		desc = "A primitive sound syntesizer. This one comes with a pump attached, as cyborgs cannot blow."
		cost = 5
		size = 1
		research_requirements = list("audio" = 1)
		item_path = /obj/item/instrument/vuvuzela
		additional_requirements = list("subtype" = list(/obj/item/instrument/vuvuzela = "Vuvuzela"))

	bikehorn
		name = "Bike Horn"
		desc = "A primitive sound syntesizer."
		cost = 5
		size = 1
		research_requirements = list("audio" = 1)
		item_path = /obj/item/instrument/bikehorn
		additional_requirements = list("subtype" = list(/obj/item/instrument/bikehorn = "Bike Horn"))

	dramahorn
		name = "Dramatic Horn"
		desc = "A primitive device capable of predicting yelling or embarrassment to an accuracy of 99.9%."
		cost = 10
		size = 1
		research_requirements = list("audio" = 15)
		item_path = /obj/item/instrument/bikehorn/dramatic

	synthesizer
		name = "Sound Synthesizer"
		desc = "A heavily modified bike horn. Capable of emitting up to 20 different sounds!"
		cost = 50
		size = 1.5
		research_requirements = list("audio" = 25, "engineering" = 10)
		item_path = /obj/item/noisemaker

	whistle
		name = "Whistle Synthesizer"
		desc = "An automated synthesis whistle."
		cost = 5
		size = 1
		research_requirements = list("audio" = 7)
		item_path = /obj/item/instrument/whistle

	harmonica
		name = "Harmonica"
		desc = "Not an actual harmonica, instead, a similarly shaped miniature synthesizer."
		cost = 5
		size = 1
		research_requirements = list("audio" = 7, "engineering" = 2)
		item_path = /obj/item/instrument/whistle

	saxophone
		name = "Saxophone"
		desc = "A pump-operated soundmaking device. Guaranteed to sound like a hit music track from the 1970s!"
		cost = 10
		size = 1.5
		research_requirements = list("audio" = 15, "metals" = 10)
		item_path = /obj/item/instrument/saxophone

	hellsax
		name = "Precursor Saxophone"
		desc = "It's slightly disorienting but man it sounds good."
		cost = 80
		size = 2.5
		research_requirements = list("audio" = 50, "precursor" = 8)
		item_path = /obj/item/hell_sax
		hidden = 1

	hellhorn
		name = "Eldritch Horn"
		desc = "It emits a rather displeasing sound."
		cost = 100
		size = 2.5
		research_requirements = list("audio" = 50, "eldritch" = 8)
		item_path = /obj/item/hell_horn
		hidden = 1

	drinking_glass
		name = "Drinking Glass"
		desc = "A standard 30 unit reagent container."
		cost = 70
		size = 1.25
		research_requirements = list("tools" = 7, "cuisine" = 5)
		item_path = /obj/item/reagent_containers/food/drinks/drinkingglass

	discount_dans_dispenser
		name = "Discount Dan's (tm) Noodle Machine"
		desc = "A vending unit dispensing state of the art Discount Dan's brand food. Made on the spot. Tastes exactly as if it was."
		cost = 500
		size = 5
		research_requirements = list("cuisine" = /*17*/170, "science" = 15)
		item_path = /obj
		hidden = 1

	fire_extinguisher
		name = "Fire Extinguisher"
		desc = "A large, robust tank. Usually used for extinguishing fires."
		cost = 50
		size = 2
		research_requirements = list("tools" = 20, "science" = 2)
		item_path = /obj/item/extinguisher

	atmospheric_transporter
		name = "Atmospheric Transporter"
		desc = "A miniaturization unit that only works on objects that vaguely look and feel like an atmospheric canister. Weird."
		cost = 185
		size = 4
		research_requirements = list("tools" = 30, "science" = 20, "engineering" = 5, "atmospherics" = 8)
		item_path = /obj/item/atmosporter

	duct_tape
		name = "Duct Tape"
		desc = "An item commonly used to fix things, such as untied hands."
		cost = 40
		size = 1
		research_requirements = list("tools" = 20, "science" = 8, "engineering" = 1)
		item_path = /obj/item/handcuffs/tape_roll

	watering_can
		name = "Watering Can"
		desc = "A high capacity reagent container."
		cost = 80
		size = 2
		research_requirements = list("tools" = 11, "hydroponics" = 8, "science" = 8)
		item_path = /obj/item/reagent_containers/glass/wateringcan

	seed_fabricator
		name = "Portable Seed Fabricator"
		desc = "A hydroponics tool, allowing cyborgs to create seeds."
		cost = 120
		size = 1.75
		research_requirements = list("tools" = 15, "devices" = 5, "science" = 4, "hydroponics" = 10)
		item_path = /obj/item/seedplanter

	patch_stacks
		name = "Patch Stack"
		desc = "A patch stacking tool. Allows carrying and applying patches. New patches are added to the top of the stack, but only the top patch can be used."
		cost = 40
		size = 1.25
		research_requirements = list("tools" = 5, "medicine" = 5, "science" = 2)
		item_path = /obj/item/patch_stack

	rcd
		name = "Electrum RCD"
		desc = "A rapid construction device. Uses internal energy reserves to create electrum matter."
		cost = 500
		size = 3
		research_requirements = list("tools" = 30, "engineering" = 20, "science" = 10, "devices" = 5)
		item_path = /obj/item/rcd/cyborg
		additional_requirements = list("subtype" = list(/obj/item/rcd = "RCD"))

	defibrillator
		name = "defibrillator"
		desc = "A human revival tool."
		cost = 35
		size = 2.5
		research_requirements = list("devices" = 15, "medicine" = 15)
		item_path = /obj/item/robodefibrillator

	defibrillator_e
		name = "defibrillator (malfunctioning)"
		desc = "A human un-revival tool."
		cost = 200
		size = 2.5
		research_requirements = list("devices" = 15, "medicine" = 15, "malfunction" = 25)
		item_path = /obj/item/robodefibrillator/emagged
		hidden = 1

	plant_analyzer
		name = "Plant Analyzer"
		desc = "An analysis tool for plant genes."
		cost = 10
		size = 1
		research_requirements = list("analysis" = 8, "hydroponics" = 5, "devices" = 5)
		item_path = /obj/item/plantanalyzer

	health_analyzer_b
		name = "Basic Health Analyzer"
		desc = "An analysis tool for humans."
		cost = 10
		size = 1
		research_requirements = list("analysis" = 8, "medicine" = 5, "devices" = 5)
		item_path = /obj/item/device/analyzer/healthanalyzer

	health_analyzer_a
		name = "Advanced Health Analyzer"
		desc = "An analysis tool for humans. This one is upgraded."
		cost = 20
		size = 1
		research_requirements = list("analysis" = 16, "medicine" = 10, "devices" = 10)
		item_path = /obj/item/device/analyzer/healthanalyzer/borg

	reagentscanner
		name = "Reagent Scanner"
		desc = "An analysis tool for objects."
		cost = 10
		size = 1
		research_requirements = list("analysis" = 8, "science" = 5, "devices" = 5)
		item_path = /obj/item/device/reagentscanner

	analyzer
		name = "Atmospheric Analyzer"
		desc = "An analysis tool for gases."
		cost = 10
		size = 1
		research_requirements = list("analysis" = 8, "atmospherics" = 5, "devices" = 5)
		item_path = /obj/item/device/analyzer/atmospheric

	t_scanner
		name = "T-Scanner"
		desc = "An analysis tool for things below a floor."
		cost = 10
		size = 1
		research_requirements = list("analysis" = 8, "engineering" = 5, "devices" = 5)
		item_path = /obj/item/device/t_scanner

	blotter
		name = "Self-Regenerating Blotter"
		desc = "A blotter that just doesn't run out."
		cost = 80
		size = 3
		research_requirements = list("vice" = 30)
		item_path = /obj/item/reagent_containers/patch/LSD/cyborg
		hidden = 1

	device_analyzer
		name = "Device Analyzer"
		desc = "An analysis tool for electronic devices."
		cost = 10
		size = 1
		research_requirements = list("analysis" = 8, "electronics" = 5)
		item_path = /obj/item/electronics/scanner

	soldering
		name = "Soldering Iron"
		desc = "A tool for assembling electronic parts."
		cost = 25
		size = 1.5
		research_requirements = list("electronics" = 10, "engineering" = 2, "tools" = 4)
		item_path = /obj/item/electronics/soldering

	deconstructor
		name = "Deconstructor"
		desc = "A tool for disassembling electronic parts."
		cost = 100
		size = 2
		research_requirements = list("electronics" = 20, "tools" = 20, "engineering" = 5)
		item_path = /obj/item/deconstructor

	probability_cube_6
		name = "Probability Cube (d6)"
		desc = "A simple six-sided tool for generating a random number."
		cost = 5
		size = 0.1
		research_requirements = list("vice" = 15)
		item_path = /obj/item/dice_bot

	probability_cube_4
		name = "Probability Cube (d4)"
		desc = "A simple four-sided tool for generating a random number."
		cost = 5
		size = 0.1
		research_requirements = list("vice" = 15)
		item_path = /obj/item/dice_bot/d4

	probability_cube_10
		name = "Probability Cube (d10)"
		desc = "A simple ten-sided tool for generating a random number."
		cost = 5
		size = 0.1
		research_requirements = list("vice" = 15)
		item_path = /obj/item/dice_bot/d10

	probability_cube_12
		name = "Probability Cube (d12)"
		desc = "A simple twelve-sided tool for generating a random number."
		cost = 5
		size = 0.1
		research_requirements = list("vice" = 15)
		item_path = /obj/item/dice_bot/d12

	probability_cube_20
		name = "Probability Cube (d20)"
		desc = "A simple twenty-sided tool for generating a random number."
		cost = 5
		size = 0.1
		research_requirements = list("vice" = 15)
		item_path = /obj/item/dice_bot/d20

	probability_cube_100
		name = "Probability Cube (d100)"
		desc = "A simple hundred-sided tool for generating a random number."
		cost = 5
		size = 0.1
		research_requirements = list("vice" = 15)
		item_path = /obj/item/dice_bot/d100

	probability_cube_2
		name = "Probability Disc"
		desc = "A simple two-sided tool for generating a random truth value."
		cost = 5
		size = 0.1
		research_requirements = list("vice" = 10)
		item_path = /obj/item/coin_bot

#define MR_MACHINE_STATE_RESEARCH_STATUS 1
#define MR_MACHINE_STATE_ITEMS 2
#define MR_MACHINE_STATE_TECHNOLOGY 3
#define MR_MACHINE_STATE_MODULE_BUILDER 4
#define MR_MACHINE_STATE_LOCKED 5
#define MR_MACHINE_STATE_UNLOCKED 6
#define MR_MACHINE_STATE_RESEARCHED 7

/datum/module_research_controller
	var/list/highest_state = list()
	var/list/research_state = list()
	var/list/unlocked_tech = list()
	var/list/locked_tech = list()
	var/list/diminishing = list()
	var/list/worth = list()
	var/list/catalog = list()
	var/maximum_size = 8
	var/size_step = 0.72
	var/cost_divisor = 1
	var/cost_divisor_step = 0.014
	var/list/secret_topics = list("malfunction")

	var/needs_setup = 1
	var/locked = 0
	var/data_points = 0
	var/last_generation = 0

	New()
		..()
		setup()
		processing_items.Add(src)

		for (var/mt in cyborg_modules)
			var/obj/item/robot_module/M = new mt
			for (var/obj/item/I in M.tools)
				var/datum/module_tech/T = locate_item(I)
				if (T)
					unlock_now(T)
			qdel(M)

	proc/setup()
		if (!needs_setup)
			return
		needs_setup = 0
		for (var/tech in childrentypesof(/datum/module_tech))
			var/datum/module_tech/T = new tech()
			for (var/research_type in T.research_requirements)
				if (!(research_type in research_state) && !(research_type in secret_topics))
					research_state[research_type] = 0
				if (!(research_type in highest_state))
					highest_state[research_type] = T.research_requirements[research_type]
				else if (highest_state[research_type] < T.research_requirements[research_type])
					highest_state[research_type] = T.research_requirements[research_type]
			locked_tech += T
			research_state["miniaturization"] = 0
			highest_state["miniaturization"] = 100
			research_state["efficiency"] = 0
			highest_state["efficiency"] = 100

	proc/add_points(var/list/res)
		var/break_timer = 0
		while (locked)
			break_timer++
			sleep(1 SECOND)
			if (break_timer > 5)
				locked = 0
		locked = 1
		for (var/rt in res)
			if (rt in research_state)
				research_state[rt] += res[rt]
			else
				research_state[rt] = res[rt]
		locked = 0

	proc/get_max(name)
		return highest_state[name]

	proc/get_amt(name)
		return min(research_state[name], highest_state[name])

	proc/get_ratio(name)
		if (!highest_state[name])
			return 1
		return get_amt(name) / highest_state[name]

	proc/get_perc(name)
		return get_ratio(name) * 100

	proc/check_unlocks()
		maximum_size = initial(maximum_size) + size_step * get_amt("miniaturization")
		cost_divisor = initial(cost_divisor) + cost_divisor_step * get_amt("efficiency")

		var/unlocked = 0
		for (var/datum/module_tech/T in locked_tech)
			var/passed = 1
			for (var/rt in T.research_requirements)
				if (research_state[rt] < T.research_requirements[rt])
					passed = 0
					break
			if (passed)
				unlock_now(T)
				unlocked++
		return unlocked

	proc/process()
		last_generation = 0
		for (var/mob/living/silicon/robot/R in mobs)
			if (R.client)
				data_points++
				last_generation++

	proc/locate_item(var/obj/item/I)
		var/path = I.type
		if (I.module_research_type)
			path = I.module_research_type
		for (var/datum/module_tech/T in locked_tech)
			if (T.item_path == path)
				return T
		for (var/datum/module_tech/T in unlocked_tech)
			if (T.item_path == path)
				return T
		return null

	proc/unlock_now(var/datum/module_tech/T)
		if (T in locked_tech)
			locked_tech -= T
			unlocked_tech += T

var/global/datum/module_research_controller/module_control = new

/obj/submachine/module_researcher
	name = "Cyborg Module Research Station"
	anchored = 1
	density = 1
	desc = "A research station specializing in the miniaturization of tools and binding them for usage with a cyborg module."
	icon = 'icons/obj/objects.dmi'
	icon_state = "moduler-off"

	var/list/modules = list()
	var/list/objects = list()
	var/machine_state = MR_MACHINE_STATE_RESEARCH_STATUS
	var/substate = null
	var/researching = 0
	var/research_speed = 0
	var/research_status = 0
	var/boost_speed = 0
	var/boosted = 0
	var/power_level = 1
	var/research_object = ""
	var/list/grumps = list('sound/machines/mixer.ogg', 'sound/impact_sounds/Slimy_Splat_1.ogg','sound/impact_sounds/Liquid_Slosh_1.ogg','sound/effects/zhit.wav','sound/impact_sounds/Slimy_Hit_3.ogg','sound/impact_sounds/Slimy_Hit_4.ogg','sound/impact_sounds/Flesh_Stab_1.ogg')
	var/list/to_add = list()
	var/list/current_module = list()
	var/module_name = "unnamed module"
	var/module_icon_state = "unknown"
	var/list/users = list()

	New()
		..()
		if (module_control)
			module_control.setup()
		processing_items.Add(src)

	attackby(obj/item/W as obj, mob/user as mob)
		if (isrobot(user))
			return
		if (istype(W, /obj/item/robot_module))
			boutput(user, "<span class='notice'>You insert [W] into [src].</span>")
			modules += W
			user.u_equip(W)
			W.loc = src
			return
		if ((!islist(W.module_research) || !W.module_research.len) && !W.artifact)
			boutput(user, "<span class='alert'>That item cannot be researched!</span>")
			return
		user.u_equip(W)
		boutput(user, "<span class='notice'>You insert [W] into [src].</span>")
		W.loc = src
		objects += W
		add_viewer(user)
		update_all_users()

	proc/check_unlocks()
		var/unlocked = module_control.check_unlocks()
		if (unlocked)
			playsound(src.loc, 'sound/machines/ding.ogg', 50, 1)
			visible_message("<b>[src]</b> unlocks [unlocked == 1 ? "a new item!" : "[unlocked] new items!"]")

	proc/process()
		if (researching)
			playsound(src.loc, pick(grumps), 50, 1)
			if (research_speed)
				research_status += research_speed * power_level
			else
				research_status += 1
			if (research_status >= 100)
				researching = 0
				research_status = 0
				research_speed = 0
				boost_speed = 0
				boosted = 0
				research_object = ""
				playsound(src.loc, 'sound/machines/ding.ogg', 50, 1)
				visible_message("<b>[src]</b> finishes its research process!")
				module_control.add_points(to_add)
				to_add.len = 0
				icon_state = "moduler-off"
				SPAWN_DBG(0)
					check_unlocks()
			update_all_users()

	Topic(href, href_list)
		if (!(usr in view(1)) && !issilicon(usr))
			return
		if (!researching)
			if (href_list["menu"])
				machine_state = text2num(href_list["menu"])
			if (href_list["locked"])
				machine_state = MR_MACHINE_STATE_LOCKED
				substate = locate(href_list["locked"]) in module_control.locked_tech
			if (href_list["unlocked"])
				machine_state = MR_MACHINE_STATE_UNLOCKED
				substate = locate(href_list["unlocked"]) in module_control.unlocked_tech
			if (href_list["researched"])
				machine_state = MR_MACHINE_STATE_RESEARCHED
				substate = text2path(href_list["researched"])
				if (!module_control.worth.Find(substate))
					substate = null
			if (href_list["eject"])
				var/obj/item/I = locate(href_list["eject"]) in src
				if (I && I.loc == src)
					I.loc = src.loc
					usr.put_in_hand_or_drop(I) // try to eject it into the users hand, if we can
					objects -= I
					modules -= I
			if (href_list["shred"])
				var/obj/item/I = locate(href_list["shred"]) in src
				if (I && I.loc == src)
					researching = 1
					visible_message("<b>[src]</b> powers up and begins its research process!")
					var/list/res = I.module_research.Copy()
					if (I.artifact)
						var/datum/artifact/art = I.artifact
						res = art.module_research.Copy()
						res[art.artitype.name] = art.module_research_insight
					else
						module_control.worth[I.type] = res.Copy() + list("--item-name"=initial(I.name))
					var/IT = I.type
					if (I.module_research_type)
						IT = I.module_research_type
					research_object = I.name
					var/diminishes = !I.module_research_no_diminish
					qdel(I)
					var/div = 1
					if (diminishes)
						if (IT in module_control.diminishing)
							div = module_control.diminishing[IT] + 1
						module_control.diminishing[IT] = div
					var/sum = 0
					to_add.len = 0
					for (var/rt in res)
						sum += res[rt]
						to_add[rt] = res[rt] / div
					research_speed = 16 / sum
					research_status = 0
					boost_speed = research_speed
					boosted = 0
					icon_state = "moduler-on"
					playsound(src.loc, 'sound/machines/mixer.ogg', 50, 1)
			if (href_list["buydp"])
				var/amt = text2num(href_list["buydp"])
				var/cost = amt * 30
				if (wagesystem.research_budget >= cost)
					wagesystem.research_budget -= cost
					module_control.data_points += amt
					boutput(usr, "<span class='notice'>Purchased [amt] data points for [cost] credits!</span>")
				else
					boutput(usr, "<span class='alert'>You cannot afford to purchase [amt] data points for [cost] credits!</span>")
			if (href_list["add"])
				var/datum/module_tech/T = locate(href_list["add"]) in module_control.unlocked_tech
				if (T && (T in module_control.unlocked_tech))
					current_module += T
			if (href_list["remove"])
				var/i = text2num(href_list["remove"])
				if (i <= current_module.len)
					current_module.Cut(i, i+1)
			if (href_list["name"])
				var/nn = input("Module name", "Module name", null) as text|null
				if (nn)
					module_name = strip_html(nn)
					if (length(module_name) > 32)
						module_name = copytext(module_name, 1, 33)
					module_name = "[module_name] module"
			if (href_list["icon"])
				var/newval = input("Module icon", "Module icon", null) as null|anything in list("unknown", "standard", "medical", "engineering", "janitor", "mining", "brobot", "hydroponics", "construction", "chemistry")
				if (newval)
					module_icon_state = newval
			if (href_list["reset"])
				current_module.len = 0
			if (href_list["create"])
				var/t_cost = 0
				var/t_size = 0
				if (!modules.len)
					boutput(usr, "<span class='alert'>There are no active modules in the machine.</span>")
				else
					for (var/i = 1, i <= current_module.len, i++)
						var/datum/module_tech/T = current_module[i]
						t_cost += T.cost / module_control.cost_divisor
						t_size += T.size
					if (t_size > module_control.maximum_size)
						boutput(usr, "<span class='alert'>The total size cannot exceed the module maximum size!</span>")
					else if (t_cost > module_control.data_points)
						boutput(usr, "<span class='alert'>You require more data points for this module!</span>")
					else
						module_control.data_points -= t_cost
						var/obj/item/robot_module/R = modules[1]
						for (var/obj/O in R.tools)
							qdel(O)
						R.tools.len = 0
						for (var/i = 1, i <= current_module.len, i++)
							var/datum/module_tech/T = current_module[i]
							var/obj/O = new T.item_path()
							O.loc = R
							R.tools += O
						modules -= R
						R.loc = get_turf(src)
						R.name = module_name
						R.mod_hudicon = module_icon_state
						current_module.len = 0
						playsound(src.loc, 'sound/machines/mixer.ogg', 50, 1)
						module_name = "unnamed module"
						module_icon_state = "unknown"
		else if (href_list["boost"])
			if (boosted >= 5)
				return
			var/boost_cost = (100 * (1 << boosted)) / module_control.cost_divisor
			if (wagesystem.research_budget >= boost_cost)
				boosted += 1
				wagesystem.research_budget -= boost_cost
				research_speed += boost_speed
			else
				boutput(usr, "<span class='alert'>Cannot boost this research any further!</span>")
		if (!href_list["close"])
			add_viewer(usr)
			update_all_users()
		else
			remove_viewer(usr)

	attack_hand(mob/user as mob)
		add_viewer(user)
		show_interface(user)

	proc/update_all_users()
		for (var/mob/M in users)
			if (!(M.machine == src && ((M in viewers(1, src)) || issilicon(M))))
				users -= M
		if (!users.len)
			return
		var/interface = generate_interface()
		for (var/mob/M in users)
			show_to_user(M, interface)

	proc/build_menu(var/list/items)
		var/ret = ""
		for (var/title in items)
			var/id = items[title]
			if (machine_state == id)
				ret += "<li class='active'>[title]</li>"
			else
				ret += "<li><a href='?src=\ref[src];menu=[id]'>[title]</a></li>"
		return "<ul class='menubar'>[ret]</ul>"

	attack_ai(mob/user as mob)
		add_viewer(user)
		show_interface(user)

	proc/add_viewer(var/mob/user)
		src.add_dialog(user)
		if (!(user in users))
			users += user

	proc/remove_viewer(var/mob/user)
		if (user.machine == src)
			user.machine = null
		if (user in users)
			users -= user

	proc/show_to_user(var/mob/user, var/interface)
		user << browse_rsc(icon('icons/mob/hud_robot.dmi', "module-[module_icon_state]"), "module-icon.png")
		user << browse(interface, "window=module_res;size=600x500")
		onclose(user, "module_res", src)

	proc/show_interface(var/mob/user)
		if (!(user in range(1)) && !issilicon(user))
			return
		var/interface = generate_interface()
		show_to_user(user, interface)

	proc/generate_interface()
		var/stylesheet = {"
table {
	border: 1px solid black;
	width: 100%;
}
tr {
	border: none;
}
td {
	border: none;
	padding: 2px;
	border-bottom: 1px solid black;
}
td.header {
	font-weight: bold;
	text-align: center;
}
td.researched {
	background: blue;
}
td.unresearched {
	background: white;
}
ul.menubar {
	padding-left: 0px;
	margin-left: 0px;
}
ul.menubar li {
	display: inline;
	list-style-type: none;
	padding-right: 10px;
}
ul.menubar li.active {
	font-weight: bold;
}
span.tiny {
	font-size: 0.75em;
}
right {
	float: right;
	font-size: 0.75em;
}
"}


		var/header = "<head><title>Module research</title><style>[stylesheet]</style></head>"

		var/list/elems = list("Research status" = MR_MACHINE_STATE_RESEARCH_STATUS, "Research" = MR_MACHINE_STATE_ITEMS, "Technology" = MR_MACHINE_STATE_TECHNOLOGY, "Module builder" = MR_MACHINE_STATE_MODULE_BUILDER)
		var/title = ""
		for (var/t in elems)
			if (machine_state == elems[t])
				title = t
		var/menu = build_menu(elems)
		var/state_screen = ""
		switch (machine_state)
			if (MR_MACHINE_STATE_RESEARCH_STATUS)
				state_screen = "<table cellspacing='0'><tr><td class='header'>Research area</td><td class='header' colspan='25'>Research progress</td></tr>"
				for (var/rtype in module_control.research_state)
					var/rname = uppertext(copytext(rtype, 1, 2)) + copytext(rtype, 2)
					state_screen += "<tr>"
					var/curr = get_amt(rtype)
					var/max = get_max(rtype)
					var/ratio = module_control.get_ratio(rtype)
					var/blocks = min(25, round(ratio * 25))
					var/perc = min(100, ratio * 100)
					state_screen += "<td class='name'>[rname] - [perc]% ([curr]/[max] points)</td>"
					for (var/i = 0, i < blocks, i++)
						state_screen += "<td class='researched'>&nbsp;</td>"
					for (var/i = blocks, i < 25, i++)
						state_screen += "<td class='unresearched'>&nbsp;</td>"
					state_screen += "</tr>"
				state_screen += "</table>"
			if (MR_MACHINE_STATE_ITEMS)
				if (!researching)
					state_screen = "<table cellspacing='0'><tr><td class='header'>Item</td><td class='header'>Topics</td><td class='header'>Effectiveness</td><td class='header' colspan='2'>Actions</td></tr>"
					for (var/obj/item/I in objects)
						state_screen += "<tr>"
						state_screen += "<td class='name'>[I.name]</td>"
						var/topics = ""
						var/sum = 0
						if (I.artifact)
							var/datum/artifact/art = I.artifact
							var/origin = art.artitype.name
							var/tou = uppertext(copytext(origin, 1, 2)) + copytext(origin, 2)
							topics = "[tou]; ???"
							for (var/topic in art.module_research)
								sum += art.module_research[topic]
							sum += art.module_research_insight
						else
							for (var/topic in I.module_research)
								var/tou = uppertext(copytext(topic, 1, 2)) + copytext(topic, 2)
								if (topics == "")
									topics = tou
								else
									topics += "; [tou]"
								sum += I.module_research[topic]
						state_screen += "<td>[topics]</td>"
						var/div = 1
						var/IT = I.type
						if (I.module_research_type)
							IT = I.module_research_type
						if (!I.module_research_no_diminish)
							if (IT in module_control.diminishing)
								div = module_control.diminishing[IT] + 1
						var/eff = 100 / div
						var/secs = 100 / (16 / sum)
						var/mins = round(secs / 60)
						secs = round(secs - mins * 60)
						var/estcompletion = "[mins]:[secs < 10 ? 0 : null][secs]"
						state_screen += "<td>[eff]% ([estcompletion])</td>"
						state_screen += "<td><a href='?src=\ref[src];shred=\ref[I]'>Research</a></td>"
						state_screen += "<td><a href='?src=\ref[src];eject=\ref[I]'>Eject</a></td>"
						state_screen += "</tr>"
					state_screen += "</table>"
				else
					state_screen = "<h2>Research in progress</h2><b>Item name:</b> [research_object]<br><b>Progress:</b> [research_status]%<br>"
					state_screen += "<b>Research budget available: </b>[wagesystem.research_budget] credits<br>"
					if (boosted < 5)
						var/boost_cost = (100 * (1 << boosted)) / module_control.cost_divisor
						state_screen += "<a href='?src=\ref[src];boost=1'>Boost research speed</a> for [boost_cost] credits<br>"
					else
						state_screen += "<b>Cannot boost</b> any further!<br>"
					state_screen += "<b>Boosted:</b> [boosted] time[boosted != 1 ? "s" : null]<br>"
					var/blocks = round(research_status / 4)
					state_screen += "<table cellspacing='0'><tr>"
					for (var/i = 0, i < blocks, i++)
						state_screen += "<td class='researched'>&nbsp;</td>"
					for (var/i = blocks, i < 25, i++)
						state_screen += "<td class='unresearched'>&nbsp;</td>"
					state_screen += "</tr></table>"
			if (MR_MACHINE_STATE_TECHNOLOGY)
				state_screen += "<table><tr><td colspan='3'><b>Technology overview</b></td></tr>"
				state_screen += "<tr><td><b>Unlocked</b></td><td><b>Locked</b></td><td><b>Researched</b></td></tr>"
				state_screen += "<tr><td>"
				for (var/datum/module_tech/T in module_control.unlocked_tech)
					state_screen += "- <a href='?src=\ref[src];unlocked=\ref[T]'>[T.name]</a><br>"
				state_screen += "&nbsp;</td><td>"
				for (var/datum/module_tech/T in module_control.locked_tech)
					if (!T.hidden)
						state_screen += "- <a href='?src=\ref[src];locked=\ref[T]'>[T.name]</a><br>"
				state_screen += "&nbsp;</td><td>"
				for (var/itemT in module_control.worth)
					var/list/itemD = module_control.worth[itemT]
					state_screen += "- <a href='?src=\ref[src];researched=[itemT]'>[itemD["--item-name"]]</a><br>"
				state_screen += "&nbsp;</td></tr></table>"
			if (MR_MACHINE_STATE_MODULE_BUILDER)
				state_screen = "<b>(WORK IN PROGRESS)</b><br><b>Available modules: </b>[modules.len]<br><br>"
				state_screen += "<b>Currently constructed module:</b><br>"
				state_screen += "<b>Module name:</b> <a href='?src=\ref[src];name=1'>[module_name]</a><br>"
				state_screen += "<b>Module icon:</b> <img src='module-icon.png' /> <a href='?src=\ref[src];icon=1'>(change)</a><ul>"
				var/total_cost = 0
				var/total_size = 0
				for (var/i = 1, i <= current_module.len, i++)
					var/datum/module_tech/T = current_module[i]
					total_cost += T.cost / module_control.cost_divisor
					total_size += T.size
					state_screen += "<li><b>[T.name]</b> (<b>Size: </b> [T.size] -- <b>Cost: </b> [T.cost / module_control.cost_divisor] data points)<div class='right'><a href='?src=\ref[src];remove=[i]'>(remove)</a></div></li>"
				state_screen += "</ul>"
				state_screen += "<br><b>Size: </b>[total_size]/[module_control.maximum_size]"
				state_screen += "<br><b>Total cost: </b>[total_cost] data points"
				state_screen += "<br><b>Available data points: </b>[module_control.data_points] data points"
				state_screen += "<br><b>Buy</b> <a href='?src=\ref[src];buydp=1'>1 point for 30 credits</a> | <a href='?src=\ref[src];buydp=10'>10 point for 300 credits</a> | <a href='?src=\ref[src];buydp=100'>100 points for 3000 credits</a>"
				state_screen += "<br><b>Research budget: </b>[wagesystem.research_budget] credits"
				state_screen += "<br><a href='?src=\ref[src];create=1'>(CREATE)</a> - <a href='?src=\ref[src];reset=1'>(RESET)</a>"
				state_screen += "<br><br><b>Unlocked technologies:<b><br><ul>"
				state_screen += ""
				for (var/datum/module_tech/T in module_control.unlocked_tech)
					state_screen += "<li><b>[T.name]</b> <a href='?src=\ref[src];add=\ref[T]'>(add)</a><br><span class='tiny'>[T.desc]</span><br><span class='tiny'><b>Size: </b>[T.size] - <b>Cost: </b>[T.cost / module_control.cost_divisor]</span></li>"
				state_screen += "</ul>"
			if (MR_MACHINE_STATE_LOCKED)
				var/datum/module_tech/T = substate
				if (!istype(T) || !(T in module_control.locked_tech) || T.hidden)
					machine_state = MR_MACHINE_STATE_RESEARCH_STATUS
					return generate_interface()
				title = T.name
				state_screen += "<i>[T.desc]</i><br><br><b>Required topics: </b><br><ul>"
				for (var/rt in T.research_requirements)
					state_screen += "<li>"
					state_screen += uppertext(copytext(rt, 1, 2)) + copytext(rt, 2)
					var/perc = "inf"
					var/pts = T.research_requirements[rt]
					if (module_control.highest_state[rt] > 0)
						perc = pts / module_control.highest_state[rt] * 100
					state_screen += ": [pts] research points ([perc]%)"
					state_screen += "</li>"
				state_screen += "</ul>"
				if (T.additional_requirements.len)
					state_screen += "<br><br><b>Additional requirements: </b><br><ul>"
					for (var/ar in T.additional_requirements)
						state_screen += "<li>"
						state_screen += format_additional_requirement(ar, T.additional_requirements[ar])
						state_screen += "</li>"
					state_screen += "</ul>"
			if (MR_MACHINE_STATE_UNLOCKED)
				var/datum/module_tech/T = substate
				if (!istype(T) || !(T in module_control.unlocked_tech))
					machine_state = MR_MACHINE_STATE_RESEARCH_STATUS
					return generate_interface()
				title = T.name
				state_screen += "<i>[T.desc]</i><br><br><b>Required topics: </b><br>"
				if (T.hidden)
					state_screen += "<i>???</i>"
				else
					state_screen += "<ul>"
					for (var/rt in T.research_requirements)
						var/pts = T.research_requirements[rt]
						state_screen += "<li>"
						state_screen += uppertext(copytext(rt, 1, 2)) + copytext(rt, 2)
						state_screen += ": [pts] research points</li>"
					state_screen += "</ul>"
					if (T.additional_requirements.len)
						state_screen += "<br><br><b>Additional requirements: </b><br><ul>"
						for (var/ar in T.additional_requirements)
							state_screen += "<li>"
							state_screen += format_additional_requirement(ar, T.additional_requirements[ar])
							state_screen += "</li>"
						state_screen += "</ul>"
			if (MR_MACHINE_STATE_RESEARCHED)
				var/key = substate
				if (!ispath(key) || !key || !(key in module_control.worth))
					machine_state = MR_MACHINE_STATE_RESEARCH_STATUS
					return generate_interface()
				var/list/data = module_control.worth[key]
				title = data["--item-name"]
				state_screen += "<b>Item research value per topic: </b><br><ul>"
				for (var/rt in data)
					if (rt == "--item-name")
						continue
					var/pts = data[rt]
					state_screen += "<li>"
					state_screen += uppertext(copytext(rt, 1, 2)) + copytext(rt, 2)
					state_screen += ": [pts] research points</li>"
				state_screen += "</ul>"
		return "<html>[header]<body><div class='menu'>[menu]</div><div class='content'><h2>[title]</h2>[state_screen]</div><br><br><a href='?action=mach_close&window=module_res'>Close</a></body></html>"

	proc/format_additional_requirement(ar, spec)
		var/output = ""
		switch (ar)
			if ("subtype")
				output += "Research one of the following types of items:<ul>"
				for (var/it in spec)
					output += "<li>[spec[it]]</li>"
				output += "</ul>"
			else
				output += "Unknown additional requirement '[ar]'"
		return output

#undef MR_MACHINE_STATE_RESEARCH_STATUS
#undef MR_MACHINE_STATE_ITEMS
#undef MR_MACHINE_STATE_TECHNOLOGY
#undef MR_MACHINE_STATE_MODULE_BUILDER
#undef MR_MACHINE_STATE_LOCKED
#undef MR_MACHINE_STATE_UNLOCKED
#undef MR_MACHINE_STATE_RESEARCHED
