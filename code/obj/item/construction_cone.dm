
//construction cone, a stackable hat / placed item.
/obj/item/clothing/head/constructioncone
	desc = "Caution!"
	name = "construction cone"
	icon = 'icons/obj/construction.dmi'
	icon_state = "cone_1"
	force = 1
	throwforce = 3
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_SMALL
	flags = TABLEPASS
	default_material = "plastic"
	stamina_damage = 15
	stamina_cost = 8
	stamina_crit_chance = 10
	max_stack = 5
	item_state = "cone_1"
	wear_state = "cone_hat_1"
	hat_offset_y = 8

	setupProperties()
		..()
		setProperty("coldprot", 0) // it has a hole on top, after all
		setProperty("heatprot", 0)
		setProperty("meleeprot_head", 2)

	before_stack(atom/movable/O as obj, mob/user as mob)
		user.visible_message(SPAN_NOTICE("[user] begins gathering up [src]\s!"))

	after_stack(atom/movable/O as obj, mob/user as mob, var/added)
		UpdateStackAppearance()
		boutput(user, SPAN_NOTICE("You finish gathering up [src]\s."))

	attack_hand(mob/user)
		if((user.r_hand == src || user.l_hand == src) && src.amount > 1)

			if (!in_interact_range(src, user)) //no walking away
				return

			var/obj/item/clothing/head/constructioncone/new_stack = split_stack(1)
			if (!istype(new_stack))
				boutput(user, SPAN_ALERT("Invalid entry, try again."))
				return
			user.put_in_hand_or_drop(new_stack)
			new_stack.add_fingerprint(user)
			boutput(user, SPAN_NOTICE("You take 1 cone from the stack, leaving [src.amount] cones behind."))
		else
			..(user)


	attackby(obj/item/I, mob/user)
		if (istype(I, /obj/item/clothing/head/constructioncone))
			if (src.loc == user)
				if (ishuman(user))
					var/mob/living/carbon/human/H = user
					if (H.head == src)
						boutput(user, SPAN_ALERT("You can't stack cones when they are on your head!"))
						return
			var/success = stack_item(I)
			if (!success)
				boutput(user, SPAN_ALERT("You can't put any more cones in this stack!"))
			else
				if(!user.is_in_hands(src))
					user.put_in_hand(src)
				if(isrobot(user))
					boutput(user, SPAN_NOTICE("You add [success] cones to the stack. It now has [I.amount] cones."))
				else
					boutput(user, SPAN_NOTICE("You add [src.amount - success] cones to the stack. It now has [src.amount] cones."))

	_update_stack_appearance()
		src.amount = clamp(src.amount, 1, src.max_stack)
		icon_state = "cone_[src.amount]"
		item_state = "cone_[src.amount]"
		wear_state = "cone_hat_[src.amount]"

	afterattack(var/turf/T, var/mob/user, reach, params)
		if (!isturf(user.loc))
			return

		if (BOUNDS_DIST(T, user) > 0)
			boutput(user, SPAN_NOTICE("You can't setup [src] that far away."))
			return

		if (!istype(T, /turf/simulated/floor))
			return

		var/obj/item/clothing/head/constructioncone/cone = new /obj/item/clothing/head/constructioncone
		src.change_stack_amount(-1)

		var/pox = cone.pixel_x
		var/poy = cone.pixel_y

		if (params)
			if (islist(params) && params["icon-y"] && params["icon-x"])
				pox = text2num(params["icon-x"]) - 16
				poy = text2num(params["icon-y"]) - 16

		cone.pixel_x = pox
		cone.pixel_y = poy
		cone.set_loc(T)
		playsound(cone, 'sound/impact_sounds/tube_bonk.ogg', 20, TRUE, pitch=0.5)
		..()

	examine()
		. = ..()
		. += "There are [src.amount] cones on this stack."
