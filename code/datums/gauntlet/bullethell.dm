/proc/proj_tracer_tick(var/obj/projectile/O)
	var/update = 0
	if (!("lastloc" in O.special_data))
		update = 1
	else if (O.special_data["lastloc"] != O.loc)
		update = 1
	if (update)
		var/ocl = length(O.crossing)
		if (!ocl)
			return
		if ("1" in O.special_data)
			var/turf/T = O.special_data["1"]
			T.color = null
		if ("2" in O.special_data)
			var/turf/T = O.special_data["2"]
			T.color = null
		if ("3" in O.special_data)
			var/turf/T = O.special_data["3"]
			T.color = null
		O.special_data["lastloc"] = O.loc
		if (ocl > 0)
			var/turf/T1 = O.crossing[1]
			O.special_data["1"] = T1
			T1.color = "#ff0000"
			if (ocl > 1)
				var/turf/T2 = O.crossing[2]
				O.special_data["2"] = T2
				T2.color = "#cc0000"
				if (ocl > 2)
					var/turf/T3 = O.crossing[3]
					O.special_data["3"] = T3
					T3.color = "#990000"

/proc/proj_tracer_on_end(var/obj/projectile/O)
	if ("1" in O.special_data)
		var/turf/T = O.special_data["1"]
		T.color = null
	if ("2" in O.special_data)
		var/turf/T = O.special_data["2"]
		T.color = null
	if ("3" in O.special_data)
		var/turf/T = O.special_data["3"]
		T.color = null

/datum/projectile/laser/light/tracer
	tick(var/obj/projectile/O)
		proj_tracer_tick(O)

	on_end(var/obj/projectile/O)
		proj_tracer_on_end(O)

	projectile_speed = 24
	damage = 30
	dissipation_delay = 8
	dissipation_rate = 5

/obj/bullethell
	name = "Bulletron"
	desc = "fuck shit fuck fuck fuck FUCK jesus pixel perfect ungh"
	var/image/shield_overlay
	var/image/invincible_overlay
	var/health = 150
	var/armor = 150
	var/shield = 150
	var/max_shield = 150
	var/max_armor = 150
	var/max_health = 150

	var/overlay_status = 0

	var/shield_regen_ticks = 10
	var/shield_regen_per_tick = 5
	var/last_damage = 0

	var/invulnerability = 0
	var/invulnerable_on_transition = 0

	var/disruptible = 0
	var/disrupted = 0

	var/datum/projectile/proj = new/datum/projectile/laser/light/tracer

	var/list/maxticks = list()
	var/list/schedules = list()
	var/list/healths = list()
	var/current_schedule = 1
	var/tick_at = 1
	var/pause_between_reset = 5

	var/test_sleep_time = 8
	var/live_sleep_time = 4
	var/live_cycles = 1
	var/broken = 1

	anchored = ANCHORED
	density = 1
	icon = 'icons/obj/bots/aibots.dmi'
	icon_state = "secbot1"

	var/datum/action/bar/bullethell/healthbar //Hack.
	var/list/dirs = list("NORTH" = NORTH, "SOUTH" = SOUTH, "WEST" = WEST, "EAST" = EAST, "NORTHWEST" = NORTHWEST, "NORTHEAST" = NORTHEAST, "SOUTHWEST" = SOUTHWEST, "SOUTHEAST" = SOUTHEAST)

	New()
		..()
		setup_schedules()
		setup_maxticks()
		shield_overlay = image('icons/effects/effects.dmi', "enshield")
		invincible_overlay = image('icons/obj/colosseum.dmi', "iron_curtain")
		if (healths.len != schedules.len)
			broken = 1
		healthbar = new
		healthbar.owner = src
		healthbar.onStart()
		healthbar.onUpdate()

	proc/setup_schedules()

	proc/setup_maxticks()
		maxticks.len = 0
		for (var/list/S in schedules)
			var/mt = 0
			for (var/tk in S)
				var/tkn = text2num(tk)
				if (tkn > mt)
					mt = tkn
			mt += pause_between_reset
			maxticks += mt

	proc/process()
		if (broken)
			return
		for (var/cycle = 0, cycle < live_cycles, cycle++)
			var/hsa = health + shield + armor
			while (current_schedule < healths.len && hsa < healths[current_schedule])
				current_schedule++
				invulnerability = invulnerable_on_transition
				tick_at = 1
			if (schedules.len < current_schedule)
				broken = 1
				message_coders("Marquesas/Bullethell: We broke due to veering off schedule.")
				return
			if (maxticks.len < current_schedule)
				broken = 1
				message_coders("Marquesas/Bullethell: We broke due to veering off schedule <maxticks>.")
				return
			if (invulnerability)
				invulnerability--
			if (last_damage < shield_regen_ticks)
				last_damage++
			else
				shield = min(shield + shield_regen_per_tick, max_shield)
			var/list/schedule = schedules[current_schedule]
			var/stick = "[tick_at]"
			if (stick in schedule)
				var/list/elements = schedule[stick]
				for (var/E in elements)
					if (isnum(E))
						var/dx = cos(E)
						var/dy = sin(E)
						shoot_projectile_XY(src, proj, dx, dy)
					else if (ispath(E, /datum/projectile))
						proj = new E
					else if (E == "invulnerable")
						invulnerability = 1
					else if (E == "RANDSTEP")
						step(src, src.dirs[pick(src.dirs)])
					else
						step(src, src.dirs[E])
			update_overlays()
			healthbar.onUpdate()
			tick_at++
			if (tick_at > maxticks[current_schedule])
				tick_at = 1
			if (cycle != live_cycles - 1)
				sleep(live_sleep_time)

	proc/update_overlays()
		if (invulnerability)
			if (overlay_status != 2)
				overlays.len = 0
				overlays += invincible_overlay
				overlay_status = 2
		else if (shield)
			if (overlay_status != 1)
				overlays.len = 0
				overlays += shield_overlay
				overlay_status = 1
		else
			if (overlay_status != 0)
				overlays.len = 0
				overlay_status = 0

	proc/test()
		SPAWN(0)
			while (!broken)
				process()
				sleep(test_sleep_time)

#define DT_NORMAL 1
#define DT_PIERCE 2
#define DT_BURN   3
#define DT_CORR   4
#define DT_ENERGY  5
	bullet_act(var/obj/projectile/O)
		var/datum/projectile/P = O.proj_data
		var/damage = O.power * P.ks_ratio
		var/damtype = DT_NORMAL
		switch (P.damage_type)
			if (D_PIERCING)
				damtype = DT_PIERCE
			if (D_ENERGY)
				damtype = DT_ENERGY
			if (D_BURNING)
				damtype = DT_BURN
			if (D_RADIOACTIVE)
				damtype = DT_CORR
			if (D_TOXIC)
				damtype = DT_CORR
		take_damage(damage, damtype)

	proc/take_damage(var/damage, var/damtype)
		if (invulnerability)
			return
		last_damage = 0
		var/act_damage = damage
		var/mult = 1
		if (shield > 0)
			if (damtype == DT_NORMAL || damtype == DT_PIERCE)
				act_damage *= 0.5
				mult = 0.5
			else if (damtype == DT_ENERGY)
				act_damage *= 2
				mult = 2
			if (shield < act_damage)
				shield = 0
				damage -= act_damage / mult
				take_damage(damage, damtype)
			else
				shield -= act_damage
			update_overlays()
			healthbar.onUpdate()
			return
		if (armor > 0)
			if (damtype == DT_NORMAL)
				act_damage *= 0.75
				mult = 0.75
			else if (damtype == DT_BURN || damtype == DT_PIERCE)
				act_damage *= 2
				mult = 2
			if (armor < act_damage)
				armor = 0
				damage -= act_damage / mult
				take_damage(damage, damtype)
			else
				armor -= act_damage
			update_overlays()
			healthbar.onUpdate()
			return
		if (damtype == DT_ENERGY)
			act_damage *= 0.5
		health -= act_damage
		update_overlays()
		healthbar.onUpdate()
		if (health <= 0)
			die()

	attackby(obj/item/W, mob/user)
		var/damtype = DT_NORMAL

		if (W.hit_type == DAMAGE_BURN)
			damtype = DT_BURN
		else if (W.hit_type == DAMAGE_CUT || W.hit_type == DAMAGE_STAB)
			damtype = DT_PIERCE
		take_damage(W.force, damtype)
		..()

	proc/die()
		qdel(src)

#undef DT_CORR
#undef DT_BURN
#undef DT_PIERCE
#undef DT_NORMAL

/obj/bullethell/test1
	broken = 0
	healths = list(0)
	pause_between_reset = 0

	setup_schedules()
		var/t = list()
		for (var/i = 0, i < 15, i++)
			t["[i+1]"] = list(i * 6, i * 6 + 90, i * 6 + 180, i * 6 + 270)
		schedules = list(t)

/obj/bullethell/test2
	broken = 0
	healths = list(300, 0)
	pause_between_reset = 0

	setup_schedules()
		var/t = list()
		var/t2 = list()
		for (var/i = 0, i < 10, i++)
			t["[(i+1)*2]"] = list(i * 6, i * 6 + 60, i * 6 + 120, i * 6 + 180, i * 6 + 240, i * 6 + 300)
			t2["[i+1]"] = list(i * 6, i * 6 + 60, i * 6 + 120, i * 6 + 180, i * 6 + 240, i * 6 + 300)
		schedules = list(t, t2)

/obj/bullethell/test3
	broken = 0
	healths = list(0)
	pause_between_reset = 0

	setup_schedules()
		var/t = list()
		for (var/i = 0, i < 20, i++)
			if (i < 10)
				t["[i+1]"] = list(i * 9, i * 9 + 90, i * 9 + 180, i * 9 + 270)
			else
				var/j = 20 - i
				t["[i+1]"] = list(j * 9, j * 9 + 90, j * 9 + 180, j * 9 + 270)
		schedules = list(t)

/obj/bullethell/test4
	broken = 0
	healths = list(0)
	pause_between_reset = 0
	live_sleep_time = 1
	test_sleep_time = 1

	setup_schedules()
		var/t = list()
		for (var/i = 0, i < 60, i++)
			t["[i+1]"] = list(i * 6)
		for (var/i = 0, i < 5, i++)
			t["[i+61]"] = list("invulnerable")
		for (var/i = 0, i < 60, i++)
			t["[i+66]"] = list(360 - (i * 6))
		for (var/i = 0, i < 5, i++)
			t["[i+126]"] = list("invulnerable")
		schedules = list(t)

/obj/bullethell/test5
	broken = 0
	healths = list(300, 0)
	pause_between_reset = 0

	setup_schedules()
		var/t = list()
		var/t2 = list()
		for (var/i = 0, i < 10, i++)
			if (i % 2 == 0)
				t["[(i+1)*2]"] = list(i * 6, i * 6 + 60, i * 6 + 120, i * 6 + 180, i * 6 + 240, i * 6 + 300)
				t2["[i+1]"] = list(i * 6, i * 6 + 60, i * 6 + 120, i * 6 + 180, i * 6 + 240, i * 6 + 300)
			else
				t["[(i+1)*2]"] = list(i * 6, i * 6 + 60, i * 6 + 120, i * 6 + 180, i * 6 + 240, i * 6 + 300, "RANDSTEP")
				t2["[i+1]"] = list(i * 6, i * 6 + 60, i * 6 + 120, i * 6 + 180, i * 6 + 240, i * 6 + 300, "RANDSTEP")
		schedules = list(t, t2)

/obj/bullethell/test6
	broken = 0
	healths = list(300, 0)
	pause_between_reset = 0
	proj = new/datum/projectile/laser/light/spiral

	setup_schedules()
		var/t = list()
		var/t2 = list()
		for (var/i = 0, i < 10, i++)
			t["[i+1]"] = list(i * 9, i * 9 + 90, i * 9 + 180, i * 9 + 270)
			t2["[i+1]"] = list(i * 6, i * 6 + 60, i * 6 + 120, i * 6 + 180, i * 6 + 240, i * 6 + 300)
		schedules = list(t, t2)
