/atom/movable/abstract_say_source/radio/gang_announcer
	radio_chat_class = RADIOCL_SYNDICATE
	radio_icon = "civ"
	radio_icon_tooltip = "Civilian"

/atom/movable/abstract_say_source/radio/gang_announcer/New(loc, datum/gang/gang)
	src.name = "The [pick("Kingpin", "Cabal", "Council", "Boss")]"
	src.default_frequency = gang.gang_frequency

	. = ..()
