/// Weapon Firemodes
/datum/firemode
	/// Name of the firemode
	var/mode_name = "default firemode"
	/// Number of times to shoot per click
	var/burst_count = 1
	/// Time between shots in a burst
	var/refire_delay = 1 DECI SECOND
	/// Delay after clicking before it'll let you click with it again
	var/shoot_delay = 4 DECI SECONDS
	/// Shots will be flung somewhere within this angle
	var/spread_angle = 0
	/// Projectile to shoot. If null, it'll shoot whatever's in the gun's magazine
	var/projectile = null
	/// Override the gun's shoot sounds with this datum, if set
	var/datum/shoot_sounds/sounds = null
	/// Whether or not the firemode'll let the gun shoot this click, for things like a single-action revolver
	var/can_shoot = 1
	/// The gun its attached to
	var/obj/item/gun/gunmaster = null

	New(var/obj/gun)
		. = ..()
		if(gunmaster)
			src.gunmaster = gun

	/// Do this after the gun shoots, for things like toggling can_shoot or playing a done-shooting sound or something
	proc/after_shot(var/mob/user)
		return

	/// Do this when switching to this firemode, like showing a message or playing a sound
	proc/switch_to_firemode(var/mob/user)
		if(!user) return
		user.visible_message("[user] switches [his_or_her(user)] [src.gunmaster] to [mode_name].")
		playsound(user.loc, "sound/machines/click.ogg", 20, 1)
		return

/// These firemodes pull their projectiles from the gun's loaded magazine, so make sure whatever it's on gets one
/datum/firemode/null_proj

/datum/firemode/null_proj/single
	mode_name = "single-shot"
	burst_count = 1

/datum/firemode/null_proj/single/lmg
	spread_angle = 12.5

/datum/firemode/null_proj/single/singleaction
	mode_name = "single-action"

	after_shot(var/mob/user)
		if(!can_shoot)
			playsound(user.loc, "sound/weapons/gun_cocked_colt45.ogg", 70, 1)
			user.visible_message("<span class='alert'><B>[user] cocks the [src.gunmaster]!</B></span>")
			can_shoot = 1
		else
			can_shoot = 0

/datum/firemode/null_proj/single/singleaction/shotgun
	mode_name = "pump-action"

	after_shot(var/mob/user)
		if(!can_shoot)
			playsound(user.loc, "sound/weapons/shotgunpump.ogg", 70, 1)
			user.visible_message("<span class='alert'><B>[user] cocks the [src.gunmaster]!</B></span>")
			can_shoot = 1
		else
			can_shoot = 0

/datum/firemode/null_proj/double
	mode_name = "double-shot"
	burst_count = 2
	refire_delay = 2
	shoot_delay = 4
	spread_angle = 6

/datum/firemode/null_proj/triple
	mode_name = "three-round burst"
	burst_count = 3
	refire_delay = 1
	shoot_delay = 1 SECOND
	spread_angle = 12.5

/datum/firemode/null_proj/triple/pistol
	refire_delay = 0.7

/datum/firemode/null_proj/auto
	mode_name = "fully automatic"
	burst_count = 8
	refire_delay = 0.7
	shoot_delay = 1 SECOND
	spread_angle = 12.5

/datum/firemode/null_proj/minigun_lowspeed
	mode_name = "low-speed"
	burst_count = 10
	refire_delay = 1.5
	shoot_delay = 4
	spread_angle = 12.5

/datum/firemode/null_proj/minigun_highspeed
	mode_name = "high-speed"
	burst_count = 50
	refire_delay = 0.2
	shoot_delay = 4
	spread_angle = 30

/// These firemodes define their own projectile, ignoring whatever's loaded in the gun's magazine
/datum/firemode/own_proj
	mode_name = "single-shot"
	burst_count = 1
	refire_delay = 1 DECI SECOND
	shoot_delay = 4 DECI SECONDS
	spread_angle = 0
	projectile = null

/datum/firemode/own_proj/heavy_ion
	mode_name = "single-shot"
	projectile = /datum/projectile/heavyion

/datum/firemode/own_proj/taser
	mode_name = "stun"
	projectile = /datum/projectile/energy_bolt

/datum/firemode/own_proj/taser/flock
	mode_name = "si.ng.le.sh.ot"
	projectile = /datum/projectile/energy_bolt/flockdrone

/datum/firemode/own_proj/taser/shotgun
	mode_name = "shot-stun"
	projectile = /datum/projectile/special/spreader/tasershotgunspread

/datum/firemode/own_proj/taser/shotgun/single
	mode_name = "single-stun"
	projectile = /datum/projectile/energy_bolt/tasershotgun

/datum/firemode/own_proj/taser/bouncy
	projectile = /datum/projectile/energy_bolt/bouncy

/datum/firemode/own_proj/taser/horn
	mode_name = "BWAAAMMMP"
	projectile = /datum/projectile/energy_bolt_v

/datum/firemode/own_proj/taser/burst
	mode_name = "burst stun"
	burst_count = 3
	spread_angle = 12.5

/datum/firemode/own_proj/taser/burst/bouncy
	projectile = /datum/projectile/energy_bolt/bouncy

/datum/firemode/own_proj/taser/burst/nt
	projectile = /datum/projectile/energy_bolt/ntburst

/datum/firemode/own_proj/laser
	mode_name = "laser"
	projectile = /datum/projectile/laser

/datum/firemode/own_proj/laser/rifle
	projectile = /datum/projectile/laser/pred

/datum/firemode/own_proj/laser/alastor
	projectile = /datum/projectile/laser/alastor

/datum/firemode/own_proj/laser/burst
	mode_name = "burst laser"
	burst_count = 3
	spread_angle = 12.5

/datum/firemode/own_proj/laser/burst/rifle
	refire_delay = 3 DECI SECONDS
	projectile = /datum/projectile/laser/pred

/datum/firemode/own_proj/laser/burst/nt
	projectile = /datum/projectile/laser/ntburst

/datum/firemode/own_proj/laser/vr
	mode_name = "xX-14z0r-Xx"
	projectile = /datum/projectile/laser/virtual

/datum/firemode/own_proj/phaser
	mode_name = "phaser"
	projectile = /datum/projectile/laser/light

/datum/firemode/own_proj/radbow
	mode_name = "irradiate"
	projectile = /datum/projectile/rad_bolt

/datum/firemode/own_proj/crab
	mode_name = "crab"
	projectile = /datum/projectile/claw

/datum/firemode/own_proj/disruptor
	mode_name = "disrupt"
	projectile = /datum/projectile/disruptor

/datum/firemode/own_proj/disruptor/super
	mode_name = "super-disrupt"
	projectile = /datum/projectile/disruptor/high

/datum/firemode/own_proj/disruptor/burst
	mode_name = "burst-disrupt"
	burst_count = 3
	spread_angle = 12.5

/datum/firemode/own_proj/wave
	mode_name = "inverse"
	projectile = /datum/projectile/wavegun

/datum/firemode/own_proj/wave/transverse
	mode_name = "transverse"
	projectile = /datum/projectile/wavegun/transverse

/datum/firemode/own_proj/wave/emp
	mode_name = "electromagnetoverse"
	projectile = /datum/projectile/wavegun/emp

/datum/firemode/own_proj/bfg
	mode_name = "obliterate"
	projectile = /datum/projectile/bfg

/datum/firemode/own_proj/teleport
	mode_name = "teleport"
	projectile = /datum/projectile/tele_bolt

/datum/firemode/own_proj/ghost_gun
	mode_name = "bust"
	projectile = /datum/projectile/energy_bolt_antighost

/datum/firemode/own_proj/blaster
	mode_name = "blast"
	projectile = /datum/projectile/laser/blaster

/datum/firemode/own_proj/blaster/burst
	mode_name = "burst-blast"
	burst_count = 3
	spread_angle = 12.5

/datum/firemode/own_proj/blaster/shotgun
	mode_name = "shot-blast"
	projectile = /datum/projectile/special/spreader/uniform_burst/blaster

/datum/firemode/own_proj/owl
	mode_name = "owl"
	projectile = /datum/projectile/owl

/datum/firemode/own_proj/owl/er
	mode_name = "owler"
	projectile = /datum/projectile/owl/owlate

/datum/firemode/own_proj/owl/wonk
	mode_name = "wonk"
	projectile = /datum/projectile/wonk

/datum/firemode/own_proj/frog
	mode_name = ":getin:"
	projectile = /datum/projectile/bullet/frog

/datum/firemode/own_proj/frog/out
	mode_name = ":getout:"
	projectile = /datum/projectile/bullet/frog/getout

/datum/firemode/own_proj/shrink
	mode_name = "shrink"
	projectile = /datum/projectile/shrink_beam

/datum/firemode/own_proj/shrink/grow
	mode_name = "grow"
	projectile = /datum/projectile/shrink_beam/grow

/datum/firemode/own_proj/glitch
	mode_name = "boutput(usr, \[src.firemodes\[src.firemode_index\].mode_name\])"
	projectile = /datum/projectile/bullet/glitch/gun

/datum/firemode/own_proj/pickpocket/steal
	mode_name = "steal"
	projectile = /datum/projectile/pickpocket/steal

/datum/firemode/own_proj/pickpocket/plant
	mode_name = "plant"
	projectile = /datum/projectile/pickpocket/plant

/datum/firemode/own_proj/pickpocket/harass
	mode_name = "harass"
	projectile = /datum/projectile/pickpocket/harass

/datum/firemode/own_proj/lawbringer/detain
	mode_name = "detain"
	projectile = /datum/projectile/energy_bolt/aoe

/datum/firemode/own_proj/lawbringer/execute
	mode_name = "execute"
	projectile = /datum/projectile/bullet/revolver_38/lawbringer

/datum/firemode/own_proj/lawbringer/smokeshot
	mode_name = "smokeshot"
	projectile = /datum/projectile/bullet/smoke/lawbringer

/datum/firemode/own_proj/lawbringer/hotshot
	mode_name = "hotshot"
	projectile = /datum/projectile/bullet/flare/lawbringer

/datum/firemode/own_proj/lawbringer/knockout
	mode_name = "knockout"
	projectile = /datum/projectile/bullet/tranq_dart/lawbringer

/datum/firemode/own_proj/lawbringer/bigshot
	mode_name = "bigshot"
	projectile = /datum/projectile/bullet/aex/lawbringer

/datum/firemode/own_proj/lawbringer/clownshot
	mode_name = "clownshot"
	projectile = /datum/projectile/bullet/clownshot

/datum/firemode/own_proj/lawbringer/pulse
	mode_name = "pulse"
	projectile = /datum/projectile/energy_bolt/pulse

	New()
		. = ..()
		if(prob(1))
			mode_name = pick("push", "pulsssssse")

/datum/firemode/own_proj/wasp
	mode_name = "wasp"
	projectile = /datum/projectile/special/spreader/quadwasp

/datum/firemode/own_proj/plasma_howitzer
	mode_name = "single-shot"
	projectile = /datum/projectile/special/howitzer

/datum/firemode/own_proj/reagent
	mode_name = "single-shot"
	projectile = /datum/projectile/syringe

/datum/firemode/own_proj/reagent/ectoplasm
	mode_name = "15-units"
	projectile = /datum/projectile/ectoblaster

/datum/firemode/own_proj/tommy
	mode_name = "fully autommytic"
	projectile = /datum/projectile/tommy

/datum/firemode/own_proj/trump
	mode_name = "violate rule 5"
	projectile = /datum/projectile/energy_bolt_v/trumpet



	//
