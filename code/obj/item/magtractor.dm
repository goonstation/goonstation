
TYPEINFO(/obj/item/magtractor)
	mats = 12

/obj/item/magtractor
	name = "magtractor"
	desc = "A device used to pick up and hold objects via the mysterious power of magnets."
	icon = 'icons/obj/items/items.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	icon_state = "magtractor"
	opacity = 0
	density = 0
	anchored = UNANCHORED
	flags = FPRINT | TABLEPASS| CONDUCT | EXTRADELAY
	force = 10
	throwforce = 10
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_NORMAL
	m_amt = 50000
	stamina_damage = 15
	stamina_cost = 15
	stamina_crit_chance = 5
	var/working = 0
	var/mob/holder //this is hacky way to get the user without looping through all mobs in process
	var/processHeld = 0
	var/highpower = 0 //high power mode (holding during movement)

	var/datum/action/holdAction

	New(mob/user)
		..()
		processing_items |= src
		if (user)
			src.holder = user
			src.verbs |= /obj/item/magtractor/proc/toggleHighPower

	process()
		//power usage here maybe??

		if ((!src.holding || src.holding.disposed) && src.holder && processHeld) //If the item has been consumed somehow
			actions.stopId("magpickerhold", src.holder)
			processHeld = 0
		return

	pickup(mob/user)
		..()
		src.holder = user
		src.verbs |= /obj/item/magtractor/proc/toggleHighPower
		src.set_mob(user)
		src.show_buttons()

	dropped(mob/user)
		..()
		src.holder = null
		src.verbs -= /obj/item/magtractor/proc/toggleHighPower

	attackby(obj/item/W, mob/user)
		if (!W) return 0

		if (BOUNDS_DIST(get_turf(src), get_turf(W)) > 0)
			out(user, "<span class='alert'>\The [W] is too far away!</span>")
			return 0

		if (src.holding)
			out(user, "<span class='alert'>\The [src] is already holding \the [src.holding]!</span>")
			return 0

		if (W.anchored || W.w_class >= W_CLASS_BULKY) //too bulky for backpacks, too bulky for this
			out(user, "<span class='notice'>\The [src] can't possibly hold that heavy an item!</span>")
			return 0

		if (istype(W, /obj/item/magtractor))
			var/turf/T = get_ranged_target_turf(user, turn(user.dir, 180), 7)
			playsound(user.loc, 'sound/impact_sounds/Metal_Hit_Heavy_1.ogg', 50, 1)
			user.visible_message("<span class='combat bold'>\The [src]'s magnets violently repel as they counter a similar magnetic field!</span>")
			user.throw_at(T, 7, 10)
			user.changeStatus("stunned", 2 SECONDS)
			return 0
		else
			actions.start(new/datum/action/bar/private/icon/magPicker(W, src), user)

		return 1

	attack_self(mob/user as mob)
		if (src.holding && !src.holding.disposed)
			//activate held item (if possible)
			src.holding.attack_self(user)
			src.updateHeldOverlay(src.holding) //for items that update icon on activation (e.g. welders)
		else
			return 0

	afterattack(atom/A, mob/user as mob)
		if (!A) return 0

		if (!src.holding)
			if (!isitem(A)) return 0
			if (BOUNDS_DIST(get_turf(src), get_turf(A)) > 0)
				out(user, "<span class='alert'>\The [A] is too far away!</span>")
				return 0
			var/obj/item/target = A

			if (target.anchored || target.w_class == W_CLASS_BULKY) //too bulky for backpacks, too bulky for this
				out(user, "<span class='notice'>\The [src] can't possibly hold that heavy an item!</span>")
				return 0

			if (istype(target, /obj/item/magtractor))
				return 0

			//pick up item
			actions.start(new/datum/action/bar/private/icon/magPicker(target, src), user)

		else if ((src.holding && src.holding.loc != src) || src.holding.disposed) // it's gone!!
			actions.stopId("magpickerhold", user)

		return 1

	throw_begin(atom/target)
		..()
		actions.stopId("magpicker", usr)
		if (src.holding)
			actions.stopId("magpickerhold", usr)

	dropped(mob/user as mob)
		..()
		actions.stopId("magpicker", user)
		if (src.holding)
			actions.stopId("magpickerhold", user)

	examine()
		. = ..()
		if (src.highpower)
			. += "<span class='notice'>The [src] has HPM enabled!</span>"
		if (src.holding)
			. += "<span class='notice'>\The [src.holding] is enveloped in the magnetic field.</span>"

	proc/releaseItem()
		set src in usr
		set name = "Release Item"
		set desc = "Release the item currently held by the magtractor"
		set category = "Local"

		if (!src || !src.holding || usr.stat || usr.getStatusDuration("stunned") || usr.getStatusDuration("weakened") || usr.getStatusDuration("paralysis")) return 0
		actions.stopId("magpickerhold", usr)
		return 1

	proc/toggleHighPower()
		set src in usr
		set name = "Toggle HPM (High Power Mode)"
		set desc = "Increases power driven to the magtractor, allowing it to carry items while moving."
		set category = "Local"

		if (!src || usr.stat || usr.getStatusDuration("stunned") || usr.getStatusDuration("weakened") || usr.getStatusDuration("paralysis")) return 0

		var/image/magField = GetOverlayImage("magField")
		var/msg = "<span class='notice'>You toggle the [src]'s HPM "
		if (src.highpower)
			if (src.holdAction) src.holdAction.interrupt_flags |= INTERRUPT_MOVE
			if (magField) magField.color = "#66ebe0" //blue
			src.highpower = 0
			msg += "off"
		else
			if (src.holdAction) src.holdAction.interrupt_flags &= ~INTERRUPT_MOVE
			if (magField) magField.color = "#FF4A4A" //red
			src.highpower = 1
			msg += "on"
		if (magField) src.UpdateOverlays(magField, "magField")
		out(usr, "[msg].</span>")
		return 1

	proc/updateHeldOverlay(obj/item/W as obj)
		if (W && !W.disposed)
			var/image/heldItem = GetOverlayImage("heldItem")
			if (!heldItem)
				heldItem = image(W.icon, W.icon_state)
				heldItem.transform *= 0.85
			heldItem.color = W.color
			heldItem.pixel_y = 1
			heldItem.layer = -1
			src.UpdateOverlays(heldItem, "heldItem")
		else
			src.UpdateOverlays(null, "heldItem")

	//Called by action_controls.dm, magPicker
	proc/pickupItem(obj/item/W as obj, mob/user as mob)
		if (!W || !user || !isitem(W) || !ismob(user) || src.holding) return 0

		src.working = 1
		user.set_pulling(null)

		var/atom/oldloc = W.loc
		W.set_loc(src)
		W.pickup(user)

		if (istype(oldloc, /obj/item/storage)) //For removing items from containers with the tractor
			var/obj/item/storage/S = oldloc
			S.hud.remove_item(W) // ugh
			W.layer = 3 //why is this necessary aaaaa!.

		src.holding = W
		src.processHeld = 1
		src.w_class = W_CLASS_BULKY //bulky
		src.useInnerItem = 1
		src.icon_state = "magtractor-active"

		src.UpdateOverlays(null, "magField")
		var/image/I = image('icons/obj/items/items.dmi', "magtractor-field")
		I.layer = -2

		if (src.highpower)
			I.color = "#FF4A4A" //red
		else
			I.color = "#66ebe0" //blue

		src.UpdateOverlays(I, "magField")
		src.updateHeldOverlay(W)

		playsound(src.loc, 'sound/machines/ping.ogg', 50, 1)

		for (var/obj/ability_button/magtractor_drop/abil in src)
			abil.icon_state = "mag_drop1"
		src.verbs |= /obj/item/magtractor/proc/releaseItem
		src.working = 0

		return 1

	//Called by action_controls.dm, magPickerHold
	proc/dropItem(var/setloc = 1)
		if (src.working) return 0

		src.holdAction = null
		src.verbs -= /obj/item/magtractor/proc/releaseItem

		if (isitem(src.holding) && usr)
			src.holding.dropped(usr)
		src.working = 1
		src.w_class = W_CLASS_NORMAL //normal
		src.useInnerItem = 0
		var/turf/T = get_turf(src)

		var/msg = "<span class='bold notice'>\The [src] deactivates its magnetic field"
		if (src.holding) //item still exists, dropping
			if (src.holding.loc == src && setloc)
				src.holding.set_loc(T)
				src.holding.layer = initial(src.holding.layer)
				msg += " and lets \the [src.holding] fall to the floor."
			else
				msg += "."
			src.holding = null
		else //item no longer exists (was used up)
			msg += " with nothing left to hold."
		msg += "</span>"
		T.visible_message(msg)

		for (var/obj/ability_button/magtractor_drop/abil in src)
			abil.icon_state = "mag_drop0"
		src.icon_state = "magtractor"
		src.UpdateOverlays(null, "magField")
		src.updateHeldOverlay()
		//TODO: playsound, de-power thing
		src.working = 0
		src.processHeld = 0

		return 1

	Exited(Obj, newloc) // handles the held item going byebye
		if(Obj == src.holding  && src.holder)
			actions.stopId("magpickerhold", src.holder)

/obj/item/magtractor/abilities = list(/obj/ability_button/magtractor_toggle, /obj/ability_button/magtractor_drop)
