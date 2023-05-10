/datum/component/foldable
	var/obj/item/objBriefcase/the_briefcase
	var/original_name
	var/original_desc
	var/briefcase_path
	var/change_name = 1

/datum/component/foldable/keep_name
	change_name = 0

TYPEINFO(/datum/component/foldable)
	initialization_args = list(
		ARG_INFO("briefcase_path", DATA_INPUT_TYPE, "Path of item that will be folded up into", /obj/item/objBriefcase)
	)

/datum/component/foldable/Initialize(var/briefcase_path = /obj/item/objBriefcase)
	. = ..()
	if(!istype(parent, /atom/movable))
		return COMPONENT_INCOMPATIBLE
	if(!ispath(briefcase_path, /obj/item/objBriefcase))
		return COMPONENT_INCOMPATIBLE
	src.briefcase_path = briefcase_path

/datum/component/foldable/RegisterWithParent()
	. = ..()
	var/atom/movable/object = src.parent
	src.the_briefcase = new src.briefcase_path(null, object)
	if(src.change_name)
		src.original_name = object.name
		src.original_desc = object.desc
		object.name = "foldable [object.name]"
		object.desc += " Whoa, this one can be folded into a briefcase!"
	object.verbs += /obj/proc/foldUpIntoBriefcase

/datum/component/foldable/UnregisterFromParent()
	. = ..()
	var/atom/movable/object = src.parent
	object.verbs -= /obj/proc/foldUpIntoBriefcase
	if(src.change_name)
		object.name = src.original_name
		object.desc = src.original_desc
	qdel(src.the_briefcase)

/obj/proc/foldUpIntoBriefcase()
	set category = "Local"
	set name = "Fold up"
	set src in view(1)

	if(usr.stat)
		return
	var/atom/movable/object = src
	if(!object)
		return

	var/datum/component/foldable/fold_component = object.GetComponent(/datum/component/foldable)
	if(!fold_component)
		return
	if(!fold_component.the_briefcase)
		return //fold_component.the_briefcase = new/obj/item/objBriefcase(get_turf(object), object)
	var/obj/item/objBriefcase/briefcase = fold_component.the_briefcase

	if(src.loc == briefcase)
		return

	if(src.loc == usr)
		usr.drop_from_slot(src)

	briefcase.set_loc(get_turf(object))
	object.set_loc(briefcase)
	usr.visible_message("<span class='alert'>[usr] folds [object] back up!</span>")

/obj/item/objBriefcase
	name = "briefcase"
	icon = 'icons/obj/items/storage.dmi'
	item_state = "briefcase"
	inhand_image_icon = 'icons/mob/inhand/hand_general.dmi'
	icon_state = "briefcase"
	desc = "A briefcase."
	flags = FPRINT | TABLEPASS| CONDUCT | NOSPLASH
	force = 8
	throw_speed = 1
	throw_range = 4
	w_class = W_CLASS_BULKY
	stamina_damage = 40
	stamina_cost = 17
	stamina_crit_chance = 10

	burn_point = 2500
	burn_output = 2500
	burn_possible = 1
	health = 10

	var/atom/movable/thingInside

	New(var/loc, var/obj/object)
		..(loc)
		src.set_loc(loc)
		if(object)
			src.thingInside = object
			src.name = "foldable [object.name]"
			src.desc = "A briefcase with a [object.name] inside. A breakthrough in briefcase technology!"
		BLOCK_SETUP(BLOCK_BOOK)

	attack_self(mob/user)
		deploy(user)

	verb/unfold()
		set src in view(1)
		set category = "Local"
		set name = "Unfold"
		deploy(usr)

	proc/deploy(var/mob/user)
		if(!thingInside)
			return
		thingInside.set_loc(get_turf(src))
		if(src.loc == user)
			user.drop_from_slot(src)
		src.set_loc(null)
		user.visible_message("<span class='alert'>[user] unfolds [thingInside] from a briefcase!</span>")

	disposing()
		if(src.thingInside)
			var/datum/component/foldable/fold_component = src.thingInside.GetComponent(/datum/component/foldable)
			if(fold_component && fold_component.the_briefcase == src)
				fold_component.the_briefcase = null
			src.thingInside = null
		..()
	blue_stripe
		icon_state = "hopcase"
		item_state = "hopcase"
	blue_green_stripe
		icon_state = "hopcaseC"
		item_state = "hopcaseC"
