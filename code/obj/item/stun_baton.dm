#define CLOSED_AND_OFF 1
#define OPEN_AND_ON 2
#define OPEN_AND_OFF 3

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
	w_class = 3
	mats = 8
	contraband = 4
	stamina_damage = 15
	stamina_cost = 21
	stamina_crit_chance = 5

	var/icon_on = "stunbaton_active"
	var/icon_off = "stunbaton"
	var/flick_baton_active = "baton_active"
	var/wait_cycle = 0 // Update sprite periodically if we're using a self-charging cell.

	var/cell_type = /obj/item/ammo/power_cell/med_power // Type of cell to spawn by default.
	var/obj/item/ammo/power_cell/cell = null // Ignored for cyborgs and when used_electricity is false.
	var/cost_normal = 25 // Cost in PU. Doesn't apply to cyborgs.
	var/cost_cyborg = 500 // Battery charge to drain when user is a cyborg.
	var/uses_charges = 1 // Does it deduct charges when used? Distinct from...
	var/uses_electricity = 1 // Does it use electricity? Certain interactions don't work with a wooden baton.
	var/status = 1

	var/stun_normal_weakened = 20
	var/stun_normal_stuttering = 20
	var/stun_harm_weakened = 8 // Only used when next flag is set to 1.
	var/instant_harmbaton_stun = 0 // Legacy behaviour for harmbaton, that is an instant knockdown.
#ifdef USE_STAMINA_DISORIENT
	var/stamina_based_stun = 1
#else
	var/stamina_based_stun = 0 // Experimental. Centered around stamina instead of traditional stun.
#endif
	var/stamina_based_stun_amount = 130 // Amount of stamina drained.
	var/can_swap_cell = 1
	var/beepsky_held_this = 0 // Did a certain validhunter hold this?


	New()
		..()
		if (src.uses_electricity != 0 && (!isnull(src.cell_type) && ispath(src.cell_type, /obj/item/ammo/power_cell)) && (!src.cell || !istype(src.cell)))
			src.cell = new src.cell_type(src)
		if (!(src in processing_items)) // No self-charging cell? Will be removed after the first tick.
			processing_items.Add(src)
		src.update_icon()
		src.setItemSpecial(/datum/item_special/spark)

		BLOCK_ROD

	disposing()
		if (src in processing_items)
			processing_items.Remove(src)
		if(cell)
			cell.dispose()
			cell = null
		..()

	examine()
		. = ..()
		if (src.uses_charges != 0 && src.uses_electricity != 0)
			if (!src.cell || !istype(src.cell))
				. += "<span class='alert'>No power cell installed.</span>"
			else
				. += "The baton is turned [src.status ? "on" : "off"]. There are [src.cell.charge]/[src.cell.max_charge] PUs left! Each stun will use [src.cost_normal] PUs."

	emp_act()
		if (src.uses_charges != 0 && src.uses_electricity != 0)
			src.status = 0
			src.process_charges(-INFINITY)
		return

	process()
		src.wait_cycle = !src.wait_cycle
		if (src.wait_cycle)
			return

		if (!(src in processing_items))
			logTheThing("debug", null, null, "<b>Convair880</b>: Process() was called for a stun baton ([src.type]) that wasn't in the item loop. Last touched by: [src.fingerprintslast ? "[src.fingerprintslast]" : "*null*"]")
			processing_items.Add(src)
			return
		if (!src.cell || !istype(src.cell) || src.uses_electricity == 0)
			processing_items.Remove(src)
			return
		if (!istype(src.cell, /obj/item/ammo/power_cell/self_charging)) // Kick out batons with a plain cell.
			processing_items.Remove(src)
			return
		if (src.cell.charge == src.cell.max_charge) // Keep self-charging cells in the loop, though.
			return

		src.update_icon()
		return

	proc/update_icon()
		if (!src || !istype(src))
			return

		if (src.status)
			set_icon_state(src.icon_on)
		else
			set_icon_state(src.icon_off)

		return

	proc/can_stun(var/requires_electricity = 0, var/amount = 1, var/mob/user)
		if (!src || !istype(src))
			return 0
		if (src.uses_electricity == 0)
			if (requires_electricity == 0)
				return 1
			else
				return 0
		if (src.status == 0)
			return 0
		if (amount <= 0)
			return 0

		src.regulate_charge()
		if (user && isrobot(user))
			var/mob/living/silicon/robot/R = user
			if (R.cell && R.cell.charge >= (src.cost_cyborg * amount))
				return 1
			else
				return 0
		if (!src.cell || !istype(src.cell))
			if (user && ismob(user))
				user.show_text("The [src.name] doesn't have a power cell!", "red")
			return 0
		if (src.cell.charge < (src.cost_normal * amount))
			if (user && ismob(user))
				user.show_text("The [src.name] is out of charge!", "red")
			return 0
		else
			return 1

	proc/regulate_charge()
		if (!src || !istype(src))
			return

		if (src.cell && istype(src.cell))
			if (src.cell.charge < 0)
				src.cell.charge = 0
			if (src.cell.charge > src.cell.max_charge)
				src.cell.charge = src.cell.max_charge

			src.cell.update_icon()
			src.update_icon()

		return

	proc/process_charges(var/amount = -1, var/mob/user)
		if (!src || !istype(src) || amount == 0)
			return
		if (src.uses_electricity == 0)
			return

		if (user && isrobot(user))
			var/mob/living/silicon/robot/R = user
			if (amount < 0)
				R.cell.use(src.cost_cyborg * -(amount))
		else
			if (src.uses_charges != 0 && (src.cell && istype(src.cell)))
				if (amount < 0)
					src.cell.use(src.cost_normal * -(amount))
					if (user && ismob(user))
						if (src.cell.charge > 0)
							user.show_text("The [src.name] now has [src.cell.charge]/[src.cell.max_charge] PUs remaining.", "blue")
						else if (src.cell.charge <= 0)
							user.show_text("The [src.name] is now out of charge!", "red")
							src.stamina_damage = initial(src.stamina_damage)
							src.status = 0
							src.item_state = "baton-D"
							use_stamina_stun() //set stam damage amount
							if (istype(src, /obj/item/baton/ntso)) //since ntso batons have some extra stuff, we need to set their state var to the correct value to make this work
								var/obj/item/baton/ntso/B = src
								B.state = OPEN_AND_OFF
								B.item_state = "ntso-baton-d"
				else if (amount > 0)
					src.cell.charge(src.cost_normal * amount)

		src.update_icon()
		if(istype(user)) // user can be a Securitron sometims, scream
			user.update_inhands()
		return

	proc/charge(var/amt)
		if(src.cell)
			return src.cell.charge(amt)
		else
			//No cell. Tell anything trying to charge it.
			return -1

	proc/use_stamina_stun()
		if (!src || !istype(src))
			return 0

		if (src.stamina_based_stun != 0 && src.cell && can_stun())
			src.stamina_damage = src.stamina_based_stun_amount
			return 1
		else
			src.stamina_damage = initial(src.stamina_damage) // Doubles as reset fallback (var editing).
			return 0

	proc/do_stun(var/mob/user, var/mob/victim, var/type = "", var/stun_who = 2)
		if (!src || !istype(src) || type == "")
			return
		if (!user || !victim || !ismob(victim))
			return

		// Sound effects, log entries and text messages.
		switch (type)
			if ("failed")
				logTheThing("combat", user, null, "accidentally stuns [himself_or_herself(user)] with the [src.name] at [log_loc(user)].")

				if (src.uses_electricity != 0)
					user.visible_message("<span class='alert'><b>[user]</b> fumbles with the [src.name] and accidentally stuns [himself_or_herself(user)]!</span>")
					flick(flick_baton_active, src)
					playsound(get_turf(src), "sound/impact_sounds/Energy_Hit_3.ogg", 50, 1, -1)
				else
					user.visible_message("<span class='alert'><b>[user]</b> swings the [src.name] in the wrong way and accidentally hits [himself_or_herself(user)]!</span>")
					playsound(get_turf(src), "sound/impact_sounds/Generic_Stab_1.ogg", 50, 1, -1)
					random_brute_damage(user, 2 * src.force)

			if ("failed_stun")
				user.visible_message("<span class='alert'><B>[victim] has been prodded with the [src.name] by [user]! Luckily it was off.</B></span>")
				playsound(get_turf(src), "sound/impact_sounds/Generic_Stab_1.ogg", 25, 1, -1)
				logTheThing("combat", user, victim, "unsuccessfully tries to stun [constructTarget(victim,"combat")] with the [src.name] at [log_loc(victim)].")

				if (src.uses_electricity && src.status == 1 && (src.cell && istype(src.cell) && (src.cell.charge < src.cost_normal)))
					if (user && ismob(user))
						user.show_text("The [src.name] is out of charge!", "red")
				return

			if ("failed_harm")
				user.visible_message("<span class='alert'><B>[user] has attempted to beat [victim] with the [src.name] but held it wrong!</B></span>")
				playsound(get_turf(src), "sound/impact_sounds/Generic_Stab_1.ogg", 50, 1, -1)
				logTheThing("combat", user, victim, "unsuccessfully tries to beat [constructTarget(victim,"combat")] with the [src.name] at [log_loc(victim)].")

			if ("stun", "stun_classic")
				user.visible_message("<span class='alert'><B>[victim] has been stunned with the [src.name] by [user]!</B></span>")
				logTheThing("combat", user, victim, "stuns [constructTarget(victim,"combat")] with the [src.name] at [log_loc(victim)].")
				JOB_XP(victim, "Clown", 3)
				if (type == "stun_classic")
					playsound(get_turf(src), "sound/impact_sounds/Generic_Stab_1.ogg", 50, 1, -1)
				else
					flick(flick_baton_active, src)
					playsound(get_turf(src), "sound/impact_sounds/Energy_Hit_3.ogg", 50, 1, -1)

			if ("harm_classic")
				user.visible_message("<span class='alert'><B>[victim] has been beaten with the [src.name] by [user]!</B></span>")
				playsound(get_turf(src), "swing_hit", 50, 1, -1)
				logTheThing("combat", user, victim, "beats [constructTarget(victim,"combat")] with the [src.name] at [log_loc(victim)].")

			else
				logTheThing("debug", user, null, "<b>Convair880</b>: stun baton ([src.type]) do_stun() was called with an invalid argument ([type]), aborting. Last touched by: [src.fingerprintslast ? "[src.fingerprintslast]" : "*null*"]")
				return

		// Target setup. User might not be a mob (Beepsky), but the victim needs to be one.
		var/mob/dude_to_stun
		if (stun_who == 1 && user && ismob(user))
			dude_to_stun = user
		else
			dude_to_stun = victim

		// Stun the target mob.
		if (type == "harm_classic")
			dude_to_stun.changeStatus("weakened", src.stun_harm_weakened * 10)
			dude_to_stun.force_laydown_standup()
			random_brute_damage(dude_to_stun, src.force,1) // Necessary since the item/attack() parent wasn't called. Wait, was this armor-piercing? -Tarm
			dude_to_stun.remove_stamina(src.stamina_damage)
			if (user && ismob(user))
				user.remove_stamina(src.stamina_cost)

		else
			if (dude_to_stun.bioHolder && dude_to_stun.bioHolder.HasEffect("resist_electric") && src.uses_electricity != 0)
				boutput(dude_to_stun, "<span class='notice'>Thankfully, electricity doesn't do much to you in your current state.</span>")
			else
				if (!src.use_stamina_stun() || (src.use_stamina_stun() && ismob(dude_to_stun) && !hasvar(dude_to_stun, "stamina")))
					dude_to_stun.changeStatus("weakened", src.stun_normal_weakened * 10)
					dude_to_stun.force_laydown_standup()
					if ((dude_to_stun.stuttering < src.stun_normal_stuttering))
						dude_to_stun.stuttering = src.stun_normal_stuttering
				else
					dude_to_stun.do_disorient(src.stamina_damage, weakened = src.stun_normal_weakened * 10, disorient = 80)
					//dude_to_stun.remove_stamina(src.stamina_damage)
					//dude_to_stun.stamina_stun() // Must be called manually here to apply the stun instantly.

				if (isliving(dude_to_stun) && src.uses_electricity != 0)
					var/mob/living/L = dude_to_stun
					L.Virus_ShockCure(33)
					L.shock_cyberheart(33)

			src.process_charges(-1, user)

		// Some after attack stuff.
		if (user && ismob(user))
			user.lastattacked = dude_to_stun
			dude_to_stun.lastattacker = user
			dude_to_stun.lastattackertime = world.time

		src.update_icon()
		return

	attack_self(mob/user as mob)
		src.add_fingerprint(user)

		if (src.uses_electricity == 0)
			return

		if (!src.cell.charge || src.cell.charge - src.cost_normal <= 0)
			boutput(user, "<span class='alert'>The [src.name] doesn't have enough power to be turned on.</span>")
			return

		src.regulate_charge()
		src.status = !src.status

		if (src.can_stun() == 1 && user.bioHolder && user.bioHolder.HasEffect("clumsy") && prob(50))
			src.do_stun(user, user, "failed", 1)
			JOB_XP(user, "Clown", 2)
			return

		if (src.status)
			boutput(user, "<span class='notice'>The [src.name] is now on.</span>")
			src.item_state = "baton-A"
			playsound(get_turf(src), "sparks", 75, 1, -1)
		else
			boutput(user, "<span class='notice'>The [src.name] is now off.</span>")
			src.item_state = "baton-D"
			playsound(get_turf(src), "sparks", 75, 1, -1)

		src.update_icon()
		user.update_inhands()
		use_stamina_stun() //set stam damage amount

		return

	attack(mob/M as mob, mob/user as mob)
		src.add_fingerprint(user)
		src.regulate_charge()

		use_stamina_stun() //set stam damage amount

		if(check_target_immunity( M ))
			user.show_message("<span class='alert'>[M] seems to be warded from attacks!</span>")
			return

		if (src.can_stun() == 1 && user.bioHolder && user.bioHolder.HasEffect("clumsy") && prob(50))
			src.do_stun(user, M, "failed", 1)
			JOB_XP(user, "Clown", 1)
			return

		switch (user.a_intent)
			if ("harm")
				if (src.uses_electricity == 0)
					if (src.instant_harmbaton_stun != 0)
						src.do_stun(user, M, "harm_classic", 2)
					else
						playsound(get_turf(src), "swing_hit", 50, 1, -1)
						..() // Parent handles attack log entry and stamina drain.
				else
					if (src.status == 0 || (src.status != 0 && src.can_stun() == 0))
						if (src.instant_harmbaton_stun != 0)
							src.do_stun(user, M, "harm_classic", 2)
						else
							playsound(get_turf(src), "swing_hit", 50, 1, -1)
							..()
					else
						src.do_stun(user, M, "failed_harm", 1)

			else
				if (src.uses_electricity == 0)
					src.do_stun(user, M, "stun_classic", 2)
				else
					if (src.status == 0 || (src.status != 0 && src.can_stun() == 0))
						src.do_stun(user, M, "failed_stun", 1)
					else
						src.do_stun(user, M, "stun", 2)

		return

	attackby(obj/item/b as obj, mob/user as mob)
		if (can_swap_cell && istype(b, /obj/item/ammo/power_cell/))
			var/obj/item/ammo/power_cell/pcell = b
			src.log_cellswap(user, pcell) //if (!src.rechargeable)
			if (istype(pcell, /obj/item/ammo/power_cell/self_charging) && !(src in processing_items)) // Again, we want dynamic updates here (Convair880).
				processing_items.Add(src)
			if (src.cell)
				if (pcell.swap(src))
					user.visible_message("<span class='alert'>[user] swaps [src]'s power cell.</span>")
			else
				src.cell = pcell
				user.drop_item()
				pcell.set_loc(src)
				user.visible_message("<span class='alert'>[user] swaps [src]'s power cell.</span>")
		else
			..()

	proc/log_cellswap(var/mob/user as mob, var/obj/item/ammo/power_cell/C)
		if (!user || !src || !istype(src) || !C || !istype(C))
			return

		logTheThing("combat", user, null, "swaps the power cell (<b>Cell type:</b> <i>[C.type]</i>) of [src] at [log_loc(user)].")
		return

/////////////////////////////////////////////// Subtypes //////////////////////////////////////////////////////

/obj/item/baton/secbot
	uses_charges = 0

/obj/item/baton/beepsky
	name = "securitron stun baton"
	desc = "A stun baton that's been modified to be used more effectively by security robots. There's a small parallel port on the bottom of the handle."

/obj/item/baton/stamina
	stamina_based_stun = 1

/obj/item/baton/cane
	name = "stun cane"
	desc = "A stun baton built into the casing of a cane."
	icon_state = "stuncane"
	item_state = "cane"
	icon_on = "stuncane_active"
	icon_off = "stuncane"
	cell_type = /obj/item/ammo/power_cell

/obj/item/baton/classic
	name = "police baton"
	desc = "A wooden truncheon for beating criminal scum."
	icon_state = "baton"
	item_state = "classic_baton"
	force = 10
	mats = 0
	contraband = 6
	icon_on = "baton"
	icon_off = "baton"
	uses_charges = 0
	uses_electricity = 0
	stun_normal_weakened = 8
	stun_normal_stuttering = 8
	instant_harmbaton_stun = 1
	stamina_based_stun_amount = 90

	New()
		..()
		src.setItemSpecial(/datum/item_special/simple) //override spark of parent

/obj/item/baton/ntso
	name = "extendable stun baton"
	desc = "An extendable stun baton for NT Security Operatives in sleek NanoTrasen blue."
	icon_state = "ntso_baton-c"
	item_state = "ntso-baton-c"
	force = 7
	icon_on = "ntso-baton-a-1"
	icon_off = "ntso-baton-c"
	var/icon_off_open = "ntso-baton-a-0"
	flick_baton_active = "ntso-baton-a-1"
	w_class = 2				//2 when closed, 4 when extended
	can_swap_cell = 0
	status = 0
	// stamina_based_stun_amount = 110

	cost_normal = 25 // Cost in PU. Doesn't apply to cyborgs.

	cell_type = /obj/item/ammo/power_cell/self_charging/ntso_baton
	//bascially overriding status, but it's kinda hacky in that they both are used jointly
	var/state = CLOSED_AND_OFF

	New()
		..()
		src.setItemSpecial(/datum/item_special/spark/ntso) //override spark of parent

	//change for later for more interestings whatsits
	// can_stun(var/requires_electricity = 0, var/amount = 1, var/mob/user)
	// 	..(requires_electricity, amount, user)
	// 	if (state == CLOSED_AND_OFF || state == OPEN_AND_OFF)
	// 		return 0

	attack_self(mob/user as mob)
		src.add_fingerprint(user)
		//never should happen but w/e
		if (src.uses_electricity == 0)
			return

		src.regulate_charge()
		//make it harder for them clowns...
		if (src.can_stun() == 1 && user.bioHolder && user.bioHolder.HasEffect("clumsy") && prob(50))
			src.do_stun(user, user, "failed", 1)
			JOB_XP(user, "Clown", 2)
			return

		//move to next state
		switch (src.state)
			if (CLOSED_AND_OFF)		//move to open/on state
				if (!src.cell.charge || src.cell.charge - src.cost_normal <= 0) //ugly copy pasted code to move to next state if its depowered, cleanest solution i could think of
					boutput(user, "<span class='alert'>The [src.name] doesn't have enough power to be turned on.</span>")
					src.state = OPEN_AND_OFF
					src.status = 0
					src.item_state = "ntso-baton-d"
					src.w_class = 4
					src.force = 7
					playsound(get_turf(src), "sound/misc/lightswitch.ogg", 75, 1, -1)
					boutput(user, "<span class='notice'>The [src.name] is now open and unpowered.</span>")
					src.update_icon()
					user.update_inhands()
					use_stamina_stun() //set stam damage amount
					return

				//this is the stuff that normally happens
				src.state = OPEN_AND_ON
				src.status = 1
				boutput(user, "<span class='notice'>The [src.name] is now open and on.</span>")
				src.item_state = "ntso-baton-a"
				src.w_class = 4
				src.force = 7
				playsound(get_turf(src), "sparks", 75, 1, -1)
			if (OPEN_AND_ON)		//move to open/off state
				src.state = OPEN_AND_OFF
				src.status = 0
				src.item_state = "ntso-baton-d"
				src.w_class = 4
				src.force = 7
				playsound(get_turf(src), "sound/misc/lightswitch.ogg", 75, 1, -1)
				boutput(user, "<span class='notice'>The [src.name] is now open and unpowered.</span>")
				// playsound(get_turf(src), "sparks", 75, 1, -1)
			if (OPEN_AND_OFF)		//move to closed/off state
				src.state = CLOSED_AND_OFF
				src.status = 0
				src.item_state = "ntso-baton-c"
				src.w_class = 2
				src.force = 1
				boutput(user, "<span class='notice'>The [src.name] is now closed.</span>")
				playsound(get_turf(src), "sparks", 75, 1, -1)

		src.update_icon()
		user.update_inhands()
		use_stamina_stun() //set stam damage amount

		return

	update_icon()
		if (!src || !istype(src))
			return
		switch (state)
			if (CLOSED_AND_OFF)
				set_icon_state(src.icon_off)
			if (OPEN_AND_ON)
				set_icon_state(src.icon_on)
			if (OPEN_AND_OFF)
				set_icon_state(src.icon_off_open)

		return

	throw_impact(atom/A)
		if(isliving(A))
			if (src.state == OPEN_AND_ON && src.can_stun())
				src.do_stun(usr, A, "stun")
				return
		..()

	emp_act()
		if (src.uses_charges != 0 && src.uses_electricity != 0)
			if (state == OPEN_AND_ON)
				state = OPEN_AND_OFF
			src.status = 0
			usr.show_text("The [src.name] is now open and unpowered.", "blue")
			src.process_charges(-INFINITY)

		return

#undef CLOSED_AND_OFF
#undef OPEN_AND_ON
#undef OPEN_AND_OFF

//todo : move this out of stun baton dm lol
/obj/item/barrier
	name = "barrier"
	desc = "A personal barrier. Activate this item with both hands free to use it."
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "barrier_0"
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	item_state = "barrier0"
	uses_multiple_icon_states = 1
	flags = FPRINT | ONBELT | TABLEPASS
	c_flags = EQUIPPED_WHILE_HELD
	force = 2
	throwforce = 6
	w_class = 2
	mats = 8
	stamina_damage = 25
	stamina_cost = 10
	stamina_crit_chance = 0
	hitsound = 0

	can_disarm = 1
	two_handed = 0
	var/use_two_handed = 0

	var/status = 0
	var/obj/itemspecialeffect/barrier/E = 0

	New()
		..()
		BLOCK_ALL
		c_flags &= ~BLOCK_TOOLTIP

	block_prop_setup(source, obj/item/grab/block/B)
		if(src.status)
			B.setProperty("rangedprot", 0.5)
			B.setProperty("exploprot", 1)
			. = ..()

	proc/update_icon()
		icon_state = status ? "barrier_1" : "barrier_0"
		item_state = status ? "barrier1" : "barrier0"

	attack_self(mob/user as mob)
		src.add_fingerprint(user)

		if (!use_two_handed || setTwoHanded(!src.status))
			src.status = !src.status

			playsound(get_turf(src), "sparks", 75, 1, -1)
			if (src.status)
				w_class = 4
				flags &= ~ONBELT //haha NO
				setProperty("meleeprot_all", 9)
				setProperty("rangedprot", 1.5)
				setProperty("movespeed", 0.3)
				setProperty("disorient_resist", 65)
				setProperty("disorient_resist_eye", 65)
				setProperty("disorient_resist_ear", 50) //idk how lol ok
				flick("barrier_a",src)
				c_flags |= BLOCK_TOOLTIP

				src.setItemSpecial(/datum/item_special/barrier)
			else
				w_class = 2
				flags |= ONBELT
				delProperty("meleeprot_all", 0)
				delProperty("rangedprot", 0)
				delProperty("movespeed", 0)
				delProperty("disorient_resist", 0)
				delProperty("disorient_resist_eye", 0)
				delProperty("disorient_resist_ear", 0)
				c_flags &= ~BLOCK_TOOLTIP

				src.setItemSpecial(/datum/item_special/simple)

			user.update_equipped_modifiers() // Call the bruteforce movement modifier proc because we changed movespeed while equipped

			destroy_deployed_barrier(user)

			can_disarm = src.status

			src.update_icon()
			user.update_inhands()
		else
			user.show_text("You need two free hands in order to activate the [src.name].", "red")

		..()

	attack(mob/M as mob, mob/user as mob)
		..()
		playsound(get_turf(src), 'sound/impact_sounds/Energy_Hit_1.ogg', 30, 0.1, 0, 2)

	dropped(mob/M)
		..()
		destroy_deployed_barrier(M)

	move_callback(var/mob/living/M, var/turf/source, var/turf/target)
		//don't delete the barrier while we are restrained from deploying the barrier
		if (M.restrain_time > TIME)
			return

		if (source != target)
			destroy_deployed_barrier(M)

	proc/destroy_deployed_barrier(var/mob/living/M)
		if (E)
			var/obj/itemspecialeffect/barrier/EE = E
			E = 0
			if (islist(M.move_laying))
				M.move_laying -= src
			else
				M.move_laying = null
			EE.deactivate()

/obj/item/syndicate_barrier
	name = "Aegis Riot Barrier"
	desc = "A personal barrier."
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "metal"
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	item_state = "barrier0"
	flags = FPRINT | ONBELT | TABLEPASS
	c_flags = EQUIPPED_WHILE_HELD
	force = 2
	throwforce = 6
	w_class = 2
	stamina_damage = 30
	stamina_cost = 10
	stamina_crit_chance = 0
	hitsound = 0

	setupProperties()
		..()
		setProperty("meleeprot_all", 9)
		setProperty("rangedprot", 1.5)
		setProperty("movespeed", 0.3)
		setProperty("disorient_resist", 65)
		setProperty("disorient_resist_eye", 65)
		setProperty("disorient_resist_ear", 50)

		src.setItemSpecial(/datum/item_special/barrier)
		BLOCK_ALL
