/*
	Porting my dojo sword-rack, making it in to more general purpose weapon racks.
	So far: A 4 slot taser rack for sec equipment storage.

	Many thanks go to Haine for food_boxes which this is stolen from.
	SpyGuy for rewriting rechargers with many helpful comments.
	And Keelin for walking me through recharger racks.

	Please excuse the learner plate comments!

	To-Do:
	Wall-mounted shotgun racks
	A cool rack for the bartender's shotgun
*/

/obj/machinery/weapon_stand
	name = "weapon stand"
	desc = "A stand which can hold a weapon. This one is a little generic looking."
	icon = 'icons/obj/weapon_rack.dmi'
	icon_state = "swordstand1"
	anchored = ANCHORED
	density = TRUE
	object_flags = CAN_REPROGRAM_ACCESS | NO_GHOSTCRITTER

	/// used to generate iconstates
	var/stand_type = "katanastand"

	/// path to a weapon
	var/contained_weapon = /obj/item/swords_sheaths/katana

	/// name of contained weapons
	var/contained_weapon_name = "katana"

	/// do we reacharge our contents
	var/recharges_contents = FALSE

	/// how many weapons are we currently holding
	var/amount = 1

	/// what's the maximum number of weapons we can hold
	var/max_amount = 1

	/// controls whether the weapon stand has a wire panel
	var/has_wire_panel = FALSE

	/// is the weapon stand emagged
	var/emagged = FALSE

	/// Wire hacking component defintion
	var/static/datum/wirePanel/panelDefintion/panel_def = new /datum/wirePanel/panelDefintion/weapon_stand

/obj/machinery/weapon_stand/New()
	..()
	if (has_wire_panel)
		src.flags |= TGUI_INTERACTIVE
		AddComponent(/datum/component/wirePanel, src.panel_def)
		RegisterSignal(src, COMSIG_WPANEL_SET_COVER, PROC_REF(set_cover))
		RegisterSignal(src, COMSIG_WPANEL_MOB_WIRE_ACT, PROC_REF(mob_wire_act))

	if(!recharges_contents)
		UnsubscribeProcess()

	SPAWN(1 SECOND)
		if (!ispath(src.contained_weapon))
			logTheThing(LOG_DEBUG, src, "has a non-path contained_weapon, \"[src.contained_weapon]\", and is being disposed of to prevent errors")
			qdel(src)
			return
		src.update()

/obj/machinery/weapon_stand/get_desc(dist)
	if (dist <= 1)
		. += "There's [(src.amount > 0) ? src.amount : "no" ] [src.contained_weapon_name][s_es(src.amount)] in [src]."

/obj/machinery/weapon_stand/attackby(obj/item/W, mob/user)
	if (!istype(W, src.contained_weapon))
		return ..()
	if (src.amount >= src.max_amount)
		boutput(user, "You can't fit anything else in this rack.")
		return
	if (W.cant_drop)
		var/mob/living/carbon/human/H = user
		H.sever_limb(H.hand == LEFT_HAND ? "l_arm" : "r_arm")
		boutput(user, "The [src]'s automated loader wirrs and rips off [H]'s arm!")
		return
	user.drop_item()
	W.set_loc(src)
	src.amount++
	boutput(user, "You place [W] into [src].")
	src.update()

/obj/machinery/weapon_stand/proc/set_cover(obj/parent, mob/user, status)
	src.check_shock(user)
	switch(status)
		if(WPANEL_COVER_OPEN)
			src.overlays += image('icons/obj/weapon_rack.dmi', "rack-panel")
			parent.ui_interact(user)
			tgui_process.update_uis(parent)
		if(WPANEL_COVER_CLOSED)
			src.overlays = null
			// the only TGUI for this object is wire panels, so close if the cover closes
			for(var/datum/tgui/ui in tgui_process.get_uis(parent))
				if(!parent.can_access_remotely(ui.user))
					tgui_process.close_user_uis(ui.user, parent)

/obj/machinery/weapon_stand/proc/mob_wire_act(obj/parent, mob/user, wire, action)
	src.check_shock(user)

/obj/machinery/weapon_stand/ui_interact(mob/user, datum/tgui/ui)
	if (src.has_wire_panel)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "WirePanelWindow", src.name)
			ui.open()


/obj/machinery/weapon_stand/proc/check_shock(mob/user)
	var/hacked_controls = SEND_SIGNAL(src, COMSIG_WPANEL_HACKED_CONTROLS)
	if (HAS_FLAG(hacked_controls, WIRE_CONTROL_GROUND))
		user.shock(src, 7500, user.hand == LEFT_HAND ? "l_arm" : "r_arm", 1, 0)

/obj/machinery/weapon_stand/attack_hand(mob/user)
	if(!ishuman(user) || !isliving(user))
		return

	var/bypass_access = FALSE
	src.add_fingerprint(user)

	if (src.has_wire_panel)
		var/hacked_controls = SEND_SIGNAL(src, COMSIG_WPANEL_HACKED_CONTROLS)
		if (hacked_controls && HAS_FLAG(hacked_controls, WIRE_CONTROL_POWER_A))
			boutput(user, "<span class='alert'>Without power, the locks can't disengage!</span>")
			return

		check_shock(user)

		if (HAS_FLAG(hacked_controls, WIRE_CONTROL_ACCESS))
			bypass_access = TRUE

	// check access: authorized, emagged, or the access control is broken)
	if (!src.allowed(user) && !src.emagged && !bypass_access)
		boutput(user, "<span class='alert'>Access denied.</span>")
		return

	var/obj/item/myWeapon = locate(src.contained_weapon) in src
	if (myWeapon)
		if (src.amount >= 1)
			src.amount--
		user.put_in_hand_or_drop(myWeapon)
		boutput(user, "You take [myWeapon] out of [src].")
		logTheThing(LOG_STATION, user, "takes [myWeapon] from the [src] [log_loc(src)].")
	else
		if (src.amount >= 1)
			src.amount--
			myWeapon = new src.contained_weapon(src.loc)
			user.put_in_hand_or_drop(myWeapon)
			boutput(user, "You take [myWeapon] out of [src].")
			logTheThing(LOG_STATION, user, "takes [myWeapon] from the [src] [log_loc(src)].")
	src.update()
	myWeapon?.UpdateIcon() // let it be known that this used to be in a try-catch for some fucking reason
	if (src.amount <= 0) //prevents a runtime if it's empty
		return

/obj/machinery/weapon_stand/proc/update()
	src.icon_state = "[src.stand_type][src.amount]"

/obj/machinery/weapon_stand/proc/valid_item(obj/item/I)
	return istype(I, contained_weapon)

/obj/machinery/weapon_stand/process() // Override the normal process proc with this:
	if(recharges_contents)
		for(var/obj/item/A in src) // For each item(A) in the rack(src) ...
			if(!istype(A, contained_weapon)) // Check if the item(A) is not(!) accepted in this kind of rack(contained_weapon) and then...
				continue // It's not accepted here! Vamoose! Skidaddle! Git outta here! (Move on without executing any further code in this proc.)
			SEND_SIGNAL(A, COMSIG_CELL_CHARGE, 10)

/obj/machinery/weapon_stand/emag_act(var/mob/user, var/obj/item/card/emag/E)
	if (!src.emagged)
		if(user)
			boutput(user, "<span class='notice'>You disable the [src]'s cardlock!</span>")
		src.emagged = TRUE
		src.updateUsrDialog()
		return 1
	else
		if(user)
			boutput(user, "The [src] is already unlocked!")
		return 0

//MELEE WEAPONS//

/obj/machinery/weapon_stand/katana_stand
	name = "katana stand"
	desc = "A wooden stand for holding a katana in it's sheath."
/*
	csaber_stand
		name = "cyalume saber stand"
		desc = "A stand that can hold a cyalume saber."
		icon_state = "swordstand1"
		stand_type = "csaberstand"
		contained_weapon = /obj/item/sword
		contained_weapon_name = "cyalume saber"
*/

//RANGED WEAPONS//

/obj/machinery/weapon_stand/taser_rack
	name = "taser rack"
	desc = "A storage rack that fits 4 taser guns. Efficient!"
	icon_state = "taser_rack"
	amount = 4
	max_amount = 4
	stand_type = "taser_rack"
	contained_weapon = /obj/item/gun/energy/taser_gun
	contained_weapon_name = "taser gun"
	req_access = list(access_security)

/obj/machinery/weapon_stand/taser_rack/recharger
	name = "security weapon recharger rack"
	desc = "A taser rack that can charge up to 3 security weapons. Handy!"
	icon_state = "taser_charge_rack"
	amount = 3
	max_amount = 3
	stand_type = "taser_charge_rack"
	contained_weapon_name = "security weapon"
	recharges_contents = TRUE

	valid_item(obj/item/I)
		return(istype(I, /obj/item/gun/energy/taser_gun) ||\
		istype(I, /obj/item/gun/energy/tasershotgun) ||\
		istype(I, /obj/item/gun/energy/tasersmg) ||\
		istype(I, /obj/item/gun/energy/wavegun)
		)

	empty
		icon_state = "taser_rack0"
		amount = 0

/obj/machinery/weapon_stand/egun_rack
	name = "energy gun rack"
	desc = "A storage rack that fits 4 energy guns. Tidy!"
	amount = 4
	max_amount = 4
	icon_state = "egun_rack"
	stand_type = "egun_rack"
	contained_weapon = /obj/item/gun/energy/egun
	contained_weapon_name = "energy gun"
	req_access = list(access_security)

/obj/machinery/weapon_stand/egun_rack/recharger
	name = "energy gun recharger rack"
	desc = "An energy gun rack that will recharge 3 energy guns."
	icon_state = "egun_charge_rack"
	amount = 3
	max_amount = 3
	stand_type = "egun_charge_rack"
	recharges_contents = TRUE

/obj/machinery/weapon_stand/shotgun_rack
	name = "shotgun rack"
	desc = "A rack for holding 3 shotguns."
	icon_state = "shotgun_rack"
	amount = 3
	max_amount = 3
	stand_type = "shotgun_rack"
	contained_weapon = /obj/item/gun/kinetic/riotgun
	contained_weapon_name = "riot shotgun"
	req_access = list(access_security)
	has_wire_panel = TRUE

/obj/machinery/weapon_stand/rifle_rack
	name = "pulse rifle rack"
	desc = "A rack that holds up to 3 pulse rifles."
	icon_state = "pulserifle_rack"
	amount = 3
	max_amount = 3
	stand_type = "pulserifle_rack"
	contained_weapon = /obj/item/gun/energy/pulse_rifle
	contained_weapon_name = "pulse rifle"
	req_access = list(access_security)
	has_wire_panel = TRUE

/obj/machinery/weapon_stand/rifle_rack/recharger
	desc = "A rack that recharges up to 3 pulse rifles."
	recharges_contents = TRUE

/datum/wirePanel/panelDefintion/weapon_stand
	wire_definition = list(
		list("puce", WIRE_CONTROL_ACCESS, WIRE_ACT_CUT_PULSE, WIRE_ACT_MEND_PULSE),
		list("mauve", WIRE_CONTROL_GROUND, WIRE_ACT_CUT_PULSE, WIRE_ACT_MEND_PULSE),
		list("ochre", WIRE_CONTROL_POWER, WIRE_ACT_CUT_PULSE, WIRE_ACT_MEND_PULSE),
		list("slate", WIRE_CONTROL_INERT, WIRE_ACT_CUT_PULSE, WIRE_ACT_MEND_PULSE)
	)

