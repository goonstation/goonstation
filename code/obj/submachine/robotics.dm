// Robotics Stuff
// TODO: move to /modules/robotics

/obj/item/robojumper
	name = "cell cables"
	desc = "Used by cyborgs for emergency recharging of APCs."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "robojumper-plus"
	var/positive = 1 //boolean, if positive, then you will charge an APC with your cell, if negative, you will take charge from apc

	attack_self(var/mob/user as mob)
		positive = !positive
		icon_state = "robojumper-[positive? "plus": "minus"]"
		boutput(user, "<span class='alert'>The jumper cables will now transfer charge [positive ? "from you to the other device" : "from the other device to you"].</span>")

/obj/item/atmosporter
	name = "atmospherics transporter"
	desc = "Used for convenient transport of siphons and tanks."
	icon = 'icons/obj/items/device.dmi'
	icon_state = "atmosporter"
	var/capacity = 2

	attack_self(var/mob/user as mob)
		if (src.contents.len == 0) boutput(user, "<span class='alert'>You have nothing stored!</span>")
		else
			if (user.loc != get_turf(user.loc))
				boutput(user, "<span class='alert'>You're in too small a space to drop anything!</span>")
				return
			var/selection = tgui_input_list(user, "What do you want to drop?", "Atmospherics Transporter", src.contents)
			if(!selection) return
			if (istype(selection, /obj/machinery/fluid_canister))
				var/obj/machinery/fluid_canister/S = selection
				S.set_loc(get_turf(user.loc))
				S.contained = 0
			else if (istype(selection, /obj/machinery/portable_atmospherics))
				var/obj/machinery/portable_atmospherics/S = selection
				S.set_loc(get_turf(user.loc))
				S.contained = 0
			else return //no sparks for unintended items
			elecflash(user)



/obj/item/lamp_manufacturer
	name = "miniaturized lamp manufacturer"
	desc = "A small manufacturing unit to produce and (re)place lamps in existing fittings."
	icon = 'icons/obj/items/tools/lampman.dmi'
	icon_state = "borg-white"
	var/prefix = "borg"
	var/metal_ammo = 0
	var/max_ammo = 20
	var/load_interval = 5

	//These costs are in terms of borg cell charge. For crew every action takes 1 sheet (except a fitting gets its lamp immediately replaced making it 2 in total)
	var/cost_broken = 50 //For broken/burned lamps (the old lamp gets recycled in the tool)
	var/cost_empty = 75
	var/cost_fitting = 200 //Putting a new fitting on a turf
	var/cost_removal = 400 //Eating a fitting
	var/removing_toggled = FALSE
	var/setting = "white"
	var/dispensing_tube = /obj/item/light/tube
	var/dispensing_bulb = /obj/item/light/bulb
	//can be obj/machinery/light for wall tubes, obj/machinery/light/small for wall bulbs. Either mode does floor fittings because there's only one type of those
	var/dispensing_fitting = /obj/machinery/light
	var/list/setting_context_actions
	contextLayout = new /datum/contextLayout/experimentalcircle

	New()
		..()
		setting_context_actions = list()
		for(var/actionType in childrentypesof(/datum/contextAction/lamp_manufacturer)) //see context_actions.dm for those
			var/datum/contextAction/lamp_manufacturer/action = new actionType(src)
			setting_context_actions += action

	attack_self(var/mob/user as mob)
		user.showContextActions(setting_context_actions, src, contextLayout)

	get_desc()

		. = {"It is currently set to [removing_toggled == TRUE ? "remove fittings" : "dispense [setting] lamps"].<br>
		It will build new [dispensing_fitting == /obj/machinery/light/small ? "bulb" : "tube"] fittings."}

	afterattack(atom/A, mob/user as mob, reach, params)
		if (removing_toggled)
			if (!istype(A, /obj/machinery/light))
				return
			if (!check_ammo(user, cost_removal))
				return
			var/obj/machinery/light/lamp = A
			if (lamp.removable_bulb == 0)
				boutput(user, "This fitting isn't user-serviceable.")
				return
			boutput(user, "<span class='notice'>Removing fitting...</span>")
			playsound(user, 'sound/machines/click.ogg', 50, 1)
			SETUP_GENERIC_ACTIONBAR(user, src, 2 SECONDS, /obj/item/lamp_manufacturer/proc/remove_light, list(A, user), null, null, null, null)


		if (!istype(A, /turf/simulated) && !istype(A, /obj/window) || !check_ammo(user, cost_fitting))
			..()
			return

		if (istype(A, /turf/simulated/floor))
			boutput(user, "<span class='notice'>Installing a floor bulb...</span>")
			playsound(user, 'sound/machines/click.ogg', 50, 1)
			SETUP_GENERIC_ACTIONBAR(user, src, 2 SECONDS, /obj/item/lamp_manufacturer/proc/add_floor_light, list(A, user), null, null, null, null)


		else if (istype(A, /turf/simulated/wall) || istype(A, /obj/window))
			if (!(islist(params) && params["icon-y"] && params["icon-x"]))
				return
			var/atom/B = get_adjacent_floor(A, user, text2num(params["icon-x"]), text2num(params["icon-y"]))
			if (!istype(B, /turf/simulated/floor) && !istype(B, /turf/space))
				return
			if (locate(/obj/window) in B)
				return
			boutput(user, "<span class='notice'>Installing a wall [dispensing_fitting == /obj/machinery/light/small ? "bulb" : "tube"]...</span>")
			playsound(user, 'sound/machines/click.ogg', 50, 1)
			SETUP_GENERIC_ACTIONBAR(user, src, 2 SECONDS, /obj/item/lamp_manufacturer/proc/add_wall_light, list(A, B, user), null, null, null, null)


/obj/item/lamp_manufacturer/attackby(obj/item/W, mob/user)
	if (issilicon(user))
		boutput(user,"You don't have to load this, you're a robot! It uses power instead.")
	else
		if (istype(W, /obj/item/sheet))
			var/obj/item/sheet/S = W
			if (S.material.material_flags & MATERIAL_METAL)
				if (src.metal_ammo == src.max_ammo)
					boutput(user, "The lamp manufacturer is full.")
				else
					var/loadAmount = 0
					if (S.amount < src.load_interval)
						loadAmount = S.amount
					else
						loadAmount = src.load_interval
					if ((src.metal_ammo + loadAmount) > src.max_ammo)
						loadAmount = loadAmount + src.max_ammo - (src.metal_ammo + loadAmount)
					src.metal_ammo += loadAmount
					S.change_stack_amount(-loadAmount)
					playsound(src, 'sound/machines/click.ogg', 25, 1)
					src.inventory_counter.update_number(src.metal_ammo)
					boutput(user, "You load the metal sheet into the lamp manufacturer.")
			else
				boutput(user, "You can't load that! You need metal sheets.")
		else
			..()

/// Procs for the action bars
/obj/item/lamp_manufacturer/proc/add_wall_light(atom/A, turf/B, mob/user)
	var/obj/machinery/light/newfitting = new dispensing_fitting(B)
	newfitting.nostick = 0 //regular tube lights don't do autoposition for some reason.
	newfitting.autoposition(get_dir(B,A))
	newfitting.Attackby(src, user) //plop in an appropriate colour lamp
	if (!isghostdrone(user))
		elecflash(user)
	take_ammo(user, cost_fitting)

/obj/item/lamp_manufacturer/proc/add_floor_light(turf/A, mob/user)
	var/obj/machinery/light/newfitting = new /obj/machinery/light/small/floor(A)
	newfitting.Attackby(src, user) //plop in an appropriate colour lamp
	if (!isghostdrone(user))
		elecflash(user)
	take_ammo(user, cost_fitting)

/obj/item/lamp_manufacturer/proc/remove_light(obj/machinery/light/A, mob/user)
	qdel(A) //RIP
	if (!isghostdrone(user))
		elecflash(user)
	take_ammo(user, cost_removal)
	return

/obj/item/lamp_manufacturer/proc/check_ammo(mob/user, cost)
	if (issilicon(user))
		var/mob/living/silicon/S = user
		if (S.cell)
			if (S.cell.charge >= cost)
				return 1
			else
				boutput(user, "Not enough cell charge.")
			return 0
	else
		if (cost == cost_fitting) //hacky but placing fixtures is the only thing that takes 2 in total
			if (metal_ammo > 1)
				return 1
		else
			if (metal_ammo > 0)
				return 1
		boutput(user, "You need to load up more metal sheets.")
		return 0

/obj/item/lamp_manufacturer/proc/take_ammo(mob/user, cost) //Cost is in cell charge, everything costs 1 sheet
	if (issilicon(user))
		var/mob/living/silicon/S = user
		if (S.cell)
			S.cell.charge -= cost
	else
		if (metal_ammo > 0) //shouldn't be possible to fail
			metal_ammo--
			inventory_counter.update_number(metal_ammo)



/obj/item/robot_chemaster
	name = "mini-CheMaster"
	desc = "A cybernetic tool designed for chemistry cyborgs to do their work with. Use a beaker on it to begin."
	icon = 'icons/obj/items/device.dmi'
	icon_state = "minichem"
	flags = NOSPLASH
	var/working = 0

	attackby(obj/item/W, mob/user)
		if (!istype(W,/obj/item/reagent_containers/glass/)) return
		var/obj/item/reagent_containers/glass/B = W

		if(!B.reagents.reagent_list.len || B.reagents.total_volume < 1)
			boutput(user, "<span class='alert'>That beaker is empty! There are no reagents for the [src.name] to process!</span>")
			return
		if (working)
			boutput(user, "<span class='alert'>CheMaster is working, be patient</span>")
			return

		working = 1
		var/holder = src.loc
		var/the_reagent = input("Which reagent do you want to manipulate?","Mini-CheMaster",null,null) in B.reagents.reagent_list
		if (src.loc != holder || !the_reagent)
			return
		var/action = input("What do you want to do with the [the_reagent]?","Mini-CheMaster",null,null) in list("Isolate","Purge","Remove One Unit","Remove Five Units","Create Pill","Create Pill Bottle","Create Bottle","Create Patch","Create Ampoule","Do Nothing")
		if (src.loc != holder || !action || action == "Do Nothing")
			working = 0
			return

		switch(action)
			if("Isolate") B.reagents.isolate_reagent(the_reagent)
			if("Purge") B.reagents.del_reagent(the_reagent)
			if("Remove One Unit") B.reagents.remove_reagent(the_reagent, 1)
			if("Remove Five Units") B.reagents.remove_reagent(the_reagent, 5)
			if("Create Pill")
				var/obj/item/reagent_containers/pill/P = new/obj/item/reagent_containers/pill(user.loc)
				var/default = B.reagents.get_master_reagent_name()
				var/name = copytext(html_encode(input(user,"Name:","Name your pill!",default)), 1, 32)
				if(!name || name == " ") name = default
				if(name && name != default)
					phrase_log.log_phrase("pill", name, no_duplicates=TRUE)
				P.name = "[name] pill"
				B.reagents.trans_to(P,B.reagents.total_volume)
			if("Create Pill Bottle")
				// copied from chem_master because fuck fixing everything at once jeez
				var/default = B.reagents.get_master_reagent_name()
				var/pillname = copytext( html_encode( input( user, "Name:", "Name the pill!", default ) ), 1, 32)
				if(!pillname || pillname == " ")
					pillname = default
				if(pillname && pillname != default)
					phrase_log.log_phrase("pill", pillname, no_duplicates=TRUE)

				var/pillvol = input( user, "Volume:", "Volume of chemical per pill!", "5" ) as num
				if( !pillvol || !isnum(pillvol) || pillvol < 5 )
					pillvol = 5

				var/pillcount = round( B.reagents.total_volume / pillvol ) // round with a single parameter is actually floor because byond
				if(!pillcount)
					boutput(user, "[src] makes a weird grinding noise. That can't be good.")
				else
					var/obj/item/chem_pill_bottle/pillbottle = new /obj/item/chem_pill_bottle(user.loc)
					pillbottle.create_from_reagents(B.reagents, pillname, pillvol, pillcount)
			if("Create Bottle")
				var/obj/item/reagent_containers/glass/bottle/P = new/obj/item/reagent_containers/glass/bottle(user.loc)
				var/default = B.reagents.get_master_reagent_name()
				var/name = copytext(html_encode(input(user,"Name:","Name your bottle!",default)), 1, 32)
				if(!name || name == " ") name = default
				if(name && name != default)
					phrase_log.log_phrase("bottle", name, no_duplicates=TRUE)
				P.name = "[name] bottle"
				B.reagents.trans_to(P,30)
			if("Create Patch")
				var/datum/reagents/R = B.reagents
				var/input_name = input(user, "Name the patch:", "Name", R.get_master_reagent_name()) as null|text
				var/patchname = copytext(html_encode(input_name), 1, 32)
				if (isnull(patchname) || !length(patchname) || patchname == " ")
					working = 0
					return
				var/all_safe = 1
				for (var/reagent_id in R.reagent_list)
					if (!global.chem_whitelist.Find(reagent_id))
						all_safe = 0
				var/obj/item/reagent_containers/patch/P
				if (R.total_volume <= 15)
					P = new /obj/item/reagent_containers/patch/mini(user.loc)
					P.name = "[patchname] mini-patch"
					R.trans_to(P, P.initial_volume)
				else
					P = new /obj/item/reagent_containers/patch(user.loc)
					P.name = "[patchname] patch"
					R.trans_to(P, P.initial_volume)
				P.medical = all_safe
				P.on_reagent_change()
				logTheThing(LOG_CHEMISTRY, user, "created a [patchname] patch containing [log_reagents(P)].")
			if("Create Ampoule")
				var/datum/reagents/R = B.reagents
				var/input_name = input(user, "Name the ampoule:", "Name", R.get_master_reagent_name()) as null|text
				var/ampoulename = copytext(html_encode(input_name), 1, 32)
				if(!ampoulename)
					working = 0
					return
				if(ampoulename == " ")
					ampoulename = R.get_master_reagent_name()
				var/obj/item/reagent_containers/ampoule/A
				A = new /obj/item/reagent_containers/ampoule(user.loc)
				A.name = "ampoule ([ampoulename])"
				R.trans_to(A, 5)
				logTheThing(LOG_CHEMISTRY, user, "created a [ampoulename] ampoule containing [log_reagents(A)].")

		working = 0

/obj/item/robot_foodsynthesizer
	name = "food synthesizer"
	desc = "A portable food synthesizer."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "synthesizer"
	var/vend_this = null
	var/last_use = 0

	attack_self(var/mob/user as mob)
		if (!vend_this)
			var/holder = src.loc
			var/pickme = tgui_input_list(user, "Please make your selection!", "Item selection", list("Burger", "Cheeseburger", "Meat sandwich", "Cheese sandwich", "Snack", "Cola", "Water"))
			if (!pickme || src.loc != holder)
				return
			src.vend_this = pickme
			user.show_text("[pickme] selected. Click with the synthesizer on yourself to pick a different item.", "blue")
			return

		if (src.last_use && world.time < src.last_use + 50)
			user.show_text("The synthesizer is recharging!", "red")
			return

		else
			switch(src.vend_this)

				if ("Burger")
					new /obj/item/reagent_containers/food/snacks/burger/synthburger(get_turf(src))
				if ("Cheeseburger")
					new /obj/item/reagent_containers/food/snacks/burger/cheeseburger(get_turf(src))
				if ("Meat sandwich")
					new /obj/item/reagent_containers/food/snacks/sandwich/meat_s(get_turf(src))
				if ("Cheese sandwich")
					new /obj/item/reagent_containers/food/snacks/sandwich/cheese(get_turf(src))
				if ("Snack")
					var/pick_snack = rand(1,6)
					switch(pick_snack)
						if(1)
							new /obj/item/reagent_containers/food/snacks/fries(get_turf(src))
						if(2)
							new /obj/item/reagent_containers/food/snacks/popcorn(get_turf(src))
						if(3)
							new /obj/item/reagent_containers/food/snacks/donut(get_turf(src))
						if(4)
							new /obj/item/reagent_containers/food/snacks/ice_cream/goodrandom(get_turf(src))
						if(5)
							new /obj/item/reagent_containers/food/snacks/candy/negativeonebar(get_turf(src))
						if(6)
							new /obj/item/reagent_containers/food/snacks/moon_pie/jaffa(get_turf(src))
				if ("Cola")
					new /obj/item/reagent_containers/food/drinks/cola(get_turf(src))
				if ("Water")
					new /obj/item/reagent_containers/food/drinks/bottle/soda/bottledwater(get_turf(src))
				else
					user.show_text("<b>ERROR</b> - Invalid item! Resetting...", "red")
					logTheThing(LOG_DEBUG, user, "<b>Convair880</b>: [user]'s food synthesizer was set to an invalid value.")
					src.vend_this = null
					return

			if (isrobot(user)) // Carbon mobs might end up using the synthesizer somehow, I guess?
				var/mob/living/silicon/robot/R = user
				if (R.cell) R.cell.charge -= 100
			playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
			user.visible_message("<span class='notice'>[user] dispenses a [src.vend_this]!</span>", "<span class='notice'>You dispense a [src.vend_this]!</span>")
			src.last_use = world.time
			return

	attack(mob/M, mob/user, def_zone)
		src.vend_this = null
		user.show_text("Selection cleared.", "red")
		return

/obj/item/reagent_containers/glass/oilcan
	name = "oil can"
	desc = "Contains oil intended for use on cyborgs and robots."
	icon = 'icons/obj/robot_parts.dmi'
	icon_state = "oilcan"
	amount_per_transfer_from_this = 15
	splash_all_contents = 0
	w_class = W_CLASS_NORMAL
	rc_flags = RC_FULLNESS
	initial_volume = 120

	New()
		..()
		reagents.add_reagent("oil", 60)

/*
Jucier container.
By: SARazage
For: LLJK Goonstation
ported and crapped up by: haine
*/

/obj/item/reagent_containers/food/drinks/juicer
	name = "\improper Juice-O-Matic 3000"
	desc = "It's the Juice-O-Matic 3000! The pinicle of juicing technology! A revolutionary new juicing system!"
	icon = 'icons/obj/items/device.dmi'
	icon_state = "juicer"
	amount_per_transfer_from_this = 10
	initial_volume = 200
	tooltip_flags = REBUILD_DIST
	can_chug = 0

	afterattack(obj/target, mob/user)
		if (BOUNDS_DIST(user, src) > 0 || BOUNDS_DIST(user, target) > 0)
			user.show_text("You're too far away!", "red")

		if (istype(target, /obj/machinery) || ismob(target) || isturf(target)) // Do nothing if the user is trying to put it in a machine or feeding a mob.
			return

		if (target.is_open_container()) //Something like a glass. Player probably wants to transfer TO it.
			if (!src.reagents.total_volume)
				user.show_text("[src] is empty!", "red")
				return

			if (target.reagents.total_volume >= target.reagents.maximum_volume)
				user.show_text("[target] is full!", "red")
				return

			var/trans = src.reagents.trans_to(target, amount_per_transfer_from_this)
			user.show_text("You transfer [trans] unit\s of the solution to [target].")

		if (reagents.total_volume == reagents.maximum_volume) // See if the juicer is full.
			user.show_text("[src] is full!", "red")
			return

		if (istype(target, /obj/item/reagent_containers/food/snacks/plant)) // Check to make sure they're juicing food.
			if ((target.reagents.total_volume + src.reagents.total_volume) > src.reagents.maximum_volume)
				var/transamnt = src.reagents.maximum_volume - src.reagents.total_volume
				target.reagents.trans_to(src, transamnt)
				user.show_text("[src] makes a slicing sound as it destroys [target].<br>[src] juiced [transamnt] units, the rest is wasted.")
				playsound(src.loc, 'sound/machines/mixer.ogg', 50, 1) // Play a sound effect.
				qdel(target) // delete the fruit, it got juiced!
				return

			else
				user.show_text("[src] makes a slicing sound as it destroys [target].<br>[src] juiced [target.reagents.total_volume] units.")
				target.reagents.trans_to(src, target.reagents.total_volume) // Transfer it all!
				playsound(src.loc, 'sound/machines/mixer.ogg', 50, 1)
				qdel(target)
				return
		else
			user.show_text("Dang, the hopper only accepts food!", "red")


	get_desc(dist)
		if (dist <= 0)
			if (src.reagents && length(src.reagents.reagent_list))
				. += "<br>It contains:"
				for (var/datum/reagent/R in src.reagents.reagent_list)
					. += "[R.volume] units of [R.name]"

/*
Hydroponics Borg formula hose.
By: SARazage
For: LLJK Goonstation
ported and crapped up by: haine
*/

/obj/item/borghose
	name = "\improper Nutriant Hose 3000" // Name of the Module
	desc = "A nutriant hose for hydroponics work." // Description that shows up when examined
	icon = 'icons/obj/items/device.dmi' // Icon, just using a green cable coil for now.
	icon_state = "nutrient"
	flags = FPRINT | TABLEPASS | SUPPRESSATTACK
	var/amt_to_transfer = 10  // How much it transfers at once.
	var/charge_cost = 20 // How much the thing costs, I'm not sure if this is per tick or what. Can be adjusted.
	var/charge_tick = 0 // regulates if the borg is in a recharge station, to recharge reagents.
	var/recharge_time = 3 // How fast the module recharges, not really sure how this works yet.
	var/recharge_per_tick = 5 // how many units to add back to the tanks each tick

	var/list/hydro_reagents = list("saltpetre", "ammonia", "potash", "poo", "space_fungus", "water") // IDs of what we should dispense
	var/list/hydro_reagent_names = list() // the tank creation proc adds the names of the above reagents to this list
	var/list/tanks = list() // what tanks we have
	var/obj/item/reagent_containers/borghose_tank/active_tank = null // what tank is active
	tooltip_flags = REBUILD_DIST //if anyone implements this, add some rebuilds

	New() // So this goes through and adds all the reagents to the hose on creation. Pretty good for expandability.
		..()
		for (var/reagent in hydro_reagents)
			create_tank(reagent)

	process() //Every [recharge_time] seconds, recharge some reagents for the cyborg
		src.charge_tick ++
		if (src.charge_tick >= src.recharge_time)
			src.regenerate_reagents()
			src.charge_tick = 0

	proc/create_tank(var/reagent) // The actual add_reagent function to add new reagents to the hose.
		var/obj/item/reagent_containers/borghose_tank/new_tank = new /obj/item/reagent_containers/borghose_tank(src)
		new_tank.reagents.add_reagent(reagent, 40)
		new_tank.label = reagent
		new_tank.label_name = reagent_id_to_name(reagent)
		new_tank.name = "[new_tank.label_name] tank"
		src.tanks += new_tank
		src.hydro_reagent_names += new_tank.label_name // the name list is so we don't have to call reagent_id_to_name() each time we wanna know the names of our reagents

	attack(mob/M, mob/user)
		return // Don't attack people with the hoses, god you people!

	proc/regenerate_reagents()
		if (isrobot(src.loc))
			var/mob/living/silicon/robot/R = src.loc // I'm not sure why it's src.loc and not src. (src is the hose, src.loc is where the hose is)
			if (R?.cell) // If the robot's alive and there's power.
				var/full_tanks = 0 // to keep track of when we're good to remove ourselves from processing_items
				for (var/obj/item/reagent_containers/borghose_tank/tank in src.tanks) // Regenerate all formulas at once.
					var/tank_max = tank.reagents.maximum_volume // easier than writing tank.reagents.total_volume/etc over and over
					var/tank_vol = tank.reagents.total_volume
					if (tank_vol >= tank_max) // if it's already full
						full_tanks ++ // add to the list of full tanks
						continue // then skip it
					var/add_amt = min((tank_max - tank_vol), src.recharge_per_tick) // how much we'll be adding, in case the room left in the tank is less than recharge_per_tick
					if (tank.label) // who knows, maybe somehow you ended up with no label?
						tank.reagents.add_reagent(tank.label, add_amt)
						R.cell.use(src.charge_cost)
						if (tank.reagents.total_volume >= tank.reagents.maximum_volume)
							full_tanks ++
					else
						full_tanks ++ // just in case, we don't need this taking up extra processing if it's just gunna fail every time this runs
				if (full_tanks >= src.tanks.len && (src in processing_items))
					processing_items.Remove(src)

	attack_self(mob/user)
		var/switch_tank = input(user, "What reagent do you want to dispense?") as null|anything in src.hydro_reagent_names
		if (!switch_tank)
			return
		for (var/obj/item/reagent_containers/borghose_tank/tank in src.tanks)
			if (src.active_tank == tank)
				return
			if (tank.label_name == switch_tank)
				src.active_tank = tank
				user.show_text("[src] is now dispensing [switch_tank].")
				playsound(loc, 'sound/effects/pop.ogg', 50, 0) // Play a sound effect.
				return

	afterattack(obj/target, mob/user)
		if (istype(target, /obj/machinery/plantpot/))
			if (!src.active_tank)
				user.show_text("No tank is currently active.", "red")
				return

			if (!src.active_tank.reagents || !src.active_tank.reagents.total_volume) // vOv
				user.show_text("[src] is currently out of this reagent.", "red")
				return

			if (target.reagents.total_volume >= target.reagents.maximum_volume)
				user.show_text("[target] is full.", "red")
				return

			var/trans = src.active_tank.reagents.trans_to(target, amt_to_transfer)
			user.show_text("You transfer [trans] unit\s of the solution to [target]. [active_tank.reagents.total_volume] unit\s remain.", "blue")
			playsound(loc, 'sound/impact_sounds/Liquid_Slosh_1.ogg', 25, 0) // Play a sound effect.
			processing_items |= src
		else
			return ..() // call your parents!!

	get_desc(dist)
		if (dist <= 0)
			. += src.DescribeContents()

	proc/DescribeContents()
		var/data = null
		for (var/obj/item/reagent_containers/borghose_tank/tank in src.tanks)
			if (tank.reagents && tank.label)
				data += "<br>It currently has [tank.reagents.total_volume] unit\s of [tank.label_name] stored."
		if (data)
			return data

/obj/item/reagent_containers/borghose_tank
	name = "borghose reagent tank"
	desc = "you shouldn't see me!!"
	initial_volume = 40
	var/label = null // the ID of the reagent inside
	var/label_name = null // the name of the reagent inside, so we don't have to keep calling reagent_id_to_name()
