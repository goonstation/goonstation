///////////////////////////////////////PW Blasters
/obj/item/gun/energy/blaster_pod_wars
	name = "blaster pistol"
	desc = "A dangerous-looking blaster pistol. It's self-charging by a radioactive power cell."
	icon = 'icons/obj/items/gun.dmi'
	icon_state = "pw_pistol"
	item_state = "pw_pistol_nt"
	w_class = 3.0
	force = 8.0
	mats = 0

	var/image/indicator_display = null
	var/display_color =	"#00FF00"
	var/initial_proj = /datum/projectile/laser/blaster
	var/team_num = 0	//1 is NT, 2 is Syndicate

	shoot(var/target,var/start,var/mob/user)
		if (canshoot())
			if (team_num)
				if (team_num == get_pod_wars_team_num(user))
					return ..(target, start, user)
				else
					boutput(user, "<span class='alert'>You don't have to right DNA to fire this weapon!</span><br>")
					playsound(get_turf(user), "sound/machines/buzz-sigh.ogg", 20, 1)

					return
			else
				return ..(target, start, user)

	shoot_point_blank(mob/M, mob/user)
		if (canshoot())
			if (team_num)
				if (team_num == get_pod_wars_team_num(user))
					return ..(M, user)
				else
					boutput(user, "<span class='alert'>You don't have to right DNA to fire this weapon!</span><br>")
					playsound(get_turf(user), "sound/machines/buzz-sigh.ogg", 20, 1)

					return
			else
				return ..(M, user)

	disposing()
		indicator_display = null
		..()


	New()
		var/obj/item/ammo/power_cell/self_charging/pod_wars_basic/PC = new/obj/item/ammo/power_cell/self_charging/pod_wars_basic()
		cell = PC
		current_projectile = new initial_proj
		projectiles = list(current_projectile)
		src.indicator_display = image('icons/obj/items/gun.dmi', "")
		if(istype(loc, /mob/living))
			RegisterSignal(loc, COMSIG_MOB_DEATH, .proc/stop_charging)
		..()


	update_icon()
		..()
		// src.overlays = null

		if (src.cell)
			var/maxCharge = (src.cell.max_charge > 0 ? src.cell.max_charge : 0)
			var/ratio = min(1, src.cell.charge / maxCharge)
			ratio = round(ratio, 0.25) * 100
			if (ratio == 0)
				return
			indicator_display.icon_state = "pw_pistol_power-[ratio]"
			indicator_display.color = display_color
			UpdateOverlays(indicator_display, "ind_dis")

	proc/stop_charging()
		var/turf/T = get_turf(src)
		var/fluff = pick("boop", "beep", "warble", "buzz", "bozzle", "wali", "hum", "whistle")
		T.visible_message("<span class='notice'>[src] lets out a sad [fluff]</span>", "<span class='notice'>You hear a sad [fluff]</span>")
		src.can_swap_cell = 0
		src.rechargeable = 0
		if(istype(src.cell, /obj/item/ammo/power_cell/self_charging))
			var/obj/item/ammo/power_cell/self_charging/P = src.cell
			P.recharge_rate = 0

	nanotrasen
		muzzle_flash = "muzzle_flash_plaser"
		display_color =	"#3d9cff"
		item_state = "pw_pistol_nt"
		initial_proj = /datum/projectile/laser/blaster/pod_pilot/blue_NT
		team_num = 1

	syndicate
		muzzle_flash = "muzzle_flash_laser"
		display_color =	"#ff4043"
		item_state = "pw_pistol_sy"
		initial_proj = /datum/projectile/laser/blaster/pod_pilot/red_SY
		team_num = 2

/obj/item/ammo/power_cell/higher_power
	name = "Power Cell - 500"
	desc = "A power cell that holds a max of 500PU"
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "power_cell"
	m_amt = 20000
	g_amt = 45000
	charge = 500.0
	max_charge = 500.0


/obj/item/ammo/power_cell/self_charging/pod_wars_basic
	name = "Power Cell - Basic Radioisotope"
	desc = "A power cell that contains a radioactive material and small capacitor that recharges at a modest rate. Holds 200PU."
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "recharger_cell"
	charge = 200
	max_charge = 200
	recharge_rate = 10

/obj/item/ammo/power_cell/self_charging/pod_wars_standard
	name = "Power Cell - Standard Radioisotope"
	desc = "A power cell that contains a radioactive material that recharges at a quick rate. Holds 300PU."
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "recharger_cell"
	charge = 300
	max_charge = 300
	recharge_rate = 15

/obj/item/ammo/power_cell/self_charging/pod_wars_high
	name = "Power Cell - Robust Radioisotope "
	desc = "A power cell that contains a radioactive material and large capacitor that recharges at a modest rate. Holds 350PU."
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "recharger_cell"
	charge = 350
	max_charge = 350
	recharge_rate = 30

//////////survival_machete//////////////
/obj/item/survival_machete
	name = "pilot survival machete"
	desc = "This peculularly shaped design was used by the Soviets nearly a century ago. It's also useful in space."
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "surv_machete_nt"
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	item_state = "surv_machete"
	force = 10.0
	throwforce = 15.0
	throw_range = 5
	hit_type = DAMAGE_STAB
	w_class = 2.0
	flags = FPRINT | TABLEPASS | NOSHIELD | USEDELAY
	tool_flags = TOOL_CUTTING
	burn_type = 1
	stamina_damage = 25
	stamina_cost = 10
	stamina_crit_chance = 40
	pickup_sfx = "sound/items/blade_pull.ogg"
	hitsound = 'sound/impact_sounds/Blade_Small_Bloody.ogg'

	New()
		..()
		BLOCK_SETUP(BLOCK_KNIFE)
	syndicate
		icon_state = "surv_machete_st"

//basically like stinger in that it shoots projectiles, but has no explosions, different icon
/obj/item/old_grenade/energy_frag
	name = "blast grenade"
	desc = "It is set to detonate in 3 seconds."
	icon_state = "energy_stinger"
	det_time = 30.0
	org_det_time = 30
	alt_det_time = 60
	item_state = "fragnade"
	is_syndicate = 0
	sound_armed = "sound/weapons/armbomb.ogg"
	icon_state_armed = "energy_stinger1"
	var/datum/projectile/custom_projectile_type = /datum/projectile/laser/blaster/blast
	var/pellets_to_fire = 10

	prime()
		var/turf/T = ..()
		if (T)
			playsound(T, "sound/weapons/grenade.ogg", 25, 1)
			var/datum/projectile/special/spreader/uniform_burst/circle/PJ = new(T)
			PJ.pellets_to_fire = src.pellets_to_fire
			if(src.custom_projectile_type)
				PJ.spread_projectile_type = src.custom_projectile_type
				PJ.pellet_shot_volume = 75 / PJ.pellets_to_fire
			//if you're on top of it, eat all the shots. Deal 1/4 damage per shot. Doesn't make sense logically, but w/e.
			var/mob/living/L = locate(/mob/living) in get_turf(src)
			if (istype(L))

				// var/datum/projectile/P = new PJ.spread_projectile_type		//dummy projectile to get power level
				L.TakeDamage("chest", 0, ((initial(custom_projectile_type.power)/4)*pellets_to_fire)/L.get_ranged_protection(), 0, DAMAGE_BURN)
				L.emote("twitch_v")
			else
				shoot_projectile_ST(get_turf(src), PJ, get_step(src, NORTH))
			SPAWN_DBG(0.1 SECONDS)
				qdel(src)
		else
			qdel(src)
		return

/obj/item/storage/box/energy_frag
	name = "\improper blast grenade box"
	desc = "A box with 5 blast grenade."
	icon_state = "flashbang"
	spawn_contents = list(/obj/item/old_grenade/energy_frag = 5)

/obj/item/old_grenade/energy_concussion
	name = "concussion grenade"
	desc = "It is set to detonate in 3 seconds."
	icon_state = "concussion"
	det_time = 30.0
	org_det_time = 30
	alt_det_time = 60
	item_state = "fragnade"
	is_syndicate = 0
	sound_armed = "sound/weapons/armbomb.ogg"
	icon_state_armed = "concussion1"

	prime()
		var/turf/T = ..()
		if (T)
			playsound(T, "sound/weapons/grenade.ogg", 25, 1)
			var/obj/overlay/O = new/obj/overlay(get_turf(T))
			O.anchored = 1
			O.name = "Explosion"
			O.layer = NOLIGHT_EFFECTS_LAYER_BASE
			O.icon = 'icons/effects/64x64.dmi'
			O.icon_state = "explo_energy"
			O.pixel_x = -16
			O.pixel_y = -16

			//if you're on the tile directly.
			var/mob/living/L = locate(/mob/living) in get_turf(src)
			if (istype(L))
				L.do_disorient(stamina_damage = 120, weakened = 60, stunned = 0, disorient = 0, remove_stamina_below_zero = 0)
				L.TakeDamage("chest", rand(20, 40)/max(1, L.get_melee_protection()), 0, 0, DAMAGE_BLUNT)
				L.emote("twitch_v")
			else

				for (var/atom/movable/A in orange(src, 3))
					var/turf/target = get_ranged_target_turf(A, get_dir(T, A), 10)
					//eh, another typecheck, no way around it I don't think. unless we wanna apply the status effect directly? idk.
					if (isliving(A))
						var/mob/living/M = A
						M.do_disorient(stamina_damage = 60, weakened = 30, stunned = 0, disorient = 20, remove_stamina_below_zero = 0)
					if (target)
						A.throw_at(target, 10 - get_dist(src, A)*2, 1)		//throw things farther if they are closer to the epicenter.

			SPAWN_DBG(0.1 SECONDS)
				qdel(O)
				qdel(src)
		else
			qdel(src)
		return

/obj/item/storage/box/energy_concussion
	name = "\improper concussion grenade box"
	desc = "A box with 5 concussion grenade."
	icon_state = "flashbang"
	spawn_contents = list(/obj/item/old_grenade/energy_concussion = 5)
