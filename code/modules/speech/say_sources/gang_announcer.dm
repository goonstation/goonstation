/atom/movable/abstract_say_source/radio/gang_announcer
	radio_chat_class = RADIO::CSS::SYNDICATE
	radio_icon = "gang_boss"
	radio_icon_tooltip = "Gang Announcer"

/atom/movable/abstract_say_source/radio/gang_announcer/New(loc, datum/gang/gang)
	src.name = "The [pick("Kingpin", "Cabal", "Council", "Boss")]"
	src.radio_icon_tooltip = src.name
	src.default_frequency = gang.gang_frequency

	. = ..()
