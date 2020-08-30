#define MEAT_NEEDED_TO_CLONE	16
#define MAXIMUM_MEAT_LEVEL		100
#define DEFAULT_MEAT_USED_PER_TICK 0.6
#define DEFAULT_SPEED_BONUS 1.5

#define MEAT_LOW_LEVEL	MAXIMUM_MEAT_LEVEL * 0.15

#define MAX_FAILED_CLONE_TICKS 200 // vOv

/obj/machinery/clonepod
	anchored = 1
	name = "cloning pod"
	desc = "An electronically-lockable pod for growing organic tissue."
	density = 1
	icon = 'icons/obj/cloning.dmi'
	icon_state = "pod_0_lowmeat"
	object_flags = CAN_REPROGRAM_ACCESS
	mats = 15
	var/meat_used_per_tick = DEFAULT_MEAT_USED_PER_TICK
	var/mob/living/occupant
	var/heal_level = 90 //The clone is released once its health reaches this level.
	var/locked = 0
	var/obj/machinery/computer/cloning/connected = null //So we remember the connected clone machine.
	var/mess = 0 //Need to clean out it if it's full of exploded clone.
	var/attempting = 0 //One clone attempt at a time thanks
	var/eject_wait = 0 //Don't eject them as soon as they are created fuckkk
	var/previous_heal = 0
	var/portable = 0 //Are we part of a port-a-clone?
	var/operating = 0 //Are we currently cloning some duder?
	var/id = null

	var/cloneslave = 0 //Is a traitor enslaving the clones?
	var/mob/implant_master = null // Who controls the clones?
	var/datum/bioEffect/BE = null // Any bioeffects to add upon cloning (used with the geneclone module)
	var/mindwipe = 0 // Are we wiping people's minds?
	var/is_speedy = 0 // Speed module installed?
	var/is_efficient = 0 // Efficiency module installed?

	var/gen_analysis = 0 //Are we analysing the genes while reassembling the duder? (read: Do we work faster or do we give a material bonus?)
	var/gen_bonus = 1 //Normal generation speed
	var/speed_bonus = DEFAULT_SPEED_BONUS // Multiplier that can be modified by modules

	power_usage = 200

	var/failed_tick_counter = 0 // goes up while someone is stuck in there and there's not enough meat to clone them, after so many ticks they'll get dumped out

	var/message = null
	var/list/mailgroups
	var/net_id = null
	var/pdafrequency = 1149
	var/datum/radio_frequency/pda_connection

	var/datum/light/light

	var/meat_level = MAXIMUM_MEAT_LEVEL / 4

	New()
		..()
		req_access = list(access_medlab) //For premature unlocking.
		mailgroups = list(MGD_MEDBAY, MGD_MEDRESEACH)

		var/datum/reagents/R = new/datum/reagents(100)
		reagents = R
		R.my_atom = src

		src.update_icon()
		genResearch.clonepods.Add(src) //This will be used for genetics bonuses when cloning

		light = new /datum/light/point
		light.set_brightness(1)
		light.set_color(1.0,0.1,0.1)
		light.set_height(0.75)
		light.attach(src)

		SPAWN_DBG(10 SECONDS)
			if (radio_controller)
				pda_connection = radio_controller.add_object(src, "[pdafrequency]")
			if (!src.net_id)
				src.net_id = generate_net_id(src)

	disposing()
		mailgroups.len = 0
		radio_controller.remove_object(src, "[pdafrequency]")
		genResearch.clonepods.Remove(src) //Bye bye
		connected.pod1 = null
		connected?.scanner?.pods -= src
		connected = null
		if(occupant)
			occupant.set_loc(src.loc)
		occupant = null
		..()

	proc/send_pda_message(var/msg)
		if (!msg && src.message)
			msg = src.message
		else if (!msg)
			return
		if(!pda_connection)
			return

		for(var/mailgroup in mailgroups)
			var/datum/signal/newsignal = get_free_signal()
			newsignal.source = src
			newsignal.transmission_method = TRANSMISSION_RADIO
			newsignal.data["command"] = "text_message"
			newsignal.data["sender_name"] = "CLONEPOD-MAILBOT"
			newsignal.data["message"] = "[msg]"

			newsignal.data["address_1"] = "00000000"
			newsignal.data["group"] = mailgroup
			newsignal.data["sender"] = src.net_id

			pda_connection.post_signal(src, newsignal)


/obj/machinery/clonepod/attack_ai(mob/user as mob)
	return attack_hand(user)

/obj/machinery/clonepod/attack_hand(mob/user as mob)
	interact_particle(user,src)

	if (status & NOPOWER)
		return

	if ((!isnull(src.occupant)) && (!isdead(src.occupant)))
		var/completion = (100 * ((src.occupant.health + 100) / (src.heal_level + 100)))
		boutput(user, "Current clone cycle is [round(completion)]% complete.")

	boutput(user, "Biomatter reserves are [round( 100 * (src.meat_level / MAXIMUM_MEAT_LEVEL) )]% full.")

	if (src.meat_level <= 0)
		boutput(user, "<span class='alert'>Alert: Biomatter reserves depleted.</span>")
	else if (src.meat_level <= MEAT_LOW_LEVEL)
		boutput(user, "<span class='alert'>Alert: Biomatter reserves low.</span>")

	return

/obj/machinery/clonepod/is_open_container()
	return 2

/obj/machinery/clonepod/proc/update_icon()
	if (src.portable) // no need here
		return
	if (src.mess)
		src.icon_state = "pod_g"
	else
		src.icon_state = "pod_[src.occupant ? "1" : "0"][src.meat_level ? "" : "_lowmeat"][src.cloneslave ? "_mindslave" : "" ][src.mindwipe ? "_mindwipe" : ""]"

//Start growing a human clone in the pod!
/obj/machinery/clonepod/proc/growclone(mob/ghost as mob, var/clonename, var/datum/mind/mindref, var/datum/bioHolder/oldholder, var/datum/abilityHolder/oldabilities, var/list/traits)
	if (((!ghost) || (!ghost.client)) || src.mess || src.attempting)
		return 0

	if (src.meat_level < MEAT_NEEDED_TO_CLONE)
		src.connected_message("Insufficient biomatter to begin.")
		return 0

	if (ghost.mind.dnr)
		src.connected_message("Ephemereal conscience detected, seance protocols reveal this corpse cannot be cloned.")
		return 0

	src.attempting = 1 //One at a time!!
	src.locked = 1
	src.failed_tick_counter = 0 // make sure we start here

	src.eject_wait = 1
	SPAWN_DBG(3 SECONDS)
		src.eject_wait = 0

	src.occupant = new /mob/living/carbon/human(src)

	if (istype(oldholder))
		oldholder.clone_generation++
		src.occupant.bioHolder.CopyOther(oldholder, copyActiveEffects = gen_analysis)
	else
		logTheThing("debug", null, null, "<b>Cloning:</b> growclone([english_list(args)]) with invalid holder.")

	if (istype(oldabilities))
		// @TODO @BUG: Things with abilities that should lose them (eg zombie clones) keep their zombie abilities.
		// Maybe not a bug? idk.
		src.occupant.abilityHolder = oldabilities // This should already be a copy.
		src.occupant.abilityHolder.transferOwnership(src.occupant) //mbc : fixed clone removing abilities bug!
		src.occupant.abilityHolder.remove_unlocks()



	if (traits && traits.len && src.occupant.traitHolder)
		src.occupant.traitHolder.traits = traits
		if (src.occupant.traitHolder.hasTrait("puritan"))
			src.mess = 1

	ghost.client.mob = src.occupant

	src.update_icon()
	//Get the clone body ready
	SPAWN_DBG(0.5 SECONDS) //Organs may not exist yet if we call this right away.
		random_brute_damage(src.occupant, 90, 1)
	src.occupant.take_toxin_damage(50)
	src.occupant.take_oxygen_deprivation(40)
	src.occupant.take_brain_damage(90)
	src.occupant.changeStatus("paralysis", 60)
	if(src.occupant.bioHolder.clone_generation > 1)
		src.occupant.setStatus("maxhealth-", null, -((src.occupant.bioHolder.clone_generation - 1) * 15))
		//src.occupant.max_health -= (src.occupant.bioHolder.clone_generation - 1) * 15 //Genetic degradation! Oh no!!
	//Here let's calculate their health so the pod doesn't immediately eject them!!!
	src.occupant.health = (src.occupant.get_brute_damage() + src.occupant.get_toxin_damage() + src.occupant.get_oxygen_deprivation())

	boutput(src.occupant, "<span class='notice'><b>Clone generation process initiated.</b></span>")
	boutput(src.occupant, "<span class='notice'>This will take a moment, please hold.</span>")

	if (clonename)
		if (prob(10))
			src.occupant.real_name = "[pick("Almost", "Sorta", "Mostly", "Kinda", "Nearly", "Pretty Much", "Roughly", "Not Quite", "Just About", "Something Resembling", "Somewhat")] [clonename]"
		else
			src.occupant.real_name = clonename
	else
		src.occupant.real_name = "clone"  //No null names!!
	src.occupant.name = src.occupant.real_name

	if ((mindref) && (istype(mindref))) //Move that mind over!!
		mindref.transfer_to(src.occupant)
	else //welp
		logTheThing("debug", null, null, "<b>Mind</b> Clonepod forced to create new mind for key \[[src.occupant.key ? src.occupant.key : "INVALID KEY"]]")
		src.occupant.mind = new /datum/mind(  )
		src.occupant.mind.key = src.occupant.key
		src.occupant.mind.transfer_to(src.occupant)
		ticker.minds += src.occupant.mind

	// -- Mode/mind specific stuff goes here

		if ((ticker && ticker.mode && istype(ticker.mode, /datum/game_mode/revolution)) && ((src.occupant.mind in ticker.mode:revolutionaries) || (src.occupant.mind in ticker.mode:head_revolutionaries)))
			ticker.mode:update_all_rev_icons() //So the icon actually appears

	// -- End mode specific stuff

	logTheThing("combat", usr, src.occupant, "starts cloning [constructTarget(src.occupant,"combat")] at [log_loc(src)].")

	if (isobserver(ghost))
		qdel(ghost) //Don't leave ghosts everywhere!!

	if (src.reagents && src.reagents.total_volume)
		src.reagents.reaction(src.occupant, 2, 1000)
		src.reagents.trans_to(src.occupant, 1000)

		// Oh boy someone is cloning themselves up an army!
	if(cloneslave && implant_master != null)
 		// No need to check near as much with a standard implant, as the cloned person is dead and is therefore enslavable upon cloning.
 		// How did this happen. Why is someone cloning you as a slave to yourself. WHO KNOWS?!
		if(implant_master == src.occupant)
			boutput(src.occupant, "<span class='alert'>You feel utterly strengthened in your resolve! You are the most important person in the universe!</span>")
		else
			if (src.occupant.mind && ticker.mode)
				if (!src.occupant.mind.special_role)
					src.occupant.mind.special_role = "mindslave"
				if (!(src.occupant.mind in ticker.mode.Agimmicks))
					ticker.mode.Agimmicks += src.occupant.mind
				src.occupant.mind.master = implant_master.ckey
 			boutput(src.occupant, "<h2><span class='alert'>You feel an unwavering loyalty to [implant_master.real_name]! You feel you must obey \his every order! Do not tell anyone about this unless your master tells you to!</span></h2>")
			SHOW_MINDSLAVE_TIPS(src.occupant)
 	// Someone is having their brain zapped. 75% chance of them being de-antagged if they were one
	//MBC todo : logging. This shouldn't be an issue thoug because the mindwipe doesn't even appear ingame (yet?)
	if(mindwipe)
		if(prob(75))
			SHOW_MINDWIPE_TIPS(src.occupant)
			boutput(src.occupant, "<h2><span class='alert'>You have awakened with a new outlook on life!</span></h2>")
			src.occupant.mind.memory = "You cannot seem to remember much from before you were cloned. Weird!<BR>"
		else
			boutput(src.occupant, "<span class='alert'>You feel your memories fading away, but you manage to hang on to them!</span>")
 	// Lucky person - they get a power on cloning!
	if (src.BE)
		src.occupant.bioHolder.AddEffectInstance(BE,1)


	previous_heal = src.occupant.health
	src.attempting = 0
	src.operating = 1
	// effectively "(1 + (!gen_analysis * 0.15)) * speed_bonus" (cash-4-clones is never on)
	src.gen_bonus = src.healing_multiplier()
	return 1

//Grow clones to maturity then kick them out.  FREELOADERS
/obj/machinery/clonepod/process()
	if (src.occupant && src.meat_level)
		power_usage = 7500
	else
		power_usage = 200
	..()
	if (status & NOPOWER) //Autoeject if power is lost
		if (src.occupant)
			src.locked = 0
			src.go_out()
		return

	var/abort = 0
	if ((src.occupant) && (src.occupant.loc == src) && src.occupant.traitHolder && src.occupant.traitHolder.hasTrait("puritan"))
		abort = 1
		src.occupant.take_toxin_damage(300)
		src.occupant.death()

	if(src.occupant && src.cloneslave == 1 && prob(10))
		playsound(src.loc, pick("sound/machines/glitch1.ogg","sound/machines/glitch2.ogg",
		"sound/machines/genetics.ogg","sound/machines/shieldoverload.ogg"), 50, 1)

	if ((src.occupant) && (src.occupant.loc == src))
		if ((isdead(src.occupant)) || (src.occupant.suiciding) || abort)  //Autoeject corpses and suiciding dudes.
			src.locked = 0
			src.go_out()
			src.connected_message("Clone Rejected: Deceased.")
			src.send_pda_message("Clone Rejected: Deceased")
			return

		else if (src.failed_tick_counter >= MAX_FAILED_CLONE_TICKS) // you been in there too long, get out
			src.locked = 0
			src.go_out()
			src.connected_message("Clone Ejected: Low Biomatter.")
			src.send_pda_message("Clone Ejected: Low Biomatter")
			return

		else if (!src.meat_level)
			src.failed_tick_counter ++
			if (src.failed_tick_counter == (MAX_FAILED_CLONE_TICKS / 2)) // halfway to ejection
				src.send_pda_message("Low Biomatter: Preparing to Eject Clone")
			src.update_icon()
			use_power(200)
			return

		else if (src.occupant.health < src.heal_level)

			src.occupant.changeStatus("paralysis", 60)

			 //Slowly get that clone healed and finished.
			src.occupant.HealDamage("All", 1 * gen_bonus, 1 * gen_bonus)

			//At this rate one clone takes about 95 seconds to produce.(with heal_level 90)
			// Zamujasa: changed -0.5 to -1; consistently the slowest type to heal
			src.occupant.take_toxin_damage(-1 * gen_bonus)

			//Premature clones may have brain damage.
			src.occupant.take_brain_damage(-2 * gen_bonus)

			//So clones don't die of oxy damage in a running pod.
			if (src.occupant.reagents.get_reagent_amount("perfluorodecalin") < 6) // cogwerks: changed from epinephrine
				src.occupant.reagents.add_reagent("perfluorodecalin", 2)

			if (src.occupant.reagents.get_reagent_amount("epinephrine") < 8) // lowering this but keeping it in a fully value range
				src.occupant.reagents.add_reagent("epinephrine", 4)

			if (src.occupant.reagents.get_reagent_amount("saline") < 10) // cogwerks: adding this because it'll be funny when someone gets scanned
				src.occupant.reagents.add_reagent("saline", 4)

			if (src.occupant.reagents.get_reagent_amount("synthflesh") < 50) // cogwerks: adding this because it'll be funny when someone gets scanned
				src.occupant.reagents.add_reagent("synthflesh", 10)

			if (src.occupant.reagents.get_reagent_amount("mannitol") < 6) // after new internal organs, some clones seem to be dying in-vat from brain damage. stopgap
				src.occupant.reagents.add_reagent("mannitol", 2)

			//Also heal some oxy ourselves because epinephrine is so bad at preventing it!!
			src.occupant.take_oxygen_deprivation(-10) // cogwerks: speeding this up too

			src.meat_level = max( 0, src.meat_level - meat_used_per_tick)
			if (!src.meat_level)
				src.connected_message("Additional biomatter required to continue.")
				src.send_pda_message("Low Biomatter")
				src.visible_message("<span class='alert'>[src] emits an urgent boop!</span>")
				playsound(src.loc, "sound/machines/buzz-two.ogg", 50, 0)
				src.failed_tick_counter = 1

			use_power(7500) //This might need tweaking.

			var/heal_delta = (src.occupant.health - previous_heal)
			if(heal_delta <= 0)
				src.failed_tick_counter++
			else
				src.failed_tick_counter = 0
			previous_heal = src.occupant.health
			if (heal_delta <= 0 && src.occupant.health > 50 && !eject_wait)
				src.connected_message("Cloning Process Complete.")
				src.send_pda_message("Cloning Process Complete")
				src.locked = 0
				src.go_out()
			else // go_out() updates icon too, so vOv
				src.update_icon()
			return

		else if ((src.occupant.health >= src.heal_level) && (!src.eject_wait))
			src.connected_message("Cloning Process Complete.")
			src.send_pda_message("Cloning Process Complete")
			src.locked = 0
			src.go_out()
			return


	else
		src.occupant = null
		src.operating = 0 //Welp. Where did you go? Jerk.
		src.failed_tick_counter = 0
		if (src.locked)
			src.locked = 0
		if (!src.mess)
			src.update_icon()
		use_power(200)
		return

	return

/obj/machinery/clonepod/emag_act(var/mob/user, var/obj/item/card/emag/E)
	if (isnull(src.occupant))
		return 0
	if(user)
		boutput(user, "You force an emergency ejection.")
	src.locked = 0
	src.go_out()
	return 1

//Let's unlock this early I guess.
/obj/machinery/clonepod/attackby(obj/item/W as obj, mob/user as mob)
	if (istype(W, /obj/item/device/pda2) && W:ID_card)
		W = W:ID_card
	if (istype(W, /obj/item/card/id))
		if (!src.check_access(W))
			boutput(user, "<span class='alert'>Access Denied.</span>")
			return
		if ((!src.locked) || (isnull(src.occupant)))
			return
		if ((src.occupant.health < -20) && (!isdead(src.occupant)))
			boutput(user, "<span class='alert'>Access Refused.</span>")
			return
		else
			src.locked = 0
			boutput(user, "System unlocked.")
	else if (istype(W, /obj/item/card/emag))	//This is needed to suppress the SYNDI CAT HITS CLONING POD message *cry
		return
	else if (istype(W, /obj/item/reagent_containers/glass))
		return
	else if (istype(W, /obj/item/cloneModule/speedyclone)) // speed module
		if(is_speedy)
			boutput(user,"<span class='alert'>There's already a speed booster in the slot!</span>")
			return
		if(operating)
			boutput(user,"<span class='alert'>The cloning pod emits an angry boop!</span>")
			return
		user.visible_message("[user] installs [W] into [src].", "You install [W] into [src].")
		logTheThing("combat", src, user, "[user] installed ([W]) to ([src]) at [log_loc(user)].")
		speed_bonus *= 2
		meat_used_per_tick *= 3
		is_speedy = 1
		user.drop_item()
		qdel(W)
		return

	else if (istype(W, /obj/item/cloneModule/efficientclone)) // efficiency module
		if(is_efficient)
			boutput(user,"<span class='alert'>There's already an efficiency booster in the slot!</span>")
			return
		if(operating)
			boutput(user,"<span class='alert'>The cloning pod emits a[pick("n angry", " grumpy", "n annoyed", " cheeky")] [pick("boop","bop", "beep", "blorp", "burp")]!</span>")
			return
		user.visible_message("[user] installs [W] into [src].", "You install [W] into [src].")
		logTheThing("combat", src, user, "[user] installed ([W]) to ([src]) at [log_loc(user)].")
		meat_used_per_tick *= 0.5
		is_efficient = 1
		user.drop_item()
		qdel(W)
		return

	else if (istype(W, /obj/item/cloneModule/mindslave_module)) // Time to re enact the clone wars
		if(operating)
			boutput(user,"<span class='alert'>The cloning pod emits a[pick("n angry", " grumpy", "n annoyed", " cheeky")] [pick("boop","bop", "beep", "blorp", "burp")]!</span>")
			return
		logTheThing("combat", src, user, "[user] installed ([W]) to ([src]) at [log_loc(user)].")
		cloneslave = 1
		implant_master = user
		// Clone armies are not allowed to use speed or efficiency modules under article 7.2 p5 of the space geneva convention
		is_speedy = 1
		is_efficient = 1
		speed_bonus = DEFAULT_SPEED_BONUS
		meat_used_per_tick = DEFAULT_MEAT_USED_PER_TICK
		light.enable()
		user.drop_item()
		qdel(W)
		return

	else if(istype(W, /obj/item/screwdriver) && cloneslave == 1) // Wait nevermind the clone wars were a terrible idea
		if(src.occupant)
			boutput(user, "<space class='alert'>You must wait for the current cloning cycle to finish before you can remove the mindslave module.</span>")
			return
		boutput(user, "<span class='notice'>You begin detatching the mindslave cloning module...</span>")
		playsound(src.loc, "sound/items/Screwdriver.ogg", 50, 1)
		if(do_after(user,50))
			new /obj/item/cloneModule/mindslave_module( src.loc )
			cloneslave = 0
			implant_master = null
			boutput(user,"<span class='alert'>The mindslave cloning module falls to the floor with a dull thunk </span>")
			playsound(src.loc, "sound/effects/thunk.ogg", 50, 0)
			light.disable()
		else
			boutput(user,"<span class='alert'>You were interrupted!</span>")
		return

	else
		..()

/obj/machinery/clonepod/var/static/list/clonepod_accepted_reagents = list("blood"=0.5,"synthflesh"=1,"beff"=0.75,"pepperoni"=0.5,"meat_slurry"=1,"bloodc"=0.5)
/obj/machinery/clonepod/on_reagent_change()
	for(var/reagent_id in src.reagents.reagent_list)
		if (reagent_id in clonepod_accepted_reagents)
			var/datum/reagent/theReagent = src.reagents.reagent_list[reagent_id]
			if (theReagent)
				src.meat_level = min(src.meat_level + (theReagent.volume * clonepod_accepted_reagents[reagent_id]), MAXIMUM_MEAT_LEVEL)
				src.reagents.del_reagent(reagent_id)

	if (src.occupant)
		src.reagents.reaction(src.occupant, 1000) // why was there a 2 here? it was injecting ice cold reagents that burn people
		src.reagents.trans_to(src.occupant, 1000)

//Put messages in the connected computer's temp var for display.
/obj/machinery/clonepod/proc/connected_message(var/msg)
	if ((isnull(src.connected)) || (!istype(src.connected, /obj/machinery/computer/cloning)))
		return 0
	if (!msg)
		return 0

	src.connected.temp = msg
	src.connected.updateUsrDialog()
	return 1

/obj/machinery/clonepod/verb/eject()
	set src in oview(1)
	set category = "Local"

	if (!isalive(usr))
		return
	src.go_out()
	add_fingerprint(usr)
	return

/obj/machinery/clonepod/proc/go_out()
	if (src.locked)
		return
	src.operating = 0 //Welp
	src.failed_tick_counter = 0

	if (src.mess) //Clean that mess and dump those gibs!
		src.mess = 0
		gibs(get_turf(src)) // we don't need to do if/else things just to say "put gibs on this thing's turf"
		src.update_icon()
		for (var/obj/O in src)
			O.set_loc(get_turf(src))
			if (prob(33))
				step_rand(O) // cogwerks - let's spread that mess instead of having a pile! bahaha
		return

	if (!(src.occupant))
		return

	for (var/obj/O in src)
		O.set_loc(get_turf(src))

	if ((src.occupant.health < heal_level - 50) && src.occupant.bioHolder) // this seems to often not work right, changing 20 to 50
		src.occupant.bioHolder.AddEffect("premature_clone")
	if (src.occupant.get_oxygen_deprivation())
		src.occupant.take_oxygen_deprivation(-INFINITY)

	if (src.occupant.losebreath) // STOP FUCKING SUFFOCATING GOD DAMN
		src.occupant.losebreath = 0

	if(iscarbon(src.occupant))
		var/mob/living/carbon/C = src.occupant
		C.remove_ailments() // no more cloning with heart failure

	src.occupant.set_loc(get_turf(src))
	src.update_icon()
	src.eject_wait = 0 //If it's still set somehow.
	src.occupant = null
	return

/obj/machinery/clonepod/proc/malfunction()
	if (src.occupant)
		src.connected_message("Critical Error!")
		src.send_pda_message("Critical Error")
		src.mess = 1
		src.failed_tick_counter = 0
		src.update_icon()
		src.occupant.ghostize()
		SPAWN_DBG(0.5 SECONDS)
			qdel(src.occupant)
	return

/obj/machinery/clonepod/proc/operating_nominally()
	return operating && src.meat_level && gen_analysis //Only operate nominally for non-shit cloners

/obj/machinery/clonepod/proc/healing_multiplier()
	if (wagesystem.clones_for_cash)
		return (2 + (!gen_analysis * 0.15)) * speed_bonus
	else
		return (1 + (!gen_analysis * 0.15)) * speed_bonus //If the analysis feature is disabled, then generate the clone slightly faster


/obj/machinery/clonepod/relaymove(mob/user as mob)
	if (user.stat)
		return
	src.go_out()
	return

/obj/machinery/clonepod/ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/atom/movable/A as mob|obj in src)
				A.set_loc(src.loc)
				A.ex_act(severity)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				for(var/atom/movable/A as mob|obj in src)
					A.set_loc(src.loc)
					A.ex_act(severity)
				qdel(src)
				return
		if(3.0)
			if (prob(25))
				for(var/atom/movable/A as mob|obj in src)
					A.set_loc(src.loc)
					A.ex_act(severity)
				qdel(src)
				return
		else
	return

//SOME SCRAPS I GUESS
/* EMP grenade/spell effect
		if(istype(A, /obj/machinery/clonepod))
			A:malfunction()
*/

//WHAT DO YOU WANT FROM ME(AT)
/obj/machinery/clonegrinder
	name = "enzymatic reclaimer"
	desc = "A tank resembling a rather large blender, designed to recover biomatter for use in cloning."
	icon = 'icons/obj/cloning.dmi'
	icon_state = "grinder0"
	anchored = 1
	density = 1
	mats = 10
	var/list/pods = null // cloning pods we're tied to
	var/id = null // if this isn't null, we'll only look for pods with this ID
	var/pod_range = 4 // if we don't have an ID, we look for pods in orange(this value)
	var/process_timer = 0	// how long this shit is running for
	var/process_per_tick = 0	// how much shit it will output per tick
	var/mob/living/occupant = null
	var/list/meats = list() //Meat that we want to reclaim.
	var/max_meat = 7 //To be honest, I added the meat reclamation thing in part because I wanted a "max_meat" var.
	var/emagged = 0
	var/auto_strip = 1 // disabled when emagged (people were babies about this when it being turned off was the default) :V
	var/upgraded = 0 // upgrade card makes the reclaimer more efficient

	New()
		..()
		UnsubscribeProcess()
		var/datum/reagents/R = new/datum/reagents(100)
		reagents = R
		R.my_atom = src
		src.update_icon(1)
		SPAWN_DBG(0)
			src.find_pods()

	proc/find_pods()
		if (!islist(src.pods))
			src.pods = list()
		if (!isnull(src.id) && genResearch && islist(genResearch.clonepods) && genResearch.clonepods.len)
			for (var/obj/machinery/clonepod/pod in genResearch.clonepods)
				if (pod.id == src.id && !src.pods.Find(pod))
					src.pods += pod
					DEBUG_MESSAGE("[src] adds pod [log_loc(pod)] (ID [src.id]) in genResearch.clonepods")
		else
			for (var/obj/machinery/clonepod/pod in orange(src.pod_range))
				if (!src.pods.Find(pod))
					src.pods += pod
					DEBUG_MESSAGE("[src] adds pod [log_loc(pod)] in orange([src.pod_range])")

	verb/eject()
		set src in oview(1)
		set category = "Local"

		if (!isalive(usr)) return
		if (src.process_timer > 0) return
		src.go_out()
		add_fingerprint(usr)
		return

	relaymove(mob/user as mob)
		src.go_out()
		return

	proc/go_out()
		if (!src.occupant)
			return
		for(var/obj/O in src)
			O.set_loc(src.loc)
		src.occupant.set_loc(src.loc)
		src.occupant = null
		return

	process()
		process_timer--
		if (process_timer > 0)
			// Add reagents for this tick
			src.reagents.add_reagent("blood", 2 * process_per_tick)
			src.reagents.add_reagent("meat_slurry", 2 * process_per_tick)
			if (prob(2))
				src.reagents.add_reagent("beff", 1 * process_per_tick)

		if (src.reagents.total_volume && islist(src.pods) && pods.len)
			// Distribute reagents to cloning pods nearby
			// Changed from before to distribute while grinding rather than all at once
			// give an equal amount of reagents to each pod that happens to be around
			var/volume_to_share = (src.reagents.total_volume / max(pods.len, 1))
			for (var/obj/machinery/clonepod/pod in src.pods)
				src.reagents.trans_to(pod, volume_to_share)
				DEBUG_MESSAGE("[src].reagents.trans_to([pod] [log_loc(pod)], [src.reagents.total_volume]/[max(pods.len, 1)])")

		if (process_timer <= 0)
			UnsubscribeProcess()
			update_icon(1)

		return

	on_reagent_change()
		src.update_icon(0)

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		if (!src.emagged)
			if (user)
				boutput(user, "<span class='notice'>You override the reclaimer's safety mechanism.</span>")
			logTheThing("combat", user, "emagged [src] at [log_loc(src)].")
			emagged = 1
			return 1
		else
			if (user)
				boutput(user, "The safety mechanism's already burnt out!")
			return 0

	demag(var/mob/user)
		if (!src.emagged)
			return 0
		emagged = 0
		if (user)
			boutput(user, "<span class='notice'>You repair the reclaimer's safety mechanism.</span>")
		return 1

	attack_hand(mob/user as mob)
		interact_particle(user,src)

		if (src.process_timer > 0)
			boutput(user, "<span class='alert'>The [src.name] is already running!</span>")
			return

		if (!src.meats.len && !src.occupant)
			boutput(user, "<span class='alert'>There is nothing loaded to reclaim!</span>")
			return

		if (src.occupant && src.occupant.loc != src)
			src.occupant = null
			boutput(user, "<span class='alert'>There is nothing loaded to reclaim!</span>")
			return

		user.visible_message("<b>[user]</b> activates [src]!", "You activate [src].")
		if (istype(src.occupant))
			logTheThing("combat", user, src.occupant, "activated [src.name] with [constructTarget(src.occupant,"combat")] ([isdead(src.occupant) ? "dead" : "alive"]) inside at [log_loc(src)].")
			if (!isdead(src.occupant))
				message_admins("[key_name(user)] activated [src.name] with [key_name(src.occupant, 1)] ([isdead(src.occupant) ? "dead" : "alive"]) inside at [log_loc(src)].")
		src.start_cycle()
		return

	proc/start_cycle()
		src.find_pods()

		// how much we will be producing
		var/process_total = 0

		if (istype(src.occupant))
			src.occupant.death(1)
			var/humanOccupant = (ishuman(src.occupant) && !ismonkey(src.occupant))
			var/decomp = ishuman(src.occupant) ? src.occupant:decomp_stage : 0 // changed from only checking humanOccupant to running ishuman again so monkeys' decomp will be considered
			if (src.occupant.mind)
				src.occupant.ghostize()
				qdel(src.occupant)
			else
				qdel(src.occupant)
			src.occupant = null

			// Old table of cloner values --
			// grinder used to count down and added either x or x + 2 depending on upgrade
			// now uses varying amounts of things! i guess!
			// here is the old code and a table of how the timer was calculated:
			// var/mult = src.upgraded ? rand(2,4) : rand(4,8)
			// src.process_timer = (humanOccupant ? 2 : 1)
			// src.process_timer *= (mult - (2 * decomp))
			// ------------------------------------------------
			// process_timer    ____speedy|normal__________
			// mult>              2   3   4   5   6   7   8  (note: speedy would increase
			// Decomp stage  0    4   6   8  10  12  14  16   reagent production by * 2)
			//               1    0   2   4   6   8  10  12
			//               2   -4  -2   0   2   4   6   8  (slightly decomposed bodies
			//               3   -8  -6  -4  -2   0   2   4   became worthless with
			//               4  -12 -10  -8  -6  -4  -2   0   speedy grinder upgrade)
			// total reagents: process_timer * (speedy ? 2 : 1)
			// this effectively means/meant that the speedy upgrade was faster,
			// but otherwise objectively worse if you had decomposed corpses

			// attempting to rewrite this to be better or at least different, i guess
			// First, how much are we going to get from this?
			//                        rand  human   decomp        total
			// Human, no decomposure: (5~8) * 2 * (4.5 / 4.5) =  10 ~ 16
			// Human, stage 1:        (5~8) * 2 * (3.5 / 4.5) = 8.8 ~12.4
			// Human, stage 2:        (5~8) * 2 * (2.5 / 4.5) = 5.5 ~ 7.7
			// Human, stage 3:        (5~8) * 2 * (1.5 / 4.5) = 3.3 ~ 5.3
			// Human, stage 4:        (5~8) * 2 * (0.5 / 4.5) = 1.1 ~ 1.7
			// Non-human monkey:      (5~8) * 1 * (4.5 / 4.5) =   5 ~ 8
			process_total += rand(5, 8) * (humanOccupant ? 2 : 1) * ((4.5 - decomp) / 4.5)

			//DEBUG_MESSAGE("[src] process_timer calced as [src.process_timer] (upgraded [src.upgraded], mult [mult], humanOccupant [humanOccupant])")
			//DEBUG_MESSAGE("[src] rough end result of cycle: [(src.process_timer * (src.upgraded ? 8 : 4))]u + up to [(src.process_timer * (src.upgraded ? 2 : 1))]u")

		if (src.meats.len)
			for (var/obj/item/theMeat in src.meats)
				src.meats -= theMeat
				if (theMeat.reagents)
					theMeat.reagents.trans_to(src, src.upgraded ? 10 : 5)

				qdel(theMeat)
				// Each bit of meat adds 2 units
				process_total += 2

			src.meats.len = 0

		// process_timer = total * 0.8 or 0.4 (rounded up) - slightly faster than before
		// normal:
		// 8 * 2 (human) =    16 units
		// 16 * 0.8 = 12.8 -> 13 ticks
		// 16 / 13 =           1.2307 per tick
		// upgraded:
		// 8 * 2 =            16 units
		// 16 * 0.4 = 6.4 ->   7 ticks
		// 16 / 7 =            2.2857 per tick
		// end result is that they produce the same amounts, the upgrade just does it faster
		src.process_timer = ceil(process_total * (src.upgraded ? 0.4 : 0.8))
		src.process_per_tick = process_total / process_timer

		src.update_icon(1)
		SubscribeToProcess()

	attackby(obj/item/grab/G as obj, mob/user as mob)
		if (istype(G, /obj/item/grinder_upgrade))
			if (src.upgraded)
				boutput(user, "<span class='alert'>There is already an upgrade card installed.</span>")
				return
			user.visible_message("[user] installs [G] into [src].", "You install [G] into [src].")
			src.upgraded = 1
			user.drop_item()
			qdel(G)
			return
		if (src.process_timer > 0)
			boutput(user, "<span class='alert'>The [src.name] is still running, hold your horses!</span>")
			return
		if (istype(G, /obj/item/reagent_containers/food/snacks/ingredient/meat) || (istype(G, /obj/item/reagent_containers/food) && (findtext(G.name, "meat")||findtext(G.name,"bacon"))) || (istype(G, /obj/item/parts/human_parts)) || istype(G, /obj/item/clothing/head/butt) || istype(G, /obj/item/organ) || istype(G,/obj/item/raw_material/martian))
			if (src.meats.len >= src.max_meat)
				boutput(user, "<span class='alert'>There is already enough meat in there! You should not exceed the maximum safe meat level!</span>")
				return

			if (G.contents && G.contents.len > 0)
				for (var/obj/item/W in G.contents)
					if (istype(W, /obj/item/skull) || istype(W, /obj/item/organ/brain) || istype(W, /obj/item/organ/eye))
						continue

					if (W)
						W.set_loc(user.loc)
						W.dropped(user)
						W.layer = initial(W.layer)

			src.meats += G
			user.u_equip(G)
			G.set_loc(src)
			user.visible_message("<b>[user]</b> loads [G] into [src].","You load [G] into [src]")
			return

		else if (istype(G, /obj/item/reagent_containers/glass))
			return

		else if (!istype(G) || !iscarbon(G.affecting))
			boutput(user, "<span class='alert'>This item is not suitable for [src].</span>")
			return
		if (src.occupant)
			boutput(user, "<span class='alert'>There is already somebody in there.</span>")
			return

		else if (G && G.affecting && !src.emagged && !isdead(G.affecting) && !ismonkey(G.affecting))
			user.visible_message("<span class='alert'>[user] tries to stuff [G.affecting] into [src], but it beeps angrily as the safety overrides engage!</span>")
			return

		src.add_fingerprint(user)
		actions.start(new /datum/action/bar/icon/put_in_reclaimer(G.affecting, src, G, 50), user)
		return

	proc/update_icon(var/update_grindpaddle=0)
		var/fluid_level = ((src.reagents.total_volume >= (src.reagents.maximum_volume * 0.6)) ? 2 : (src.reagents.total_volume >= (src.reagents.maximum_volume * 0.2) ? 1 : 0))

		src.icon_state = "grinder[fluid_level]"

		if (update_grindpaddle)
			src.overlays = null
			src.overlays += "grindpaddle[src.process_timer > 0 ? 1 : 0]"

			src.overlays += "grindglass[fluid_level]"
		return

	ex_act(severity)
		switch(severity)
			if(1.0)
				for(var/atom/movable/A as mob|obj in src)
					A.set_loc(src.loc)
					A.ex_act(severity)
				qdel(src)
				return
			if(2.0)
				if (prob(50))
					for(var/atom/movable/A as mob|obj in src)
						A.set_loc(src.loc)
						A.ex_act(severity)
					qdel(src)
					return
			if(3.0)
				if (prob(25))
					src.status |= BROKEN
					src.icon_state = "grinderb"
			else
		return

	is_open_container()
		return -1

	custom_suicide = 1
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		if (src.process_timer > 0)
			return 0

		src.visible_message("<span class='alert'><b>[user] climbs into [src] and turns it on!</b></span>")

		user.unequip_all()
		user.set_loc(src)
		src.occupant = user

		src.start_cycle()

		SPAWN_DBG(50 SECONDS)
			if (user && !isdead(user)) // how????????? ?
				user.suiciding = 0 // just in case I guess
		return 1

/datum/action/bar/icon/put_in_reclaimer
	id = "put_in_reclaimer"
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	duration = 50
	icon = 'icons/mob/screen1.dmi'
	icon_state = "grabbed"

	var/mob/living/carbon/human/target
	var/obj/machinery/clonegrinder/grinder
	var/obj/item/grab/grab

	New(var/mob/living/carbon/human/ntarg, var/obj/machinery/clonegrinder/ngrind, var/obj/item/grab/ngrab, var/duration_i)
		..()
		if (ntarg)
			target = ntarg
		if (ngrind)
			grinder = ngrind
		if (ngrab)
			grab = ngrab
		if (duration_i)
			duration = duration_i

	onUpdate()
		..()
		if (grab == null || target == null || grinder == null || owner == null || get_dist(owner, grinder) > 1 || get_dist(owner, target) > 1 || get_dist(target, grinder) > 1)
			interrupt(INTERRUPT_ALWAYS)
			return
		var/mob/source = owner
		if (!istype(source) || !source.find_in_hand(grab) || grab.affecting != target)
			interrupt(INTERRUPT_ALWAYS)

	onStart()
		..()
		owner.visible_message("<span class='alert'><b>[owner] starts to put [target] into [grinder]!</b></span>")

	onEnd()
		..()
		owner.visible_message("<span class='alert'><b>[owner] stuffs [target] into [grinder]!</b></span>")
		logTheThing("combat", owner, target, "forced [constructTarget(target,"combat")] ([isdead(target) ? "dead" : "alive"]) into \an [grinder] at [log_loc(grinder)].")
		if (!isdead(target))
			message_admins("[key_name(owner)] forced [key_name(target, 1)] ([target == 2 ? "dead" : "alive"]) into \an [grinder] at [log_loc(grinder)].")
		if (grinder.auto_strip && !grinder.emagged)
			target.unequip_all()
		target.set_loc(grinder)
		grinder.occupant = target
		qdel(grab)

#undef MEAT_NEEDED_TO_CLONE
#undef MAXIMUM_MEAT_LEVEL
#undef DEFAULT_MEAT_USED_PER_TICK
#undef DEFAULT_SPEED_BONUS
#undef MEAT_LOW_LEVEL
