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
	var/datum/projectile/projectile = null
	/// Override the gun's shoot sounds with this datum, if set
	var/datum/shoot_sounds/sounds = new/datum/shoot_sounds/test
	/// Whether or not the firemode'll let the gun shoot this click, for things like a single-action revolver
	var/can_shoot = 1
	/// The gun its attached to
	var/obj/item/gun/gunmaster = null

	New(var/obj/gun, name, spread, refire, proj)
		. = ..()
		if(gun)
			src.gunmaster = gun
		if(name)
			src.mode_name = name
		if(spread)
			src.spread_angle = spread
		if(refire)
			src.refire_delay = refire
		if(proj)
			src.projectile = proj

	/// Do this after the gun shoots, for things like toggling can_shoot or playing a done-shooting sound or something
	proc/after_shot(var/mob/user)
		return

	/// Do this when switching to this firemode, like showing a message or playing a sound
	proc/switch_to_firemode(var/mob/user, var/mode_changed = 1)
		if(!user) return
		user.visible_message("[user] switches [his_or_her(user)] [src.gunmaster] to [mode_name].")
		playsound(user.loc, "sound/machines/click.ogg", 20, 1)
		if(istype(src.projectile, /datum/projectile))
			boutput(user, "<span class='notice'>Each shot will use [src.projectile.cost] ammo units.</span>")
		return

	disposing()
		. = ..()
		src.gunmaster = null
		src.projectile = null

/datum/firemode/single
	mode_name = "single-shot"
	burst_count = 1

/datum/firemode/single/singleaction
	mode_name = "single-action"

	after_shot(var/mob/user)
		if(!can_shoot)
			playsound(user.loc, "sound/weapons/gun_cocked_colt45.ogg", 70, 1)
			user.visible_message("<span class='alert'><B>[user] cocks the [src.gunmaster]!</B></span>")
			can_shoot = 1
		else
			can_shoot = 0

/datum/firemode/single/singleaction/shotgun
	mode_name = "pump-action"

	after_shot(var/mob/user)
		if(!can_shoot)
			playsound(user.loc, "sound/weapons/shotgunpump.ogg", 70, 1)
			user.visible_message("<span class='alert'><B>[user] cocks the [src.gunmaster]!</B></span>")
			// make riotgun not auto-eject, put handle_casings here to eject the shell on KCHYKH
			can_shoot = 1
		else
			can_shoot = 0

/datum/firemode/double
	mode_name = "double-shot"
	burst_count = 2
	refire_delay = 2
	shoot_delay = 4
	spread_angle = 6

/datum/firemode/double/signifer
	mode_name = "double-shot"
	burst_count = 2
	refire_delay = 2
	shoot_delay = 4
	spread_angle = 6
	var/list/projectiles = list("A" = new/datum/projectile/laser/signifer_lethal,
															"B" = new/datum/projectile/laser/signifer_lethal/brute)
	var/proj_num = "A"

	after_shot(var/mob/user)
		if(!can_shoot)
			playsound(user.loc, "sound/weapons/shotgunpump.ogg", 70, 1)
			user.visible_message("<span class='alert'><B>[user] cocks the [src.gunmaster]!</B></span>")
			// make riotgun not auto-eject, put handle_casings here to eject the shell on KCHYKH
			can_shoot = 1
		else
			can_shoot = 0

/datum/firemode/triple
	mode_name = "three-round burst"
	burst_count = 3
	refire_delay = 1
	shoot_delay = 1 SECOND
	spread_angle = 12.5
	sounds = new/datum/shoot_sounds/test2

/datum/firemode/auto
	mode_name = "fully automatic"
	burst_count = 8
	refire_delay = 0.7
	shoot_delay = 1 SECOND
	spread_angle = 12.5

/datum/firemode/minigun_lowspeed
	mode_name = "low-speed"
	burst_count = 10
	refire_delay = 1.5
	shoot_delay = 4
	spread_angle = 12.5

/datum/firemode/minigun_highspeed
	mode_name = "high-speed"
	burst_count = 50
	refire_delay = 0.2
	shoot_delay = 4
	spread_angle = 30

/datum/firemode/lawbringer/detain
	mode_name = "detain"
	projectile = new/datum/projectile/energy_bolt/aoe

/datum/firemode/lawbringer/execute
	mode_name = "execute"
	projectile = new/datum/projectile/bullet/revolver_38/lawbringer

/datum/firemode/lawbringer/smokeshot
	mode_name = "smokeshot"
	projectile = new/datum/projectile/bullet/smoke/lawbringer

/datum/firemode/lawbringer/hotshot
	mode_name = "hotshot"
	projectile = new/datum/projectile/bullet/flare/lawbringer

/datum/firemode/lawbringer/knockout
	mode_name = "knockout"
	projectile = new/datum/projectile/bullet/tranq_dart/lawbringer

/datum/firemode/lawbringer/bigshot
	mode_name = "bigshot"
	projectile = new/datum/projectile/bullet/aex/lawbringer

/datum/firemode/lawbringer/clownshot
	mode_name = "clownshot"
	projectile = new/datum/projectile/bullet/clownshot

/datum/firemode/lawbringer/pulse
	mode_name = "pulse"
	projectile = new/datum/projectile/energy_bolt/pulse

	New()
		. = ..()
		if(prob(1))
			mode_name = pick("push", "pulsssssse")

/// Randomized on spawn, has its own initialized projectile
/datum/firemode/artgun
	var/list/action_list = list("slide", "twist", "force", "wrestle")
	var/list/part_adj_list = list("a smooth", "the smooth", "the top", "an invisible", "the corner-side")
	var/list/part_list = list("surface", "handle-nub", "protrusion", "groove")
	var/list/part_dest_list = list("backwards", "clockwise", "forward", "topwise", "inside itself")
	var/list/mode_prefix = list("uncanny","strange","dull","wavering","strobing","haunting","pleasant")
	var/list/mode_suffix = list("lights","pulsations","bumps","ridges","waves","vibrations","squiggles")
	var/action
	var/part_adj
	var/part
	var/part_dest
	var/number_thing

	New()
		. = ..()
		src.action = pick(action_list)
		src.part_adj = pick(part_adj_list)
		src.part = pick(part_list)
		src.part_dest = pick(part_dest_list)
		src.burst_count = rand(1, 3)
		src.refire_delay = rand(0.1, 10)
		src.shoot_delay = rand(0.1, 10)
		src.spread_angle = rand(0, 30)
		src.number_thing = rand(2, 20) * burst_count
		src.mode_name = "[pick(mode_prefix)] [pick(mode_suffix)]"

		var/datum/projectile/artifact/artbullet = new/datum/projectile/artifact
		artbullet = new/datum/projectile/artifact
		artbullet.randomise()
		// artifact tweak buff, people said guns were useless compared to their cells
		// the next 3 lines override the randomize(). Doing this instead of editting randomize to avoid changing prismatic spray.
		artbullet.power = rand(15,35) / burst_count // randomise puts it between 2 and 50, let's make it less variable
		artbullet.dissipation_rate = rand(1,artbullet.power)
		artbullet.cost = rand(35,100) / burst_count // randomise puts it at 50-150
		src.projectile = artbullet

	switch_to_firemode(var/mob/user, var/mode_changed = 1)
		if(!user) return
		if(mode_changed)
			user.visible_message("[user] [action]s [part_adj] [part] on the [src.gunmaster] [part_dest], engaging [number_thing] [mode_name].")
			playsound(user.loc, "sound/machines/click.ogg", 20, 1)
		else
			user.visible_message("[user] [action]s [part_adj] [part] on the [src.gunmaster] [part_dest], but nothing seemed to change!")
		return
