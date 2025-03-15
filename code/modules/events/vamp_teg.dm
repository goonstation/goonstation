/datum/random_event/major/vampire_teg
	name = "Haunted TEG"
#ifdef RP_MODE
	required_elapsed_round_time = 40 MINUTES
#else
	required_elapsed_round_time = 26.6 MINUTES
#endif
	customization_available = 1
#ifdef HALLOWEEN
	weight = 75
#else
	weight = 50
#endif
	var/obj/machinery/power/generatorTemp/generator
	var/list/circulators_to_relube
	var/event_active
	var/target_grump

	is_event_available(var/ignore_time_lock = 0)
		. = ..()
		if(.)
			generator = locate(/obj/machinery/power/generatorTemp) in machine_registry[MACHINES_POWER]
			if( !generator || generator.grump < 100 )
				. = FALSE

	admin_call(var/source)
		if (..())
			return

		var/warning_delay = input(usr,"Delay for warning? (Seconds)",src.name, 25) as num|null
		if (!isnum(warning_delay) || warning_delay < 1)
			return
		var/event_duration = input(usr,"Duration of event? (Minutes)",src.name, 9) as num|null
		if (!isnum(event_duration) || event_duration < 1)
			return
		var/grump_to_overcome = input(usr,"Grump to overcome?",src.name, 100) as num|null
		if (!isnum(grump_to_overcome) || grump_to_overcome < 1)
			return

		src.event_effect(warning_delay, event_duration, grump_to_overcome)

	event_effect(warning_delay, event_duration, grump_to_overcome)
		..()
		var/list/spooky_sounds = list('sound/ambience/nature/Wind_Cold1.ogg', 'sound/ambience/nature/Wind_Cold2.ogg', 'sound/ambience/nature/Wind_Cold3.ogg','sound/ambience/nature/Cave_Bugs.ogg', 'sound/ambience/nature/Glacier_DeepRumbling1.ogg', 'sound/effects/bones_break.ogg',	'sound/effects/gust.ogg', 'sound/effects/static_horror.ogg', 'sound/effects/blood.ogg')
		var/list/area/stationAreas = get_accessible_station_areas()

		if(!generator)
			generator = locate(/obj/machinery/power/generatorTemp) in machine_registry[MACHINES_POWER]
		if (!generator || generator.disposed || generator.z != Z_LEVEL_STATION )
			message_admins("The Vampire TEG event failed to find TEG!")
			return

		if (!isnum(warning_delay))
			warning_delay = rand(10, 50)
		warning_delay = warning_delay SECONDS

		if (!isnum(event_duration))
			event_duration = rand(7, 9)
		event_duration = event_duration MINUTES

		if (!isnum(grump_to_overcome))
			grump_to_overcome = 100

		var/list/obj/machinery/station_switches = list()
		for(var/area_key as() in stationAreas)
			var/obj/machinery/light_switch/S
			var/area/SA = stationAreas[area_key]
			S = locate(/obj/machinery/light_switch) in SA?.machines
			if(S)
				station_switches += S

		event_active = TRUE
		target_grump =  max(generator.grump-50, 50)
		generator.grump += grump_to_overcome
		var/datum/effects/system/harmless_smoke_spread/smoke = new /datum/effects/system/harmless_smoke_spread()
		smoke.set_up(1, 0, generator.loc)
		smoke.attach(generator)
		smoke.start()
		playsound(generator, pick(spooky_sounds), 30, 0, -1)

		src.circulators_to_relube = list(generator.circ1, generator.circ2)
		for(var/obj/machinery/atmospherics/binary/circulatorTemp/C in circulators_to_relube)
			C.reagents.add_reagent("black_goop", 10)
			C.reagents.add_reagent("black_goop", 10)

		// Delayed Warning and Instruction
		SPAWN(warning_delay)
			if(event_active)
				command_alert("Reports indicate that the engine on-board [station_name()] is behaving unusually. Stationwide power failures may occur or worse.", "Engine Warning", alert_origin = ALERT_STATION)
				sleep(30 SECONDS)
			if(event_active)
				command_alert("Onsite Engineers inform us a sympathetic connection exists between the furnaces and the engine. Considering burning something it might enjoy: food, people, weed. We're grasping at straws here. ", "Engine Suggestion")
				sleep(randfloat(1 MINUTE, 2.5 MINUTES))

			if(event_active)
				pda_msg("Unknown substance detected in Themo-Electric Generator Circulators. Please drain and replace lubricants.")

		// FAILURE EVENT
		SPAWN(event_duration)
			if(event_active)
				event_active = FALSE
				for (var/obj/machinery/light_switch/L as() in station_switches)
					if(L.on && prob(50))
						elecflash(L)
						L.Attackhand(null)
				generator.transformation_mngr.transform_to_type(/datum/teg_transformation/vampire)

		SPAWN(0)
			var/area/A = get_area(generator)
			var/obj/machinery/teg_light_switch = locate(/obj/machinery/light_switch) in A.machines

			// Set stage by turning off lights to engine room
			if(teg_light_switch)
				elecflash(teg_light_switch)
				teg_light_switch.Attackhand(null)
			else
				elecflash(A.area_apc)
				if(!A.area_apc.lighting)
					A.area_apc.lighting = 0
					SPAWN(rand(5 SECONDS,10 SECONDS))
						A.area_apc.lighting = 3

			while(event_active)
				//Bail on event if something happened to TEG
				if(!generator || generator.disposed)
					event_active = FALSE
					return

				//Check for success!
				if(generator.grump < target_grump)
					event_active = FALSE
					return

				if(prob(50))
					playsound(generator, pick(spooky_sounds), 30, 0, -1)
					switch(rand(1,5))
						if(1)
							animate_flash_color_fill_inherit(pick(generator,generator.circ1,generator.circ2),"#e13333",2, 2 SECONDS)
						if(2)
							animate_levitate(pick(generator,generator.circ1,generator.circ2), 1, 50, random_side = FALSE)
						if(3)
							// Turn off light switches
							for (var/obj/machinery/light_switch/L as() in station_switches)
								if(L.on && prob(5))
									elecflash(L)
									L.Attackhand(null)
						if(4)
							// Electrify Doors
							for_by_tcl(D, /obj/machinery/door/airlock)
								if (D.z == Z_LEVEL_STATION && D.powered() && prob(5))
									if (D.secondsElectrified == 0)
										elecflash(D)
										D.secondsElectrified = -1
										SPAWN(10 SECONDS)
											if (D)
												D.secondsElectrified = 0
						if(5)
							// Reduced APC EMP
							var/obj/machinery/power/apc/apc
							A = pick(stationAreas)
							apc = stationAreas[A].area_apc
							if(apc && apc.powered() && (apc.lighting || apc.equipment || apc.environ ) )
								elecflash(apc, radius=1)
								if(apc.cell)
									apc.cell.use(500)
									if (apc.cell.charge < 0)
										apc.cell.charge = 0
								apc.lighting = 0
								apc.equipment = 0
								apc.environ = 0
								SPAWN(20 SECONDS)
									apc.equipment = 3
									apc.environ = 3

				// Check if circulator lubricant has been replaced to remove the "black goop"
				for(var/obj/machinery/atmospherics/binary/circulatorTemp/C in circulators_to_relube)
					if( !C.reagents.has_reagent("black_goop") && (C.reagents.total_volume > (C.reagents.maximum_volume/10) ))
						circulators_to_relube -= C
						target_grump += 25

				sleep(randfloat(5.8 SECONDS, 25 SECONDS))

	proc/pda_msg(event_string)
		var/datum/signal/signal = get_free_signal()
		signal.source = src.generator
		signal.data["command"] = "text_message"
		signal.data["sender_name"] = "ENGINE-MAILBOT"
		signal.data["group"] = list(MGO_ENGINEER, MGA_ENGINE)
		signal.data["message"] = "Notice: [event_string]"
		signal.data["sender"] = "00000000"
		signal.data["address_1"] = "00000000"

		radio_controller.get_frequency(FREQ_PDA).post_packet_without_source(signal)

datum/teg_transformation/vampire
	mat_id = "bone"
	var/datum/abilityHolder/vampire/abilityHolder
	var/list/datum/targetable/vampire/abilities = list()
	var/health = 150

	proc/attach_hud()
		. = FALSE

	disposing()
		actions.stop_all(abilityHolder.owner)
		abilityHolder.owner = null
		qdel(abilityHolder)
		. = ..()

	on_transform(obj/machinery/power/generatorTemp/teg)
		. = ..()
		abilityHolder = new /datum/abilityHolder/vampire(src)
		abilityHolder.owner = teg
		abilityHolder.addAbility(/datum/targetable/vampire/blood_steal)
		abilityHolder.addAbility(/datum/targetable/vampire/glare)
		abilityHolder.addAbility(/datum/targetable/vampire/enthrall/teg)
		for(var/datum/targetable/vampire/A in abilityHolder.abilities)
			abilities[A.name] = A
		RegisterSignal(src.teg, COMSIG_ATOM_HITBY_PROJ, PROC_REF(projectile_collide))
		RegisterSignal(src.teg, COMSIG_ATTACKBY, PROC_REF(attackby))
		RegisterSignal(src.teg.circ1, COMSIG_ATTACKBY, PROC_REF(attackby))
		RegisterSignal(src.teg.circ2, COMSIG_ATTACKBY, PROC_REF(attackby))

		var/image/mask = image('icons/obj/clothing/item_masks.dmi', "death")
		mask.appearance_flags = RESET_COLOR | RESET_ALPHA | PIXEL_SCALE
		mask.color = "#b10000"
		mask.alpha = 240
		teg.UpdateOverlays(mask, "mask")
		var/volume = src.teg.circ1.reagents.total_volume
		src.teg.circ1.reagents.remove_any(volume)
		src.teg.circ1.reagents.add_reagent("blood", volume)
		vampify(src.teg.circ1)
		volume = src.teg.circ2.reagents.total_volume
		src.teg.circ2.reagents.remove_any(volume)
		src.teg.circ2.reagents.add_reagent("blood", volume)
		vampify(src.teg.circ2)
		vampify(src.teg)

		teg.ensure_speech_tree().AddSpeechOutput(SPEECH_OUTPUT_THRALLCHAT_VAMPIRE, subchannel = "\ref[src.abilityHolder]")
		teg.default_speech_output_channel = SAY_CHANNEL_THRALL

	proc/vampify(obj/O)
		animate_levitate(O, -1, 50, random_side = FALSE)
		O.color = "#bd1335"
		animate_flash_color_fill_inherit(O,"#e13333",-1, 2 SECONDS)

	proc/use_ability(abilityType, mob/target)
		var/datum/targetable/vampire/A = abilityHolder.getAbility(abilityType)
		if(A)
			if (world.time < A.last_cast)
				return
			SPAWN(0)
				A.handleCast(target)

	on_revert()
		var/datum/reagents/leaked
		teg.UpdateOverlays(null, "mask")
		UnregisterSignal(src.teg, COMSIG_ATOM_HITBY_PROJ)
		UnregisterSignal(src.teg, COMSIG_ATTACKBY)
		UnregisterSignal(src.teg.circ1, COMSIG_ATTACKBY)
		UnregisterSignal(src.teg.circ2, COMSIG_ATTACKBY)
		var/volume = src.teg.circ1.reagents.total_volume
		if(volume)
			leaked = src.teg.circ1.reagents.remove_any_to(volume)
			leaked.reaction(get_step(src.teg.circ1, SOUTH))
		volume = src.teg.circ2.reagents.total_volume
		if(volume)
			leaked = src.teg.circ2.reagents.remove_any_to(volume)
			leaked.reaction(get_step(src.teg.circ2, SOUTH))
		animate(src.teg)
		animate(src.teg.circ1)
		animate(src.teg.circ2)
		for(var/mob/M in abilityHolder.thralls)
			M.mind?.remove_antagonist(ROLE_VAMPTHRALL)

		teg.ensure_speech_tree().RemoveSpeechOutput(SPEECH_OUTPUT_THRALLCHAT_VAMPIRE, subchannel = "\ref[src.abilityHolder]")
		teg.default_speech_output_channel = SAY_CHANNEL_OUTLOUD

		. = ..()

	on_grump(mult)
		var/mob/living/carbon/human/H
		var/list/mob/living/carbon/targets = list()

		if(probmult(20))
			for(var/mob/living/carbon/M in orange(5, teg))
				if(M.blood_volume >= 0 && !M.traitHolder.hasTrait("training_chaplain"))
					targets += M

		if(length(targets))
			if(probmult(30))
				if( !ON_COOLDOWN(src.teg,"blood", 30 SECONDS) )
					playsound(src.teg, 'sound/effects/blood.ogg', rand(10,20), 0, -1)

			var/mob/living/carbon/target = pick(targets)

			if(target in abilityHolder.thralls)
				H = target
				if( abilityHolder.points > 100 && target.blood_volume < 50 && !ON_COOLDOWN(src.teg,"heal", 120 SECONDS) )
					use_ability(/datum/targetable/vampire/enthrall/teg, target)
			else
				if(isalive(target))
					if( prob(80) && !ON_COOLDOWN(target,"teg_glare", 30 SECONDS) )
						use_ability(/datum/targetable/vampire/glare, target)

					use_ability(/datum/targetable/vampire/blood_steal, target)

			if(ishuman(target))
				H = target
				if(isdead(H) && abilityHolder.points > 100 && !ON_COOLDOWN(src.teg,"enthrall",30 SECONDS))
					use_ability(/datum/targetable/vampire/enthrall/teg, target)

		if(probmult(10))
			var/list/responses = list("I hunger! Bring us food so we may eat!", "Blood... I needs it.", "I HUNGER!", "Summon them here so we may feast!")
			src.teg.say(pick(responses))

		if(probmult(20) && abilityHolder.points > 100)
			var/datum/reagents/reagents = pick(src.teg.circ1.reagents, src.teg.circ2.reagents)
			var/transfer_volume = clamp(reagents.maximum_volume - reagents.total_volume, 0, abilityHolder.points - 100)

			if(transfer_volume)
				transfer_volume = rand(0, transfer_volume)
				reagents.add_reagent("blood",transfer_volume)
				abilityHolder.deductPoints(transfer_volume)
				src.teg.grump -= 10
			else
				reagents.remove_any_to(100)
				make_cleanable(/obj/decal/cleanable/blood,get_step(src.teg, SOUTH))
				src.teg.efficiency_controller += 5
				SPAWN(45 SECONDS)
					if(src.teg?.active_form == src)
						src.teg?.efficiency_controller -= 5
		else
			if(probmult(33))
				var/list/stationAreas = get_accessible_station_areas()
				var/area/A = stationAreas[pick(stationAreas)]
				A?.area_apc?.emp_act()

		checkhealth()
		return TRUE

	proc/checkhealth()
		for(var/obj/machinery/atmospherics/binary/circulatorTemp/C in list(src.teg?.circ1,src.teg?.circ2))
			if(C.reagents)
				if(C.reagents.has_reagent("water_holy", 5))
					src.health -= 5
					C.reagents.remove_reagent("water_holy", 8)
					if (!(locate(/datum/effects/system/steam_spread) in C.loc))
						playsound(C.loc, 'sound/effects/bubbles3.ogg', 80, 1, -3, pitch=0.7)
						var/datum/effects/system/steam_spread/steam = new /datum/effects/system/steam_spread
						steam.set_up(1, 0, get_turf(C))
						steam.attach(C)
						steam.start(clear_holder=1)

		if(health <= 0) // thou haft defeated the beast
			on_revert()

	// Implement attackby to handle objects and attacks to Generator and Circulators
	proc/attackby(obj/T, obj/item/I, mob/user)
		user.lastattacked = get_weakref(src)
		var/force = I.force
		if(istype(I,/obj/item/bible) && user.traitHolder.hasTrait("training_chaplain"))
			force = 60

		switch (force)
			if (0 to 19)
				force = force / 4
			if (20 to 39)
				force = force / 5
			if (40 to 59)
				force = force / 6
			if (60 to INFINITY)
				force = force / 7
		health -= force

	// Customized implementation of collision with vamp blood and be susceptable to projectiles
	proc/projectile_collide(owner, obj/projectile/P)
		if(P.proj_data.damage_type & (D_KINETIC | D_ENERGY | D_SLASHING))
			var/damage = P.power*P.proj_data.ks_ratio

			switch (P.proj_data.damage_type)
				if (D_KINETIC)
					damage /= 5
				if (D_SLASHING)
					damage /= 7
				if (D_ENERGY)
					damage /= 10

			health -= round(damage, 1.0)

/datum/targetable/vampire/enthrall/teg
	max_range = 10
