///////////////////////////////////////////////////////////////////////////////////////////////////
/chui/window/chem_dispenser
	name = "Chem Dispenser"
	//template = "html/chemDispenserTemplate.html"
	windowSize = "700x600"
	var/obj/machinery/chem_dispenser/dispenser //The chem dispenser we attach to

	disposing()
		dispenser = null
		theAtom = null
		..()

	proc/SetDispenser(var/obj/machinery/chem_dispenser/dispenser)
		if (istype(dispenser))
			src.dispenser = dispenser
			theAtom = dispenser


	GetBody()
		if(!template)
			template = grabResource("html/chemDispenserTemplate.html")
		//DEBUG("Continuing dispenser body generation.")
		return ..()

	OnClick(var/client/who, var/id, var/data)
		..()
		//DEBUG("Client: [who], ID: [id], DATA: [data]")
		if (dispenser) //Wire: Fix for: Cannot execute null.Topic()
			dispenser.Topic("", list("[id]"=1) + params2list(data))

	Subscribe(var/client/who)
		var/reag = IsSubscribed(who)
		..()
		dispenser.ui_fullupdate(!reag)

/obj/machinery/chem_dispenser
	name = "chem dispenser"
	density = 1
	anchored = 1
	icon = 'icons/obj/chemical.dmi'
	icon_state = "dispenser"
	var/icon_base = "dispenser"
	flags = NOSPLASH
	var/health = 400
	mats = 30
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_CROWBAR | DECON_WELDER | DECON_WIRECUTTERS | DECON_MULTITOOL
	var/obj/item/beaker = null
	var/list/dispensable_reagents = list("aluminium","barium","bromine","carbon","calcium","chlorine", \
										"chromium","copper","ethanol","fluorine","hydrogen", \
										"iodine","iron","lithium","magnesium","mercury","nickel", \
										"nitrogen","oxygen","plasma","platinum","phosphorus","potassium", \
										"radium","silicon","silver","sodium","sulfur","sugar","water")
	var/glass_path = /obj/item/reagent_containers/glass
	var/glass_name = "beaker"
	var/dispenser_name = "Chemical"
	var/obj/item/card/id/user_id = null
	var/datum/reagent_group_account/current_account = null
	var/list/accounts = list()
	var/doing_a_thing = 0
	var/user_dispense_amt = 10 // users can set this to dispense a custom amount of stuff, rounded to 1 and between 1-50
	var/user_remove_amt = 10 // same as above but for removing chems
	var/HTML = null
	// The chemistry APC was largely meaningless, so I made dispensers/heaters require a power supply (Convair880).
	var/dispense_data = ""
	var/chui/window/chem_dispenser/ch_window = new
	var/output_target = null

	var/dispense_sound = 'sound/effects/zzzt.ogg'

	New()
		..()
		UnsubscribeProcess()
		ch_window.SetDispenser(src)
		update_dispensable_data()
		update_account()

	disposing()
		beaker = null
		qdel(ch_window)
		ch_window = null


		if (current_account.user_id == src)
			current_account.user_id = null
		for (var/datum/reagent_group_account/A in src.accounts)
			if (A.user_id == src)
				A.user_id = null

		..()

	proc/update_dispensable_data()
		dispensable_reagents=sortList(dispensable_reagents)
		dispense_data ="\["
		for(var/R in dispensable_reagents)
			var/datum/reagent/re = reagents_cache[R]
			if(re)
				dispense_data += {"{"name":"[re.name]","id":"[R]\"},"}

		dispense_data = "[copytext(dispense_data,1,length(dispense_data))]]"

	proc/ui_fullupdate(include_chems=0)
		send_reagent_details(include_chems)
		send_generic_details()
		send_beaker_details()
		send_group_details()

	proc/send_reagent_details(include_chems=0)
		//Update creatable reagents
		var/data = {"{"}
		var/show_stat = 0
		if(!beaker)
			data += {""stat_msg":"No [glass_name] loaded.\""}
			show_stat = 1
		else if (!beaker.reagents || beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
			data += {""stat_msg":"[capitalize(glass_name)] is full.\""}
			show_stat = 1

		data += {"[show_stat ? ",":null]"show_stat":[show_stat]"}
		if (include_chems)
			data += {","chems":[dispense_data]"}
		data += "}"

		//DEBUG_MESSAGE("send_reagent_details: [data]")
		SPAWN_DBG(0) ch_window.CallJSFunction("updateChemSection", list(data))

	proc/send_generic_details()
		//Update info about the card and add/remove amounts
		var/data
		if(user_id)
			data = {""card":1,"}

		data += {""add_amt":[user_dispense_amt], "remove_amt":[user_remove_amt]"}
		data = "{[data]}"

		//DEBUG_MESSAGE("send_generic_details: [data]")
		SPAWN_DBG(0) ch_window.CallJSFunction("updateGeneric", list(data))


	proc/send_beaker_details()
		//Update info about the existence of and contents of the current beaker
		var/data
		if(!beaker)
			data = "{}"
		else
			var/list/data_parts = list()
			data_parts += {"{"name":"[capitalize(glass_name)]""}
			var/datum/reagents/R = beaker:reagents
			if(istype(R) && R.reagent_list.len>0)
				data_parts += {","reagents":\["}
				var/first = 1
				for(var/RID in R.reagent_list)
					if(!first)
						data_parts += ","
					first = 0
					var/datum/reagent/RE = R.reagent_list[RID]
					data_parts += {"{"name":"[RE.name]","id":"[RID]","quantity":[RE.volume]}"}
				data_parts += "]"
			data_parts += "}"
			data = jointext(data_parts, "")

		//DEBUG_MESSAGE("send_beaker_details: [data]")
		SPAWN_DBG(0) ch_window.CallJSFunction("updateBeaker", list(data))

	proc/send_group_details()
		//Update info about the groups in use
		var/data = {"{"groups":\[ "}
		if(current_account)

			for (var/datum/reagent_group/group in current_account.groups)
				data += {"{"name":"[group.name]","ref":"\ref[group]","info":"[group.group_desc]\"},"}

			data = copytext(data, 1, length(data))

		data ="[data]]}"
		//DEBUG_MESSAGE("send_group_details: [data]")
		SPAWN_DBG(0) ch_window.CallJSFunction("updateGroups", list(data))

	attackby(var/obj/item/reagent_containers/glass/B as obj, var/mob/user as mob)
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
			send_generic_details()
			send_group_details()
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
		if (src.beaker)
			boutput(user, "A [glass_name] is already loaded into the machine.")
			return

		src.beaker =  B
		user.drop_item()
		B.set_loc(src)
		boutput(user, "You add the [glass_name] to the machine!")
		if(ch_window.IsSubscribed(user.client))
			send_beaker_details()
			send_reagent_details(0)
		src.update_icon()
		src.add_dialog(user)
		ch_window.Subscribe(user.client)

	handle_event(var/event, var/sender)
		if (event == "reagent_holder_update")
			src.send_beaker_details()

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

	Topic(href, href_list)
		if (status & (NOPOWER|BROKEN)) return
		if (usr.stat || usr.restrained()) return
		if (!in_range(src, usr)) return
		if (isghostcritter(usr)) return
		if (doing_a_thing) return

		src.add_dialog(usr)
		src.add_fingerprint(usr)

		if (href_list["card"])
			if (src.user_id)
				src.eject_card()
				src.update_account()
				send_generic_details()
				send_group_details()
			else
				var/obj/item/I = usr.equipped()
				if (istype(I, /obj/item/card/id) || istype(I, /obj/item/card/data))
					usr.drop_item()
					I.set_loc(src)
					src.user_id = I
					src.update_account()
					send_generic_details()
					send_group_details()
			return

		else if (href_list["new_group"])
			doing_a_thing = 1
			var/reagents = input("Which reagents (separated by semicolons, indicate amount with equals signs)?","New Group") as null|text
			if (isnull(reagents) || !length(reagents))
				doing_a_thing = 0
				return
			var/name = input("What should the reagent group be called?","New Group") as null|text
			name = copytext(sanitize(html_encode(name)), 1, MAX_MESSAGE_LEN)
			if (isnull(name) || !length(name) || name == " ")
				doing_a_thing = 0
				return
			//DEBUG(reagents)
			var/list/reagentlist = params2list(reagents)
			//DEBUG(list2params(reagentlist))

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
				doing_a_thing = 0
				return

			G.name = name
			G.update_desc()
			if (current_account)
				current_account.groups += G
			send_group_details()

			doing_a_thing = 0
			return

		else if (href_list["eject"])
			if (beaker)
				usr.put_in_hand_or_drop(beaker)
				beaker = null
			else
				var/obj/item/I = usr.equipped()
				if (istype(I, glass_path))
					usr.drop_item()
					I.set_loc(src)
					src.beaker = I

			update_icon()
			send_beaker_details()
			send_reagent_details(0)
			return

		else if (href_list["setaddamt"])
			doing_a_thing = 1
			var/nadd = input(usr, "Set custom dispense amount:", "New Dispense Amount", src.user_dispense_amt) as null|num
			if (isnull(nadd) || get_dist(src,usr) > 1)
				doing_a_thing = 0
				return
			src.user_dispense_amt = clamp(round(nadd), 1, 100)
			src.updateUsrDialog()
			doing_a_thing = 0
			return

		else if (href_list["setremoveamt"])
			doing_a_thing = 1
			var/nremove = input(usr, "Set custom removal amount:", "New Removal Amount", src.user_remove_amt) as null|num
			if (isnull(nremove) || get_dist(src,usr) > 1)
				doing_a_thing = 0
				return
			src.user_remove_amt = clamp(round(nremove), 1, 100)
			src.updateUsrDialog()
			doing_a_thing = 0
			return

		if (!src.beaker)
			return

		if (href_list["dispense"])
			doing_a_thing = 1
			var/id = href_list["dispense"]
			if (!(id in dispensable_reagents))
				doing_a_thing = 0
				return
			beaker.reagents.add_reagent(id,10)
			beaker.reagents.handle_reactions()
			src.update_icon()
			src.send_beaker_details()
			send_reagent_details()
			doing_a_thing = 0
			playsound(src.loc, dispense_sound, 50, 1, 0.3)
			return

		else if (href_list["dispensecustom"])
			doing_a_thing = 1
			var/id = href_list["dispensecustom"]
			if (!(id in dispensable_reagents))
				doing_a_thing = 0
				return
			beaker.reagents.add_reagent(id, isnum(src.user_dispense_amt) ? src.user_dispense_amt : 10)
			beaker.reagents.handle_reactions()
			src.update_icon()
			src.send_beaker_details()
			send_reagent_details()
			doing_a_thing = 0
			playsound(src.loc, dispense_sound, 50, 1, 0.3)
			return

		else if (href_list["group_dispense"])
			doing_a_thing = 1
			var/datum/reagent_group/group = locate(href_list["group_dispense"])
			if(istype(group) && current_account && (group in current_account.groups))
				for (var/reagent in group.reagents)
					if ((reagent in dispensable_reagents))
						var/amt = 10
						if (isnum(group.reagents[reagent]))
							amt = group.reagents[reagent]
						beaker.reagents.add_reagent(reagent,amt)
						beaker.reagents.handle_reactions()
				src.update_icon()
				src.send_beaker_details()
				send_reagent_details()
			doing_a_thing = 0
			playsound(src.loc, dispense_sound, 50, 1, 0.3)
			return

		else if (href_list["group_delete"])
			var/datum/reagent_group/group = locate(href_list["group_delete"]) in src.current_account.groups
			if(group)
				src.current_account.groups -= group
				qdel(group)
				send_group_details()
			return

		else if (href_list["isolate"])
			beaker.reagents.isolate_reagent(href_list["isolate"])
			src.update_icon()
			send_beaker_details()
			send_reagent_details()
			return
		else if (href_list["remove"])
			beaker.reagents.del_reagent(href_list["remove"])
			src.update_icon()
			send_beaker_details()
			send_reagent_details()
			return
		else if (href_list["removecustom"])
			beaker.reagents.remove_reagent(href_list["removecustom"], isnum(src.user_remove_amt) ? src.user_remove_amt : 5)
			src.update_icon()
			send_beaker_details()
			send_reagent_details()
			return
		else if (href_list["remove5"])
			beaker.reagents.remove_reagent(href_list["remove5"], 5)
			src.update_icon()
			send_beaker_details()
			send_reagent_details()
			return
		else if (href_list["remove1"])
			beaker.reagents.remove_reagent(href_list["remove1"], 1)
			src.update_icon()
			send_beaker_details()
			send_reagent_details()
			return

		else
			ch_window.Unsubscribe(usr.client)
			return

	attack_ai(mob/user as mob)
		return src.attack_hand(user)

	attack_hand(mob/user as mob)
		if(status & (NOPOWER|BROKEN))
			return
		src.add_dialog(user)
		/*
		src.update_html()
		user.Browse("<TITLE>[dispenser_name] Dispenser</TITLE>[dispenser_name] dispenser:<BR>[src.HTML]", "window=chem_dispenser;size=500x800;title=Chemistry Dispenser")
		*/
		ch_window.Subscribe(user.client)
		return

	proc/update_html()


	proc/eject_card()
		if (src.user_id)
			usr.put_in_hand_or_eject(src.user_id) // try to eject it into the users hand, if we can
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
