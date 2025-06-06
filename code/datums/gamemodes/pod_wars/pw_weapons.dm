///////////////////////////////////////PW Blasters
TYPEINFO(/obj/item/gun/energy/blaster_pod_wars)
	mats = 0

/obj/item/gun/energy/blaster_pod_wars
	name = "blaster pistol"
	desc = "A dangerous-looking blaster pistol. It's self-charging by a radioactive power cell."
	icon_state = "pw_pistol"
	item_state = "pw_pistol_nt"
	w_class = W_CLASS_NORMAL
	force = 8
	cell_type = /obj/item/ammo/power_cell/self_charging/pod_wars_basic

	var/image/indicator_display = null
	var/display_color =	"#00FF00"
	var/initial_proj = /datum/projectile/laser/blaster
	var/team_num = 0	//1 is NT, 2 is Syndicate

#if defined(MAP_OVERRIDE_POD_WARS)
	shoot(turf/target, turf/start, mob/user, POX, POY, is_dual_wield, atom/called_target = null)
		if (canshoot(user))
			if (team_num)
				if (team_num == get_pod_wars_team_num(user))
					return ..(target, start, user)
				else
					boutput(user, "[SPAN_ALERT("You don't have to right DNA to fire this weapon!")]<br>")
					playsound(get_turf(user), 'sound/machines/buzz-sigh.ogg', 20, 1)

					return
			else
				return ..(target, start, user)

	shoot_point_blank(atom/target, mob/user, second_shot)
		if (canshoot(user))
			if (team_num)
				if (team_num == get_pod_wars_team_num(user))
					return ..(target, user)
				else
					boutput(user, "[SPAN_ALERT("You don't have to right DNA to fire this weapon!")]<br>")
					playsound(get_turf(user), 'sound/machines/buzz-sigh.ogg', 20, 1)

					return
			else
				return ..(target, user, second_shot)
#endif

	disposing()
		indicator_display = null
		..()


	New()
		current_projectile = new initial_proj
		projectiles = list(current_projectile)
		src.indicator_display = image('icons/obj/items/guns/energy.dmi', "")
		if(istype(loc, /mob/living))
			RegisterSignal(loc, COMSIG_MOB_DEATH, PROC_REF(stop_charging))
		..()


	update_icon()
		..()
		// src.overlays = null
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			var/ratio = min(1, ret["charge"] / ret["max_charge"])
			ratio = round(ratio, 0.25) * 100
			if (ratio == 0)
				return
			indicator_display.icon_state = "[icon_state]_power-[ratio]" //using icon_state to set the charge icon? probably fine.
			indicator_display.color = display_color
			UpdateOverlays(indicator_display, "ind_dis")

	proc/stop_charging()
		var/turf/T = get_turf(src)
		var/fluff = pick("boop", "beep", "warble", "buzz", "bozzle", "wali", "hum", "whistle")
		T.visible_message(SPAN_NOTICE("[src] lets out a sad [fluff]"), SPAN_NOTICE("You hear a sad [fluff]"))
		src.can_swap_cell = 0
		src.rechargeable = 0

		AddComponent(/datum/component/cell_holder, list(null, null, 0), 0, null, 0)

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

/obj/item/gun/energy/blaster_pod_wars/smg
	name = "blaster smg"
	desc = "A dangerous-looking blaster smg. It's self-charging by a radioactive power cell."
	icon_state = "pw_smg"
	item_state = "pw_smg"
	w_class = W_CLASS_NORMAL
	force = 12
	cell_type = /obj/item/ammo/power_cell/self_charging/pod_wars_basic
	initial_proj = /datum/projectile/laser/blaster/pod_pilot/blue_NT/smg
	spread_angle = 10

	New()
		AddComponent(/datum/component/holdertargeting/fullauto, 2)
		..()
	nanotrasen
		muzzle_flash = "muzzle_flash_plaser"
		display_color =	"#3d9cff"
		item_state = "pw_smg_nt"
		initial_proj = /datum/projectile/laser/blaster/pod_pilot/blue_NT/smg
		team_num = 1


	syndicate
		muzzle_flash = "muzzle_flash_laser"
		display_color =	"#ff4043"
		item_state = "pw_smg_sy"
		initial_proj = /datum/projectile/laser/blaster/pod_pilot/red_SY/smg
		team_num = 2



/obj/item/gun/energy/blaster_pod_wars/shotgun
	name = "blaster shotgun"
	desc = "A dangerous-looking blaster shotgun. It's self-charging by a radioactive power cell."
	icon_state = "pw_shotgun"
	item_state = "pw_shotgun"
	w_class = W_CLASS_NORMAL
	force = 12
	initial_proj = /datum/projectile/special/spreader/pwshotgunspread
	cell_type = /obj/item/ammo/power_cell/self_charging/pod_wars_basic
	two_handed = 1
	can_dual_wield = 0
	shoot_delay = 8 DECI SECONDS

	nanotrasen
		muzzle_flash = "muzzle_flash_plaser"
		display_color =	"#3d9cff"
		item_state = "pw_shotgun_nt"
		initial_proj = /datum/projectile/special/spreader/pwshotgunspread/NT
		team_num = 1

	syndicate
		muzzle_flash = "muzzle_flash_laser"
		display_color =	"#ff4043"
		item_state = "pw_shotgun_sy"
		initial_proj = /datum/projectile/special/spreader/pwshotgunspread/SY
		team_num = 2

/obj/item/ammo/power_cell/higher_power
	name = "power cell - 500"
	desc = "A power cell that holds a max of 500PU"
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "power_cell"
	m_amt = 20000
	g_amt = 45000
	charge = 500
	max_charge = 500


/obj/item/ammo/power_cell/self_charging/pod_wars_basic
	name = "power cell - basic radioisotope"
	desc = "A power cell that contains a radioactive material and small capacitor that recharges at a modest rate. Holds 200PU."
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "recharger_cell"
	charge = 200
	max_charge = 200
	recharge_rate = 5

/obj/item/ammo/power_cell/self_charging/pod_wars_standard
	name = "power cell - standard radioisotope"
	desc = "A power cell that contains a radioactive material that recharges at a quick rate. Holds 300PU."
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "recharger_cell"
	charge = 300
	max_charge = 300
	recharge_rate = 8

/obj/item/ammo/power_cell/self_charging/pod_wars_high
	name = "power cell - robust radioisotope"
	desc = "A power cell that contains a radioactive material and large capacitor that recharges at a modest rate. Holds 350PU."
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "recharger_cell"
	charge = 350
	max_charge = 350
	recharge_rate = 15

//////////melee weapons//////////////
/obj/item/survival_machete
	name = "pilot survival machete"
	desc = "This peculularly shaped design was used by the Soviets nearly a century ago. It's also useful in space."
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "surv_machete_nt"
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	item_state = "surv_machete"
	force = 10
	throwforce = 15
	throw_range = 5
	hit_type = DAMAGE_STAB
	w_class = W_CLASS_SMALL
	flags = TABLEPASS | NOSHIELD | USEDELAY
	tool_flags = TOOL_CUTTING
	burn_remains = BURN_REMAINS_MELT
	stamina_damage = 25
	stamina_cost = 10
	stamina_crit_chance = 40
	pickup_sfx = 'sound/items/blade_pull.ogg'
	hitsound = 'sound/impact_sounds/Blade_Small_Bloody.ogg'

	New()
		..()
		BLOCK_SETUP(BLOCK_KNIFE)

/obj/item/survival_machete/NT
	icon_state = "surv_machete_nt"

/obj/item/survival_machete/SY
	icon_state = "surv_machete_sy"

/obj/item/survival_knife
	name = "pilot survival knife"
	desc = "A lightweight carbon steel knife that allows you to move faster in fights, colored for your stabbing pleasure."
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "surv_knife_nt"
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	item_state = "surv_machete" // they're already small inhands *shrug
	force = 6
	throwforce = 6
	throw_range = 7
	hit_type = DAMAGE_STAB
	w_class = W_CLASS_POCKET_SIZED
	flags = TABLEPASS | NOSHIELD | USEDELAY
	tool_flags = TOOL_CUTTING
	burn_remains = BURN_REMAINS_MELT
	stamina_damage = 15
	stamina_cost = 8
	stamina_crit_chance = 40
	pickup_sfx = 'sound/items/blade_pull.ogg'
	hitsound = 'sound/impact_sounds/Blade_Small_Bloody.ogg'

	setupProperties()
		..()
		setProperty("movespeed", -0.3)

/obj/item/survival_knife/NT
	icon_state = "surv_knife_nt"

/obj/item/survival_knife/SY
	icon_state = "surv_knife_sy"

/obj/item/survival_axe
	name = "pilot survival axe"
	desc = "An axe with a pick-shaped end on the back, intended to be used to get through doors or windows in an emergency, or the skull of your enemy also in an emergency. It's quite hefty."
	icon = 'icons/obj/items/weapons.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	icon_state = "surv_axe_nt"
	item_state = "surv_axe_nt"
	hitsound = null
	flags = CONDUCT | TABLEPASS | USEDELAY
	c_flags = ONBELT
	object_flags = NO_ARM_ATTACH
	tool_flags = TOOL_CUTTING | TOOL_CHOPPING //TOOL_CHOPPING flagged items do 4 times as much damage to doors.
	hit_type = DAMAGE_CUT
	leaves_slash_wound = TRUE
	click_delay = 10
	two_handed = 0

	w_class = W_CLASS_NORMAL
	force = 15
	var/one_handed_force = 15
	var/two_handed_force = 30
	throwforce = 15
	throw_speed = 2
	throw_range = 4
	stamina_damage = 25
	stamina_cost = 15
	stamina_crit_chance = 5

	setupProperties()
		..()
		setProperty("movespeed", 0.4)

	onVarChanged(variable, oldval, newval)
		. = ..()
		if (variable == "force")
			if (src.two_handed)
				src.two_handed_force = newval
			else
				src.one_handed_force = newval

	proc/set_values()
		if(two_handed)
			src.click_delay = COMBAT_CLICK_DELAY * 1.5
			force = src.two_handed_force
			throwforce = 25
			throw_speed = 4
			throw_range = 8
			stamina_damage = 45
			stamina_cost = 25
			stamina_crit_chance = 10
		else
			src.click_delay = COMBAT_CLICK_DELAY
			force = src.one_handed_force
			throwforce = 15
			throw_speed = 2
			throw_range = 4
			stamina_damage = 25
			stamina_cost = 15
			stamina_crit_chance = 5
		tooltip_rebuild = 1
		return

	attack_self(mob/user as mob)
		if(ishuman(user))
			if(two_handed)
				setTwoHanded(0) //Go 1-handed.
				set_values()
			else
				if(!setTwoHanded(1)) //Go 2-handed.
					boutput(user, SPAN_ALERT("Can't switch to 2-handed while your other hand is full."))
				else
					set_values()
		..()

	attack_hand(var/mob/user) // todo: maybe make the base/twohand delays into vars. maybe.
		src.two_handed = 0
		set_values()
		return ..()

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		..()
		// ugly but basically we make it louder and slightly downpitched if we're 2 handing
		playsound(target, 'sound/impact_sounds/Fireaxe.ogg', 30 * (1 + src.two_handed), pitch=(1 - 0.3 * src.two_handed))

	New()
		..()
		src.setItemSpecial(/datum/item_special/swipe)
		BLOCK_SETUP(BLOCK_ROD)

/obj/item/survival_axe/NT
	icon_state = "surv_axe_nt"

/obj/item/survival_axe/SY
	icon_state = "surv_axe_sy"
	item_state = "surv_axe_sy"

//basically like stinger in that it shoots projectiles, but has no explosions, different icon
/obj/item/old_grenade/energy_frag
	name = "blast grenade"
	desc = "It is set to detonate in 3 seconds."
	icon_state = "energy_stinger"
	det_time = 30
	org_det_time = 30
	alt_det_time = 60
	item_state = "fragnade"
	is_syndicate = 0
	sound_armed = 'sound/weapons/armbomb.ogg'
	icon_state_armed = "energy_stinger1"
	var/datum/projectile/custom_projectile_type = /datum/projectile/laser/blaster/blast
	var/pellets_to_fire = 10

	detonate()
		var/turf/T = ..()
		if (T)
			playsound(T, 'sound/weapons/grenade.ogg', 25, TRUE)
			var/datum/projectile/special/spreader/uniform_burst/circle/PJ = new(T)
			PJ.pellets_to_fire = src.pellets_to_fire
			if(src.custom_projectile_type)
				PJ.spread_projectile_type = src.custom_projectile_type
				PJ.pellet_shot_volume = 75 / PJ.pellets_to_fire
			//if you're on top of it, eat all the shots. Deal 1/4 damage per shot. Doesn't make sense logically, but w/e.
			var/mob/living/L = locate(/mob/living) in get_turf(src)
			if (istype(L))

				// var/datum/projectile/P = new PJ.spread_projectile_type		//dummy projectile to get power level
				L.TakeDamage("chest", 0, ((initial(custom_projectile_type.damage)/4)*pellets_to_fire)/L.get_ranged_protection(), 0, DAMAGE_BURN)
				L.emote("twitch_v")
			else
				shoot_projectile_ST_pixel_spread(get_turf(src), PJ, get_step(src, NORTH))
			SPAWN(0.1 SECONDS)
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
	det_time = 30
	org_det_time = 30
	alt_det_time = 60
	item_state = "fragnade"
	is_syndicate = 0
	sound_armed = 'sound/weapons/armbomb.ogg'
	icon_state_armed = "concussion1"

	detonate()
		var/turf/T = ..()
		if (T)
			playsound(T, 'sound/weapons/conc_grenade.ogg', 90, TRUE)
			var/obj/overlay/O = new/obj/overlay(get_turf(T))
			O.anchored = ANCHORED
			O.name = "Explosion"
			O.layer = NOLIGHT_EFFECTS_LAYER_BASE
			O.icon = 'icons/effects/64x64.dmi'
			O.icon_state = "explo_energy"
			O.pixel_x = -16
			O.pixel_y = -16

			//if you're on the tile directly.
			var/mob/living/L = locate(/mob/living) in get_turf(src)
			if (istype(L))
				L.do_disorient(stamina_damage = 120, knockdown = 60, stunned = 0, disorient = 0, remove_stamina_below_zero = 0)
				L.TakeDamage("chest", rand(20, 40)/max(1, L.get_melee_protection()), 0, 0, DAMAGE_BLUNT)
				L.emote("twitch_v")
			else

				for (var/atom/movable/A in orange(src, 3))
					var/turf/target = get_ranged_target_turf(A, get_dir(T, A), 10)
					//eh, another typecheck, no way around it I don't think. unless we wanna apply the status effect directly? idk.
					if (isliving(A))
						var/mob/living/M = A
						M.do_disorient(stamina_damage = 60, knockdown = 30, stunned = 0, disorient = 20, remove_stamina_below_zero = 0)
					if (target)
						A.throw_at(target, 10 - GET_DIST(src, A)*2, 1)		//throw things farther if they are closer to the epicenter.

			SPAWN(0.1 SECONDS)
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
