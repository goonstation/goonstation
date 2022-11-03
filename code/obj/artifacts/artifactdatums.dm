// MASTER DATUMS

ABSTRACT_TYPE(/datum/artifact/)
/datum/artifact/
	/// the actual /obj type that is the artifact for this datum
	var/associated_object = null
	/// a weighted commonness, the higher it is the more often the artifact will appear
	/// at 0 it should not appear randomly at all
	var/rarity_weight = 0
	/// the name for this artifact type, used for displaying it visually (for instance in analysis forms)
	var/type_name = "buggy artifact code"
	/// the size category of the artifact
	// this could probably be determined via the icon of the associated_object type right now, but that'd be weird and dumb
	var/type_size = ARTIFACT_SIZE_LARGE
	/// the artifact origin (martian, eldritch, etc...)
	var/datum/artifact_origin/artitype = null
	/// the list of options for the origin from which to pick from
	var/list/validtypes = list("ancient","martian","wizard","eldritch","precursor")
	// During setup, artitype will be set from a pick() from within the validtypes list.
	// Keep it to only the five here or shit will probably get a bit weird. This allows us to exclude things that don't make
	// any sense such as martian robot builders or ancient robot plant seeds.

	/// the actual name of the artifact to be displayed once it is analyzed
	var/internal_name = null
	/// a number of "fake" names for each artifact origin, for when people put the wrong origin on an analysis form
	var/used_names = list()
	// These are automatically handled. They're used to make the artifact glow different colors.
	/// the glowy overlay used for when the artifact is activated
	var/image/fx_image = null
	/// the actual /obj that belongs to this specific artifact instance
	var/obj/holder = null

	/// Is the artifact currently switched on?
	var/activated = 0
	/// Does the artifact switch itself on on spawn?
	var/automatic_activation = 0
  	/// Does the artifact not need activation? (for instance, reagent containers)
	var/no_activation = FALSE
	/// What noise the artifact makes when activated
	var/activ_sound = null
	/// What message the artifact gives when activated
	var/activ_text = null
	/// What noise the artifact makes when deactivated
	var/deact_sound = null
	/// What message the artifact gives when deactivated
	var/deact_text = null
	/// How likely this artifact is to appear to be from an origin that it isn't from
	var/scramblechance = 10
	/// used to set straight icon_states on activation instead of fx overlays
	var/nofx = 0
	/// special_addendum for ArtifactLogs() proc
	var/log_addendum = null

	/// the list of all the artifacts faults
	var/list/faults = list()
	/// a weighted list of possible faults
	/// it should be the possible fault types of the origin minus the fault types in the artifact type's fault_blacklist
	var/list/fault_types = list()
	/// fault types that are not allowed on this type of artifact (usually due to not working properly/making sense)
	var/list/datum/artifact_fault/fault_blacklist = list()

	/// Which stimuli will activate this artifact?
	var/list/triggers = list()
	/// List from which to pick the triggers
	var/validtriggers = list(/datum/artifact_trigger/force,/datum/artifact_trigger/electric,/datum/artifact_trigger/heat,
	/datum/artifact_trigger/radiation,/datum/artifact_trigger/carbon_touch,/datum/artifact_trigger/silicon_touch,/datum/artifact_trigger/data)
	/// minimum amount of triggers the artifact will have
	var/min_triggers = 1
	/// maximum amount of triggers the artifact will have
	var/max_triggers = 1
	/// Message displayed when the artifact receives the correct stimulus at close to the correct amount (but not quite there)
	var/hint_text = "emits a faint noise."
	/// An additional message displayed when examining, to hint at the artifact type (mainly used for more dangerous types)
	var/examine_hint = null

	/// ID of the cargo tech skimming a cut of the sale
	var/obj/item/card/id/scan = null
	/// Bank account info of the cargo tech skimming a cut of the sale
	var/datum/db_record/account = null

	/// The health of the artifact, can be damaged by stimuli, chems, etc
	/// When it hits 0, the artifact will be destroyed (after triggering ArtifactDestroyed())
	var/health = 100

	// these below are holders for data that will come back from the various artifact sensor test apparatus
	// various things (like origins, faults, ..) can still alter these values for the machines
	/// Impact Pad response, Vibration Amplitude, Vibration Frequency
	/// This is mostly so one can figure out the origin of disguised artifacts
	/// It also allows you to see if an artifact reponds to physical force easily without activating it
	/// set up in ArtifactSetup()
	var/list/react_mpct = list(0,0)
	/// Elecbox response, Returned Current, Circuit Capacity, Circuit Interference
	/// This is mostly so the Circuit Capacity can show the capacity of artifact power cells.
	/// Because those inherit from the cell object, it is set up in the New() proc of the /obj, I guess.
	var/list/react_elec = list(0.1,0,0)
	/// Heater response, Artifact Temp, Heat/Cold Reponse, Details
	/// The artifact temp is modified by origin, so that could be used to find the real origin as well.
	/// Heat/Cold reponse just shows if the current artifact reponds to the current stimulus
	/// The Details just give a hint for a whole bunch of artifacts
	var/list/react_heat = list(1,"NONE")
	/// X-ray response, Density, Structural Consistency, Structural Integrity, Reponse, Special Features
	/// lots of features make it good to determine artifact types, but the values are also modified a lot by origin/faults, to make it trickier
	/// notably, Density can also estimate the yield of explosive artifact bombs
	/// Set on the artifact datum
	var/list/react_xray = list(10,100,100,11,"NONE")
	/// Some descriptive texts you may get when you touch the artifact.
	/// It is based mainly on origin, but some artifact types add more descriptors.
	/// It is based on the fake origin though, so it is no use for recognizing fake origins.
	var/list/touch_descriptors = list()

	/// gets called after the artifact basics (origin, appearance, object, etc) are all set up, so the type can modify it further
	proc/post_setup()
		SHOULD_CALL_PARENT(TRUE)
		src.artitype.post_setup(holder)
		OTHER_START_TRACKING_CAT(holder, TR_CAT_ARTIFACTS)

	disposing()
		if(src.artitype)
			OTHER_STOP_TRACKING_CAT(holder, TR_CAT_ARTIFACTS)

		artitype = null
		fx_image = null
		holder = null
		faults = null
		fault_types = null
		triggers = null
		scan = null
		account = null
		. = ..()

	/// Whether or not the artifact is allowed to activate, usually just a sanity check, but artifact types can add more conditions (like cooldowns).
	proc/may_activate(var/obj/O)
		if (!O)
			return 0
		return 1

	/// What the artifact does once when activated.
	proc/effect_activate(var/obj/O)
		if (!O)
			return 1
		O.add_fingerprint(usr)
		ArtifactLogs(usr, null, O, "activated", log_addendum, istype(src, /datum/artifact/bomb/) ? 1 : 0)
		return 0

	/// What the artifact does once when deactivated.
	proc/effect_deactivate(var/obj/O)
		if (!O)
			return 1
		O.add_fingerprint(usr)
		ArtifactLogs(usr, null, O, "deactivated", log_addendum, 0)
		return 0

	/// What activated artifact machines do each processing tick.
	proc/effect_process(var/obj/O)
		if (!O)
			return 1
		return 0

	/// What the artifact does if touched while activated.
	proc/effect_touch(var/obj/O,var/mob/living/user)
		if (!O || !user)
			return 1
		O.add_fingerprint(user)
		return 0

	/// What the artifact does when it is activated and you smack a person with it.
	/// Only called in /obj/item/artifact/melee_weapon so far.
	proc/effect_melee_attack(var/obj/O,var/mob/living/user,var/mob/living/target)
		if (!O || !user || !target)
			return 1
		O.add_fingerprint(user)
		ArtifactLogs(user, target, O, "weapon", null, 0)
		return 0

	/// What the artifact does after you clicked some tile with it when activated.
	/// Basically like afterattack() for activated artifacts.
	proc/effect_click_tile(var/obj/O,var/mob/living/user,var/turf/T)
		if (!O || !user || !T)
			return 1
		if (!user.in_real_view_range(T))
			return 1
		else if (!user.client && GET_DIST(T,user) > world.view) // idk, SOMEhow someone would find a way
			return 1
		O.add_fingerprint(user)
		if (!istype(O, /obj/item/artifact/attack_wand)) // Special log handling required there.
			ArtifactLogs(user, T, O, "used", "triggering its effect on target turf", 0)
		return 0

	/// Gets the trigger instance of this name if the artifact has that trigger.
	proc/get_trigger_by_string(var/string)
		if (!istext(string))
			return null
		for (var/datum/artifact_trigger/AT in src.triggers)
			if (AT.stimulus_required == string)
				return AT
		return null

	/// Gets the trigger instance of this type if the artifact has that trigger.
	proc/get_trigger_by_path(var/path)
		if (!ispath(path))
			return null
		for (var/datum/artifact_trigger/AT in src.triggers)
			if (AT.type == path)
				return AT
		return null

	/// The rarity modifier formula based on the types rarity_weight.
	/// This is used for stuff like the probability of an artifact being this type, or the price an artifact will fetch when sold.
	/// By the old Tier system this would be ~0.63 for a tier 4 artifact, ~0.1 for a tier 1 artifact
	proc/get_rarity_modifier()
		return src.rarity_weight ? 0.995**src.rarity_weight : 0.2

// SPECIFIC DATUMS

ABSTRACT_TYPE(/datum/artifact/art)
/datum/artifact/art
	validtypes = list("ancient","martian","wizard","eldritch","precursor")
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
	ks_ratio = 1
	sname = "energy bolt"
	shot_sound = 'sound/weapons/Taser.ogg'
	shot_number = 1
	damage_type = D_PIERCING
	armor_ignored = 0.66
	hit_ground_chance = 90
	window_pass = 0
	var/obj/machinery/artifact/turret/turretArt = null

	on_hit(atom/hit)
		if(turretArt && istype(hit, /mob/living/))
			turretArt.ArtifactFaultUsed(hit, src)
		return

	proc/randomise()
		icon_state = pick("spark","laser","ibeam","u_laser","phaser_heavy","phaser_light","phaser_med","phaser_ultra","blue_spark","disrupt","disrupt_lethal","radbolt","crescent",
		"goo","40mmgatling","elecorb","purple_orb","triple")
		src.shot_sound = pick('sound/weapons/Taser.ogg','sound/weapons/flaregun.ogg','sound/weapons/Laser.ogg','sound/weapons/laserheavy.ogg','sound/weapons/laserlight.ogg','sound/weapons/lasermed.ogg','sound/weapons/laserultra.ogg','sound/weapons/grenade.ogg','sound/weapons/rocket.ogg','sound/weapons/snipershot.ogg','sound/weapons/TaserOLD.ogg','sound/weapons/ACgun1.ogg','sound/weapons/ACgun2.ogg')
		var/namep1 = pick("neutrino","meson","photon","quark","disruptor","atomic","zero point","tachyon","plasma","quantum","neutron","baryon","hadron","electron","positron")
		var/namep2 = pick("bolt","ray","beam","wave","burst","blast","torpedo","missile","bomb","shard","stream","string")
		src.name = "[namep1] [namep2]"
		src.sname = src.name
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

	shot_volume = 66
	projectile_speed = 54

	randomise()
		. = ..()
		src.dissipation_rate = 0
		src.max_range = 13
		src.power = max(10, src.power)
		if(prob(90))
			src.ks_ratio = 1

	on_pre_hit(atom/hit, angle, obj/projectile/O)
		. = ..()
		if(ismob(hit) && ON_COOLDOWN(hit, "prismaticed", 1.5 SECONDS))
			. = TRUE

	New()
		..()
		src.randomise()
