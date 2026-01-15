ABSTRACT_TYPE(/obj/item/parts/robot_parts/chest)
/obj/item/parts/robot_parts/chest
	name = "cyborg chest"
	desc = "Oh no I'm an abstract parent object, how did you get me?"
	icon_state_base = "body"
	icon_state = "body-generic"
	slot = "chest"
	// These vars track the wiring/cell that the chest needs before you can stuff it on a frame
	var/wires = 0
	var/obj/item/cell/cell = null

	examine()
		. = ..()

		if (src.cell)
			. += SPAN_NOTICE("This chest unit has a [src.cell] installed. Use a wrench if you want to remove it.")
		else
			. += SPAN_ALERT("This chest unit has no power cell.")

		if (src.wires)
			. += SPAN_NOTICE("This chest unit has had wiring installed.")
		else
			. += SPAN_ALERT("This chest unit has not yet been wired up.")

	attackby(obj/item/W, mob/user)
		if(istype(W, /obj/item/cell))
			if(src.cell)
				boutput(user, SPAN_ALERT("You have already inserted a cell!"))
				return
			else
				user.drop_item()
				W.set_loc(src)
				src.cell = W
				boutput(user, SPAN_NOTICE("You insert [W]."))
				playsound(src, 'sound/impact_sounds/Generic_Stab_1.ogg', 40, TRUE)

		else if(istype(W, /obj/item/cable_coil))
			if (src.ropart_get_damage_percentage(2) > 0) ..()
			else
				if(src.wires)
					boutput(user, SPAN_ALERT("You have already inserted some wire!"))
					return
				else
					var/obj/item/cable_coil/coil = W
					coil.use(1)
					src.wires = 1
					boutput(user, SPAN_NOTICE("You insert some wire."))
					playsound(src, 'sound/impact_sounds/Generic_Stab_1.ogg', 40, TRUE)

		else if (iswrenchingtool(W))
			if(!src.cell)
				boutput(user, SPAN_ALERT("There's no cell in there to remove."))
				return
			playsound(src, 'sound/items/Ratchet.ogg', 40, TRUE)
			boutput(user, SPAN_NOTICE("You remove the cell from it's slot in the chest unit."))
			src.cell.set_loc( get_turf(src) )
			src.cell = null

		else if (issnippingtool(W))
			if(src.wires < 1)
				boutput(user, SPAN_ALERT("There's no wiring in there to remove."))
				return
			playsound(src, 'sound/items/Wirecutter.ogg', 40, TRUE)
			boutput(user, SPAN_NOTICE("You cut out the wires and remove them from the chest unit."))
			// i don't know why this would get abused
			// but it probably will
			// when that happens
			// tell past me i'm saying hello
			var/obj/item/cable_coil/cut/C = new /obj/item/cable_coil/cut(src.loc)
			C.amount = src.wires
			src.wires = 0

		else ..()

	Exited(Obj, newloc)
		. = ..()
		if(Obj == src.cell)
			src.cell = null

/obj/item/parts/robot_parts/chest/standard
	name = "standard cyborg chest"
	desc = "The centerpiece of any cyborg. It wouldn't get very far without it."
	material_amt = ROBOT_CHEST_COST
	max_health = 250
	robot_movement_modifier = /datum/movement_modifier/robot_part/standard_chest

	attackby(obj/item/W, mob/user)
		if (isweldingtool(W))
			var/obj/item/weldingtool/welder = W
			if (welder.try_weld(user, 3, 3))
				var/obj/item/clothing/suit/armor/makeshift/R = new /obj/item/clothing/suit/armor/makeshift(get_turf(user))
				boutput(user, SPAN_NOTICE("You remove the internal support structures of the [src]. It's structural integrity is ruined, but you could squeeze into it now."))
				user.u_equip(src)
				user.put_in_hand_or_drop(R)
				SEND_SIGNAL(src, COMSIG_ITEM_CONVERTED, R, user)
				qdel(src)
		else
			..()

/obj/item/parts/robot_parts/chest/light
	name = "light cyborg chest"
	desc = "A bare-bones cyborg chest designed for the least consumption of resources."
	appearanceString = "light"
	icon_state = "body-light"
	material_amt = ROBOT_CHEST_COST * ROBOT_LIGHT_COST_MOD
	max_health = 75
	robot_movement_modifier = /datum/movement_modifier/robot_part/light_chest
	kind_of_limb = (LIMB_ROBOT | LIMB_LIGHT) // hush

/obj/item/parts/robot_parts/chest/ancient
	name = "ancient chest"
	desc = "The thoracic carapace of an ancient silicon construct."
	icon_state = "body-ancient"
	appearanceString = "ancient"
	max_health = 350
	robot_movement_modifier = /datum/movement_modifier/robot_part/standard_chest

	stonecutter
		name = "stonecutter chest"
		desc = "The thoracic carapace of an ancient silicon stonecutter."
		icon_state = "body-ancient2"
		appearanceString = "ancient2"
		max_health = 250

	actuator
		name = "actuator chest"
		desc = "The heavy actuator frame of an ancient silicon loader."
		icon_state = "body-ancient3"
		appearanceString = "ancient3"
		max_health = 450
