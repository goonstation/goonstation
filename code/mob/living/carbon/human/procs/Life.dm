
/datum/lifeprocess
	var/mob/living/owner
	var/last_process = 0

	var/const/tick_spacing = 20 //This should pretty much *always* stay at 20, for it is the one number that all do-over-time stuff should be balanced around
	var/const/cap_tick_spacing = 90 //highest timeofday allowance between ticks to try to play catchup with realtime thingo

	var/mob/living/carbon/human/human_owner = null
	var/mob/living/silicon/hivebot/hivebot_owner = null
	var/mob/living/silicon/robot/robot_owner = null
	var/mob/living/critter/critter_owner = null

	New(new_owner)
		..()
		last_process = TIME

		owner = new_owner
		if (ishuman(owner))
			human_owner = owner
		if (istype(owner,/mob/living/silicon/hivebot))
			hivebot_owner = owner

	disposing()
		..()
		owner = null
		human_owner = null
		hivebot_owner = null

	proc/process(var/datum/gas_mixture/environment)
		last_process = TIME

	proc/get_multiplier()
		.= clamp(TIME - last_process, tick_spacing, cap_tick_spacing) / tick_spacing

/datum/lifeprocess/breath
	var/breathtimer = 0
	var/breathstate = 0


	proc/update_oxy(var/on)
		if (human_owner)
			human_owner.hud.update_oxy_indicator(on)

	proc/update_toxy(var/on)
		if (human_owner)
			human_owner.hud.update_tox_indicator(on)

	process(var/datum/gas_mixture/environment)
		//special (read: stupid) manual breathing stuff. weird numbers are so that messages don't pop up at the same time as manual blinking ones every time
		if (manualbreathing && human_owner)
			breathtimer++
			switch(breathtimer)
				if (0 to 15)
					breathe(environment)
				if (34)
					boutput(owner, "<span class='alert'>You need to breathe!</span>")
				if (35 to 51)
					if (prob(5)) owner.emote("gasp")
				if (52)
					boutput(owner, "<span class='alert'>Your lungs start to hurt. You really need to breathe!</span>")
				if (53 to 61)
					update_oxy(1)
					owner.take_oxygen_deprivation(breathtimer/12)
				if (62)
					update_oxy(1)
					boutput(owner, "<span class='alert'>Your lungs are burning and the need to take a breath is almost unbearable!</span>")
					owner.take_oxygen_deprivation(10)
				if (63 to INFINITY)
					update_oxy(1)
					owner.take_oxygen_deprivation(breathtimer/6)
		else // plain old automatic breathing
			breathe(environment)

		if (istype(owner.loc, /obj/))
			var/obj/location_as_object = owner.loc
			location_as_object.handle_internal_lifeform(owner, 0)
		..()

	proc/breathe(datum/gas_mixture/environment)
		//if (!owner.loc) //already checked
		//	return

		var/mult = get_multiplier()

		var/atom/underwater = 0
		if (isturf(owner.loc))
			var/turf/T = owner.loc
			if (istype(T, /turf/space/fluid))
				underwater = T
			else if (T.active_liquid)
				var/obj/fluid/F = T.active_liquid

				var/depth_to_breathe_from = depth_levels.len
				if (owner.lying)
					depth_to_breathe_from = depth_levels.len-1

				if (F.amt >= depth_levels[depth_to_breathe_from])
					underwater = F
					if (owner.is_submerged != 4)
						owner.show_submerged_image(4)

			else if (T.active_airborne_liquid)
				if (!(human_owner?.wear_mask && (human_owner?.wear_mask.c_flags & BLOCKSMOKE || (human_owner?.wear_mask.c_flags & MASKINTERNALS && human_owner?.internal))))
					//underwater = T.active_airborne_liquid
					var/obj/fluid/F = T.active_airborne_liquid
					F.force_mob_to_ingest(owner)
				else
					if (!owner.clothing_protects_from_chems())
						var/obj/fluid/airborne/F = T.active_airborne_liquid
						F.just_do_the_apply_thing(owner, hasmask = 1)

		else if (istype(owner.loc, /mob/living/object))
			return // no breathing inside possessed objects
		else if (istype(owner.loc, /obj/machinery/atmospherics/unary/cryo_cell))
			return
		//if (istype(loc, /obj/machinery/clonepod)) return

		if (owner.reagents)
			if (owner.reagents.has_reagent("lexorin")) return

		// Changelings generally can't take OXY/LOSEBREATH damage...except when they do.
		// And because they're excluded from the breathing procs, said damage didn't heal
		// on its own, making them essentially mute and perpetually gasping for air.
		// Didn't seem like a feature to me (Convair880).
		// If you have the breathless effect, same deal - you'd never heal oxy damage
		// If your mutant race doesn't need oxygen from breathing, ya no losebreath
		// so, now you do
		if (ischangeling(owner) || (owner.bioHolder && owner.bioHolder.HasEffect("breathless") || (human_owner?.mutantrace && !human_owner?.mutantrace.needs_oxy)))
			if (owner.losebreath)
				owner.losebreath = 0
			if (owner.get_oxygen_deprivation())
				owner.take_oxygen_deprivation(-50 * mult)
			return

		if (underwater)
			if (human_owner?.mutantrace && human_owner?.mutantrace.aquatic)
				return
			if (prob(25) && owner.losebreath > 0)
				boutput(owner, "<span class='alert'>You are drowning!</span>")

		var/datum/air_group/breath = null
		// HACK NEED CHANGING LATER
		//if (src.oxymax == 0 || (breathtimer > 15))
		if (breathtimer > 15)
			owner.losebreath += (0.7 * mult)

		if (owner.grabbed_by && owner.grabbed_by.len)
			breath = get_breath_grabbed_by(BREATH_VOLUME)

		if (!breath)
			if (owner.losebreath>0) //Suffocating so do not take a breath
				owner.losebreath -= (1.3 * mult)
				owner.losebreath = max(owner.losebreath,0)
				if (prob(75)) //High chance of gasping for air
					if (underwater)
						owner.emote("gurgle")
					else
						owner.emote("gasp")
				if (isobj(owner.loc))
					var/obj/location_as_object = owner.loc
					location_as_object.handle_internal_lifeform(owner, 0)
				if (owner.losebreath <= 0)
					boutput(owner, "<span class='notice'>You catch your breath.</span>")
			else
				//First, check for air from internal atmosphere (using an air tank and mask generally)
				breath = get_breath_from_internal(BREATH_VOLUME)

				//No breath from internal atmosphere so get breath from location
				if (!breath)
					if (isobj(owner.loc))
						var/obj/location_as_object = owner.loc
						breath = location_as_object.handle_internal_lifeform(owner, BREATH_VOLUME)
					else if (isturf(owner.loc))
						var/breath_moles = (TOTAL_MOLES(environment)*BREATH_PERCENTAGE)

						breath = owner.loc.remove_air(breath_moles)

				else //Still give containing object the chance to interact
					underwater = 0 // internals override underwater state
					if (isobj(owner.loc))
						var/obj/location_as_object = owner.loc
						location_as_object.handle_internal_lifeform(owner, 0)

		handle_breath(breath, underwater, mult = mult)

		if (breath)
			owner.loc.assume_air(breath)


	proc/get_breath_grabbed_by(volume_needed)
		.= null
		for(var/obj/item/grab/force_mask/G in owner.grabbed_by)
			.= G.get_breath(volume_needed)
			if (.)
				break

	proc/get_breath_from_internal(volume_needed)
		if (human_owner?.internal)
			if (!owner.contents.Find(human_owner.internal))
				human_owner?.internal = null
			if (!human_owner?.wear_mask || !(human_owner?.wear_mask.c_flags & MASKINTERNALS) )
				human_owner?.internal = null
			if (human_owner?.internal)
				if (human_owner?.internals)
					human_owner?.internals.icon_state = "internal1"
				for (var/obj/ability_button/tank_valve_toggle/T in human_owner?.internal.ability_buttons)
					T.icon_state = "airon"
				return human_owner?.internal.remove_air_volume(volume_needed)
			else
				if (human_owner?.internals)
					human_owner?.internals.icon_state = "internal0"

		return null

	proc/handle_breath(datum/gas_mixture/breath, var/atom/underwater = 0, var/mult = 1) //'underwater' really applies for any reagent that gets deep enough. but what ever
		if (owner.nodamage) return
		var/area/A = get_area(owner)
		if( A && A.sanctuary )
			return
		// Looks like we're in space
		// or with recent atmos changes, in a room that's had a hole in it for any amount of time, so now we check src.loc
		if (underwater || !breath || (TOTAL_MOLES(breath) == 0))
			if (istype(owner.loc, /turf/space))
				owner.take_oxygen_deprivation(6 * mult)
			else
				owner.take_oxygen_deprivation(3 * mult)
			update_oxy(1)

			//consume some reagents if we drowning
			if (underwater && (owner.get_oxygen_deprivation() > 40 || underwater.type == /obj/fluid/airborne))
				if (istype(underwater,/obj/fluid))
					var/obj/fluid/F = underwater
					F.force_mob_to_ingest(owner)// * mult
				else if (istype(underwater, /turf/space/fluid))
					var/turf/space/fluid/F = underwater
					F.force_mob_to_ingest(owner)// * mult


			return 0

		if (owner.health < 0 || (human_owner?.organHolder && human_owner?.organHolder.get_working_lung_amt() == 0)) //We aren't breathing.
			return 0

		var/has_cyberlungs = (human_owner?.organHolder && (human_owner.organHolder.left_lung && human_owner.organHolder.right_lung) && (human_owner.organHolder.left_lung.robotic && human_owner.organHolder.right_lung.robotic)) //gotta prevent null pointers...
		var/safe_oxygen_min = 17 // Minimum safe partial pressure of O2, in kPa
		//var/safe_oxygen_max = 140 // Maximum safe partial pressure of O2, in kPa (Not used for now)
		var/safe_co2_max = 9 // Yes it's an arbitrary value who cares?
		var/safe_toxins_max = 0.4
		var/SA_para_min = 1
		var/SA_sleep_min = 5
		var/oxygen_used = 0
		var/breath_pressure = (TOTAL_MOLES(breath)*R_IDEAL_GAS_EQUATION*breath.temperature)/BREATH_VOLUME
		var/fart_smell_min = 0.69 // don't ask ~warc
		var/fart_vomit_min = 6.9
		var/fart_choke_min = 16.9

		//Partial pressure of the O2 in our breath
		var/O2_pp = (breath.oxygen/TOTAL_MOLES(breath))*breath_pressure
		// Same, but for the toxins
		var/Toxins_pp = (breath.toxins/TOTAL_MOLES(breath))*breath_pressure
		// And CO2, lets say a PP of more than 10 will be bad (It's a little less really, but eh, being passed out all round aint no fun)
		var/CO2_pp = (breath.carbon_dioxide/TOTAL_MOLES(breath))*breath_pressure


		//change safe gas levels for cyberlungs
		if (has_cyberlungs)
			safe_oxygen_min = 9
			safe_co2_max = 18
			safe_toxins_max = 5		//making it a lot higher than regular, because even doubling the regular value is pitifully low. This is still reasonably low, but it might be noticable

		if (O2_pp < safe_oxygen_min) 			// Too little oxygen
			if (prob(20))
				if (underwater)
					owner.emote("gurgle")
				else
					owner.emote("gasp")
			if (O2_pp > 0)
				var/ratio = round(safe_oxygen_min/(O2_pp + 0.1))
				owner.take_oxygen_deprivation(min(5*ratio, 5)) // Don't fuck them up too fast (space only does 7 after all!)
				oxygen_used = breath.oxygen*ratio/6
			else
				owner.take_oxygen_deprivation(3 * mult)
			update_oxy(1)
		else 									// We're in safe limits
			//if (breath.oxygen/TOTAL_MOLES(breath) >= 0.95) //high oxygen concentration. lets slightly heal oxy damage because it feels right
			//	take_oxygen_deprivation(-6 * mult)

			owner.take_oxygen_deprivation(-6 * mult)
			oxygen_used = breath.oxygen/6
			update_oxy(0)

		breath.oxygen -= oxygen_used
		breath.carbon_dioxide += oxygen_used

		if (CO2_pp > safe_co2_max)
			if (!owner.co2overloadtime) // If it's the first breath with too much CO2 in it, lets start a counter, then have them pass out after 12s or so.
				owner.co2overloadtime = world.time
			else if (world.time - owner.co2overloadtime > 120)
				owner.changeStatus("paralysis", (4 * mult) SECONDS)
				owner.take_oxygen_deprivation(1.8 * mult) // Lets hurt em a little, let them know we mean business
				if (world.time - owner.co2overloadtime > 300) // They've been in here 30s now, lets start to kill them for their own good!
					owner.take_oxygen_deprivation(7 * mult)
			if (prob(20)) // Lets give them some chance to know somethings not right though I guess.
				owner.emote("cough")

		else
			owner.co2overloadtime = 0

		if (Toxins_pp > safe_toxins_max) // Too much toxins
			var/ratio = breath.toxins/safe_toxins_max
			owner.take_toxin_damage(min(ratio * 125,20) * mult)
			update_toxy(1)
		else
			update_toxy(0)

		if (length(breath.trace_gases))	// If there's some other shit in the air lets deal with it here.
			for (var/datum/gas/sleeping_agent/SA in breath.trace_gases)
				var/SA_pp = (SA.moles/TOTAL_MOLES(breath))*breath_pressure
				if (SA_pp > SA_para_min) // Enough to make us paralysed for a bit
					owner.changeStatus("paralysis", 5 SECONDS)
					if (SA_pp > SA_sleep_min) // Enough to make us sleep as well
						owner.sleeping = max(owner.sleeping, 2)
				else if (SA_pp > 0.01)	// There is sleeping gas in their lungs, but only a little, so give them a bit of a warning
					if (prob(20))
						owner.emote(pick("giggle", "laugh"))

		var/FARD_pp = (breath.farts/TOTAL_MOLES(breath))*breath_pressure
		if (prob(15) && (FARD_pp > fart_smell_min))
			boutput(owner, "<span class='alert'>Smells like someone [pick("died","soiled themselves","let one rip","made a bad fart","peeled a dozen eggs")] in here!</span>")
			if ((FARD_pp > fart_vomit_min) && prob(50))
				owner.visible_message("<span class='notice'>[src] vomits from the [pick("stink","stench","awful odor")]!!</span>")
				owner.vomit()
		if (FARD_pp > fart_choke_min)
			owner.take_oxygen_deprivation(6.9 * mult)
			if (prob(20))
				owner.emote("cough")
				if (prob(30))
					boutput(owner, "<span class='alert'>Oh god it's so bad you could choke to death in here!</span>")


			//cyber lungs beat radiation. Is there anything they can't do?
			if (!has_cyberlungs)
				for (var/datum/gas/rad_particles/RV in breath.trace_gases)
					owner.changeStatus("radiation", RV.moles, 2 SECONDS)

		if (human_owner)
			if (breath.temperature > min(human_owner.organHolder.left_lung ? human_owner.organHolder.left_lung.temp_tolerance : INFINITY, human_owner.organHolder.right_lung ? human_owner.organHolder.right_lung.temp_tolerance : INFINITY) && !human_owner.is_heat_resistant()) // Hot air hurts :(
				//checks the temperature threshold for each lung, ignoring missing ones. the case of having no lungs is handled in handle_breath.
				var/lung_burn_left = min(max(breath.temperature - human_owner.organHolder.left_lung?.temp_tolerance, 0) / 3, 10)
				var/lung_burn_right = min(max(breath.temperature - human_owner.organHolder.right_lung?.temp_tolerance, 0) / 3, 10)
				if (breath.temperature > (human_owner.organHolder.left_lung ? human_owner.organHolder.left_lung.temp_tolerance : INFINITY))
					human_owner.TakeDamage("chest", 0, (lung_burn_left / 2) + 3, 0, DAMAGE_BURN)
					if(prob(20))
						boutput(human_owner, "<span class='alert'>This air is searing hot!</span>")
						if (prob(80))
							human_owner.organHolder.damage_organ(0, lung_burn_left + 6, 0, "left_lung")
				if (breath.temperature > (human_owner.organHolder.right_lung ? human_owner.organHolder.right_lung.temp_tolerance : INFINITY))
					human_owner.TakeDamage("chest", 0, (lung_burn_right / 2) + 3, 0, DAMAGE_BURN)
					if(prob(20))
						boutput(human_owner, "<span class='alert'>This air is searing hot!</span>")
						if (prob(80))
							human_owner.organHolder.damage_organ(0, lung_burn_right + 6, 0, "right_lung")

				human_owner.hud.update_fire_indicator(1)
				if (prob(4))
					boutput(human_owner, "<span class='alert'>Your lungs hurt like hell! This can't be good!</span>")
					//src.contract_disease(new/datum/ailment/disability/cough, 1, 0) // cogwerks ailment project - lung damage from fire

			else
				human_owner.hud.update_fire_indicator(0)


		//Temporary fixes to the alerts.

		return 1


/datum/lifeprocess/chems
	process(var/datum/gas_mixture/environment)
		//proc/handle_chemicals_in_body()
		if (owner.nodamage)
			return ..()

		if (owner.reagents)
			var/reagent_time_multiplier = get_multiplier()

			owner.reagents.temperature_reagents(owner.bodytemperature, 100, 35/reagent_time_multiplier, 15*reagent_time_multiplier)

			if (blood_system && owner.reagents.get_reagent("blood"))
				var/blood2absorb = min(owner.blood_absorption_rate, owner.reagents.get_reagent_amount("blood")) * reagent_time_multiplier
				owner.reagents.remove_reagent("blood", blood2absorb)
				owner.blood_volume += blood2absorb
			if (owner.metabolizes)
				owner.reagents.metabolize(src, multiplier = reagent_time_multiplier)

		if (owner.nutrition > owner.blood_volume)
			owner.nutrition = owner.blood_volume
		if (owner.nutrition < 0)
			owner.contract_disease(/datum/ailment/malady/hypoglycemia, null, null, 1)

		..()
		//health_update_queue |= src //#843 uncomment this if things go funky maybe


/datum/lifeprocess/mutations
	process(var/datum/gas_mixture/environment)
		//proc/handle_mutations_and_radiation()
		if (owner.bioHolder) owner.bioHolder.OnLife()
		..()

/datum/lifeprocess/bomberman
	process(var/datum/gas_mixture/environment)
		SPAWN_DBG(1 SECOND)
			new /obj/bomberman(get_turf(owner))
		..()

/datum/lifeprocess/fire
	process(var/datum/gas_mixture/environment)
		var/duration = owner.getStatusDuration("burning")
		if (duration)
			if (duration > 200)
				for(var/atom in owner.contents)
					var/atom/A = atom
					if (A.event_handler_flags & HANDLE_STICKER)
						if (A:active)
							owner.visible_message("<span class='alert'><b>[A]</b> is burnt to a crisp and destroyed!</span>")
							qdel(A)

			if (isturf(owner.loc))
				var/turf/location = owner.loc
				location.hotspot_expose(T0C + 300, 400)

			for (var/atom/A in owner.contents)
				if (A.material)
					A.material.triggerTemp(A, T0C + 900)

			if(owner.traitHolder && owner.traitHolder.hasTrait("burning"))
				if(prob(50))
					owner.update_burning(1)
		..()

/datum/lifeprocess/viruses
	process(var/datum/gas_mixture/environment)
		//proc/handle_virus_updates()
		//might need human
		if (owner.ailments && owner.ailments.len)
			for (var/mob/living/carbon/M in oviewers(4, owner))
				if (prob(40))
					owner.viral_transmission(M,"Airborne",0)
				if (prob(20))
					owner.viral_transmission(M,"Sight", 0)

			if (!isdead(owner))
				for (var/datum/ailment_data/am in owner.ailments)
					am.stage_act()

		if (prob(40))
			for (var/obj/decal/cleanable/blood/B in view(2, owner))
				for (var/datum/ailment_data/disease/virus in B.diseases)
					if (virus.spread == "Airborne")
						owner.contract_disease(null,null,virus,0)
		..()

/datum/lifeprocess/skin
	//handle_skinstuff((life_time_passed / tick_spacing))
	process(var/datum/gas_mixture/environment)
		if (owner.skin_process && owner.skin_process.len)

			var/mult = get_multiplier()
			//you absorb shit faster if you have lots of patches stacked
			//gives patches a way to heal quickly if you slap on a whole bunch, also makes long heals over time less viable

			var/multi_process_mult = owner.skin_process.len > 1 ? (owner.skin_process.len * 1.5) : 1
			var/use_volume = 0.35 * mult * multi_process_mult

			for(var/atom in owner.skin_process)
				var/atom/A = atom

				if (A.loc != owner)
					owner.skin_process -= A
					continue

				if (A.reagents && A.reagents.total_volume)
					A.reagents.reaction(owner, TOUCH, react_volume = use_volume, paramslist = (A.reagents.total_volume == A.reagents.maximum_volume) ? 0 : list("silent", "nopenetrate"))
					A.reagents.trans_to(owner, use_volume/2)
					A.reagents.remove_any(use_volume/2)
				else
					if (A.reagents.total_volume <= 0)
						owner.skin_process -= A //disposing will do this too but whatever
						qdel(A)
		..()

/datum/lifeprocess/decomposition

	//proc/handle_decomposition()
	process(var/datum/gas_mixture/environment)
		if (isdead(owner) && human_owner) //hey i know this only hanldes human right now but i predict we will want other mobs to decompose later on
			var/mob/living/carbon/human/H = owner
			var/turf/T = get_turf(owner)
			if (!T)
				return ..()

			if (T.temp_flags & HAS_KUDZU)
				H.infect_kudzu()

			var/suspend_rot = 0
			if (H.decomp_stage >= 4)
				suspend_rot = (istype(owner.loc, /obj/machinery/atmospherics/unary/cryo_cell) || istype(owner.loc, /obj/morgue) || (owner.reagents && owner.reagents.has_reagent("formaldehyde")))
				if (!suspend_rot)
					icky_icky_miasma(T)
				return ..()

			if (H.mutantrace)
				return ..()
			suspend_rot = (istype(owner.loc, /obj/machinery/atmospherics/unary/cryo_cell) || istype(owner.loc, /obj/morgue) || (owner.reagents && owner.reagents.has_reagent("formaldehyde")))
			var/env_temp = 0
			// cogwerks note: both the cryo cell and morgue things technically work, but the corpse rots instantly when removed
			// if it has been in there longer than the next decomp time that was initiated before the corpses went in. fuck!
			// will work out a fix for that soon, too tired right now

			// hello I fixed the thing by making it so that next_decomp_time is added to even if src is in a morgue/cryo or they have formaldehyde in them - haine
			if (!suspend_rot)
				env_temp = environment.temperature
				H.next_decomp_time -= min(30, max(round((env_temp - T20C)/10), -60))

				icky_icky_miasma(T)

			if (world.time > H.next_decomp_time) // advances every 4-10 game minutes
				H.next_decomp_time = world.time + rand(240,600)*10
				if (suspend_rot)
					return ..()
				H.decomp_stage = min(H.decomp_stage + 1, 4)
				owner.update_body()
				owner.update_face()
		..()

	proc/icky_icky_miasma(var/turf/T)
		var/mob/living/carbon/human/H = owner
		var/max_produce_miasma = H.decomp_stage * 20
		if (T.active_airborne_liquid && prob(90)) //sometimes just add anyway lol
			var/obj/fluid/F = T.active_airborne_liquid
			if (F.group && F.group.reagents && F.group.reagents.total_volume > max_produce_miasma)
				max_produce_miasma = 0

		if (max_produce_miasma)
			T.fluid_react_single("miasma", 10, airborne = 1)


/datum/lifeprocess/bodytemp
	//proc/handle_environment(datum/gas_mixture/environment) //TODO : REALTIME BODY TEMP CHANGES (Mbc is too lazy to look at this mess right now)
	process(var/datum/gas_mixture/environment)
		if (!environment)
			return ..()
		var/environment_heat_capacity = HEAT_CAPACITY(environment)
		var/loc_temp = T0C
		if (istype(owner.loc, /turf/space))
			var/turf/space/S = owner.loc
			environment_heat_capacity = S.heat_capacity
			loc_temp = S.temperature
		else if (istype(owner.loc, /obj/machinery/vehicle))
			var/obj/machinery/vehicle/ship = owner.loc
			if (ship.life_support)
				if (ship.life_support.active)
					loc_temp = ship.life_support.tempreg
				else
					loc_temp = environment.temperature
		// why am i repeating this shit?
		else if (istype(owner.loc, /obj/vehicle))
			var/obj/vehicle/V = owner.loc
			if (V.sealed_cabin)
				loc_temp = T20C // hardcoded honkytonk nonsense
		else if (istype(owner.loc, /obj/machinery/atmospherics/unary/cryo_cell))
			var/obj/machinery/atmospherics/unary/cryo_cell/C = owner.loc
			loc_temp = C.air_contents.temperature
		else if (istype(owner.loc, /obj/machinery/colosseum_putt))
			loc_temp = T20C
		else
			loc_temp = environment.temperature

		var/thermal_protection
		if (owner.stat < 2)
			owner.bodytemperature = owner.adjustBodyTemp(owner.bodytemperature,owner.base_body_temp,1,owner.thermoregulation_mult)
		if (loc_temp < owner.base_body_temp) // a cold place -> add in cold protection
			if (owner.is_cold_resistant())
				return ..()
			thermal_protection = owner.get_cold_protection()
		else // a hot place -> add in heat protection
			if (owner.is_heat_resistant())
				return ..()
			thermal_protection = owner.get_heat_protection()
		var/thermal_divisor = (100 - thermal_protection) * 0.01
		owner.bodytemperature = owner.adjustBodyTemp(owner.bodytemperature,loc_temp,thermal_divisor,owner.innate_temp_resistance)

		if (istype(owner.loc, /obj/machinery/atmospherics/unary/cryo_cell))
			return ..()

		// lets give them a fair bit of leeway so they don't just start dying
		//as that may be realistic but it's no fun
		if ((owner.bodytemperature > owner.base_body_temp + (owner.temp_tolerance * 1.7) && environment.temperature > owner.base_body_temp + (owner.temp_tolerance * 1.7)) || (owner.bodytemperature < owner.base_body_temp - (owner.temp_tolerance * 1.7) && environment.temperature < owner.base_body_temp - (owner.temp_tolerance * 1.7)))

			//Yep this means that the damage is no longer per limb. Restore this to per limb eventually. See above.
			owner.handle_temperature_damage(LEGS, environment.temperature, environment_heat_capacity*thermal_divisor)
			owner.handle_temperature_damage(TORSO,environment.temperature, environment_heat_capacity*thermal_divisor)
			owner.handle_temperature_damage(HEAD, environment.temperature, environment_heat_capacity*thermal_divisor)
			owner.handle_temperature_damage(ARMS, environment.temperature, environment_heat_capacity*thermal_divisor)

			for (var/atom/A in owner.contents)
				if (A.material)
					A.material.triggerTemp(A, environment.temperature)

		// decoupled this from environmental temp - this should be more for hypothermia/heatstroke stuff
		//if (src.bodytemperature > src.base_body_temp || src.bodytemperature < src.base_body_temp)

		//Account for massive pressure differences
		//TODO: DEFERRED
		..()

/datum/lifeprocess/disability

	//proc/handle_disabilities(var/mult = 1)
	process(var/datum/gas_mixture/environment)
		var/mult = get_multiplier()

		// moved drowsy, confusion and such from handle_chemicals because it seems better here
		if (owner.drowsyness)
			owner.drowsyness--
			owner.change_eye_blurry(2)
			if (prob(5))
				owner.sleeping = 1
				owner.changeStatus("paralysis", 5 SECONDS)

		if (owner.misstep_chance > 0)
			switch(owner.misstep_chance)
				if (50 to INFINITY)
					owner.change_misstep_chance(-2 * mult)
				else
					owner.change_misstep_chance(-1 * mult)

		// The value at which this stuff is capped at can be found in mob.dm
		if (owner.hasStatus("resting"))
			owner.dizziness = max(0, owner.dizziness - 5)
			owner.jitteriness = max(0, owner.jitteriness - 5)
		else
			owner.dizziness = max(0, owner.dizziness - 2)
			owner.jitteriness = max(0, owner.jitteriness - 2)

		if (owner.mind && isvampire(owner))
			if (istype(get_area(owner), /area/station/chapel) && owner.check_vampire_power(3) != 1)
				if (prob(33))
					boutput(owner, "<span class='alert'>The holy ground burns you!</span>")
				owner.TakeDamage("chest", 0, 5 * mult, 0, DAMAGE_BURN)
			if (owner.loc && istype(owner.loc, /turf/space))
				if (prob(33))
					boutput(owner, "<span class='alert'>The starlight burns you!</span>")
				owner.TakeDamage("chest", 0, 2 * mult, 0, DAMAGE_BURN)

		if (owner.loc && isarea(owner.loc.loc))
			var/area/A = owner.loc.loc
			if (A.irradiated)
				if (owner.get_rad_protection())
					if (ishuman(owner) && istype(owner:wear_suit, /obj/item/clothing/suit/rad) && prob(33))
						boutput(owner, "<span class='alert'>Your geiger counter ticks...</span>")
					return ..()
				else
					owner.changeStatus("radiation", (A.irradiated * 10) SECONDS)

		if (owner.bioHolder)
			var/total_stability = owner.bioHolder.genetic_stability

			if (owner.reagents && owner.reagents.has_reagent("mutadone"))
				total_stability += 60

			if (total_stability <= 40 && prob(5))
				owner.bioHolder.DegradeRandomEffect()

			if (total_stability <= 20 && prob(10))
				owner.bioHolder.DegradeRandomEffect()

		..()

/datum/lifeprocess/organs
	process(var/datum/gas_mixture/environment)
		owner.handle_organs(get_multiplier())

		//the master vore loop
		if (owner.stomach_contents && owner.stomach_contents.len)
			SPAWN_DBG(0)
				for (var/mob/M in owner.stomach_contents)
					if (M.loc != owner)
						owner.stomach_contents.Remove(M)
						continue
					if (iscarbon(M) && !isdead(owner))
						if (isdead(M))
							M.death(1)
							owner.stomach_contents.Remove(M)
							M.ghostize()
							qdel(M)
							owner.emote("burp")
							playsound(owner.loc, "sound/voice/burp.ogg", 50, 1)
							continue
						if (air_master.current_cycle%3==1)
							if (!M.nodamage)
								M.TakeDamage("chest", 5, 0)
							owner.nutrition += 10
		..()


/datum/lifeprocess/critical //for mobs that use crit (humans only right now)
	process(var/datum/gas_mixture/environment)
		var/mult = get_multiplier()
		//health_update_queue |= src //#843 uncomment this if things go funky maybe
		var/death_health = owner.health + (owner.get_oxygen_deprivation() * 0.5) - (owner.get_burn_damage() * 0.67) - (owner.get_brute_damage() * 0.67) //lower weight of oxy, increase weight of brute/burn here
		// I don't think the revenant needs any of this crap - Marq
		if (owner.bioHolder && owner.bioHolder.HasEffect("revenant") || isdead(owner)) //You also don't need to do a whole lot of this if the dude's dead.
			return ..()

		if (owner.health < 0 && !isdead(owner))
			if (prob(5) * mult)
				owner.emote(pick("faint", "collapse", "cry","moan","gasp","shudder","shiver"))
			if (owner.stuttering <= 5)
				owner.stuttering+=5
			if (owner.get_eye_blurry() <= 5)
				owner.change_eye_blurry(5)
			if (prob(7) * mult)
				owner.change_misstep_chance(2)
			if (prob(5) * mult)
				owner.changeStatus("paralysis", 3 SECONDS)
			switch(owner.health)
				if (-INFINITY to -100)
					owner.take_oxygen_deprivation(1 * mult)
					if (prob(owner.health * -0.1  * mult))
						owner.contract_disease(/datum/ailment/malady/flatline,null,null,1)
						//boutput(world, "\b LOG: ADDED FLATLINE TO [src].")
					if (prob(owner.health * -0.2  * mult))
						owner.contract_disease(/datum/ailment/malady/heartfailure,null,null,1)
						//boutput(world, "\b LOG: ADDED HEART FAILURE TO [src].")
					if (isalive(owner))
						if (owner && owner.mind)
							owner.lastgasp() // if they were ok before dropping below zero health, call lastgasp() before setting them unconscious
					owner.setStatus("paralysis", max(owner.getStatusDuration("paralysis"), 15 * mult))
				if (-99 to -80)
					owner.take_oxygen_deprivation(1 * mult)
					if (prob(4 * mult))
						boutput(owner, "<span class='alert'><b>Your chest hurts...</b></span>")
						owner.changeStatus("paralysis", 2 SECONDS)
						owner.contract_disease(/datum/ailment/malady/heartfailure,null,null,1)
				if (-79 to -51)
					owner.take_oxygen_deprivation(1 * mult)
					if (prob(10 * mult)) // shock added back to crit because it wasn't working as a bloodloss-only thing
						owner.contract_disease(/datum/ailment/malady/shock,null,null,1)
						//boutput(world, "\b LOG: ADDED SHOCK TO [src].")
					if (prob(owner.health * -0.08) * mult)
						owner.contract_disease(/datum/ailment/malady/heartfailure,null,null,1)
						//boutput(world, "\b LOG: ADDED HEART FAILURE TO [src].")
					if (prob(6) * mult)
						boutput(owner, "<span class='alert'><b>You feel [pick("horrible pain", "awful", "like shit", "absolutely awful", "like death", "like you are dying", "nothing", "warm", "really sweaty", "tingly", "really, really bad", "horrible")]</b>!</span>")
						owner.setStatus("weakened", max(owner.getStatusDuration("weakened"), 30))
					if (prob(3) * mult)
						owner.changeStatus("paralysis", 2 SECONDS)
				if (-50 to 0)
					owner.take_oxygen_deprivation(0.25 * mult)
					/*if (src.reagents)
						if (!src.reagents.has_reagent("inaprovaline") && prob(50))
							src.take_oxygen_deprivation(1)*/
					if (prob(3) * mult)
						owner.contract_disease(/datum/ailment/malady/shock,null,null,1)
						//boutput(world, "\b LOG: ADDED SHOCK TO [src].")
					if (prob(5) * mult)
						boutput(owner, "<span class='alert'><b>You feel [pick("terrible", "awful", "like shit", "sick", "numb", "cold", "really sweaty", "tingly", "horrible")]!</b></span>")
						owner.changeStatus("weakened", 3 SECONDS)

		var/is_chg = ischangeling(owner)
		//if (src.brain_op_stage == 4.0) // handled above in handle_organs() now
			//death()
		if (owner.get_brain_damage() >= 120 || death_health <= -500) //-200) a shitty test here // let's lower the weight of oxy
			if (!is_chg || owner.suiciding)
				owner.death()

		if (owner.get_brain_damage() >= 100) // braindeath
			if (!is_chg)
				boutput(owner, "<span class='alert'>Your head [pick("feels like shit","hurts like fuck","pounds horribly","twinges with an awful pain")].</span>")
				owner.losebreath+=10
				owner.changeStatus("weakened", 3 SECONDS)
		if (owner.health <= -100)
			var/deathchance = min(99, ((owner.get_brain_damage() * -5) + (owner.health + (owner.get_oxygen_deprivation() / 2))) * -0.01)
			if (prob(deathchance))
				owner.death()

		..()

/datum/lifeprocess/statusupdate
	//april fools stuff
	var/blinktimer = 0
	var/blinkstate = 0

	process(var/datum/gas_mixture/environment)
		//proc/handle_regular_status_updates(datum/controller/process/mobs/parent,var/mult = 1)
		if (owner.bioHolder && owner.bioHolder.HasEffect("revenant") || isdead(owner)) //You also don't need to do a whole lot of this if the dude's dead.
			return ..()

		var/mult = get_multiplier()

		//maximum stamina modifiers.
		owner.stamina_max = max((STAMINA_MAX + owner.get_stam_mod_max()), 0)
		owner.stamina = min(owner.stamina, owner.stamina_max)

		if (owner.sleeping)
			if (owner.hasStatus("resting"))
				owner.sleeping = 4
			else
				owner.sleeping--
			owner.changeStatus("paralysis", 4 SECONDS * mult)
			if (prob(10) && (owner.health > 0))
				owner.emote("snore")
			if (!owner.last_sleep) // we are asleep but weren't previously
				owner.last_sleep = 1
				owner.UpdateOverlays(owner.sleep_bubble, "sleep_bubble")
		else
			if (owner.last_sleep) // we were previously asleep but aren't anymore
				owner.last_sleep = 0
				owner.UpdateOverlays(null, "sleep_bubble")

				if (critter_owner)
					critter_owner.on_wake()

		if (prob(50) && owner.hasStatus("disorient"))
			//src.drop_item()
			owner.emote("twitch")

		//todo : clothing blindles flags for less istypeing
		if (owner.getStatusDuration("blinded"))
			owner.blinded = 1
		else
			for (var/thing in owner.get_equipped_items())
				if (!thing) continue
				var/obj/item/I = thing
				if (I.block_vision)
					owner.blinded = 1
					break

		if (manualblinking && human_owner)
			var/showmessages = 1
			var/tempblind = owner.get_eye_damage(1)

			if (owner.find_ailment_by_type(/datum/ailment/disability/blind))
				showmessages = 0

			src.blinktimer++
			switch(src.blinktimer)
				if (20)
					if (showmessages) boutput(owner, "<span class='alert'>Your eyes feel slightly uncomfortable!</span>")
				if (30)
					if (showmessages) boutput(owner, "<span class='alert'>Your eyes feel quite dry!</span>")
				if (40)
					if (showmessages) boutput(owner, "<span class='alert'>Your eyes feel very dry and uncomfortable, it's getting difficult to see!</span>")
					owner.change_eye_blurry(3, 3)
				if (41 to 59)
					owner.change_eye_blurry(3, 3)
				if (60)
					if (showmessages) boutput(owner, "<span class='alert'>Your eyes are so dry that you can't see a thing!</span>")
					owner.take_eye_damage(max(0, min(3, 3 - tempblind)), 1)
				if (61 to 99)
					owner.take_eye_damage(max(0, min(3, 3 - tempblind)), 1)
				if (100) //blinking won't save you now, buddy
					if (showmessages) boutput(owner, "<span class='alert'>You feel a horrible pain in your eyes. That can't be good.</span>")
					owner.contract_disease(/datum/ailment/disability/blind,null,null,1)

			if (src.blinkstate) owner.take_eye_damage(max(0, min(1, 1 - tempblind)), 1)

		if (owner.get_eye_damage(1)) // Temporary blindness.
			owner.take_eye_damage(-1, 1)
			owner.blinded = 1

		if (owner.stuttering)
			owner.stuttering--

		if (owner.get_ear_damage(1)) // Temporary deafness.
			owner.take_ear_damage(-1, 1)

		if (owner.get_ear_damage() && (owner.get_ear_damage() <= owner.get_ear_damage_natural_healing_threshold()))
			owner.take_ear_damage(-0.05)

		if (owner.get_eye_blurry())
			owner.change_eye_blurry(-1)

		if (owner.druggy)
			owner.druggy = max(owner.druggy-1, 0)

		if (owner.nodamage)
			owner.HealDamage("All", 10000, 10000)
			owner.take_toxin_damage(-5000)
			owner.take_oxygen_deprivation(-5000)
			owner.take_brain_damage(-120)
			owner.delStatus("radiation")
			owner.delStatus("paralysis")
			owner.delStatus("weakened")
			owner.delStatus("stunned")
			owner.stuttering = 0
			owner.take_ear_damage(-INFINITY)
			owner.take_ear_damage(-INFINITY, 1)
			owner.change_eye_blurry(-INFINITY)
			owner.druggy = 0
			owner.blinded = null

		if (hivebot_owner)
			hivebot_owner.hud.update_charge()
			hivebot_owner.health = hivebot_owner.max_health - (hivebot_owner.fireloss + hivebot_owner.bruteloss)
			return 1

		if (robot_owner)
			if(!robot_owner.part_chest)
				// this doesn't even make any sense unless you're rayman or some shit

				if (robot_owner.mind && robot_owner.mind.special_role)
					robot_owner.handle_robot_antagonist_status("death", 1) // Mindslave or rogue (Convair880).

				robot_owner.visible_message("<b>[src]</b> falls apart with no chest to keep it together!")
				logTheThing("combat", robot_owner, null, "was destroyed at [log_loc(robot_owner)].") // Brought in line with carbon mobs (Convair880).

				if (robot_owner.part_arm_l)
					if (robot_owner.part_arm_l.slot == "arm_both")
						robot_owner.part_arm_l.set_loc(robot_owner.loc)
						robot_owner.part_arm_l = null
						robot_owner.part_arm_r = null
					else
						robot_owner.part_arm_l.set_loc(robot_owner.loc)
						robot_owner.part_arm_l = null
				if (robot_owner.part_arm_r)
					if (robot_owner.part_arm_r.slot == "arm_both")
						robot_owner.part_arm_r.set_loc(robot_owner.loc)
						robot_owner.part_arm_l = null
						robot_owner.part_arm_r = null
					else
						robot_owner.part_arm_r.set_loc(robot_owner.loc)
						robot_owner.part_arm_r = null

				if (robot_owner.part_leg_l)
					if (robot_owner.part_leg_l.slot == "leg_both")
						robot_owner.part_leg_l.set_loc(robot_owner.loc)
						robot_owner.part_leg_l = null
						robot_owner.part_leg_r = null
					else
						robot_owner.part_leg_l.set_loc(robot_owner.loc)
						robot_owner.part_leg_l = null
				if (robot_owner.part_leg_r)
					if (robot_owner.part_leg_r.slot == "leg_both")
						robot_owner.part_leg_r.set_loc(robot_owner.loc)
						robot_owner.part_leg_r = null
						robot_owner.part_leg_l = null
					else
						robot_owner.part_leg_r.set_loc(robot_owner.loc)
						robot_owner.part_leg_r = null

				if (robot_owner.part_head)
					robot_owner.part_head.set_loc(robot_owner.loc)
					robot_owner.part_head = null
					//no chest means you are dead. Placed here to avoid duplicate alert in event that head was already destroyed and you then destroy torso
					robot_owner.borg_death_alert()

				if (robot_owner.client)
					var/mob/dead/observer/newmob = robot_owner.ghostize()
					if (newmob)
						newmob.corpse = null

				qdel(robot_owner)

			else if (!robot_owner.part_head && robot_owner.client)
				// no head means no brain!!

				if (robot_owner.mind && robot_owner.mind.special_role)
					robot_owner.handle_robot_antagonist_status("death", 1) // Mindslave or rogue (Convair880).

				robot_owner.visible_message("<b>[src]</b> completely stops moving and shuts down...")
				robot_owner.borg_death_alert()
				logTheThing("combat", src, null, "was destroyed at [log_loc(robot_owner)].") // Ditto (Convair880).

				var/mob/dead/observer/newmob = robot_owner.ghostize()
				if (newmob)
					newmob.corpse = null

		..()



/datum/lifeprocess/blood
	process(var/datum/gas_mixture/environment)
		///////////////////////////////////////////////////////////////////////////
		//proc/handle_blood(var/mult = 1) // hopefully this won't cause too much lag?
		///////////////////////////////////////////////////////////////////////////

		if (!blood_system) // I dunno if this'll do what I want but hopefully it will
			return ..()

		if (isdead(owner) || owner.nodamage || !owner.can_bleed || isvampire(owner)) // if we're dead or immortal or have otherwise been told not to bleed, don't bother
			if (owner.bleeding)
				owner.bleeding = 0 // also stop bleeding if we happen to be doing that
			return ..()

		//This is now handled by the on_life in the spleen organ in the organHolder
		// if (src.blood_volume < 500 && src.blood_volume > 0) // if we're full or empty, don't bother v
		// 	if (prob(66))
		// 		src.blood_volume += 1 * mult // maybe get a little blood back ^
		// else if (src.blood_volume > 500) // just in case there's no reagent holder
		// 	if (prob(20))
		// 		src.blood_volume -= 1 * mult

		var/mult = get_multiplier()


		var/anticoag_amt = 0
		var/coag_amt = 0
		if (owner.reagents)
			anticoag_amt = owner.reagents.get_reagent_amount("heparin")
			coag_amt = owner.reagents.get_reagent_amount("proconvertin")

		if (owner.bleeding)


			var/decrease_chance = 2 // defaults to 2 because blood does clot and all, but we want bleeding to maybe not stop entirely on its own TOO easily, and there's only so much clotting can do when all your blood is falling out at once
			var/surgery_increase_chance = 5 //likelihood we bleed more bc we are being surgeried or have open cuts

			if (owner.bleeding > 1 && owner.bleeding < 4) // midrange bleeding gets a better chance to drop down
				decrease_chance += 3
			else
				surgery_increase_chance += 10


			if (anticoag_amt) // anticoagulant
				decrease_chance -= rand(1,2)
			if (coag_amt) // coagulant
				decrease_chance += rand(2,4)

			if (owner.get_surgery_status())
				decrease_chance -= 1
			if (prob(decrease_chance))
				owner.bleeding -= 1 * mult
				boutput(owner, "<span class='notice'>Your wounds feel [pick("better", "like they're healing a bit", "a little better", "itchy", "less tender", "less painful", "like they're closing", "like they're closing up a bit", "like they're closing up a little")].</span>")

			if (owner.bleeding < 0) //INVERSE BLOOD LOSS was a fun but ultimately easily fixed bug
				owner.bleeding = 0

			if (prob(surgery_increase_chance) && owner.get_surgery_status())
				owner.bleeding += 1 * mult


			if (owner.blood_volume)
				var/final_bleed = clamp(owner.bleeding, 0, 5) // trying this at 5 being the max
				//var/final_bleed = clamp(src.bleeding, 0, 10) // still don't want this above 10

				if (anticoag_amt)
					final_bleed += round(clamp((anticoag_amt / 10), 0, 2), 1)
				final_bleed *= mult
				if (prob(max(0, min(final_bleed, 10)) * 5)) // up to 50% chance to make a big bloodsplatter
					bleed(owner, final_bleed, 5)

				else
					switch (owner.bleeding)
						if (1)
							bleed(owner, final_bleed, 1) // this proc creates a bloodsplatter on src's tile
						if (2)
							bleed(owner, final_bleed, 2) // it takes care of removing blood, and transferring reagents, color and ling status to the blood
						if (3 to 4)
							bleed(owner, final_bleed, 3) // see blood_system.dm for the proc
						if (5)
							bleed(owner, final_bleed, 4)


		////////////////////////////////////////////
		//proc/handle_blood_pressure(var/mult = 1)//
		////////////////////////////////////////////

		if (!blood_system)
			return ..()
		// very low (90/60 or lower) (<375u)
		// low (100/65) (<415u)
		// normal (120/80) (500u)
		// high (stage 1) (140/90 or higher) (>585u)
		// very high (stage 2) (160/100 or higher) (>666u)
		// dangerously high (urgency) (180/110 or higher) (>750u)
		if (isvampire(owner))
			owner.blood_pressure["systolic"] = 120
			owner.blood_pressure["diastolic"] = 80
			owner.blood_pressure["rendered"] = "[rand(115,125)]/[rand(78,82)]"
			owner.blood_pressure["total"] = 500
			owner.blood_pressure["status"] = "Normal"
			return ..()

		owner.blood_volume = max(0, owner.blood_volume) //clean up negative blood amounts here. Lazy fix, but easier than cleaning up every place that blood is removed
		var/current_blood_amt = owner.blood_volume + (owner.reagents ? owner.reagents.total_volume / 4 : 0) // dropping how much reagents count so that people stop going hypertensive at the drop of a hat
		var/cho_amt = (owner.reagents ? owner.reagents.get_reagent_amount("cholesterol") : 0)
		if (anticoag_amt)
			current_blood_amt -= ((anticoag_amt / 4) + anticoag_amt) * mult// set the total back to what it would be without the heparin, then remove the total of the heparin
		if (coag_amt)
			current_blood_amt -= (coag_amt / 4) * mult // set the blood total to what it would be without the proconvertin in it
			current_blood_amt += coag_amt * mult// then add the actual total of the proconvertin back so it counts for 4x what the other chems do
		if (cho_amt)
			current_blood_amt -= (cho_amt / 4) * mult // same as proconvertin above
			current_blood_amt += cho_amt * mult
		current_blood_amt = round(current_blood_amt, 1)

		var/current_systolic = round((current_blood_amt * 0.24), 1)
		var/current_diastolic = round((current_blood_amt * 0.16), 1)
		owner.blood_pressure["systolic"] = current_systolic
		owner.blood_pressure["diastolic"] = current_diastolic
		owner.blood_pressure["rendered"] = "[max(rand(current_systolic-5,current_systolic+5), 0)]/[max(rand(current_diastolic-2,current_diastolic+2), 0)]"
		owner.blood_pressure["total"] = current_blood_amt
		owner.blood_pressure["status"] = (current_blood_amt < 415) ? "HYPOTENSIVE" : (current_blood_amt > 584) ? "HYPERTENSIVE" : "NORMAL"

		if (ischangeling(owner))
			return ..()

		//special case
		if (current_blood_amt >= 1500)
			if (prob(10))
				owner.visible_message("<span class='alert'><b>[owner] bursts like a bloody balloon! Holy fucking shit!!</b></span>")
				owner.gib(1) // :v
				return

		if (isdead(owner))
			return ..()

		switch (current_blood_amt)
			if (-INFINITY to 0) // welp
				owner.take_oxygen_deprivation(1 * mult)
				owner.take_brain_damage(2 * mult)
				owner.losebreath += (1 * mult)
				owner.drowsyness = max(owner.drowsyness, rand(3,4))
				if (prob(10))
					owner.change_misstep_chance(rand(3,4) * mult)
				if (prob(10))
					owner.emote(pick("faint", "collapse", "pale", "shudder", "shiver", "gasp", "moan"))
				if (prob(18))
					var/extreme = pick("", "really ", "very ", "extremely ", "terribly ", "insanely ")
					var/feeling = pick("[extreme]ill", "[extreme]sick", "[extreme]numb", "[extreme]cold", "[extreme]dizzy", "[extreme]out of it", "[extreme]confused", "[extreme]off-balance", "[extreme]terrible", "[extreme]awful", "like death", "like you're dying", "[extreme]tingly", "like you're going to pass out", "[extreme]faint")
					boutput(owner, "<span class='alert'><b>You feel [feeling]!</b></span>")
					owner.changeStatus("weakened", (4 * mult) SECONDS)
				owner.contract_disease(/datum/ailment/malady/shock, null, null, 1) // if you have no blood you're gunna be in shock
				owner.add_stam_mod_regen("hypotension", -3)
				owner.add_stam_mod_max("hypotension", -15)

			if (1 to 374) // very low (90/60)
				owner.take_oxygen_deprivation(0.8 * mult)
				owner.take_brain_damage(0.8 * mult)
				owner.losebreath += (0.8 * mult)
				owner.drowsyness = max(owner.drowsyness, rand(1,2))
				if (prob(6))
					owner.change_misstep_chance(rand(1,2) * mult)
				if (prob(8))
					owner.emote(pick("faint", "collapse", "pale", "shudder", "shiver", "gasp", "moan"))
				if (prob(14))
					var/extreme = pick("", "really ", "very ", "extremely ", "terribly ", "insanely ")
					var/feeling = pick("[extreme]ill", "[extreme]sick", "[extreme]numb", "[extreme]cold", "[extreme]dizzy", "[extreme]out of it", "[extreme]confused", "[extreme]off-balance", "[extreme]terrible", "[extreme]awful", "like death", "like you're dying", "[extreme]tingly", "like you're going to pass out", "[extreme]faint")
					boutput(owner, "<span class='alert'><b>You feel [feeling]!</b></span>")
					owner.changeStatus("weakened", (3 * mult) SECONDS)
				if (prob(25))
					owner.contract_disease(/datum/ailment/malady/shock, null, null, 1)
				owner.add_stam_mod_regen("hypotension", -2)
				owner.add_stam_mod_max("hypotension", -10)

			if (375 to 414) // low (100/65)
				if (prob(2))
					owner.emote(pick("pale", "shudder", "shiver"))
				if (prob(5))
					var/extreme = pick("", "kinda ", "a little ", "sorta ", "a bit ")
					var/feeling = pick("ill", "sick", "numb", "cold", "dizzy", "out of it", "confused", "off-balance", "tingly", "faint")
					boutput(owner, "<span class='alert'><b>You feel [extreme][feeling]!</b></span>")
				if (prob(5))
					owner.contract_disease(/datum/ailment/malady/shock, null, null, 1)
				owner.add_stam_mod_regen("hypotension", -1)
				owner.add_stam_mod_max("hypotension", -5)

			if (415 to 584) // normal (120/80)
				owner.remove_stam_mod_regen("hypertension")
				owner.remove_stam_mod_regen("hypotension")
				owner.remove_stam_mod_max("hypertension")
				owner.remove_stam_mod_max("hypotension")
				return ..()

			if (585 to 665) // high (140/90)
				if (prob(2))
					var/msg = pick("You feel kinda sweaty",\
					"You can feel your heart beat loudly in your chest",\
					"Your head hurts")
					boutput(owner, "<span class='alert'>[msg].</span>")
				if (prob(1))
					owner.losebreath += (1 * mult)
				if (prob(1))
					owner.emote("gasp")
				if (prob(1) && prob(10))
					owner.contract_disease(/datum/ailment/malady/heartdisease,null,null,1)
				owner.add_stam_mod_regen("hypertension", -1)
				owner.add_stam_mod_max("hypertension", -5)

			if (666 to 749) // very high (160/100)
				if (prob(2))
					var/msg = pick("You feel sweaty",\
					"Your heart beats rapidly",\
					"Your head hurts badly",\
					"Your chest hurts")
					boutput(owner, "<span class='alert'>[msg].</span>")
				if (prob(3))
					owner.losebreath += (1 * mult)
				if (prob(2))
					owner.emote("gasp")
				if (prob(1))
					owner.contract_disease(/datum/ailment/malady/heartdisease,null,null,1)
				owner.add_stam_mod_regen("hypertension", -2)
				owner.add_stam_mod_max("hypertension", -10)

			if (750 to INFINITY) // critically high (180/110)
				if (prob(5))
					var/msg = pick("You feel really sweaty",\
					"Your heart pounds in your chest",\
					"Your head pounds with pain",\
					"Your chest hurts badly",\
					"It's hard to breathe")
					boutput(owner, "<span class='alert'>[msg]!</span>")
				if (prob(5))
					owner.losebreath += (1 * mult)
				if (prob(2))
					owner.take_eye_damage(1)
				if (prob(3))
					owner.emote("gasp")
				if (prob(5))
					owner.contract_disease(/datum/ailment/malady/heartdisease,null,null,1)
				if (prob(2))
					owner.visible_message("<span class='alert'>[src] coughs up a little blood!</span>")
					playsound(get_turf(owner), "sound/impact_sounds/Slimy_Splat_1.ogg", 30, 1)
					bleed(owner, rand(1,2) * mult, 1)
				owner.add_stam_mod_regen("hypertension", -3)
				owner.add_stam_mod_max("hypertension", -15)

		..()

/datum/lifeprocess/health_mon
	process(var/datum/gas_mixture/environment)
		if (!human_owner) //humans only, fix this later to work on critters!!!
			return ..()

		// Update Prodoc overlay heart
		var/mob/living/carbon/human/H = owner
		if (H.health_mon)
			// Originally the isdead() check was only done in the other check if <0, which meant
			// if you were dead but had > 0 HP (e.g. eaten by blob) you would still show
			// a not-dead heart. So, now you don't.
			if ((owner.bioHolder && owner.bioHolder.HasEffect("dead_scan")) || isdead(owner))
				H.health_mon.icon_state = "-1"
			else
				// Handle possible division by zero
				var/health_prc = (owner.health / (owner.max_health != 0 ? owner.max_health : 1)) * 100
				switch (health_prc)
					// There's 5 "regular" health states (ignoring 100% and < 0)
					// but the health icons were set up as if there were 4
					// (25, 50, 75, 100) / (20, 40, 60, 80, 100)
					// The "75" state was only used for 75-80!
					// Spread these out to make it more represenative
					if (98 to INFINITY) //100
						H.health_mon.icon_state = "100"
					if (80 to 98) //80
						H.health_mon.icon_state = "80"
					if (60 to 80) //75
						H.health_mon.icon_state = "75"
					if (40 to 60) //50
						H.health_mon.icon_state = "50"
					if (20 to 40) //25
						H.health_mon.icon_state = "25"
					if ( 0 to 20) //10
						H.health_mon.icon_state = "10"
					if (-INFINITY to 0) //0
						H.health_mon.icon_state = "0"
		if (H.health_implant)
			if (locate(/obj/item/implant/health) in H.implant)
				H.health_implant.icon_state = "implant"
			else
				H.health_implant.icon_state = null

		..()

/datum/lifeprocess/arrest_icon
	process(var/datum/gas_mixture/environment)
		if (!human_owner) //humans only, fix this later to work on critters!!!
			return ..()

		var/mob/living/carbon/human/H = owner
		if (H.arrestIcon) // Update security hud icon

			//TODO : move this code somewhere else that updates from an event trigger instead of constantly
			var/arrestState = ""
			var/visibleName = H.name
			if (H.wear_id)
				visibleName = H.wear_id.registered_owner()

			for (var/security_record in data_core.security)
				var/datum/data/record/R = security_record
				if ((R.fields["name"] == visibleName) && ((R.fields["criminal"] == "*Arrest*") || R.fields["criminal"] == "Parolled" || R.fields["criminal"] == "Incarcerated" || R.fields["criminal"] == "Released"))
					arrestState = R.fields["criminal"] // Found a record of some kind
					break

			if (arrestState != "*Arrest*") // Contraband overrides non-arrest statuses, now check for contraband

				if (locate(/obj/item/implant/antirev) in H.implant)
					if (ticker.mode && ticker.mode.type == /datum/game_mode/revolution)
						var/datum/game_mode/revolution/R = ticker.mode
						if (H.mind && H.mind.special_role == "head_rev")
							arrestState = "RevHead"
						else if (H.mind in R.revolutionaries)
							arrestState = "Loyal_Progress"
						else
							arrestState = "Loyal"
					else
						arrestState = "Loyal"

				else
					var/obj/item/card/id/myID = 0
					//mbc : its faster to check if the item in either hand has a registered owner than doing istype on equipped()
					//this does mean that if an ID has no registered owner + carry permit enabled it will blink off as contraband. however i dont care!
					if (H.l_hand && H.l_hand.registered_owner())
						myID = H.l_hand
					else if (H.r_hand && H.r_hand.registered_owner())
						myID = H.r_hand

					if (!myID)
						myID = H.wear_id
					if (myID && (access_carrypermit in myID.access))
						myID = null
					else
						var/contrabandLevel = 0
						if (H.l_hand)
							contrabandLevel += H.l_hand.contraband
						if (!contrabandLevel && H.r_hand)
							contrabandLevel += H.r_hand.contraband
						if (!contrabandLevel && H.belt)
							contrabandLevel += H.belt.contraband
						if (!contrabandLevel && H.wear_suit)
							contrabandLevel += H.wear_suit.contraband

						if (contrabandLevel > 0)
							arrestState = "Contraband"

			if (H.arrestIcon.icon_state != arrestState)
				H.arrestIcon.icon_state = arrestState

		..()

/datum/lifeprocess/stuns_lying
	var/last_recovering_msg = 0

	process()
		//proc/handle_stuns_lying(datum/controller/process/mobs/parent)
		var/lying_old = owner.lying
		var/cant_lie = robot_owner || hivebot_owner || (human_owner && (human_owner.limbs && istype(human_owner.limbs.l_leg, /obj/item/parts/robot_parts/leg/left/treads) && istype(human_owner.limbs.r_leg, /obj/item/parts/robot_parts/leg/right/treads) && !locate(/obj/table, human_owner.loc) && !locate(/obj/machinery/optable, human_owner.loc)))

		var/list/statusList = owner.getStatusList()

		var/must_lie = statusList["resting"] || (!cant_lie && human_owner && human_owner.limbs && !human_owner.limbs.l_leg && !human_owner.limbs.r_leg) //hasn't got a leg to stand on... haaa

		var/changeling_fakedeath = 0
		var/datum/abilityHolder/changeling/C = owner.get_ability_holder(/datum/abilityHolder/changeling)
		if (C && C.in_fakedeath)
			changeling_fakedeath = 1

		if (!isdead(owner)) //Alive.
			if (statusList["paralysis"] || statusList["stunned"] || statusList["weakened"] || statusList["pinned"] || changeling_fakedeath || statusList["resting"]) //Stunned etc.
				var/setStat = owner.stat
				var/oldStat = owner.stat
				if (statusList["stunned"])
					setStat = 0
				if (statusList["weakened"] || statusList["pinned"] && !owner.fakedead)
					if (!cant_lie)
						owner.lying = 1
					setStat = 0
				if (statusList["paralysis"])
					if (!cant_lie)
						owner.lying = 1
					setStat = 1
				if (isalive(owner) && setStat == 1 && owner.mind)
					owner.lastgasp() // calling lastgasp() here because we just got knocked out
				if (must_lie)
					owner.lying = 1

				owner.stat = setStat
				owner.empty_hands()

				if (world.time - last_recovering_msg >= 60 || last_recovering_msg == 0)
					if (prob(10))
						last_recovering_msg = world.time
						//chance to heal self by minute amounts each 'recover' tick
						owner.take_oxygen_deprivation(-0.3)
						owner.lose_breath(-0.3)
						owner.HealDamage("All", 0.2, 0.2, 0.2)

				else if ((oldStat == 1) && (!statusList["paralysis"] && !statusList["stunned"] && !statusList["weakened"] && !changeling_fakedeath))
					owner << sound('sound/misc/molly_revived.ogg', volume=50)
					setalive(owner)

			else	//Not stunned.
				owner.lying = must_lie ? 1 : 0
				setalive(owner)

		else //Dead.
			owner.lying = cant_lie ? 0 : 1
			owner.blinded = 1
			setdead(owner)

		if (owner.lying != lying_old)
			owner.update_lying()
			owner.set_density(!owner.lying)

			if (owner.lying && !owner.buckled)
				if (human_owner)
					playsound(owner.loc, 'sound/misc/body_thud.ogg', 40, 1, 0.3)
				else
					playsound(owner.loc, 'sound/misc/body_thud.ogg', 15, 1, 0.3)
		..()

/datum/lifeprocess/canmove
	process()
		//check_if_buckled()
		if (owner.buckled)
			if (owner.buckled.loc != owner.loc)
				owner.buckled = null
				return
			owner.lying = istype(owner.buckled, /obj/stool/bed) || istype(owner.buckled, /obj/machinery/conveyor)
			if (owner.lying)
				owner.drop_item()
			owner.set_density(initial(owner.density))
		else
			if (!owner.lying)
				owner.set_density(initial(owner.density))
			else
				owner.set_density(0)

		//update_canmove

		if (HAS_MOB_PROPERTY(owner, PROP_CANTMOVE))
			owner.canmove = 0
			return

		if (owner.buckled && owner.buckled.anchored)
			if (istype(owner.buckled, /obj/stool/chair)) //this check so we can still rotate the chairs on their slower delay even if we are anchored
				var/obj/stool/chair/chair = owner.buckled
				if (!chair.rotatable)
					owner.canmove = 0
					return
			else
				owner.canmove = 0
				return

		if (owner.throwing & (THROW_CHAIRFLIP | THROW_GUNIMPACT | THROW_SLIP))
			owner.canmove = 0
			return

		owner.canmove = 1

		..()

/datum/lifeprocess/hud
	process()
		if (!owner.client) return ..()

		//proc/handle_regular_hud_updates()
		if (owner.stamina_bar) owner.stamina_bar.update_value(src)
		//hud.update_indicators()


		if (robot_owner)
			robot_owner.hud.update_health()
			robot_owner.hud.update_charge()
			robot_owner.hud.update_pulling()
			robot_owner.hud.update_environment()

		if (hivebot_owner)
			if (ticker?.mode && istype(ticker.mode, /datum/game_mode/construction))
				hivebot_owner.see_invisible = 9

		if (critter_owner)
			critter_owner.hud.update_health()

		if (human_owner)
			human_owner.hud.update_health_indicator()
			human_owner.hud.update_temp_indicator()
			human_owner.hud.update_blood_indicator()
			human_owner.hud.update_pulling()

			var/color_mod_r = 255
			var/color_mod_g = 255
			var/color_mod_b = 255
			if (istype(human_owner.glasses))
				color_mod_r *= human_owner.glasses.color_r
				color_mod_g *= human_owner.glasses.color_g
				color_mod_b *= human_owner.glasses.color_b
			if (istype(human_owner.wear_mask))
				color_mod_r *= human_owner.wear_mask.color_r
				color_mod_g *= human_owner.wear_mask.color_g
				color_mod_b *= human_owner.wear_mask.color_b
			if (istype(human_owner.head))
				color_mod_r *= human_owner.head.color_r
				color_mod_g *= human_owner.head.color_g
				color_mod_b *= human_owner.head.color_b
			var/obj/item/organ/eye/L_E = human_owner.get_organ("left_eye")
			if (istype(L_E))
				color_mod_r *= L_E.color_r
				color_mod_g *= L_E.color_g
				color_mod_b *= L_E.color_b
			var/obj/item/organ/eye/R_E = human_owner.get_organ("right_eye")
			if (istype(R_E))
				color_mod_r *= R_E.color_r
				color_mod_g *= R_E.color_g
				color_mod_b *= R_E.color_b

			if (human_owner.druggy)
				human_owner.vision.animate_color_mod(rgb(rand(0, 255), rand(0, 255), rand(0, 255)), 15)
			else
				human_owner.vision.set_color_mod(rgb(color_mod_r, color_mod_g, color_mod_b))

			if (istype(human_owner.glasses, /obj/item/clothing/glasses/healthgoggles))
				var/obj/item/clothing/glasses/healthgoggles/G = human_owner.glasses
				if (human_owner.client && !(G.assigned || G.assigned == human_owner.client))
					G.assigned = human_owner.client
					if (!(G in processing_items))
						processing_items.Add(G)
					//G.updateIcons()

			if (istype(human_owner.head, /obj/item/clothing/head/helmet/space/syndicate/specialist/medic))
				var/obj/item/clothing/head/helmet/space/syndicate/specialist/medic/M = human_owner.head
				if (human_owner.client && !(M.assigned || M.assigned == human_owner.client))
					M.assigned = human_owner.client
					if (!(M in processing_items))
						processing_items.Add(M)
					//G.updateIcons()

			else if (human_owner.organHolder && istype(human_owner.organHolder.left_eye, /obj/item/organ/eye/cyber/prodoc))
				var/obj/item/organ/eye/cyber/prodoc/G = human_owner.organHolder.left_eye
				if (human_owner.client && !(G.assigned || G.assigned == human_owner.client))
					G.assigned = human_owner.client
					if (!(G in processing_items))
						processing_items.Add(G)
					//G.updateIcons()
			else if (human_owner.organHolder && istype(human_owner.organHolder.right_eye, /obj/item/organ/eye/cyber/prodoc))
				var/obj/item/organ/eye/cyber/prodoc/G = human_owner.organHolder.right_eye
				if (human_owner.client && !(G.assigned || G.assigned == human_owner.client))
					G.assigned = human_owner.client
					if (!(G in processing_items))
						processing_items.Add(G)
					//G.updateIcons()
		else
			if (owner.druggy)
				human_owner.vision.animate_color_mod(rgb(rand(0, 255), rand(0, 255), rand(0, 255)), 15)
			else
				human_owner.vision.set_color_mod("#FFFFFF")
		..()
/datum/lifeprocess/sight
	process()
		if (!owner.client) return ..()
		//proc/handle_regular_sight_updates()

////Mutrace and normal sight
		owner.sight |= SEE_BLACKNESS
		if (!isdead(owner))
			owner.sight &= ~SEE_TURFS
			owner.sight &= ~SEE_MOBS
			owner.sight &= ~SEE_OBJS

			if (human_owner?.mutantrace)
				human_owner.mutantrace.sight_modifier()
			else
				owner.see_in_dark = SEE_DARK_HUMAN
				owner.see_invisible = 0

			if (owner.client)
				if((owner.traitHolder && owner.traitHolder.hasTrait("cateyes")) || (owner.getStatusDuration("food_cateyes")))
					owner.render_special.set_centerlight_icon("cateyes")
				else
					owner.render_special.set_centerlight_icon("default")

			if (human_owner && isvampire(human_owner))
				if (human_owner.check_vampire_power(1) == 1 && !isrestrictedz(human_owner.z))
					human_owner.sight |= SEE_MOBS
					human_owner.see_invisible = 2

////Dead sight
		var/turf/T = owner.eye ? get_turf(owner.eye) : get_turf(owner) //They might be in a closet or something idk
		if ((isdead(owner) ||( owner.bioHolder && owner.bioHolder.HasEffect("xray"))) && (T && !isrestrictedz(T.z)))
			owner.sight |= SEE_TURFS
			owner.sight |= SEE_MOBS
			owner.sight |= SEE_OBJS
			owner.see_in_dark = SEE_DARK_FULL
			if (owner.client?.adventure_view)
				owner.see_invisible = 21
			else
				owner.see_invisible = 2
			return
		else
			if (robot_owner)
				//var/sight_therm = 0 //todo fix this
				var/sight_meson = 0
				var/sight_constr = 0
				for (var/obj/item/roboupgrade/R in robot_owner.upgrades)
					if (R && istype(R, /obj/item/roboupgrade/visualizer) && R.activated)
						sight_constr = 1
					if (R && istype(R, /obj/item/roboupgrade/opticmeson) && R.activated)
						sight_meson = 1
					//if (R && istype(R, /obj/item/roboupgrade/opticthermal) && R.activated)
					//	sight_therm = 1

				if (sight_meson)
					robot_owner.sight &= ~SEE_BLACKNESS
					robot_owner.sight |= SEE_TURFS
					robot_owner.render_special.set_centerlight_icon("meson", rgb(0.5 * 255, 0.5 * 255, 0.5 * 255))
					robot_owner.vision.set_scan(1)
					robot_owner.client.color = "#c2ffc2"
				else
					robot_owner.sight |= SEE_BLACKNESS
					robot_owner.sight &= ~SEE_TURFS
					robot_owner.client.color = null
					robot_owner.vision.set_scan(0)
				//if (sight_therm)
				//	src.sight |= SEE_MOBS //todo make borg thermals have a purpose again
				//else
				//	src.sight &= ~SEE_MOBS

				if (sight_constr)
					robot_owner.see_invisible = 9
				else
					robot_owner.see_invisible = 2

				robot_owner.sight &= ~SEE_OBJS
				robot_owner.see_in_dark = SEE_DARK_FULL
////Ship sight
		if (istype(owner.loc, /obj/machinery/vehicle))
			var/obj/machinery/vehicle/ship = owner.loc
			if (ship.sensors)
				if (ship.sensors.active)
					owner.sight |= ship.sensors.sight
					owner.sight &= ~ship.sensors.antisight
					owner.see_in_dark = ship.sensors.see_in_dark
					if (owner.client?.adventure_view)
						owner.see_invisible = 21
					else
						owner.see_invisible = ship.sensors.see_invisible
					if(ship.sensors.centerlight)
						owner.render_special.set_centerlight_icon(ship.sensors.centerlight, ship.sensors.centerlight_color)
					return

		if (owner.traitHolder && owner.traitHolder.hasTrait("infravision"))
			if (owner.see_infrared < 1)
				owner.see_infrared = 1
////Reagents
		if (owner.reagents.has_reagent("green_goop") && (T && !isrestrictedz(T.z)))
			if (owner.see_in_dark != 1)
				owner.see_in_dark = 1
			if (owner.see_invisible < 15)
				owner.see_invisible = 15

		if (owner.client?.adventure_view)
			owner.see_invisible = 21




		if (human_owner)////Glasses handled separately because i dont have a fast way to get glasses on any mob type

			if (istype(human_owner.glasses, /obj/item/clothing/glasses/construction) && (T && !isrestrictedz(T.z)))
				if (human_owner.see_in_dark < initial(human_owner.see_in_dark) + 1)
					human_owner.see_in_dark++
				if (human_owner.see_invisible < 8)
					human_owner.see_invisible = 8

			else if (istype(human_owner.glasses, /obj/item/clothing/glasses/thermal/traitor))
				human_owner.sight |= SEE_MOBS //traitor item can see through walls
				human_owner.sight &= ~SEE_BLACKNESS
				if (human_owner.see_in_dark < SEE_DARK_FULL)
					human_owner.see_in_dark = SEE_DARK_FULL
				if (human_owner.see_invisible < 2)
					human_owner.see_invisible = 2
				if (human_owner.see_infrared < 1)
					human_owner.see_infrared = 1
				human_owner.render_special.set_centerlight_icon("thermal", rgb(0.5 * 255, 0.5 * 255, 0.5 * 255))

			else if ((istype(human_owner.glasses, /obj/item/clothing/glasses/thermal) || human_owner.eye_istype(/obj/item/organ/eye/cyber/thermal)))	//  && (T && !isrestrictedz(T.z))
				// This kinda fucks up the ability to hide things in infra writing in adv zones
				// so away the restricted z check goes.
				// with mobs invisible it shouldn't matter anyway? probably? idk.
				//src.sight |= SEE_MOBS
				if (human_owner.see_in_dark < initial(human_owner.see_in_dark) + 4)
					human_owner.see_in_dark += 4
				if (human_owner.see_invisible < 2)
					human_owner.see_invisible = 2
				if (human_owner.see_infrared < 1)
					human_owner.see_infrared = 1
				human_owner.render_special.set_centerlight_icon("thermal", rgb(0.5 * 255, 0.5 * 255, 0.5 * 255))

			else if (istype(human_owner.wear_mask, /obj/item/clothing/mask/hunter) && (T && !isrestrictedz(T.z)))
				human_owner.sight |= SEE_MOBS // Hunters kinda need proper thermal vision, I've found in playtesting (Convair880).
				if (human_owner.see_in_dark < SEE_DARK_FULL)
					human_owner.see_in_dark = SEE_DARK_FULL
				if (human_owner.see_invisible < 2)
					human_owner.see_invisible = 2
				human_owner.render_special.set_centerlight_icon("thermal", rgb(0.5 * 255, 0.5 * 255, 0.5 * 255))

			else if (istype(human_owner.glasses, /obj/item/clothing/glasses/regular/ecto) || human_owner.eye_istype(/obj/item/organ/eye/cyber/ecto))
				if (human_owner.see_in_dark != 1)
					human_owner.see_in_dark = 1
				if (human_owner.see_invisible < 15)
					human_owner.see_invisible = 15

			else if (istype(human_owner.glasses, /obj/item/clothing/glasses/nightvision) || human_owner.eye_istype(/obj/item/organ/eye/cyber/nightvision) || human_owner.bioHolder && human_owner.bioHolder.HasEffect("nightvision"))
				human_owner.render_special.set_centerlight_icon("nightvision", rgb(0.5 * 255, 0.5 * 255, 0.5 * 255))

			else if (istype(human_owner.glasses, /obj/item/clothing/glasses/meson) && (T && !isrestrictedz(T.z)))
				var/obj/item/clothing/glasses/meson/M = human_owner.glasses
				if (M.on)
					human_owner.sight |= SEE_TURFS
					human_owner.sight &= ~SEE_BLACKNESS
					if (human_owner.see_in_dark < initial(human_owner.see_in_dark) + 1)
						human_owner.see_in_dark++
					human_owner.render_special.set_centerlight_icon("meson", rgb(0.5 * 255, 0.5 * 255, 0.5 * 255), wide = (human_owner.client?.widescreen))

			else if (istype(human_owner.head, /obj/item/clothing/head/helmet/space/syndicate/specialist/engineer) && (T && !isrestrictedz(T.z)))
				var/obj/item/clothing/head/helmet/space/syndicate/specialist/engineer/E = human_owner.head
				if (E.on)
					human_owner.sight |= SEE_TURFS
					human_owner.sight &= ~SEE_BLACKNESS
					if (human_owner.see_in_dark < initial(human_owner.see_in_dark) + 1)
						human_owner.see_in_dark++
					human_owner.render_special.set_centerlight_icon("meson", rgb(0.5 * 255, 0.5 * 255, 0.5 * 255), wide = (human_owner.client?.widescreen))

			else if (human_owner.eye_istype(/obj/item/organ/eye/cyber/meson) && (T && !isrestrictedz(T.z)))
				if (!istype(human_owner.glasses, /obj/item/clothing/glasses/meson))
					var/eye_on
					if (human_owner.organ_istype("left_eye", /obj/item/organ/eye/cyber/meson))
						var/obj/item/organ/eye/cyber/meson/meson_eye = human_owner.organHolder.left_eye
						if (meson_eye.on) eye_on = 1
					if (human_owner.organ_istype("right_eye", /obj/item/organ/eye/cyber/meson))
						var/obj/item/organ/eye/cyber/meson/meson_eye = human_owner.organHolder.right_eye
						if (meson_eye.on) eye_on = 1
					if (eye_on)
						human_owner.sight |= SEE_TURFS
						human_owner.sight &= ~SEE_BLACKNESS
						if (human_owner.see_in_dark < initial(human_owner.see_in_dark) + 1)
							human_owner.see_in_dark++
						human_owner.render_special.set_centerlight_icon("meson", rgb(0.5 * 255, 0.5 * 255, 0.5 * 255), wide = (human_owner.client?.widescreen))

		..()

/datum/lifeprocess/blindness
	process()
		if (!owner.client) return ..()

		owner.vision.animate_dither_alpha(owner.get_eye_blurry() / 10 * 255, 15) // animate it so that it doesnt "jump" as much

		if (human_owner)
			var/eyes_blinded = 0

			if (!isdead(human_owner))
				if (!human_owner.sight_check(1))
					eyes_blinded |= EYEBLIND_L
					eyes_blinded |= EYEBLIND_R
				else
					if (!human_owner.get_organ("left_eye"))
						eyes_blinded |= EYEBLIND_L
					if (!human_owner.get_organ("right_eye"))
						eyes_blinded |= EYEBLIND_R
					if (istype(human_owner.glasses))
						if (human_owner.glasses.block_eye)
							if (human_owner.glasses.block_eye == "L")
								eyes_blinded |= EYEBLIND_L
							else
								eyes_blinded |= EYEBLIND_R
						if (human_owner.glasses.allow_blind_sight)
							eyes_blinded = 0

			if (human_owner.last_eyes_blinded == eyes_blinded) // we don't need to update!
				return 1


			if (!eyes_blinded) // neither eye is blind
				human_owner.removeOverlayComposition(/datum/overlayComposition/blinded)
				human_owner.removeOverlayComposition(/datum/overlayComposition/blinded_l_eye)
				human_owner.removeOverlayComposition(/datum/overlayComposition/blinded_r_eye)

			else if ((eyes_blinded & EYEBLIND_L) && (eyes_blinded & EYEBLIND_R)) // both eyes are blind
				human_owner.addOverlayComposition(/datum/overlayComposition/blinded)
				human_owner.removeOverlayComposition(/datum/overlayComposition/blinded_l_eye)
				human_owner.removeOverlayComposition(/datum/overlayComposition/blinded_r_eye)

			else if (eyes_blinded & EYEBLIND_L) // left eye is blind, not right
				human_owner.removeOverlayComposition(/datum/overlayComposition/blinded)
				human_owner.addOverlayComposition(/datum/overlayComposition/blinded_l_eye)
				human_owner.removeOverlayComposition(/datum/overlayComposition/blinded_r_eye)

			else if (eyes_blinded & EYEBLIND_R) // right eye is blind, not left
				human_owner.removeOverlayComposition(/datum/overlayComposition/blinded)
				human_owner.removeOverlayComposition(/datum/overlayComposition/blinded_l_eye)
				human_owner.addOverlayComposition(/datum/overlayComposition/blinded_r_eye)

			else // edge case?  remove overlays just in case
				human_owner.removeOverlayComposition(/datum/overlayComposition/blinded)
				human_owner.removeOverlayComposition(/datum/overlayComposition/blinded_l_eye)
				human_owner.removeOverlayComposition(/datum/overlayComposition/blinded_r_eye)

			human_owner.last_eyes_blinded = eyes_blinded
		else
			if (!owner.sight_check(1) && !isdead(owner))
				owner.addOverlayComposition(/datum/overlayComposition/blinded) //ov1
			else
				owner.removeOverlayComposition(/datum/overlayComposition/blinded) //ov1
		..()


/mob/living
	var/list/lifeprocesses = list()

	//remove these evntually cause lifeporcesses handl ethem
	var/last_life_tick = 0 //and this ones just the whole lifetick
	var/const/tick_spacing = 20 //This should pretty much *always* stay at 20, for it is the one number that all do-over-time stuff should be balanced around
	var/const/cap_tick_spacing = 90 //highest timeofday allowance between ticks to try to play catchup with realtime thingo
	var/last_stam_change = 0

	var/life_context = "begin"

	var/metabolizes = 1

	var/can_bleed = 1
	blood_id = "blood"
	var/blood_volume = 300
	var/blood_pressure = null
	var/blood_color = DEFAULT_BLOOD_COLOR
	var/bleeding = 0
	var/bleeding_internal = 0
	var/blood_absorption_rate = 1 // amount of blood to absorb from the reagent holder per Life()
	var/list/bandaged = list()
	var/being_staunched = 0 // is someone currently putting pressure on their wounds?

	var/co2overloadtime = null
	var/temperature_resistance = T0C+75


	var/stamina = STAMINA_MAX
	var/stamina_max = STAMINA_MAX
	var/stamina_regen = STAMINA_REGEN
	var/stamina_crit_chance = STAMINA_CRIT_CHANCE
	var/list/stamina_mods_regen = list()
	var/list/stamina_mods_max = list()

	var/list/stomach_contents = list()

	var/last_sleep = 0 //used for sleep_bubble

	proc/add_lifeprocess(type)
		var/datum/lifeprocess/L = new(src)
		lifeprocesses[type] = L

	proc/remove_lifeprocess(type)
		for (var/thing in lifeprocesses)
			if (thing)
				var/datum/lifeprocess/L = thing
				if (L.type == type)
					lifeprocesses -= L
				qdel(L)

	proc/get_heat_protection()
		.= 0
	proc/get_cold_protection()
		.= 0
	proc/get_rad_protection()
		.= 0

/mob/living/carbon/human
	var/last_human_life_tick = 0

/mob/living/New()
	..()
	//wel gosh, its important that we do this otherwisde the crew could spawn into an airless room and then immediately die
	last_life_tick = TIME

/mob/living/disposing()
	..()
	for (var/datum/lifeprocess/L in lifeprocesses)
		remove_lifeprocess(L)

/mob/living/carbon/human
	var/list/heartbeatOverlays = list()

	can_bleed = 1
	blood_id = "blood"
	blood_volume = 500


/mob/living/carbon/human/New()
	..()
	for(var/X in typesof(/datum/lifeprocess))
		add_lifeprocess(X)

/mob/living/carbon/human
	proc/Thumper_createHeartbeatOverlays()
		for (var/mob/x in (src.observers + src))
			if(!heartbeatOverlays[x] && x.client)
				var/obj/screen/hb = new
				hb.icon = x.client.widescreen ? 'icons/effects/overlays/crit_thicc.png' : 'icons/effects/overlays/crit_thin.png'
				hb.screen_loc = "1,1"
				hb.layer = HUD_LAYER_UNDER_2
				hb.plane = PLANE_HUD
				hb.mouse_opacity = 0
				x.client.screen += hb
				heartbeatOverlays[x] = hb
			else if(x.client && !(heartbeatOverlays[x] in x.client.screen))
				x.client.screen += heartbeatOverlays[x]
	proc/Thumper_thump(var/animateInitial)
		Thumper_createHeartbeatOverlays()
		var/sound/thud = sound('sound/effects/thump.ogg')
#define HEARTBEAT_THUMP_APERTURE 3.5
#define HEARTBEAT_THUMP_BASE 5
#define HEARTBEAT_THUMP_INTENSITY 0.2
#define HEARTBEAT_THUMP_INTENSITY_BASE 0.1
		for(var/mob/x in src.heartbeatOverlays)
			var/obj/screen/overlay = src.heartbeatOverlays[x]
			if(x.client)
				x.client << thud
				if(animateInitial)
					animate(overlay, alpha=255, color=list( list(HEARTBEAT_THUMP_INTENSITY,0,0,0), list( 0,0,0,0 ), list(0,0,0,0), list(0,0,0,HEARTBEAT_THUMP_APERTURE)), 10, easing=ELASTIC_EASING)
					animate(color=list( list(HEARTBEAT_THUMP_INTENSITY_BASE,0,0,0), list( 0,0,0,0 ), list(0,0,0,0), list(0,0,0,HEARTBEAT_THUMP_BASE), list(0,0,0,0) ), 10, easing=ELASTIC_EASING, flags=ANIMATION_END_NOW)
				else
					//src << sound('sound/thump.ogg')
					overlay.color=list( list(0.16,0,0,0), list( 0,0,0,0 ), list(0,0,0,0), list(0,0,0,2.6), list(0,0,0,0) )//, 5, 0, ELASTIC_EASING)
					animate(overlay, color=list( list(0.13,0,0,0), list( 0,0,0,0 ), list(0,0,0,0), list(0,0,0,3.5), list(0,0,0,0) ), 13, easing = ELASTIC_EASING, flags = ANIMATION_END_NOW)


#undef HEARTBEAT_THUMP_APERTURE
#undef HEARTBEAT_THUMP_BASE
#undef HEARTBEAT_THUMP_INTENSITY
#undef HEARTBEAT_THUMP_INTENSITY_BASE
	var/doThumps = 0
	proc/Thumper_theThumpening()
		if(doThumps) return
		doThumps = 1
		Thumper_thump(1)
		SPAWN_DBG(2 SECONDS)
			while(src.doThumps)
				Thumper_thump(0)
				sleep(2 SECONDS)
	proc/Thumper_stopThumps()
		doThumps = 0
	proc/Thumper_paralyzed()
		Thumper_createHeartbeatOverlays()
		if(doThumps)//we're thumping dangit
			doThumps = 0
		for(var/mob/x in src.heartbeatOverlays)
			var/obj/screen/overlay = src.heartbeatOverlays[x]
			if(x.client)
				animate(overlay, alpha = 255,
					color = list( list(0,0,0,0), list( 0,0,0,0 ), list(0,0,0,0), list(0,0,0,4) ),
					10, flags=ANIMATION_END_NOW)//adjust the 4 to adjust aperture size
	proc/Thumper_crit()
		Thumper_createHeartbeatOverlays()
		if(doThumps)
			doThumps = 0
		for(var/mob/x in src.heartbeatOverlays)
			var/obj/screen/overlay = src.heartbeatOverlays[x]
			if(x.client)
				animate(overlay,
					alpha = 255,
					color = list( list(0.1,0,0,0), list( 0,0,0,0 ), list(0,0,0,0), list(0,0,0,0.8), list(0,0,0,0) ),
				time = 10, easing = SINE_EASING)

	proc/Thumper_restore()
		Thumper_createHeartbeatOverlays()
		doThumps = 0
		for(var/mob/x in src.heartbeatOverlays)
			var/obj/screen/overlay = src.heartbeatOverlays[x]
			if(x.client)
				animate(overlay, color = list( list(0,0,0,0), list( 0,0,0,0 ), list(0,0,0,0), list(0,0,0,-100), list(0,0,0,0) ), alpha = 0, 20, SINE_EASING )

/mob/living/Life(datum/controller/process/mobs/parent)
	set invisibility = 0
	if (..())
		return 1

	if (src.transforming)
		return 1

	var/life_time_passed = max(tick_spacing, world.timeofday - last_life_tick)

	// Jewel's attempted fix for: null.return_air()
	// These objects should be garbage collected the next tick, so it's not too bad if it's not breathing I think? I might be totallly wrong here.
	if (loc)
		clamp_values()

		var/datum/gas_mixture/environment = loc.return_air()

		src.blinded = null//needs to be set here, multiple life processes will be affecting it ewwww

		///LIFE PROCESS
		//Most stuff gets handled here but i've left some other code below because all living mobs can use it
		for (var/datum/lifeprocess/L in lifeprocesses)
			L.process(environment)

		for (var/obj/item/implant/I in src.implant)
			I.on_life((life_time_passed / tick_spacing))

		update_item_abilities()

		update_objectives()

		if (!isdead(src)) //still breathing
			//do on_life things for components?
			SEND_SIGNAL(src, COMSIG_HUMAN_LIFE_TICK, (life_time_passed / tick_spacing))

			if(src.no_gravity)
				src.no_gravity = 0
				animate(src, transform = matrix(), time = 1)

			for (var/obj/item/I in src)
				if (I.no_gravity)
					src.no_gravity = 1
				if (!I.material)
					continue
				I.material.triggerOnLife(src, I)

			if(src.no_gravity)
				animate_levitate(src, -1, 10, 1)

		clamp_values()

		//Regular Trait updates
		if(src.traitHolder)
			for(var/T in src.traitHolder.traits)
				var/obj/trait/O = getTraitById(T)
				O.onLife(src)

		update_icons_if_needed()

		if (src.client) //ov1
			// overlays
			src.updateOverlaysClient(src.client)
			src.antagonist_overlay_refresh(0, 0)

		if (src.observers.len)
			for (var/mob/x in src.observers)
				if (x.client)
					src.updateOverlaysClient(x.client)

		for (var/obj/item/grab/G in src.equipped_list(check_for_magtractor = 0))
			G.process((life_time_passed / tick_spacing))


		if (!can_act(M=src,include_cuffs=0))
			actions.interrupt(src, INTERRUPT_STUNNED)

		//rev mutiny
		//change this to trigger from the sign, not the revs!!
		if (src.mind && ticker.mode && ticker.mode.type == /datum/game_mode/revolution)
			var/datum/game_mode/revolution/R = ticker.mode

			if ((src.mind in R.revolutionaries) || (src.mind in R.head_revolutionaries))
				var/found = 0
				for (var/datum/mind/M in R.head_revolutionaries)
					if (M.current && ishuman(M.current))
						if (get_dist(src,M.current) <= 5)
							for (var/obj/item/revolutionary_sign/RS in M.current.equipped_list(check_for_magtractor = 0))
								found = 1
								break
				if (found)
					src.changeStatus("revspirit", 20 SECONDS)


		if (src.abilityHolder)
			//MBC : update countdowns on topbar screen abilities
			var/show = 1
			if (ishuman(src))//FUCKKK FIX THIS
				var/mob/living/carbon/human/H = src
				show = (H.hud.current_ability_set == 1)
			if (show)
				if (istype(src.abilityHolder,/datum/abilityHolder/composite))
					var/datum/abilityHolder/composite/composite = src.abilityHolder
					for (var/datum/abilityHolder/H in composite.holders)
						for(var/datum/targetable/B in H.abilities)
							if (B.display_available())
								var/obj/screen/ability/topBar/button = B.object
								if (istype(B))
									button.update_on_hud(button.last_x, button.last_y)
				else
					for(var/datum/targetable/B in src.abilityHolder.abilities)
						if (B.display_available())
							var/obj/screen/ability/topBar/button = B.object
							if (istype(B))
								button.update_on_hud(button.last_x, button.last_y)


			src.abilityHolder.onLife((life_time_passed / tick_spacing))

	last_life_tick = TIME

//LIFE() PROCS THAT ARE HIGHLY SPECIFIC ABOUT WHAT MOB THEY RUN
//THIS INCLUDES EVERYTHING I COULDNT FIGURE OUT HOW TO WORK INTO A LIFEPROCESS NICELY

/mob/living/carbon/human/Life(datum/controller/process/mobs/parent)
	if (..(parent))
		return 1

	var/mult = (max(tick_spacing, world.timeofday - last_human_life_tick) / tick_spacing)

	if (farty_party)
		src.emote("fart")

	//Attaching a limb that didn't originally belong to you can do stuff
	if(prob(2) && src.limbs)
		if(src.limbs.l_arm && istype(src.limbs.l_arm, /obj/item/parts/human_parts/arm/))
			var/obj/item/parts/human_parts/arm/A = src.limbs.l_arm
			if(A.original_holder && src != A.original_holder)
				A.foreign_limb_effect()
		if(src.limbs.r_arm && istype(src.limbs.r_arm, /obj/item/parts/human_parts/arm/))
			var/obj/item/parts/human_parts/arm/B = src.limbs.r_arm
			if(B.original_holder && src != B.original_holder)
				B.foreign_limb_effect()
		if(src.limbs.l_leg && istype(src.limbs.l_leg, /obj/item/parts/human_parts/leg/))
			var/obj/item/parts/human_parts/leg/C = src.limbs.l_leg
			if(C.original_holder && src != C.original_holder)
				C.foreign_limb_effect()
		if(src.limbs.r_leg && istype(src.limbs.r_leg, /obj/item/parts/human_parts/leg/))
			var/obj/item/parts/human_parts/leg/D = src.limbs.r_leg
			if(D.original_holder && src != D.original_holder)
				D.foreign_limb_effect()

	if (src.mutantrace)
		src.mutantrace.onLife(mult)

	if (!isdead(src)) // Marq was here, breaking everything.

		if (src.sims && src.ckey) // ckey will be null if it's an npc, so they're skipped
			src.sims.Life()

		if (prob(1) && prob(5))
			src.handle_random_emotes()

	src.handle_pathogens()

	last_human_life_tick = TIME

/mob/living/critter/Life(datum/controller/process/mobs/parent)
	if (..(parent))
		return 1

	if (!isdead(src))
		update_stunned_icon(canmove)

		for (var/T in healthlist)
			var/datum/healthHolder/HH = healthlist[T]
			HH.Life()

/mob/living/silicon/Life(datum/controller/process/mobs/parent)
	if (..(parent))
		return 1
	if (!isdead(src))
		use_power()

/mob/living/silicon/robot/Life(datum/controller/process/mobs/parent)
	if (..(parent))
		return 1

	src.mainframe_check()

	if (!isdead(src)) //Alive.
		// AI-controlled cyborgs always use the global lawset, so none of this applies to them (Convair880).
		if ((src.emagged || src.syndicate) && src.mind && !src.dependent)
			if (!src.mind.special_role)
				src.handle_robot_antagonist_status()

	process_killswitch()
	process_locks()
	process_oil()

	if (metalman_skin && prob(1))
		var/msg = pick("can't see...","feels bad...","leave me...", "you're cold...", "unwelcome...")
		src.show_text(voidSpeak(msg))
		src.emagged = 1

/mob/living/silicon/ai/Life(datum/controller/process/mobs/parent)
	if (..(parent))
		return 1

	if (isalive(src))
		if (src.health < 0)
			death()
	else
		tracker.cease_track()
		src:current = null
		if (src.health >= 0)
			// sure keep trying to use power i guess.
			use_power()

	// Assign antag status if we don't have any yet (Convair880).
	if (src.mind && (src.emagged || src.syndicate))
		if (!src.mind.special_role)
			src.handle_robot_antagonist_status()

	hud.update()
	process_killswitch()
	process_locks()

/mob/living/silicon/hivebot/Life(datum/controller/process/mobs/parent)
	if (..(parent))
		return 1

	if(health <= 0)
		gib(1)

	if(client)
		src.shell = 0
		if(dependent)
			mainframe_check()


/mob/living/
	proc/clamp_values()
		sleeping = clamp(sleeping, 0, 20)
		stuttering = clamp(stuttering, 0, 50)
		losebreath = clamp(losebreath, 0, 25) // stop going up into the thousands, goddamn

	proc/handle_burning()
		if (src.getStatusDuration("burning"))

			if (src.getStatusDuration("burning") > 200)
				for(var/atom in src.contents)
					var/atom/A = atom
					if (A.event_handler_flags & HANDLE_STICKER)
						if (A:active)
							src.visible_message("<span class='alert'><b>[A]</b> is burnt to a crisp and destroyed!</span>")
							qdel(A)

			if (isturf(src.loc))
				var/turf/location = src.loc
				location.hotspot_expose(T0C + 300, 400)

			for (var/atom/A in src.contents)
				if (A.material)
					A.material.triggerTemp(A, T0C + 900)

			if(src.traitHolder && src.traitHolder.hasTrait("burning"))
				if(prob(50))
					src.update_burning(1)

	proc/stink()
		if (prob(15))
			for (var/mob/living/carbon/C in view(6,get_turf(src)))
				if (C == src || !C.client)
					continue
				boutput(C, "<span class='alert'>[stinkString()]</span>")
				if (prob(30))
					C.vomit()
					C.changeStatus("stunned", 2 SECONDS)
					boutput(C, "<span class='alert'>[stinkString()]</span>")


	proc/update_objectives()
		if (!src.mind)
			return
		if (!src.mind.objectives)
			return
		if (!istype(src.mind.objectives, /list))
			return
		if (src.mind.stealth_objective)
			for (var/datum/objective/O in src.mind.objectives)
				if (istype(O, /datum/objective/specialist/stealth))
					var/turf/T = get_turf_loc(src)
					if (T && isturf(T) && (istype(T, /turf/space) || T.loc.name == "Space" || T.loc.name == "Ocean" || T.z != 1))
						O:score = max(0, O:score - 1)
						if (prob(20))
							boutput(src, "<span class='alert'><B>Being away from the station is making you lose your composure...</B></span>")
						src << sound('sound/effects/env_damage.ogg')
						continue
					if (T && isturf(T) && T.RL_GetBrightness() < 0.2)
						O:score++
					else
						var/spotted_by_mob = 0
						for (var/mob/living/M in oviewers(src, 5))
							if (M.client && M.sight_check(1))
								O:score = max(0, O:score - 5)
								spotted_by_mob = 1
								break
						if (!spotted_by_mob)
							O:score++

	proc/update_canmove()
		var/datum/lifeprocess/L = lifeprocesses[/datum/lifeprocess/canmove]
		if (L)
			L.process()

	proc/update_sight()
		var/datum/lifeprocess/L = lifeprocesses[/datum/lifeprocess/sight]
		if (L)
			L.process()

	force_laydown_standup() //immediately force a laydown
		//if (processScheduler.hasProcess("Mob"))
		//	var/datum/controller/process/P = processScheduler.nameToProcessMap["Mob"]
		//	src.handle_stuns_lying(P)
		var/datum/lifeprocess/L = lifeprocesses[/datum/lifeprocess/stuns_lying]
		if (L)
			L.process()
		L = lifeprocesses[/datum/lifeprocess/canmove]
		if (L)
			L.process()
		L = lifeprocesses[/datum/lifeprocess/blindness]
		if (L)
			L.process()

		if (src.client)
			updateOverlaysClient(src.client)
		if (src.observers.len)
			for (var/mob/x in src.observers)
				if (x.client)
					src.updateOverlaysClient(x.client)


	handle_stamina_updates()
		if (stamina == STAMINA_NEG_CAP)
			setStatus("paralysis", max(getStatusDuration("paralysis"), STAMINA_NEG_CAP_STUN_TIME))

		//Modify stamina.
		var/stam_time_passed = max(tick_spacing, world.timeofday - last_stam_change)

		var/final_mod = (src.stamina_regen + src.get_stam_mod_regen()) * (stam_time_passed / tick_spacing)
		if (final_mod > 0)
			src.add_stamina(abs(final_mod))
		else if (final_mod < 0)
			src.remove_stamina(abs(final_mod))

		last_stam_change = world.timeofday

		if (src.stamina_bar && src.client)
			src.stamina_bar.update_value(src)

		last_stam_change = TIME


	proc/handle_random_events()
		if (prob(1) && prob(2))
			emote("sneeze")

	proc/handle_random_emotes()
		if (!islist(src.random_emotes) || !src.random_emotes.len || src.stat)
			return
		var/emote2do = pick(src.random_emotes)
		src.emote(emote2do)

	proc/handle_temperature_damage(body_part, exposed_temperature, exposed_intensity)
		if (exposed_temperature > src.base_body_temp && src.is_heat_resistant())
			return
		if (exposed_temperature < src.base_body_temp && src.is_cold_resistant())
			return
		var/discomfort = min(abs(exposed_temperature - bodytemperature)*(exposed_intensity)/2000000, 1)

		switch(body_part)
			if (HEAD)
				TakeDamage("head", 0, 2.5*discomfort, 0, DAMAGE_BURN)
			if (TORSO)
				TakeDamage("chest", 0, 2.5*discomfort, 0, DAMAGE_BURN)
			if (LEGS)
				TakeDamage("l_leg", 0, 0.6*discomfort, 0, DAMAGE_BURN)
				TakeDamage("r_leg", 0, 0.6*discomfort, 0, DAMAGE_BURN)
			if (ARMS)
				TakeDamage("l_arm", 0, 0.4*discomfort, 0, DAMAGE_BURN)
				TakeDamage("r_arm", 0, 0.4*discomfort, 0, DAMAGE_BURN)

	proc/handle_organs(var/mult = 1)//for things that arent humans, and dont override to use actual organs - they might use digestion ok
		src.handle_digestion(mult)

/mob/living/carbon/human

	proc/handle_pathogens()
		if (isdead(src))
			if (src.pathogens.len)
				for (var/uid in src.pathogens)
					var/datum/pathogen/P = src.pathogens[uid]
					P.disease_act_dead()
					if (prob(5))
						src.cured(P)
			return
		for (var/uid in src.pathogens)
			var/datum/pathogen/P = src.pathogens[uid]
			P.disease_act()

	get_cold_protection()
		// calculate 0-100% insulation from cold environments
		if (!src)
			return 0

		// Sealed space suit? If so, consider it to be full protection
		if (src.protected_from_space())
			return 100

		var/thermal_protection = 10 // base value

		// Resistance from Bio Effects
		if (src.bioHolder)
			if (src.bioHolder.HasEffect("fat"))
				thermal_protection += 10
			if (src.bioHolder.HasEffect("dwarf"))
				thermal_protection += 10

		// Resistance from Clothing
		thermal_protection += GET_MOB_PROPERTY(src, PROP_COLDPROT)

/*
		for(var/atom in src.get_equipped_items())
			var/obj/item/C = atom
			thermal_protection += C.getProperty("coldprot")*/

		/*
		// Resistance from covered body parts
		// Commented out - made certain covering items (winter coats) basically spaceworthy all on their own, and made tooltips inaccurate
		// Besides, the protected_from_space check above covers wearing a full spacesuit.
		if (w_uniform && (w_uniform.body_parts_covered & TORSO))
			thermal_protection += 10

		if (wear_suit)
			if (wear_suit.body_parts_covered & TORSO)
				thermal_protection += 10
			if (wear_suit.body_parts_covered & LEGS)
				thermal_protection += 10
			if (wear_suit.body_parts_covered & ARMS)
				thermal_protection += 10
		*/

		thermal_protection = clamp(thermal_protection, 0, 100)
		return thermal_protection

	proc/get_disease_protection(var/ailment_path=null, var/ailment_name=null)
		if (!src)
			return 100

		var/resist_prob = 0

		if (ispath(ailment_path) || istext(ailment_name))
			var/datum/ailment/A = null
			if (ailment_name)
				A = get_disease_from_name(ailment_name)
			else
				A = get_disease_from_path(ailment_path)

			if (!istype(A,/datum/ailment/))
				return 100

			if (istype(A,/datum/ailment/disease/))
				var/datum/ailment/disease/D = A
				if (D.spread == "Airborne")
					if (src.wear_mask)
						if (src.internal)
							resist_prob += 100
				else if (D.spread == "Sight")
					if (src.eyes_protected_from_light())
						resist_prob += 190

		for(var/atom in src.get_equipped_items())
			var/obj/item/C = atom
			resist_prob += C.getProperty("viralprot")

		if(src.getStatusDuration("food_disease_resist"))
			resist_prob += 80

		resist_prob = clamp(resist_prob,0,100)
		return resist_prob

	get_rad_protection()
		// calculate 0-100% insulation from rads
		if (!src)
			return 0

		var/rad_protection = 0

		// Resistance from Clothing
		rad_protection += GET_MOB_PROPERTY(src, PROP_RADPROT)

		if (bioHolder && bioHolder.HasEffect("food_rad_resist"))
			rad_protection += 100

		rad_protection = clamp(rad_protection, 0, 100)
		return rad_protection

	get_ranged_protection()
		if (!src)
			return 0

		var/protection = 1

		// Resistance from Clothing
		protection += GET_MOB_PROPERTY(src, PROP_RANGEDPROT)

		return protection

	get_melee_protection(zone, damage_type)
		if (!src)
			return 0
		var/protection = 0
		var/a_zone = zone
		if (a_zone in list("l_leg", "r_arm", "l_leg", "r_leg"))
			a_zone = "chest"
		if(a_zone=="All")
			protection=(5*get_melee_protection("chest",damage_type)+get_melee_protection("head",damage_type))/6

		else

			//protection from clothing
			if (a_zone == "chest")
				protection = GET_MOB_PROPERTY(src, PROP_MELEEPROT_BODY)
			else //can only be head
				protection = GET_MOB_PROPERTY(src, PROP_MELEEPROT_HEAD)

			//protection from blocks
			var/obj/item/grab/block/G = src.check_block()
			if (G)
				protection += 1
				if (G != src.equipped()) // bare handed block is less protective
					protection += G.can_block(damage_type)

		if (isnull(protection)) //due to GET_MOB_PROPERTY returning null if it doesnt exist
			protection = 0
		return protection

	get_deflection()
		if (!src)
			return 0

		var/protection = 0

		// Resistance from Clothing
		for(var/atom in src.get_equipped_items())
			var/obj/item/C = atom
			if(C.hasProperty("deflection"))
				var/curr = C.getProperty("deflection")
				protection += curr

		return min(protection, 90-STAMINA_BLOCK_CHANCE)


	get_heat_protection()
		// calculate 0-100% insulation from cold environments
		if (!src)
			return 0

		var/thermal_protection = 10 // base value

		// Resistance from Bio Effects
		if (src.bioHolder)
			if (src.bioHolder.HasEffect("dwarf"))
				thermal_protection += 10

		// Resistance from Clothing
		thermal_protection += GET_MOB_PROPERTY(src, PROP_HEATPROT)

		/*
		// Resistance from covered body parts
		// See get_cold_protection for comment out reasoning
		if (w_uniform && (w_uniform.body_parts_covered & TORSO))
			thermal_protection += 10

		if (wear_suit)
			if (wear_suit.body_parts_covered & TORSO)
				thermal_protection += 10
			if (wear_suit.body_parts_covered & LEGS)
				thermal_protection += 10
			if (wear_suit.body_parts_covered & ARMS)
				thermal_protection += 10
		*/

		thermal_protection = clamp(thermal_protection, 0, 100)
		return thermal_protection

	proc/add_fire_protection(var/temp)
		var/fire_prot = 0
		if (head)
			if (head.protective_temperature > temp)
				fire_prot += (head.protective_temperature/10)
		if (wear_mask)
			if (wear_mask.protective_temperature > temp)
				fire_prot += (wear_mask.protective_temperature/10)
		if (glasses)
			if (glasses.protective_temperature > temp)
				fire_prot += (glasses.protective_temperature/10)
		if (ears)
			if (ears.protective_temperature > temp)
				fire_prot += (ears.protective_temperature/10)
		if (wear_suit)
			if (wear_suit.protective_temperature > temp)
				fire_prot += (wear_suit.protective_temperature/10)
		if (w_uniform)
			if (w_uniform.protective_temperature > temp)
				fire_prot += (w_uniform.protective_temperature/10)
		if (gloves)
			if (gloves.protective_temperature > temp)
				fire_prot += (gloves.protective_temperature/10)
		if (shoes)
			if (shoes.protective_temperature > temp)
				fire_prot += (shoes.protective_temperature/10)

		return fire_prot

	handle_organs(var/mult = 1) // is this even where this should go???  ??????  haine gud codr
		if (src.ignore_organs)
			return

		if (!src.organHolder)
			src.organHolder = new(src)
			sleep(1 SECOND)

		var/datum/organHolder/oH = src.organHolder
		if (!oH.head && !src.nodamage)
			src.death()

		// time to find out why this wasn't added - cirr
		oH.handle_organs(mult)


		if (!oH.skull) // look okay it's close enough to an organ and there's no other place for it right now shut up
			if (!src.nodamage && oH.head)
				src.death()
				src.visible_message("<span class='alert'><b>[src]</b>'s head collapses into a useless pile of skin mush with no skull to keep it in its proper shape!</span>",\
				"<span class='alert'>Your head collapses into a useless pile of skin mush with no skull to keep it in its proper shape!</span>")

		//Wire note: Fix for Cannot read null.loc
		else if (oH.skull.loc != src)
			oH.skull = null

		if (!oH.brain)
			if (!src.nodamage)
				src.death()
		else if (oH.brain.loc != src)
			oH.brain = null

		if (!oH.heart && !src.nodamage)
			if (!ischangeling(src))
				if (src.get_oxygen_deprivation())
					src.take_brain_damage(3)
				else if (prob(10))
					src.take_brain_damage(1)

				src.changeStatus("weakened", 5 SECONDS)
				src.losebreath += 20
				src.take_oxygen_deprivation(20)
		else
			if (oH.heart.loc != src)
				oH.heart = null
			else if (oH.heart.robotic && oH.heart.emagged && !oH.heart.broken)
				src.drowsyness = max (src.drowsyness - 8, 0)
				if (src.sleeping) src.sleeping = 0
			else if (oH.heart.robotic && !oH.heart.broken)
				src.drowsyness = max (src.drowsyness - 4, 0)
				if (src.sleeping) src.sleeping = 0
			else if (oH.heart.broken)
				if (src.get_oxygen_deprivation())
					src.take_brain_damage(3)
				else if (prob(10))
					src.take_brain_damage(1)

				changeStatus("weakened", 2 SECONDS)
				src.losebreath += 20
				src.take_oxygen_deprivation(20)
			else if (src.organHolder.heart.get_damage() > 100)
				src.contract_disease(/datum/ailment/malady/flatline,null,null,1)

		// lungs are skipped until they can be removed/whatever
