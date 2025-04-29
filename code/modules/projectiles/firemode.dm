datum/firemode
	var/name = "single shot" // The name of the firemode
	var/shot_number = 1         // How many projectiles should be fired, each will cost the full cost
	var/shot_delay = 0.1 SECONDS // Time between shots in a burst. Pods will use shot_delay for cooldowns
	var/full_auto = 0 // If this is fully automatic

	donotshoot //! slime does this for w/e reason
		shot_number = 0

	single
		shot_number = 1

	automatic
		name = "automatic fire"
		full_auto = 1
		shot_number = 1

	two_burst
		name = "two shot burst"
		shot_number = 2

	three_burst
		name = "burst fire"
		shot_number = 3
		automatic
			name = "automatic burst fire"
			full_auto = 1

	four_burst
		name = "four shot burst"
		shot_number = 4

	five_burst
		name = "five shot burst"
		shot_number = 4
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

	grenade_launcher_broadside
		name = "grenade launcher broadside"
		shot_number = 2
		shot_delay = 0.2 SECONDS
	akm
		burst
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
		burst
			name = "burst fire"
			shot_number = 3
			shot_delay = 0.04 SECONDS

	match22
		shot_delay = 0.2

	slime
		shot_number = 0 // ??? this was set to 0

	flamethrower
		auto

			name = "auto fire"
			shot_number = 2
			shot_delay = 2 DECI SECONDS
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
