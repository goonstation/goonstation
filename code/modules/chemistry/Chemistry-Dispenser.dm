/obj/machinery/chem_dispenser
	name = "chem dispenser"
	density = 1
	anchored = 1
	icon = 'icons/obj/chemical.dmi'
	icon_state = "dispenser"
	var/icon_base = "dispenser"
	flags = NOSPLASH | TGUI_INTERACTIVE
	var/health = 400
	mats = 30
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_CROWBAR | DECON_WELDER | DECON_WIRECUTTERS | DECON_MULTITOOL
	var/obj/item/beaker = null
	var/list/dispensable_reagents = list(
		"aluminium","barium","bromine","calcium","carbon","chlorine", \
		"chromium","copper","ethanol","fluorine","hydrogen", \
		"iodine","iron","lithium","magnesium","mercury","nickel", \
		"nitrogen","oxygen","phosphorus","plasma","platinum","potassium", \
		"radium","silicon","silver","sodium","sugar","sulfur","water"
	)
	var/glass_path = /obj/item/reagent_containers/glass
	var/glass_name = "beaker"
	var/dispenser_name = "Chemical"
	var/obj/item/card/id/user_id = null
	var/datum/reagent_group_account/current_account = null
	var/list/accounts = list()
	var/output_target = null
	var/dispense_sound = 'sound/effects/zzzt.ogg'

	New()
		..()
		update_account()

	disposing()
		beaker = null
		if (current_account.user_id == src)
			current_account.user_id = null
		for (var/datum/reagent_group_account/A in src.accounts)
			if (A.user_id == src)
				A.user_id = null
		..()

	attackby(var/obj/item/reagent_containers/glass/B as obj, var/mob/user as mob)
		remove_distant_beaker()
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
			update_static_data(user)
			tgui_process.update_uis(src)
			return

		if (!istype(B, glass_path))
			var/damage = B.force
			if (damage >= 5) //if it has five or more force, it'll do damage. prevents very weak objects from rattling the thing.
				user.lastattacked = src
				attack_particle(user,src)
				hit_twitch(src)
				playsound(src,"sound/impact_sounds/Metal_Clang_2.ogg",50,1)
				src.take_damage(damage)
				user.visible_message("<span class='alert'><b>[user] bashes [src] with [B]!</b></span>")
			else
				playsound(src,"sound/impact_sounds/Generic_Stab_1.ogg",50,1)
				user.visible_message("<span class='alert'><b>[user] uselessly taps [src] with [B]!</b></span>")
			return

		if (B.incompatible_with_chem_dispensers == 1)
			return

		if (status & (NOPOWER|BROKEN))
			user.show_text("[src] seems to be out of order.", "red")
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
			if (get_dist(src,user) > 1)
				boutput(user, "You need to move closer to get the chemicals!")
				return
			if (status & (NOPOWER|BROKEN))
				user.show_text("[src] seems to be out of order.", "red")
				return
			B.reagents.add_reagent(the_reagent,amount)
			B.reagents.handle_reactions()
			return
		*/
		if (src.beaker)
			boutput(user, "A [glass_name] is already loaded into the machine.")
			return

		src.beaker =  B
		if(!B.cant_drop)
			user.drop_item()
			if(!B.qdeled)
				B.set_loc(src)
		if(B.qdeled)
			B = null
		else
			boutput(user, "You add the [glass_name] to the machine!")
		src.update_icon()
		src.ui_interact(user)

	ex_act(severity)
		switch(severity)
			if(1.0)
				SPAWN_DBG(0)
					src.take_damage(400)
				return
			if(2.0)
				SPAWN_DBG(0)
					src.take_damage(150)
				return

	blob_act(var/power)
		if (prob(25 * power/20))
			qdel(src)

	meteorhit()
		qdel(src)
		return

	proc/eject_card()
		if (src.user_id)
			if(IN_RANGE(usr, src, 1))
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

	proc/update_icon()
		if (!beaker)
			src.icon_state = src.icon_base
		else
			src.icon_state = "[src.icon_base][rand(1,5)]"

	MouseDrop(over_object, src_location, over_location)
		if(!isliving(usr))
			boutput(usr, "<span class='alert'>Only living mobs are able to set the dispenser's output target.</span>")
			return

		if(get_dist(over_object,src) > 1)
			boutput(usr, "<span class='alert'>The dispenser is too far away from the target!</span>")
			return

		if(get_dist(over_object,usr) > 1)
			boutput(usr, "<span class='alert'>You are too far away from the target!</span>")
			return

		else if (istype(over_object,/turf/simulated/floor/))
			src.output_target = over_object
			boutput(usr, "<span class='notice'>You set the dispenser to output to [over_object]!</span>")

		else
			boutput(usr, "<span class='alert'>You can't use that as an output target.</span>")
		return

	proc/take_damage(var/damage_amount = 5)
		src.health -= damage_amount
		if (src.health <= 0)
			if (beaker)
				beaker.set_loc(src.output_target ? src.output_target : get_turf(src))
				beaker = null
			src.visible_message("<span class='alert'><b>[name] falls apart into useless debris!</b></span>")
			robogibs(src.loc,null)
			playsound(src.loc,'sound/impact_sounds/Machinery_Break_1.ogg', 50, 2)
			qdel(src)
			return

	proc/remove_distant_beaker()
		// borgs and people with item arms don't insert the beaker into the machine itself
		// but whenever something would happen to the dispenser and the beaker is far it should disappear
		if(beaker && !IN_RANGE(get_turf(beaker), src, 1))
			beaker = null
			src.update_icon()

	ui_interact(mob/user, datum/tgui/ui)
		remove_distant_beaker()
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
		var/list/beakerContentsTemp = list()
		.["idCardInserted"] = !isnull(src.user_id)
		.["idCardName"] = !isnull(src.user_id) ? src.user_id.registered : "None"
		.["maximumBeakerVolume"] = (!isnull(beaker) ? beaker.reagents.maximum_volume : 0)
		.["beakerTotalVolume"] = (!isnull(beaker) ? beaker.reagents.total_volume : 0)
		if(beaker)
			var/datum/reagents/R = beaker.reagents
			var/datum/color/average = R.get_average_color()
			.["currentBeakerName"] = beaker.name
			.["finalColor"] = average.to_rgba()
			if(istype(R) && R.reagent_list.len>0)
				for(var/reagent in R.reagent_list)
					var/datum/reagent/current_reagent = R.reagent_list[reagent]
					beakerContentsTemp.Add(list(list(
						name = reagents_cache[reagent],
						id = reagent,
						colorR = current_reagent.fluid_r,
						colorG = current_reagent.fluid_g,
						colorB = current_reagent.fluid_b,
						state = current_reagent.reagent_state,
						volume = current_reagent.volume
					)))
		.["beakerContents"] = beakerContentsTemp

	ui_act(action, params, datum/tgui/ui)
		if(..())
			return
		remove_distant_beaker()
		switch(action)
			if ("dispense")
				if (!beaker || !(params["reagentId"] in dispensable_reagents))
					return
				var/amount = clamp(round(params["amount"]), 1, 100)
				beaker.reagents.add_reagent(params["reagentId"], isnum(amount) ? amount : 10)
				beaker.reagents.handle_reactions()
				src.update_icon()
				playsound(src.loc, dispense_sound, 50, 1, 0.3)
				use_power(10)
				. = TRUE
			if ("eject")
				if (beaker)
					if(beaker.loc == src)
						if(IN_RANGE(usr, src, 1))
							usr.put_in_hand_or_drop(beaker)
						else
							beaker.set_loc(src.loc)
					beaker = null
					src.update_icon()
					. = TRUE
				else
					var/obj/item/I = usr.equipped()
					if (istype(I, glass_path))
						if(!I.cant_drop) // borgs and item arms
							usr.drop_item()
							I.set_loc(src)
						src.beaker = I
						src.update_icon()
						. = TRUE
			if ("remove")
				if(!beaker)
					return
				var/amount = clamp(round(params["amount"]), 1, 100)
				beaker.reagents.remove_reagent(params["reagentId"], isnum(amount) ? amount : 10)
				src.update_icon()
				. = TRUE
			if ("isolate")
				if(!beaker)
					return
				beaker.reagents.isolate_reagent(params["reagentId"])
				src.update_icon()
				. = TRUE
			if ("all")
				if(!beaker)
					return
				beaker.reagents.del_reagent(params["reagentId"])
				src.update_icon()
				. = TRUE
			if ("newGroup")
				var/reagents = params["reagents"]
				if (isnull(reagents) || !length(reagents))
					return
				var/name = params["groupName"]
				name = copytext(sanitize(html_encode(name)), 1, MAX_MESSAGE_LEN)
				if (isnull(name) || !length(name) || name == " ")
					return
				var/list/reagentlist = params2list(reagents)
				var/datum/reagent_group/G = new /datum/reagent_group()
				for (var/reagent in reagentlist)
					if (lowertext(reagent) in src.dispensable_reagents)
						G.reagents += lowertext(reagent)
						//Special amounts!
						if (istext(reagentlist[reagent])) //Set a dispense amount
							var/num = text2num(reagentlist[reagent])
							if(!num) num = 10
							G.reagents[lowertext(reagent)] = clamp(round(num), 1, 100)
						else //Default to 10 if no specific amount given
							G.reagents[lowertext(reagent)] = 10
				if(G.reagents == 0)
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
					for (var/reagent in group.reagents)
						if ((reagent in dispensable_reagents))
							var/amt = 10
							if (isnum(group.reagents[reagent]))
								amt = group.reagents[reagent]
							beaker.reagents.add_reagent(reagent,amt)
							beaker.reagents.handle_reactions()
					src.update_icon()
					use_power(length(group.reagents) * 10)
				playsound(src.loc, dispense_sound, 50, 1, 0.3)
				. = TRUE
			if ("card")
				if (src.user_id)
					src.eject_card()
					src.update_account()
					update_static_data(usr,ui)
				else
					var/obj/item/I = usr.equipped()
					if (istype(I, /obj/item/card/id) || istype(I, /obj/item/card/data))
						usr.drop_item()
						I.set_loc(src)
						src.user_id = I
						src.update_account()
						update_static_data(usr,ui)
				return

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
	icon_state = "alc_dispenser"
	icon_base = "alc_dispenser"
	glass_path = /obj/item/reagent_containers/food/drinks
	glass_name = "bottle"
	dispenser_name = "Alcohol"

	dispense_sound = 'sound/misc/pourdrink2.ogg'

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
	dispensable_reagents = list("cola", "juice_lime", "juice_lemon", "juice_orange", \
								"juice_cran", "juice_cherry", "juice_pineapple", "juice_tomato", \
								"coconut_milk", "sugar", "water", "vanilla", "tea", "grenadine")
	icon_state = "alc_dispenser"
	icon_base = "alc_dispenser"
	glass_path = /obj/item/reagent_containers/food/drinks
	glass_name = "bottle"
	dispenser_name = "Soda"

	dispense_sound = 'sound/misc/pourdrink2.ogg'

/obj/machinery/chem_dispenser/chef
	name = "kitchen fountain"
	desc = "A soda fountain that definitely does not have a suspicious similarity to the alcohol and chemical dispensers OR the soda fountain. No sir."
	dispensable_reagents = list("cola", "juice_lime", "juice_lemon", "juice_orange", "mint", "mustard", "pepper", \
								"juice_cran", "juice_cherry", "juice_pineapple","coconut_milk", "ketchup", \
								"sugar", "water", "vanilla", "tea", "chocolate", "chocolate_milk","strawberry_milk")
	icon_state = "alc_dispenser"
	icon_base = "alc_dispenser"
	glass_path = /obj/item/reagent_containers/food/drinks
	glass_name = "bottle"
	dispenser_name = "Soda"

	dispense_sound = 'sound/effects/splort.ogg'

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

	proc/update_desc()
		group_desc = ""
		for (var/reagent in src.reagents)
			var/amt = reagents[reagent]
			if (!isnum(amt))
				amt = 10
			src.group_desc += "[reagent][!isnull(amt) ? " ([amt]u)" : null], "
		group_desc = copytext(group_desc, 1, length(group_desc)-1)
