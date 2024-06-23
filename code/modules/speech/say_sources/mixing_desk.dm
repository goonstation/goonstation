/atom/movable/abstract_say_source/mixing_desk
	var/obj/submachine/mixing_desk/parent

/atom/movable/abstract_say_source/mixing_desk/New(obj/submachine/mixing_desk/loc, name, accent_id)
	. = ..()

	src.parent = loc
	src.name = name
	if (accent_id)
		src.ensure_say_tree().AddModifier(accent_id)

/atom/movable/abstract_say_source/mixing_desk/disposing()
	src.parent.voice_say_sources -= src

	. = ..()
