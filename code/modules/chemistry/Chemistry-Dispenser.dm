var/list/basic_elements = list(
		"aluminium","barium","bromine","calcium","carbon","chlorine", \
		"chromium","copper","ethanol","fluorine","hydrogen", \
		"iodine","iron","lithium","magnesium","mercury","nickel", \
		"nitrogen","oxygen","phosphorus","plasma","platinum","potassium", \
		"radium","silicon","silver","sodium","sugar","sulfur","water"
	)

ABSTRACT_TYPE(/obj/machinery/chem_dispenser)
TYPEINFO(/obj/machinery/chem_dispenser)
	mats = list("metal_dense" = 10,
				"conductive_high" = 10,
				"miracle" = 20)
/obj/machinery/chem_dispenser
	name = "chem dispenser"
	desc = "A complicated, soda fountain-like machine that allows the user to dispense basic chemicals for use in recipes."
	density = 1
	anchored = ANCHORED
	icon = 'icons/obj/chemical.dmi'
	icon_state = "dispenser"
	var/icon_base = "dispenser"
	flags = NOSPLASH | TGUI_INTERACTIVE
	object_flags = NO_GHOSTCRITTER
	var/health = 400
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_CROWBAR | DECON_WELDER | DECON_WIRECUTTERS | DECON_MULTITOOL
	var/obj/item/beaker = null
	var/list/dispensable_reagents = null
	///Should always be a type of /obj/item/reagent_containers
	var/glass_path = /obj/item/reagent_containers/glass
	var/glass_name = "beaker"
	var/dispenser_name = "Chemical"
	var/obj/item/card/id/user_id = null
	var/datum/reagent_group_account/current_account = null
	var/list/starting_groups
	var/list/accounts = list()
	var/output_target = null
	var/dispense_sound = 'sound/effects/zzzt.ogg'

	var/list/recording_queue
	var/list/recording_state = FALSE

	New()
		..()
		update_account()
		recording_queue = list()

		if(!starting_groups && current_state <= GAME_STATE_PREGAME)
			var/area/A = get_area(src)
			if(istype(A,/area/station/medical) && !istype(A, /area/station/medical/asylum))
				starting_groups = list(/datum/reagent_group/default/potassium_iodide,
									   /datum/reagent_group/default/styptic,
								       /datum/reagent_group/default/silver_sulfadiazine)

		if(starting_groups)
			for(var/P in starting_groups)
				var/datum/reagent_group/default/G = new P
				G.update_desc()
				if (current_account)
					current_account.groups += G

	disposing()
		if (beaker)
			REMOVE_ATOM_PROPERTY(beaker, PROP_ITEM_IN_CHEM_DISPENSER, src)
		beaker = null
		if (current_account.user_id == src)
			current_account.user_id = null
		for (var/datum/reagent_group_account/A in src.accounts)
			if (A.user_id == src)
				A.user_id = null
		..()

	attackby(var/obj/item/reagent_containers/glass/B, var/mob/user)
		remove_distant_beaker()
		src.add_fingerprint(user)
		if (istype(B, /obj/item/card/id) || istype(B, /obj/item/card/data))
			var/obj/item/card/id/ID = B
			if (src.user_id)
				user.put_in_hand_or_drop(src.user_id)
				user.show_text("You swap [src.user_id] out of [src].")
			src.user_id = ID
			if (ID.loc == user)
				user.u_equip(ID)
			else if (istype(ID.loc, /obj/item/device/pda2))
				var/obj/item/device/pda2/PDA = ID.loc
				PDA.eject_id_card()
			ID.set_loc(src)
			src.user_id = ID
			src.update_account()
			update_static_data(user)
			tgui_process.update_uis(src)
			return

		if (!istype(B, glass_path))
			var/damage = B.force
			if (damage >= 5) //if it has five or more force, it'll do damage. prevents very weak objects from rattling the thing.
				user.lastattacked = src
				attack_particle(user,src)
				hit_twitch(src)
				playsound(src, 'sound/impact_sounds/Metal_Clang_2.ogg', 50,TRUE)
				src.take_damage(damage)
				user.visible_message(SPAN_ALERT("<b>[user] bashes [src] with [B]!</b>"))
			else
				playsound(src, 'sound/impact_sounds/Generic_Stab_1.ogg', 50,TRUE)
				user.visible_message(SPAN_ALERT("<b>[user] uselessly taps [src] with [B]!</b>"))
			return

		if (B.incompatible_with_chem_dispensers == 1)
			return

		if (status & (NOPOWER|BROKEN))
			user.show_text("[src] seems to be out of order.", "red")
			return

		if (B.current_lid)
			boutput(user, SPAN_ALERT("You cannot put the [B.name] in the [src.name] while it has a lid on it."))
			return
		/*
		if (isrobot(user))
			var/the_reagent = input("Which chemical do you want to put in the [glass_name]?", "[dispenser_name] Dispenser", null, null) as null|anything in src.dispensable_reagents
			if (!the_reagent)
				return
			var/amtlimit = B.reagents.maximum_volume - B.reagents.total_volume
			var/amount = input("How much of it do you want? (1 to [amtlimit])", "[dispenser_name] Dispenser", null, null) as null|num
			if (isnull(amount) || amount <= 0)
				return
			amount = clamp(amount, 0, amtlimit)
			if (BOUNDS_DIST(src, user) > 0)
				boutput(user, "You need to move closer to get the chemicals!")
				return
			if (status & (NOPOWER|BROKEN))
				user.show_text("[src] seems to be out of order.", "red")
				return
			B.reagents.add_reagent(the_reagent,amount)
			B.reagents.handle_reactions()
			return
		*/
		var/obj/item/reagent_containers/glass/ejected_beaker = null
		if (src.beaker?.loc == src)
			ejected_beaker = src.beaker
			user.put_in_hand_or_drop(ejected_beaker)
		if(src.beaker) // hotswapping but possibly current beaker is a borg beaker
			src.beaker.reagents?.handle_reactions()
			REMOVE_ATOM_PROPERTY(src.beaker, PROP_ITEM_IN_CHEM_DISPENSER, src)

		src.beaker = B
		APPLY_ATOM_PROPERTY(B, PROP_ITEM_IN_CHEM_DISPENSER, src)
		if(!B.cant_drop)
			user.drop_item()
			if(!B.qdeled)
				B.set_loc(src)
		if(B.qdeled)
			B = null
		else
			if(ejected_beaker)
				boutput(user, "You swap the [B] with the [glass_name] already loaded into the machine.")
			else
				boutput(user, "You add the [glass_name] to the machine!")
		B.reagents?.handle_reactions()
		src.UpdateIcon()
		src.ui_interact(user)

	bullet_act(obj/projectile/P)
		if(P.proj_data.damage_type & (D_KINETIC | D_PIERCING | D_SLASHING))
			src.take_damage(P.power * P.proj_data?.ks_ratio)

	ex_act(severity)
		switch(severity)
			if(1)
				SPAWN(0)
					src.take_damage(400)
				return
			if(2)
				SPAWN(0)
					src.take_damage(150)
				return
			if(3)
				SPAWN(0)
					src.take_damage(50)

	blob_act(var/power)
		if (prob(25 * power/20))
			qdel(src)
		else
			src.take_damage(power*5)

	meteorhit()
		qdel(src)
		return


	proc/eject_card()
		if (src.user_id)
			if((BOUNDS_DIST(usr, src) == 0))
				usr.put_in_hand_or_drop(src.user_id)
			else
				src.user_id.set_loc(src.loc)
			src.user_id = null
		return

	proc/update_account()
/*		for (var/datum/reagent_group_account/A in src.accounts)
			if (A.user_id == src.user_id)
				src.current_account = A
				return
*/
		if (src.user_id)
			if (!src.user_id.reagent_account)
				src.user_id.reagent_account = new /datum/reagent_group_account()
				src.user_id.reagent_account.user_id = src.user_id
			src.current_account = user_id.reagent_account
			return
		else
			for (var/datum/reagent_group_account/A in src.accounts)
				if (A.user_id == src)
					src.current_account = A
					return
			var/datum/reagent_group_account/new_account = new /datum/reagent_group_account()
			new_account.user_id = src//.user_id
			src.accounts += new_account
			src.current_account = new_account

	update_icon()
		if (src.status & BROKEN)
			src.icon_state = "[src.icon_base]-broken"
		else if (!beaker)
			src.icon_state = src.icon_base
		else
			src.icon_state = "[src.icon_base][rand(1,5)]"

	mouse_drop(over_object, src_location, over_location)
		if(!isliving(usr))
			boutput(usr, SPAN_ALERT("Only living mobs are able to set the dispenser's output target."))
			return

		if(BOUNDS_DIST(over_object, src) > 0)
			boutput(usr, SPAN_ALERT("The dispenser is too far away from the target!"))
			return

		if(BOUNDS_DIST(over_object, usr) > 0)
			boutput(usr, SPAN_ALERT("You are too far away from the target!"))
			return

		else if (istype(over_object,/turf/simulated/floor/))
			src.output_target = over_object
			boutput(usr, SPAN_NOTICE("You set the dispenser to output to [over_object]!"))

		else
			boutput(usr, SPAN_ALERT("You can't use that as an output target."))
		return

	proc/take_damage(var/damage_amount = 5)
		src.health -= damage_amount
		if (damage_amount > 0 && src.health < 300)
			if (prob(((400-src.health)/400)*100)) // probability of breaking increases with damage taken
				src.set_broken()
		if (damage_amount > 50) // additional break roll for high-damage hits
			if (prob(damage_amount))
				src.set_broken()
		if (src.health <= 0)
			if (beaker)
				beaker.set_loc(src.output_target ? src.output_target : get_turf(src))
				REMOVE_ATOM_PROPERTY(beaker, PROP_ITEM_IN_CHEM_DISPENSER, src)
				beaker = null
			src.visible_message(SPAN_ALERT("<b>[name] falls apart into useless debris!</b>"))
			robogibs(src.loc)
			playsound(src.loc,'sound/impact_sounds/Machinery_Break_1.ogg', 50, 2)
			qdel(src)
			return

	proc/remove_distant_beaker(force = FALSE)
		// borgs and people with item arms don't insert the beaker into the machine itself
		// but whenever something would happen to the dispenser and the beaker is far it should disappear
		if(beaker && (BOUNDS_DIST(beaker, src) > 0 || force))
			REMOVE_ATOM_PROPERTY(beaker, PROP_ITEM_IN_CHEM_DISPENSER, src)
			beaker = null
			src.UpdateIcon()

	ui_interact(mob/user, datum/tgui/ui)
		remove_distant_beaker()
		if (src.beaker)
			SEND_SIGNAL(src.beaker.reagents, COMSIG_REAGENTS_ANALYZED, user)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "ChemDispenser", src.name)
			ui.open()

	ui_static_data(mob/user)
		. = list()
		var/list/groupListTemp = list()
		var/list/dispensableReagentsTemp = list()
		if(dispensable_reagents)
			for(var/reagent in dispensable_reagents)
				var/datum/reagent/current_reagent = reagents_cache[reagent]
				dispensableReagentsTemp.Add(list(list(
					name = current_reagent.name,
					colorR = current_reagent.fluid_r,
					colorG = current_reagent.fluid_g,
					colorB = current_reagent.fluid_b,
					state = current_reagent.reagent_state,
					id = reagent
				)))
		if(current_account)
			for (var/datum/reagent_group/group in current_account.groups)
				groupListTemp.Add(list(list(
					name = group.name,
					info = group.group_desc,
					ref = ref(group)
				)))
		.["groupList"] = groupListTemp
		.["beakerName"] = glass_name
		.["dispensableReagents"] = dispensableReagentsTemp

	ui_data(mob/user)
		. = list()
		.["idCardInserted"] = !isnull(src.user_id)
		.["idCardName"] = !isnull(src.user_id) ? src.user_id.registered : "None"
		.["isRecording"] = src.recording_state
		.["activeRecording"] = src.get_recording_text()
		.["container"] = ui_describe_reagents(src.beaker)

	proc/get_recording_text()
		. = ""
		for (var/reagent in src.recording_queue)
			. += "[reagent]; "

	ui_act(action, params, datum/tgui/ui)
		if(..())
			return
		remove_distant_beaker()
		src.add_fingerprint(usr)
		switch(action)
			if ("dispense")
				if (!beaker || !(params["reagentId"] in dispensable_reagents))
					return
				var/amount = clamp(round(params["amount"]), 1, 100)
				beaker.reagents.add_reagent(params["reagentId"], isnum(amount) ? amount : 10)
				beaker.reagents.handle_reactions()
				src.UpdateIcon()
				playsound(src.loc, dispense_sound, 50, 1, 0.3)
				use_power(amount)
				if(src.recording_state)
					src.recording_queue += "[params["reagentId"]]=[isnum(amount) ? amount : 10]"
				. = TRUE
			if ("eject")
				if (beaker)
					if(beaker.loc == src)
						if((BOUNDS_DIST(usr, src) == 0))
							usr.put_in_hand_or_drop(beaker)
							beaker.reagents?.handle_reactions()
						else
							beaker.set_loc(src.loc)
					REMOVE_ATOM_PROPERTY(beaker, PROP_ITEM_IN_CHEM_DISPENSER, src)
					beaker = null
					src.UpdateIcon()
					. = TRUE
				else
					var/obj/item/reagent_containers/newbeaker = usr.equipped()
					if (istype(newbeaker, glass_path) && !newbeaker.incompatible_with_chem_dispensers)
						if (newbeaker.current_lid)
							boutput(ui.user, SPAN_ALERT("You cannot put the [newbeaker.name] in the [src.name] while it has a lid on it."))
							return
						if(!newbeaker.cant_drop) // borgs and item arms
							usr.drop_item()
							newbeaker.set_loc(src)
						src.beaker = newbeaker
						APPLY_ATOM_PROPERTY(src.beaker, PROP_ITEM_IN_CHEM_DISPENSER, src)
						src.UpdateIcon()
						. = TRUE
			if ("remove")
				if(!beaker)
					return
				var/amount = clamp(round(params["amount"]), 1, 100)
				beaker.reagents.remove_reagent(params["reagentId"], isnum(amount) ? amount : 10)
				src.UpdateIcon()
				. = TRUE
			if ("isolate")
				if(!beaker)
					return
				beaker.reagents.isolate_reagent(params["reagentId"])
				src.UpdateIcon()
				. = TRUE
			if ("all")
				if(!beaker)
					return
				beaker.reagents.del_reagent(params["reagentId"])
				src.UpdateIcon()
				. = TRUE
			if ("newGroup")
				var/reagents = get_recording_text()
				if (isnull(reagents) || !length(reagents))
					return
				var/name = params["groupName"]
				name = copytext(sanitize(html_encode(name)), 1, MAX_MESSAGE_LEN)
				if (isnull(name) || !length(name) || name == " ")
					return

				var/datum/reagent_group/G = new /datum/reagent_group()
				G.reagents = src.recording_queue.Copy()

				if(!length(G.reagents))
					return
				G.name = name
				G.update_desc()
				if (current_account)
					current_account.groups += G
				update_static_data(usr,ui)
				. = TRUE
			if ("deleteGroup")
				var/datum/reagent_group/group = locate(params["selectedGroup"]) in src.current_account.groups
				if(group)
					src.current_account.groups -= group
					qdel(group)
					update_static_data(usr,ui)
					. = TRUE
			if ("groupDispense")
				if(!beaker)
					return
				var/datum/reagent_group/group = locate(params["selectedGroup"]) in src.current_account.groups
				if(istype(group) && current_account && (group in current_account.groups))
					var/total_power_use = 0
					for (var/reagent in group.reagents)
						var/tuple = params2list(reagent)
						var/key = tuple[1]
						var/value = text2num_safe(tuple[tuple[1]])
						if ((key in dispensable_reagents))
							var/amt = 10
							if (isnum(value))
								amt = value
							total_power_use += amt
							beaker.reagents.add_reagent(key,amt)
							beaker.reagents.handle_reactions()
					src.UpdateIcon()
					use_power(total_power_use)
				playsound(src.loc, dispense_sound, 50, 1, 0.3)
				. = TRUE
			if ("card")
				if (src.user_id)
					src.eject_card()
					src.update_account()
					update_static_data(usr,ui)
					. = TRUE
				else
					var/obj/item/I = usr.equipped()
					if (istype(I, /obj/item/card/id) || istype(I, /obj/item/card/data))
						usr.drop_item()
						I.set_loc(src)
						src.user_id = I
						src.update_account()
						update_static_data(usr,ui)
						. = TRUE
				return
			if ("record")
				src.recording_state = !src.recording_state
				. = TRUE
			if ("clear_recording")
				src.recording_queue = list()
				. = TRUE

	ui_close(mob/user)
		. = ..()
		if(src.beaker?.loc != src)
			src.remove_distant_beaker(force = TRUE)

	set_broken()
		. = ..()
		if (.) return
		if (src.beaker && src.beaker.loc == src)
			src.beaker.set_loc(src.loc)
			REMOVE_ATOM_PROPERTY(src.beaker, PROP_ITEM_IN_CHEM_DISPENSER, src)
			src.beaker = null
		if (src.user_id && src.user_id.loc == src)
			src.user_id.set_loc(src.loc)
			src.user_id = null

		AddComponent(/datum/component/equipment_fault/leaky, tool_flags = TOOL_SCREWING | TOOL_WRENCHING, reagent_list = src.dispensable_reagents)
		src.UpdateIcon()

	power_change()
		. = ..()
		src.UpdateIcon()

/obj/machinery/chem_dispenser/chemical
	New()
		..()
		src.dispensable_reagents = basic_elements

/obj/machinery/chem_dispenser/chemical/med_test
	starting_groups = list(/datum/reagent_group/default/potassium_iodide,
								/datum/reagent_group/default/styptic,
								/datum/reagent_group/default/silver_sulfadiazine)

/obj/machinery/chem_dispenser/alcohol
	name = "alcohol dispenser"
	desc = "You see a small, fading warning label on the side of the machine:<br>WARNING: Contents artificially produced using industrial ethanol. Not recommended for human consumption."
	dispensable_reagents = list("beer", "cider", "gin", "wine", "champagne", \
								"rum", "vodka", "bourbon", "vermouth", "tequila", \
								"bitters", "tonic")
	icon_state = "alc_dispenser"
	icon_base = "alc_dispenser"
	glass_path = /obj/item/reagent_containers/food/drinks
	glass_name = "bottle"
	dispenser_name = "Alcohol"

	dispense_sound = 'sound/misc/pourdrink2.ogg'

//Combines alcohol and soda dispenser
/obj/machinery/chem_dispenser/alcohol/bar
	name = "bar dispenser"
	desc = "You see a small, fading warning label on the side of the machine:<br>WARNING: Contents pending approval for human consumption. User assumes all risks.</br>"
	dispensable_reagents = list("beer", "bitters", "bourbon", "champagne", "juice_cherry", "cider", \
								"coconut_milk", "cola", "juice_cran", "gin", "ginger_ale", "grenadine", "juice_lemon", \
								"juice_lime", "juice_orange", "juice_pineapple",  "rum", "sugar", \
								"tea", "tequila", "juice_tomato", "tonic", "vanilla", "vermouth", "vodka", "water", "wine")

// Dispenses any drink you want. Designed for the afterlife bar
/obj/machinery/chem_dispenser/alcohol/ultra
	name = "alcohol dispenser"
	desc = "A heavenly booze dispenser. Makes any drink you want instantly! Cool!"
	dispensable_reagents = list("bilk","beer","cider","mead","wine","champagne","rum","vodka","bourbon", \
							"boorbon","beepskybeer","moonshine","bojack","screwdriver","bloody_mary","bloody_scary",\
							"snakebite","diesel","suicider","grog","port","gin","vermouth","bitters","whiskey_sour",\
							"daiquiri","martini","v_martini","murdini","mutini","manhattan","libre","ginfizz","gimlet",\
							"v_gimlet","w_russian","b_russian","irishcoffee","cosmo","beach","gtonic","vtonic","sonic",\
							"gpink","eraser","dbreath","squeeze","hunchback","madmen","planter","maitai","harlow",\
							"gchronic","margarita","tequini","pfire","bull","longisland","pinacolada","longbeach",\
							"mimosa","french75","sangria","tomcollins","peachschnapps","moscowmule","tequila","tequilasunrise",\
							"paloma","mintjulep","mojito","cremedementhe","grasshopper","freeze","curacao","bluelagoon",\
							"bluehawaiian","negroni","necroni") // ow my hands

/obj/machinery/chem_dispenser/alcohol/hydro
	name = "ULTRA DISPENSER"
	desc = "The most powerful bar dispenser to ever exist."
	dispensable_reagents = list("bilk","beer","cider","mead","wine","champagne","rum","vodka","bourbon", \
						"boorbon","beepskybeer","moonshine","bojack","screwdriver","bloody_mary","bloody_scary",\
						"snakebite","diesel","suicider","port","gin","vermouth","bitters","whiskey_sour",\
						"daiquiri","martini","v_martini","murdini","manhattan","libre","ginfizz","gimlet",\
						"v_gimlet","w_russian","b_russian","irishcoffee","cosmo","beach","gtonic","vtonic","sonic",\
						"gpink","eraser","squeeze","hunchback","madmen","planter","maitai","harlow",\
						"gchronic","margarita","tequini","pfire","bull","longisland","pinacolada","longbeach",\
						"mimosa","french75","sangria","tomcollins","peachschnapps","moscowmule","tequilasunrise",\
						"paloma","mintjulep","mojito","cremedementhe","grasshopper","curacao","bluelagoon",\
						"bluehawaiian","negroni","necroni", "cola", "juice_lime", "juice_lemon", "juice_orange", \
						"juice_cran", "juice_cherry", "juice_pineapple", "juice_tomato", \
						"coconut_milk", "sugar", "water", "vanilla", "tea","mint")


/obj/machinery/chem_dispenser/soda
	name = "soda fountain"
	desc = "A soda fountain that definitely does not have a suspicious similarity to the alcohol and chemical dispensers. No sir."
	dispensable_reagents = list("cola", "ginger_ale", "juice_lime", "juice_lemon", "juice_orange", \
								"juice_cran", "juice_cherry", "juice_pineapple", "juice_tomato", \
								"coconut_milk", "sugar", "water", "vanilla", "tea", "grenadine")
	icon_state = "alc_dispenser"
	icon_base = "alc_dispenser"
	glass_path = /obj/item/reagent_containers/food/drinks
	glass_name = "bottle"
	dispenser_name = "Soda"

	dispense_sound = 'sound/misc/pourdrink2.ogg'

/obj/machinery/chem_dispenser/chef
	name = "HAPPY CHEF Dispense-o-tronic"
	desc = "It's covered in a thin layer of acrid-smelling dust. The contents probably taste more like preservatives than whatever they're supposed to be."
	dispensable_reagents = list("ketchup","mustard","salt","pepper","gravy","chocolate","chocolate_milk","strawberry_milk","milk")
	icon_state = "alc_dispenser"
	icon_base = "alc_dispenser"
	glass_path = /obj/item/reagent_containers/food/drinks
	glass_name = "bottle"
	dispenser_name = "Soda"

	dispense_sound = 'sound/effects/splort.ogg'

/obj/machinery/chem_dispenser/botany
	name = "botany dispenser"
	desc = "Unlike other chem dispensers, this one's mostly just made for plants.";
	dispensable_reagents = list("mutadone","saltpetre","ammonia","potash","poo","space_fungus","weedkiller","mutagen");

// Reagent Groups

/datum/reagent_group_account
	var/obj/item/card/id/user_id = null
	var/list/groups = list()

	disposing()
		user_id = null
		groups = null
		..()


/datum/reagent_group
	var/name = null
	var/list/reagents = list()
	var/group_desc
	var/custom_desc

	proc/update_desc()
		if(custom_desc)
			group_desc = custom_desc

		else
			group_desc = ""
			for (var/reagent_data in src.reagents)
				var/tuple = params2list(reagent_data)
				var/key = tuple[1]
				var/amt = text2num_safe(tuple[key])
				if (!isnum(amt))
					amt = 10
				src.group_desc += "[key]([amt]u), "
			group_desc = copytext(group_desc, 1, length(group_desc)-1)

	proc/build_reagent_group_by_reaction(reaction_id, scale=1)
		var/datum/chemical_reaction/C = chem_reactions_by_id[reaction_id]
		var/datum/reagent/R  = reagents_cache[C?.result]

		if(R && C)
			if(!name)
				src.name = R.name
			for(var/reagent in C.required_reagents)
				reagents += "[reagent]=[C.required_reagents[reagent] * scale]"

	default
		var/reaction_id
		var/default_scale = 5

		New()
			..()
			if(reaction_id)
				build_reagent_group_by_reaction(reaction_id, default_scale)

		potassium_iodide
			reaction_id = "anti_rad"
			custom_desc = "Anti-Radiation Medication"

		styptic
			name = "Styptic Powder"
			custom_desc = "Control bleeding and heal physical wounds"
			reagents = list("sulfur=1", "hydrogen=1", "oxygen=1", "aluminium=2", "oxygen=2", "hydrogen=2")

		silver_sulfadiazine
			name = "Burn Medication"
			custom_desc = "This antibacterial compound is used to treat burn victims"
			reagents = list("hydrogen=3","nitrogen=1","silver=3","sulfur=3","oxygen=3","chlorine=3")

		space_cleaner
			name = "Space cleaner"
			custom_desc = "An industrial compound used to clean things. Lots of things."
			reagents = list("hydrogen=3","nitrogen=1","ethanol=3", "water=3")
