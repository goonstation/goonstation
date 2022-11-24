/obj/item/barrier
	name = "barrier"
	desc = "A personal barrier. Activate this item inhand to deploy it."
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "barrier_0"
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	item_state = "barrier0"
	uses_multiple_icon_states = 1
	flags = FPRINT | ONBELT | TABLEPASS
	c_flags = EQUIPPED_WHILE_HELD
	force = 2
	throwforce = 6
	w_class = W_CLASS_SMALL
	mats = 8
	stamina_damage = 20
	var/stamina_damage_active = 40
	stamina_cost = 10
	var/stamina_cost_active = 25
	stamina_crit_chance = 0
	hitsound = 0

	can_disarm = 0
	two_handed = 0

	/// Potentially could be used for subtypes; set it to 1 so that the object occupies two hands when activated.
	var/use_two_handed = 0

	var/status = 0
	var/obj/itemspecialeffect/barrier/E = 0

	New()
		..()
		BLOCK_SETUP(BLOCK_ALL)
		c_flags &= ~BLOCK_TOOLTIP

	block_prop_setup(source, obj/item/grab/block/B)
		if(src.status)
			B.setProperty("rangedprot", 0.5)
			B.setProperty("exploprot", 10)
			. = ..()

	update_icon()
		icon_state = status ? "barrier_1" : "barrier_0"
		item_state = status ? "barrier1" : "barrier0"

	attack_self(mob/user as mob)
		src.add_fingerprint(user)

		if (!use_two_handed || setTwoHanded(!src.status))
			src.status = !src.status

			playsound(src, "sparks", 75, 1, -1)
			if (src.status)
				w_class = W_CLASS_BULKY
				flags &= ~ONBELT //haha NO
				setProperty("meleeprot_all", 9)
				setProperty("rangedprot", 1.5)
				setProperty("movespeed", 0.3)
				setProperty("disorient_resist", 65)
				setProperty("disorient_resist_eye", 65)
				setProperty("disorient_resist_ear", 50) //idk how lol ok
				stamina_damage = stamina_damage_active
				stamina_cost = stamina_cost_active
				setProperty("deflection", 20)
				flick("barrier_a",src)
				c_flags |= BLOCK_TOOLTIP

				src.setItemSpecial(/datum/item_special/barrier)
			else
				w_class = W_CLASS_SMALL
				flags |= ONBELT
				delProperty("meleeprot_all", 0)
				delProperty("rangedprot", 0)
				delProperty("movespeed", 0)
				delProperty("disorient_resist", 0)
				delProperty("disorient_resist_eye", 0)
				delProperty("disorient_resist_ear", 0)
				setProperty("deflection", 0)
				c_flags &= ~BLOCK_TOOLTIP
				stamina_damage = initial(stamina_damage)
				stamina_cost = initial(stamina_cost)

				src.setItemSpecial(/datum/item_special/simple)

			user.update_equipped_modifiers() // Call the bruteforce movement modifier proc because we changed movespeed while equipped

			destroy_deployed_barrier(user)

			can_disarm = src.status

			src.UpdateIcon()
			user.update_inhands()
		else
			user.show_text("You need two free hands in order to activate the [src.name].", "red")

		..()

	attack(mob/M, mob/user)
		..()
		playsound(src, 'sound/impact_sounds/Energy_Hit_1.ogg', 30, 0.1, 0, 2)

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
	w_class = W_CLASS_SMALL
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
		BLOCK_SETUP(BLOCK_ALL)
