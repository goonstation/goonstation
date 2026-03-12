/image/maptext/sap_power
	alpha = 180
	respect_maptext_preferences = FALSE

/image/maptext/sap_power/init(content)
	src.maptext = "<span class='c ps2p sh' style=\"color: #e6e600;\">[content]</span>"
	. = ..()
