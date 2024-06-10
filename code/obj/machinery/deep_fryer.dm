TYPEINFO(/obj/machinery/deep_fryer)
	mats = 20

/obj/machinery/deep_fryer
	name = "Deep Fryer"
	desc = "An industrial deep fryer.  A big hit at state fairs!"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "fryer0"
	anchored = ANCHORED
	density = 1
	flags = NOSPLASH
	status = REQ_PHYSICAL_ACCESS
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_CROWBAR | DECON_WELDER | DECON_WIRECUTTERS
	var/atom/movable/fryitem = null
	var/cooktime = 0
	var/frytemp = 185 + T0C //365 F is a good frying temp, right?
	var/max_wclass = W_CLASS_NORMAL
	var/fed_ice = FALSE // hungy

/obj/machinery/deep_fryer/New()
	..()
	UnsubscribeProcess()
	src.create_reagents(50)

	reagents.add_reagent("grease", 25)
	reagents.set_reagent_temp(src.frytemp)

/obj/machinery/deep_fryer/get_desc()
	. = ..()
	if (HAS_FLAG(status, BROKEN))
		. += " It looks broken."

/obj/machinery/deep_fryer/attackby(obj/item/W, mob/user)
	if (isghostdrone(user) || isAI(user))
		boutput(user, SPAN_ALERT("The [src] refuses to interface with you, as you are not a properly trained chef!"))
		return
	if (W.cant_drop) //For borg held items
		boutput(user, SPAN_ALERT("You can't put that in [src] when it's attached to you!"))
		return
	if (src.fryitem)
		boutput(user, SPAN_ALERT("There is already something in the fryer!"))
		return
	if (istype(W, /obj/item/reagent_containers/food/snacks/shell/deepfry))
		boutput(user, SPAN_ALERT("Your cooking skills are not up to the legendary Doublefry technique."))
		return
	if (HAS_FLAG(status, BROKEN))
		boutput(user, SPAN_ALERT("It looks like the fryer is broken!"))
		return

	else if ((istype(W, /obj/item/reagent_containers/glass/) || istype(W, /obj/item/reagent_containers/food/drinks/)) && W.is_open_container(FALSE))
		if (!W.reagents.total_volume)
			boutput(user, SPAN_ALERT("There is nothing in [W] to pour!"))
		else
			logTheThing(LOG_CHEMISTRY, user, "pours chemicals [log_reagents(W)] into the [src] at [log_loc(src)].") // Logging for the deep fryer (Convair880).
			src.visible_message(SPAN_NOTICE("[user] pours [W:amount_per_transfer_from_this] units of [W]'s contents into [src]."))
			playsound(src.loc, 'sound/impact_sounds/Liquid_Slosh_1.ogg', 25, 1)
			W.reagents.trans_to(src, W:amount_per_transfer_from_this)
			if (!W.reagents.total_volume) boutput(user, SPAN_ALERT("<b>[W] is now empty.</b>"))
		return

	else if (istype(W, /obj/item/grab))
		var/obj/item/grab/G = W
		if (!G.affecting) return
		user.lastattacked = src
		src.visible_message(SPAN_ALERT("<b>[user] is trying to shove [G.affecting] into [src]!</b>"))
		if(!do_mob(user, G.affecting) || !W)
			return

		if(ismonkey(G.affecting))
			logTheThing(LOG_COMBAT, user, "shoves [constructTarget(G.affecting,"combat")] into the [src] at [log_loc(src)].") // For player monkeys (Convair880).
			src.visible_message(SPAN_ALERT("<b>[user] shoves [G.affecting] into [src]!</b>"))
			src.start_frying(G.affecting)
			G.affecting.death(FALSE)
			qdel(W)
			return

		logTheThing(LOG_COMBAT, user, "shoves [constructTarget(G.affecting,"combat")]'s face into the [src] at [log_loc(src)].")
		src.visible_message(SPAN_ALERT("<b>[user] shoves [G.affecting]'s face into [src]!</b>"))
		src.reagents.reaction(G.affecting, TOUCH)
		return

	if (W.w_class > src.max_wclass || W.storage || istype(W, /obj/item/plate))
		boutput(user, SPAN_ALERT("There is no way that could fit!"))
		return

	logTheThing(LOG_STATION, user, "puts the [log_object(W)] into the [log_object(src)] at [log_loc(src)].")
	src.visible_message(SPAN_NOTICE("[user] loads [W] into the [src]."))
	user.u_equip(W)
	W.dropped(user)
	W.add_fingerprint(user)
	src.start_frying(W)
	SubscribeToProcess()
	src.check_hunger(user, W)

/obj/machinery/deep_fryer/MouseDrop_T(obj/item/W as obj, mob/user as mob)
	. = ..()
	if (istype(W) && in_interact_range(W, user) && in_interact_range(src, user))
		return src.Attackby(W, user)

/obj/machinery/deep_fryer/onVarChanged(variable, oldval, newval)
	. = ..()
	if (variable == "fryitem")
		if (!oldval && newval)
			SubscribeToProcess()
		else if (oldval && !newval)
			UnsubscribeProcess()
		src.UpdateIcon()

/obj/machinery/deep_fryer/update_icon()
	if (src.fryitem)
		src.icon_state = "fryer1"
	else
		src.icon_state = "fryer0"

/obj/machinery/deep_fryer/attack_hand(mob/user)
	if (isghostdrone(user))
		boutput(user, SPAN_ALERT("The [src] refuses to interface with you, as you are not a properly trained chef!"))
		return
	if (!src.fryitem)
		boutput(user, SPAN_ALERT("There is nothing in the fryer."))
		return
	if (src.cooktime < 5)
		boutput(user, SPAN_ALERT("Frying things takes time! Be patient!"))
		return

	user.visible_message(SPAN_NOTICE("[user] removes [src.fryitem] from [src]!"), SPAN_NOTICE("You remove [src.fryitem] from [src]."))
	src.eject_food()

/obj/machinery/deep_fryer/process()
	if (status & BROKEN)
		UnsubscribeProcess()
		return

	if (!src.reagents.has_reagent("grease"))
		src.reagents.add_reagent("grease", 25)

	//DaerenNote: so it turned out hellmixes + self-heating mixes constantly got dragged to the src.frytemp
	//so i fixed that, heated stuff won't get cooled by the fryer now b/c thats lame + i am not going to thermodynamics this shit to model equilibrium
	if (src.frytemp >= src.reagents.total_temperature)
		src.reagents.set_reagent_temp(src.frytemp) // I'd love to have some thermostat logic here to make it heat up / cool down slowly but aaaaAAAAAAAAAAAAA (exposing it to the frytemp is too slow)

	if(!src.fryitem)
		UnsubscribeProcess()
		return
	else
		src.cooktime++

	if (src.fryitem.material?.getID() == "ice" && !ON_COOLDOWN(src, "ice_explosion", 10 SECONDS))
		if (ismob(fed_ice)) // have we asked someone for ice?
			var/mob/ice_feeder = fed_ice
			fed_ice = TRUE
			var/msg = "Oh, now I can die a warrior's death! Thank you!"
			src.audible_message("<span class='radio' style='color: #e8ae2a'>\
					[SPAN_NAME("[src.name] [bicon(src)]")] [SPAN_MESSAGE(" says, \"[msg]\"")]</span>",
					assoc_maptext = make_chat_maptext(src, msg, "color: #e8ae2a;"))
			ADD_FLAG(src.status, BROKEN)
			name = "Satiated [initial(src.name)]"
			ice_feeder = ice_feeder || ckey_to_mob(src.fryitem.fingerprintslast) // in case someone else had to fufill, no direct ref
			ice_feeder?.unlock_medal("Deep Freeze", TRUE)

		qdel(src.fryitem)
		src.fryitem = null
		src.visible_message(SPAN_ALERT("The ice reacts violently with the hot oil!"))
		fireflash(src, 3, chemfire = CHEM_FIRE_RED)
		UnsubscribeProcess()
		return

	src.reagents.trans_to(src.fryitem, 2)

	if (src.cooktime < 60)
		if (src.cooktime == 30)
			playsound(src.loc, 'sound/machines/ding.ogg', 50, 1)
			src.audible_message(SPAN_NOTICE("[src] dings!"))
		else if (src.cooktime == 60) //Welp!
			src.visible_message(SPAN_ALERT("[src] emits an acrid smell!"))
	else if(src.cooktime >= 120)
		if((src.cooktime % 5) == 0 && prob(10))
			src.visible_message(SPAN_ALERT("[src] sprays burning oil all around it!"))
			fireflash(src, 1, chemfire = CHEM_FIRE_RED)

/obj/machinery/deep_fryer/custom_suicide = TRUE
/obj/machinery/deep_fryer/suicide(var/mob/user as mob)
	if (!src.user_can_suicide(user))
		return 0
	if (src.fryitem)
		return 0
	user.visible_message(SPAN_ALERT("<b>[user] climbs into the deep fryer! How is that even possible?!</b>"))

	src.start_frying(user)
	user.TakeDamage("head", 0, 175)
	if(user.reagents && user.reagents.has_reagent("dabs"))
		var/amt = user.reagents.get_reagent_amount("dabs")
		user.reagents.del_reagent("dabs")
		user.reagents.add_reagent("deepfrieddabs",amt)
	SPAWN(50 SECONDS)
		if (user && !isdead(user))
			user.suiciding = 0
	return 1

/obj/machinery/deep_fryer/proc/start_frying(atom/movable/frying) //might be an item, might be a mob, might be a fucking singularity
	if (!istype(frying))
		return
	frying.set_loc(src)
	src.cooktime = 0
	src.fryitem = frying
	src.UpdateIcon()
	if (!src.fryitem.reagents)
		src.fryitem.create_reagents(50)
	if (round(src.fryitem.reagents.total_volume, 1) == round(src.fryitem.reagents.maximum_volume, 1)) //I LOVE FLOATING POINTS
		src.fryitem.reagents.maximum_volume += 25
	SubscribeToProcess()

/obj/machinery/deep_fryer/proc/fryify(atom/movable/thing, burnt=FALSE)
	var/obj/item/reagent_containers/food/snacks/shell/deepfry/fryholder = new(src)

	//photos cause exponential lag when deepfried, see #17848
	//feel free to remove this if you can figure out why
	if(burnt || istype(thing, /obj/item/photo))
		if (ismob(thing))
			var/mob/M = thing
			M.ghostize()
		else
			for (var/mob/M in thing)
				M.ghostize()
		qdel(thing)
		thing = new /obj/item/reagent_containers/food/snacks/yuck/burn (src)
		if (!thing.reagents)
			thing.create_reagents(50)

		thing.reagents.add_reagent("grease", 50)
		fryholder.desc = "A heavily fried...something.  Who can tell anymore?"
	if (istype(thing, /obj/item/reagent_containers/food/snacks))
		fryholder.food_effects += thing:food_effects

	var/icon/composite = new(thing.icon, thing.icon_state)
	for(var/O in thing.underlays + thing.overlays)
		var/image/I = O
		composite.Blend(icon(I.icon, I.icon_state, I.dir, 1), ICON_OVERLAY)

	switch(src.cooktime)
		if (0 to 15)
			fryholder.name = "lightly-fried [thing.name]"
			fryholder.color = ( rgb(166,103,54) )


		if (16 to 49)
			fryholder.name = "fried [thing.name]"
			fryholder.color = ( rgb(103,63,24) )

		if (50 to 59)
			fryholder.name = "deep-fried [thing.name]"
			fryholder.color = ( rgb(63, 23, 4) )

		else
			fryholder.color = ( rgb(33,19,9) )
			fryholder.reagents.maximum_volume += 25
			fryholder.reagents.add_reagent("friedessence",25)

	fryholder.charcoaliness = src.cooktime
	fryholder.icon = composite
	fryholder.overlays = thing.overlays
	if (isitem(thing))
		var/obj/item/item = thing
		fryholder.bites_left = round(item.w_class)
		fryholder.w_class = item.w_class
	else
		fryholder.bites_left = 5
	fryholder.uneaten_bites_left = fryholder.bites_left
	if (ismob(thing))
		fryholder.w_class = W_CLASS_BULKY
	if(thing.reagents)
		fryholder.reagents.maximum_volume += thing.reagents.total_volume
		thing.reagents.trans_to(fryholder, thing.reagents.total_volume)
	fryholder.reagents.my_atom = fryholder

	thing.set_loc(fryholder)
	return fryholder

/obj/machinery/deep_fryer/proc/eject_food()
	if (!src.fryitem)
		UnsubscribeProcess()
		return

	var/obj/item/reagent_containers/food/snacks/shell/deepfry/fryholder = src.fryify(src.fryitem, src.cooktime >= 60)
	fryholder.set_loc(get_turf(src))

/obj/machinery/deep_fryer/Exited(Obj, newloc)
	. = ..()
	if(Obj == src.fryitem)
		src.fryitem = null
		src.UpdateIcon()
		for (var/obj/item/I in src) //Things can get dropped somehow sometimes ok
			I.set_loc(src.loc)
		UnsubscribeProcess()


/obj/machinery/deep_fryer/verb/drain()
	set src in oview(1)
	set name = "Drain Oil"
	set desc = "Drain and replenish fryer oils."
	set category = "Local"

	if (src.reagents)
		if (isobserver(usr) || isintangible(usr)) // Ghosts probably shouldn't be able to take revenge on a traitor chef or whatever (Convair880).
			return
		else
			src.reagents.clear_reagents()
			src.visible_message(SPAN_ALERT("[usr] drains and refreshes the frying oil!"))

/// Shivers: You notice the fryer looks famished, needing to consume ice - VxnipVk6j5A
/obj/machinery/deep_fryer/proc/check_hunger(mob/M, obj/item/W)
	if (!M.client || (src.fed_ice != FALSE)) // no monke sry
		return
	var/shivers = 1
	if (ishuman(M))
		var/mob/living/carbon/human/H = M
		if ((H.mind.assigned_role in list("Detective", "Vice Officer")) || (H.job in list("Detective", "Vice Officer")))
			shivers = 20
	if (prob(0.5 * shivers))
		fed_ice = M // asked this mob
		src.name = "Absolutely Famished [src.name]"
		var/msg = "I'm SO hungry! Please feed me a 20 pound bag of ice!"
		boutput(M, "<span class='radio' style='color: #e8ae2a'>\
			[SPAN_NAME("[src.name] [bicon(src)]")] [SPAN_MESSAGE(" says, \"[msg]\"")]</span>")
		var/image/chat_maptext/maptext = make_chat_maptext(src, msg, "color: #e8ae2a;")
		maptext.show_to(M.client)
