/datum/component/holdertargeting/simple_light
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	var/r = 255
	var/g = 255
	var/b = 255
	var/a = 255

/datum/component/holdertargeting/simple_light/Initialize(r = 255, g = 255, b = 255, a = 127)
	. = ..()
	if(. == COMPONENT_INCOMPATIBLE)
		return
	src.r = r
	src.g = g
	src.b = b
	src.a = a
	var/obj/item/I = src.parent
	I.add_simple_light("comp\ref[src]", list(src.r, src.g, src.b, src.a))

/datum/component/holdertargeting/simple_light/on_pickup(datum/source, mob/user)
	. = ..()
	var/obj/item/I = src.parent
	I.remove_simple_light("comp\ref[src]")
	user.add_simple_light("comp\ref[src]", list(r, g, b, a))

/datum/component/holdertargeting/simple_light/on_dropped(datum/source, mob/user)
	. = ..()
	var/obj/item/I = src.parent
	if (I.loc != user)
		user.remove_simple_light("comp\ref[src]")
		I.add_simple_light("comp\ref[src]", list(r, g, b, a))
