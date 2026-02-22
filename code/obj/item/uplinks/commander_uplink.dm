#define PLAYERS_PER_UPLINK_POINT 20

/obj/item/device/nukeop_commander_uplink
	name = "nuclear commander uplink"
	desc = "A nifty device used by the commander to order powerful equipment for their team."
	icon = 'icons/obj/items/device.dmi'
	icon_state = "uplink_commander"
	flags = TABLEPASS | CONDUCT
	c_flags = ONBELT
	w_class = W_CLASS_SMALL
	item_state = "uplink_commander"
	throw_speed = 4
	throw_range = 20
	var/points = 2
	var/list/commander_buylist = list()
	var/datum/syndicate_buylist/reading_about = null
	/// Bitflags for what items this uplink can buy (see `_std/defines/uplink.dm` for flags)
	var/purchase_flags = UPLINK_NUKE_COMMANDER
#ifdef BONUS_POINTS
	points = 9999
#endif

	New()
		..()
		var/num_players
		for(var/client/C in clients)
			var/mob/client_mob = C.mob
			if (!istype(client_mob))
				continue
			num_players++
		points = max(2, round(num_players / PLAYERS_PER_UPLINK_POINT))
#ifdef BONUS_POINTS
		points = 9999
#endif
		SPAWN(1 SECOND)
			if (src && istype(src) && (!length(src.commander_buylist)))
				src.setup()

	attackby(obj/item/W, mob/user, params)
		if(istype(W, /obj/item/remote/reinforcement_beacon))
			var/obj/item/remote/reinforcement_beacon/R = W
			if(R.uses >= 1 && !R.anchored)
				R.force_drop(user)
				sleep(1 DECI SECOND)
				boutput(user, SPAN_ALERT("The [src] accepts the [R], warping it away."))
				src.points += 2
				qdel(R)
		else
			..()

	proc/setup()
		for (var/datum/syndicate_buylist/S in syndi_buylist_cache)
			if ((istype(S, /datum/syndicate_buylist/commander) || (S.can_buy & purchase_flags)) && !(S in src.commander_buylist))
				src.commander_buylist.Add(S)

		var/list/names = list()
		var/list/namecounts = list()
		if (length(src.commander_buylist))
			var/list/sort1 = list()

			for (var/datum/syndicate_buylist/S in src.commander_buylist)
				var/name = S.name
				if (name in names) // sanity check
					namecounts[name]++
					name = text("[] ([])", name, namecounts[name])
				else
					names.Add(name)
					namecounts[name] = 1

				sort1[name] = S

			src.commander_buylist = sortList(sort1, /proc/cmp_text_asc)

	attack_self(mob/user)
		return ui_interact(user)

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "ComUplink")
			ui.open()

	ui_data(mob/user)
		. = list(
			"points" = points,
		)

	ui_static_data(mob/user)
		. = list("stock" = list())

		for (var/datum/syndicate_buylist/SB as anything in commander_buylist)
			var/datum/syndicate_buylist/I = commander_buylist[SB]
			.["stock"] += list(list(
				"ref" = "\ref[I]",
				"name" = I.name,
				"description" = I.desc,
				"cost" = I.cost,
				"category" = I.category,
			))

	ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
		. = ..()
		if(.)
			return
		switch(action)
			if ("redeem")
				for(var/datum/syndicate_buylist/SB as anything in commander_buylist)
					if(istype(commander_buylist[SB], locate(params["ref"])))
						var/datum/syndicate_buylist/B = commander_buylist[SB]
						if (src.points >= B.cost)
							src.points -= B.cost

							if (length(B.items) == 0)
								break

							for (var/uplink_item in B.items)
								var/atom/A = new uplink_item(get_turf(src))
								B.run_on_spawn(A, usr, FALSE, src)

								// Remember purchased item for the crew credits
								var/datum/antagonist/nuclear_operative/antagonist_role = usr.mind?.get_antagonist(ROLE_NUKEOP) || usr.mind?.get_antagonist(ROLE_NUKEOP_COMMANDER)
								antagonist_role?.uplink_items.Add(B)

								logTheThing(LOG_STATION, usr, "bought a [initial(B.items[1].name)] from a [src] at [log_loc(usr)].")
								var/loadnum = world.load_intra_round_value("Nuclear-Commander-[initial(B.items[1].name)]-Purchased")
								if(isnull(loadnum))
									loadnum = 0
								world.save_intra_round_value("NuclearCommander-[initial(B.items[1].name)]-Purchased", loadnum + 1)
								. = TRUE
								break

#undef PLAYERS_PER_UPLINK_POINT
