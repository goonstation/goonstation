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
		armed = 1

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

	attack_self(mob/M as mob)
		if (!src.armed)
			M.show_text("You start to arm the beartrap...", "blue")
			var/datum/action/bar/icon/callback/action_bar = new /datum/action/bar/icon/callback(M, src, 2 SECONDS, /obj/item/beartrap/proc/arm,\
			list(M), src.icon, src.icon_state, "[M] finishes arming [src]")
			actions.start(action_bar, M)
		return

	Crossed(atom/movable/AM as mob|obj)
		if ((ishuman(AM)) && (src.armed))
			var/mob/living/carbon/H = AM
			src.triggered(H)
			H.visible_message("<span class='alert'><B>[H] steps on the bear trap!</B></span>",\
			"<span class='alert'><B>You step on the bear trap!</B></span>")

		else if (istype(AM, /obj/critter/bear) && (src.armed))
			var/obj/critter/bear/M = AM
			playsound(src.loc, 'sound/impact_sounds/Generic_Snap_1.ogg', 80, 1)
			set_icon_state("bear_trap-close")
			src.armed = FALSE
			src.anchored = FALSE
			src.visible_message("<span class='alert'><b>[M] is caught in the trap!</b></span>")
			M.CritterDeath()
		..()
		return

	proc/arm(mob/M)
		if (!src.armed)
			logTheThing(LOG_COMBAT, src, "armed a beartrap at [src.loc]")
			set_icon_state("bear_trap-open")
			M.drop_item(src)
			src.armed = TRUE
			src.anchored = TRUE
			playsound(src.loc, 'sound/weapons/handcuffs.ogg', 30, 1, -3)
		return

	proc/disarm(mob/M)
		if (src.armed)
			playsound(src.loc, 'sound/weapons/handcuffs.ogg', 30, 1, -3)
			set_icon_state("bear_trap-close")
			src.armed = FALSE
			src.anchored = FALSE
		return

	proc/triggered(mob/target as mob)
		if (!src || !src.armed)
			return

		if (target && ishuman(target))
			var/mob/living/carbon/human/H = target
			logTheThing(LOG_COMBAT, H, "stood on a [src] at [log_loc(src)].")
			H.changeStatus("stunned", 4 SECONDS)
			H.force_laydown_standup()
			random_brute_damage(H, 50, 0)
			take_bleeding_damage(H, null, 15, DAMAGE_CUT)
			H.UpdateDamageIcon()

		if (target)
			playsound(target.loc, 'sound/impact_sounds/Generic_Snap_1.ogg', 80, 1)
			set_icon_state("bear_trap-close")
			src.armed = FALSE
			src.anchored = FALSE
			logTheThing(LOG_COMBAT, target, "triggers [src] at [log_loc(src)]")
		return
