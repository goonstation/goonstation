/datum/component/holdertargeting/light
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	var/datum/light/light

/datum/component/holdertargeting/light/Initialize(r = 1.0, g = 1.0, b = 1.0, brightness = 1.5, height = 1.0)
	. = ..()
	if(. == COMPONENT_INCOMPATIBLE)
		return
	light = new /datum/light/point
	light.set_brightness(brightness)
	light.set_color(r, g, b)
	light.set_height(height)
	light.enable()
	var/obj/item/I = src.parent
	light.attach(I)

/datum/component/holdertargeting/light/on_pickup(datum/source, mob/user)
	. = ..()
	light.attach(user)

/datum/component/holdertargeting/light/on_dropped(datum/source, mob/user)
	. = ..()
	var/obj/item/I = parent
	if (I.loc != user)
		light.attach(parent)
