// MASTER DATUMS

/datum/artifact/
	var/associated_object = null
	var/rarity_class = 0
	//Bigger rarity means its less likely to show up. Thanks for documenting this, guys. - Azungar
	// Also note that rarity 0 means the artifact does not randomly spawn.
	// Tweaked rarity 1 to contain all the uninteresting garbage artifacts. Explosion artifacts still appear at 3/4 because explodey is not boring - Phyvo

	var/datum/artifact_origin/artitype = null
	var/list/validtypes = list("ancient","martian","wizard","eldritch","precursor",/*"reliquary"*/)
	// During setup, artitype will be set from a pick() from within the validtypes list.
	// Keep it to only the five here or shit will probably get a bit weird. This allows us to exclude things that don't make
	// any sense such as martian robot builders or ancient robot plant seeds.

	var/internal_name = null
	var/image/fx_image = null
	//var/image/effects_overlay = null
	var/obj/holder = null
	// These are automatically handled. They're used to make the artifact glow different colors.

	var/activated = 0            // Is the artifact currently switched on?
	var/automatic_activation = 0 // Does the artifact switch itself on on spawn?
	var/activ_sound = null       // What noise the artifact makes when it activates
	var/activ_text = null        // What message the artifact transmits when it activates
	var/deact_sound = null       // Guess.
	var/deact_text = null        // No really, have a wild guess.
	var/scramblechance = 10      // how likely this artifact is to look like a type it isnt
	var/nofx = 0			 	 // used to set straight icon_states on activation instead of fx overlays

	var/list/faults = list()      // Automatically handled
	var/list/fault_types = list() // this is set up based on the artifact's origin type

	var/list/triggers = list()
	var/validtriggers = list(/datum/artifact_trigger/force,/datum/artifact_trigger/electric,/datum/artifact_trigger/heat,
	/datum/artifact_trigger/radiation,/datum/artifact_trigger/carbon_touch,/datum/artifact_trigger/silicon_touch,/datum/artifact_trigger/data)
	var/min_triggers = 1
	var/max_triggers = 1
	var/hint_text = "emits a faint noise."
	var/examine_hint = null

	// These are used for module research
	var/list/module_research = list()
	var/module_research_insight = 1 // insight level into the origin of the artifact

	var/health = 100
	// This is mostly used in the stimulus procs that deal with damaging the artifact and whatnot.
	// Once it hits 0 or below, the artifact is destroyed.

	// these below are holders for data that will come back from the various artifact sensor test apparatus
	var/list/react_mpct = list(0,0)
	// Impact Pad - returns Vibration Amplitude, Vibration Frequency
	// react_mpct should be set up in the ArtifactSetup proc
	var/list/react_elec = list(0.1,0,0)
	// Electrobox - returns Returned Current, Circuit Capacity, Circuit Interference
	// react_elec should be set up in the item's New proc (NOT the datum's!)
	var/list/react_heat = list(1,"NONE")
	// Heat Plate - returns Artifact Temp, Heat Response, Cold Response, Details
	// react_heat - set up first var in ArtifactSetup, the rest in the individual datums
	var/list/react_xray = list(10,100,100,11,"NONE")
	// X-ray - returns Density, Structural Consistency, Structural Integrity, Response, Special Features
	// react_xray should be set as a variable on the artifact datum
	var/list/touch_descriptors = list()

	proc/post_setup()
		return

	proc/may_activate(var/obj/O)
		if (!O)
			return 0
		return 1

	// Added log entry calls here. See artifactprocs.dm for the proc (Convair880).
	proc/effect_activate(var/obj/O)
		if (!O)
			return 1
		O.add_fingerprint(usr)
		ArtifactLogs(usr, null, O, "activated", null, istype(src, /datum/artifact/bomb/) ? 1 : 0)
		return 0

	proc/effect_deactivate(var/obj/O)
		if (!O)
			return 1
		O.add_fingerprint(usr)
		ArtifactLogs(usr, null, O, "deactivated", null, 0)
		return 0

	proc/effect_process(var/obj/O)
		if (!O)
			return 1
		return 0

	proc/effect_touch(var/obj/O,var/mob/living/user)
		if (!O || !user)
			return 1
		O.add_fingerprint(user)
		return 0

	proc/effect_melee_attack(var/obj/O,var/mob/living/user,var/mob/living/target)
		if (!O || !user || !target)
			return 1
		O.add_fingerprint(user)
		ArtifactLogs(user, target, O, "weapon", null, 0)
		return 0

	proc/effect_click_tile(var/obj/O,var/mob/living/user,var/turf/T)
		if (!O || !user || !T)
			return 1
		if (user.client && get_dist(T,user) > (istext(user.client.view) ? 10 : user.client.view)) // shitty hack // we cannot see that far, we're probably being a butt and trying to do something through a camera
			return 1
		else if (!user.client && get_dist(T,user) > world.view) // idk, SOMEhow someone would find a way
			return 1
		O.add_fingerprint(user)
		if (!istype(O, /obj/item/artifact/attack_wand)) // Special log handling required there.
			ArtifactLogs(user, T, O, "used", "triggering its effect on target turf", 0)
		return 0

	proc/get_trigger_by_string(var/string)
		if (!istext(string))
			return null
		for (var/datum/artifact_trigger/AT in src.triggers)
			if (AT.stimulus_required == string)
				return AT
		return null

	proc/get_trigger_by_path(var/path)
		if (!ispath(path))
			return null
		for (var/datum/artifact_trigger/AT in src.triggers)
			if (AT.type == path)
				return AT
		return null

// SPECIFIC DATUMS

/datum/artifact/art
	validtypes = list("ancient","martian","wizard","eldritch","precursor",/*"reliquary"*/)
	activated = 0
	min_triggers = 0
	max_triggers = 0
	react_xray = list(10,100,100,11,"NONE","NONE")

// DATUMS USED BY ARTIFACTS

/datum/projectile/artifact
	name = "energy bolt"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "u_laser"
	power = 75
	cost = 25
	dissipation_rate = 0
	dissipation_delay = 50
	ks_ratio = 1.0
	sname = "energy bolt"
	shot_sound = 'sound/weapons/Taser.ogg'
	shot_number = 1
	damage_type = D_PIERCING
	hit_ground_chance = 90
	window_pass = 0

	on_hit(atom/hit)
		return

	proc/randomise()
		icon_state = pick("spark","laser","ibeam","u_laser","phaser_heavy","phaser_light","phaser_med","phaser_ultra","blue_spark","disrupt","disrupt_lethal","radbolt","crescent",
		"goo","40mmgatling","elecorb","purple_orb","triple")
		src.shot_sound = pick('sound/weapons/Taser.ogg','sound/weapons/flaregun.ogg','sound/weapons/Laser.ogg','sound/weapons/laserheavy.ogg','sound/weapons/laserlight.ogg','sound/weapons/lasermed.ogg','sound/weapons/laserultra.ogg','sound/weapons/grenade.ogg','sound/weapons/rocket.ogg','sound/weapons/snipershot.ogg','sound/weapons/TaserOLD.ogg','sound/weapons/ACgun1.ogg','sound/weapons/ACgun2.ogg')
		var/namep1 = pick("neutrino","meson","photon","quark","disruptor","atomic","zero point","tachyon","plasma","quantum","neutron","baryon","hadron","electron","positron")
		var/namep2 = pick("bolt","ray","beam","wave","burst","blast","torpedo","missile","bomb","shard","stream","string")
		src.name = "[namep1] [namep2]"
		// Now randomise the damage type, power, energy cost and other fun stuff

		src.damage_type = pick(D_KINETIC,D_PIERCING,D_SLASHING,D_ENERGY,D_BURNING,D_RADIOACTIVE,D_TOXIC)
		src.power = rand(2,50)
		src.dissipation_rate = rand(1,power)
		src.dissipation_delay = rand(1,10)
		src.ks_ratio = pick(0, 1, prob(10); (rand(0, 10000) / 10000))

		src.cost = rand(50,150)
		if (prob(20))
			src.window_pass = 1
		// Rare chance of the gun firing several shots in a burst
		shot_number = pick(1, prob(25); 2, prob(5); 3, prob(1); 4)

// for use with the wizard spell prismatic_spray
/datum/projectile/artifact/prismatic_projectile
	is_magical = 1

	New()
		..()
		src.randomise()
