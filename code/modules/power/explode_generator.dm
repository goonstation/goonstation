
// "Wobbler" - Kenetic Transfer Device
/obj/machinery/power/ktd_generator
	icon = 'icons/obj/machines/resonance.dmi'
	icon_state = "ktd_base"

	var/stored_power
	var/efficiency = 1.0
	var/obj/ktd_rod/rod
	var/lastgen
	var/lastanimate_power
	var/image/power_band
	var/image/warning
	var/stress_fracture = 0

	New()
		START_TRACKING_CAT(TR_CAT_RESONANCE_ATOMS)
		rod = new
		src.vis_contents += rod

		power_band = image('icons/obj/machines/resonance.dmi',"band")
		power_band.appearance_flags = RESET_COLOR | RESET_ALPHA
		power_band.color = "#0f0"
		power_band.alpha = 120
		power_band.plane = PLANE_SELFILLUM
		src.UpdateOverlays(power_band,"band")

		warning = image('icons/obj/machines/resonance.dmi',"warning")
		warning.appearance_flags = RESET_COLOR | RESET_ALPHA
		warning.color = "#ff0"
		warning.alpha = 120
		warning.plane = PLANE_SELFILLUM
		src.UpdateOverlays(warning,"warning")

		..()

	disposing()
		STOP_TRACKING_CAT(TR_CAT_RESONANCE_ATOMS)
		..()

	power_change()
		. = ..()
		update_icon()

	proc/update_icon()
		if(src.status & NOPOWER)
			src.UpdateOverlays(null,"band")
		else
			power_band.alpha = clamp(lastgen/(50 KILO WATTS)*180, 5, 200)
			src.UpdateOverlays(power_band,"band")

		if((src.status & BROKEN) && !(src.status & NOPOWER))
			warning.color = "#f00"
			src.UpdateOverlays(warning,"warning")
		else if(src.stress_fracture)
			warning.color = "#ff0"
			warning.alpha = clamp(40*stress_fracture, 20, 255)
			src.UpdateOverlays(warning,"warning")
		else
			src.UpdateOverlays(null,"warning")

	// Adjust swing animation based on power
	proc/animate_swing(power)
		var/icon_power
		lastanimate_power = power

		if(power)
			icon_power = clamp(round(log(10, power)), 1, 5)
		else
			icon_power = 0

		rod.icon_state = "ktd_[icon_power]"

	ex_act(severity, last_touched, power)
		//use severity to determine stress on device
		//use power to determine amount of energy
		var/new_power = (power**3) HECTO WATTS

		// Constructive vs Destructive Interference
		// Determine how divisible the current and new waves are from 0-1
		var/max_power = max(new_power, stored_power)
		var/min_power = min(new_power, stored_power)

		var/scale = min_power / max(max_power, 1)
		var/divisible = abs(2*(scale-round(scale)-0.5))
		//Reward divisibility
		if(( scale >= 0.05) && (scale <= 0.66) && (divisible > 0.7 ) )
			var/boost = (1.5 * divisible * max_power)
			stored_power += boost

		//Have chance for destructive interference with equivalent wave forms to avoid cheese?
		var/close = min_power / max_power
		if(close > 0.90)
			// Linear Function fitting: 0.9=10, 1=70
			if(prob((600*close)-150))
				var/converted_power = new_power*efficiency
				add_avail(converted_power WATTS)
				new_power *= -1
				stress_fracture += 1

		if(prob(power))
			stress_fracture += severity * rand()

		stored_power += new_power

	process()
		if(stored_power)
			var/energy_transfer = stored_power * 0.05
			var/stress_efficiency = 1

			if(stored_power > 10 KILO WATTS)
				energy_transfer = max(stored_power * 0.05, 10 KILO WATTS)

			stored_power -= energy_transfer

			if(stress_fracture)
				stress_efficiency = clamp(1+(-0.01*stress_fracture)+(-0.01*stress_fracture*stress_fracture), 0, 1)

			lastgen = energy_transfer*efficiency*stress_efficiency
			add_avail(lastgen WATTS)

			if(abs(stored_power - lastanimate_power) > 5 || !stored_power)
				animate_swing(stored_power)

			src.maptext = "<span class='pixel sh'>[round(stored_power)]<BR/>[round(lastgen)]</span>" // Azrun TODO DELETE THIS PRIOR TO ACCEPTANCE

		if( stress_fracture )
			stress_fracture = max(stress_fracture - 0.02, 0)

	attackby(obj/item/W, mob/user)
		src.add_fingerprint(user)
		if (iswrenchingtool(W))
			if (!anchored)
				anchored = 1
				playsound(src.loc, "sound/items/Ratchet.ogg", 75, 1)
				boutput(user, "You secure the [src.name] to the floor.")
				src.anchored = 1
			else if (anchored)
				anchored = 0
				playsound(src.loc, "sound/items/Ratchet.ogg", 75, 1)
				boutput(user, "You unsecure the [src.name].")
				src.anchored = 0
			return

		else if(isweldingtool(W))
			if(!stress_fracture)
				boutput(user, "<span class='alert'>That isn't damaged!</span>")
				return

			if(!W:try_weld(user, 1, noisy=2))
				return

			boutput(user, "You start to repair the [src.name].")

			SETUP_GENERIC_ACTIONBAR(user, src, 2 SECONDS, /obj/machinery/power/ktd_generator/proc/weld_action,\
				list(user), W.icon, W.icon_state, "[user] finishes using their [W.name] on the [src].", null)

			return

		..()
		if(!istype(W, /obj/item/cable_coil))
			if(prob(100-(stored_power/ (1 HECTO WATTS))))
				if( W.hit_type == DAMAGE_BLUNT )
					stored_power += W.force
					animate_swing(stored_power)
			else
				stored_power -= rand(0,5)

				playsound(src.loc, 'sound/impact_sounds/Generic_Shove_1.ogg', 50, 1, 0 , 0.7)
				if(W.temp_flags & IS_LIMB_ITEM)
					src.visible_message("<span class='alert'><B>[src] shoves [user] and forces them to hit themselves!</B></span>")
					user.attackby(W, user)
					if(prob(20))
						W.attack_self(user)
				else if(!W.cant_other_remove && prob(33) )
					src.visible_message("<span class='alert'><B>[src] swings toward [user] and hits [W] out of [his_or_her(user)] hand!</B></span>")
					user.deliver_move_trigger("bump")
					user.drop_item_throw()
				else
					src.visible_message("<span class='alert'><B>[src] shoves [user] backwards!</B></span>")
					step_away(user, src, 1)
					user.OnMove(src)


				//striking with sufficient energy stored to disarm/knockback/stun person

	proc/weld_action(mob/user)
		stress_fracture = max(stress_fracture-1,0)

		if(!stress_fracture)
			boutput(user, "You have fully repaired the [src.name].")
		else
			boutput(user, "You have partially repaired the [src.name].")

/obj/ktd_rod
	icon = 'icons/obj/machines/resonance.dmi'
	icon_state = "ktd_0"
	vis_flags = VIS_INHERIT_ID

	New()
		..()
		src.setMaterial(getMaterial("plasmaresonate"))

/////////////////////////////////////////////////EXPLODEY FLOOR

/turf/simulated/floor/resonance
	name = "reinforced floor"
	icon_state = "engine-blue"
	reinforced = TRUE
	step_material = "step_lattice"
	step_priority = STEP_PRIORITY_MAX
	color = "#822"
	var/power = 0

	New()
		START_TRACKING_CAT(TR_CAT_RESONANCE_ATOMS)
		..()

	proc/energize(activate)
		if(activate)
			icon_state = "engine-glow"
		else
			icon_state = "engine-blue"
		return

	proc/resonate_explosion(exp_power)
		var/area/A = get_area(src)
		if( !ON_COOLDOWN(A, "resonate", 1.5 SECONDS) )
			src.power = exp_power
			if( !ON_COOLDOWN(A, "resonate_delay", 5 SECONDS) )
				SPAWN_DBG(1.5 SECONDS)
					explosion_new(src, src, exp_power) //allow for adjustment with resonance!!!
					src.resonate_wobblers(exp_power*0.8)
					src.power = 0
		else
			if(exp_power > src.power)
				src.power = exp_power

	proc/resonate_wobblers(power)
		for(var/obj/machinery/power/ktd_generator/wobbler in by_cat[TR_CAT_RESONANCE_ATOMS])
			if(wobbler.z != src.z) continue
			wobbler.ex_act(power=power)

	ex_act(severity, last_touched, power)
		resonate_explosion(power)

		if(ON_COOLDOWN(src,"resonate_mobs", 4 SECONDS))
			for(var/mob/M in src)
				var/weak = max(0, 2 * (4-severity))
				var/misstep = clamp(10 + 6 * (5 - severity), 0, 40)
				var/ear_damage = max(0, 2 * (3 - severity))
				var/ear_tempdeaf = max(0, 2 * (5 - severity)) //annoying and unfun so reduced dramatically
				var/stamina = clamp(50 + 10 * (7 - severity), 0, 120)

				if (issilicon(M))
					M.apply_sonic_stun(weak, 0)
				else
					M.apply_sonic_stun(weak, 0, misstep, 0, 0, ear_damage, ear_tempdeaf, stamina)

		return

	pry_tile(obj/item/C as obj, mob/user as mob, params)
		boutput(user, "<span class='alert'>You can't pry apart this reinforced flooring!</span>")

	ReplaceWithWall()
		RL_LumB = 0.2
		var/turf/wall = ReplaceWith(/turf/simulated/wall/auto/supernorn/resonance)
		if (map_settings)
			if (map_settings.auto_walls)
				for (var/turf/simulated/wall/auto/W in orange(1))
					W.update_icon()
			if (map_settings.auto_windows)
				for (var/obj/window/auto/W in orange(1))
					W.update_icon()
		SPAWN_DBG(0.2 SECONDS)
			wall.color = "#44A"
		return wall

	ReplaceWithRWall()
		RL_LumB = 0.2
		var/turf/wall = ReplaceWith(/turf/simulated/wall/auto/reinforced/supernorn/resonance)
		color = "#44A"
		if (map_settings)
			if (map_settings.auto_walls)
				for (var/turf/simulated/wall/auto/W in orange(1))
					W.update_icon()
			if (map_settings.auto_windows)
				for (var/obj/window/auto/W in orange(1))
					W.update_icon()
		SPAWN_DBG(0.2 SECONDS)
			wall.color = "#44A"
		return wall

/obj/machinery/light/small/floor/resonance
	icon_state = "floor1"
	base_state = "floor"
	desc = "A small lighting fixture, embedded in the floor and reinforced."
	name = "explosion resistant light fixture"
	plane = PLANE_FLOOR
	allowed_type = /obj/item/light/bulb
	light_type = /obj/item/light/bulb/warm/very

	ex_act(severity)
		return

//////// EXPLODEY PROTECTION WALLS

/turf/simulated/wall/auto/supernorn/resonance
	explosion_resistance = 20
	connects_to = list(/turf/simulated/wall/auto/supernorn/resonance, /turf/simulated/wall/auto/reinforced/supernorn/resonance, /obj/machinery/door/airlock/pyro/engineering/alt/resonance)
	RL_LumB = 0.2
	color = "#44A"
	mat_changeappearance = 0
	mat_changename = 0
	mat_changedesc = 0

	New()
		START_TRACKING_CAT(TR_CAT_RESONANCE_ATOMS)
		..()

	proc/energize(activate)
		if(activate)
			explosion_resistance = 100
			RL_LumR = 0.4
			RL_LumB = 0.0
			color = "#A44"
		else
			explosion_resistance = 20
			RL_LumR = 0.0
			RL_LumB = 0.2
			color = "#44A"

	ex_act(severity, last_touched, power)
		if(power > src.explosion_resistance)
			src.ReplaceWith(/turf/simulated/floor/resonance)
		return

	ReplaceWithFloor()
		src.ReplaceWith(/turf/simulated/floor/resonance)

/turf/simulated/wall/auto/reinforced/supernorn/resonance
	explosion_resistance = 60
	connects_to = list(/turf/simulated/wall/auto/supernorn/resonance, /turf/simulated/wall/auto/reinforced/supernorn/resonance, /obj/machinery/door/airlock/pyro/engineering/alt/resonance)
	RL_LumB = 0.2
	color = "#44A"
	mat_changeappearance = 0
	mat_changename = 0
	mat_changedesc = 0

	New()
		START_TRACKING_CAT(TR_CAT_RESONANCE_ATOMS)
		..()

	proc/energize(activate)
		if(activate)
			explosion_resistance = 200
			RL_LumR = 0.4
			RL_LumB = 0.0
			color = "#A44"
		else
			explosion_resistance = 60
			RL_LumR = 0.0
			RL_LumB = 0.2
			color = "#44A"

	ex_act(severity, last_touched, power)
		if(power > src.explosion_resistance)
			src.ReplaceWith(/turf/simulated/wall/auto/supernorn/resonance)

	ReplaceWithFloor()
		src.ReplaceWith(/turf/simulated/wall/auto/supernorn/resonance)

//////// EXPLODEY DOOR

/obj/machinery/door/airlock/pyro/engineering/alt/resonance
	explosion_protection = 40
	explosion_resistance = 40
	req_access = list(access_engineering)

	New()
		START_TRACKING_CAT(TR_CAT_RESONANCE_ATOMS)
		..()

	disposing()
		STOP_TRACKING_CAT(TR_CAT_RESONANCE_ATOMS)
		..()

	proc/energize(activate)
		if(activate)
			explosion_protection = 200
			explosion_resistance = 200
		else
			explosion_protection = 40
			explosion_resistance = 40

	ex_act(severity)
		return

//////// ANTI-EXPLODEY BUTTON

/obj/machinery/explosive_shield_button
	name = "Explosion Shield Button"
	icon = 'icons/obj/objects.dmi'
	icon_state = "launcherbtt"
	desc = "A remote control switch to activate explosive resistive shield."
	var/id = null
	var/active = 0
	anchored = 1.0

	attack_ai(mob/user as mob)
		return src.attack_hand(user)

	attackby(obj/item/W, mob/user as mob)
		if(istype(W, /obj/item/device/detective_scanner))
			return
		return src.attack_hand(user)

	attack_hand(mob/user as mob)
		if(status & (NOPOWER|BROKEN))
			return
		if(active)
			return

		var/duration = 10 SECONDS
		var/delay = 5 SECONDS

		use_power(25 KILO WATTS)
		active = 1
		icon_state = "launcheract"
		src.energize_turfs(duration)

		sleep(duration + delay)
		icon_state = "launcherbtt"
		active = 0

	proc/energize_turfs(duration=10 SECONDS)
		var/x=0
		var/y=0
		var/cnt=0
		var/turf/center
		for(var/turf/T in by_cat[TR_CAT_RESONANCE_ATOMS])
			if(T.z != src.z) continue
			if(istype(T, /turf/simulated/wall/auto/supernorn/resonance))
				var/turf/simulated/wall/auto/supernorn/resonance/wall = T
				wall.energize(TRUE)
			else if(istype(T, /turf/simulated/wall/auto/reinforced/supernorn/resonance) )
				var/turf/simulated/wall/auto/reinforced/supernorn/resonance/r_wall = T
				r_wall.energize(TRUE)
			else if(istype(T, /turf/simulated/floor/resonance) )
				var/turf/simulated/floor/resonance/floor = T
				floor.energize(TRUE)
			x += T.x
			y += T.y
			cnt += 1

		center = locate(round(x/cnt), round(y/cnt), src.z)
		playsound(center, 'sound/machines/shieldoverload.ogg', 50, 0, 0 , 1.2)
		SPAWN_DBG(duration)
			playsound(center, 'sound/effects/shielddown.ogg', 50, 0, 0)
			for(var/turf/T in by_cat[TR_CAT_RESONANCE_ATOMS])
				if(T.z != src.z) continue
				if(istype(T, /turf/simulated/wall/auto/supernorn/resonance))
					var/turf/simulated/wall/auto/supernorn/resonance/wall = T
					wall.energize(FALSE)
				else if(istype(T, /turf/simulated/wall/auto/reinforced/supernorn/resonance))
					var/turf/simulated/wall/auto/reinforced/supernorn/resonance/r_wall = T
					r_wall.energize(FALSE)
				else if(istype(T, /turf/simulated/floor/resonance))
					var/turf/simulated/floor/resonance/floor = T
					floor.energize(FALSE)

	ex_act(severity)
		return

// Prefab APC

/obj/machinery/power/apc/war_eng
	attack_hand(mob/user)
		if (user.getStatusDuration("stunned") || user.getStatusDuration("weakened") || user.stat)
			return

		if(opened && !isAI(user))
			if(cell)
				boutput(user, "Sharpnel has wedged power cell in place.  It isn't going anywhere.")
				return
		..()

	attackby(obj/item/W, mob/user)
		if (issilicon(user))
			if (istype(W, /obj/item/robojumper))
				boutput(user, "The typical means of connecting to an APC is not present here...")
				return
		..()


// Prefab Resources

/obj/machinery/door/poddoor/blast/puzzle
	ex_act(severity, last_touched, power)
		return

// Prefab Materials

/datum/material/crystal/plasmaresonate
	mat_id = "plasmaresonate"
	name = "plasma polycrystalline"
	desc = "Polycrystallized plasma that has been rendered inert. Treated to have an intricate lattice pattern.  It lets out a soft hum in response to sound."
	color = "#c710ff"
	alpha = 210

	New()
		setProperty("density", 30)
		setProperty("hard", 75)
		setProperty("resonance", 80)
		return ..()

// Prefab Turfs

/obj/item/paper/proof_read_note
	name = "Todo list"
	info = {"<head>
			<style type="text/css">
			body {color:black; font-family: Georgia}
			</style>
			</head>
			&#9745; - Redline latest revision of generator manual<br>
			&#9744; - Clean up<br>
			&#9745; - Get more potatos<br>
			&#9744; - Get some grapes<br>
			&#9744; - Obtain more fermentable things?<br>
			&#9744; - Quit and become a botanist<br>
			&#9744; - Stop making these lists<br>
			<br>
			&#9744; - Request further detail regarding maintenance from R&D<br>
			"}

/obj/item/paper/book/resonance_draft
	name = "Resonance Power"
	icon_state = "whitebook"
	desc = "A redlined draft detailing the use and operation of prototype generator"
	info = {"
<head>
<style type="text/css">
table, th, td {
border: 1px solid grey;
}
s
{
color:red
}
.add
{
color:green
}
p, li
{
font-family:"Arial";
font-size:14px;
}
h4
{
padding:10px;
}
</style>
</head>
<h1>Explosive Resonance <s>Engine</s> <span class="add">Generator</span></h1>
<center><h2>DRAFT</h2></center>
<p><i>Compiled for Nanotrasen by Servin Underwriting, LTD - (C) 2048 All Rights Reserved</i></p>
<h3>Preface</h3>
<p>The following is a <s>quick start</s> <span class="add">guide</span> to safe operation and repair of the prototype explosive resonance power system.  Remember there is <s>always</s> inherent danger in use of this engine even when used properly and thus following proper procedures is critical <s>in maintaining company resources.</s></p>
<p>This energy generation source is a continuation in leveraging the exploration of utilizing the uses of plasma and plasma related materials.  When properly treated plasmaglass acts as an somewhat efficient a piezoelectric material and allows for material deformation to be harnessed and transferred directly into electric energy by the piezoelectric effect.  This allows for the harnessing of shockwaves generated from the <s>disposal or testing of various forms of</s> explosives.</p>
<h3>Resonance Chamber</h3>
<p>A critical part of maintaining safety and efficiency is the proper use of the resonance chamber.  Specially designed paneling helps reflect the shockwave back into the chamber to maximize the amount of kinetic energy that can be captured.</p>
<p>The chamber is also specially engineered to be <b>resistant</b> to explosions.  When properly energized the chamber’s explosive resistance is greatly improved, unfortunately this state is not sustainable for an extended period of time.  The change to the chamber should be immediately visually apparent while accompanied by an identifiable audible sound.</p>
<h3><s>Kinetic Transfer Device</s><span class="add">Wobblers call them wobblers</span></h3>
<p>The Kinetic Transfer Devices characterized by the sphere, pillar, and base.  The sphere is where the majority of the energy from the shockwave will be absorbed causing a transfer of kinetic energy to the KTD.  The force on the sphere then transfers energy leveraging the elasticity pillar to move.  Elasticity of the pillar then causes deformation of the pillar allowing for the energy to be converted into electricity inside the piezoelectric material.  As the pillar relaxes, typically as the sphere swings back, power is released and collected to the base as materials return to their normal form.  The base can be connected to standard Nanotrasen electronics but should be <s>preferably</s> connected to an SMES system to maintain consistent power output.</p>
<p>The base is equipped with an indicator that power is being provided that cycles around the unit.  Additionally new kinetic transfer devices are equipped with structural integrity monitors.  <s>Calibrated based on observed piezoelectric response</s> the monitor will illuminate a warning with an indication that repair is required.</p>

<h3><span class="add">Repair and Maintenance</span></h3>
<span class="add">
<ul>
<li>Welding when visible stress fractures form</li>
<li>I swear I left a KTD fractured overnight and the next morning it was fixed? Do they repair themselves?</li>
</ul>
</span>
	"}

