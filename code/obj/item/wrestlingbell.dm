/obj/item/wrestlingbell/
	var/obj/machinery/wrestlingbell/parent = null	//temp set while not attached
	w_class = W_CLASS_BULKY

	disposing()
		parent?.hammer = null
		parent = null
		..()

/obj/item/tinyhammer/wrestling
	name = "tiny bell hammer"
	desc = "Notorious violent cousin of teeny tiny hammer."
	icon = 'icons/obj/wrestlingbell.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	icon_state = "bellhammer"
	item_state = "bellhammer"
	flags = TABLEPASS | CONDUCT
	w_class = W_CLASS_TINY
	force = 5
	throwforce = 5
	stamina_damage = 33
	stamina_cost = 18
	stamina_crit_chance = 10
	var/obj/machinery/wrestlingbell/parent

/obj/machinery/wrestlingbell // this is essentially a renamed mounted defib
	name = "Wrestling bell"
	desc = "A bell used to start or stop a round."
	anchored = ANCHORED
	object_flags = NO_GHOSTCRITTER
	density = 1
	var/cooldown = 10 SECONDS
	icon = 'icons/obj/wrestlingbell.dmi'
	icon_state = "wrestlingbell1"
	var/last_ring = 0
	/// tiny hammer when taken out
	var/obj/item/tinyhammer/wrestling/hammer = null

	New()
		..()
		if (!hammer)
			src.hammer = new /obj/item/tinyhammer/wrestling(src)
			src.hammer.parent = src
		RegisterSignal(src.hammer, COMSIG_MOVABLE_MOVED, PROC_REF(hammer_move))

	disposing()
		if (hammer)
			qdel(hammer)
			hammer = null
		..()

	process()
		if(!QDELETED(src.hammer))
			hammer_move()
		else
			src.hammer = null
		..()

	update_icon()
		if (hammer && hammer.loc == src)
			icon_state = "wrestlingbell1"
		else
			icon_state = "wrestlingbell0"

	attack_hand(mob/living/user)
		if (isAI(user) || isintangible(user) || isobserver(user) || !in_interact_range(src, user)) return
		user.lastattacked = get_weakref(src)
		..()
		if(hammer.loc != src)
			return //if someone else has it, don't put it in user's hand
		user.put_in_hand_or_drop(src.hammer)
		src.hammer.parent = src
		RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(hammer_move), TRUE)
		UpdateIcon()

	attackby(obj/item/W, mob/living/user)
		user.lastattacked = get_weakref(src)
		if (istype(W, /obj/item/tinyhammer/wrestling))
			if (user.a_intent != "harm")
				playsound(src.loc, 'sound/impact_sounds/Generic_Click_1.ogg', 50)
				src.put_back_hammer()
				return
			else if (!ON_COOLDOWN(src, "bell", 10 SECONDS))
				var/turf/floor = get_turf(src)
				for (var/mob/mob in floor.loc) // checks if anyone in the room's area has the status
					var/datum/statusEffect/wrestler/status = mob.hasStatus("wrestler")
					if (status)
						status.toggle_active()
				playsound(src.loc, 'sound/misc/Boxingbell.ogg', 50,1)

	/// snap back if too far away
	proc/hammer_move()
		if (src.hammer && src.hammer.loc != src)
			if (BOUNDS_DIST(src.hammer, src) > 0)
				src.put_back_hammer()

	proc/put_back_hammer()
		if (src.hammer)
			src.hammer.force_drop(sever=TRUE)
			src.hammer.set_loc(src)
			src.hammer.parent = null

			UpdateIcon()

/datum/statusEffect/wrestler // makes more sense for this to be in here than floors.dm. perhaps a better place exists still
	id = "wrestler"
	name = "Wrestling!"
	desc = "You're in the ring, break a leg!"
	icon_state = "wrestling0"
	unique = TRUE
	effect_quality = STATUS_QUALITY_NEUTRAL
	var/active = 0

	onAdd(optional)
		. = ..()
		RegisterSignal(owner, COMSIG_ATTACKHAND, PROC_REF(handsignal))
		RegisterSignal(owner, COMSIG_ATTACKBY, PROC_REF(itemsignal))

	onUpdate(timePassed)
		var/mob/M = null
		if(ismob(owner))
			M = owner
		else
			return ..(timePassed)
		if (M.health <= 0 | !istype(get_turf(M), /turf/simulated/floor/specialroom/gym))
			M.delStatus("wrestler")

	onRemove()
		. = ..()
		var/mob/M = null
		if(ismob(owner))
			M = owner
			UnregisterSignal(M, COMSIG_ATTACKHAND)
			UnregisterSignal(M, COMSIG_ATTACKBY)
			if (M.health <= 0 && src.active)
				SPAWN(0)
					playsound(M.loc, 'sound/misc/knockout_new.ogg', 50)
				playsound(M.loc, 'sound/misc/Boxingbell.ogg', 50,1)
				M.make_dizzy(140)
				M.UpdateOverlays(image('icons/mob/critter/overlays.dmi', "dizzy"), "dizzy")
				M.setStatus("resting", INFINITE_STATUS)
				SPAWN(10 SECONDS)
					M.UpdateOverlays(null, "dizzy")

	proc/handsignal(mob/attacker, mob/user) // wrapper procs, looks stinky?
		var/datum/statusEffect/wrestler/statusAttacked = attacker.hasStatus("wrestler")
		var/datum/statusEffect/wrestler/statusUser = user.hasStatus("wrestler")
		if (!statusAttacked.active && statusUser.active)
			src.toggle_active(owner)

	proc/itemsignal(obj/item, mob/attacker, mob/user)
		var/datum/statusEffect/wrestler/statusAttacked = attacker.hasStatus("wrestler")
		var/datum/statusEffect/wrestler/statusUser = user.hasStatus("wrestler")
		if (!statusAttacked.active && statusUser.active)
			src.toggle_active(owner)

	proc/toggle_active(mob/user)
		if (!src.active)
			src.active = 1
			src.name = "Wrestling!"
		else
			src.active = 0
			src.name = "Waiting to wrestle!"
		src.icon_state = "wrestling[src.active]"






