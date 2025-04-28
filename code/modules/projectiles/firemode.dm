datum/firemode
	var/shot_number = 1         // How many projectiles should be fired, each will cost the full cost
	var/shot_delay = 0.1 SECONDS // Time between shots in a burst. Pods will use shot_delay for cooldowns

	donotshoot //! slime does this for w/e reason
		shot_number = 0

	single
		shot_number = 1

	two_burst
		shot_number = 2

	three_burst
		shot_number = 3

	four_burst
		shot_number = 4

	five_burst
		shot_number = 4
	ten_burst
		shot_number = 10

	plasma_burst
		shot_number = 4
		shot_delay = 1

	kuvalda_broadside
		shot_number = 4
		shot_delay = 0.1 SECONDS

	grenade_launcher_broadside
		shot_number = 2
		shot_delay = 0.2 SECONDS
	akm
		burst
			shot_number = 3
			shot_delay = 120 MILLI SECONDS

	lmg
		burst
			shot_number = 8
		weak
			shot_number = 16
			shot_delay = 0.07 SECONDS

	mrl
		shot_delay = 1 SECONDS

	g11
		burst
			shot_number = 3
			shot_delay = 0.04 SECONDS

	match22
		shot_delay = 0.2

	slime
		shot_number = 0 // ??? this was set to 0

	flamethrower
		auto
			shot_number = 2
			shot_delay = 2 DECI SECONDS
		burst
			shot_number = 4
			shot_delay = 1 SECOND
		backtank
			shot_delay = 2 DECI SECONDS

	homing_missile
		shot_delay = 1 SECOND
	cluster_rocket
		shot_delay = 1 SECOND
	pod
		rocket_salvo
			shot_number = 3
			shot_delay = 0.5 SECONDS

		podseeker
			shot_delay = 1 SECOND

		burst_phaser
			shot_number = 3
			shot_delay = 0.2 SECONDS
