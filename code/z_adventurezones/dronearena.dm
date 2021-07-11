/datum/projectile/bullet/bullet_22/se
	power = 20
	fullauto_valid = 1

	burst
		shot_number = 5
		cost = 5
		power = 15

	fire
		name = "incendiary bullet"
		power = 15

		on_hit(atom/hit, direction, obj/projectile/P)
			if (isliving(hit))
				fireflash(get_turf(hit), 0)
			else if (isturf(hit))
				fireflash(hit, 0)
			else
				fireflash(get_turf(hit), 0)

/obj/item/ammo/bullets/bullet_22/se13
	name = "SE13 .22 Magazine"
	amount_left = 21
	ammo_type = new/datum/projectile/bullet/bullet_22/se

	fire
		ammo_type = new/datum/projectile/bullet/bullet_22/se/fire
		name = "SE13 .22 Incendiary Magazine"

/obj/item/gun/kinetic/se13
	name = "SE13 Assault Rifle"
	desc = "Powerful assault rifle chambered in .22, A dragon is etched into the side of the barrel."
	icon = 'icons/obj/large/64x32.dmi'
	icon_state = "assault_rifle"
	force = 12
	caliber = 0.22
	max_ammo_capacity = 21
	auto_eject = TRUE
	two_handed = TRUE
	can_dual_wield = FALSE

	New()
		ammo = new/obj/item/ammo/bullets/bullet_22/se13
		set_current_projectile(new/datum/projectile/bullet/bullet_22/se)
		AddComponent(/datum/component/holdertargeting/fullauto, 0.35 SECONDS, 0.35 SECONDS, 1)
		..()

/obj/critter/gunbot/drone/arenadrone
	name = "Experimental Combat Drone SP332"
	desc = "A very powerful drone designed to guard syndicate bases. This one seems modified."
	health = 1750
	maxhealth = 3250
	attack_cooldown = 30
	projectile_type = /datum/projectile/bullet/bullet_22/se/burst
	current_projectile = new/datum/projectile/bullet/bullet_22/se/burst
	must_drop_loot = 1
	droploot = /obj/item/card/id/syndicate
	mats = 120

	New()
		..()
		name = "Experimental Combat Drone SP332"
		return

/obj/item/paper/dronearenafail
	name = "scribbled letter"
	icon_state = "paper"
	info ={"
	FOR THE LOVE OF GOD STOP FUCKING WITH THE DRONE<br>
	The last 2 times you "upgraded" the drone it went rouge and nearly killed us!<br>
	<br>"}

/obj/item/paper/dronearenanote
	name = "scribbled note"
	icon_state = "paper"
	info ={"
	In case of NT attack<br>
	1. Pick up the SE13 Assault Rifle on the table next to this note<br>
	2. Point at NT attackers<br>
	3. Pull the trigger until they are riddled with bullets<br>
	4. Reload if 1 magazine of ammo isnt enough to get rid of them<br>
	5. Put SE13 rifle back on the table<br>
	<br>"}

