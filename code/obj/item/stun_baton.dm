// Contains:
// - Baton parent
// - Subtypes

////////////////////////////////////////// Stun baton parent //////////////////////////////////////////////////
// Completely refactored the ca. 2009-era code here. Powered batons also use power cells now (Convair880).
/obj/item/baton
	name = "stun baton"
	desc = "A standard issue baton for stunning people with."
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "stunbaton"
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	item_state = "baton-A"
	uses_multiple_icon_states = 1
	flags = FPRINT | ONBELT | TABLEPASS
	force = 10
	throwforce = 7
	health = 7
	w_class = W_CLASS_NORMAL
	mats = list("MET-3"=10, "CON-2"=10)
	contraband = 4
	stamina_damage = 15
	stamina_cost = 21
	stamina_crit_chance = 5
	item_function_flags = USE_INTENT_SWITCH_TRIGGER

	var/icon_on = "stunbaton_active"
	var/icon_off = "stunbaton"
	var/item_on = "baton-A"
	var/item_off = "baton-D"
	var/flick_baton_active = "baton_active"
	var/wait_cycle = 0 // Update sprite periodically if we're using a self-charging cell.

	var/cell_type = /obj/item/ammo/power_cell/med_power // Type of cell to spawn by default.
	var/from_frame_cell_type = /obj/item/ammo/power_cell //type of cell to spawn when mechscanned
	var/cost_normal = 25 // Cost in PU. Doesn't apply to cyborgs.
	var/cost_cyborg = 500 // Battery charge to drain when user is a cyborg.
	var/is_active = TRUE

	var/stun_normal_weakened = 15

	var/disorient_stamina_damage = 130 // Amount of stamina drained.
	var/can_swap_cell = 1
	var/rechargable = 1
	var/beepsky_held_this = 0 // Did a certain validhunter hold this?
	var/flipped = false //is it currently rotated so that youre grabbing it by the head?

	New()
		..()
		var/cell = null
		if(cell_type)
			cell = new cell_type
		AddComponent(/datum/component/cell_holder, cell, rechargable, INFINITY, can_swap_cell)
		RegisterSignal(src, COMSIG_UPDATE_ICON, /atom/proc/UpdateIcon)
		processing_items |= src
		src.UpdateIcon()
		src.setItemSpecial(/datum/item_special/spark/baton)

		BLOCK_SETUP(BLOCK_ROD)

	was_built_from_frame(mob/user, newly_built)
		. = ..()
		if(src.can_swap_cell && from_frame_cell_type)
			AddComponent(/datum/component/cell_holder, new from_frame_cell_type)

		SEND_SIGNAL(src, COMSIG_CELL_USE, INFINITY) //also drain the cell out of spite

	disposing()
		processing_items -= src
		..()

	examine()
		. = ..()
		var/ret = list()
		if (!(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST))
			. += "<span class='alert'>No power cell installed.</span>"
		else
			. += "The baton is turned [src.is_active ? "on" : "off"]. There are [ret["charge"]]/[ret["max_charge"]] PUs left! Each stun will use [src.cost_normal] PUs."

	emp_act()
		src.is_active = FALSE
		src.process_charges(-INFINITY)
		return

	update_icon()

		if (!src || !istype(src))
			return

		if (src.is_active)
			src.set_icon_state("[src.icon_on][src.flipped ? "-f" : ""]") //if flipped is true, attach -f to the icon state. otherwise leave it as normal
			src.item_state = "[src.item_on][src.flipped ? "-f" : ""]"
		else
			src.set_icon_state("[src.icon_off][src.flipped ? "-f" : ""]")
			src.item_state = "[src.item_off][src.flipped ? "-f" : ""]"
			return

	proc/can_stun(var/amount = 1, var/mob/user)
		if (!src || !istype(src))
			return 0
		if (!(src.is_active))
			return 0
		if (amount <= 0)
			return 0

		if (user && isrobot(user))
			var/mob/living/silicon/robot/R = user
			if (R.cell && R.cell.charge >= (src.cost_cyborg * amount))
				return 1
			else
				return 0

		var/ret = SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, src.cost_normal * amount)
		if (!ret)
			if (user && ismob(user))
				user.show_text("The [src.name] doesn't have a power cell!", "red")
			return 0
		if (ret & CELL_INSUFFICIENT_CHARGE)
			if (user && ismob(user))
				user.show_text("The [src.name] is out of charge!", "red")
			return 0
		else
			return 1

	proc/process_charges(var/amount = -1, var/mob/user)
		if (!src || !istype(src) || amount == 0)
			return
		if (user && isrobot(user))
			var/mob/living/silicon/robot/R = user
			if (amount < 0)
				R.cell.use(src.cost_cyborg * -(amount))
		else if (amount < 0)
			SEND_SIGNAL(src, COMSIG_CELL_USE, src.cost_normal * -(amount))
			if (user && ismob(user))
				var/list/ret = list()
				if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
					if (ret["charge"] > 0)
						user.show_text("The [src.name] now has [ret["charge"]]/[ret["max_charge"]] PUs remaining.", "blue")
					else if (ret["charge"] <= 0)
						user.show_text("The [src.name] is now out of charge!", "red")
						src.is_active = FALSE
						if (istype(src, /obj/item/baton/ntso)) //since ntso batons have some extra stuff, we need to set their state var to the correct value to make this work
							var/obj/item/baton/ntso/B = src
							B.state = EXTENDO_BATON_OPEN_AND_OFF
		else if (amount > 0)
			SEND_SIGNAL(src, COMSIG_CELL_CHARGE, src.cost_normal * amount)

		src.UpdateIcon()

		if(istype(user)) // user can be a Securitron sometims, scream
			user.update_inhands()
		return

	proc/do_stun(var/mob/user, var/mob/victim, var/type = "", var/stun_who = 2)
		if (!src || !istype(src) || type == "")
			return
		if (!user || !victim || !ismob(victim))
			return

		// Sound effects, log entries and text messages.
		switch (type)
			if ("failed")
				logTheThing("combat", user, null, "accidentally stuns [himself_or_herself(user)] with the [src.name] at [log_loc(user)].")
				user.visible_message("<span class='alert'><b>[user]</b> fumbles with the [src.name] and accidentally stuns [himself_or_herself(user)]!</span>")
				flick(flick_baton_active, src)
				playsound(src, "sound/impact_sounds/Energy_Hit_3.ogg", 50, 1, -1)

			if ("failed_stun")
				user.visible_message("<span class='alert'><B>[victim] has been prodded with the [src.name] by [user]! Luckily it was off.</B></span>")
				playsound(src, "sound/impact_sounds/Generic_Stab_1.ogg", 25, 1, -1)
				logTheThing("combat", user, victim, "unsuccessfully tries to stun [constructTarget(victim,"combat")] with the [src.name] at [log_loc(victim)].")

				if (src.is_active && !(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, src.cost_normal) & CELL_SUFFICIENT_CHARGE))
					if (user && ismob(user))
						user.show_text("The [src.name] is out of charge!", "red")
				return

			if ("failed_harm")
				user.visible_message("<span class='alert'><B>[user] has attempted to beat [victim] with the [src.name] but held it wrong!</B></span>")
				playsound(src, "sound/impact_sounds/Generic_Stab_1.ogg", 50, 1, -1)
				logTheThing("combat", user, victim, "unsuccessfully tries to beat [constructTarget(victim,"combat")] with the [src.name] at [log_loc(victim)].")

			if ("stun")
				user.visible_message("<span class='alert'><B>[victim] has been stunned with the [src.name] by [user]!</B></span>")
				logTheThing("combat", user, victim, "stuns [constructTarget(victim,"combat")] with the [src.name] at [log_loc(victim)].")
				playsound(src, "sound/impact_sounds/Energy_Hit_3.ogg", 50, 1, -1)
				flick(flick_baton_active, src)
				JOB_XP(victim, "Clown", 3)

			else
				logTheThing("debug", user, null, "<b>Convair880</b>: stun baton ([src.type]) do_stun() was called with an invalid argument ([type]), aborting. Last touched by: [src.fingerprintslast ? "[src.fingerprintslast]" : "*null*"]")
				return

		// Target setup. User might not be a mob (Beepsky), but the victim needs to be one.
		var/mob/dude_to_stun
		if (stun_who == 1 && user && ismob(user))
			dude_to_stun = user
		else
			dude_to_stun = victim


		dude_to_stun.do_disorient(src.disorient_stamina_damage, weakened = src.stun_normal_weakened * 10, disorient = 60)

		if (isliving(dude_to_stun))
			var/mob/living/L = dude_to_stun
			L.Virus_ShockCure(33)
			L.shock_cyberheart(33)

		src.process_charges(-1, user)

		// Some after attack stuff.
		if (user && ismob(user))
			user.lastattacked = dude_to_stun
			dude_to_stun.lastattacker = user
			dude_to_stun.lastattackertime = world.time

		return

	attack_self(mob/user as mob)
		src.add_fingerprint(user)

		if (!(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, cost_normal) & CELL_SUFFICIENT_CHARGE) && !(src.is_active))
			boutput(user, "<span class='alert'>The [src.name] doesn't have enough power to be turned on.</span>")
			return

		src.is_active = !src.is_active

		if (src.can_stun() == 1 && user.bioHolder && user.bioHolder.HasEffect("clumsy") && prob(50))
			src.do_stun(user, user, "failed", 1)
			JOB_XP(user, "Clown", 2)
			return

		if (src.is_active)
			boutput(user, "<span class='notice'>The [src.name] is now on.</span>")
			playsound(src, "sparks", 75, 1, -1)
		else
			boutput(user, "<span class='notice'>The [src.name] is now off.</span>")
			playsound(src, "sparks", 75, 1, -1)

		src.UpdateIcon()
		user.update_inhands()

		return

	attack(mob/M as mob, mob/user as mob)
		src.add_fingerprint(user)

		if(check_target_immunity( M ))
			user.show_message("<span class='alert'>[M] seems to be warded from attacks!</span>")
			return

		if (src.can_stun() == 1 && user.bioHolder && user.bioHolder.HasEffect("clumsy") && prob(50))
			src.do_stun(user, M, "failed", 1)
			JOB_XP(user, "Clown", 1)
			return

		switch (user.a_intent)
			if ("harm")
				if (!src.is_active || (src.is_active && src.can_stun() == 0))
					playsound(src, "swing_hit", 50, 1, -1)
					..()
				else
					src.do_stun(user, M, "failed_harm", 1)

			else
				if (!src.is_active || (src.is_active && src.can_stun() == 0))
					src.do_stun(user, M, "failed_stun", 1)
				else
					src.do_stun(user, M, "stun", 2)

		return

	intent_switch_trigger(var/mob/user)
		src.do_flip_stuff(user, user.a_intent)

	attack_hand(var/mob/user)
		if (src.flipped && user.a_intent != INTENT_HARM)
			user.show_text("You flip \the [src] the right way around as you grab it.")
			src.flipped = false
			src.UpdateIcon()
			user.update_inhands()
		else if (user.a_intent == INTENT_HARM)
			src.do_flip_stuff(user, INTENT_HARM)
		..()

	proc/do_flip_stuff(var/mob/user, var/intent)
		if (intent == INTENT_HARM)
			if (src.flipped) //swapping hands triggers the intent switch too, so we dont wanna spam that
				return
			src.flipped = true
			animate(src, transform = turn(matrix(), 120), time = 0.07 SECONDS) //turn partially
			animate(transform = turn(matrix(), 240), time = 0.07 SECONDS) //turn the rest of the way
			animate(transform = turn(matrix(), 180), time = 0.04 SECONDS) //finish up at the right spot
			src.transform = null //clear it before updating icon
			src.setItemSpecial(/datum/item_special/simple)
			src.UpdateIcon()
			user.update_inhands()
			user.show_text("<B>You flip \the [src] and grab it by the head! [src.is_active ? "It seems pretty unsafe to hold it like this while it's on!" : "At least it's off!"]</B>", "red")
		else //not already flipped
			if (!src.flipped) //swapping hands triggers the intent switch too, so we dont wanna spam that
				return
			src.flipped = false
			animate(src, transform = turn(matrix(), 120), time = 0.07 SECONDS) //turn partially
			animate(transform = turn(matrix(), 240), time = 0.07 SECONDS) //turn the rest of the way
			animate(transform = turn(matrix(), 180), time = 0.04 SECONDS) //finish up at the right spot
			src.transform = null //clear it before updating icon
			src.setItemSpecial(/datum/item_special/spark/baton)
			src.UpdateIcon()
			user.update_inhands()
			user.show_text("<B>You flip \the [src] and grab it by the base!", "red")

	dropped(mob/user)
		if (src.flipped)
			src.setItemSpecial(/datum/item_special/spark/baton)
			src.flipped = false
			src.UpdateIcon()
			user.update_inhands()
		..()

/////////////////////////////////////////////// Subtypes //////////////////////////////////////////////////////

/obj/item/baton/secbot
	cost_normal = 0

/obj/item/baton/beepsky
	name = "securitron stun baton"
	desc = "A stun baton that's been modified to be used more effectively by security robots. There's a small parallel port on the bottom of the handle."
	can_swap_cell = 0
	rechargable = 0
	cell_type = /obj/item/ammo/power_cell
	mats = 0 //no

/obj/item/baton/cane
	name = "stun cane"
	desc = "A stun baton built into the casing of a cane."
	icon_state = "stuncane"
	item_state = "cane"
	icon_on = "stuncane_active"
	icon_off = "stuncane"
	item_on = "cane"
	item_off = "cane"
	cell_type = /obj/item/ammo/power_cell
	mats = list("MET-3"=10, "CON-2"=10, "gem"=1, "gold"=1)

/obj/item/baton/classic
	name = "police baton"
	desc = "YOU SHOULD NOT SEE THIS"
	icon_state = "baton"
	item_state = "classic_baton"
	force = 15
	mats = 0
	contraband = 6
	icon_on = "baton"
	icon_off = "baton"
	stamina_damage = 105
	stamina_cost = 25
	cost_normal = 0
	can_swap_cell = 0

	New()
		..()
		src.setItemSpecial(/datum/item_special/simple) //override spark of parent

	do_stun(mob/user, mob/victim, type, stun_who)
		user.visible_message("<span class='alert'><B>[victim] has been beaten with the [src.name] by [user]!</B></span>")
		playsound(src, "swing_hit", 50, 1, -1)
		random_brute_damage(victim, src.force, 1) // Necessary since the item/attack() parent wasn't called.
		victim.changeStatus("weakened", 8 SECONDS)
		victim.force_laydown_standup()
		victim.remove_stamina(src.stamina_damage)
		if (user && ismob(user) && user.get_stamina() >= STAMINA_MIN_ATTACK)
			user.remove_stamina(src.stamina_cost)


/obj/item/baton/ntso
	name = "extendable stun baton"
	desc = "An extendable stun baton for NT Security Operatives in sleek NanoTrasen blue."
	icon_state = "ntso_baton-c"
	item_state = "ntso-baton-c"
	force = 7
	mats = list("MET-3"=10, "CON-2"=10, "POW-1"=5)
	icon_on = "ntso-baton-a-1"
	icon_off = "ntso-baton-c"
	var/icon_off_open = "ntso-baton-a-0"
	item_on = "ntso-baton-a"
	item_off = "ntso-baton-c"
	var/item_off_open = "ntso-baton-d"
	flick_baton_active = "ntso-baton-a-1"
	w_class = W_CLASS_SMALL	//2 when closed, 4 when extended
	can_swap_cell = 0
	rechargable = 0
	is_active = FALSE
	// stamina_based_stun_amount = 110
	cost_normal = 25 // Cost in PU. Doesn't apply to cyborgs.
	cell_type = /obj/item/ammo/power_cell/self_charging/ntso_baton
	from_frame_cell_type = /obj/item/ammo/power_cell/self_charging/disruptor
	item_function_flags = 0
	//bascially overriding is_active, but it's kinda hacky in that they both are used jointly
	var/state = EXTENDO_BATON_CLOSED_AND_OFF

	New()
		..()
		src.setItemSpecial(/datum/item_special/spark/ntso) //override spark of parent

	//change for later for more interestings whatsits
	// can_stun(var/requires_electricity = 0, var/amount = 1, var/mob/user)
	// 	..(requires_electricity, amount, user)
	// 	if (state == EXTENDO_BATON_CLOSED_AND_OFF || state == EXTENDO_BATON_OPEN_AND_OFF)
	// 		return 0

	attack_self(mob/user as mob)
		src.add_fingerprint(user)
		//never should happen but w/e

		//make it harder for them clowns...
		if (src.can_stun() == 1 && user.bioHolder && user.bioHolder.HasEffect("clumsy") && prob(50))
			src.do_stun(user, user, "failed", 1)
			JOB_XP(user, "Clown", 2)
			return

		//move to next state
		switch (src.state)
			if (EXTENDO_BATON_CLOSED_AND_OFF)		//move to open/on state
				if (!(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, cost_normal) & CELL_SUFFICIENT_CHARGE)) //ugly copy pasted code to move to next state if its depowered, cleanest solution i could think of
					boutput(user, "<span class='alert'>The [src.name] doesn't have enough power to be turned on.</span>")
					src.state = EXTENDO_BATON_OPEN_AND_OFF
					src.is_active = FALSE
					src.w_class = W_CLASS_BULKY
					src.force = 7
					playsound(src, "sound/misc/lightswitch.ogg", 75, 1, -1)
					boutput(user, "<span class='notice'>The [src.name] is now open and unpowered.</span>")
					src.UpdateIcon()
					user.update_inhands()
					return

				//this is the stuff that normally happens
				src.state = EXTENDO_BATON_OPEN_AND_ON
				src.is_active = TRUE
				boutput(user, "<span class='notice'>The [src.name] is now open and on.</span>")
				src.w_class = W_CLASS_BULKY
				src.force = 7
				playsound(src, "sparks", 75, 1, -1)
			if (EXTENDO_BATON_OPEN_AND_ON)		//move to open/off state
				src.state = EXTENDO_BATON_OPEN_AND_OFF
				src.is_active = FALSE
				src.w_class = W_CLASS_BULKY
				src.force = 7
				playsound(src, "sound/misc/lightswitch.ogg", 75, 1, -1)
				boutput(user, "<span class='notice'>The [src.name] is now open and unpowered.</span>")
				// playsound(src, "sparks", 75, 1, -1)
			if (EXTENDO_BATON_OPEN_AND_OFF)		//move to closed/off state
				src.state = EXTENDO_BATON_CLOSED_AND_OFF
				src.is_active = FALSE
				src.w_class = W_CLASS_SMALL
				src.force = 1
				boutput(user, "<span class='notice'>The [src.name] is now closed.</span>")
				playsound(src, "sparks", 75, 1, -1)

		src.UpdateIcon()
		user.update_inhands()


	update_icon()

		if (!src || !istype(src))
			return
		switch (src.state)
			if (EXTENDO_BATON_CLOSED_AND_OFF)
				src.set_icon_state(src.icon_off)
				src.item_state = src.item_off
			if (EXTENDO_BATON_OPEN_AND_ON)
				src.set_icon_state(src.icon_on)
				src.item_state = src.item_on
			if (EXTENDO_BATON_OPEN_AND_OFF)
				src.set_icon_state(src.icon_off_open)
				src.item_state = src.item_off_open

	throw_impact(atom/A, datum/thrown_thing/thr)
		if(isliving(A))
			if (src.state == EXTENDO_BATON_OPEN_AND_ON && src.can_stun())
				src.do_stun(usr, A, "stun")
				return
		..()

	emp_act()
		if (state == EXTENDO_BATON_OPEN_AND_ON)
			state = EXTENDO_BATON_OPEN_AND_OFF
		src.is_active = FALSE
		usr.show_text("The [src.name] is now open and unpowered.", "blue")
		src.process_charges(-INFINITY)
