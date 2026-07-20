/obj/item/uplink
	name = "uplink"
	stamina_damage = 0
	stamina_cost = 0
	stamina_crit_chance = 0

	var/uses = 12 // Amount of telecrystals.
	var/list/datum/syndicate_buylist/items_general = list() // See setup() and validate_spawn().
	var/list/datum/syndicate_buylist/items_job = list()
	var/list/datum/syndicate_buylist/items_objective = list()
	var/list/datum/syndicate_buylist/items_telecrystal = list()
	var/list/datum/syndicate_buylist/items_ammo = list()
	var/is_VR_uplink = 0
	var/lock_code = null
	var/lock_code_autogenerate = 0
	var/locked = 0
	var/reading_synd_int = FALSE
	var/reading_specific_synd_int = null
	var/has_synd_int = TRUE
#ifdef BONUS_POINTS
	uses = 9999
#endif

	/// Allow direct UI interaction with this uplink through attackself?
	var/can_directly_open = FALSE
	var/temp = null
	var/selfdestruct = 0
	var/can_selfdestruct = 0
	var/datum/syndicate_buylist/reading_about = null

	/// Bitflags for what items this uplink can buy (see `_std/defines/uplink.dm` for flags)
	var/purchase_flags
	var/owner_ckey = null

	/// Associative list, where keys are /datum/syndicate_buylist types and values are the number of purchases.
	var/list/purchase_log = list()

	// Spawned uplinks for which setup() wasn't called manually only get the standard (generic) items.
	New()
		..()
		if (istype(get_area(src), /area/sim/gunsim))
			src.is_VR_uplink = TRUE
		SPAWN(1 SECOND)
			if (src && istype(src) && (!length(src.items_general) && !length(src.items_job) && !length(src.items_objective) && !length(src.items_telecrystal) && !length(src.items_ammo)))
				src.setup()

	disposing()
		reading_specific_synd_int = null
		reading_about = null
		..()

	proc/generate_code()
		if (!src || !istype(src))
			return

		var/code = "[rand(100,999)] [pick("Alpha","Bravo","Delta","Omega","Gamma","Zeta")]"
		return code

	proc/setup(var/datum/mind/ownermind, var/obj/item/device/master)
		if (!src || !istype(src))
			return

		src.owner_ckey = ownermind?.ckey

		if (!islist(src.items_general))
			src.items_general = list()
		if (!islist(src.items_job))
			src.items_job = list()
		if (!islist(src.items_objective))
			src.items_objective = list()
		if (!islist(src.items_telecrystal))
			src.items_telecrystal = list()
		if (!islist(src.items_ammo))
			src.items_ammo = list()

		for (var/datum/syndicate_buylist/S in syndi_buylist_cache)
			if (src.is_VR_uplink)
				if (!S.vr_allowed)
					continue
				if (S.objective)
					src.items_objective.Add(S)
				else if (S.job)
					src.items_job.Add(S)
				else
					src.items_general.Add(S)

			else

				if(!(S.can_buy & purchase_flags))
					continue

				if (istype(S, /datum/syndicate_buylist/surplus))
					continue

				if (istype(S, /datum/syndicate_buylist/generic) && !src.items_general.Find(S))
					if (S.telecrystal)
						src.items_telecrystal.Add(S)
						src.items_general.Remove(S)
					else
						src.items_general.Add(S)

				if (ownermind || istype(ownermind))
					if (!isnukeop(ownermind.current) && istype(S, /datum/syndicate_buylist/traitor))
						if (!S.objective && !S.job && !src.items_general.Find(S))
							src.items_general.Add(S)
						if (S.ammo)
							src.items_ammo.Add(S)
							src.items_general.Remove(S)


					if (S.objective)
						if (ownermind.objectives)
							var/has_objective = 0
							for (var/datum/objective/O in ownermind.objectives)
								if (istype(O, S.objective))
									has_objective = 1
							if (has_objective && !src.items_objective.Find(S))
								src.items_objective.Add(S)

					if (S.job)
						for (var/allowedjob in S.job)
							if (ownermind.assigned_role && ownermind.assigned_role == allowedjob && !src.items_job.Find(S))
								src.items_job.Add(S)

		// Sort alphabetically by item name.
		var/list/names = list()
		var/list/namecounts = list()

		if (length(src.items_general))
			var/list/sort1 = list()

			for (var/datum/syndicate_buylist/S1 in src.items_general)
				var/name = S1.name
				if (name in names) // Should never, ever happen, but better safe than sorry.
					namecounts[name]++
					name = text("[] ([])", name, namecounts[name])
				else
					names.Add(name)
					namecounts[name] = 1

				sort1[name] = S1

			src.items_general = sortList(sort1, /proc/cmp_text_asc)

		if (length(src.items_job))
			var/list/sort2 = list()

			for (var/datum/syndicate_buylist/S2 in src.items_job)
				var/name = S2.name
				if (name in names)
					namecounts[name]++
					name = text("[] ([])", name, namecounts[name])
				else
					names.Add(name)
					namecounts[name] = 1

				sort2[name] = S2

			src.items_job = sortList(sort2, /proc/cmp_text_asc)

		if (length(src.items_objective))
			var/list/sort3 = list()

			for (var/datum/syndicate_buylist/S3 in src.items_objective)
				var/name = S3.name
				if (name in names)
					namecounts[name]++
					name = text("[] ([])", name, namecounts[name])
				else
					names.Add(name)
					namecounts[name] = 1

				sort3[name] = S3

			src.items_objective = sortList(sort3, /proc/cmp_text_asc)

		if (length(src.items_ammo))
			var/list/sort4 = list()

			for (var/datum/syndicate_buylist/S4 in src.items_ammo)
				var/name = S4.name
				if (name in names)
					namecounts[name]++
					name = text("[] ([])", name, namecounts[name])
				else
					names.Add(name)
					namecounts[name] = 1

				sort4[name] = S4

			src.items_ammo = sortList(sort4, /proc/cmp_text_asc)

		if (length(src.items_telecrystal))
			var/list/sort5 = list()

			for (var/datum/syndicate_buylist/S5 in src.items_telecrystal)
				var/name = S5.name
				if (name in names)
					namecounts[name]++
					name = text("[] ([])", name, namecounts[name])
				else
					names.Add(name)
					namecounts[name] = 1

				sort5[name] = S5

			src.items_telecrystal = sortList(sort5, /proc/cmp_text_asc)

		src.update_static_data_for_all_viewers() //In case someone pulls up the UI in the second before New() calls setup()
		return

	proc/vr_check(var/mob/user)
		if (!src || !istype(src) || !user || !ismob(user))
			return 0
		if (src.is_VR_uplink == 0)
			return 1

		var/area/A = get_area(user)
		if (!A || !istype(A, /area/sim))
			return 0
		else
			return 1

	proc/explode()
		if (!src || !istype(src))
			return

		if (src.can_selfdestruct == 1)
			var/turf/location = get_turf(src.loc)
			if (location && isturf(location))
				location.hotspot_expose(700,125)
				explosion(src, location, 0, 0, 2, 4)
			qdel(src)

		return

	attack_self(mob/user as mob)
		if(!src.can_directly_open)
			return
		if (!src.vr_check(user))
			user.show_text("This uplink only works in virtual reality.", "red")
			return
		if(src.locked)
			src.try_unlock(user)
		if(src.locked)
			return
		src.ui_interact(user)

	attackby(obj/item/W, mob/user)
		if(src.locked)
			return
		if (istype(W, /obj/item/uplink_telecrystal/trick))
			boutput(user, SPAN_ALERT("The [W] explodes!"))
			var/turf/T = get_turf(W.loc)
			if(T)
				T.hotspot_expose(700,125)
				explosion(W, T, -1, -1, 2, 3) //about equal to a PDA bomb
			W.set_loc(user.loc)
			qdel(W)
		else if (istype(W, /obj/item/uplink_telecrystal))
			var/crystal_amount = W.amount
			uses = uses + crystal_amount
			boutput(user, "You insert [crystal_amount] [syndicate_currency] into the [src].")
			qdel(W)

	// Validates that the user is not trying to spawn something they should not
	proc/validate_spawn(var/datum/syndicate_buylist/SB)

		for(var/S in items_general)
			if(SB == items_general[S])
				return 1

		for(var/S in items_job)
			if(SB == items_job[S])
				return 1

		for(var/S in items_objective)
			if(SB == items_objective[S])
				return 1

		for(var/S in items_telecrystal)
			if(SB == items_telecrystal[S])
				return 1

		for(var/S in items_ammo)
			if (SB == items_ammo[S])
				return 1

		return 0

	proc/try_buy(var/datum/syndicate_buylist/I)
		if (!I || !istype(I))
			//usr.show_text("Something went wrong (invalid syndicate_buylist reference). Please try again and contact a coder if the problem persists.", "red")
			return

		// Trying to spawn things you shouldn't, eh?
		if(!validate_spawn(I))
			trigger_anti_cheat(usr, "tried to href exploit the syndicate buylist")
			return

		if (!src.is_VR_uplink)
			if (src.uses < I.cost)
				boutput(usr, SPAN_ALERT("The uplink doesn't have enough [syndicate_currency] left for that!"))
				return
			if (src.purchase_log[I.type] >= I.max_buy)
				boutput(usr, SPAN_ALERT("You have already bought as many of those as you can!"))
				return
			src.uses = max(0, src.uses - I.cost)

			if (src.purchase_flags & UPLINK_TRAITOR)
				var/datum/antagonist/traitor/antagonist_role = usr.mind?.get_antagonist(ROLE_TRAITOR)
				if (istype(antagonist_role) && !istype(I, /datum/syndicate_buylist/generic/telecrystal))
					antagonist_role.purchased_items.Add(I)

			if (src.purchase_flags & UPLINK_HEAD_REV)
				var/datum/antagonist/head_revolutionary/antagonist_role = usr.mind?.get_antagonist(ROLE_HEAD_REVOLUTIONARY)
				if (istype(antagonist_role) && !istype(I, /datum/syndicate_buylist/generic/telecrystal))
					antagonist_role.purchased_items.Add(I)

			if (src.purchase_flags & UPLINK_NUKE_OP)
				var/datum/antagonist/nuclear_operative/antagonist_role = usr.mind?.get_antagonist(ROLE_NUKEOP) || usr.mind?.get_antagonist(ROLE_NUKEOP_COMMANDER)
				if (istype(antagonist_role) && !istype(I, /datum/syndicate_buylist/generic/telecrystal))
					antagonist_role.uplink_items.Add(I)

			logTheThing(LOG_DEBUG, usr, "bought this from [owner_ckey || "unknown"]'s uplink: [I.name] (in [src.loc])")

		if (length(I.items) > 0)
			for (var/uplink_item in I.items)
				var/obj/item = new uplink_item(get_turf(src))
				I.run_on_spawn(item, usr, FALSE, src)
			if (src.is_VR_uplink == 0)
				var/datum/eventRecord/AntagItemPurchase/antagItemPurchaseEvent = new()
				antagItemPurchaseEvent.buildAndSend(usr, I.name, I.cost)
				if (!src.purchase_log[I.type])
					src.purchase_log[I.type] = 0
				src.purchase_log[I.type]++

	proc/lock(mob/user)
		if(src.locked || src.is_VR_uplink)
			return FALSE
		tgui_process.close_uis(src)
		user.show_text("The uplink is now locked.", "blue")
		src.locked = 1
		return TRUE

	proc/self_destruct()
		if(!src.can_selfdestruct)
			return
		src.selfdestruct = 1
		logTheThing(LOG_COMBAT, usr, "activates the self destruct on [owner_ckey || "unknown"]'s uplink")
		SPAWN(10 SECONDS)
			if (src)
				src.explode()

#define CHECK1 (BOUNDS_DIST(src, user) > 0 || !user.contents.Find(src) || !isliving(user) || iswraith(user) || isintangible(user))
#define CHECK2 (is_incapacitated(user) || user.restrained())
	proc/try_unlock(mob/user)
		var/the_code = adminscrub(tgui_input_text(user, "Please enter the password.", "Unlock Uplink", null))
		if (!src || !istype(src) || !user || !ismob(user) || CHECK1 || CHECK2)
			return
		if (isnull(the_code) || !cmptext(the_code, src.lock_code))
			user.show_text("Incorrect password.", "red")
			return

		src.locked = 0
		user.show_text("The uplink beeps softly and unlocks.", "blue")
#undef CHECK1
#undef CHECK2

// --- TGUI Uplinks
	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if (!ui)
			ui = new(user, src, "Uplink")
			ui.open()

	ui_data(mob/user)
		. = list(
			"currency_amount" = src.uses,
			"purchased_items" = src.purchase_log,
			"self_destructing" = src.selfdestruct,
		)

	ui_static_data(mob/user)
		. = list(
			"title" = "Syndicate Uplink",
			"theme" = "syndicate",
			"currency_name" = global.syndicate_currency,
			"item_entries" = src.get_categorised_item_data(),
			"vr" = src.is_VR_uplink,
			"can_lock" = !isnull(src.lock_code) || istype(src, /obj/item/uplink/integrated/radio), //radio uplink codes are on their associated radio
			"can_self_destruct" = src.can_selfdestruct,
		)

	proc/get_categorised_item_data()
		var/list/all_items = src.items_general + src.items_job + src.items_objective + src.items_telecrystal + src.items_ammo
		var/list/categorised_data = list()
		for(var/category in UPLINK.CATEGORY._get_namespace_constants())
			categorised_data[category] = list()
		for(var/buylist_name in all_items)
			var/datum/syndicate_buylist/buylist_entry = all_items[buylist_name]
			categorised_data[buylist_entry.get_category()] += src.get_item_data(buylist_entry)
		for(var/category in categorised_data)
			if(!length(categorised_data[category]))
				categorised_data -= category
		return categorised_data

	proc/get_item_data(var/datum/syndicate_buylist/uplink_item)
		return list(list(
			"name" = uplink_item.name,
			"desc" = uplink_item.desc,
			"cost" = uplink_item.cost,
			"icon" = getItemIcon(uplink_item.items[1]),
			"vr_allowed"= uplink_item.vr_allowed,
			"ref" = ref(uplink_item),
			"type" = uplink_item.type,
			"purchase_limit" = uplink_item.max_buy,
		))

	ui_act(action, list/params)
		. = ..()
		if (.)
			return
		switch (action)
			if ("purchase")
				src.try_buy(locate(params["item_ref"]))
			if ("lock")
				src.lock(usr)
			if("self_destruct")
				if(tgui_alert(usr, "Detonate this uplink?", "Self Destruct Confirmation", list("Confirm", "Cancel")) != "Confirm")
					return
				src.self_destruct()
