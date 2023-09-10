/datum/demand_control
	var/list/commodities = list()
	var/price_multiplier = 1
	var/base_price_multiplier = 1
	var/high_demand_level = 30

	var/workstation_grade = 1

	var/current_demand_level = 30

	var/demand_change_interval = 3000
	var/last_demand_change = 0
	var/fluctuates = 1
	var/static_growth = 0

	var/maximum_demand_level = 120

	var/demand_change_text = null

	New()
		..()
		var/new_packs = list()
		for (var/P in commodities)
			if (ispath(P))
				new_packs += new P()
			else if (istype(P, /datum/commodity))
				new_packs += P
		commodities = new_packs

	proc/visibility(var/grade)
		if (!istype(ticker.mode, /datum/game_mode/construction))
			return 0
		if (workstation_grade > grade)
			return 0
		if (current_demand_level < high_demand_level * 0.5)
			return "out-of-stock"
		return "available"

	proc/fluctuate()
		current_demand_level += static_growth
		if (fluctuates)
			if (current_demand_level < high_demand_level)
				var/difference = high_demand_level - current_demand_level
				if (prob(3))
					current_demand_level = 0
				else if (prob(50))
					current_demand_level += rand(difference)
				else if (prob(75))
					current_demand_level  -= rand(difference)
					current_demand_level = max(current_demand_level, 0)
				else
					current_demand_level = high_demand_level
			else
				if (prob(30))
					current_demand_level = high_demand_level
				else if (prob(40))
					current_demand_level = round(current_demand_level / 2)
				else if (prob(40))
					current_demand_level = round(current_demand_level * ((100 + rand(100)) / 100))
				else
					current_demand_level = (current_demand_level - high_demand_level)
		if (current_demand_level > maximum_demand_level)
			current_demand_level = maximum_demand_level
		adjust_price_multiplier()

	proc/adjust_price_multiplier()
		if (current_demand_level > high_demand_level * 1.2)
			price_multiplier = (high_demand_level / current_demand_level) - 0.2
		else if (current_demand_level > high_demand_level * 0.5)
			price_multiplier = 1
		else
			var/ratio = current_demand_level / (high_demand_level * 0.5)
			price_multiplier = 0.2 + 0.8 * ratio
		price_multiplier *= base_price_multiplier

	proc/fulfill(var/datum/commodity/C)
		if (current_demand_level > 0)
			current_demand_level--
		var/profit = price_multiplier * C.baseprice
		wagesystem.shipping_budget += profit
		adjust_price_multiplier()
		return profit

	proc/match_condition(var/obj/O)
		return null

	proc/is_sellable(var/obj/O)
		if (istype(O, /obj/storage/crate))
			return 1

	proc/unlisted_commodities()
		return null

/datum/demand_control/artifacts
	commodities = list()
	high_demand_level = 20
	static_growth = 0
	current_demand_level = 20
	maximum_demand_level = 20
	base_price_multiplier = 1

	var/comhandheld
	var/comlarge

	New()
		..()
		comhandheld = new /datum/commodity/smallartifact()
		comlarge = new /datum/commodity/largeartifact()

	match_condition(var/obj/O)
		if (isitem(O) && O.artifact)
			return comhandheld
		else if (O.artifact)
			return comlarge
		return null

	is_sellable(var/obj/O)
		if (match_condition(O))
			return 1
		return 0

	unlisted_commodities()
		return list(comhandheld, comlarge)

/datum/demand_control/produce
	commodities = list(/datum/commodity/produce)
	high_demand_level = 200
	static_growth = 40
	current_demand_level = 200
	maximum_demand_level = 1000
	base_price_multiplier = 1.5

/datum/demand_control/herbs
	commodities = list(/datum/commodity/herbs)
	high_demand_level = 20
	static_growth = 10
	current_demand_level = 20
	maximum_demand_level = 100
	base_price_multiplier = 1.5

/datum/demand_control/gold
	commodities = list(/datum/commodity/goldbar)
	high_demand_level = 8
	static_growth = 0
	current_demand_level = 10
	maximum_demand_level = 20
	base_price_multiplier = 0.5

/datum/demand_control/goldnuggets
	commodities = list(/datum/commodity/ore/gold)
	high_demand_level = 20
	static_growth = 0
	current_demand_level = 20
	maximum_demand_level = 25
	base_price_multiplier = 0.5

/datum/demand_control/common_ores
	commodities = list(/datum/commodity/ore/mauxite, /datum/commodity/ore/pharosium, /datum/commodity/ore/molitz, /datum/commodity/ore/char)
	high_demand_level = 100
	static_growth = 20
	current_demand_level = 100
	maximum_demand_level = 500
	base_price_multiplier = 8

/datum/demand_control/common_valuables
	commodities = list(/datum/commodity/ore/cobryl)
	high_demand_level = 50
	static_growth = 5
	current_demand_level = 20
	maximum_demand_level = 100

/datum/demand_control/alien_ores
	commodities = list(/datum/commodity/ore/koshmarite, /datum/commodity/ore/viscerite)
	high_demand_level = 250
	static_growth = 10
	current_demand_level = 250
	maximum_demand_level = 300

/datum/demand_control/rare_ores
	commodities = list(/datum/commodity/ore/claretine, /datum/commodity/ore/bohrum)
	high_demand_level = 100
	static_growth = 20
	current_demand_level = 100
	maximum_demand_level = 500

/datum/demand_control/special_ores
	commodities = list(/datum/commodity/ore/cerenkite, /datum/commodity/ore/plasmastone)
	high_demand_level = 10
	static_growth = 2
	current_demand_level = 0
	maximum_demand_level = 100

/datum/demand_control/rare_valuables
	commodities = list(/datum/commodity/ore/syreline)
	high_demand_level = 25
	static_growth = 0
	current_demand_level = 60
	maximum_demand_level = 100

/datum/demand_control/rare_crystals
	commodities = list(/datum/commodity/ore/erebite, /datum/commodity/ore/telecrystal, /datum/commodity/ore/uqill)
	high_demand_level = 20
	static_growth = 1
	fluctuates = 0
	current_demand_level = 30
	maximum_demand_level = 50

/datum/supply_control
	var/datum/progress/required = null
	var/maximum_stock = 1
	var/replenishment_time = 6000
	var/list/supply_packs = list()

	var/cost_multiplier = 1

	var/initial_stock = 1
	var/current_stock = 1

	var/next_resupply_at = 0
	var/next_resupply_text = null

	var/workstation_grade = 1

	proc/update_resupply_text()
		if (next_resupply_at)
			next_resupply_text = dstohms(next_resupply_at - ticker.round_elapsed_ticks)
		else
			if (next_resupply_text)
				next_resupply_text = null

	New()
		..()
		var/new_packs = list()
		for (var/P in supply_packs)
			if (ispath(P))
				new_packs += new P()
			else if (istype(P, /datum/supply_packs))
				new_packs += P
		supply_packs = new_packs

	proc/visibility(var/grade)
		if (!istype(ticker.mode, /datum/game_mode/construction))
			return 0
		if (workstation_grade > grade)
			return 0
		var/datum/game_mode/construction/C = ticker.mode
		if (required)
			var/datum/progress/P = locate(required) in C.milestones
			if (!P)
				return 0
			if (!P.completed)
				return "not-yet-available"
		if (!current_stock && maximum_stock)
			return "out-of-stock"
		return "available"

	proc/is_available(var/grade)
		if (!istype(ticker.mode, /datum/game_mode/construction))
			return 0
		if (workstation_grade > grade)
			return 0
		if (!current_stock && maximum_stock)
			return 0
		var/datum/game_mode/construction/C = ticker.mode
		if (required)
			var/datum/progress/P = locate(required) in C.milestones
			if (!P)
				return 0
			if (!P.completed)
				return 0
		return 1

	proc/consume()
		current_stock--
		if (maximum_stock && replenishment_time > 0 && !next_resupply_at)
			next_resupply_at = ticker.round_elapsed_ticks + replenishment_time
			update_resupply_text()

/datum/supply_control/crate
	maximum_stock = 0
	supply_packs = list(/datum/supply_packs/emptycrate)

/datum/supply_control/glass_kit
	maximum_stock = 3
	supply_packs = list(/datum/supply_packs/glass50)

/datum/supply_control/metal_kit
	maximum_stock = 3
	supply_packs = list(/datum/supply_packs/metal50)

/datum/supply_control/cable_kit
	maximum_stock = 3
	supply_packs = list(/datum/supply_packs/electrical)

/datum/supply_control/homing_kit
	maximum_stock = 3
	replenishment_time = 18000
	supply_packs = list(/datum/supply_packs/homing_kit)

/datum/supply_control/cargo_kit
	maximum_stock = 2
	replenishment_time = 18000
	supply_packs = list(/datum/supply_packs/complex/cargo_kit)

/datum/supply_control/manufacturer_kit
	maximum_stock = 2
	replenishment_time = 18000
	supply_packs = list(/datum/supply_packs/complex/manufacturer_kit)

//Nadir is not intended to have station pods/submarines
#ifndef MAP_OVERRIDE_NADIR
/datum/supply_control/pod_kit
	maximum_stock = 2
	replenishment_time = 9000
	supply_packs = list(/datum/supply_packs/complex/pod_kit)
	workstation_grade = 2
#endif

/datum/supply_control/ai_kit
	maximum_stock = 2
	replenishment_time = 36000
	supply_packs = list(/datum/supply_packs/complex/ai_kit)
	workstation_grade = 2

/datum/supply_control/security_camera
	maximum_stock = 0
	supply_packs = list(/datum/supply_packs/complex/security_camera)
	workstation_grade = 2

/datum/supply_control/mainframe_kit
	maximum_stock = 2
	replenishment_time = 36000
	supply_packs = list(/datum/supply_packs/complex/mainframe_kit)
	workstation_grade = 2

/datum/supply_control/manufacturer_kit
	maximum_stock = 1
	replenishment_time = 6000
	supply_packs = list(/datum/supply_packs/complex/manufacturer_kit)

/datum/supply_control/elec_kit
	maximum_stock = 1
	supply_packs = list(/datum/supply_packs/complex/electronics_kit)

#ifndef UNDERWATER_MAP
/datum/supply_control/mini_magnet_kit
	maximum_stock = 2
	replenishment_time = 9000
	supply_packs = list(/datum/supply_packs/complex/mini_magnet_kit)

/datum/supply_control/magnet_kit
	maximum_stock = 2
	replenishment_time = 36000
	supply_packs = list(/datum/supply_packs/complex/magnet_kit)
	workstation_grade = 2
#endif

/datum/supply_control/medkits
	maximum_stock = 1
	replenishment_time = 6000
	supply_packs = list(/datum/supply_packs/medicalfirstaid)

/datum/supply_control/bathroom
	maximum_stock = 5
	replenishment_time = 3000
	supply_packs = list(/datum/supply_packs/medicalfirstaid)
/*
/datum/supply_control/arc_smelter
	required = /datum/progress/rooms/cargo_bay
	maximum_stock = 2
	replenishment_time = 36000
	supply_packs = list(/datum/supply_packs/complex/arc_smelter)
	workstation_grade = 2
*/
/datum/supply_control/weapon_kit
	maximum_stock = 3
	initial_stock = 1
	replenishment_time = 36000
	supply_packs = list(/datum/supply_packs/weapons2)

/datum/supply_control/stun_baton
	maximum_stock = 3
	initial_stock = 2
	replenishment_time = 6000
	supply_packs = list(/datum/supply_packs/baton)

/datum/supply_control/administrative_id
	maximum_stock = 3
	initial_stock = 2
	replenishment_time = 6000
	supply_packs = list(/datum/supply_packs/administrative_id)

/datum/supply_control/plasmastone
	maximum_stock = 3
	initial_stock = 2
	replenishment_time = 18000
	supply_packs = list(/datum/supply_packs/plasmastone)

/datum/supply_control/banking
	required = /datum/progress/rooms/cargo_bay
	maximum_stock = 2
	initial_stock = 2
	workstation_grade = 2
	replenishment_time = 18000
	supply_packs = list(/datum/supply_packs/banking_kit)

/datum/supply_control/basic_power
	required = /datum/progress/rooms/cargo_bay
	maximum_stock = 2
	initial_stock = 2
	workstation_grade = 2
	replenishment_time = 18000
	supply_packs = list(/datum/supply_packs/complex/basic_power_kit)

/datum/supply_control/id_computer
	required = /datum/progress/rooms/cargo_bay
	maximum_stock = 2
	initial_stock = 2
	workstation_grade = 2
	replenishment_time = 18000
	supply_packs = list(/datum/supply_packs/id_computer)

/datum/supply_control/medical
	required = /datum/progress/rooms/cargo_bay
	maximum_stock = 2
	initial_stock = 2
	workstation_grade = 2
	replenishment_time = 18000
	supply_packs = list(/datum/supply_packs/complex/medical_kit)

/datum/supply_control/robotics
	required = /datum/progress/rooms/medbay
	maximum_stock = 2
	initial_stock = 2
	workstation_grade = 2
	replenishment_time = 18000
	supply_packs = list(/datum/supply_packs/complex/robotics_kit)

/datum/supply_control/genetics
	required = /datum/progress/rooms/medbay
	maximum_stock = 2
	initial_stock = 2
	workstation_grade = 2
	replenishment_time = 18000
	supply_packs = list(/datum/supply_packs/complex/genetics_kit)

/datum/supply_control/artlab
	maximum_stock = 2
	initial_stock = 2
	workstation_grade = 2
	replenishment_time = 18000
	supply_packs = list(/datum/supply_packs/complex/artlab_kit)

/datum/supply_control/telesci
	maximum_stock = 2
	initial_stock = 2
	workstation_grade = 2
	replenishment_time = 18000
	supply_packs = list(/datum/supply_packs/complex/telescience_kit)

/datum/supply_control/defense
	maximum_stock = 5
	initial_stock = 0
	replenishment_time = 18000
	supply_packs = list(/datum/supply_packs/complex/turret_kit)

/datum/supply_control/fueltank
	maximum_stock = 1
	initial_stock = 1
	replenishment_time = 18000
	supply_packs = list(/datum/supply_packs/fueltank)

/datum/supply_control/watertank
	maximum_stock = 1
	initial_stock = 1
	replenishment_time = 18000
	supply_packs = list(/datum/supply_packs/watertank)

/datum/supply_control/compostbin
	maximum_stock = 1
	initial_stock = 1
	replenishment_time = 18000
	supply_packs = list(/datum/supply_packs/compostbin)

/datum/supply_control/telecrystal
	maximum_stock = 6
	initial_stock = 4
	replenishment_time = 18000
	supply_packs = list(/datum/supply_packs/telecrystal)

/datum/supply_control/telecrystal_bulk
	maximum_stock = 3
	initial_stock = 2
	replenishment_time = 36000
	supply_packs = list(/datum/supply_packs/telecrystal_bulk)

/datum/supply_control/janitor
	maximum_stock = 2
	initial_stock = 2
	replenishment_time = 2500
	supply_packs = list(/datum/supply_packs/janitor)

/obj/supply_pad
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "pad0"
	name = "supply telepad"
	desc = "It's a Nanotrasen 'Waterloo 1.0' cargo teleportation pad used to teleport goods instantly between distant locations. Requires a telecrystal to function."
	density = 0
	anchored = ANCHORED
	opacity = 0

	var/has_crystal = 0
	var/direction = 0 // 0 = incoming, 1 = outgoing
	var/obj/machinery/computer/linked = null

	var/charge = 100
	var/recharge_rate = 1

	proc/is_ready()
		return has_crystal && charge == 100

	proc/used()
		charge = 0
		has_crystal--
		SPAWN(0)
			while (charge < 100)
				charge++
				sleep(0.1 SECONDS)

	examine()
		. = ..()
		. += "<span class='notice'>The pad is currently at [charge]% charge.</span>"
		if (has_crystal)
			. += "<span class='notice'>The pad is complete with a telecrystal.</span>"
		else
			. += "<span class='alert'>The pad's telecrystal socket is empty!</span>"

	attackby(var/obj/item/I, user)
		if (istype(I, /obj/item/raw_material/telecrystal))
			qdel(I)
			has_crystal++
			boutput(user, "<span class='notice'>You plug the telecrystal into the teleportation pad.</span>")

	ex_act()
		return
	meteorhit()
		return
	bullet_act()
		return

TYPEINFO(/obj/supply_pad/incoming)
	mats = 10

/obj/supply_pad/incoming
	name = "Incoming supply pad"
	direction = 0

TYPEINFO(/obj/supply_pad/outgoing)
	mats = 10

/obj/supply_pad/outgoing
	name = "Outgoing supply pad"
	direction = 1

/obj/machinery/computer/special_supply
	// This is a grade 1 workstation. Contains bare-bones supplies.
	name = "Special Supply Computer"
	icon = 'icons/obj/computer.dmi'
	icon_state = "QMcom"
	density = 1
	anchored = ANCHORED
	opacity = 0

	var/obj/supply_pad/in_target
	var/obj/supply_pad/out_target

	var/static/list/sellables_cache = list()
	var/static/list/unsellables_cache = list()
	var/static/list/dccache = list()
	var/static/list/comcache = list()

	var/message = null

	var/mode = 0
	var/workstation_grade = 1

	var/has_battery_power = 1

	commerce
		// Grade 2 workstation. No trader contact, contains the full NT catalog.
		name = "Commerce Computer"
		workstation_grade = 2
		has_battery_power = 0

	ex_act()
		return
	meteorhit()
		return
	bullet_act()
		return

	proc/recheck()
		for (var/obj/supply_pad/S in orange(1, src))
			if (S.direction && !out_target)
				out_target = S
			else if (!S.direction && !in_target)
				in_target = S
		if (!out_target)
			var/obj/supply_pad/outgoing/OUT = locate() in range(1, src)
			if (OUT)
				out_target = OUT
		if (!in_target)
			var/obj/supply_pad/incoming/IN = locate() in range(1, src)
			if (IN)
				in_target = IN

	New()
		..()
		SPAWN(5 SECONDS)
			recheck()

	proc/is_sellable(var/obj/O)
		if (!istype(O))
			return 0
		if (O.type in sellables_cache)
			return 1
		if (O.type in unsellables_cache)
			return 0
		var/datum/game_mode/construction/C = ticker.mode
		for (var/datum/demand_control/DQ in C.special_demand_control)
			if (DQ.is_sellable(O))
				sellables_cache += O.type
				return 1
		unsellables_cache += O.type
		return 0

	proc/do_sell(var/obj/Q)
		var/datum/game_mode/construction/C = ticker.mode
		var/datum/demand_control/DCO = null
		var/datum/commodity/COM = null
		if (Q.type in dccache)
			DCO = dccache[Q.type]
			COM = comcache[Q.type]
		else
			for (var/datum/demand_control/DQ in C.special_demand_control)
				for (var/datum/commodity/CO in DQ.commodities)
					if (istype(Q, CO.comtype))
						DCO = DQ
						COM = CO
						dccache[Q.type] = DCO
						comcache[Q.type] = COM
						break
				if (!DCO)
					COM = DQ.match_condition(Q)
					if (COM)
						DCO = DQ
				if (DCO)
					break
		if (DCO)
			return DCO.fulfill(COM)
		return 0

	Topic(href, href_list)
		if (!(usr in range(1)))
			return
		if (!ticker)
			return
		if (!ticker.mode)
			return
		if (!powered() && !has_battery_power)
			return
		if (href_list["recheck"])
			recheck()
		if (href_list["purchase"] && href_list["control"])
			if (!in_target)
				message = "<span class='bad'>Cannot lock targeting vector, aborting purchase.</span>"
			else
				if (!in_target.is_ready())
					if (!in_target.has_crystal)
						message = "<span class='bad'>The supply pad requires a telecrystal to function.</span>"
					else
						message = "<span class='bad'>The supply pad is recharging.</span>"
				else
					var/turf/T = get_turf(in_target)
					for (var/atom/movable/O in T)
						if ((O != in_target && O.density) || isliving(O))
							message = "<span class='bad'>Please clear the teleportation target area.</span>"
							attack_hand(usr)
							return
					var/datum/supply_packs/P = locate(href_list["purchase"])
					var/datum/supply_control/C = locate(href_list["control"])
					if (C.is_available(workstation_grade))
						if (P.cost <= wagesystem.shipping_budget)
							in_target.used()
							C.consume()
							wagesystem.shipping_budget -= P.cost
							P.create(T)
							showswirl(T)
							message = "<span class='good'>Purchase complete. Cost: [P.cost] credits.</span>"
						else
							message = "<span class='bad'>Insufficient funds in budget to purchase that item.</span>"
					else
						message = "<span class='bad'>That item is currently not available.</span>"
		else if (href_list["sell"])
			if (!out_target)
				message = "<span class='bad'>Cannot lock targeting vector, aborting purchase.</span>"
			else
				if (!out_target.is_ready())
					if (!out_target.has_crystal)
						message = "<span class='bad'>The supply pad requires a telecrystal to function.</span>"
					else
						message = "<span class='bad'>The supply pad is recharging.</span>"
				else
					var/turf/T = get_turf(out_target)
					var/obj/CR = null
					for (var/atom/movable/O in T)
						if (O == src)
							continue
						if (is_sellable(O))
							CR = O
						else if (O.density || isliving(O) || isitem(O))
							message = "<span class='bad'>Please remove all objects and lifeforms not being sold from the telepad.</span>"
							attack_hand(usr)
							return
					if (!CR)
						message = "<span class='bad'>No objects slated for selling found on the pad.</span>"
					else
						var/profit = 0
						for (var/obj/item/Q in CR)
							if (!istype(Q))
								Q.set_loc(T)
								for (var/mob/M in viewers(Q))
									boutput(M, "<span class='notice'>[Q] pops out of [CR]!</span>")
							else
								profit += do_sell(Q)
								qdel(Q)
						profit += do_sell(CR)
						message = "<span class='good'>Sold [CR] from outgoing pad. Profit: [profit] credits</span>"
						qdel(CR)
						showswirl(get_turf(out_target))
						out_target.used()
		else if (href_list["mode"])
			mode = text2num_safe(href_list["mode"])
		attack_hand(usr)

	attack_hand(var/mob/user)
		if (!ticker || !ticker.mode)
			return
		if (!istype(ticker.mode, /datum/game_mode/construction))
			return
		if (!in_target || !out_target)
			recheck()
		var/datum/game_mode/construction/C = ticker.mode
		var/is_powered = src.powered()
		if (!is_powered && !has_battery_power)
			user.Browse("The screen is blank.", "window=specsupply;size=500x400")
			return
		var/interface = {"<html><head><style>
table.orderable {
	border-collapse: collapse;
	width: 100%;
}
table.orderable thead tr {
	background-color: #F0DC82;
}
table.orderable tr.out-of-stock {
	background-color: #FF6666;
}
table.orderable tr.not-yet-available {
	background-color: #999999;
}
table.orderable td.purchase {
	text-align: right;
}
body {
	margin: 0;
	padding: 0;
}
h2 {
	margin-left: 5px;
	margin-top: 5px;
}
.bad {
	color: red;
}
.good {
	color: blue;
}
</style></head><body>"}
		interface += "<h2>Survey Supply Console</h2>"
		if (!is_powered)
			interface += "<span class='bad'><b>Warning:</b> workstation operating off battery power.<br><br>"
		if (message)
			interface += "[message]<br><br>"
		interface += "<strong>Expedition budget:</strong> [wagesystem.shipping_budget] credits<br>"
		if (!in_target)
			interface += "<span class='bad'>Incoming supply pad not detected. <a href='?src=\ref[src];recheck=1'>Re-check</a></span><br>"
		else
			if (in_target.has_crystal == 0)
				interface += "<span class='bad'>Incoming supply pad telecrystal storage depleted.</span><br>"
			else if (in_target.charge < 100)
				interface += "<span class='bad'>Incoming supply pad is recharging. Current charge: [in_target.charge]%.</span><br>"
			else
				interface += "<span class='good'>Incoming supply pad is ready. Available crystals: [in_target.has_crystal].</span><br>"
		if (!out_target)
			interface += "<span class='bad'>Outgoing supply pad not detected. <a href='?src=\ref[src];recheck=1'>Re-check</a></span><br>"
		else
			if (out_target.has_crystal == 0)
				interface += "<span class='bad'>Outgoing supply pad telecrystal storage depleted.</span><br>"
			else if (out_target.charge < 100)
				interface += "<span class='bad'>Outgoing supply pad is recharging. Current charge: [out_target.charge]%.</span><br>"
			else
				interface += "<span class='good'>Outgoing supply pad is ready. Available crystals: [out_target.has_crystal].</span><br>"
		if (mode == 0)
			interface += "<strong>Purchase items</strong> | <a href='?src=\ref[src];mode=1'>View market demand</a> | <a href='?src=\ref[src];sell=1'>Sell goods</a><br>"
			interface += "<table class='orderable'><thead><tr><th>Item name and contents</th><th>Stock</th><th>Cost</th><th>Purchase</th></tr></thead>"
			interface += "<tbody>"
			for (var/datum/supply_control/S in C.special_supply_control)
				var/vis = S.visibility(workstation_grade)
				if (vis)
					for (var/datum/supply_packs/P in S.supply_packs)
						interface += "<tr class='[vis]'><td><strong>[P.name]</strong><br>[P.desc]"
						if (S.next_resupply_text)
							interface += "<br><em>Projected stock update in [S.next_resupply_text]</em>"
						interface += "</td>"
						if (S.maximum_stock)
							interface += "<td>[S.current_stock]</td>"
						else
							interface += "<td>&nbsp;</td>"
						interface += "<td>[P.cost * S.cost_multiplier]</td>"
						interface += "<td class='purchase'>"
						if (S.is_available(workstation_grade) && in_target)
							interface += "<a href='?src=\ref[src];purchase=\ref[P];control=\ref[S]'>Buy</a>"
						interface += "</td></tr>"
			interface += "</tbody></table>"
		else
			interface += "<a href='?src=\ref[src];mode=0'>Purchase items</a> | <strong>View market demand</strong> | <a href='?src=\ref[src];sell=1'>Sell goods</a><br>"
			interface += "<table class='orderable'><thead><tr><th>Demanded commodity</th><th>Price per unit</th><th>Demand level</th></thead>"
			for (var/datum/demand_control/D in C.special_demand_control)
				var/vis = D.visibility(workstation_grade)
				if (vis)
					var/list/all_commodities = D.unlisted_commodities()
					if (!all_commodities)
						all_commodities = list()
					all_commodities += D.commodities
					for (var/datum/commodity/CO in all_commodities)
						var/DLI = null
						if (D.current_demand_level > D.high_demand_level)
							DLI = "high"
						else if (D.current_demand_level > D.high_demand_level * 0.7)
							DLI = "normal"
						else if (D.current_demand_level > D.high_demand_level * 0.4)
							DLI = "low"
						else
							DLI = "very low"
						interface += "<tr class='[vis]'><td>[CO.comname]"
						if (D.demand_change_text)
							interface += "<br><em>Projected market shift in [D.demand_change_text]</em>"
						interface += "</td><td>[CO.baseprice * D.price_multiplier]</td><td>[DLI]</td></tr>"
			interface += "<tbody>"

			interface += "</tbody></table>"
		interface += "</body></html>"
		user.Browse(interface, "window=specsupply;size=500x400")
