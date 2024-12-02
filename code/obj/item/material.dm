/obj/item/raw_material/
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
	burn_remains = BURN_REMAINS_MELT
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
			if (splitnum >= amount || splitnum < 1 || !isnum_safe(splitnum) || QDELETED(src))
				boutput(user, SPAN_ALERT("Invalid entry, try again."))
				return
			var/obj/item/raw_material/new_stack = split_stack(splitnum)
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

		if (istype(over_object,/obj/item/material_piece) && isturf(over_object.loc)) //piece to piece only if on ground
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
						else if (istype(dude.l_hand, /obj/item/raw_material))
							var/obj/item/raw_material/DP = dude.l_hand
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
						else if (istype(dude.r_hand, /obj/item/raw_material))
							var/obj/item/raw_material/DP = dude.r_hand
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

/obj/item/raw_material/rock
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

/obj/item/raw_material/mauxite
	name = "mauxite ore"
	desc = "A chunk of Mauxite, a sturdy common metal."
	material_name = "Mauxite"
	default_material = "mauxite"
	metal = 2

/obj/item/raw_material/molitz
	name = "molitz crystal"
	desc = "A crystal of Molitz, a common crystalline substance."
	material_name = "Molitz"
	default_material = "molitz"
	crystal = 1

/obj/item/raw_material/molitz_beta
	name = "molitz crystal"
	desc = "An unusual crystal of Molitz."
	icon_state = "ore$$molitz_b"
	material_name = "Molitz Beta"
	default_material = "molitz_b"
	crystal = 1

	setup_material()
		. = ..()
		src.pressure_resistance = INFINITY //has to be after material setup. REASONS

/obj/item/raw_material/pharosium
	name = "pharosium ore"
	desc = "A chunk of Pharosium, a conductive metal."
	material_name = "Pharosium"
	default_material = "pharosium"
	metal = 1
	conductor = 1

/obj/item/raw_material/cobryl // relate this to precursors
	name = "cobryl ore"
	desc = "A chunk of Cobryl, a somewhat valuable metal."
	material_name = "Cobryl"
	default_material = "cobryl"
	metal = 1

/obj/item/raw_material/char
	name = "char ore"
	desc = "A heap of Char, a fossil energy source similar to coal."
	material_name = "Char"
	default_material = "char"
	//cogwerks - burn vars
	burn_point = 450
	burn_output = 1600
	burn_possible = TRUE
	health = 20

/obj/item/raw_material/claretine // relate this to wizardry somehow
	name = "claretine ore"
	desc = "A heap of Claretine, a highly conductive salt."
	material_name = "Claretine"
	default_material = "claretine"
	conductor = 2

/obj/item/raw_material/bohrum
	name = "bohrum ore"
	desc = "A chunk of Bohrum, a heavy and highly durable metal."
	material_name = "Bohrum"
	default_material = "bohrum"
	metal = 3
	dense = 1

/obj/item/raw_material/syreline
	name = "syreline ore"
	desc = "A chunk of Syreline, an extremely valuable and coveted metal."
	material_name = "Syreline"
	default_material = "syreline"
	metal = 1

/obj/item/raw_material/erebite
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
		for(var/obj/item/raw_material/erebite/E in get_turf(src))
			if(E == src) continue
			qdel(E)

		for(var/obj/item/raw_material/erebite/E in range(4,src))
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

/obj/item/raw_material/cerenkite
	name = "cerenkite ore"
	desc = "A chunk of Cerenkite, a highly radioactive mineral."
	material_name = "Cerenkite"
	default_material = "cerenkite"
	metal = 1
	powersource = 1

/obj/item/raw_material/plasmastone
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


/obj/item/raw_material/gemstone
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

/obj/item/raw_material/uqill // relate this to ancients
	name = "uqill nugget"
	desc = "A nugget of Uqill, a rare and very dense stone."
	material_name = "Uqill"
	default_material = "uqill"
	dense = 2

/obj/item/raw_material/fibrilith
	name = "fibrilith chunk"
	desc = "A compressed chunk of Fibrilith, an odd mineral known for its high tensile strength."
	material_name = "Fibrilith"
	default_material = "fibrilith"

/obj/item/raw_material/telecrystal
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

/obj/item/raw_material/miracle
	name = "miracle matter"
	desc = "Miracle Matter is a bizarre substance known to metamorphosise into other minerals when processed."
	material_name = "Miracle"
	default_material = "miracle"

/obj/item/raw_material/starstone
	name = "starstone"
	desc = "An extremely rare jewel. Highly prized by collectors and lithovores."
	material_name = "Starstone"
	default_material = "starstone"
	crystal = 1

/obj/item/raw_material/eldritch
	name = "koshmarite ore"
	desc = "An unusual dense pulsating stone. You feel uneasy just looking at it."
	material_name = "Koshmarite"
	default_material = "koshmarite"
	crystal = 1
	dense = 2

/obj/item/raw_material/martian
	name = "viscerite lump"
	desc = "A disgusting flesh-like material. Ugh. What the hell is this?"
	material_name = "Viscerite"
	default_material = "viscerite"
	dense = 2

	setup_material()
		src.create_reagents(25)
		src.reagents.add_reagent("synthflesh", 25)
		return ..()

/obj/item/raw_material/gold
	name = "gold nugget"
	desc = "A chunk of pure gold. Damn son."
	material_name = "Gold"
	default_material = "gold"
	dense = 2

// Misc building material

/// This has no material, why does it exist???? Someone replace it
/obj/item/raw_material/fabric
	name = "fabric sheet"
	desc = "Some spun cloth. Useful if you want to make clothing."
	icon_state = "fabric"
	material_name = "Fabric"
	scoopable = 0

/obj/item/raw_material/cotton
	name = "cotton wad"
	desc = "It's a big puffy white thing. Most likely not a cloud though."
	icon_state = "cotton"
	material_name = "Cotton"
	default_material = "cotton"

/obj/item/raw_material/ice
	name = "ice chunk"
	desc = "A chunk of ice. It's pretty cold."
	material_name = "Ice"
	default_material = "ice"
	crystal = 1
	scoopable = 0

/obj/item/raw_material/scrap_metal
	// this should only be spawned by the game, spawning it otherwise would just be dumb
	name = "scrap"
	desc = "Some twisted and ruined metal. It could probably be smelted down into something more useful."
	icon_state = "scrap"
	stack_type = /obj/item/raw_material/scrap_metal
	burn_possible = FALSE
	mat_changename = TRUE
	material_name = "Steel"
	default_material = "steel"

	New()
		..()
		icon_state += "[rand(1,5)]"

/obj/item/raw_material/shard
	// same deal here
	name = "shard"
	desc = "A jagged piece of broken crystal or glass. It could probably be smelted down into something more useful."
	icon_state = "shard"
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	item_state = "shard-glass"
	stack_type = /obj/item/raw_material/shard
	object_flags = NO_GHOSTCRITTER
	tool_flags = TOOL_CUTTING
	w_class = W_CLASS_NORMAL
	hit_type = DAMAGE_CUT
	hitsound = 'sound/impact_sounds/Flesh_Stab_1.ogg'
	force = 5
	throwforce = 5
	g_amt = 3750
	burn_remains = BURN_REMAINS_MELT
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

/obj/item/raw_material/shard/proc/walked_over(mob/living/carbon/human/H as mob)
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
		if(!H.shoes || (src.material && src.material.hasProperty("hard") && src.material.getProperty("hard") >= 7))
			boutput(H, SPAN_ALERT("<B>You step on [src]! Ouch!</B>"))
			step_on(H)

/obj/item/raw_material/shard/proc/step_on(mob/living/carbon/human/H as mob)
	playsound(src.loc, src.sound_stepped, 50, 1)
	H.changeStatus("knockdown", 3 SECONDS)
	H.force_laydown_standup()
	var/zone = pick("l_leg", "r_leg")
	H.TakeDamage(zone, force, 0, 0, DAMAGE_CUT)

/obj/item/raw_material/chitin
	name = "chitin chunk"
	desc = "A chunk of chitin."
	material_name = "Chitin"
	default_material = "chitin"
	metal = 3
	dense = 1

// bars, tied into the new material system

/obj/item/material_piece/mauxite
	desc = "A processed bar of Mauxite, a sturdy common metal."
	default_material = "mauxite"
	icon_state = "bar"

/obj/item/material_piece/molitz
	desc = "A cut block of Molitz, a common crystalline substance."
	default_material = "molitz"
	icon_state = "bar"

/obj/item/material_piece/pharosium
	desc = "A processed bar of Pharosium, a conductive metal."
	default_material = "pharosium"
	icon_state = "bar"

/obj/item/material_piece/cobryl
	desc = "A processed bar of Cobryl, a somewhat valuable metal."
	default_material = "cobryl"
	icon_state = "bar"

/obj/item/material_piece/claretine
	desc = "A compressed Claretine, a highly conductive salt."
	default_material = "claretine"
	icon_state = "bar"

/obj/item/material_piece/bohrum
	desc = "A processed bar of Bohrum, a heavy and highly durable metal."
	default_material = "bohrum"
	icon_state = "bar"

/obj/item/material_piece/syreline
	desc = "A processed bar of Syreline, an extremely valuable and coveted metal."
	default_material = "syreline"
	icon_state = "bar"

/obj/item/material_piece/plasmastone
	desc = "A cut block of Plasmastone."
	default_material = "plasmastone"
	icon_state = "bar"

/obj/item/material_piece/uqill
	desc = "A cut block of Uqill. It is quite heavy."
	default_material = "uqill"
	icon_state = "bar"

/obj/item/material_piece/koshmarite
	desc = "A cut block of an unusual dense stone. It seems similar to obsidian."
	default_material = "koshmarite"
	icon_state = "bar"

/obj/item/material_piece/viscerite
	desc = "A cut block of a disgusting flesh-like material. Grody."
	default_material = "viscerite"
	icon_state = "bar"

/obj/item/material_piece/char
	desc = "A cut block of Char."
	default_material = "char"
	icon_state = "wad"
	color = "#221122"

/obj/item/material_piece/telecrystal
	desc = "A cut block of Telecrystal."
	default_material = "telecrystal"
	icon_state = "bar"

/obj/item/material_piece/fibrilith
	desc = "A cut block of Fibrilith."
	default_material = "fibrilith"
	icon_state = "bar"

/obj/item/material_piece/cerenkite
	desc = "A cut block of Cerenkite."
	default_material = "cerenkite"
	icon_state = "bar"

/obj/item/material_piece/erebite
	desc = "A cut block of Erebite."
	default_material = "erebite"
	icon_state = "bar"

/obj/item/material_piece/ice
	desc = "Uh. What's the point in this? Is someone planning to make an igloo?"
	default_material = "ice"

// Material-related Machinery

/obj/machinery/portable_reclaimer
	name = "portable reclaimer"
	desc = "A sophisticated piece of machinery can process raw materials, scrap, and material sheets into bars."
	icon = 'icons/obj/scrap.dmi'
	icon_state = "reclaimer"
	anchored = UNANCHORED
	density = 1
	event_handler_flags = NO_MOUSEDROP_QOL
	var/active = 0
	var/reject = 0
	var/smelt_interval = 5
	var/sound/sound_load = sound('sound/items/Deconstruct.ogg')
	var/sound/sound_process = sound('sound/effects/pop.ogg')
	var/sound/sound_grump = sound('sound/machines/buzz-two.ogg')
	var/atom/output_location = null
	var/list/atom/leftovers = list()

	attack_hand(var/mob/user)
		if (active)
			boutput(user, SPAN_ALERT("It's already working! Give it a moment!"))
			return
		if (length(src.contents) < 1)
			boutput(user, SPAN_ALERT("There's nothing inside to reclaim."))
			return
		user.visible_message("<b>[user.name]</b> switches on [src].")
		active = 1
		anchored = ANCHORED
		icon_state = "reclaimer-on"

		for (var/obj/item/M in src.contents)
			if (istype(M, /obj/item/wizard_crystal))
				var/obj/item/wizard_crystal/wc = M
				wc.setMaterial(getMaterial(wc.assoc_material),0,0,1,0)

			if (!istype(M.material))
				M.set_loc(src.loc)
				src.reject = 1
				continue

			else if (istype(M, /obj/item/cable_coil))
				var/obj/item/cable_coil/C = M
				output_bar_from_item(M, 1 / M.material_amt, C.conductor.getID())
				qdel(C)

			else
				output_bar_from_item(M, 1 / M.material_amt)
				qdel(M)

			sleep(smelt_interval)

		if (reject)
			src.reject = 0
			src.visible_message("<b>[src]</b> emits an angry buzz and rejects some unsuitable materials!")
			playsound(src.loc, sound_grump, 40, 1)

		active = 0
		anchored = UNANCHORED
		icon_state = "reclaimer"
		src.visible_message("<b>[src]</b> finishes working and shuts down.")

	proc/output_bar_from_item(obj/item/O, var/amount_per_bar = 1, var/extra_mat)
		if (!O || !O.material)
			return

		var/output_amount = O.amount

		if (amount_per_bar)
			var/bonus = leftovers[O.material.getID()]
			var/num_bars = O.amount / amount_per_bar + bonus

			output_amount = round(num_bars)
			if (output_amount != num_bars)
				leftovers[O.material.getID()] = num_bars - output_amount

		output_bar(O.material, output_amount)

		if (extra_mat) // i hate this
			output_amount = O.amount

			if (amount_per_bar)
				var/bonus = leftovers[extra_mat]
				var/num_bars = O.amount / amount_per_bar + bonus

				output_amount = round(num_bars)
				if (output_amount != num_bars)
					leftovers[extra_mat] = num_bars - output_amount

			output_bar(extra_mat, output_amount)

	proc/output_bar(material, amount)

		if(amount <= 0)
			return

		var/datum/material/MAT = material
		if (!istype(MAT))
			MAT = getMaterial(material)
			if (!MAT)
				return

		var/atom/output_location = src.get_output_location()

		var/bar_type = getProcessedMaterialForm(MAT)
		var/obj/item/material_piece/BAR = new bar_type
		BAR.setMaterial(MAT)
		BAR.change_stack_amount(amount - 1)

		if (istype(output_location, /obj/machinery/manufacturer))
			var/obj/machinery/manufacturer/M = output_location
			M.add_contents(BAR)
		else
			BAR.set_loc(output_location)
			for (var/obj/item/material_piece/other_bar in output_location.contents)
				if (other_bar == BAR)
					continue
				if (BAR.material.isSameMaterial(other_bar.material))
					if (other_bar.stack_item(BAR))
						break

		playsound(src.loc, sound_process, 40, 1)

	proc/load_reclaim(obj/item/W as obj, mob/user as mob)
		. = FALSE
		if (src.is_valid(W) && brain_check(W, user, TRUE))
			if (W.stored)
				W.stored.transfer_stored_item(W, src, user = user)
			else
				W.set_loc(src)
				if (user) user.u_equip(W)
			W.dropped(user)
			. = TRUE

	attackby(obj/item/W, mob/user)

		if (istype(W, /obj/item/ore_scoop))
			var/obj/item/ore_scoop/scoop = W
			W = scoop.satchel
		if (W.storage || istype(W, /obj/item/satchel))
			var/items = W
			if (W.storage)
				items = W.storage.get_contents()
			for(var/obj/item/O in items)
				if (load_reclaim(O))
					. = TRUE
			if (istype(W, /obj/item/satchel) && .)
				W.UpdateIcon()
			//Users loading individual items would make an annoying amount of messages
			//But loading a container is more noticable and there should be less
			if (.)
				user.visible_message("<b>[user.name]</b> loads [W] into [src].")
				playsound(src, sound_load, 40, TRUE)
				logTheThing(LOG_STATION, user, "loads [W] into \the [src] at [log_loc(src)].")
		else if (W?.cant_drop)
			boutput(user, SPAN_ALERT("You can't put that in [src] when it's attached to you!"))
			return ..()
		else if (load_reclaim(W, user))
			boutput(user, "You load [W] into [src].")
			playsound(src, sound_load, 40, TRUE)
			logTheThing(LOG_STATION, user, "loads [W] into \the [src] at [log_loc(src)].")
		else
			. = ..()

	mouse_drop(over_object, src_location, over_location)
		if(!isliving(usr))
			boutput(usr, SPAN_ALERT("Get your filthy dead fingers off that!"))
			return

		if(over_object == src)
			output_location = null
			boutput(usr, SPAN_NOTICE("You reset the reclaimer's output target."))
			return

		if(BOUNDS_DIST(over_object, src) > 0)
			boutput(usr, SPAN_ALERT("The reclaimer is too far away from the target!"))
			return

		if(BOUNDS_DIST(over_object, usr) > 0)
			boutput(usr, SPAN_ALERT("You are too far away from the target!"))
			return

		if (istype(over_object,/obj/storage/crate/))
			var/obj/storage/crate/C = over_object
			if (C.locked || C.welded)
				boutput(usr, SPAN_ALERT("You can't use a currently unopenable crate as an output target."))
			else
				src.output_location = over_object
				boutput(usr, SPAN_NOTICE("You set the reclaimer to output to [over_object]!"))

		else if (istype(over_object,/obj/storage/cart/))
			var/obj/storage/cart/C = over_object
			if (C.locked || C.welded)
				boutput(usr, SPAN_ALERT("You can't use a currently unopenable cart as an output target."))
			else
				src.output_location = over_object
				boutput(usr, SPAN_NOTICE("You set the reclaimer to output to [over_object]!"))

		else if (istype(over_object,/obj/machinery/manufacturer/))
			var/obj/machinery/manufacturer/M = over_object
			if (M.status & BROKEN || M.status & NOPOWER || M.dismantle_stage > 0)
				boutput(usr, SPAN_ALERT("You can't use a non-functioning manufacturer as an output target."))
			else
				src.output_location = M
				boutput(usr, SPAN_NOTICE("You set the reclaimer to output to [over_object]!"))

		else if (istype(over_object,/obj/table/) && istype(over_object,/obj/rack/))
			var/obj/O = over_object
			src.output_location = O.loc
			boutput(usr, SPAN_NOTICE("You set the reclaimer to output on top of [O]!"))

		else if (istype(over_object,/turf/simulated/floor/))
			src.output_location = over_object
			boutput(usr, SPAN_NOTICE("You set the reclaimer to output to [over_object]!"))

		else
			boutput(usr, SPAN_ALERT("You can't use that as an output target."))
		return

	MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
		if (!O || !user)
			return

		if(!isliving(user))
			boutput(user, SPAN_ALERT("Only living mobs are able to use the reclaimer's quick-load feature."))
			return

		if (!isobj(O))
			boutput(user, SPAN_ALERT("You can't quick-load that."))
			return

		if(BOUNDS_DIST(O, user) > 0)
			boutput(user, SPAN_ALERT("You are too far away!"))
			return

		if (istype(O, /obj/storage/crate/) || istype(O, /obj/storage/cart/))
			user.visible_message(SPAN_NOTICE("[user] uses [src]'s automatic loader on [O]!"), SPAN_NOTICE("You use [src]'s automatic loader on [O]."))
			var/amtload = 0
			for (var/obj/item/raw_material/M in O.contents)
				M.set_loc(src)
				amtload++
			if (amtload) boutput(user, SPAN_NOTICE("[amtload] materials loaded from [O]!"))
			else boutput(user, SPAN_ALERT("No material loaded!"))

		else if (is_valid(O))
			quickload(user,O)
		else
			..()

	proc/quickload(var/mob/living/user,var/obj/item/O)
		if (!user || !O)
			return
		user.visible_message(SPAN_NOTICE("[user] begins quickly stuffing [O] into [src]!"))
		var/staystill = user.loc
		for(var/obj/item/M in view(1,user))
			if (!M || M.loc == user)
				continue
			if (M.name != O.name)
				continue
			if(!(src.is_valid(M) && brain_check(M, user, FALSE)))
				continue
			M.set_loc(src)
			playsound(src, sound_load, 40, TRUE)
			sleep(0.5)
			if (user.loc != staystill) break
		boutput(user, SPAN_NOTICE("You finish stuffing [O] into [src]!"))
		return

	proc/get_output_location()
		if (!output_location)
			return src.loc

		if (!(BOUNDS_DIST(src.output_location, src) == 0))
			output_location = null
			return src.loc

		if (istype(output_location,/obj/machinery/manufacturer))
			var/obj/machinery/manufacturer/M = output_location
			if (M.status & NOPOWER || M.status & BROKEN | M.dismantle_stage > 0)
				return M.loc
			return M

		if (istype(output_location,/obj/storage))
			var/obj/storage/S = output_location
			if (S.locked || S.welded || S.open)
				return S.loc
			return S

		return output_location

	proc/is_valid(var/obj/item/I)
		if (!istype(I))
			return
		return (I.material && !istype(I,/obj/item/material_piece) && !istype(I,/obj/item/nuclear_waste)) || istype(I,/obj/item/wizard_crystal)

	proc/brain_check(var/obj/item/I, var/mob/user, var/ask)
		if (!istype(I))
			return
		var/obj/item/organ/brain/brain = null
		if (istype(I, /obj/item/parts/robot_parts/head))
			var/obj/item/parts/robot_parts/head/head = I
			brain = head.brain
		else if (istype(I, /obj/item/organ/brain))
			brain = I

		if (brain)
			if (!ask)
				boutput(user, SPAN_ALERT("[I] turned the intelligence detection light on! You decide to not load it for now."))
				return FALSE
			var/accept = tgui_alert(user, "Possible intelligence detected. Are you sure you want to reclaim [I]?", "Incinerate brain?", list("Yes", "No")) == "Yes" && can_reach(user, src) && user.equipped() == I
			if (accept)
				logTheThing(LOG_COMBAT, user, "loads [brain] (owner's ckey [brain.owner ? brain.owner.ckey : null]) into a portable reclaimer.")
			return accept
		return TRUE
