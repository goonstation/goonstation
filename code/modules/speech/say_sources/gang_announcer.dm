/atom/movable/abstract_say_source/radio/gang_announcer
	radio_chat_class = RADIOCL_SYNDICATE
	radio_icon = "civ"
	radio_icon_tooltip = "Civilian"

/atom/movable/abstract_say_source/radio/gang_announcer/New(loc, datum/gang/gang)
	src.name = "The [pick("Kingpin", "Cabal", "Council", "Boss")]"
	src.update_name(gang.gang_name)
	src.default_frequency = gang.gang_frequency

	. = ..()

/atom/movable/abstract_say_source/radio/gang_announcer/proc/update_name(gang_name)
	src.internal_name = "Gang Announcer \[[gang_name]\]"
