TYPEINFO(/obj/item/barrier)
	mats = 8

/obj/item/barrier
	name = "barrier"
	desc = "ABSTRACT BARRIER VERSION. REPORT TO 1300 IM CODER."
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "barrier_1"
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	item_state = "barrier1"
	c_flags = EQUIPPED_WHILE_HELD | ONBELT
	force = 2
	throwforce = 6
	w_class = W_CLASS_SMALL
	stamina_damage = 20
	var/stamina_damage_active = 40
	stamina_cost = 10
	var/stamina_cost_active = 25
	stamina_crit_chance = 0
	hitsound = 0
	var/toggleable = 0

	can_disarm = 0
	two_handed = 0

	/// Potentially could be used for subtypes; set it to 1 so that the object occupies two hands when activated.
	var/use_two_handed = 0

	var/status = 0
	var/obj/itemspecialeffect/barrier/E = null

	New()
		..()
		BLOCK_SETUP(BLOCK_ALL)
		c_flags &= ~BLOCK_TOOLTIP

	block_prop_setup(source, obj/item/grab/block/B)
		if(src.status || !toggleable)
			B.setProperty("rangedprot", 0.5)
			B.setProperty("exploprot", 10)
			. = ..()

	attack_self(mob/user as mob)
		src.add_fingerprint(user)
		..()

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		..()
		playsound(src, 'sound/impact_sounds/Energy_Hit_1.ogg', 30, 0.1, 0, 2)

	dropped(mob/M)
		..()
		destroy_deployed_barrier(M)

	emp_act(mob/M)
		. = ..()
		destroy_deployed_barrier(M)

	proc/destroy_deployed_barrier(var/mob/living/M)
		src.E?.deactivate(M)
		src.E = null

/obj/item/barrier/collapsible
	desc = "Abstract type for collapsible barriers. Report to imcoder."
	icon_state = "barrier_0"
	item_state = "barrier0"
	toggleable = 1
	update_icon()
		icon_state = status ? "barrier_1" : "barrier_0"
		item_state = status ? "barrier1" : "barrier0"

	attack_self(mob/user as mob)
		src.toggle(user)
		..()

	emp_act()
		..()
		if(src.status)
			src.toggle(null, FALSE)
			src.visible_message("[src] sparks briefly as it overloads!")

	proc/toggle(mob/user, new_state = null)
		if(!user && ismob(src.loc))
			user = src.loc

		if(isnull(new_state))
			new_state = !status

		if (!use_two_handed || setTwoHanded(!src.status))
			playsound(src, "sparks", 75, 1, -1)
			src.status = new_state
			if (new_state)
				w_class = W_CLASS_BULKY
				c_flags &= ~ONBELT //haha NO
				setProperty("meleeprot_all", 9)
				setProperty("rangedprot", 1.5)
				setProperty("movespeed", 0.3)
				setProperty("disorient_resist", 65)
				setProperty("disorient_resist_eye", 65)
				setProperty("disorient_resist_ear", 50) //idk how lol ok
				stamina_damage = stamina_damage_active
				stamina_cost = stamina_cost_active
				setProperty("deflection", 20)
				FLICK("barrier_a",src)
				c_flags |= BLOCK_TOOLTIP
				src.setItemSpecial(/datum/item_special/barrier)
			else
				w_class = W_CLASS_SMALL
				c_flags |= ONBELT
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

			user?.update_equipped_modifiers() // Call the bruteforce movement modifier proc because we changed movespeed while equipped

			destroy_deployed_barrier(user)

			can_disarm = src.status

			src.UpdateIcon()
			user?.update_inhands()
		else
			user?.show_text("You need two free hands in order to activate the [src.name].", "red")

/obj/item/barrier/collapsible/security
	desc = "A personal barrier. Activate this item inhand to deploy it."

/obj/item/barrier/void
	name = "Scale Shield"
	desc = "A crude and unwieldy shield made from a eldritch scale. It appears to be able to both reflect and amplify projectiles."
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "void_barrier"
	item_state = "void_barrier"
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	wear_image_icon = 'icons/mob/clothing/back.dmi'
	c_flags = EQUIPPED_WHILE_HELD
	force = 8
	throwforce = 6
	w_class = W_CLASS_BULKY
	stamina_damage = 50
	stamina_cost = 35
	stamina_crit_chance = 0
	hitsound = 'sound/effects/exlow.ogg'

	can_disarm = 0
	two_handed = 1

	setupProperties()
		..()
		setProperty("meleeprot_all", 11)
		setProperty("rangedprot", 3)
		setProperty("movespeed", 0.8)
		setProperty("disorient_resist", 75)
		setProperty("disorient_resist_eye", 45)
		setProperty("disorient_resist_ear", 35) //idk how lol ok
		setProperty("deflection", 25)
		c_flags |= BLOCK_TOOLTIP && ONBACK

		src.setItemSpecial(/datum/item_special/barrier/void)
		BLOCK_SETUP(BLOCK_ALL)

/obj/item/barrier/syndicate
	name = "Aegis Riot Barrier"
	desc = "A personal barrier."
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "syndie_barrier"
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	item_state = "syndie_barrier"
	c_flags = EQUIPPED_WHILE_HELD | ONBELT
	force = 2
	throwforce = 6
	w_class = W_CLASS_NORMAL
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

		src.setItemSpecial(/datum/item_special/barrier/syndie)
		BLOCK_SETUP(BLOCK_ALL)
