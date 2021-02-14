/obj/item/beartrap
	name = "beartrap"
	desc = "Caution: This device cannot distinguish bears from other humanoids."
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "bear_trap-close"
	item_state = "bear_trap"
	w_class = 1
	force = null
	throwforce = null
	var/armed = 0
	stamina_damage = 0
	stamina_cost = 0
	stamina_crit_chance = 5
	event_handler_flags = USE_HASENTERED | USE_FLUID_ENTER

	armed
		icon_state = "bear_trap-open"
		armed = 1

	examine()
		. = ..()
		if (src.armed)
			. += "<span class='alert'>It looks like it's armed.</span>"

	attack_self(mob/user as mob)
		if (!src.armed)
			set_icon_state("bear_trap-open")
			user.show_text("You arm the beartrap.", "blue")
		else
			set_icon_state("bear_trap-close")
			if ((user.get_brain_damage() >= 60 || user.bioHolder.HasEffect("clumsy")) && prob(30))
				src.triggered(user)
				JOB_XP(user, "Clown", 1)
				user.visible_message("<span class='alert'><B>[user] accidentally sets off the bear trap, cutting off a finger!</B></span>",\
				"<span class='alert'><B>You accidentally trigger the beartrap on your hand! Yowch!</B></span>")
				return
			user.show_text("You disarm the bear trap.", "blue")

		src.armed = !src.armed
		playsound(user.loc, "sound/weapons/handcuffs.ogg", 30, 1, -3)
		return

	HasEntered(AM as mob|obj)
		if ((ishuman(AM)) && (src.armed))
			var/mob/living/carbon/H = AM
			src.triggered(H)
			H.visible_message("<span class='alert'><B>[H] steps on the bear trap!</B></span>",\
			"<span class='alert'><B>You step on the bear trap!</B></span>")

		else if (istype(AM, /obj/critter/bear) && (src.armed))
			var/obj/critter/bear/M = AM
			playsound(src.loc, "sound/impact_sounds/Generic_Snap_1.ogg", 80, 1)
			set_icon_state("bear_trap-close")
			src.armed = 0
			src.visible_message("<span class='alert'><b>[M] is caught in the trap!</b></span>")
			M.CritterDeath()
		..()
		return

	proc/triggered(mob/target as mob)
		if (!src || !src.armed)
			return

		if (target && ishuman(target))
			var/mob/living/carbon/human/H = target
			H.changeStatus("stunned", 4 SECONDS)
			random_brute_damage(H, 30, 0)
			take_bleeding_damage(H, null, 12, DAMAGE_CUT)
			H.UpdateDamageIcon()

		if (target)
			playsound(target.loc, "sound/impact_sounds/Generic_Snap_1.ogg", 80, 1)
			set_icon_state("bear_trap-close")
			src.armed = 0
			logTheThing("combat", target, null, "triggers [src] at [log_loc(src)]")
		return
