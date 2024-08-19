/datum/targetable/wraithAbility/spook
	name = "Spook"
	icon_state = "spook"
	desc = "Cause freaky, weird, creepy or spooky stuff to happen in an area around you. Use this ability to mark your current tile as the origin of these events, then activate it by using this ability again."
	targeted = 0
	pointCost = 0
	cooldown = 20 SECONDS
	special_screen_loc="NORTH,EAST-1"
	min_req_dist = 10

	var/obj/spookMarker/marker = new /obj/spookMarker()		//removed for now
	var/status = 0
	var/static/list/effects = list("Flip light switches" = 1, "Burn out lights" = 2, "Create smoke" = 3, "Create ectoplasm" = 4, "Sap APC" = 5, "Haunt PDAs" = 6, "Open doors, lockers, crates" = 7, "Random" = 8)
	var/list/effects_buttons = list()


	New()
		..()
		object.contextLayout = new /datum/contextLayout/screen_HUD_default(2, 16, 16)//, -32, -32)
		if (!object.contextActions)
			object.contextActions = list()

		for(var/i=1, i<=8, i++)
			var/datum/contextAction/wraith_spook_button/newcontext = new /datum/contextAction/wraith_spook_button(i)
			object.contextActions += newcontext

	proc/haunt_pda(var/obj/item/device/pda2/pda)
		var/message = pick("boo", "git spooked", "BOOM", "there's a skeleton inside of you", "DEHUMANIZE YOURSELF AND FACE TO BLOODSHED", "ICARUS HAS FOUND YOU!!!!! RUN WHILE YOU CAN!!!!!!!!!!!")

		var/datum/signal/signal = get_free_signal()
		signal.source = src.holder.owner
		signal.data["command"] = "text_message"
		signal.data["sender_name"] = holder.owner.name
		signal.data["message"] = "[message]" // (?)
		signal.data["sender"] = "00000000" // surely this isn't going to be a problem
		signal.data["address_1"] = pda.net_id

		radio_controller.get_frequency(FREQ_PDA).post_packet_without_source(signal)

	allowcast() // Spooking can be done even while force-manifested
		return TRUE

	proc/do_spook_ability(var/effect as text)
		if (effect == 8)
			effect = rand(1, 7)
		switch (effect)
			if (1)
				boutput(holder.owner, SPAN_NOTICE("You flip some light switches near the designated location!!"))
				for (var/obj/machinery/light_switch/L in range(10, holder.owner))
					L.Attackhand(holder.owner)
				return 0
			if (2)
				boutput(holder.owner, SPAN_NOTICE("You cause a few lights to burn out near the designated location!."))
				var/c_prob = 100
				for (var/obj/machinery/light/L in range(10, holder.owner))
					if (L.status == 2 || L.status == 1)
						continue
					if (prob(c_prob))
						L.broken()
						c_prob *= 0.5
				return 0
			if (3)
				boutput(holder.owner, SPAN_NOTICE("Smoke rises in the designated location."))
				var/turf/trgloc = get_turf(holder.owner)
				if (trgloc && isturf(trgloc))
					var/datum/effects/system/bad_smoke_spread/S = new /datum/effects/system/bad_smoke_spread/(trgloc)
					if (S)
						S.set_up(15, 0, trgloc, null, "#000000")
						S.start()
				return 0
			if (4)
				boutput(holder.owner, SPAN_NOTICE("Matter from your realm appears near the designated location!"))
				var/count = rand(5,9)
				var/turf/trgloc = get_turf(holder.owner)
				var/list/affected = block(locate(trgloc.x - 8,trgloc.y - 8,trgloc.z), locate(trgloc.x + 8,trgloc.y + 8,trgloc.z))
				for (var/i in 1 to count)
					new /obj/item/reagent_containers/food/snacks/ectoplasm(pick(affected))
				return 0
			if (5)
				var/sapped_amt = src.holder.regenRate * 100
				var/obj/machinery/power/apc/apc = locate() in get_area(holder.owner)
				if (!apc)
					boutput(holder.owner, SPAN_ALERT("Power sap failed: local APC not found."))
					return 0
				boutput(holder.owner, SPAN_NOTICE("You sap the power of the chamber's power source."))
				var/obj/item/cell/cell = apc.cell
				if (cell)
					cell.use(sapped_amt)
				return 0
			if (6)
				boutput(holder.owner, SPAN_NOTICE("Mysterious messages haunt PDAs near the designated location!"))
				for (var/mob/living/L in range(10, holder.owner))
					var/obj/item/device/pda2/pda = locate() in L
					if (pda)
						src.haunt_pda(pda)
				for (var/obj/item/device/pda2/pda in range(10, holder.owner))
					src.haunt_pda(pda)
			if (7)
				boutput(holder.owner, SPAN_NOTICE("Crates, lockers and doors mysteriously open and close in the designated area!"))
				var/c_prob = 100
				for(var/obj/machinery/door/G in range(10, holder.owner))
					if (prob(c_prob))
						c_prob *= 0.4
						SPAWN(1 DECI SECOND)
							if (G.density)
								G.open()
							else
								G.close()
				c_prob = 100
				for(var/obj/storage/F in range(10, holder.owner))
					if (prob(c_prob))
						c_prob *= 0.4
						SPAWN(1 DECI SECOND)
							if (F.open)
								F.close()
							else
								F.open()

		return 0
