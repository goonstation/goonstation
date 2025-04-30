
/// Charge for defibrillators with internal small power cells
#define DEFIB_CHARGE_SMALL_CELL_COST 25 WATTS
/// Charge for defibrillators that draw from large power cells (i.e. the ones in APCs)
#define DEFIB_CHARGE_LARGE_CELL_COST 500 WATTS

// TODO: common abstract parent to split power cell / cell using defibs; requires large code & map repathing

TYPEINFO(/obj/item/robodefibrillator)
	mats = list("metal" = 10,
				"conductive" = 15)
/obj/item/robodefibrillator
	name = "defibrillator"
	desc = "Uses electrical currents to restart the hearts of critical patients."
	flags = TABLEPASS | CONDUCT
	icon = 'icons/obj/surgery.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_medical.dmi'
	icon_state = "defib-off"
	item_state = "defib"
	pickup_sfx = 'sound/items/pickup_defib.ogg'
	inventory_counter_enabled = TRUE
	var/icon_base = "defib"
	/// Cooldown after charging a defib before it's chargable again
	var/charge_time = 10 SECONDS
	/// Is this defib emagged
	var/emagged = FALSE
	/// Is this defib makeshift
	var/makeshift = FALSE
	/// Type of power cell to be installed on spawn
	var/cell_type = /obj/item/ammo/power_cell/med_power
	/// How much cell charge does this cost
	var/cost = DEFIB_CHARGE_SMALL_CELL_COST

	New()
		. = ..()
		var/cell = new cell_type
		AddComponent(/datum/component/cell_holder, cell, swappable = FALSE)
		src.UpdateIcon()

	emag_act(var/mob/user)
		if (!src.emagged)
			if (user)
				user.show_text("You short out the on board medical scanner!", "blue")
			src.desc += " The screen only shows the word KILL flashing over and over."
			src.emagged = TRUE
			return 1
		else
			if (user)
				user.show_text("This has already been tampered with.", "red")
			return 0

	demag(var/mob/user)
		if (!src.emagged)
			return 0
		if (user)
			user.show_text("You repair the on board medical scanner.", "blue")
			src.desc = null
			src.desc = "Uses electrical currents to restart the hearts of critical patients."
		src.emagged = FALSE
		return 1

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		if (!isliving(target) || issilicon(target))
			return ..()
		if (src.defibrillate(target, user))
			JOB_XP(user, "Medical Doctor", 5)
			src.delStatus("defib_charged")
			if(istype(src.loc, /obj/machinery/atmospherics/unary/cryo_cell))
				var/obj/machinery/atmospherics/unary/cryo_cell/cryo = src.loc
				cryo.shock_icon()
			FLICK("[src.icon_base]-shock", src)

	attack_self(mob/user)
		if (src.hasStatus("defib_charged"))
			boutput(user, SPAN_NOTICE("[src] is already primed!"))
			return
		// don't try to use charge if it's on cooldown, but also don't set the recharging time if we fail to charge
		if(GET_COOLDOWN(src, "defib_cooldown"))
			boutput(user, SPAN_ALERT("[src] is still recharging!"))
			return
		if(!src.try_charge(user))
			return // user feedback done in `try_charge`
		ON_COOLDOWN(src, "defib_cooldown", src.charge_time)
		user.visible_message(SPAN_ALERT("[user] rubs the paddles of [src] together."), SPAN_NOTICE("You rub the paddles of [src] together."), SPAN_ALERT("You hear an electrical whine."))
		playsound(user.loc, 'sound/items/defib_charge.ogg', 90, 0)
		SETUP_GENERIC_ACTIONBAR(user, src, 0.2 SECONDS, PROC_REF(charge), user, src.icon, "[src.icon_base]-on", null, INTERRUPT_NONE)

	examine(mob/user)
		. = ..()
		if (istype_exact(src, /obj/item/robodefibrillator) || istype_exact(src, /obj/item/robodefibrillator/vr))
			var/list/ret = list()
			if (!(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST))
				. += SPAN_ALERT("No power cell installed.")
			else
				. += "There are [ret["charge"]]/[ret["max_charge"]] PUs left! Each use will consume [src.cost]PU."
		else
			. += "Each use of [src] will consume [src.cost]PU."

	update_icon(...)
		. = ..()
		var/list/counter_ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, counter_ret) & CELL_RETURNED_LIST)
			inventory_counter.update_percent(counter_ret["charge"], counter_ret["max_charge"])
		else
			inventory_counter.update_text("-")

	/// Attempt to charge the defib paddles, using power. Only call parent if you're using power_cell
	proc/try_charge(mob/user)
		if (!(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE) & CELL_SUFFICIENT_CHARGE))
			boutput(user, SPAN_ALERT("The internal cell doesn't have enough power to prime [src]!"))
			return FALSE
		var/ret = SEND_SIGNAL(src, COMSIG_CELL_USE, src.cost)
		if (ret & CELL_INSUFFICIENT_CHARGE)
			boutput(user, SPAN_ALERT("[src] is now out of charge."))
		src.UpdateIcon()
		return TRUE

	/// The charge status and fx on charge end
	proc/charge(mob/user)
		if(prob(1))
			user.say("CLEAR!")
		src.setStatus("defib_charged", 3 SECONDS)

	/// handle defib charge status and do fx
	proc/do_the_shocky_thing(mob/user as mob)
		if (!src.hasStatus("defib_charged"))
			user.show_text("[src] needs to be primed first!", "red")
			return 0
		playsound(src.loc, 'sound/impact_sounds/Energy_Hit_3.ogg', 75, 1, pitch = 0.92)
		src.delStatus("defib_charged")
		if(istype(src.loc, /obj/machinery/atmospherics/unary/cryo_cell))
			var/obj/machinery/atmospherics/unary/cryo_cell/cryo = src.loc
			cryo.shock_icon()
		FLICK("[src.icon_base]-shock", src)
		return 1

	proc/speak(var/message)	// lifted entirely from bot_parent.dm
		src.audible_message(SPAN_SAY("[SPAN_NAME("[src]")] beeps, \"[message]\""))

	custom_suicide = 1
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		if (src.defibrillate(user, user, suiciding=TRUE))
			SPAWN(50 SECONDS)
				if (user && !isdead(user))
					user.suiciding = 0
		else
			user.suiciding = 0
		return 1

/// the actual defib effect to the target patient
/obj/item/robodefibrillator/proc/defibrillate(mob/living/patient, mob/living/user, suiciding = FALSE)
	if (!isliving(patient))
		return 0

	var/shockcure = 0
	for (var/datum/ailment_data/V in patient.ailments)
		if (V.cure_flags & CURE_ELEC_SHOCK)
			shockcure = 1
			break

	if(!istype(src.loc, /obj/machinery/atmospherics/unary/cryo_cell))
		user.visible_message(SPAN_ALERT("<b>[user]</b> places the electrodes of [src] onto [user == patient ? "[his_or_her(user)] own" : "[patient]'s"] [suiciding ? "eyes" : "chest"]!"),\
		SPAN_ALERT("You place the electrodes of [src] onto [user == patient ? "your own" : "[patient]'s"] [suiciding ? "eyes" : "chest"]!"))

	if (src.emagged || src.makeshift || patient.health < 0 || shockcure || prob(25 + suiciding) || (suiciding && prob(44)))
		if (!do_the_shocky_thing(user))
			// shit done didnt work dangit
			return 0

		user.visible_message(SPAN_ALERT("<b>[user]</b> shocks [user == patient ? "[him_or_her(user)]self" : patient] with [src]!"),\
		SPAN_ALERT("You shock [user == patient ? "yourself" : patient] with [src]!"))
		logTheThing(LOG_COMBAT, patient, "was defibrillated by [constructTarget(user,"combat")] with [src] [log_loc(patient)]")


		if (patient.bioHolder.HasEffect("resist_electric"))
			patient.visible_message(SPAN_ALERT("<b>[patient]</b> doesn't respond at all!"),\
			SPAN_NOTICE("You resist the shock!"))
			speak("ERROR: Unable to complete circuit for shock delivery!")
			return 1

		else if (isdead(patient))
			patient.visible_message(SPAN_ALERT("<b>[patient]</b> doesn't respond at all!"))
			speak("ERROR: Patient is deceased.")
			patient.setStatus("defibbed", 1.5 SECONDS)
			return 1

		else
			if (patient.find_ailment_by_type(/datum/ailment/malady/flatline))
				if ((patient.hasStatus("defibbed") && prob(90)) || prob(75)) // it was a 100% chance before... probably
					patient.cure_disease_by_path(/datum/ailment/malady/flatline)
				if (!patient.find_ailment_by_type(/datum/ailment/malady/flatline))
					speak("Normal cardiac rhythm restored.")
				else
					speak("Lethal dysrhythmia detected. Patient is still in cardiac arrest!")

			patient.Virus_ShockCure(35)	// so it doesnt have a 100% chance to cure roboTF
			patient.setStatus("defibbed", user == patient ? 6 SECONDS : 12 SECONDS)

			if (ishuman(patient)) //remove later when we give nonhumans pathogen / organ response?
				var/mob/living/carbon/human/H = patient
				var/sumdamage = patient.get_brute_damage() + patient.get_burn_damage() + patient.get_toxin_damage()
				if (suiciding)
					; // do nothing
				else if (patient.health < 0)
					if (sumdamage >= 90)
						user.show_text("<b>[patient]</b> looks horribly injured. Resuscitation alone may not help revive them.", "red")
						speak("Patient has life-threatening injuries. Patient is unlikely to survive unless these wounds are treated.")
					if (prob(66))
						patient.visible_message(SPAN_NOTICE("<b>[patient]</b> inhales deeply!"))
						patient.take_oxygen_deprivation(-50)
						if (H.organHolder && H.organHolder.heart)
							H.get_organ("heart").heal_damage(10,10,10)
					else if (patient.hasStatus("defibbed")) // Always gonna get *something* if you keep shocking them
						patient.visible_message(SPAN_NOTICE("<b>[patient]</b> inhales sharply!"))
						patient.take_oxygen_deprivation(-10)
						if (H.organHolder && H.organHolder.heart)
							H.get_organ("heart").heal_damage(3,3,3)
					else
						patient.visible_message(SPAN_ALERT("<b>[patient]</b> doesn't respond!"))


			#ifdef USE_STAMINA_DISORIENT
			if (src.emagged || src.makeshift)
				patient.do_disorient(130, knockdown = 50, stunned = 50, unconscious = 40, disorient = 60, remove_stamina_below_zero = 0)
			else
				patient.changeStatus("unconscious", 5 SECONDS)
			#else
			patient.changeStatus("unconscious", 5 SECONDS)
			#endif
			patient.stuttering += 10

			patient.show_text("You feel a powerful jolt[suiciding ? " wrack your brain" : null]!", "red")
			patient.shock_cyberheart(100)
			patient.emote("twitch_v")
			if (suiciding)
				user.take_brain_damage(119)
				user.TakeDamage("head", 0, 99)

			if (src.emagged && prob(10))
				user.show_text("[src]'s on board scanner indicates that the target is undergoing a cardiac arrest!", "red")
				patient.contract_disease(/datum/ailment/malady/flatline, null, null, 1) // path, name, strain, bypass resist
			return 1

	else
		if (do_the_shocky_thing(user))
			user.visible_message(SPAN_ALERT("<b>[user]</b> shocks [user == patient ? "[him_or_her(user)]self" : patient] with [src]!"),\
			SPAN_ALERT("You shock [user == patient ? "yourself" : patient] with [src]!"))
			logTheThing(LOG_COMBAT, patient, "was defibrillated by [constructTarget(user,"combat")] with [src] when they didn't need it at [log_loc(patient)]")
			patient.changeStatus("knockdown", 0.1 SECONDS)
			patient.force_laydown_standup()
			patient.remove_stamina(45)
			if (isdead(patient) && !patient.bioHolder.HasEffect("resist_electric"))
				patient.setStatus("defibbed", 1.5 SECONDS)
		return 0

/obj/item/robodefibrillator/vr
	icon = 'icons/effects/VR.dmi'
	cell_type = /obj/item/ammo/power_cell/self_charging/mediumbig

TYPEINFO(/obj/item/robodefibrillator/makeshift)
	mats = null
/obj/item/robodefibrillator/makeshift
	name = "shoddy-looking makeshift defibrillator"
	desc = "It might restart your heart, I guess, or it might barbeque your insides."
	icon_state = "cell-on"
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	item_state = "cell"
	icon_base = "cell"
	cost = DEFIB_CHARGE_LARGE_CELL_COST
	makeshift = TRUE
	var/obj/item/cell/cell

	New(obj/item/cell/attached_cell)
		. = ..()
		src.RemoveComponentsOfType(/datum/component/cell_holder)
		src.inventory_counter.update_text("")
		if (istype(attached_cell))
			src.cell = attached_cell
		else
			src.cell = new /obj/item/cell/supercell/charged

	disposing()
		. = ..()
		if (src.cell)
			src.cell.set_loc(src.loc)
			src.cell = null

	emag_act(mob/user)
		if (user)
			user.show_text("You prod at [src], but it doesn't do anything.", "red")
		return 0

	try_charge(mob/user)
		if (src.cell?.charge < src.cost)
			boutput(user, SPAN_ALERT("There's not enough power in the attached cell to prime [src]!"))
			return FALSE
		src.cell.charge -= src.cost
		return TRUE

TYPEINFO(/obj/item/robodefibrillator/cyborg)
	mats = null
/obj/item/robodefibrillator/cyborg
	cost = DEFIB_CHARGE_LARGE_CELL_COST

	New()
		. = ..()
		RemoveComponentsOfType(/datum/component/cell_holder)
		src.inventory_counter.update_text("")

	try_charge(mob/user)
		var/mob/living/silicon/robot/robot = user
		if (!istype(robot) || isnull(robot.cell) || robot.cell.charge < src.cost)
			boutput(user, SPAN_ALERT("You don't have enough power to prime [src]!"))
			return FALSE
		robot.cell.charge -= src.cost
		return TRUE

TYPEINFO(/obj/item/robodefibrillator/mounted)
	mats = null
/obj/item/robodefibrillator/mounted
	var/obj/machinery/defib_mount/parent = null	//temp set while not attached
	w_class = W_CLASS_BULKY
	cost = DEFIB_CHARGE_LARGE_CELL_COST

	New()
		. = ..()
		RemoveComponentsOfType(/datum/component/cell_holder)
		src.inventory_counter.update_text("")

	try_charge(mob/user)
		if (!src.parent?.try_charge(user))
			boutput(user, SPAN_ALERT("There's no local power to prime [src]!"))
			return FALSE
		return TRUE

	disposing()
		parent?.defib = null
		parent = null
		..()

TYPEINFO(/obj/item/robodefibrillator/recharging)
	mats = null
/obj/item/robodefibrillator/recharging
	cell_type = /obj/item/ammo/power_cell/self_charging/mediumbig

TYPEINFO(/obj/machinery/defib_mount)
	mats = 25

/obj/machinery/defib_mount
	name = "mounted defibrillator"
	icon = 'icons/obj/compact_machines.dmi'
	desc = "Uses electrical currents to restart the hearts of critical patients."
	icon_state = "defib1"
	anchored = ANCHORED
	density = 0
	status = REQ_PHYSICAL_ACCESS
	/// defibrillator, when out of mount
	var/obj/item/robodefibrillator/mounted/defib = null

	New()
		..()
		if (!defib)
			src.defib = new /obj/item/robodefibrillator/mounted(src)
		RegisterSignal(src, COMSIG_CORD_RETRACT, PROC_REF(put_back_defib))

	emag_act()
		..()
		return defib?.emag_act()

	disposing()
		if (defib)
			qdel(defib)
			defib = null
		..()

	process()
		if(!QDELETED(src.defib))
			if (BOUNDS_DIST(src.defib, src) > 0)
				src.put_back_defib()
		else
			src.defib = null
		..()

	update_icon()
		if (defib && defib.loc == src)
			icon_state = "defib1"
		else
			icon_state = "defib0"

	attack_hand(mob/living/user)
		if (isAI(user) || isintangible(user) || isobserver(user) || !in_interact_range(src, user)) return
		user.lastattacked = get_weakref(src)
		..()
		if(!defib || QDELETED(defib))
			defib = null // ditch the ref, just in case we're QDEL'd but defib is still holding on
			return //maybe a bird ate it
		if(defib.loc != src)
			return //if someone else has it, don't put it in user's hand
		src.AddComponent(/datum/component/cord, src.defib, base_offset_x = 0, base_offset_y = -2)
		user.put_in_hand_or_drop(src.defib)
		src.defib.parent = src
		playsound(src, 'sound/items/pickup_defib.ogg', 65, vary=0.2)
		UpdateIcon()

	attackby(obj/item/W, mob/living/user)
		user.lastattacked = get_weakref(src)
		if (W == src.defib)
			src.put_back_defib()

	/// Attempt to charge the defib from the local area
	proc/try_charge(mob/user)
		var/area/A = get_area(src)
		if (!A.powered(EQUIP))
			boutput(user, SPAN_ALERT("There's no local power to prime [src.defib]!"))
			return FALSE
		src.use_power(src.defib.cost)
		return TRUE

	/// Put the defib back in the mount, by force if necessary.
	proc/put_back_defib()
		if (src.defib)
			src.RemoveComponentsOfType(/datum/component/cord)
			src.defib.force_drop(sever=TRUE)
			src.defib.set_loc(src)
			src.defib.parent = null
			src.ClearSpecificOverlays("cord_\ref[src]")
			playsound(src, 'sound/items/putback_defib.ogg', 65, vary=0.2)
			UpdateIcon()

#undef DEFIB_CHARGE_SMALL_CELL_COST
#undef DEFIB_CHARGE_LARGE_CELL_COST
