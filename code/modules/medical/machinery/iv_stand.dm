TYPEINFO(/obj/machinery/medical/iv_stand)
	mats = 10

/obj/machinery/medical/iv_stand
	name = "\improper IV stand"
	desc = "A metal pole that you can hang IV bags on, which is useful since we aren't animals that go leaving our sanitized medical equipment all over the ground or anything!"
	icon = 'icons/obj/machines/medical/iv_stand.dmi'
	icon_state = "IVstand"
	anchored = UNANCHORED
	density = 0
	var/image/fluid_image = null
	var/image/bag_image = null
	var/obj/item/reagent_containers/iv_drip/IV = null
	var/obj/paired_obj = null
	var/finished_pumping = FALSE

/obj/machinery/medical/iv_stand/get_desc()
	if (src.IV)
		var/list/examine_list = src.IV.examine()
		return examine_list.Join("\n")

/obj/machinery/medical/iv_stand/update_icon()
	if (!src.IV)
		src.icon_state = "IVstand"
		src.name = "\improper IV stand"
		src.UpdateOverlays(null, "fluid")
		src.UpdateOverlays(null, "bag")
	else
		src.name = "\improper IV stand ([src.IV])"
		if (src.IV.reagents.total_volume)
			src.bag_image = image(src.icon, icon_state = "IVstand1-full")
			if (!src.fluid_image)
				src.fluid_image = image(src.icon, icon_state = "IVstand1-fluid")
			src.fluid_image.icon_state = "IVstand1-fluid"
			var/datum/color/average = src.IV.reagents.get_average_color()
			src.fluid_image.color = average.to_rgba()
			src.UpdateOverlays(src.fluid_image, "fluid")
		else
			src.bag_image = image(src.icon, icon_state = "IVstand1")
			src.UpdateOverlays(null, "fluid")
		if(!src.bag_image)
			src.bag_image = image(src.icon, icon_state = "IVstand1")
		src.UpdateOverlays(src.bag_image, "bag")
		if (src.IV.in_use)
			src.icon_state = "IVstand-active"
		else
			src.icon_state = "IVstand-finished"

/obj/machinery/medical/iv_stand/attackby(obj/item/W, mob/user)
	if (iswrenchingtool(W))
		actions.start(new /datum/action/bar/icon/furniture_deconstruct(src, W, 20), user)
		return
	else if (!src.IV && istype(W, /obj/item/reagent_containers/iv_drip))
		if (isrobot(user)) // are they a borg? it's probably a mediborg's IV then, don't take that!
			return
		var/obj/item/reagent_containers/iv_drip/newIV = W
		user.visible_message(SPAN_NOTICE("[user] hangs [newIV] on [src]."),\
		SPAN_NOTICE("You hang [newIV] on [src]."))
		user.u_equip(newIV)
		newIV.set_loc(src)
		src.IV = newIV
		newIV.stand = src
		src.UpdateIcon()
		return
	else if (src.IV)
		//src.IV.Attackby(W, user)
		W.AfterAttack(src.IV, user)
		return
	else
		return ..()

/obj/machinery/medical/iv_stand/attack_hand(mob/user)
	if (src.IV && !isrobot(user))
		var/obj/item/reagent_containers/iv_drip/oldIV = src.IV
		user.visible_message(SPAN_NOTICE("[user] takes [oldIV] down from [src]."),\
		SPAN_NOTICE("You take [oldIV] down from [src]."))
		user.put_in_hand_or_drop(oldIV)
		oldIV.stand = null
		src.IV = null
		src.UpdateIcon()
		return
	else
		return ..()

/obj/machinery/medical/iv_stand/mouse_drop(atom/over_object as mob|obj)
	var/atom/movable/A = over_object
	if (usr && !usr.restrained() && !usr.stat && in_interact_range(src, usr) && in_interact_range(over_object, usr) && istype(A))
		if (src.IV && ishuman(over_object))
			src.IV.attack(over_object, usr)
			return
		else if (src.IV && over_object == src)
			src.IV.AttackSelf(usr)
			return
		else if (istype(over_object, /obj/stool/bed) || istype(over_object, /obj/stool/chair) || istype(over_object, /obj/machinery/optable))
			if (A == src.paired_obj && src.detach_from())
				src.visible_message("[usr] detaches [src] from [over_object].")
				return
			else if (src.attach_to(A))
				src.visible_message("[usr] attaches [src] to [over_object].")
				return
		else
			return ..()
	else
		return ..()

/obj/machinery/medical/iv_stand/proc/attach_to(var/obj/O as obj)
	if (!O)
		return 0
	if (src.paired_obj && !src.detach_from()) // detach_from() defaults to removing our paired_obj so we don't have to pass it anything
		return 0
	if (islist(O.attached_objs) && O.attached_objs.Find(src)) // we're already attached to this thing!!
		return 0
	mutual_attach(src, O)
	src.set_loc(O.loc)
	src.layer = (O.layer-0.1)
	src.pixel_y = 10
	src.paired_obj = O
	return 1

/obj/machinery/medical/iv_stand/proc/detach_from(var/obj/O as obj)
	if (!O && src.paired_obj)
		O = src.paired_obj
	if (!O)
		return 0
	mutual_detach(src, O)
	src.layer = initial(src.layer)
	src.pixel_y = initial(src.pixel_y)
	if (src.paired_obj == O)
		src.paired_obj = null
	return 1

/obj/machinery/medical/iv_stand/proc/deconstruct()
	if (src.IV)
		src.IV.set_loc(get_turf(src))
		src.IV.stand = null
		src.IV = null
	var/obj/item/furniture_parts/IVstand/P = new /obj/item/furniture_parts/IVstand(src.loc)
	if (P && src.material)
		P.setMaterial(src.material)
	qdel(src)
	return

/obj/machinery/medical/iv_stand/disposing()
	if (src.paired_obj)
		src.detach_from()
	if (src.IV)
		src.IV.set_loc(get_turf(src))
		src.IV.stand = null
		src.IV = null
	..()

/obj/item/furniture_parts/IVstand
	name = "\improper IV stand parts"
	desc = "A collection of parts that can be used to make an IV stand."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "IVstand_parts"
	force = 2
	stamina_damage = 10
	stamina_cost = 8
	furniture_type = /obj/machinery/medical/iv_stand
	furniture_name = "\improper IV stand"
	build_duration = 25
