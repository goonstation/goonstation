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
	anchored = TRUE
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

	/// controls whether the weapon stand is hackable
	var/hackable = FALSE

	/// is the weapon stand emagged
	var/emagged = FALSE

	/// is the access panel open
	var/panelopen = FALSE

	/// our wire hacking component defintion
	var/static/datum/wireDefinition/wire_definition = new /datum/wireDefinition(
		effects=list(WIRE_INERT, WIRE_POWER_A, WIRE_GROUND, WIRE_ID_SCAN),
		colors=list("Puce", "Mauve", "Ochre", "Slate")
	)

	New()
		..()
		AddComponent(/datum/component/wireStatus, src.wire_definition)

		if(!recharges_contents)
			UnsubscribeProcess()

		SPAWN(1 SECOND)
			if (!ispath(src.contained_weapon))
				logTheThing(LOG_DEBUG, src, "has a non-path contained_weapon, \"[src.contained_weapon]\", and is being disposed of to prevent errors")
				qdel(src)
				return
			src.update()

	get_desc(dist)
		if (dist <= 1)
			. += "There's [(src.amount > 0) ? src.amount : "no" ] [src.contained_weapon_name][s_es(src.amount)] in [src]."

	attackby(obj/item/W, mob/user)
		if (isscrewingtool(W))
			if (!src.panelopen)
				src.overlays += image('icons/obj/vending.dmi', "grife-panel")
				src.panelopen = 1
			else
				src.overlays = null
				src.panelopen = 0
			boutput(user, "You [src.panelopen ? "open" : "close"] the maintenance panel.")
			src.updateUsrDialog()
			return

		if (src.amount >= src.max_amount)
			boutput(user, "You can't fit anything else in this rack.")
			return
		if (W.cant_drop == 1)
			var/mob/living/carbon/human/H = user
			H.sever_limb(H.hand == LEFT_HAND ? "l_arm" : "r_arm")
			boutput(user, "The [src]'s automated loader wirrs and rips off [H]'s arm!")
			return
		else
			if (istype(W, src.contained_weapon))
				user.drop_item()
				W.set_loc(src)
				src.amount ++
				boutput(user, "You place [W] into [src].")
				src.update()
			else return ..()

//no, this isnt even an item its not allowed. if you wanna move racks around, code an unscrew behavior or something
/*
	mouse_drop(mob/user as mob) // no I ain't even touchin this mess it can keep doin whatever it's doin
		// I finally came back and touched that mess because it was broke - Haine
		// When I was working on this in the 2016 release, some stuff was broken and I didn't know why. Then when I got coder, it'd already been fixed! Thanks Haine! ~Gannets
		if (user == usr && !user.restrained() && !user.stat && (user.contents.Find(src) || in_interact_range(src, user)))
			if (!user.put_in_hand(src))
				return ..()
*/

	proc/show_panel(mob/user)
		var/datum/component/wireStatus/status = src.LoadComponent(/datum/component/wireStatus) // TODO: excise this when TGUI
		var/pdat = "<B>[src.name] Maintenance Panel</B><hr>"
		for(var/i in 1 to length(status.cut_wires))
			pdat += "[wire_definition.wire_color[i]] wire: "
			if (status.cut_wires[i])
				pdat += "<a href='?src=\ref[src];cutwire=[i]'>Mend</a>"
			else
				pdat += "<a href='?src=\ref[src];cutwire=[i]'>Cut</a> "
				pdat += "<a href='?src=\ref[src];pulsewire=[i]'>Pulse</a> "
			pdat += "<br>"

		pdat += "<br>"
		// TODO: excise this when TGUI VVVVV gross
		pdat += "The yellow light is [HAS_FLAG(SEND_SIGNAL(src, COMSIG_WIRE_HACK_FLAGS), WIRE_POWER_A) ? "off" : "on"].<BR>"
		pdat += "The blue light is [HAS_FLAG(SEND_SIGNAL(src, COMSIG_WIRE_HACK_FLAGS), WIRE_GROUND) ? "flashing" : "on"].<BR>"
		pdat += "The white light is [HAS_FLAG(SEND_SIGNAL(src, COMSIG_WIRE_HACK_FLAGS), WIRE_ID_SCAN) ? "on" : "off"].<BR>"

		user.Browse(pdat, "window=rackpanel")
		onclose(user, "rackpanel")

	attack_hand(mob/user)
		if (hackable && (src.panelopen || isAI(user)))
			show_panel(user)

		if(!ishuman(user) || !isliving(user))
			return

		src.add_fingerprint(user)

		// no power
		if (HAS_FLAG(SEND_SIGNAL(src, COMSIG_WIRE_HACK_FLAGS), WIRE_POWER_A)) // no power
			boutput(user, "<span class='alert'>Without power, the locks can't disengage!</span>")
			return

		// ground cut
		if (HAS_FLAG(SEND_SIGNAL(src, COMSIG_WIRE_HACK_FLAGS), WIRE_GROUND))
			user.shock(src, 7500, user.hand == LEFT_HAND ? "l_arm" : "r_arm", 1, 0)

		// do we not have access (legit, emag, wires)
		if (!src.allowed(user) && !emagged && !HAS_FLAG(SEND_SIGNAL(src, COMSIG_WIRE_HACK_FLAGS), WIRE_ID_SCAN))
			boutput(user, "<span class='alert'>Access denied.</span>")
			return

		var/obj/item/myWeapon = locate(src.contained_weapon) in src
		if (myWeapon)
			if (src.amount >= 1)
				src.amount--
			user.put_in_hand_or_drop(myWeapon)
			boutput(user, "You take [myWeapon] out of [src].")
		else
			if (src.amount >= 1)
				src.amount--
				myWeapon = new src.contained_weapon(src.loc)
				user.put_in_hand_or_drop(myWeapon)
				boutput(user, "You take [myWeapon] out of [src].")
		src.update()
		myWeapon?.UpdateIcon() // let it be known that this used to be in a try-catch for some fucking reason
		if (src.amount <= 0) //prevents a runtime if it's empty
			return

	proc/update()
		src.icon_state = "[src.stand_type][src.amount]"
		return

	process() // Override the normal process proc with this:
		if(recharges_contents)
			for(var/obj/item/A in src) // For each item(A) in the rack(src) ...
				if(!istype(A, contained_weapon)) // Check if the item(A) is not(!) accepted in this kind of rack(contained_weapon) and then...
					continue // It's not accepted here! Vamoose! Skidaddle! Git outta here! (Move on without executing any further code in this proc.)
				SEND_SIGNAL(A, COMSIG_CELL_CHARGE, 10)

	Topic(href, href_list)
		if(BOUNDS_DIST(usr, src) > 0 && !issilicon(usr) && !isAI(usr))
			boutput(usr, "<span class='alert'>You need to be closer to the rack to do that!</span>")
			return

		if ((href_list["cutwire"]) && (src.panelopen || isAI(usr)))
			var/twire = text2num_safe(href_list["cutwire"])
			SEND_SIGNAL(src, COMSIG_WIRE_HACK_MOB_SNIP, twire, usr)
			src.updateUsrDialog()

		if ((href_list["pulsewire"]) && (src.panelopen || isAI(usr)))
			var/twire = text2num_safe(href_list["pulsewire"])
			SEND_SIGNAL(src, COMSIG_WIRE_HACK_MOB_PULSE, twire, usr)
			src.updateUsrDialog()

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		if (!src.emagged)
			if(user)
				boutput(user, "<span class='notice'>You disable the [src]'s cardlock!</span>")
			src.emagged = 1
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
	name = "taser recharger rack"
	desc = "A taser rack that can charge up to 3 taser guns. Handy!"
	icon_state = "taser_charge_rack"
	amount = 3
	max_amount = 3
	stand_type = "taser_charge_rack"
	recharges_contents = 1

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
	recharges_contents = 1

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
	hackable = TRUE

/obj/machinery/weapon_stand/rifle_rack
	name = "pulse rifle rack"
	desc = "A rack that charges up to 3 pulse rifles."
	icon_state = "pulserifle_rack"
	amount = 3
	max_amount = 3
	stand_type = "pulserifle_rack"
	contained_weapon = /obj/item/gun/energy/pulse_rifle
	contained_weapon_name = "pulse rifle"
	req_access = list(access_security)
	hackable = TRUE

/obj/machinery/weapon_stand/rifle_rack/recharger
	recharges_contents = 1
