/datum/hud/revenant
	var/mob/master = null
	var/atom/movable/screen/health = null
	var/initial_health = null

	New(M)
		..()
		master = M
		health = create_screen("health","Health", 'icons/mob/wraith_ui.dmi', "revhealth-7", "EAST, NORTH", HUD_LAYER, tooltipTheme = "healthDam healthDam0")
		health.desc = "You feel almost alive!"
		initial_health = master.health

	clear_master()
		master = null
		..()

	proc/update_health()
		var/effective_health = min(master.health, master.max_health)
		var/health_num = round( (max (effective_health + 50, 0) / (initial_health + 50)) *7 ) // Revenants die at -50.
		health.icon_state = "revhealth-[health_num]"
		switch(health_num)
			if (0)
				health.desc = "You feel like you're falling apart!"
			if (1)
				health.desc = "Your feel your insides slosh and churn as you move."
			if (2)
				health.desc = "You feel like your skin is loose and ill-fitting."
			if (3)
				health.desc = "You sense you've begun to leak a viscous fluid."
			if (4)
				health.desc = "You feel bloated."
			if (5)
				health.desc = "You feel stiff."
			if (6)
				health.desc = "You feel fresh"
			if (7)
				health.desc = "You feel almost alive!"
