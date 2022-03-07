/datum/component/legs
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/obj/legs

TYPEINFO(/datum/component/legs)
	initialization_args = list()

/datum/component/legs/Initialize()
	if(!istype(parent, /atom/movable))
		return COMPONENT_INCOMPATIBLE
	legs = new/obj{icon = 'icons/misc/SomepotatoArt.dmi'; pixel_y = -14; icon_state = "feet"}

/datum/component/legs/RegisterWithParent()
	. = ..()
	var/atom/movable/A = parent
	legs.pixel_y = -14 - A.pixel_y
	animate(A, pixel_y = A.pixel_y + 14, time = 5 DECI SECONDS, easing = SINE_EASING)
	A.underlays += legs

/datum/component/legs/UnregisterFromParent()
	. = ..()
	var/atom/movable/A = parent
	animate(A, pixel_y = A.pixel_y - 14, time = 5 DECI SECONDS, easing = SINE_EASING)
	A.underlays -= legs

