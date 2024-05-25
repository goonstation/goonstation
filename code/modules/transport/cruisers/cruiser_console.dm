//This might just be the file that finally breaks angriestibm.
//I just nilly willy directly use the cruiser object instead of sending packets.

/datum/computer/file/terminal_program/cruiser
	name = "Cruiser"
	size = 32

	disposing()
		..()

	initialize()
		if (..())
			return TRUE
		src.print_text("Cruiser Control Assistant<br>Type \"help\" for commands.")

	input_text(text)
		if(..())
			return

		var/list/command_list = parse_string(text)
		var/command = command_list[1]
		command_list -= command_list[1] //Remove the command we are now processing.

		var/obj/item/peripheral/cruiser/adapter = find_peripheral("SHIP_ADAPTER")

		switch(lowertext(command))
			if ("help")
				src.print_text("Command List:<br> read_power - Gets power usage<br>power_ratios - Displays sub-system power ratios.<br>damage - Lists damaged systems<br>set_power (thrusters/weapons/shields) (percentage) - Adjusts how much power subsystems receive.<br>reboot (turret_l/turret_r/engine/life_support/pod_weapons/pod_navigation/pod_defense) - Restores basic functions of the given system while degrading the ship.")
				return

			if ("reboot")
				if(length(command_list) >= 1)
					//for(var/t in command_list)
					//	command_list -= t
					var/t = command_list[1]
					if(lowertext(t) in list("turret_l","turret_r","engine","life_support","pod_weapons","pod_navigation","pod_defense"))
						var/datum/signal/newsignal = get_free_signal()
						newsignal.data["system"] = lowertext(t)
						print_text("Rebooting [lowertext(t)]. Please wait ...")
						src.peripheral_command("reboot", newsignal, "\ref[adapter]")
					else
						print_text("Unknown system: [lowertext(t)]")

			if ("set_power","spwr")
				if(length(command_list) == 2)
					var/system = command_list[1]
					var/percentage = command_list[2]

					if(lowertext(system) != "thrusters" && lowertext(system) != "weapons" && lowertext(system) != "shields")
						print_text("Unknown sub-system: [system]")
						return
					if(!text2num_safe(percentage))
						print_text("Invalid setting: [percentage]")
						return
					var/datum/signal/newsignal = get_free_signal()
					newsignal.data["system"] = system
					newsignal.data["percentage"] = percentage

					src.peripheral_command("set_power", newsignal, "\ref[adapter]")
				else
					print_text("Usage: set_power (thrusters/weapons/shields) (percentage)")

			if ("power_ratios", "p%", "pwrr")
				src.peripheral_command("power_ratios", null, "\ref[adapter]")

			if ("read_power", "power", "pwr")
				src.peripheral_command("read_power", null, "\ref[adapter]")

			if ("damage", "dmg")
				src.peripheral_command("get_damage", null, "\ref[adapter]")

			if ("quit","exit")
				src.master.temp = ""
				print_text("Now quitting...")
				src.master.unload_program(src)
				return

			else
				src.print_text("Unknown command.")

	receive_command(obj/source, command, datum/signal/signal)
		if ((..()) || (!signal))
			return
		if (command == "read_power")
			var/list/received = params2list(signal.data["usage_breakdown"])
			src.print_text("Power: [signal.data["used_last"]]Pu / [signal.data["prod_last"]]Pu")
			for(var/X in received)
				src.print_text("--[X]: [received[X]]")
			src.print_text("<br>")
			return

		else if (command == "get_damage")
			src.print_text("Number of damaged systems: [signal.data["damage_num"]]")
			src.print_text("Total damage: [signal.data["damage_total"]]")
			src.print_text("Ship degradation: [signal.data["degradation"]]%")
			if(signal.data["damage_breakdown"])
				src.print_text(signal.data["damage_breakdown"])
			return

		else if (command == "power_ratios")
			src.print_text("Thrusters power: [signal.data["ratio_movement"]]%")
			src.print_text("Weapons power: [signal.data["ratio_offense"]]%")
			src.print_text("Shields power: [signal.data["ratio_defense"]]%")
			return
		else if (command == "set_power")
			src.print_text("[signal.data["info"]]")
			return
		else if (command == "reboot")
			src.print_text("[signal.data["info"]]")
			return

/obj/machinery/computer3/generic/cruiser
	name = "cruiser console"
	icon_state = "cruiser"
	base_icon_state = "cruiser"
	setup_drive_size = 64
	setup_frame_type = /obj/computer3frame/terminal
	setup_starting_os = /datum/computer/file/terminal_program/os/main_os/no_login
	setup_starting_peripheral1 = /obj/item/peripheral/cruiser
	setup_starting_program = /datum/computer/file/terminal_program/cruiser
	setup_idscan_path = null

	power_change()
		if(status & BROKEN)
			icon_state = src.base_icon_state
			src.icon_state += "b"
			light.disable()
		else
			icon_state = src.base_icon_state
			status &= ~NOPOWER
			light.enable()


/obj/item/peripheral/cruiser
	name = "cruiser interface module"
	desc = "A computer interface card designed to interface with a small starcraft's main bus."
	icon_state = "power_mod"
	func_tag = "SHIP_ADAPTER"
	var/obj/machinery/cruiser/cruiser

	installed(var/obj/machinery/computer3/newhost)
		if(..())
			return 1

		check_cruiser()

		return 0

	uninstalled()
		src.cruiser = null
		return 0

	disposing()
		uninstalled()

		..()
	receive_command(obj/source, command, datum/signal/signal)
		if(..())
			return 1

		if(!src.check_cruiser())
			return 1

		switch (command)
			if ("read_power")
				var/datum/signal/newsignal = get_free_signal()
				newsignal.data["used_last"] = cruiser.power_used_last
				newsignal.data["prod_last"] = cruiser.power_produced_last

				var/usage_count_builder = ""
				for(var/X in cruiser.powerUse)
					var/decodeList = params2list(cruiser.powerUse[X])

					usage_count_builder += "[X]=[decodeList[1]];"

				if (usage_count_builder)
					newsignal.data["usage_breakdown"] = usage_count_builder

				SPAWN(0.4 SECONDS)
					send_command("read_power", newsignal)

				return newsignal

			if ("get_damage")
				var/datum/signal/newsignal = get_free_signal()
				var/dmg_total = 0
				var/dmg_count = 0

				var/damage_builder = ""

				for(var/obj/machinery/cruiser_destroyable/D in cruiser.interior_area)
					if(D.ignore || D.health == D.health_max) continue
					damage_builder += "--[D.name]: [D.health]/[D.health_max]<br>"
					dmg_count++
					dmg_total += (D.health_max - D.health)

				if (damage_builder)
					newsignal.data["damage_breakdown"] = damage_builder

				newsignal.data["damage_total"] = dmg_total
				newsignal.data["damage_num"] = dmg_count
				newsignal.data["degradation"] = cruiser.degradation

				SPAWN(0.4 SECONDS)
					send_command("get_damage", newsignal)

			if ("power_ratios")
				var/datum/signal/newsignal = get_free_signal()

				newsignal.data["ratio_movement"] = cruiser.power_movement
				newsignal.data["ratio_defense"] = cruiser.power_defense
				newsignal.data["ratio_offense"] = cruiser.power_offense

				SPAWN(0.4 SECONDS)
					send_command("power_ratios", newsignal)

				return newsignal

			if ("reboot")
				var/system = signal.data["system"]
				var/datum/signal/newsignal = get_free_signal()
				switch(system)
					if("turret_l")
						if(cruiser.interior_area)
							var/obj/machinery/cruiser_destroyable/cruiser_component_slot/weapon/left/P = (locate(/obj/machinery/cruiser_destroyable/cruiser_component_slot/weapon/left) in cruiser.interior_area)
							if(istype(P))
								newsignal.data["info"] = P.reboot()
								cruiser.degradation = min(cruiser.degradation + 5, 100)
					if("turret_r")
						if(cruiser.interior_area)
							var/obj/machinery/cruiser_destroyable/cruiser_component_slot/weapon/right/P = (locate(/obj/machinery/cruiser_destroyable/cruiser_component_slot/weapon/right) in cruiser.interior_area)
							if(istype(P))
								newsignal.data["info"] = P.reboot()
								cruiser.degradation = min(cruiser.degradation + 5, 100)
					if("engine")
						if(cruiser.interior_area)
							var/obj/machinery/cruiser_destroyable/cruiser_component_slot/engine/P = (locate(/obj/machinery/cruiser_destroyable/cruiser_component_slot/engine) in cruiser.interior_area)
							if(istype(P))
								newsignal.data["info"] = P.reboot()
								cruiser.degradation = min(cruiser.degradation + 5, 100)
					if("life_support")
						if(cruiser.interior_area)
							var/obj/machinery/cruiser_destroyable/cruiser_component_slot/life_support/P = (locate(/obj/machinery/cruiser_destroyable/cruiser_component_slot/life_support) in cruiser.interior_area)
							if(istype(P))
								newsignal.data["info"] = P.reboot()
								cruiser.degradation = min(cruiser.degradation + 5, 100)
					if("pod_weapons")
						if(cruiser.interior_area)
							var/obj/machinery/cruiser_destroyable/cruiser_pod/security/P = (locate(/obj/machinery/cruiser_destroyable/cruiser_pod/security) in cruiser.interior_area)
							if(istype(P))
								newsignal.data["info"] = P.reboot()
								cruiser.degradation = min(cruiser.degradation + 5, 100)
					if("pod_navigation")
						if(cruiser.interior_area)
							var/obj/machinery/cruiser_destroyable/cruiser_pod/movement/P = (locate(/obj/machinery/cruiser_destroyable/cruiser_pod/movement) in cruiser.interior_area)
							if(istype(P))
								newsignal.data["info"] = P.reboot()
								cruiser.degradation = min(cruiser.degradation + 5, 100)
					if("pod_defense")
						if(cruiser.interior_area)
							var/obj/machinery/cruiser_destroyable/cruiser_pod/engineering/P = (locate(/obj/machinery/cruiser_destroyable/cruiser_pod/engineering) in cruiser.interior_area)
							if(istype(P))
								newsignal.data["info"] = P.reboot()
								cruiser.degradation = min(cruiser.degradation + 5, 100)
					else
						newsignal.data["info"] = "INTERNAL ERROR. UNKNOWN SYSTEM"
				SPAWN(0.4 SECONDS)
					send_command("reboot", newsignal)
				return

			if ("set_power")
				var/percentage = text2num_safe(signal.data["percentage"])
				if(!percentage)
					return
				var/datum/signal/newsignal = get_free_signal()

				percentage = clamp(percentage, 1, 500)

				switch(lowertext(signal.data["system"]))
					if("thrusters")
						cruiser.power_movement = percentage
					if("weapons")
						cruiser.power_offense = percentage
					if("shields")
						cruiser.power_defense = percentage

				newsignal.data["info"] = "Set [signal.data["system"]] to [percentage]%"
				SPAWN(0.4 SECONDS)
					send_command("set_power", newsignal)

			else
				return "Valid commands: read_power get_damage power_ratios set_power reboot"

	//Return true if cruiser is valid/found.
	proc/check_cruiser()
		var/area/cruiser/A = get_area(src.host)
		if(istype(A))
			cruiser = A.ship
			return 1
		return 0
