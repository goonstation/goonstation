/obj/item/beartrap
	name = "beartrap"
	desc = "Caution: This device cannot distinguish bears from other humanoids."
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "bear_trap-close"
	item_state = "bear_trap"
	flags = FPRINT
	w_class = W_CLASS_SMALL
	force = 5
	throwforce = 5
	var/armed = FALSE
	stamina_damage = 0
	stamina_cost = 0
	stamina_crit_chance = 5

	armed
		icon_state = "bear_trap-open"
		armed = TRUE

	armed/hidden_a_bit
		layer = -1 // layers under doors

	examine()
		. = ..()
		if (src.armed)
			. += "<span class='alert'>It looks like it's armed.</span>"

	attack_hand(mob/M)
		if (src.armed)
			if ((M.get_brain_damage() >= 60 || M.bioHolder.HasEffect("clumsy")) && prob(30))
				src.triggered(M)
				JOB_XP(M, "Clown", 5)
				M.visible_message("<span class='alert'><B>[M] accidentally sets off the bear trap!</B></span>",\
				"<span class='alert'><B>You accidentally trigger the beartrap on your hand! Yowch!</B></span>")
				return
			M.visible_message("[M] starts disarming [src]...")
			var/datum/action/bar/icon/callback/action_bar = new /datum/action/bar/icon/callback(M, src, 3 SECONDS, /obj/item/beartrap/proc/disarm,\
			list(M), src.icon, src.icon_state, "[M] finishes disarming [src]")
			actions.start(action_bar, M)
		else
			..()

	attack_self(mob/M)
		if (!src.armed)
			M.show_text("You start to arm the beartrap...", "blue")
			var/datum/action/bar/icon/callback/action_bar = new /datum/action/bar/icon/callback(M, src, 2 SECONDS, /obj/item/beartrap/proc/arm,\
			list(M), src.icon, src.icon_state, "[M] finishes arming [src]")
			actions.start(action_bar, M)
		return

	Crossed(atom/movable/AM)
		if (src.armed &&  isliving(AM) && !(isintangible(AM) || isghostcritter(AM)))
			var/mob/living/M = AM
			src.triggered(M)
			M.visible_message("<span class='alert'><B>[M] steps on the bear trap!</B></span>",\
			"<span class='alert'><B>You step on the bear trap!</B></span>")
			..()

	proc/arm(mob/M)
		if (!src.armed)
			logTheThing(LOG_COMBAT, src, "armed a beartrap at [src.loc]")
			set_icon_state("bear_trap-open")
			M.drop_item(src)
			src.armed = TRUE
			src.anchored = ANCHORED
			playsound(src.loc, 'sound/weapons/handcuffs.ogg', 30, 1, -3)
		return

	proc/disarm(mob/M)
		if (src.armed)
			playsound(src.loc, 'sound/weapons/handcuffs.ogg', 30, 1, -3)
			set_icon_state("bear_trap-close")
			src.armed = FALSE
			src.anchored = UNANCHORED
		return

	proc/triggered(mob/target)
		if (!src || !src.armed || isghostcritter(target) || isintangible(target))
			return

		if (target && isliving(target))
			var/mob/living/M = target
			logTheThing(LOG_COMBAT, M, "stood on a [src] at [log_loc(src)].")
			if(istype(M, /mob/living/critter/bear))
				M.death()
			else
				M.changeStatus("stunned", 4 SECONDS)
				M.force_laydown_standup()
				random_brute_damage(M, 50, 0)
				take_bleeding_damage(M, null, 15, DAMAGE_CUT)
			M.UpdateDamageIcon()

		if (target)
			playsound(target.loc, 'sound/impact_sounds/Generic_Snap_1.ogg', 80, 1)
			set_icon_state("bear_trap-close")
			src.armed = FALSE
			src.anchored = UNANCHORED
			logTheThing(LOG_COMBAT, target, "triggers [src] at [log_loc(src)]")
		return
