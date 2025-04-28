/*
Contents:
Skull of Souls
Tommyize proc
Donald Trumpet
SpyGUI
Chemistry spectrometer prototype
Retractable solar panel prototype
Fibre wire
*/


//--------------------------//
//The pretty darn mean skull
//That's nice to ghosts
//		Yay
//-------------------------//
/obj/item/soulskull
	name = "ominous skull"
	desc = "This skull gives you the heebie-jeebies."
	icon = 'icons/obj/items/organs/skull.dmi'
	icon_state = "skull_ominous"
	var/being_mean = 0

	attack_hand(mob/M)
		if(!being_mean)
			..()
			M.show_text("<B><I>It burns...!</I></B>", "red")
			if(ishuman(M)) evil_act(M)
/* oops didn't quite think this through
	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/parts/robot_parts/leg))
			var/obj/machinery/bot/skullbot/B = new /obj/machinery/bot/skullbot
			B.icon = icon('icons/obj/bots/aibots.dmi', "skullbot-ominous")
			B.name = "ominous skullbot"
			boutput(user, SPAN_NOTICE("You add [W] to [src]. That's neat."))
			B.set_loc(get_turf(user))
			qdel(W)
			qdel(src)
			return
*/
	proc/evil_act(mob/living/carbon/human/H)

		var/list/mob/dead/observer/possible_targets = list()
		var/list/mob/dead/observer/priority_targets = list()


		if(ticker?.mode) //Yes, I'm sure my runtimes will matter if the goddamn TICKER is gone.
			for(var/datum/mind/M in (ticker.mode.Agimmicks | ticker.mode.traitors)) //We want an EVIL ghost
				if(!M.get_player().dnr && M.current && isobserver(M.current) && M.current.client && M.special_role != ROLE_VAMPTHRALL && M.special_role != ROLE_MINDHACK)
					priority_targets.Add(M.current)

		if(!priority_targets.len) //Okay, fine. Any ghost. *sigh

			for (var/client/C)
				var/mob/dead/observer/O = C.mob
				if (!istype(C)) continue
				if(O.mind && !O.mind.get_player()?.dnr)
					possible_targets.Add(O)


		if(!priority_targets.len && !length(possible_targets)) return //Gotta have a ghostie

		being_mean = 1
		H.canmove = 0
		H.drop_item(src)
		src.set_loc(H.loc)
		src.layer = EFFECTS_LAYER_4
		playsound(src.loc, 'sound/ambience/spooky/Void_Calls.ogg', 40, 1)
		SPAWN(0) animate_levitate(src, -1)
		H.emote("scream")

		H.changeStatus("knockdown", 10 SECONDS)

		SPAWN(7 SECONDS)
			if(!H)
				being_mean = 0
				return
			H.emote("faint")
			H.changeStatus("unconscious", 15 SECONDS)
			H.show_text("<I><font size=5>You feel your mind drifting away from your body!</font></I>", "red")

			playsound(src.loc, 'sound/effects/ghost.ogg', 50, 1)

			if(!H.mind)
				H.ghostize()
			else
				if(priority_targets.len) //Do we have an evil ghost?
					H.mind.swap_with(pick(priority_targets))
					H.show_text("<I><B>You hear a sinister voice in your head... \"I have brought you back to do evil once more!\"</B></I>")
				else if(possible_targets.len) //Do we have a plain ol' ghost?
					H.mind.swap_with(pick(possible_targets))
				else //How the fuck did we even get here??
					H.ghostize()

			FLICK("skull_ominous_explode", src)
			sleep(1.5 SECONDS)
			playsound(src.loc, 'sound/effects/ghostlaugh.ogg', 70, 1)
			sleep(1.5 SECONDS)
			qdel(src)

//////////////////////////////
//Tommyize
////////////////////////////
proc/Create_Tommyname()
	return pick("Toh", "Tho", "To") + pick("mmh", "mh", "mm", "m") + pick("i", "eh", "yh", "ee", "u") + " " + pick("Wa", "Wi", "Wu", "Wee", "We") + pick("z", "zh", "se", "seh") + pick("oo", "oh", "eeh", "au", "ay", "uu", "uh")

/mob/proc/tommyize()
	src.transforming = 1
	src.canmove = 0
	src.invisibility = INVIS_ALWAYS
	for(var/obj/item/clothing/O in src)
		src.u_equip(O)
		if (O)
			O.set_loc(src.loc)
			O.dropped(src)
			O.layer = initial(O.layer)

	var/mob/living/carbon/human/tommy/T = new(src.loc)
	if(src.mind)
		src.mind.transfer_to(T)
	else
		T.key = src.key

	SPAWN(1 SECOND)
		qdel(src)

/mob/living/carbon/human/proc/tommyize_reshape()
	//Set up the new appearance
	if(src.bioHolder)
		src.bioHolder.AddEffect("accent_tommy")
		if(src.bioHolder.mobAppearance)
			var/datum/appearanceHolder/AH = src.bioHolder.mobAppearance
			AH.gender = "male"
			AH.customizations["hair_bottom"].style =  new /datum/customization_style/hair/long/dreads
			AH.customizations["hair_bottom"].color = "#101010"
			AH.customizations["hair_middle"].style =  new /datum/customization_style/none
			AH.customizations["hair_top"].style =  new /datum/customization_style/none
			AH.s_tone = "#FAD7D0"
			src.bioHolder.AddEffect("accent_tommy")

	src.gender = "male"
	src.real_name = Create_Tommyname()
	src.sound_list_laugh = list('sound/voice/tommy_hahahah.ogg', 'sound/voice/tommy_hahahaha.ogg')
	src.sound_list_scream = list('sound/voice/tommy_you-are-tearing-me-apart-lisauh.ogg', 'sound/voice/tommy_did-not-hit-hehr.ogg')
	src.sound_list_flap = list('sound/voice/tommy_weird-chicken-noise.ogg')

	for(var/obj/item/clothing/O in src)
		src.u_equip(O)
		if (O)
			if(istype(O, /obj/item/clothing/shoes/black) || istype(O, /obj/item/clothing/under/suit))
				O.cant_drop = 1
				O.cant_other_remove = 1
				O.cant_self_remove = 1
				continue

			O.set_loc(src.loc)
			O.dropped(src)
			O.layer = initial(O.layer)

	src.equip_new_if_possible(/obj/item/clothing/shoes/black {cant_drop = 1; cant_other_remove = 1; cant_self_remove = 1} , SLOT_SHOES)
	src.equip_new_if_possible(/obj/item/clothing/under/suit/black {cant_drop = 1; cant_other_remove = 1; cant_self_remove = 1} , SLOT_W_UNIFORM)
	src.equip_new_if_possible(/obj/item/football, SLOT_IN_BACKPACK)

	src.sound_scream = 'sound/voice/tommy_you-are-tearing-me-apart-lisauh.ogg'
	src.sound_fingersnap = 'sound/voice/tommy_did-not-hit-hehr.ogg'

	src.update_colorful_parts()

//------------------------//
//Tommy gun
//------------------------//

/datum/projectile/tommy
	name = "space-tommy disruption"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "random_thing"
//How much of a punch this has, tends to be seconds/damage before any resist
	stun = 10
//How much ammo this costs
	cost = 10
//How fast the power goes away
	dissipation_rate = 1
//How many tiles till it starts to lose power
	dissipation_delay = 10
//name of the projectile setting, used when you change a guns setting
	sname = "Tommify"
//file location for the sound you want it to play
	shot_sound = 'sound/voice/tommy_hauh.ogg'
//How many projectiles should be fired, each will cost the full cost
	default_firemode = /datum/firemode/single
//What is our damage type
	damage_type = 0
	//With what % do we hit mobs laying down
	hit_ground_chance = 10
	//Can we pass windows
	window_pass = 0

	on_hit(atom/hit)
		if(ishuman(hit))
			hit:tommyize_reshape()
			playsound(hit.loc, 'sound/voice/tommy_hey-everybody.ogg', 50, 1)
		else if(ismob(hit))
			if (issilicon(hit))
				return
			hit:tommyize()
			playsound(hit.loc, 'sound/voice/tommy_hey-everybody.ogg', 50, 1)

///////////////////////////////////////Tommy Gun

/obj/item/gun/energy/tommy_gun
	name = "Tommy Gun"
	icon = 'icons/obj/items/guns/kinetic.dmi'
	icon_state = "tommygun"
	m_amt = 4000
	rechargeable = 1
	force = 0
	cell_type = /obj/item/ammo/power_cell/high_power
	desc = "It smells of cheap cologne and..."

	New()
		set_current_projectile(new/datum/projectile/tommy)
		projectiles = list(new/datum/projectile/tommy)
		..()

	shoot(turf/target, turf/start, mob/user, POX, POY, is_dual_wield, atom/called_target = null)
		for(var/mob/O in AIviewers(user, null))
			O.show_message(SPAN_ALERT("<B>[user] fires the [src] at [target]!</B>"), 1, SPAN_ALERT("You hear a loud crackling noise."), 2)
		sleep(0.1 SECONDS)
		return ..(target, start, user)

	update_icon()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE) & CELL_SUFFICIENT_CHARGE)
			src.icon_state = "tommygun[(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE) & CELL_SUFFICIENT_CHARGE) ? "" : "-empty"]"
			return

///////////////////////////////////////Analysis datum for the spectrometer

/datum/spectro_analysis

	proc/analyze_reagents(var/datum/reagents/R, var/check_recipes = 0)
		if(length(R?.reagent_list))
			if(check_recipes)
				. = analyze_reagent_components(R.reagent_list)
			else
				. = analyze_reagent_list(R.reagent_list)



	//Analyze the recipe for each reagent id. If there's more than one id this will be a fucking mess.
	proc/analyze_reagent_components(var/list/reagent_ids)
		if(reagent_ids.len)
			var/output = list()
			for (var/id in reagent_ids)

				var/datum/chemical_reaction/recipe = chem_reactions_by_id[id]
				if(length(recipe?.required_reagents))
					analyze_reagent_list(recipe.required_reagents, output)
				else
					for(var/i=0, i<rand(2,7), i++) //If it doesn't have a recipe, just spit out some random data
						analyze_single(output, md5(rand(100,100000)))

			return output

		return null

	//Calculates the result for every reagent ID in a list
	proc/analyze_reagent_list(var/list/reagent_ids, var/list/output)
		if(reagent_ids.len)
			if(!output) output = list()
			for(var/RID in reagent_ids)
				if(reagents_cache[RID])
					output = analyze_single(output, RID)
				else
					logTheThing(LOG_DEBUG, null, "<B>SpyGuy/spectro:</B> attempted to analyze invalid reagent id: [RID]")

			return output

	//This is mainly a helper
	proc/analyze_single(var/list/base, var/id)
		var/hash = md5("AReally[id]ShittySalt")
		var/listPos = calc_start_point(hash)

		for(var/i=1, i <= length(hash), i+=2)
			var/block = copytext(hash, i, i+2)
			if (isnull(base["[listPos]"]))
				base["[listPos]"] = hex2num(block)
			else
				base["[listPos]"]  += hex2num(block)
			listPos += (hex2num(copytext(block,1,2)) + hex2num(copytext(block,2)))
		return base

	//So is this
	proc/calc_start_point(var/hash)
		for(var/i = 1; i <= length(hash); i++)
			var/temp = copytext(hash, i, i+1)
			temp = hex2num(temp)
			. += temp

		. = round(. * 1.5)

/////////////////////////////// Trigger

/obj/trigger
	name = "trigger"
	desc = "warning"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x2"
	anchored = ANCHORED
	invisibility = INVIS_ALWAYS

	Crossed(atom/movable/AM)
		..()
		on_trigger(AM)

	proc/on_trigger(var/atom/movable/triggerer)


/obj/trigger/critter //Wakes up all critters in an area
	name = "critter trigger"
	var/area/assigned_area = null

	on_trigger(atom/movable/triggerer)
		if(isliving(triggerer) || locate(/mob) in triggerer)
			if(!assigned_area) assigned_area = get_area(src)
			assigned_area.wake_critters(isliving(triggerer) ? triggerer : locate(/mob/living) in triggerer)

/obj/trigger/throw
	name = "throw trigger"
	var/throw_dir = NORTH

	on_trigger(var/atom/movable/triggerer)
		if(isobserver(triggerer)) return
		var/atom/target = get_edge_target_turf(src, src.throw_dir)
		if (target)
			triggerer.throw_at(target, 50, 1)


/obj/trigger/cluwnegib
	name = "floor cluwne trigger"
	desc = "The name belies the fact that floor cluwnes are not real."

	on_trigger(var/atom/movable/triggerer)
		if(isobserver(triggerer)) return
		var/mob/M = triggerer
		if(istype(M))
			M.cluwnegib(10)

/obj/trigger/badmantrigger
	name = "Death Badman Meeting Zone"
	desc = "He's very angry he lost the election."
	var/activated = 0

	on_trigger(var/atom/movable/triggerer)
		//Sanity check, thanks readster.
		if(isobserver(triggerer)) return
		var/mob/M = triggerer
		if(!istype(M))
			return
		if(istype(M, /mob/living/carbon/human) && !activated)
			switch(M.ckey)
				if("hydrofloric")
					return
				if("kyle2143")
					return
				if("johnwarcrimes")
					return
				else
					activated = 1
					sleep(2 SECONDS)
					var/startx = 1
					var/starty = 1
					var/mob/badmantarget = M
					boutput(badmantarget, "<span style=\"color:black\"> <B> You hear a voice in your head, 'You're not supposed to be here'. </B>")
					playsound(badmantarget, 'sound/misc/american_patriot.ogg', 50, TRUE, -1)
					sleep(10 SECONDS)
					startx = badmantarget.x - rand(-11, 11)
					starty = badmantarget.y - rand(-11, 11)
					var/turf/pickedstart = locate(startx, starty, badmantarget.z)
					new /obj/badman(pickedstart, badmantarget)
					sleep(15 SECONDS)
					activated = 0

////////////////////////////// Donald Trumpet
/datum/projectile/energy_bolt_v/trumpet
	name = "trumpet bolt"
	shot_sound = 'sound/musical_instruments/Bikehorn_2.ogg'

	on_hit(atom/hit)
		..()

		if(ishuman(hit))
			var/mob/living/carbon/human/H = hit
			if(!H.is_bald())
				var/obj/item/clothing/head/wig/W = H.create_wig()
				H.drop_from_slot(H.head)
				H.force_equip(W, SLOT_HEAD)
				H.update_colorful_parts()

/obj/item/gun/energy/dtrumpet
	name = "Donald Trumpet"
	desc = "You can tell this gun has been fired!"
	icon = 'icons/obj/instruments.dmi'
	icon_state = "trumpet"
	cell_type = /obj/item/ammo/power_cell/high_power
	New()
		set_current_projectile(new/datum/projectile/energy_bolt_v/trumpet)
		projectiles = list(new/datum/projectile/energy_bolt_v/trumpet)
		..()

////////////////////////////// Power machine
/obj/machinery/power/debug_generator
	name = "mysterious petrol generator"
	desc = "Holds untold powers. Literally. Untold power. Get it? Power. Watts? Ok, fine. This thing spits out unlimited watt-volts!! There. I said it!"
	icon_state = "ggen0"
	density = 1
	var/generating = 0
	New()
		..()
		//UnsubscribeProcess()
	attack_hand(mob/user)
		if(!user) return
		generating = (input("Select the amount of power this machine should generate (in MW))", "Playing with power") as num) * 1e6
		if(generating > 0)
			SubscribeToProcess()
			powernet = get_direct_powernet()
			icon_state = "ggen0"
		else
			UnsubscribeProcess()
			powernet = null
			icon_state = "ggen1"

	process()
		..()
		if(!generating) UnsubscribeProcess()
		add_avail(generating)

////////////////////////////// Spy GUI (ha ha ha ha)
#define INIT_CHECK if(!src.initialized) src.initialize()
/datum/spyGUI
	var/target_file = null
	var/desired_file = ""
	var/target_window = ""
	var/target_params = ""
	var/list/mob/subscribed_mobs = new
	var/list/mob/connecting = new
	var/datum/master = null

	var/max_retries = 5
	var/time_per_try = 2

	var/validate_user = 0
	var/initialized = 0

	New(var/filename, var/windowname, var/parameters, var/datum/master)
		..()
		target_window = windowname
		target_params = parameters
		desired_file = filename
		src.master = master

	proc/initialize()
		target_file = grabResource(desired_file)
		initialized = 1

	proc/getFile()
		if(!target_file)
			target_file = grabResource(desired_file)
		return target_file


	proc/displayInterface(var/mob/target, var/initData)
		INIT_CHECK //Initialize the SpyGUI instance on use
		if((target in connecting))
			return
		if(!target.client)
			return
		connecting[target] = initData
		var/retries = max_retries
		var/extrasleep = 0
		target.Browse(getFile(), "window=[target_window];[target_params]")
		onclose(target, target_window, src)

		do
			if(winexists(target, "[target_window].browser")) //Fuck if I know
				target << output("\ref[src]", "[target_window].browser:setRef")
			sleep(time_per_try + extrasleep++)
		while(retries-- > 0 && (target in connecting)) //Keep trying to send the UI update until it times out or they get it.

		if(target in connecting)
			connecting -= target
			target.Browse(null, target_window)

	proc/unsubscribeTarget(var/mob/target, close=1)
		INIT_CHECK //Initialize the SpyGUI instance on use
		if(close)
			target.Browse(null, target_window)
		subscribed_mobs -= target


	Topic(href, href_list)
		INIT_CHECK //Initialize the SpyGUI instance on use
		..()
		DEBUG_MESSAGE("Received: [href]")
		if (href_list["ackref"] )
			var/D = connecting[usr]
			if(D)
				connecting -= usr
				subscribed_mobs |= usr
				sendData(usr, D, "setUIState")
			return
		if (href_list["close"])
			subscribed_mobs -= usr


		if(master != src)
			master.Topic(href, href_list) //Pass the href on

	proc/validateSubscriber(var/mob/sub)
		if(!sub.client) //If the subscriber lacks a client then rip they
			return 0

		if(!validate_user)
			return 1

		. = 1
		if(sub.stat) . = 0 //Not dead / unconscious
		if ( . && istype(master, /atom)) //Range check.
			. = (sub in range(1, master))

	proc/sendToSubscribers(var/data, var/handler)
		INIT_CHECK //Initialize the SpyGUI instance on use
		//DEBUG_MESSAGE("Sending: [data] to [handler ? handler : "-nothing-"]")
		for(var/mob/M in subscribed_mobs)
			if(validateSubscriber(M))
				sendData(M, data, handler)
			else
				unsubscribeTarget(M)

	proc/sendData(var/mob/target, var/data, var/handler)
		var/list/L = new
		L += handler
		L += data
		var/O = list2params(L)
		target << output(O, "[target_window].browser:receiveData")

#undef INIT_CHECK

#define STAT_STANDBY 0
#define STAT_MOVING 1
#define STAT_EXTENDED 2

#define DEFAULT_ANIMATION_TIME 10
////////////////////////////// Solar Panel thingamajig
/obj/solar_control
	name = "solar panel servo"
	desc = "This machine contains a neatly-folded solar panel, for use when the ship is at little risk of external impacts and low on power."
	//invisibility = INVIS_ALWAYS_ISH
	icon = 'icons/obj/machines/nuclear.dmi'
	icon_state = "engineoff"
	var/extension_dir = WEST
	var/num_panels = 4
	var/panel_width = 2
	var/panel_length = 5
	var/panel_space = 1
	var/controller_padding = 1
	var/station_padding = 2

	var/status = 0

	var/list/atom/created_atoms = list()

	//TODO:
	//Pooling and reuse of components

////Debug verbs
/obj/solar_control/verb/extend()
	set src in range(1)
	set category = "Local"
	extend_panel()

/obj/solar_control/verb/retract()
	set src in range(1)
	set category = "Local"
	retract_panel()

/obj/solar_control/proc/extend_panel()
	if(status != STAT_STANDBY) return
	icon_state = "engineon"
	status = STAT_MOVING
	var/paneldir1 = turn(extension_dir, 90)
	var/paneldir2 = turn(extension_dir, -90)
	var/list/turf/panelturfs = list()
	var/turf/walker = get_turf(src)
	DEBUG_MESSAGE("Extending panel at [log_loc(src)]. extension_dir: [extension_dir] ([dir2text(extension_dir)]), paneldir1: [paneldir1] ([dir2text(paneldir1)]), paneldir2: [paneldir2] ([dir2text(paneldir2)])")
	var/total_len = station_padding + controller_padding + (panel_space * (num_panels -1)) + num_panels * panel_width
	DEBUG_MESSAGE("Determined total length of panel to be [total_len] tiles.")

	//Create the initial padding
	DEBUG_MESSAGE("Creating stationside padding.")
	var/list/catwalk = list(/turf/simulated/floor/airless/plating/catwalk, /obj/mesh/catwalk)
	for(var/i = 0; i < station_padding;i++)
		move_create_obj(catwalk, walker, extension_dir, extension_dir) //Then we walk outwards, creating stuff as we go along
		walker = get_step(walker,extension_dir)
		/*
		if(i == 0)
			SPAWN(0)
				move_create_obj(list(new /obj/lattice{icon_state="lattice-dir-b"}), walker, paneldir1, paneldir2 | extension_dir)
			move_create_obj(list(new /obj/lattice{icon_state="lattice-dir-b"}), walker, paneldir2, paneldir1 | turn(extension_dir, 180))
		*/

	DEBUG_MESSAGE("Creating panel segments.")
	//Create the panels themselves
	for(var/i = 0; i < num_panels; i++)
		for(var/j = 0; j < (panel_space + panel_width);j++)
			move_create_obj(catwalk, walker, extension_dir, (j >= panel_space) ? paneldir1 : extension_dir)
			walker = get_step(walker, extension_dir)
			if(j >= panel_space) panelturfs += walker

	DEBUG_MESSAGE("Creating controller padding")
	for(var/i = 0; i < controller_padding; i++)
		move_create_obj(catwalk, walker, extension_dir, extension_dir) //Then we walk outwards, creating stuff as we go along
		walker = get_step(walker,extension_dir)


	DEBUG_MESSAGE("Creating solar panels")
	var/list/solar_list = list(/turf/simulated/floor/airless/solar, /obj/machinery/power/solar)
	for(var/turf/T in panelturfs)
		SPAWN(0)
			var/turf/w1 = T
			var/turf/w2 = T
			for(var/i = 0; i < panel_length; i++)
				SPAWN(-1)
					move_create_obj(solar_list, w1, paneldir1, paneldir1)
				w1 = get_step(w1, paneldir1)
				move_create_obj(solar_list, w2, paneldir2, paneldir2)
				w2 = get_step(w2, paneldir2)

	DEBUG_MESSAGE("Creating solar controller")
	move_create_obj(list(/turf/simulated/floor/plating/airless, /obj/machinery/power/tracker), walker, extension_dir)
	walker = get_step(walker,extension_dir)
	SPAWN(0) move_create_obj(list(new /obj/lattice{icon_state="lattice-dir-b"}), walker, paneldir1, paneldir2)
	move_create_obj(list(new /obj/lattice{icon_state="lattice-dir-b"}), walker, paneldir2, paneldir1)

	status = STAT_EXTENDED
	icon_state = "engineoff"

/obj/solar_control/proc/retract_panel()
	if(status != STAT_EXTENDED) return
	status = STAT_MOVING

	var/list/atom/panels = get_panels()

	for(var/i = panels.len; i > 0; i--)
		var/list/atom/L = panels[i]
		for(var/atom/A in L)
			SPAWN(0)
				move_and_delete_object(A)
		sleep(DEFAULT_ANIMATION_TIME)

	while(length(created_atoms) > 0)
		var/atom/A = created_atoms[created_atoms.len]
		created_atoms.len--
		if(istype(A, /turf))
			var/turf/T = A
			T.ReplaceWithSpace()
		else if(istype(A,/obj))
			move_and_delete_object(A)


	status = STAT_STANDBY


/obj/solar_control/proc/get_panels()
	var/list/atom/out = list()
	var/list/atom/temp

	out.len = panel_length //A list containing all the solar panels sorted on distance from centreline
	for(var/i = created_atoms.len; i > 0; i--)
		var/atom/A = created_atoms[i]
		if(istype(A, /obj/machinery/power/solar) || istype(A, /turf/simulated/floor/airless/solar))
			var/dist = get_dist_from_centreline(A)
			temp = out[dist]
			if(!temp)
				temp = list()
				out[dist] = temp
			temp += A

	return out

/obj/solar_control/proc/move_and_delete_object(var/obj/O, var/animtime = DEFAULT_ANIMATION_TIME)
//calculate new px / py
	if(istype(O, /turf))
		var/turf/T = O
		var/obj/movedummy/MD = new /obj/movedummy
		MD.mimic_turf(T.type, 0)
		MD.set_loc(T)
		T.ReplaceWithSpace()
		O = MD

	var/tdir = get_reciprocal(O)
	var/npx = 0
	if(tdir & (EAST | WEST))
		if(tdir & WEST)
			npx = -32
		else if(tdir & EAST)
			npx = 32
	var/npy = 0
	if(tdir & (NORTH | SOUTH))
		if(tdir & NORTH)
			npy = 32
		else if (tdir & SOUTH)
			npy = -32

	animate_slide(O, npx, npy, animtime)
	sleep(animtime)
	if(istype(O, /obj/movedummy))
		qdel(O)
	else
		qdel(O)


/obj/solar_control/proc/move_create_obj(var/list/atom/to_create, var/turf/startturf, var/movedir, var/setdir=null, var/animtime = DEFAULT_ANIMATION_TIME)
	//calculate initial px / py
	var/ipx = 0
	if(movedir & (EAST | WEST))
		if(movedir & WEST)
			ipx = 32
		else if(movedir & EAST)
			ipx = -32
	var/ipy = 0
	if(movedir & (NORTH | SOUTH))
		if(movedir & NORTH)
			ipy = -32
		else if (movedir & SOUTH)
			ipy = 32


	DEBUG_MESSAGE("Initial offsets calculated based on movedir: [movedir] ([dir2text(movedir)]) as ipx: [ipx], ipy: [ipy]")
	var/is_turf = 0
	var/turf/T = get_step(startturf, movedir)
	var/turf_type = null
	for(var/t_type in to_create)
		if(ispath(t_type, /turf))
			turf_type = t_type
			break
	SPAWN(0)
		for(var/t_type in to_create)
			var/obj/O
			is_turf = ispath(t_type, /turf) //If it's a turf we need some special handling.

			if(istype(t_type, /obj))
				O = t_type
			else if(ispath(t_type))
				if(!is_turf)
					O = new t_type(null)
				else
					var/obj/movedummy/MD = new /obj/movedummy
					MD.mimic_turf(t_type, animtime)
					O = MD

			else if(!ispath(t_type))
				CRASH("move_create_obj not provided with type")
			if(!is_turf)
				created_atoms += O
			O.pixel_x = ipx
			O.pixel_y = ipy
			if(setdir)
				O.set_dir(setdir)
			O.set_loc(T)
			animate_slide(O, 0, 0, animtime, LINEAR_EASING)

	playsound(T, 'sound/effects/airbridge_dpl.ogg', 50, TRUE)
	sleep(animtime)
	if(turf_type)
		DEBUG_MESSAGE("Creating [turf_type] at [log_loc(T)]")
		var/turf/NT = new turf_type(T)
		if(setdir) NT.set_dir(setdir)
		created_atoms += NT


//Helpers
/obj/solar_control/proc/get_reciprocal(var/atom/A)
	var/d = get_dir(A,src)
	d &= ~(extension_dir | turn(extension_dir, 180)) //Turn off the bits parallel to the extension_dir
	if(!d) d = turn(extension_dir, 180) //If this wound up turning off all the bits, the dir is on the extension line
	//Look, I'm Swedish, I don't know your goddamn mathwords
	return d

/obj/solar_control/proc/get_dist_from_centreline(var/atom/A) //Finds the distance from the closest point on the extension line
	if(extension_dir & (NORTH|SOUTH) )
		.= abs(A.x - src.x)
	else if ( extension_dir & (EAST|WEST) )
		.= abs(A.y - src.y)

	DEBUG_MESSAGE("get_dist from [log_loc(A)] returned: [.]")


//The dummy object that imitates a turf
/obj/movedummy
	name = "Dummy object."
	invisibility = INVIS_ALWAYS

/obj/movedummy/proc/mimic_turf(var/turf_type, var/TTL)
	ASSERT(ispath(turf_type, /turf))
	var/turf/T = turf_type
	src.name = initial(T.name)
	src.desc = initial(T.desc)
	src.icon = initial(T.icon)
	src.icon_state = initial(T.icon_state)
	src.set_density(initial(T.density))
	src.set_opacity(initial(T.opacity))
	src.set_dir(initial(T.dir))
	src.layer = initial(T.layer)
	src.invisibility = INVIS_NONE
	if(TTL)
		SPAWN(TTL)
			qdel(src)

#undef STAT_STANDBY
#undef STAT_MOVING
#undef STAT_EXTENDED
#undef DEFAULT_ANIMATION_TIME

//Aw heck


////////////////////////////// Fibre wire

/*
	TO DO:
	- = Must have
	? = Nice to have
	* = Done

	* Only allow someone to initiate a stranglehold from behind. Eg - someone facing NORTH should only be strangleable from SOUTHWEST, SOUTH and SOUTHEAST
	* setTwoHanded does not really cover cases where both hands have contents during the switch, if done while the item is equipped. This needs handling
	* There's some weirdness with dropping the garrote and trying to pick it back up calling attack_self() instead of the pick up proc. Test & fix whatever causes it.
	* The art needs considerable improvement, good grief
	* Stunned targets should not take facing into consideration
	* Faster death
	* Lower slowdown when opened
	? Break free message in case whoever manages to avoid the strangle in the action bar
	? Improve grab strangles to jostle the target mob slightly? Make it look more fierce. Make_Jittery() or something similar,  perhaps?
*/

/obj/item/garrote
	name = "fibre wire"
	desc = "A sturdy wire between two handles. Could be used with both hands to really ruin someone's day."
	w_class = W_CLASS_TINY
	c_flags = EQUIPPED_WHILE_HELD
	object_flags = NO_ARM_ATTACH | NO_GHOSTCRITTER
	hide_attack = ATTACK_FULLY_HIDDEN //we handle our own attack twitch

	icon = 'icons/obj/items/items.dmi'
	icon_state = "garrote0"

	event_handler_flags = USE_GRAB_CHOKE | USE_FLUID_ENTER
	special_grab = /obj/item/grab/garrote_grab

	// Are we ready to do something mean here?
	var/wire_readied = 0

	HELP_MESSAGE_OVERRIDE({"Use the garrot wire in hand to hold it with two hands, then place yourself behind your target.
							Click them with the wire to attempt to grab them.
							While a target is being strangled, use the wire in hand to inflict more damage and bleed in addition to the suffocation."})

	New()
		..()
		BLOCK_SETUP(BLOCK_ROPE)


/obj/item/garrote/proc/toggle_wire_readiness()
	set_readiness(!wire_readied)


/obj/item/garrote/proc/set_readiness(new_readiness)
	wire_readied = new_readiness
	// Try to stretch the wire
	if(!src.setTwoHanded(new_readiness))
		usr.show_text("You need two free hands in order to activate the [src.name].", "red")
		wire_readied = 0
		return

	if(wire_readied)
		playsound(usr, 'sound/items/garrote_twang.ogg', 25,5)
		w_class = W_CLASS_BULKY
	else
		drop_grab()
		w_class = W_CLASS_TINY

	update_state()

/obj/item/garrote/proc/update_state()
	if(src.chokehold && !istype(src.chokehold, /obj/item/grab/block))
		var/obj/item/grab/garrote_grab/GG = src.chokehold
		if(!GG.extra_deadly)
			icon_state = "garrote2"
			//We're choking someone out - apply a hefty slowdown
			src.setProperty("movespeed", 6)
		else
			icon_state = "garrote3"
			// We're really putting our back into it now - apply a heftier slowdown
			src.setProperty("movespeed", 12)
	else
		icon_state = "garrote[wire_readied]"
		//Slow us down slightly when we have the thing readied to encourage late-readying
		src.setProperty("movespeed", 1 * wire_readied)

	var/mob/M = the_mob // inc terminally stupid code
	if (!ismob(M) && src.chokehold && ismob(src.chokehold.assailant))
		M = src.chokehold.assailant
	else if (ismob(src.loc))
		M = src.loc
	else if (ismob(usr)) // we've tried nothing and we're all out of ideas
		M = usr
	M?.update_equipped_modifiers() // Call the bruteforce movement modifier proc because we changed movespeed while (maybe!) equipped

/obj/item/garrote/proc/is_behind_target(var/mob/living/assailant, var/mob/living/target)
	var/assailant_dir = get_dir(target, assailant)
	var/target_rear = turn(target.dir, 180)

	return (assailant_dir & target_rear) > 0 || target.lying || target.stat


// Try to grab someone
/obj/item/garrote/proc/attempt_grab(var/mob/living/assailant, var/mob/living/target)
	// Can't strangle someone who doesn't exist. Or if we're already strangling someone.
	// Also no strangling with flaccid wires, that's just weird.

	if(!assailant || !target)
		return FALSE

	if(!wire_readied)
		assailant.show_message(SPAN_COMBAT("You have to have a firm grip of the wire before you can strangle [target]!"))
		return FALSE

	if(chokehold)
		assailant.show_message(SPAN_COMBAT("You're too busy strangling [chokehold.affecting] to strangle someone else!"))
		return FALSE

	// TODO: check that target has their back turned
	if(is_behind_target(assailant, target))
		// Try to grab a dude
		actions.start(new/datum/action/bar/private/icon/garrote_target(target, src), assailant)
		return TRUE
	else
		assailant.show_message(SPAN_COMBAT("You have to be behind your target or they'll see you coming!"))

// Actually apply the grab (called via action bar)
/obj/item/garrote/try_grab(var/mob/living/target, var/mob/living/assailant)
	if(..())
		assailant.visible_message("<span class='combat bold'>[assailant] wraps \the [src] around [target]'s neck!</span>")
		chokehold.state = GRAB_AGGRESSIVE
		chokehold.upgrade_to_choke()
		update_state()

// Drop the grab
/obj/item/garrote/drop_grab()
	..()
	update_state()

// It will crumple when dropped
/obj/item/garrote/dropped(mob/user)
	if (src.wire_readied)
		set_readiness(0)
	..()

/obj/item/garrote/throw_impact(atom/hit_atom, datum/thrown_thing/thr)
	..(hit_atom)
	set_readiness(0)

/obj/item/garrote/disposing()
	drop_grab()
	..()

// Repeatedly process when in a chokehold, to verify things are as they should be
/obj/item/garrote/process_grab()
	..()
	if(src.chokehold && src.loc != src.chokehold.assailant)
		set_readiness(0)

/obj/item/garrote/proc/try_upgrade_grab()
	if (istype(src.chokehold, /obj/item/grab/block))
		return
	var/obj/item/grab/garrote_grab/GG = src.chokehold
	GG.extra_deadly = !GG.extra_deadly
	if(GG.extra_deadly)
		GG.assailant.visible_message("<span class='combat bold'>[GG.assailant] tightens their grip on \the [src], it digs into [GG.affecting]'s neck!</span>")
	else
		GG.assailant.visible_message("<span class='combat bold'>[GG.assailant] releases their hold on [GG.affecting] slightly!</span>")

	src.update_state()

// Change the size of the garrote or the posture
/obj/item/garrote/attack_self(mob/user)
	if(!chokehold)
		..()
		src.toggle_wire_readiness()
	else
		src.try_upgrade_grab()

/obj/item/garrote/attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
	if (target && target == src.chokehold?.affecting)
		src.try_upgrade_grab()
	else
		if (src.attempt_grab(user, target)) //if we successfully grab someone then do an attack twitch
			attack_twitch(user)

/datum/action/bar/private/icon/garrote_target
	duration = 10
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED
	icon = 'icons/mob/critter_ui.dmi'
	icon_state = "neck_over"
	var/mob/living/target
	var/obj/item/garrote/the_garrote

	New(target, garrote)
		src.target = target
		the_garrote=garrote
		..()

	proc/check_conditions()
		. = 0
		if(BOUNDS_DIST(owner, target) > 0 || !target || !isturf(target.loc) || !owner || !the_garrote || !the_garrote.wire_readied)
			interrupt(INTERRUPT_ALWAYS)
			. = 1

	onUpdate()
		..()

		if(check_conditions())
			return

	onStart()
		..()
		if(check_conditions())
			return

	onEnd()
		..()
		if(check_conditions())
			return

		the_garrote.try_grab(target, owner)

// Special grab obj that doesn't care if it's in someone's hands
/obj/item/grab/garrote_grab
	// No breaking out under own power
	irresistible = 1
	var/extra_deadly = 0
	check()
		if(!assailant || !affecting)
			qdel(src)
			return 1

		if(!isturf(assailant.loc) || (!isturf(affecting.loc) || assailant.loc != affecting.loc && BOUNDS_DIST(assailant, affecting) > 0) )
			qdel(src)
			return 1

		return 0

	// An extra dangerous grab
	process_kill(var/mob/living/carbon/human/H, mult = 1)
		if(extra_deadly)
			affecting.TakeDamage(zone="All", brute=rand(3, 7) * mult)
			affecting.losebreath += (1 * mult)
			if(prob(25))
				// Wire digging into a neck.
				take_bleeding_damage(affecting, assailant, rand(0, 20) * mult)
		..()

	attack_self(user)


/proc/trigger_anti_cheat(var/mob/M, var/message, var/external_alert = 1)
	if(M)
		message_admins("[key_name(M)] [message].")
		logTheThing(LOG_ADMIN, M, message)
		logTheThing(LOG_DIARY, M, message, "admin")

		if(external_alert)
			//IRCbot alert, for fun
			var/ircmsg[] = new()
			ircmsg["key"] =  M.key
			ircmsg["name"] = stripTextMacros(M.real_name)
			ircmsg["msg"] = "[message] and got themselves got by the anti-cheat cluwne."
			ircbot.export_async("admin", ircmsg)

		M.cluwnegib(15, 1)


/proc/list_item_damage_stats()
	var/list/L = typesof(/obj/item)
	var/result = "<table><tr><th>Name</th><th>Type</th><th>Force</th><th>Stamina damage</th><th>Stamina cost</th><th>Damage Type</th><th>Throw force</th></tr>"

	for(var/type in L)
		result += {"<tr>
					<td>[initial(type:name)]</td>
					<td>[type]</td>
					<td>[initial(type:force)]</td>
					<td>[initial(type:stamina_damage)]</td>
					<td>[initial(type:stamina_cost)]</td>
					<td>[initial(type:hit_type)]</td>
					<td>[initial(type:throwforce)]</td>
					</tr>"}

	result += "</table>"

	usr.Browse(result, "window=item_dam_stats;size=400x400")
