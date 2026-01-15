ABSTRACT_TYPE(/obj/item/parts/robot_parts/leg)
/obj/item/parts/robot_parts/leg
	name = "placeholder item (don't use this!)"
	desc = "A metal leg for a cyborg. It won't be able to move very well without this!"
	icon_state_base = "legs" // effectively the prefix for items that go on both legs at once.
	material_amt = ROBOT_LIMB_COST
	max_health = 60
	var/step_sound = "step_robo"
	var/step_priority = STEP_PRIORITY_LOW

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		if(!ismob(target))
			return

		src.add_fingerprint(user)

		if(!(user.zone_sel.selecting in list("l_leg","r_leg")) || !ishuman(target))
			return ..()

		if (!surgeryCheck(target,user))
			return ..()

		var/mob/living/carbon/human/H = target

		if(H.limbs.get_limb(user.zone_sel.selecting))
			boutput(user, SPAN_ALERT("[H.name] already has one of those!"))
			return

		if(src.appearanceString == "sturdy" || src.appearanceString == "heavy" || src.appearanceString == "thruster")
			boutput(user, SPAN_ALERT("That leg is too big to fit on [H]'s body!"))
			return

		attach(H,user)

		return

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/skull))
			var/obj/item/skull/Skull = W
			var/obj/machinery/bot/skullbot/B

			if (Skull.icon_state == "skull_omnitraitor" || istype(Skull, /obj/item/skull/omnitraitor))
				B = new /obj/machinery/bot/skullbot/omnitraitor(get_turf(user))

			else if (Skull.icon_state == "skull_hunter" || istype(Skull, /obj/item/skull/hunter))
				B = new /obj/machinery/bot/skullbot/hunter(get_turf(user))

			else if (Skull.icon_state == "skull_wizard" || istype(Skull, /obj/item/skull/wizard))
				B = new /obj/machinery/bot/skullbot/wizard(get_turf(user))

			else if (Skull.icon_state == "skull_changeling" || istype(Skull, /obj/item/skull/changeling))
				B = new /obj/machinery/bot/skullbot/changeling(get_turf(user))

			else if (Skull.icon_state == "skull_cluwne" || istype(Skull, /obj/item/skull/cluwne))
				B = new /obj/machinery/bot/skullbot/cluwne(get_turf(user))

			else if (Skull.icon_state == "skull_macho" || istype(Skull, /obj/item/skull/macho))
				B = new /obj/machinery/bot/skullbot/macho(get_turf(user))

			else
				B = new /obj/machinery/bot/skullbot(get_turf(user))

			if (Skull.donor)
				B.name = "[Skull.donor.real_name] skullbot"

			user.show_text("You add [W] to [src]. That's neat.", "blue")
			qdel(W)
			qdel(src)
			return

		else if (istype(W, /obj/item/soulskull))
			new /obj/machinery/bot/skullbot/ominous(get_turf(user))
			boutput(user, SPAN_NOTICE("You add [W] to [src]. That's neat."))
			qdel(W)
			qdel(src)
			return

		else
			return ..()

	on_holder_examine()
		if (!isrobot(src.holder)) // probably a human, probably  :p
			return "has [bicon(src)] \an [initial(src.name)] attached as a"
		return

ABSTRACT_TYPE(/obj/item/parts/robot_parts/leg/left)
/obj/item/parts/robot_parts/leg/left
	name = "cyborg left leg"
	slot = "l_leg"
	step_image_state = "footprintsL"
	icon_state_base = "l_leg"
	icon_state = "l_leg-generic"
	partlistPart = "legL-generic"
	movement_modifier = /datum/movement_modifier/robotleg_left

/obj/item/parts/robot_parts/leg/left/standard
	name = "standard cyborg left leg"
	max_health = 115

/obj/item/parts/robot_parts/leg/left/light
	name = "light cyborg left leg"
	appearanceString = "light"
	icon_state = "l_leg-light"
	partlistPart = "legL-light"
	material_amt = ROBOT_LIMB_COST * ROBOT_LIGHT_COST_MOD
	max_health = 25
	movement_modifier = null
	robot_movement_modifier = /datum/movement_modifier/robot_part/light_leg_left
	kind_of_limb = (LIMB_ROBOT | LIMB_LIGHT)
	breaks_cuffs = FALSE

/obj/item/parts/robot_parts/leg/left/treads
	name = "left cyborg tread"
	desc = "A large wheeled unit like tank tracks. This will help heavier cyborgs to move quickly."
	appearanceString = "treads"
	icon_state = "l_leg-treads"
	handlistPart = "legL-treads" // THIS ONE gets to layer with the hands because it looks ugly if jumpsuits are over it. Will fix codewise later
	material_amt = ROBOT_TREAD_METAL_COST
	powerdrain = 2.5
	step_image_state = "tracksL"
	movement_modifier = /datum/movement_modifier/robottread_left
	robot_movement_modifier = /datum/movement_modifier/robot_part/tread_left
	kind_of_limb = (LIMB_ROBOT | LIMB_TREADS)

ABSTRACT_TYPE(/obj/item/parts/robot_parts/leg/right)
/obj/item/parts/robot_parts/leg/right
	name = "cyborg right leg"
	slot = "r_leg"
	step_image_state = "footprintsR"
	icon_state_base = "r_leg"
	icon_state = "r_leg-generic"
	partlistPart = "legR-generic"
	movement_modifier = /datum/movement_modifier/robotleg_right

/obj/item/parts/robot_parts/leg/right/standard
	name = "standard cyborg right leg"
	max_health = 115

/obj/item/parts/robot_parts/leg/right/light
	name = "light cyborg right leg"
	appearanceString = "light"
	icon_state = "r_leg-light"
	partlistPart = "legR-light"
	material_amt = ROBOT_LIMB_COST * ROBOT_LIGHT_COST_MOD
	max_health = 25
	movement_modifier = null
	robot_movement_modifier = /datum/movement_modifier/robot_part/light_leg_right
	kind_of_limb = (LIMB_ROBOT | LIMB_LIGHT)
	breaks_cuffs = FALSE

/obj/item/parts/robot_parts/leg/right/treads
	name = "right cyborg tread"
	desc = "A large wheeled unit like tank tracks. This will help heavier cyborgs to move quickly."
	appearanceString = "treads"
	icon_state = "r_leg-treads"
	handlistPart = "legR-treads"  // THIS ONE gets to layer with the hands because it looks ugly if jumpsuits are over it. Will fix codewise later
	material_amt = ROBOT_TREAD_METAL_COST
	powerdrain = 2.5
	step_image_state = "tracksR"
	movement_modifier = /datum/movement_modifier/robottread_right
	robot_movement_modifier = /datum/movement_modifier/robot_part/tread_right
	kind_of_limb = (LIMB_ROBOT | LIMB_TREADS)

/obj/item/parts/robot_parts/leg/left/thruster
	name = "left thruster assembly"
	desc = "Is it really a good idea to give thrusters to cyborgs..? Probably not."
	appearanceString = "thruster"
	icon_state = "l_leg-thruster"
	material_amt = ROBOT_THRUSTER_COST
	max_health = 100
	powerdrain = 5
	step_image_state = null //It's flying so no need for this.
	robot_movement_modifier = /datum/movement_modifier/robot_part/thruster_left
	kind_of_limb = (LIMB_ROBOT | LIMB_TREADS | LIMB_LIGHT)

	on_life()
		var/turf/T = get_turf(src.holder)
		if(src.holder && (src.holder.loc == T))
			T?.hotspot_expose(700, 50)

/obj/item/parts/robot_parts/leg/right/thruster
	name = "right thruster assembly"
	desc = "Is it really a good idea to give thrusters to cyborgs..? Probably not."
	appearanceString = "thruster"
	icon_state = "r_leg-thruster"
	material_amt = ROBOT_THRUSTER_COST
	max_health = 100
	powerdrain = 5
	step_image_state = null //It's flying so no need for this.
	robot_movement_modifier = /datum/movement_modifier/robot_part/thruster_right
	kind_of_limb = (LIMB_ROBOT | LIMB_TREADS | LIMB_LIGHT)

	on_life()
		var/turf/T = get_turf(src.holder)
		if(src.holder && (src.holder.loc == T))
			T?.hotspot_expose(700, 50)
