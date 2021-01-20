/*var/const/PHASER_EMP = 1
var/const/PHASER_FLASH = 2
var/const/PHASER_TOXINS = 4
var/const/PHASER_BURN = 8
var/const/PHASER_SING = 16
var/const/PHASER_CONC = 512

var/const/PHASER_ENERGY = 32
var/const/PHASER_RADIUS = 64
var/const/PHASER_HOMING = 128
var/const/PHASER_SNIPER = 256

/obj/phaser_projectile
	name = "Energy"
	desc = "Looks dangerous."
	density = 0
	opacity = 0
	anchored = 1
	icon = 'icons/obj/projectiles.dmi'
	var/mob/origin = null
	var/list/impactsounds = new/list()
	var/power = 0
	var/damage = 0
	var/range = 0
	var/stun = 0
	var/upgrades = 0
	var/turf/dest = null
	flags = TABLEPASS

/obj/mod_spawner
	icon = 'icons/misc/mark.dmi'
	icon_state = "rup"
	New()
		var/A = pick(typesof(/obj/item/gun_ext)-/obj/item/gun_ext)
		new A (src.loc)
		qdel(src)

/obj/item/gun_ext
	var/overlay_name = ""
	var/upgrade = null
	var/location = null
	name = "Phaser extension"
	desc = "For use with phasers"
	item_state = "table_parts"
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	icon = 'icons/obj/items/gun.dmi'
	var/proj_mod = null
	var/proj_sound = null
	var/proj_sound_impact = null
	mats = 8

/obj/item/gun_ext/sniper
	name = "Phaser extension (sniper)"
	desc = "Massively increases energy usage and damage. Also disables the radius setting."
	overlay_name = "ext_sniper"
	upgrade = PHASER_SNIPER
	location = "ext"
	icon_state = "add_sniper"
	proj_sound = 'sound/weapons/snipershot.ogg'

/obj/item/gun_ext/battery
	name = "Phaser extension (battery)"
	desc = "Increases battery maximum but slightly reduces damage."
	overlay_name = "ext_battery"
	upgrade = PHASER_ENERGY
	location = "ext"
	icon_state = "add_battery"

/obj/item/gun_ext/homing
	name = "Phaser extension (homing)"
	desc = "Decreases battery maximum and increases energy usage but gives shots a slight homing ability."
	overlay_name = "ext_focus"
	upgrade = PHASER_HOMING
	location = "ext"
	icon_state = "add_homing"

/obj/item/gun_ext/thermal
	name = "Phaser energy-converter mod (thermal)"
	desc = "Decreases energy usage but causes burn damage instead of brute damage."
	overlay_name = "conv_thermal"
	upgrade = PHASER_BURN
	location = "conv"
	icon_state = "add_thermal"
	proj_mod = "proj_thermal"

/obj/item/gun_ext/sing
	name = "Phaser energy-converter mod (micro-singularity)"
	desc = "Increases energy usage and decreases damage but pulls nearby targets in."
	overlay_name = "conv_sing"
	upgrade = PHASER_SING
	location = "conv"
	icon_state = "add_sing"
	proj_mod = "proj_sing"
	proj_sound_impact = 'sound/effects/singsuck.ogg'

/obj/item/gun_ext/toxin
	name = "Phaser energy-converter mod (toxin)"
	desc = "Increases energy usage but causes toxin damage instead of brute damage and adds additional damage over time."
	overlay_name = "conv_tox"
	upgrade = PHASER_TOXINS
	location = "conv"
	icon_state = "add_tox"
	proj_mod = "proj_tox"

/obj/item/gun_ext/flash
	name = "Phaser energy-converter mod (flash)"
	desc = "Greatly reduces damage and stun time but causes each hit to blind the target temporarily."
	overlay_name = "conv_flash"
	upgrade = PHASER_FLASH
	location = "conv"
	icon_state = "add_flash"
	proj_mod = "proj_flash"

/obj/item/gun_ext/emp
	name = "Phaser energy-converter mod (EMP)"
	desc = "Increases damage against synthetic lifeforms but slightly increases energy usage."
	overlay_name = "conv_emp"
	upgrade = PHASER_EMP
	location = "conv"
	icon_state = "add_emp"
	proj_mod = "proj_emp"

/obj/item/gun_ext/conc
	name = "Phaser energy-converter mod (concussion)"
	desc = "Disables stuns and reduces damage but knocks target back on hit."
	overlay_name = "conv_conc"
	upgrade = PHASER_CONC
	location = "conv"
	icon_state = "add_conc"
	proj_mod = "proj_conc"

/obj/item/oldgun
	name = "gun"
	icon = 'icons/obj/items/gun.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	flags =  FPRINT | TABLEPASS | CONDUCT | ONBELT | EXTRADELAY
	item_state = "gun"
	m_amt = 2000
	throwforce = 5
	w_class = 2.0
	throw_speed = 4
	throw_range = 10

/obj/item/oldgun/energy
	name = "energy"
	var/charges = 10.0
	var/maximum_charges = 10.0
	var/unscrewed = 0
	mats = 15

/obj/item/oldgun/energy/phaser/secure
	safeties = 1
	name = "locked phaser"

/obj/item/oldgun/energy/phaser
	name = "phaser"
	icon_state = "phaser"
	desc = "Set phasers to 'Robust'"
	w_class = 3.0
	item_state = "gun"
	force = 10.0
	throw_speed = 2
	throw_range = 10

	var/obj/item/gun_ext/extension_mod = null
	var/obj/item/gun_ext/converter_mod = null
	var/list/shot_overlays = new/list()
	var/list/shot_firesounds = new/list()
	var/list/shot_impactsounds = new/list()

	var/upgrades = 0

	charges = 125
	maximum_charges = 125

	var/charges_per_shot = 0
	var/safeties = 0

	var/prop_dmg = 0
	var/prop_stun = 0
	var/prop_range = 0
	var/prop_maxrange = 1
	var/prop_power = 10
	var/prop_iconstate = ""
	var/prop_sound = 'sound/weapons/Taser.ogg'

	var/overloading = 0

	verb/remove_mods()
		set src in usr
		set name = "Remove Mods"
		if(!src.contents.len)
			boutput(usr, "<span class='alert'>No mods to remove.</span>")
			return
		boutput(usr, "<span class='notice'>You remove all mods.</span>")
		for(var/obj/O in src)
			O.set_loc(get_turf(src))
		var/obj/item/oldgun/energy/phaser/P = new/obj/item/oldgun/energy/phaser(get_turf(src))
		var/energy_old = min(125,src.charges)
		P.safeties = src.safeties
		P.charges = energy_old
		P.update_icon()
		qdel(src)

	examine()
		set src in view()
		if(src.contents.len)
			boutput(usr, "<span class='notice'>Installed mods:</span>")
			boutput(usr, "")
			for(var/obj/O in src)
				boutput(usr, "<span class='notice'>[O.name]</span>")
				boutput(usr, "<span class='notice'>[O.desc]</span>")
				boutput(usr, "")
		..()

	New()
		update_settings()
		..()

	proc/generate_overlays()
		src.overlays = null
		if(extension_mod)
			src.overlays += icon('icons/obj/items/gun.dmi',extension_mod.overlay_name)
		if(converter_mod)
			src.overlays += icon('icons/obj/items/gun.dmi',converter_mod.overlay_name)

	attackby(obj/O as obj, mob/user as mob)
		if (istype(O,/obj/item/gun_ext))
			var/obj/item/gun_ext/G = O
			switch(G.location)
				if("ext")
					if(extension_mod)
						boutput(user, "<span class='alert'>There is already a gun extension installed.</span>")
					else
						user.drop_item()
						boutput(user, "<span class='notice'>You install the gun extension.</span>")
						playsound(user, "sound/items/Screwdriver2.ogg", 65, 1)
						G.set_loc(src)
						extension_mod = G
						generate_overlays()
						upgrades |= G.upgrade
						if(G.proj_mod) shot_overlays += G.proj_mod
						if(G.proj_sound) shot_firesounds += G.proj_sound
						if(G.proj_sound_impact) shot_impactsounds += G.proj_sound_impact
						update_settings()
				if("conv")
					if(converter_mod)
						boutput(user, "<span class='alert'>There is already an energy-converter mod installed.</span>")
					else
						user.drop_item()
						boutput(user, "<span class='notice'>You install the energy-converter mod.</span>")
						playsound(user, "sound/items/Screwdriver2.ogg", 65, 1)
						G.set_loc(src)
						converter_mod = G
						generate_overlays()
						upgrades |= G.upgrade
						if(G.proj_mod) shot_overlays += G.proj_mod
						if(G.proj_sound) shot_firesounds += G.proj_sound
						if(G.proj_sound_impact) shot_impactsounds += G.proj_sound_impact
						update_settings()

	proc/update_settings()
		var/dmg_mod = 0
		var/stun_mod = 0
		var/cost_mod = 0
		if(overloading) return

		if(upgrades & PHASER_ENERGY)
			maximum_charges = 175
		else if((upgrades & PHASER_RADIUS) || (upgrades & PHASER_HOMING))
			maximum_charges = 100
			charges = min(100,charges)
		else
			maximum_charges = 125

		if(upgrades & PHASER_RADIUS)
			prop_maxrange = 2
		else
			prop_maxrange = 1

		switch(prop_power)
			if(1 to 33)
				prop_iconstate = "phaser_light"
				dmg_mod = -round(prop_power/6)
				stun_mod = min(round(prop_power/4),4)
				prop_sound = 'sound/weapons/laserlight.ogg'
			if(34 to 66)
				prop_iconstate = "phaser_med"
				dmg_mod = 1
				stun_mod = -round(prop_power/6)
				prop_sound = 'sound/weapons/lasermed.ogg'
			if(67 to 100)
				prop_iconstate = "phaser_heavy"
				dmg_mod = max(0,round(prop_power / 10)-2)
				stun_mod = -prop_power
				prop_sound = 'sound/weapons/laserheavy.ogg'
			if(101 to 150)
				prop_iconstate = "phaser_ultra"
				dmg_mod = max(0,round(prop_power / 10)-2) + 10
				stun_mod = -20
				cost_mod = max(0,round(prop_power / 10)-2)
				prop_sound = 'sound/weapons/laserultra.ogg'

		if(upgrades & PHASER_SNIPER)
			prop_range = 0
		prop_dmg = max(0, round(prop_power / 4)-(prop_range*5) + dmg_mod)
		prop_stun = max(0,round( ((prop_power/4)+stun_mod-prop_range*2)) )
		if(upgrades & PHASER_SNIPER)
			cost_mod += 50
			prop_dmg += 45
		if(upgrades & PHASER_ENERGY)
			prop_dmg = max(0,prop_dmg-8)
		if(upgrades & PHASER_HOMING)
			cost_mod += 5
		if(upgrades & PHASER_BURN)
			cost_mod -= 5
		if(upgrades & PHASER_TOXINS)
			cost_mod += 8
		if(upgrades & PHASER_EMP)
			cost_mod += 5
		if(upgrades & PHASER_SING)
			cost_mod += 8
			prop_dmg = max(0,prop_dmg-((prop_dmg/3)+3))
		if(upgrades & PHASER_FLASH)
			prop_dmg = max(0,round(prop_dmg-(prop_dmg/2)))
			prop_stun = max(0, prop_stun-5)
		if(upgrades & PHASER_CONC)
			prop_stun = 0
			prop_dmg = max(0,round(prop_dmg-(prop_dmg/2)))

		charges_per_shot = round(max( 10,(prop_power/4)+(prop_range*14) ))+cost_mod

		if(isrobot(loc))
			charges_per_shot = charges_per_shot*10

		return

	proc/update_icon()
		var/ratio = src.charges / maximum_charges
		ratio = round(ratio, 0.25) * 100
		src.icon_state = text("phaser[]", ratio)

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob, flag)
		if(overloading) return
		if (flag)
			return

		src.add_fingerprint(user)

		if(isrobot(user))
			var/mob/living/silicon/robot/R = user
			if(R.cell.charge < charges_per_shot)
				boutput(user, "<span class='alert'>*Warning* Not enough power.</span>");
				return
		else
			if(src.charges < charges_per_shot)
				boutput(user, "<span class='alert'>*click* *click*</span>");
				return

		if(shot_firesounds.len)
			for(var/S in shot_firesounds)
				playsound(user, S, 60, 1)
		else
			playsound(user, prop_sound, 60, 1)

		if(isrobot(user))
			var/mob/living/silicon/robot/R = user
			R.cell.charge -= charges_per_shot
		else
			src.charges -= charges_per_shot

		update_icon()

		SPAWN_DBG(0)

			var/obj/phaser_projectile/O = new/obj/phaser_projectile(get_turf(src))
			O.damage = prop_dmg
			O.range = prop_range
			O.stun = prop_stun
			O.power = prop_power
			O.upgrades = upgrades
			O.icon_state = prop_iconstate
			O.dest = get_turf(target)
			O.origin = user
			O.impactsounds = shot_impactsounds.Copy()
			SPAWN_DBG(1.5 SECONDS) qdel(O)

			if(shot_overlays.len)
				for(var/S in shot_overlays)
					O.overlays += icon("icons/obj/gun.dmi",S)

			while(O.loc != O.dest)
				var/impact = 0
				var/turf/next = get_step_towards(O,O.dest)
				if(next.density) impact = 1
				else O.set_loc(next)

				if(O.upgrades & PHASER_HOMING)
					for(var/mob/living/M in view(2,O.loc))
						if(M == O.origin) continue
						step_towards(O,M)
						break

				for(var/mob/living/M in O.loc)
					if(M == O.origin || M.lying) continue
					impact = 1
					break

				for(var/obj/machinery/bot/B in O.loc)
					impact = 1
					break

				for(var/obj/critter/C in O.loc)
					impact = 1
					break

				if(O.loc == O.dest) impact = 1

				if(impact)
					if(O.impactsounds.len)
						for(var/S in O.impactsounds)
							playsound(user, S, 65, 1)

					if(O.upgrades & PHASER_SING)
						var/turf/myloc = O.loc
						for(var/mob/living/M in view(2,O.loc))
							if(M == O.origin) continue
							SPAWN_DBG(0)
								step_towards(M,myloc)
								sleep(0.5 SECONDS)
								step_towards(M,myloc)

					var/obj/projectile/PBul = unpool(/obj/projectile)
					var/obj/projectile/PLas = unpool(/obj/projectile)
					PBul.proj_data = new /datum/projectile/bullet/revolver_357(  )
					PLas.proj_data = new /datum/projectile/laser(  )
					for(var/obj/machinery/bot/B in view(O.range,O.loc))
						if(O.upgrades & PHASER_EMP)
							B.bullet_act(PBul)
							B.bullet_act(PLas)
						else
							B.bullet_act(PLas)
						if(O.upgrades & PHASER_CONC)
							var/dir_old = O.dir
							SPAWN_DBG(0)
								step(B,dir_old)
								sleep(0.3 SECONDS)
								step(B,dir_old)

					for(var/obj/critter/C in view(O.range,O.loc))
						C.bullet_act(PLas)
						if(O.upgrades & PHASER_CONC)
							var/dir_old = O.dir
							SPAWN_DBG(0)
								step(C,dir_old)
								sleep(0.3 SECONDS)
								step(C,dir_old)

					qdel(PBul)
					qdel(PLas)

					for(var/mob/living/M in view(O.range,O.loc))
						if(M == O.origin) continue

						user.lastattacked = M
						M.lastattacker = user
						M.lastattackertime = world.time

						if(!isrobot(M) || (isrobot(M)&&!(O.upgrades & PHASER_EMP)))
							if(O.upgrades & PHASER_BURN)
								M.TakeDamage("chest", 0, O.damage)
							else if(O.upgrades & PHASER_TOXINS)
								M.take_toxin_damage(O.damage)
								if(M.reagents)
									M.reagents.add_reagent("toxin",7)
							else
								random_brute_damage(M, max(0,O.damage))
							M.weakened += max(0,O.stun)
						else if(isrobot(M) && (O.upgrades & PHASER_EMP))
							random_brute_damage(M, max(0,round(O.damage*1.5)))
							M.weakened += max(0,O.stun)
						if(O.upgrades & PHASER_FLASH)
							M.flash(60)

						if(O.upgrades & PHASER_CONC)
							var/dir_old = O.dir
							SPAWN_DBG(0)
								M.weakened += 2
								step(M,dir_old)
								sleep(0.3 SECONDS)
								step(M,dir_old)

					switch(O.power)
						if(1 to 33)
							for(var/turf/simulated/floor/T in view(O.range,O.loc))
								var/obj/OV = unpool(/obj/effects/sparks)
								OV.set_loc(T)
								OV.set_dir(pick(alldirs))
								SPAWN_DBG(2 SECONDS) if (OV) pool(OV)
						if(34 to 66)
							playsound(O.loc, "sound/effects/exlow.ogg", 65, 1)
							for(var/turf/simulated/floor/T in view(O.range,O.loc))
								var/obj/OV = new/obj/overlay(T)
								OV.icon = 'icons/effects/effects.dmi'
								OV.icon_state = "empdisable"
								OV.set_dir(pick(alldirs))
								SPAWN_DBG(0.3 SECONDS) qdel(OV)
								if(prob(O.power/2) || !O.range)
									T.burn_tile()
						if(67 to 100)
							playsound(O.loc, "sound/weapons/flashbang.ogg", 65, 1)
							for(var/turf/simulated/floor/T in view(O.range,O.loc))
								var/obj/OV = new/obj/effects/expl_particles(T)
								OV.set_dir(get_dir(O.loc,OV))
								if(prob(O.power/2) || !O.range)
									T.break_tile()
						if(101 to 150)
							playsound(O.loc, "sound/weapons/grenade.ogg", 65, 1)
							for(var/turf/simulated/floor/T in view(O.range,O.loc))
								var/obj/OV = new/obj/effects/expl_particles(T)
								OV.set_dir(get_dir(O.loc,OV))
								if(prob(85) || !O.range)
									T.break_tile_to_plating()

					qdel(O)
					return
				sleep(0.1 SECONDS)
			return

	Topic(href, href_list)
		if(overloading) return
		if(usr.stat || usr.restrained()) return
		if(!in_range(src, usr)) return
		src.add_dialog(usr)
		if (href_list["power"])
			var/change = href_list["power"]
			prop_power += text2num(change)
			if(prop_power < 0) prop_power = 0
			if(prop_power > 50 && safeties) prop_power = 50
			if(prop_power > 100) prop_power = 100

			update_settings()
			src.attack_self(usr)
			return
		else if (href_list["focus"])
			var/change = href_list["focus"]
			prop_range += text2num(change)
			if(prop_range < 0) prop_range = 0
			if(prop_range > prop_maxrange) prop_range = prop_maxrange
			update_settings()
			src.attack_self(usr)
			return
		else if (href_list["overload"])
			boutput(usr, "<span class='alert'>Your phaser overloads.</span>");
			overloading = 1
			playsound(usr, "sound/weapons/phaseroverload.ogg", 65, 1)
			SPAWN_DBG(6 SECONDS)
				var/turf/curr = get_turf(src)
				curr.hotspot_expose(700,125)
				explosion(src, curr, 0, 0, 2, 4)
				qdel(src)
		src.attack_self(usr)
		src.add_fingerprint(usr)
		return

	attack_self(mob/user as mob)
		if(overloading) return
		src.add_dialog(usr)
		var/dat = "Phaser settings:<BR><BR>"
		dat += "Power:<BR>"
		dat += "<A href='?src=\ref[src];power=-5'>(--)</A><A href='?src=\ref[src];power=-1'>(-)</A> [prop_power] <A href='?src=\ref[src];power=1'>(+)</A><A href='?src=\ref[src];power=5'>(++)</A><BR><BR>"
		dat += "Radius:<BR>"
		//dat += "<A href='?src=\ref[src];focus=-1'>(-)</A> [prop_range] <A href='?src=\ref[src];focus=1'>(+)</A><BR><BR>"
		dat += "Energy-cost per shot:[charges_per_shot]<BR>"

		if(isrobot(user))
			var/mob/living/silicon/robot/R = user
			dat += "Energy:[R.cell.charge]<BR><BR>"
		else
			dat += "Energy:[charges]/[maximum_charges]<BR><BR>"

		if(safeties) dat += "Safeties active. Phaser locked to non-lethal power levels."
		//dat += "Damage:[prop_dmg]<BR>"
		//dat += "Stun:[prop_stun]<BR>"
		user << browse(dat, "window=phaser;can_minimize=0;can_resize=0;size=180x340")
		onclose(user, "window=phaser")
		return
*/
