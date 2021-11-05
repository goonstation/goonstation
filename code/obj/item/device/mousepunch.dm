// A gimmick trap for unsuspecting people
/obj/item/device/mousepunch
	name = "punching trap"
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "boxing_trap"
	item_state = "boxing_trap"
	desc = "A boxing glove shoddily tied to a mousetrap, eager to meet some clumsy assistant's face."
	w_class = W_CLASS_TINY
	force = 0
	throwforce = null
	var/armed = FALSE
	stamina_damage = 0
	stamina_cost = 0
	stamina_crit_chance = 5
	var/mob/armer = null
	event_handler_flags = USE_FLUID_ENTER

	armed
		icon_state = "boxing_trap_armed"
		armed = 1

	examine()
		. = ..()
		if (src.armed)
			. += "<span class='alert'>It looks like it's armed.</span>"

	attack_self(mob/user as mob)
		if (!src.armed)
			icon_state = "boxing_trap_armed"
			user.show_text("You arm the trap.", "blue")
			set_armer(user)
		else
			icon_state = "boxing_trap"
			if ((user.get_brain_damage() >= 60 || user.bioHolder.HasEffect("clumsy")) && prob(50))
				var/which_hand = "l_arm"
				if (!user.hand)
					which_hand = "r_arm"
				src.triggered(user, which_hand)
				JOB_XP(user, "Clown", 1)
				user.visible_message("<span class='alert'><B>[user] accidentally sets off the trap, knocking themselves out!</B></span>",\
				"<span class='alert'><B>You accidentally trigger the springloaded boxing glove!</B></span>")
				return
			user.show_text("You disarm the trap.", "blue")
			clear_armer()

		src.armed = !src.armed
		playsound(user.loc, "sound/weapons/handcuffs.ogg", 30, 1, -3)

	proc/clear_armer()
		UnregisterSignal(armer, COMSIG_PARENT_PRE_DISPOSING)
		armer = null

	proc/set_armer(mob/user)
		RegisterSignal(user, COMSIG_PARENT_PRE_DISPOSING, .proc/clear_armer)
		armer = user

	disposing()
		clear_armer()
		. = ..()

	attack_hand(mob/user as mob)
		if (src.armed)
			if ((user.get_brain_damage() >= 60 || user.bioHolder.HasEffect("clumsy")) && prob(50))
				var/which_hand = "l_arm"
				if (!user.hand)
					which_hand = "r_arm"
				src.triggered(user, which_hand)
				JOB_XP(user, "Clown", 1)
				user.visible_message("<span class='alert'><B>[user] accidentally sets off the trap, knocking themselves out!</B></span>",\
				"<span class='alert'><B>You accidentally trigger the springloaded boxing glove!</B></span>")
				return
		..()

	proc/triggered(mob/target as mob, var/type = "feet")
		if (!src || !src.armed)
			return

		if (target && ishuman(target))
			playsound(target.loc, "sound/impact_sounds/Generic_Punch_2.ogg", 50, 1)
			playsound(target.loc,"sound/misc/Boxingbell.ogg",30,1)
			var/mob/living/carbon/human/H = target

			H.changeStatus("stunned", 3 SECONDS)
			H.changeStatus("weakened", 3 SECONDS)
			H.force_laydown_standup()
			//SPAWN_DBG(0)
			var/turf/curr = get_turf(H)

			for(var/i=0, i<7, i++)
				curr = get_step(curr, turn(H.dir, 180))

			H.throw_unlimited = 1
			H.throw_at(curr, 8, 3)
			//..()

		src.icon_state = "boxing_trap"
		src.armed = FALSE

		clear_armer()
