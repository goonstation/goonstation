/image/maptext/gang_score
	alpha = 180
	respect_maptext_preferences = FALSE

/image/maptext/gang_score/init(amount)
	src.maptext = "<span class='pixel c ol' style=\"color: #08be4e;\">+[amount]</span>"
	. = ..()
