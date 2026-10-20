ABSTRACT_TYPE(/datum/firemode)
/datum/firemode
	var/name // The name of the firemode
	var/shot_number = 1         // How many projectiles should be fired, each will cost the full cost
	var/shot_delay = 0.1 SECONDS // Time between shots in a burst. Pods will use shot_delay for cooldowns
	var/full_auto = FALSE // If this is fully automatic
	var/datum/projectile/projectile_override = null // If true, override fired projectile

	donotshoot //! slime does this for w/e reason
		shot_number = 0

	single
		name = "single shot"
		shot_number = 1

	automatic
		name = "automatic fire"
		full_auto = TRUE
		shot_number = 1

	two_burst
		name = "two shot burst"
		shot_number = 2

	three_burst
		name = "burst fire"
		shot_number = 3
		automatic
			name = "automatic burst fire"
			full_auto = TRUE

	four_burst
		name = "four shot burst"
		shot_number = 4

	five_burst
		name = "five shot burst"
		shot_number = 5
	ten_burst
		name = "ten shot burst"
		shot_number = 10

	plasma_burst
		name = "plasma burst"
		shot_number = 4
		shot_delay = 1

	kuvalda_broadside
		name = "kuvalda broadside"
		shot_number = 4
		shot_delay = 0.1 SECONDS

	janitor_wave
		wave
			projectile_override = new /datum/projectile/special/shotchem/wave/wide
		single
			projectile_override = new /datum/projectile/special/shotchem/wave/single

	energy
		heavyion
			projectile_override = new /datum/projectile/heavyion
		energy_bolt
			projectile_override = new /datum/projectile/energy_bolt
		laser
			projectile_override = new /datum/projectile/laser
		energy_bolt_ntburst
			projectile_override = new /datum/projectile/energy_bolt/ntburst
		shotgun_spread
			projectile_override = new /datum/projectile/special/spreader/tasershotgunspread
		laser_ntburst
			projectile_override = new /datum/projectile/laser/ntburst
		tasershotgun_slug
			projectile_override = new /datum/projectile/energy_bolt/tasershotgunslug
		wavegun_transverse
			projectile_override = new /datum/projectile/wavegun/transverse
		wavegun_bouncy
			projectile_override = new /datum/projectile/wavegun/bouncy
		wavegun
			projectile_override = new /datum/projectile/wavegun
		owl
			projectile_override = new /datum/projectile/owl
		owl_owlate
			projectile_override = new /datum/projectile/owl/owlate
		frog
			projectile_override = new /datum/projectile/bullet/frog
		frog_getout
			projectile_override = new /datum/projectile/bullet/frog/getout
		pickpocket_steal
			projectile_override = new /datum/projectile/pickpocket/steal
		pickpocket_plant
			projectile_override = new /datum/projectile/pickpocket/plant
		pickpocket_harass
			projectile_override = new /datum/projectile/pickpocket/harass
		pulse_electromagnetic
			projectile_override = new /datum/projectile/energy_bolt/electromagnetic_pulse
		pulse
			projectile_override = new /datum/projectile/energy_bolt/pulse
		pulse_pull
			projectile_override = new /datum/projectile/energy_bolt/pulse/pull
		optio_hitscan
			projectile_override = new /datum/projectile/bullet/optio/hitscan
		optio
			projectile_override = new /datum/projectile/bullet/optio
		signifer_lethal
			projectile_override = new /datum/projectile/laser/signifer_lethal
		signifer_tase
			projectile_override = new /datum/projectile/energy_bolt/signifer_tase
		plasma_burst
			shot_number = 4
			projectile_override = new /datum/projectile/laser/plasma/burst
		plasma_auto
			full_auto = TRUE
			projectile_override = new /datum/projectile/laser/plasma/auto
		smg_auto
			full_auto = TRUE
			projectile_override = new /datum/projectile/energy_bolt/smgauto
		smg_burst
			shot_number = 2
			projectile_override = new /datum/projectile/energy_bolt/smgburst
		laser_glitter_burst
			shot_number = 3
			projectile_override = new /datum/projectile/laser/glitter/burst
		laser_glitter
			projectile_override = new /datum/projectile/laser/glitter

	kinetic
		veritate
			name = "single shot"
		veritate_burst
			name = "burst fire"
			shot_number = 3
	grenade_launcher_broadside
		name = "grenade launcher broadside"
		shot_number = 2
		shot_delay = 0.2 SECONDS
	akm
		name = "burst fire"
		shot_number = 3
		shot_delay = 120 MILLI SECONDS

	lmg
		burst
			name = "8 shot burst"
			shot_number = 8
		weak
			name = "16 shot burst"
			shot_number = 16
			shot_delay = 0.07 SECONDS

	mrl
		shot_delay = 1 SECONDS

	g11
		name = "burst fire"
		shot_number = 3
		shot_delay = 0.04 SECONDS

	match22
		shot_delay = 0.2

	flamethrower
		auto

			name = "auto fire"
			shot_number = 2
			shot_delay = 2 DECI SECONDS
			full_auto = TRUE
		burst
			name = "burst fire"
			shot_number = 4
			shot_delay = 1 SECOND
		backtank
			name = "backtank mode"
			shot_delay = 2 DECI SECONDS

	homing_missile
		shot_delay = 1 SECOND
	cluster_rocket
		shot_delay = 1 SECOND
	pod
		rocket_salvo
			name = "salvo"
			shot_number = 3
			shot_delay = 0.5 SECONDS

		podseeker
			shot_delay = 1 SECOND

		burst_phaser
			name = "burst fire"
			shot_number = 3
			shot_delay = 0.2 SECONDS
