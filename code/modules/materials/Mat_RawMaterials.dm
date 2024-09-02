/obj/item/material
	name = "construction materials"
	desc = "placeholder item!"
	icon = 'icons/obj/materials.dmi'
	icon_state = "ore"
	force = 4
	throwforce = 6
	var/material_name = "Ore" //text to display for this ore in manufacturers
	var/initial_material_name = null // used to store what the ore is
	var/metal = 0  // what grade of metal is it?
	var/conductor = 0
	var/dense = 0
	var/crystal = 0
	var/powersource = 0
	var/scoopable = 1
	burn_type = 1
	var/wiggle = 6 // how much we want the sprite to be deviated fron center
	max_stack = 50
	event_handler_flags = USE_FLUID_ENTER
	/// Does the raw material item get its name set?
	mat_changename = FALSE
	uses_default_material_appearance = TRUE
	default_material = null

	New()
		..()
		src.pixel_x = rand(0 - wiggle, wiggle)
		src.pixel_y = rand(0 - wiggle, wiggle)
		setup_material()
		if(src.material?.getName())
			initial_material_name = src.material.getName()

	proc/setup_material() // Overwrite for ore specific setup
		return

	_update_stack_appearance()
		if(material)
			UpdateName(src) // get the name in order so it has whatever it needs
			name = "[amount] [src.name][amount > 1 ? "s":""]"
		return

	attackby(obj/item/W, mob/user)
		if(check_valid_stack(W))
			stack_item(W)
			if(!user.is_in_hands(src))
				user.put_in_hand(src)
			boutput(user, SPAN_NOTICE("You add the ores to the stack. It now has [src.amount] ores."))
			return
		if (istype(W, /obj/item/satchel/mining/))
			var/obj/item/satchel/mining/manipulated_satchel = W
			if (!manipulated_satchel.check_valid_content(src))
				boutput(user, SPAN_ALERT("[manipulated_satchel] cannot hold that kind of item!"))
				return
			if (length(manipulated_satchel.contents) < manipulated_satchel.maxitems)
				var/max_stack_reached = FALSE
				if (src.amount > 1)
					boutput(user, SPAN_NOTICE("You begin to fill [manipulated_satchel] with [src]."))
					var/amount_of_stack_splits = manipulated_satchel.split_stack_into_satchel(src, user)
					if (amount_of_stack_splits == manipulated_satchel.max_stack_scoop)
						max_stack_reached = TRUE
				else
					boutput(user, SPAN_NOTICE("You put [src] in [manipulated_satchel]."))
				if (!max_stack_reached && (length(manipulated_satchel.contents) < manipulated_satchel.maxitems)) // if we split up the item and it was more than the satchel can find we should not add the rest
					user.u_equip(src)
					src.set_loc(manipulated_satchel)
					src.dropped(user)
				if (length(manipulated_satchel.contents) == manipulated_satchel.maxitems)
					boutput(user, SPAN_NOTICE("[W] is now full!"))
				manipulated_satchel.tooltip_rebuild = 1
				manipulated_satchel.UpdateIcon()
			else
				boutput(user, SPAN_ALERT("[manipulated_satchel] is full!"))
			return
		..()

	attack_hand(mob/user)
		if(user.is_in_hands(src) && src.amount > 1)
			var/splitnum = round(input("How many ores do you want to take from the stack?","Stack of [src.amount]",1) as num)
			if (splitnum >= amount || splitnum < 1 || !isnum_safe(splitnum))
				boutput(user, SPAN_ALERT("Invalid entry, try again."))
				return
			var/obj/item/material/new_stack = split_stack(splitnum)
			user.put_in_hand_or_drop(new_stack)
			new_stack.add_fingerprint(user)
		else
			..(user)

	Crossed(atom/movable/AM as mob|obj)
		..()
		if (isobserver(AM))
			return
		else if (isliving(AM))
			var/mob/living/H = AM
			var/obj/item/ore_scoop/S = H.get_equipped_ore_scoop()
			if (S?.satchel && length(S.satchel.contents) < S.satchel.maxitems && (src.scoopable || S.collect_junk) && S.satchel.check_valid_content(src))
				var/max_stack_reached = FALSE
				if (src.amount > 1)
					var/increment = 0
					//since we need to add additional manipulation to the item in hand, we won't touch the last item here
					var/amount_of_stack_splits = min(S.satchel.maxitems - length(S.satchel.contents), src.amount - 1, S.satchel.max_stack_scoop)
					if (amount_of_stack_splits == S.satchel.max_stack_scoop)
						max_stack_reached = TRUE
					for (increment = 0, increment < amount_of_stack_splits, increment++)
						var/obj/item/splitted_stack = src.split_stack(1)
						splitted_stack.set_loc(S.satchel)
				if (!max_stack_reached && (length(S.satchel.contents) < S.satchel.maxitems))
					src.set_loc(S.satchel)  // if we split up the item and it was more than the satchel can find we should not add the rest
				S.satchel.UpdateIcon()
				if (length(S.satchel.contents) >= S.satchel.maxitems)
					boutput(H, SPAN_ALERT("Your ore scoop's satchel is full!"))
					playsound(H, 'sound/machines/chime.ogg', 20, TRUE)
		else if (istype(AM,/obj/machinery/vehicle/))
			var/obj/machinery/vehicle/V = AM
			if (istype(V.sec_system,/obj/item/shipcomponent/secondary_system/orescoop))
				var/obj/item/shipcomponent/secondary_system/orescoop/SCOOP = V.sec_system
				if (length(SCOOP.contents) >= SCOOP.capacity || !src.scoopable)
					return
				var/max_stack_reached = FALSE
				if (src.amount > 1)
					var/increment = 0
					//since we need to add additional manipulation to the item in hand, we won't touch the last item here
					var/amount_of_stack_splits = min(SCOOP.capacity - length(SCOOP.contents), src.amount - 1, SCOOP.max_stack_scoop)
					if (amount_of_stack_splits == SCOOP.max_stack_scoop)
						max_stack_reached = TRUE
					for (increment = 0, increment < amount_of_stack_splits, increment++)
						var/obj/item/splitted_stack = src.split_stack(1)
						splitted_stack.set_loc(SCOOP)
				if (!max_stack_reached && (length(SCOOP.contents) < SCOOP.capacity)) // if we split up the item and it was more than the satchel can find we should not add the rest
					src.set_loc(SCOOP)
				if (length(SCOOP.contents) >= SCOOP.capacity)
					boutput(V.pilot, SPAN_ALERT("Your pod's ore scoop hold is full!"))
					playsound(V.loc, 'sound/machines/chime.ogg', 20, 1)
			return
		else
			return

	mouse_drop(atom/over_object, src_location, over_location) //src dragged onto over_object
		if (isobserver(usr))
			boutput(usr, SPAN_ALERT("Quit that! You're dead!"))
			return

		if(!istype(over_object, /atom/movable/screen/hud))
			if (BOUNDS_DIST(usr, src) > 0)
				boutput(usr, SPAN_ALERT("You're too far away from it to do that."))
				return
			if (BOUNDS_DIST(usr, over_object) > 0)
				boutput(usr, SPAN_ALERT("You're too far away from it to do that."))
				return

		if(istype(over_object, /obj/machinery/power/furnace))
			return ..()

		if(istype(over_object, /obj/afterlife_donations))
			return ..()

		if (istype(over_object,/obj/item/material) && isturf(over_object.loc)) //piece to piece only if on ground
			var/obj/item/targetObject = over_object
			if(targetObject.stack_item(src))
				usr.visible_message(SPAN_NOTICE("[usr.name] stacks \the [src]!"))
		else if(isturf(over_object)) //piece to turf. piece loc doesnt matter.
			if(src.amount > 1) //split stack.
				usr.visible_message(SPAN_NOTICE("[usr.name] splits the stack of [src]!"))
				var/toSplit = round(amount / 2)
				var/atom/movable/splitStack = split_stack(toSplit)
				if(splitStack)
					splitStack.set_loc(over_object)
			else
				if(isturf(src.loc))
					src.set_loc(over_object)
				for(var/obj/item/I in view(1,usr))
					if (!I || I == src)
						continue
					if (!src.check_valid_stack(I))
						continue
					src.stack_item(I)
				usr.visible_message(SPAN_NOTICE("[usr.name] stacks \the [src]!"))
		else if(istype(over_object, /atom/movable/screen/hud))
			var/atom/movable/screen/hud/H = over_object
			var/mob/living/carbon/human/dude = usr
			switch(H.id)
				if("lhand")
					if(dude.l_hand)
						if(dude.l_hand == src) return
						else if (istype(dude.l_hand, /obj/item/material))
							var/obj/item/material/DP = dude.l_hand
							DP.stack_item(src)
							usr.visible_message(SPAN_NOTICE("[usr.name] stacks \the [DP]!"))
					else if(amount > 1)
						var/toSplit = round(amount / 2)
						var/atom/movable/splitStack = split_stack(toSplit)
						if(splitStack)
							usr.visible_message(SPAN_NOTICE("[usr.name] splits the stack of [src]!"))
							splitStack.set_loc(dude)
							dude.put_in_hand(splitStack, 1)
				if("rhand")
					if(dude.r_hand)
						if(dude.r_hand == src) return
						else if (istype(dude.r_hand, /obj/item/material))
							var/obj/item/material/DP = dude.r_hand
							DP.stack_item(src)
							usr.visible_message(SPAN_NOTICE("[usr.name] stacks \the [DP]!"))
					else if(amount > 1)
						var/toSplit = round(amount / 2)
						var/atom/movable/splitStack = split_stack(toSplit)
						if(splitStack)
							usr.visible_message(SPAN_NOTICE("[usr.name] splits the stack of [src]!"))
							splitStack.set_loc(dude)
							dude.put_in_hand(splitStack, 0)
		else
			..()

/obj/item/material/block
	// crystal, rubber
	name = "block"
	icon_state = "block"
	desc = "A nicely cut square brick."

/obj/item/material/wad
	// organic
	icon_state = "wad"
	name = "clump"
	desc = "A clump of some kind of material."

/obj/item/material/wad/blob
		name = "chunk of blob"
		default_material = "blob"
		mat_changename = FALSE

/obj/item/material/wad/blob/random
	var/static/list/random_blob_materials = null
	New()
		. = ..()
		if (!src.random_blob_materials)
			src.random_blob_materials = list()
			var/datum/material/base_mat = getMaterial("blob")
			for (var/i in 1 to 10)
				var/datum/material/new_mat = base_mat.getMutable()
				new_mat.setColor(rgb(rand(1,255), rand(1,255), rand(1,255), 255))
				src.random_blob_materials += new_mat
		src.setMaterial(pick(src.random_blob_materials))

/obj/item/material/sphere
	// energy
	icon_state = "sphere"
	name = "sphere"
	desc = "A weird sphere of some kind."

/obj/item/material/cloth
	// fabric
	icon_state = "fabric"
	name = "fabric"
	desc = "A weave of some kind."
	var/in_use = 0

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		if (user.a_intent == INTENT_GRAB)
			return ..()
		if (src.in_use)
			return ..()
		if (ishuman(target))
			var/mob/living/carbon/human/H = target
			var/zone = user.zone_sel.selecting
			var/surgery_status = H.get_surgery_status(zone)
			if (surgery_status && H.organHolder)
				actions.start(new /datum/action/bar/icon/medical_suture_bandage(H, src, 15, zone, surgery_status, rand(1,4), Vrb = "bandag"), user)
				src.in_use = 1
			else if (H.bleeding)
				actions.start(new /datum/action/bar/icon/medical_suture_bandage(H, src, 20, zone, 0, rand(2,4), Vrb = "bandag"), user)
				src.in_use = 1
			else
				user.show_text("[H == user ? "You have" : "[H] has"] no wounds or incisions on [H == user ? "your" : his_or_her(H)] [zone_sel2name[zone]] to bandage!", "red")
				src.in_use = 0
				return
		else
			return ..()

	afterattack(turf/simulated/A, mob/user)
		if(locate(/obj/decal/poster/banner, A))
			return
		else if(istype(A, /turf/simulated/wall/))
			var/obj/decal/poster/banner/B = new(A)
			if (src.material) B.setMaterial(src.material)
			logTheThing(LOG_STATION, user, "Hangs up a banner (<b>Material:</b> [B.material && B.material.getID() ? "[B.material.getID()]" : "*UNKNOWN*"]) in [A] at [log_loc(user)].")
			src.change_stack_amount(-1)
			user.visible_message(SPAN_NOTICE("[user] hangs up a [B.name] in [A]!."), SPAN_NOTICE("You hang up a [B.name] in [A]!"))

/obj/item/material/rock
	name = "rock"
	desc = "It's plain old space rock. Pretty worthless!"
	icon_state = "rock1"
	force = 8
	throwforce = 10
	scoopable = 0
	material_name = "Rock"
	default_material = "rock"

	setup_material()
		..()
		src.icon_state = pick("rock1","rock2","rock3")

/obj/item/material/mauxite
	name = "mauxite ore"
	desc = "A chunk of Mauxite, a sturdy common metal."
	material_name = "Mauxite"
	default_material = "mauxite"
	metal = 2

/obj/item/material/molitz
	name = "molitz crystal"
	desc = "A crystal of Molitz, a common crystalline substance."
	material_name = "Molitz"
	default_material = "molitz"
	crystal = 1

	var/molitzBubbles = 4
	var/doAgentB = FALSE

	temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
		..()
		if(exposed_temperature < 500 KELVIN)
			return
		if(src.molitzBubbles < 1)
			return
		if(ON_COOLDOWN(src, "molitz_gas_generate", 30 SECONDS))
			return
		src.doGasReaction(air, exposed_temperature)

	proc/doGasReaction(datum/gas_mixture/air, var/temperature)
		var/datum/gas_mixture/payload = new /datum/gas_mixture
		if(src.doAgentB && air.toxins > MINIMUM_REACT_QUANTITY)
			payload.oxygen_agent_b = 0.18
			payload.oxygen = 15
			payload.temperature = T0C
			animate_flash_color_fill_inherit(src,"#ff0000", 4, 2 SECONDS)
			playsound(src, 'sound/effects/leakagentb.ogg', 50, TRUE, 8)
			if(!particleMaster.CheckSystemExists(/datum/particleSystem/sparklesagentb, src))
				particleMaster.SpawnSystem(new /datum/particleSystem/sparklesagentb(src))
		else //not molitz B or doesnt meet the requirements to make agent B
			payload.oxygen = 80
			payload.temperature = temperature
			animate_flash_color_fill_inherit(src,"#0000FF", 4, 2 SECONDS)
			playsound(src, 'sound/effects/leakoxygen.ogg', 50, TRUE, 5)
		air.merge(payload)
		src.molitzBubbles--

/obj/item/material/molitz/beta
	name = "molitz β crystal"
	desc = "An unusual crystal of Molitz."
	icon_state = "ore$$molitz_b"
	material_name = "Molitz Beta"
	default_material = "molitz_b"
	crystal = 1
	doAgentB = TRUE

	setup_material()
		. = ..()
		src.pressure_resistance = INFINITY //has to be after material setup. REASONS

/obj/item/material/pharosium
	name = "pharosium ore"
	desc = "A chunk of Pharosium, a conductive metal."
	material_name = "Pharosium"
	default_material = "pharosium"
	metal = 1
	conductor = 1

/obj/item/material/cobryl // relate this to precursors
	name = "cobryl ore"
	desc = "A chunk of Cobryl, a somewhat valuable metal."
	material_name = "Cobryl"
	default_material = "cobryl"
	metal = 1

/obj/item/material/char
	name = "char ore"
	desc = "A heap of Char, a fossil energy source similar to coal."
	material_name = "Char"
	default_material = "char"
	//cogwerks - burn vars
	burn_point = 450
	burn_output = 1600
	burn_possible = TRUE
	health = 20

/obj/item/material/claretine // relate this to wizardry somehow
	name = "claretine ore"
	desc = "A heap of Claretine, a highly conductive salt."
	material_name = "Claretine"
	default_material = "claretine"
	conductor = 2

/obj/item/material/bohrum
	name = "bohrum ore"
	desc = "A chunk of Bohrum, a heavy and highly durable metal."
	material_name = "Bohrum"
	default_material = "bohrum"
	metal = 3
	dense = 1

/obj/item/material/syreline
	name = "syreline ore"
	desc = "A chunk of Syreline, an extremely valuable and coveted metal."
	material_name = "Syreline"
	default_material = "syreline"
	metal = 1

/obj/item/material/erebite
	name = "erebite ore"
	desc = "A chunk of Erebite, an extremely volatile high-energy mineral."
	var/exploded = 0
	material_name = "Erebite"
	default_material = "erebite"
	powersource = 2

	ex_act(severity)
		if(exploded)
			return
		exploded = 1/*
		for(var/obj/item/material/erebite/E in get_turf(src))
			if(E == src) continue
			qdel(E)

		for(var/obj/item/material/erebite/E in range(4,src))
			if (E == src) continue
			qdel(E)*/

		switch(severity)
			if(1)
				explosion(src, src.loc, 1, 2, 3, 4)
			if(2)
				explosion(src, src.loc, 0, 1, 2, 3)
			if(3)
				explosion(src, src.loc, 0, 0, 1, 2)
			else
				return
		// if not on mining z level
		if (src.z != MINING_Z)
			var/turf/bombturf = get_turf(src)
			if (bombturf)
				var/bombarea = bombturf.loc.name
				logTheThing(LOG_BOMBING, null, "Erebite detonated by an explosion in [bombarea] ([log_loc(bombturf)]). Last touched by: [src.fingerprintslast]")
				if (src.fingerprintslast && !istype(get_area(bombturf), /area/mining/magnet))
					message_admins("Erebite detonated by an explosion in [bombarea] ([log_loc(bombturf)]). Last touched by: [key_name(src.fingerprintslast)]")

		qdel(src)

	temperature_expose(null, temp, volume)

		explosion(src, src.loc, 1, 2, 3, 4)

		// if not on mining z level
		if (src.z != MINING_Z)
			var/turf/bombturf = get_turf(src)
			var/bombarea = istype(bombturf) ? bombturf.loc.name : "a blank, featureless void populated only by your own abandoned dreams and wasted potential"

			logTheThing(LOG_BOMBING, null, "Erebite detonated by heat in [bombarea]. Last touched by: [src.fingerprintslast]")
			if(src.fingerprintslast && !istype(get_area(bombturf), /area/mining/magnet))
				message_admins("Erebite detonated by heat in [bombarea]. Last touched by: [key_name(src.fingerprintslast)]")

		qdel(src)

/obj/item/material/cerenkite
	name = "cerenkite ore"
	desc = "A chunk of Cerenkite, a highly radioactive mineral."
	material_name = "Cerenkite"
	default_material = "cerenkite"
	metal = 1
	powersource = 1

/obj/item/material/plasmastone
	name = "plasmastone"
	desc = "A piece of plasma in its solid state."
	material_name = "Plasmastone"
	default_material = "plasmastone"
	//cogwerks - burn vars
	burn_point = 1000
	burn_output = 10000
	burn_possible = TRUE
	health = 40
	powersource = 1
	crystal = 1

	var/plasmaBubbles = 10

	material_trigger_when_attacked(atom/attackatom, mob/attacker, meleeorthrow, situation_modifier)
		..()
		var/turf/simulated/floor/T = get_turf(src)
		if(!istype(T))
			return
		src.tryGasReaction(T.air)

	temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
		..()
		if(exposed_temperature < 500 KELVIN)
			return
		src.tryGasReaction(air)

	proc/tryGasReaction(datum/gas_mixture/air)
		if(src.plasmaBubbles < 1)
			return
		if(ON_COOLDOWN(src, "plasmastone_plasma_generate", 5 SECONDS))
			return
		src.doGasReaction(air)

	proc/doGasReaction(datum/gas_mixture/air)
		var/datum/gas_mixture/payload = new /datum/gas_mixture
		payload.toxins = 25
		payload.temperature = T20C
		animate_flash_color_fill_inherit(src,"#ff00ff", 4, 2 SECONDS)
		playsound(src, 'sound/effects/leakoxygen.ogg', 50, TRUE, 5)
		air.merge(payload)
		src.plasmaBubbles--

/obj/item/material/gemstone
	name = "gem"
	desc = "A gemstone. It's probably pretty valuable!"
	icon_state = "gem1"
	material_name = "Gem"
	default_material = null
	mat_changename = TRUE
	force = 1
	throwforce = 3
	crystal = 1

	setup_material()
		..()
		src.icon_state = pick("gem1","gem2","gem3")
		var/picker = rand(1,100)
		var/list/picklist
		switch(picker)
			if(1 to 10)
				picklist = list("diamond","ruby","topaz","emerald","sapphire","amethyst")
			if(11 to 40)
				picklist = list("jasper","garnet","peridot","malachite","lapislazuli","alexandrite")
			else
				picklist = list("onyx","rosequartz","citrine","jade","aquamarine","iolite")

		var/datum/material/M = getMaterial(pick(picklist))
		src.setMaterial(M)
		src.icon_state = pick("gem1","gem2","gem3")

/obj/item/material/uqill // relate this to ancients
	name = "uqill nugget"
	desc = "A nugget of Uqill, a rare and very dense stone."
	material_name = "Uqill"
	default_material = "uqill"
	dense = 2

/obj/item/material/fibrilith
	name = "fibrilith chunk"
	desc = "A compressed chunk of Fibrilith, an odd mineral known for its high tensile strength."
	material_name = "Fibrilith"
	default_material = "fibrilith"

/obj/item/material/telecrystal
	name = "telecrystal"
	desc = "A large unprocessed telecrystal, a gemstone with space-warping properties."
	material_name = "Telecrystal"
	default_material = "telecrystal"
	crystal = 1
	powersource = 2

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		if(target == user)
			boutput(target, "<b class='alert'>You eat the [html_encode(src)]!</b>")
			boutput(target, "Nothing happens, though.")
			qdel(src)
		else if(istype(target))
			boutput(user, "<b class='alert'>You feed [html_encode(target)] the [html_encode(src)]!</b>")
			boutput(target, "<b class='alert'>[html_encode(user)] feeds you the [html_encode(src)]!</b>")
			boutput(target, "Nothing happens, though.")
			boutput(user, "Nothing happens, though.")
			qdel(src)
		else return ..()
		return
	var/emagged = 0
	emag_act()
		if(emagged) return
		src.visible_message( "<b class='notice'>\the [src] turns blue!</b>" )
		emagged = 1
		src.color = "#00f"
		name = "Blue Telecrystal"
		desc = "[desc] It's all shiny and blue now."
		return TRUE

/obj/item/material/miracle
	name = "miracle matter"
	desc = "Miracle Matter is a bizarre substance known to metamorphosise into other minerals when processed."
	material_name = "Miracle"
	default_material = "miracle"

/obj/item/material/starstone
	name = "starstone"
	desc = "An extremely rare jewel. Highly prized by collectors and lithovores."
	material_name = "Starstone"
	default_material = "starstone"
	crystal = 1

/obj/item/material/eldritch
	name = "koshmarite ore"
	desc = "An unusual dense pulsating stone. You feel uneasy just looking at it."
	material_name = "Koshmarite"
	default_material = "koshmarite"
	crystal = 1
	dense = 2

/obj/item/material/martian
	name = "viscerite lump"
	desc = "A disgusting flesh-like material. Ugh. What the hell is this?"
	material_name = "Viscerite"
	default_material = "viscerite"
	dense = 2

	setup_material()
		src.create_reagents(25)
		src.reagents.add_reagent("synthflesh", 25)
		return ..()

/obj/item/material/gold
	name = "gold nugget"
	desc = "A chunk of pure gold. Damn son."
	material_name = "Gold"
	default_material = "gold"
	dense = 2

// Misc building material

/// This has no material, why does it exist???? Someone replace it
/obj/item/material/fabric
	name = "fabric sheet"
	desc = "Some spun cloth. Useful if you want to make clothing."
	icon_state = "fabric"
	material_name = "Fabric"
	scoopable = 0

/obj/item/material/cotton
	name = "cotton wad"
	desc = "It's a big puffy white thing. Most likely not a cloud though."
	icon_state = "cotton"
	material_name = "Cotton"
	default_material = "cotton"

/obj/item/material/ice
	name = "ice chunk"
	desc = "A chunk of ice. It's pretty cold."
	material_name = "Ice"
	default_material = "ice"
	crystal = 1
	scoopable = 0

/obj/item/material/scrap_metal
	// this should only be spawned by the game, spawning it otherwise would just be dumb
	name = "scrap"
	desc = "Some twisted and ruined metal. It could probably be smelted down into something more useful."
	icon_state = "scrap"
	stack_type = /obj/item/material/scrap_metal
	burn_possible = FALSE
	mat_changename = TRUE
	material_name = "Steel"
	default_material = "steel"

	New()
		..()
		icon_state += "[rand(1,5)]"

/obj/item/material/shard
	// same deal here
	name = "shard"
	desc = "A jagged piece of broken crystal or glass. It could probably be smelted down into something more useful."
	icon_state = "shard"
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	item_state = "shard-glass"
	stack_type = /obj/item/material/shard
	object_flags = NO_GHOSTCRITTER
	tool_flags = TOOL_CUTTING
	w_class = W_CLASS_NORMAL
	hit_type = DAMAGE_CUT
	hitsound = 'sound/impact_sounds/Flesh_Stab_1.ogg'
	force = 5
	throwforce = 5
	g_amt = 3750
	burn_type = 1
	stamina_damage = 5
	stamina_cost = 5
	stamina_crit_chance = 35
	burn_possible = FALSE
	event_handler_flags = USE_FLUID_ENTER
	material_amt = 0.1
	material_name = "Glass"
	default_material = "glass"
	mat_changename = TRUE
	var/sound_stepped = 'sound/impact_sounds/Glass_Shards_Hit_1.ogg'

	New()
		..()
		icon_state += "[rand(1,3)]"
		src.setItemSpecial(/datum/item_special/double)

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		if(!scalpel_surgery(target,user)) return ..()
		else return

	Crossed(atom/movable/AM as mob|obj)
		if(ishuman(AM))
			walked_over(AM) // check if we need to hurt they feeties
		..()

	custom_suicide = 1
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		user.visible_message(SPAN_ALERT("<b>[user] slashes [his_or_her(user)] own throat with [src]!</b>"))
		blood_slash(user, 25)
		user.TakeDamage("head", 150, 0)
		SPAWN(50 SECONDS)
			if (user && !isdead(user))
				user.suiciding = 0
		return 1

	glass
		material_name = "Glass"
		default_material = "glass"

	plasmacrystal
		material_name = "Plasmaglass"
		default_material = "plasmaglass"

/obj/item/material/shard/proc/walked_over(mob/living/carbon/human/H as mob)
	if(ON_COOLDOWN(H, "shard_Crossed", 7 SECONDS) || H.getStatusDuration("stunned") || H.getStatusDuration("knockdown")) // nerf for dragging a person and a shard to damage them absurdly fast - drsingh
		return
	if(isabomination(H))
		return
	if(H.lying)
		boutput(H, SPAN_ALERT("<B>You crawl on [src]! Ouch!</B>"))
		step_on(H)
	else
		//Can't step on stuff if you have no legs, and it can't hurt if they're protected or not human parts.
		if (H.mutantrace?.can_walk_on_shards)
			return
		if (!istype(H.limbs?.l_leg, /obj/item/parts/human_parts) && !istype(H.limbs?.r_leg, /obj/item/parts/human_parts))
			return
		if(!H.shoes || (src.material && src.material.hasProperty(MATERIAL_PROPERTY_HARDNESS) && src.material.getProperty("hard") >= 7))
			boutput(H, SPAN_ALERT("<B>You step on [src]! Ouch!</B>"))
			step_on(H)

/obj/item/material/shard/proc/step_on(mob/living/carbon/human/H as mob)
	playsound(src.loc, src.sound_stepped, 50, 1)
	H.changeStatus("knockdown", 3 SECONDS)
	H.force_laydown_standup()
	var/zone = pick("l_leg", "r_leg")
	H.TakeDamage(zone, force, 0, 0, DAMAGE_CUT)

/obj/item/material/chitin
	name = "chitin chunk"
	desc = "A chunk of chitin."
	material_name = "Chitin"
	default_material = "chitin"
	metal = 3
	dense = 1

// bars, tied into the new material system

/obj/item/material/mauxite
	desc = "A processed bar of Mauxite, a sturdy common metal."
	default_material = "mauxite"
	icon_state = "bar"

/obj/item/material/molitz
	desc = "A cut block of Molitz, a common crystalline substance."
	default_material = "molitz"
	icon_state = "bar"

/obj/item/material/pharosium
	desc = "A processed bar of Pharosium, a conductive metal."
	default_material = "pharosium"
	icon_state = "bar"

/obj/item/material/cobryl
	desc = "A processed bar of Cobryl, a somewhat valuable metal."
	default_material = "cobryl"
	icon_state = "bar"

/obj/item/material/claretine
	desc = "A compressed Claretine, a highly conductive salt."
	default_material = "claretine"
	icon_state = "bar"

/obj/item/material/bohrum
	desc = "A processed bar of Bohrum, a heavy and highly durable metal."
	default_material = "bohrum"
	icon_state = "bar"

/obj/item/material/syreline
	desc = "A processed bar of Syreline, an extremely valuable and coveted metal."
	default_material = "syreline"
	icon_state = "bar"

/obj/item/material/plasmastone
	desc = "A cut block of Plasmastone."
	default_material = "plasmastone"
	icon_state = "bar"

/obj/item/material/uqill
	desc = "A cut block of Uqill. It is quite heavy."
	default_material = "uqill"
	icon_state = "bar"

/obj/item/material/koshmarite
	desc = "A cut block of an unusual dense stone. It seems similar to obsidian."
	default_material = "koshmarite"
	icon_state = "bar"

/obj/item/material/viscerite
	desc = "A cut block of a disgusting flesh-like material. Grody."
	default_material = "viscerite"
	icon_state = "bar"

/obj/item/material/char
	desc = "A cut block of Char."
	default_material = "char"
	icon_state = "wad"
	color = "#221122"

/obj/item/material/telecrystal
	desc = "A cut block of Telecrystal."
	default_material = "telecrystal"
	icon_state = "bar"

/obj/item/material/fibrilith
	desc = "A cut block of Fibrilith."
	default_material = "fibrilith"
	icon_state = "bar"

/obj/item/material/cerenkite
	desc = "A cut block of Cerenkite."
	default_material = "cerenkite"
	icon_state = "bar"

/obj/item/material/erebite
	desc = "A cut block of Erebite."
	default_material = "erebite"
	icon_state = "bar"

/obj/item/material/ice
	desc = "Uh. What's the point in this? Is someone planning to make an igloo?"
	default_material = "ice"

/// The metal appearance and stuff is on the parent, this is just a concrete subtype
/obj/item/material/metal
/obj/item/material/fart
	icon_state = "fart"
	name = "frozen fart"
	desc = "Remarkable! The cold temperatures in the freezer have frozen the fart in mid-air."
	amount = 5
	default_material = "frozenfart"
	mat_changename = FALSE
	uses_default_material_appearance = FALSE

/obj/item/material/steel
	desc = "A processed bar of Steel, a common metal."
	default_material = "steel"
	icon_state = "bar"
	default_material = "steel"

/obj/item/material/hamburgris
	name = "clump"
	desc = "A big clump of petrified mince, with a horrific smell."
	default_material = "hamburgris"
	icon_state = "wad"

/obj/item/material/glass
	desc = "A cut block of glass, a common crystalline substance."
	default_material = "glass"
	icon_state = "block"

/obj/item/material/copper
	desc = "A processed bar of copper, a conductive metal."
	default_material = "copper"
	icon_state = "bar"

/obj/item/material/iridiumalloy
	icon_state = "iridium"
	name = "plate"
	desc = "A chunk of some sort of iridium alloy plating."
	default_material = "iridiumalloy"
	uses_default_material_appearance = FALSE
	amount = 5

/obj/item/material/spacelag
	icon_state = "bar"
	desc = "Yep. There it is. You've done it. I hope you're happy now."
	default_material = "spacelag"
	amount = 1

/obj/item/material/slag
	icon_state = "wad"
	name = "slag"
	desc = "By-product of smelting"
	default_material = "slag"
	mat_changename = FALSE

ABSTRACT_TYPE(/obj/item/material/rubber)
/obj/item/material/rubber/latex
	name = "latex sheet"
	desc = "A sheet of latex."
	icon_state = "latex"
	default_material = "latex"

	setup_material()
		src.create_reagents(10)
		reagents.add_reagent("rubber", 10)
		return ..()

/obj/item/material/rubber/plastic
	name = "plastic sheet"
	icon_state = "latex"
	desc = "A sheet of plastic."
	default_material = "plastic"

/obj/item/material/organic/wood
	name = "wooden log"
	desc = "Years of genetic engineering mean timber always comes in mostly perfectly shaped cylindrical logs."
	icon_state = "log"
	default_material = "wood"
	uses_default_material_appearance = FALSE
	mat_changename = FALSE

	attackby(obj/item/W, mob/user)
		if ((istool(W, TOOL_CUTTING | TOOL_SAWING)))
			user.visible_message("[user] cuts a plank from the [src].", "You cut a plank from the [src].")
			new /obj/item/sheet/wood(user.loc)
			if (src.amount > 1)
				change_stack_amount(-1)
			else
				qdel (src)
		else
			..()

/obj/item/material/organic/bamboo
	name = "stalk"
	desc = "Keep away from Space Pandas."
	icon_state = "bamboo"
	default_material = "bamboo"
	uses_default_material_appearance = FALSE
	mat_changename = TRUE

	attackby(obj/item/W, mob/user)
		if ((istool(W, TOOL_CUTTING | TOOL_SAWING)))
			user.visible_message("[user] carefully extracts a shoot from [src].", "You carefully cut a shoot from [src], leaving behind some usable building material.")
			new /obj/item/reagent_containers/food/snacks/plant/bamboo/(user.loc)
			new /obj/item/sheet/bamboo(user.loc)
			if (src.amount > 1)
				change_stack_amount(-1)
			else
				qdel (src)
		else
			..()

/obj/item/material/cloth/spidersilk
	name = "space spider silk"
	desc = "space silk produced by space dwelling space spiders. space."
	icon_state = "spidersilk"
	default_material = "spidersilk"
	uses_default_material_appearance = FALSE
	mat_changename = FALSE

/obj/item/material/cloth/leather
	name = "leather"
	desc = "leather made from the skin of some sort of space critter."
	icon_state = "fabric"
	default_material = "leather"
	mat_changename = FALSE

/obj/item/material/cloth/synthleather
	name = "synthleather"
	desc = "A type of artificial leather."
	icon_state = "fabric"
	default_material = "synthleather"
	mat_changename = FALSE

/obj/item/material/cloth/cottonfabric
	name = "fabric"
	desc = "A type of natural fabric."
	icon_state = "fabric"
	default_material = "cotton"

/obj/item/material/cloth/jean
	name = "jean textile"
	desc = "A type of a sturdy textile."
	icon_state = "fabric"
	default_material = "jean"
	mat_changename = FALSE

/obj/item/material/cloth/brullbarhide
	name = "brullbar hide"
	desc = "The hide of a brullbar."
	icon_state = "fabric"
	default_material = "brullbarhide"
	mat_changename = FALSE

/obj/item/material/cloth/kingbrullbarhide
	name = "king brullbar hide"
	desc = "The hide of a king brullbar."
	icon_state = "fabric"
	default_material = "kingbrullbarhide"
	mat_changename = FALSE

/obj/item/material/cloth/carbon
	name = "fabric"
	desc = "carbon based hi-tech material."
	icon_state = "fabric"
	default_material = "carbonfibre"

/obj/item/material/cloth/dyneema
	name = "fabric"
	desc = "carbon nanofibres and space spider silk!"
	icon_state = "fabric"
	default_material = "dyneema"

/obj/item/material/cloth/hauntium
	name = "fabric"
	desc = "This cloth seems almost alive."
	icon_state = "fabric"
	default_material = "hauntium"

/obj/item/material/cloth/beewool
	name = "bee wool"
	desc = "Some bee wool."
	icon_state = "fabric"
	default_material = "beewool"
	mat_changename = FALSE

/obj/item/material/cloth/carpet
	name = "carpet"
	desc = "Some grimy carpet."
	icon_state = "fabric"
	default_material = "carpet"

/obj/item/material/soulsteel
	desc = "A bar of soulsteel. Metal made from souls."
	icon_state = "bar"
	default_material = "soulsteel"

/obj/item/material/metal/censorium
	desc = "A bar of censorium. Nice try."
	icon_state = "bar"
	default_material = "censorium"

/obj/item/material/bone
	name = "bits of bone"
	desc = "some bits and pieces of bones."
	icon_state = "scrap3"
	default_material = "bone"
	uses_default_material_appearance = FALSE
	mat_changename = FALSE

/obj/item/material/gnesis
	name = "wafer"
	desc = "A warm, pulsing block of weird alien computer crystal stuff."
	icon_state = "bar"
	default_material = "gnesis"

/obj/item/material/gnesisglass
	name = "wafer"
	desc = "A shimmering, translucent block of weird alien computer crystal stuff."
	icon_state = "bar"
	default_material = "gnesisglass"

/obj/item/material/coral
	name = "chunk"
	desc = "A piece of coral. Nice!"
	icon_state = "coral"
	default_material = "coral"
	uses_default_material_appearance = FALSE

/obj/item/material/neutronium
	desc = "Neutrons condensed into a solid form."
	icon_state = "bar"
	default_material = "neutronium"

/obj/item/material/plutonium
	desc = "Reprocessed nuclear fuel, refined into fissile isotopes."
	icon_state = "bar"
	default_material = "plutonium"

/obj/item/material/foolsfoolsgold
	name = "fool's pyrite bar"
	desc = "It's gold that isn't. Except it is. MINDFUCK"
	icon_state = "bar"
	default_material = "gold"
