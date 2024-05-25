// Salvager Gear

/obj/item/salvager
	name = "salvage reclaimer"
	desc = "A strange hodgepodge of industrial equipment used to break apart equipment and structures and reclaim the material.  A retractable crank acts as a great belt hook and recharging aid."
#ifndef SECRETS_ENABLED
	icon_state = "broken_egun"
#endif
	flags = FPRINT | TABLEPASS | CONDUCT
	c_flags = ONBELT
	force = 10.0
	throwforce = 10.0
	throw_speed = 1
	throw_range = 5
	two_handed = 1
	w_class = W_CLASS_NORMAL
	m_amt = 50000
	stamina_damage = 15
	stamina_cost = 15
	stamina_crit_chance = 5
	inventory_counter_enabled = 1
	/// do we really actually for real want this to work in adventure zones?? just do this with varedit dont make children with this on
	var/really_actually_bypass_z_restriction = FALSE

	New()
		..()
		var/cell = new/obj/item/ammo/power_cell
		AddComponent(/datum/component/cell_holder, new_cell=cell, chargable=TRUE, max_cell=100, swappable=FALSE)
		RegisterSignal(src, COMSIG_UPDATE_ICON, /atom/proc/UpdateIcon)
		UpdateIcon()

	proc/get_welding_positions()
		var/start = list(-15,15)
		var/stop = list(15,-15)
		. = list(start,stop)

	update_icon()
		var/list/ret = list()
		if (SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			inventory_counter.update_percent(ret["charge"], ret["max_charge"])
		else
			inventory_counter.update_text("-")

	afterattack(atom/A, mob/user as mob)
		if ((isrestrictedz(user.z) || isrestrictedz(A.z)) && !src.really_actually_bypass_z_restriction)
			boutput(user, "\The [src] won't work here for some reason. Oh well!")
			return

		if (BOUNDS_DIST(get_turf(src), get_turf(A)) > 0)
			return
		else if (istype(A, /turf/simulated/wall))
			. = 20 SECONDS
			if (istype(A, /turf/simulated/wall/r_wall) || istype(A, /turf/simulated/wall/auto/reinforced))
				. += 5 SECONDS
			else if (istype(A, /turf/simulated/wall/auto/shuttle))
				return

			var/turf/simulated/wall/W = A
			. *= max(W.health/initial(W.health),0.1)

		else if (istype(A, /turf/simulated/floor))
			var/turf/simulated/floor/floor_turf
#ifdef UNDERWATER_MAP
			. = 45 SECONDS
#else
			. = 30 SECONDS
#endif
			if(floor_turf.broken)
				. -= 5 SECONDS
			if(!floor_turf.intact)
				. -= 5 SECONDS
		else if (istype(A, /obj/machinery/door/airlock)||istype(A, /obj/machinery/door/unpowered/wood))
			var/obj/machinery/door/airlock/AL = A
			if (AL.hardened == 1)
				boutput(user, SPAN_ALERT("\The [AL] is reinforced against deconstruction!"))
				return
			. = 30 SECONDS
		else if (istype(A, /obj/structure/girder))
			. = 10 SECONDS
		else if (istype(A, /obj/grille))
			. = 6 SECONDS
			var/obj/grille/the_grille = A
			. *= max(the_grille.health/the_grille.health_max,0.1)
		else if (istype(A, /obj/window))
			. = 10 SECONDS
		else if (istype(A, /obj/lattice))
			. = 5 SECONDS
		else if( isobj(A) )
			var/obj/O = A

			// Based on /obj/item/deconstructor/proc/afterattack()
			var/decon_complexity = O.build_deconstruction_buttons()
			if (!decon_complexity)
				boutput(user, SPAN_ALERT("[O] cannot be deconstructed."))
				return

			if (istext(decon_complexity))
				boutput(user, SPAN_ALERT("[decon_complexity]"))
				return

			if(locate(/mob/living) in O)
				boutput(user, SPAN_ALERT("You cannot deconstruct [O] while someone is inside it!"))
				return

			if (isrestrictedz(O.z) && !isitem(A))
				boutput(user, SPAN_ALERT("You cannot bring yourself to deconstruct [O] in this area."))
				return

			. += 5 SECONDS
			. += decon_complexity * 3 SECONDS
			boutput(user, "You start to destructively deconstruct [A].")

		if(user.traitHolder.hasTrait("carpenter") || user.traitHolder.hasTrait("training_engineer"))
			. = round(. * 0.75)

		if(.)
			. = max(., 2 SECONDS)
#ifdef SECRETS_ENABLED
			icon_state = "salvager-on"
			item_state = "salvager-on"
#endif
			user.update_inhands()
			var/positions = src.get_welding_positions()
			actions.start(new /datum/action/bar/private/welding/salvage(user, A, ., /obj/item/salvager/proc/weld_action, \
				list(A, user), null, positions[1], positions[2], src),user)

	proc/weld_action(atom/A, mob/user as mob)
#ifdef SECRETS_ENABLED
		icon_state = "salvager"
		item_state = "salvager"
#endif
		user.update_inhands()

		if (istype(A, /turf/simulated/wall/r_wall) || istype(A, /turf/simulated/wall/auto/reinforced))
			var/turf/simulated/wall/W = A
			W.dismantle_wall(prob(10))
			log_construction(user, "deconstructs a reinforced wall into a normal wall ([A])")
			return

		else if (istype(A, /turf/simulated/wall))
			var/turf/simulated/wall/W = A
			W.dismantle_wall(prob(33))
			log_construction(user, "deconstructs a wall ([A])")

		else if (istype(A, /turf/simulated/floor))
			var/turf/simulated/floor/F = A
			if (prob(50))
				var/atom/movable/B = new /obj/item/raw_material/scrap_metal
				B.set_loc(get_turf(A))
				if (F.material)
					B.setMaterial(F.material)
				else
					var/datum/material/M = getMaterial("steel")
					B.setMaterial(M)
			F.ReplaceWithSpace()
			log_construction(user, "removes flooring ([A])")

		else if (istype(A, /obj/machinery/door/airlock)||istype(A, /obj/machinery/door/unpowered/wood))
			for(var/i in 1 to 3)
				if (prob(50))
					var/atom/movable/B = new /obj/item/raw_material/scrap_metal
					B.set_loc(get_turf(A))
					if (A.material)
						B.setMaterial(A.material)
					else
						var/datum/material/M = getMaterial("steel")
						B.setMaterial(M)

			log_construction(user, "deconstructs an airlock ([A])")
			qdel(A)

		else if (istype(A, /obj/structure/girder))
			var/atom/movable/B = new /obj/item/raw_material/scrap_metal(get_turf(A))

			if (A.material)
				B.setMaterial(A.material)
			else
				var/datum/material/M = getMaterial("steel")
				B.setMaterial(M)

			log_construction(user, "deconstructs a girder ([A])")
			qdel(A)

		else if (istype(A, /obj/window))
			for(var/i in 1 to 3)
				var/atom/movable/B = new /obj/item/raw_material/shard(get_turf(A))
				if (A.material)
					B.setMaterial(A.material)
				else
					var/datum/material/M = getMaterial("glass")
					B.setMaterial(M)
			log_construction(user, "deconstructs a ([A])")
			qdel(A)

		else if (istype(A, /obj/grille))
			var/atom/movable/B
			if(prob(20))
				B = new /obj/item/raw_material/scrap_metal(get_turf(A))

				if (A.material)
					B.setMaterial(A.material)
				else
					var/datum/material/M = getMaterial("steel")
					B.setMaterial(M)

			log_construction(user, "deconstructs a grille ([A])")
			qdel(A)

		else if (istype(A, /obj/lattice))
			var/atom/movable/B = new /obj/item/raw_material/scrap_metal
			B.set_loc(get_turf(A))
			if (A.material)
				B.setMaterial(A.material)
			else
				var/datum/material/M = getMaterial("steel")
				B.setMaterial(M)
			log_construction(user, "deconstructs a lattice ([A])")
			qdel(A)
		else if(isobj(A))
			var/obj/O = A
			if(O.deconstruct_flags)
				var/atom/movable/B
				var/scrap = 1
				scrap += HAS_ALL_FLAGS( O.deconstruct_flags, DECON_SCREWDRIVER)
				scrap += HAS_ALL_FLAGS( O.deconstruct_flags, DECON_WRENCH)
				scrap += HAS_ALL_FLAGS( O.deconstruct_flags, DECON_CROWBAR)
				scrap += HAS_ALL_FLAGS( O.deconstruct_flags, DECON_WELDER) * 2
				if(O.deconstruct_flags & DECON_WIRECUTTERS)
					new /obj/item/cable_coil/cut/small(get_turf(A))
				for(var/i in 1 to scrap)
					B = new /obj/item/raw_material/scrap_metal(get_turf(A))
					if (A.material)
						B.setMaterial(A.material)
					else
						var/datum/material/M = getMaterial("steel")
						B.setMaterial(M)
				log_construction(user, "deconstructs a ([A])")
				qdel(A)

	proc/log_construction(mob/user as mob, var/what)
		logTheThing(LOG_STATION, user, "[what] using \the [src] at [user.loc.loc] ([log_loc(user)])")

	proc/use_power(watts)
		if(watts == 0 || !(SEND_SIGNAL(src, COMSIG_CELL_USE, watts) & CELL_INSUFFICIENT_CHARGE))
			. = TRUE

	proc/check_power(watts)
		if(watts == 0 || !(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, watts) & CELL_INSUFFICIENT_CHARGE))
			return TRUE

/datum/action/bar/private/welding/salvage

	onUpdate()
		if(QDELETED(target))
			interrupt(INTERRUPT_ALWAYS)
			return
		..()
		if(istype(target, /turf/simulated/wall))
			var/turf/simulated/wall/W = target
			W.health -= 5
			if (istype(W, /turf/simulated/wall/r_wall) || istype(W, /turf/simulated/wall/auto/reinforced))
				W.health -= 5
		else if(istype(target, /obj/grille))
			var/obj/grille/the_grille = target
			the_grille.health -= 5

		var/obj/item/salvager/S = src.call_proc_on
		if(istype(S))
			if(!S.use_power(1))
				resumable = FALSE
				interrupt(INTERRUPT_ALWAYS)
				boutput(owner,"\The [S] is out of power!")

		if(!ON_COOLDOWN(S,"welding_sound", rand(5 SECONDS, 10 SECONDS)))
			playsound(owner, list('sound/items/Welder.ogg', 'sound/items/Welder2.ogg')[1], 20, 1)

	onDelete()
		var/obj/item/salvager/S = src.call_proc_on
		if(istype(S))
#ifdef SECRETS_ENABLED
			S.icon_state = "salvager"
			S.item_state = "salvager"
#endif
			var/mob/M = owner
			if(istype(M))
				M.update_inhands()
		..()

/obj/item/storage/box/salvager_frame_compartment
	name = "electronics frame compartment"
	desc = "A special compartment designed to neatly and safely store deconstructed electronics and machinery frames."
	max_wclass = W_CLASS_HUGE
	can_hold = list(/obj/item/electronics/frame)
	slots = 8

	attack_hand(mob/user)
		if (src.stored)
			src.stored.hide_hud(user)
			// in case its somehow attacked without opening where its stored
			if (user.s_active)
				user.detach_hud(user.s_active)
				user.s_active = null
			src.storage.show_hud(user)
		else
			. = ..()

/obj/item/storage/backpack/salvager
	name = "salvager rucksack"
	desc = "A repurposed military backpack made of high density fabric, designed to fit a wide array of tools and junk."
	icon_state = "tactical_backpack"
	spawn_contents = list()
	slots = 10
	can_hold = list(/obj/item/electronics/frame, /obj/item/salvager)
	check_wclass = 1
	color = "#ff9933"
	satchel_compatible = FALSE

/obj/item/device/radio/headset/salvager
	protected_radio = 1 // Ops can spawn with the deaf trait.

/obj/salvager_putt_spawner
	name = "syndiputt spawner"
	icon = 'icons/obj/ship.dmi'
	icon_state = "syndi_mini_spawn"
	New()
		..()
#ifdef UNDERWATER_MAP
		new/obj/machinery/vehicle/tank/minisub/salvsub(src.loc)
#else
		new/obj/machinery/vehicle/miniputt/armed/salvager(src.loc)
#endif
		qdel(src)

/obj/machinery/vehicle/tank/minisub/salvsub
	body_type = "minisub"
	icon_state = "whitesub_body"
	health = 150
	maxhealth = 150
	acid_damage_multiplier = 0.5
	init_comms_type = /obj/item/shipcomponent/communications/salvager
	color = list(-0.269231,0.75,3.73077,0.269231,-0.249999,-2.73077,1,0.5,0)

	New()
		..()
		name = "salvager minisub"
		Install(new /obj/item/shipcomponent/mainweapon/taser(src))
		Install(new /obj/item/shipcomponent/secondary_system/cargo(src))
		Install(new /obj/item/shipcomponent/secondary_system/lock/bioscan(src))

// MAGPIE Equipment
/obj/machinery/vehicle/miniputt/armed/salvager
	desc = "A repeatedly rebuilt and refitted pod.  Looks like it has seen some things."
	color = list(-0.269231,0.75,3.73077,0.269231,-0.249999,-2.73077,1,0.5,0)
	init_comms_type = /obj/item/shipcomponent/communications/salvager

	health = 250
	maxhealth = 250
	armor_score_multiplier = 0.7
	speed = 0.85

	New()
		..()
		src.lock = new /obj/item/shipcomponent/secondary_system/lock/bioscan(src)
		src.lock.ship = src
		src.components += src.lock
		myhud.update_systems()
		myhud.update_states()

/datum/manufacture/pod/armor_light/salvager
	name = "Salvager Pod Armor"
	item_requirements = list("metal_dense" = 30,
							 "conductive" = 20)
	item_outputs = list(/obj/item/podarmor/salvager)
	create = 1
	time = 20 SECONDS
	category = "Component"

/obj/item/podarmor/salvager
	name = "Salvager Pod Armor"
	desc = "Exterior plating for vehicle pods."
	icon = 'icons/obj/electronics.dmi'
	icon_state = "dbox"
	vehicle_types = list("/obj/structure/vehicleframe/puttframe" = /obj/machinery/vehicle/miniputt/armed/salvager,
						 "/obj/structure/vehicleframe/subframe" = /obj/machinery/vehicle/tank/minisub/salvsub )

/obj/item/shipcomponent/communications/salvager
	name = "Salvager Communication Array"
	desc = "A rats nest of cables and extra parts fashioned into a shipboard communicator."
	color = "#91681c"
	access_type = list(POD_ACCESS_SALVAGER)

	go_home()
		var/escape_planet
#ifdef UNDERWATER_MAP
		escape_planet = !isrestrictedz(ship.z)
#else
		escape_planet = !isnull(station_repair.station_generator) && (ship.z == Z_LEVEL_STATION)
#endif

		if(!escape_planet)
			return

		var/turf/target = get_home_turf()
		if(!src.active)
			boutput(usr, "[ship.ship_message("Sensors inactive! Unable to calculate trajectory!")]")
			return TRUE
		if(!target)
			boutput(usr, "[ship.ship_message("Sensor error! Unable to calculate trajectory!")]")
			return TRUE

		if(ship.engine.active)
			if(ship.engine.ready)
				//brake the pod, we must stop to calculate warp trajectory.
				if (istype(ship.movement_controller, /datum/movement_controller/pod))
					var/datum/movement_controller/pod/MCP = ship.movement_controller
					if (MCP.velocity_x != 0 || MCP.velocity_y != 0)
						boutput(usr, "[ship.ship_message("Ship must have ZERO relative velocity to calculate trajectory to destination!")]")
						playsound(src, 'sound/machines/buzz-sigh.ogg', 50)
						return TRUE
				else if (istype(ship.movement_controller, /datum/movement_controller/tank))
					var/datum/movement_controller/tank/MCT = ship.movement_controller
					if (MCT.input_x != 0 || MCT.input_y != 0)
						boutput(usr, "[ship.ship_message("Ship must have ZERO relative velocity (be stopped) to calculate trajectory destination!")]")
						playsound(src, 'sound/machines/buzz-sigh.ogg', 50)
						return TRUE


				ship.engine.warp_autopilot = 1
				boutput(usr, "[ship.ship_message("Charging engines for escape velocity! Overriding manual control!")]")

				var/health_perc = ship.health_percentage
				ship.going_home = FALSE
				sleep(5 SECONDS)

				if(ship.health_percentage < (health_perc - 30))
					boutput(usr, "[ship.ship_message("Trajectory calculation failure! Ship characteristics changed from calculations!")]")
				else if(ship.engine.active && ship.engine.ready && src.active)
					var/old_color = ship.color
					animate_teleport(ship)
					sleep(0.8 SECONDS)
					ship.set_loc(target)
					ship.color = old_color // revert color from teleport color-shift
				else
					boutput(usr, "[ship.ship_message("Trajectory calculation failure! Loss of systems!")]")

				ship.engine.ready = 0
				ship.engine.warp_autopilot = 0
				ship.engine.ready()
			else
				boutput(usr, "[ship.ship_message("Engine recharging! Unable to minimize trajectory error!")]")
		else
			boutput(usr, "[ship.ship_message("Engines inactive! Unable to calculate trajectory!")]")

		return TRUE

	get_home_turf()
		if((POD_ACCESS_SALVAGER in src.access_type) && length(landmarks[LANDMARK_SALVAGER_BEACON]))
			. = pick(landmarks[LANDMARK_SALVAGER_BEACON])

var/datum/magpie_manager/magpie_man = new
/datum/magpie_manager
	var/obj/npc/trader/salvager/magpie

	proc/setup()
		src.magpie = locate("M4GP13")


/obj/npc/trader/salvager
	name = "M4GP13 Salvage and Barter System"
	icon = 'icons/obj/trader.dmi'
	icon_state = "crate_dispenser"
	picture = "generic.png"
	angrynope = "Unable to process request."
	whotext = "I am the salvage reclamation and supply commissary.  In short I will provide goods in exchange for reclaimed materials and equipment."
	barter = TRUE
	currency = "Salvage Points"

	New()
		..()

		src.chat_text = new(null, src)

		for(var/sell_type in concrete_typesof(/datum/commodity/magpie/sell))
			src.goods_sell += new sell_type(src)

		for(var/buy_type in (concrete_typesof(/datum/commodity/magpie/buy) - concrete_typesof(/datum/commodity/magpie/buy/random_buy)))
			src.goods_buy += new buy_type(src)

		greeting= {"[src.name]'s light flash, and he states, \"Greetings, welcome to my shop. Please select from my available equipment.\""}

		sell_dialogue = "[src.name] states, \"There are several individuals in my database that are looking to procure goods."

		buy_dialogue = "[src.name] states,\"Please select what you would like to buy\"."

		successful_sale_dialogue = list("[src.name] states, \"Thank you for the business organic.\"",
			"[src.name], \"I am adding you to the Good Customer Database.\"")

		failed_sale_dialogue = list("[src.name] states, \"<ERROR> Item not in purchase database.\"",
			"[src.name] states, \"I'm sorry I currently have no interest in that item, perhaps you should try another trader.\"",
			"[src.name] starts making a loud and irritating noise. [src.name] states, \"Fatal Exception Error: Cannot locate item\"",
			"[src.name] states, \"Invalid Input\"")

		successful_purchase_dialogue = list("[src.name] states, \"Thank you for your business\".",
			"[src.name] states, \"Looking forward to future transactions\".")

		failed_purchase_dialogue = list("[src.name] states, \"I am sorry, but you currenty do not have enough funds to purchase this.\"",
			"[src.name] states, \"Funds not found.\"")

		pickupdialogue = "[src.name] states, \"Thank you for your business. Please come again\"."

		pickupdialoguefailure = "[src.name] states, \"I'm sorry, but you don't have anything to pick up\"."

	var/list/speakverbs = list("beeps", "boops")
	var/static/mutable_appearance/bot_speech_bubble = mutable_appearance('icons/mob/mob.dmi', "speech")
	var/bot_speech_color

	proc/speak(var/message, var/sing, var/just_float, var/just_chat)
		if (!message)
			return
		var/image/chat_maptext/chatbot_text = null
		if (src.chat_text && !just_chat)
			UpdateOverlays(bot_speech_bubble, "bot_speech_bubble")
			SPAWN(1.5 SECONDS)
				UpdateOverlays(null, "bot_speech_bubble")
			if(!src.bot_speech_color)
				var/num = hex2num(copytext(md5("[src.name][TIME]"), 1, 7))
				src.bot_speech_color = hsv2rgb(num % 360, (num / 360) % 10 + 18, num / 360 / 10 % 15 + 85)
			var/maptext_color
			if (sing)
				maptext_color ="#D8BFD8"
			else
				maptext_color = src.bot_speech_color
			chatbot_text = make_chat_maptext(src, message, "color: [maptext_color];")
			if(chatbot_text && src.chat_text && length(src.chat_text.lines))
				chatbot_text.measure(src)
				//hack until measure is unfucked
				chatbot_text.measured_height = 20
				for(var/image/chat_maptext/I in src.chat_text.lines)
					if(I != chatbot_text)
						I.bump_up(chatbot_text.measured_height)

		src.audible_message(SPAN_SAY("[SPAN_NAME("[src]")] [pick(src.speakverbs)], \"[message]\""), just_maptext = just_float, assoc_maptext = chatbot_text)
		playsound(src, 'sound/misc/talk/bottalk_1.ogg', 40, TRUE)


// Stubs for the public
/obj/item/clothing/suit/space/salvager
/obj/item/clothing/head/helmet/space/engineer/salvager
/obj/item/clothing/glasses/salvager
#ifndef SECRETS_ENABLED
	icon_state = "construction"
	item_state = "construction"
#endif
/obj/salvager_cryotron
/obj/item/salvager_hand_tele
/obj/item/device/pda2/salvager

ABSTRACT_TYPE(/datum/commodity/magpie/sell)
/datum/commodity/magpie/sell
ABSTRACT_TYPE(/datum/commodity/magpie/buy)
/datum/commodity/magpie/buy
ABSTRACT_TYPE(/datum/commodity/magpie/buy/random_buy)
/datum/commodity/magpie/buy/random_buy
