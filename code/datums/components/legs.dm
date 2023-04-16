/datum/component/legs
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/obj/legs
	var/icon_path = 'icons/misc/SomepotatoArt.dmi'
	var/icon_state_name = "feet"
	var/y_offset = -14

TYPEINFO(/datum/component/legs)
	initialization_args = list()

/datum/component/legs/Initialize()
	. = ..()
	if(!istype(parent, /atom/movable))
		return COMPONENT_INCOMPATIBLE
	legs = new/obj
	legs.icon = src.icon_path
	legs.pixel_y = src.y_offset
	legs.icon_state = src.icon_state_name
	legs.plane = FLOAT_PLANE

/datum/component/legs/RegisterWithParent()
	. = ..()
	var/atom/movable/A = parent
	legs.pixel_y = src.y_offset - A.pixel_y
	animate(A, pixel_y = A.pixel_y - src.y_offset, time = 5 DECI SECONDS, easing = SINE_EASING)
	A.underlays += legs

/datum/component/legs/UnregisterFromParent()
	. = ..()
	var/atom/movable/A = parent
	animate(A, pixel_y = A.pixel_y + src.y_offset, time = 5 DECI SECONDS, easing = SINE_EASING)
	A.underlays -= legs

/datum/component/legs/six
	icon_path = 'icons/misc/mechanicsExpansion.dmi'
	icon_state_name = "legs"
	y_offset = -8

/datum/component/legs/four
	icon_path = 'icons/misc/mechanicsExpansion.dmi'
	icon_state_name = "small_legs"
	y_offset = 0
