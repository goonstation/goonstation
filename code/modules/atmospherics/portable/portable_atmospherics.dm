/obj/machinery/portable_atmospherics
	name = "atmoalter"
	var/datum/gas_mixture/air_contents = null

	var/obj/machinery/atmospherics/portables_connector/connected_port
	var/obj/item/tank/holding

	var/volume = 0
	var/destroyed = 0

	var/maximum_pressure = 90*ONE_ATMOSPHERE

	var/init_connected = 0

	var/contained = 0

	onMaterialChanged()
		..()
		if(istype(src.material))
			// Roughly tweaked to be equal to steel (hard = 15 density = 30) = 90,
			// which I assume these are generally made out of
			// Mauxite is 15 / 50, so slightly better.
			// I went with hardness here just because I figure if it's hard it doesn't break all that well.
			// Probably could be adjusted, but this gives decent results, I guess. Eh.
			maximum_pressure = max((src.material.getProperty("hard") * 4 + src.material.getProperty("density")) * ONE_ATMOSPHERE, ONE_ATMOSPHERE * 2)
		return

	New()
		..()

		air_contents = new /datum/gas_mixture

		air_contents.volume = volume
		air_contents.temperature = T20C

		if(init_connected)
			var/obj/machinery/atmospherics/portables_connector/possible_port = locate(/obj/machinery/atmospherics/portables_connector/) in loc
			if(possible_port)
				connect(possible_port)

		return 1

	process()
		if(contained) return
		if(!connected_port) //only react when pipe_network will ont it do it for you
			//Allow for reactions
			air_contents?.react() //ZeWaka: Fix for null.react()

	disposing()
		if (air_contents)
			qdel(air_contents)
			air_contents = null

		..()

	get_desc()
		. = " It is labeled to have a volume of [src.volume] litres."

	proc
		connect(obj/machinery/atmospherics/portables_connector/new_port)
			//Make sure not already connected to something else
			if(connected_port || !new_port || new_port.connected_device)
				return 0

			//Make sure are close enough for a valid connection
			if(new_port.loc != loc)
				return 0

			add_fingerprint(usr)

			//Perform the connection
			connected_port = new_port
			connected_port.connected_device = src
			connected_port.on = 1

			anchored = ANCHORED //Prevent movement

			//Actually enforce the air sharing
			var/datum/pipe_network/network = connected_port.return_network(src)
			if(network && !network.gases.Find(air_contents))
				network.gases += air_contents

			return 1

		disconnect()
			if(!connected_port)
				return 0

			var/datum/pipe_network/network = connected_port.return_network(src)
			network?.gases -= air_contents

			anchored = UNANCHORED

			connected_port.connected_device = null
			connected_port = null

			return 1

/obj/machinery/portable_atmospherics/proc/eject_tank()
	if(holding)
		holding.set_loc(loc)
		usr.put_in_hand_or_eject(holding) // try to eject it into the users hand, if we can
		holding = null
		UpdateIcon()
	return

/obj/machinery/portable_atmospherics/attackby(var/obj/item/W, var/mob/user)
	if(istype(W, /obj/item/tank))
		if(!src.holding)
			boutput(user, "<span class='notice'>You attach the [W.name] to the the [src.name]</span>")
			user.drop_item()
			W.set_loc(src)
			src.holding = W
			UpdateIcon()
			tgui_process.update_uis(src) //update UI immediately

	else if (iswrenchingtool(W))
		if ((istype(src, /obj/machinery/portable_atmospherics/canister))) //No messing with anchored canbombs. -ZeWaka
			var/obj/machinery/portable_atmospherics/canister/C = src
			if (!isnull(C.det) && C.anchored)
				boutput(user, "<span class='alert'>The detonating mechanism blocks you from modifying the anchors on the [src.name].</span>")
				return
		if(connected_port)
			logTheThing(LOG_STATION, user, "has disconnected \the [src] [log_atmos(src)] from the port at [log_loc(src)].")
			disconnect()
			boutput(user, "<span class='notice'>You disconnect [name] from the port.</span>")
			playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
			tgui_process.update_uis(src)
			return
		else
			var/obj/machinery/atmospherics/portables_connector/possible_port = locate(/obj/machinery/atmospherics/portables_connector/) in loc
			if(possible_port)
				if(connect(possible_port))
					logTheThing(LOG_STATION, user, "has connected \the [src] [log_atmos(src)] to the port at [log_loc(src)].")
					boutput(user, "<span class='notice'>You connect [name] to the port.</span>")
					playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
					tgui_process.update_uis(src)
					return
				else
					boutput(user, "<span class='notice'>[name] failed to connect to the port.</span>")
					return
			else
				boutput(user, "<span class='notice'>Nothing happens.</span>")
				return
	else if (istype(W, /obj/item/reagent_containers/balloon))
		var/obj/item/reagent_containers/balloon/balloon = W
		var/amount = balloon.breaths * BREATH_VOLUME - TOTAL_MOLES(balloon.air)
		if (amount <= 0)
			boutput(user, "<span class='alert'>[balloon] is already full.</span>")
			return
		else if (istype(src, /obj/machinery/portable_atmospherics/scrubber))
			var/fillfrom = tgui_alert(user, "Fill balloon from liquid tank or air tank?", "Fill balloon", list("Air tank", "Liquid tank", "Cancel"))
			if (fillfrom == "Cancel")
				return
			else if (fillfrom == "Liquid tank")
				if (src.reagents && !src.reagents.total_volume)
					user.show_text("[src] is empty.", "red")
					return
				if (reagents && reagents.total_volume >= reagents.maximum_volume)
					user.show_text("[balloon] is full.", "red")
					return
				var/transferamt = balloon.reagents.maximum_volume - balloon.reagents.total_volume
				var/trans = src.reagents.trans_to(balloon, transferamt)
				user.show_text("You fill [balloon] with [trans] units of the contents of [src].", "blue")
				user.update_inhands()
				return
			else
		var/datum/gas_mixture/removed = src.air_contents.remove(amount)
		balloon.air.merge(removed)
		balloon.UpdateIcon()
		playsound(get_turf(src), 'sound/machines/hiss.ogg', 50, 1)
		user.visible_message("<span class='notice'>[user] fills [balloon] from src.</span>", "<span class='notice'>You fill [balloon] from [src].</span>")
		return
	return
