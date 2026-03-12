///Datum used to combine the bounty being claimed with the item being delivered
/datum/bounty_claim
	var/datum/bounty_item/bounty = null
	var/atom/delivery = null

	New(datum/bounty_item/bounty, atom/delivery)
		..()
		src.bounty = bounty
		src.delivery = delivery

	disposing()
		src.bounty = null
		src.delivery = null
		..()

/obj/item/uplink/integrated/pda/spy
	uses = 5 //amount of times that we can deliver items
			//When uses hits 0, the spawn will be an ID tracker
			//at -1 and below, no new item spawns! yer done

	var/start_uses = 5

	var/loops_allowed = 1
	var/loops = 0			//allow us to continue getting gear at a slowed rate instead of allowing uses to go to -1!
	var/max_loops = 8
	var/bounty_tally = 0 //during loop, need more bountieas for rewards to fill

	/// for use with photo printer cooldown
	var/last_photo_print = 0

	var/datum/game_mode/spy_theft/game
	purchase_flags = UPLINK_SPY_THIEF

	disposing()
		if (game)
			game.uplinks -= src
		..()

	setup(var/datum/mind/ownermind, var/obj/item/device/master)
		..()
		RegisterSignal(master, COMSIG_ITEM_ATTACKBY_PRE, PROC_REF(master_pre_attackby))
		if (ticker?.mode)
			if (istype(ticker.mode, /datum/game_mode/spy_theft))
				src.game = ticker.mode
			else //The gamemode is NOT spy, but we've got one on our hands! Set this badboy up.
				if (!ticker.mode.spy_market)
					ticker.mode.spy_market = new /datum/game_mode/spy_theft
					SPAWN(5 SECONDS) //Some possible bounty items (like organs) need some time to get set up properly and be assigned names
						ticker.mode.spy_market.build_bounty_list()
						ticker.mode.spy_market.update_bounty_readouts()
				game = ticker.mode.spy_market

		if (game)
			game.uplinks += src

		return

	///We have hit something with our uplink master device
	proc/master_pre_attackby(obj/item/device/master, atom/target, mob/user)
		var/datum/bounty_item/bounty = src.bounty_is_claimable(target, user)
		if (bounty)
			actions.start(new/datum/action/bar/private/spy_steal(target, src), user)
			return TRUE

	proc/req_bounties()
		if (loops <= 0 || !loops_allowed)
			.= 1
		else
			.= loops+1 - bounty_tally

	///Returns a /datum/bounty_claim containing the bounty that can be claimed and the item that will be delivered
	proc/bounty_is_claimable(atom/A, mob/user)
		.= 0
		if (ismob(A))
			var/mob/M = A
			for (var/obj/possible in M.contents)
				.= bounty_object_is_claimable(possible, user)
				if(.)
					break
		else if (isobj(A))
			.= bounty_object_is_claimable(A, user)

	proc/bounty_object_is_claimable(obj/delivery, mob/user)
		. = FALSE
		for(var/datum/bounty_item/B in game.active_bounties)
			if (B.claimed)
				continue

			var/organ_succ = (B.item && delivery == B.item)
			var/everythingelse_succ = ( (B.path && istype(delivery,B.path)) || B.item && delivery == B.item || (B.photo_containing && istype(delivery,/obj/item/photo) && findtext(delivery.name, B.photo_containing)) )
			if (((B.bounty_type == BOUNTY_TYPE_ORGAN) && organ_succ) || ((B.bounty_type != BOUNTY_TYPE_ORGAN) && everythingelse_succ))
				if (B.delivery_area && B.delivery_area != get_area(src.hostpda))
					user.show_text("You must stand in the designated delivery zone to send this item!", "red")
					if (istype(B.delivery_area, /area/diner))
						user.show_text("It can be found at the nearby space diner!", "red")
					var/turf/end = B.delivery_area.spyturf
					user.gpsToTurf(end, doText = FALSE, all_access = TRUE) // spy thieves probably need to break in anyway, so screw access check
					return FALSE
				for (var/obj/item/device/pda2/P in delivery.contents) //make sure we don't delete the PDA
					if (P.uplink == src)
						return FALSE
				return new /datum/bounty_claim(B, delivery)

	proc/try_deliver(obj/delivery, mob/user)
		if (uses < 0)
			src.ui_update()
			return

		if (!user.mind?.get_antagonist(ROLE_SPY_THIEF))
			user.show_text("You cannot claim a bounty! The PDA doesn't recognize you!", "red")
			return FALSE

		var/datum/bounty_claim/claim = src.bounty_is_claimable(delivery)
		if (!claim)
			user.show_text("You cannot claim [delivery] for bounty!", "red")
			src.ui_update()
			return FALSE
		var/datum/bounty_item/bounty = claim.bounty
		delivery = claim.delivery
		user.removeGpsPath(doText = FALSE)
		bounty.claimed = TRUE

		if (istype(delivery.loc, /mob))
			var/mob/M = delivery.loc
			if (istype(delivery,/obj/item/parts) && ishuman(M))
				var/mob/living/carbon/human/H = M
				var/obj/item/parts/HP = delivery
				if(HP == bounty.item && HP.holder == M) //Is this the right limb and is it attached?
					HP.remove()
					take_bleeding_damage(H, null, 10)
					H.changeStatus("knockdown", 3 SECONDS)
					playsound(H.loc, 'sound/impact_sounds/Flesh_Break_2.ogg', 50, 1)
					H.emote("scream")
					logTheThing(LOG_STATION, user, "spy thief claimed [constructTarget(H)]'s [HP] at [log_loc(user)]")
				else if(HP != bounty.item)
					user.show_text("That isn't the right limb!", "red")
					return FALSE
			else
				M.drop_from_slot(delivery,get_turf(M))
		for (var/mob/M in delivery.contents) //make sure we dont delete mobs inside the stolen item
			M.set_loc(get_turf(delivery))
		if (!istype(delivery,/obj/item/parts))
			logTheThing(LOG_DEBUG, user, "spy thief claimed delivery of: [delivery] at [log_loc(user)]")

		var/datum/antagonist/spy_thief/antag_role = user.mind?.get_antagonist(ROLE_SPY_THIEF)
		if (istype(antag_role))
			antag_role.stolen_items[delivery.name] = new /mutable_appearance(delivery)


		if (req_bounties() > 1)
			bounty_tally += 1
			user.show_text("Your PDA accepts the bounty. Deliver [req_bounties()] more bounties to earn a reward.", "red")
		else
			src.spawn_reward(bounty, user)
		src.ui_update()
		qdel(delivery)
		return TRUE

	proc/loop()
		if (loops_allowed && loops < max_loops)
			uses = start_uses
			loops += 1

	proc/spawn_reward(var/datum/bounty_item/B, var/mob/user)
		B.spawn_reward(user,src.loc)

		if (uses == 0)//Spawn ID tracker. Last item!


			if (loops <= 0)
				if (user.mind)
					var/spawn_tracker = 0
					//for (var/datum/objective/objective in user.mind.objectives)
					//	if (istype(objective,/datum/objective_set/spy_theft/vigilante))
					//		spawn_tracker = 1

					if (spawn_tracker) //only aspawn id tracker if we have the proper objective
						var/obj/item/extra = new /datum/syndicate_buylist/traitor/idtracker/spy
						user.put_in_hand_or_drop(extra)
			loop()

		uses--
		bounty_tally = 0

		return 1

	proc/ui_update() //when the market refreshes or bounties are claimed, everyone needs ta know
		src.generate_menu()
		if(src.active)
			src.print_to_host(src.menu_message)

	/// Prints a photo of the spy theif's target item or mob owner
	proc/print_photo(datum/bounty_item/B, mob/user)
		if (!B) return
		if (!user) return
		if (TIME <= src.last_photo_print + 5 SECONDS)
			boutput(user, SPAN_ALERT("The photo printer is recharging!"))
			return

		var/title = null
		var/detail = null
		var/image/photo_image
		var/icon/photo_icon
		var/atom/A = null
		if ((B.bounty_type == BOUNTY_TYPE_ORGAN) && B.item)
			var/obj/item/parts/O = B.item
			if (O.holder)
				A = O.holder
			else
				A = O // loose limb
		else if (B.item)
			A = B.item

		if (ismob(A))
			var/mob/M = A
			var/list/trackable_mobs = get_mobs_trackable_by_AI()
			if (!(((M.name in trackable_mobs) && (trackable_mobs[M.name] == M)) || (M == user)))
				boutput(user, SPAN_ALERT("Unable to locate target within the station camera network!"))
				return
			photo_image = image(A.icon, null, A.icon_state, null, SOUTH)
			photo_image.overlays = A.overlays
			photo_image.underlays = A.underlays
			photo_icon = M.build_flat_icon(SOUTH)

			title = "photo of [M]"
			var/holding = null
			if (M.l_hand || M.r_hand)
				var/they_are = M.gender == "male" ? "He's" : M.gender == "female" ? "She's" : "They're"
				if (M.l_hand)
					holding = "[they_are] holding \a [M.l_hand]"
				if (M.r_hand)
					if (holding)
						holding += " and \a [M.r_hand]."
					else
						holding = "[they_are] holding \a [M.r_hand]."
				else if (holding)
					holding += "."

			var/they_look = M.gender == "male" ? "he looks" : M.gender == "female" ? "she looks" : "they look"
			var/health_info = M.health < 75 ? " - [they_look][M.health < 25 ? " really" : null] hurt" : null
			if (!detail)
				detail = "In the photo, you can see [M][M.lying ? " lying on [get_turf(M)]" : null][health_info][holding ? ". [holding]" : "."]"

		else
			photo_image = build_composite_icon(A)
			photo_icon = getFlatIcon(A)
			title = "photo of \a [A]"
			detail = "You can see \a [A]."

		var/obj/item/photo/P = new(src, photo_image, photo_icon, title, detail)
		user.put_in_hand_or_drop(P)
		playsound(src, 'sound/machines/scan.ogg', 10, TRUE)
		last_photo_print = TIME

	generate_menu()
		src.menu_message = "<B>Spy Console:</B> Current location: [get_area(src)]<BR>"

		if(reading_synd_int)
			src.menu_message += "<br><h4>Syndicate Intelligence</h4>"
			src.menu_message += get_manifest(FALSE, src)
			src.menu_message += "<br>"
			src.menu_message += "<A href='byond://?src=\ref[src];back_menu=1'>Back</A>"
			return

		else if(reading_specific_synd_int)
			var/datum/db_record/staff_record = reading_specific_synd_int
			src.menu_message += "<br><h4>Syndicate intelligence on [staff_record["name"]]</h4>"
			src.menu_message += replacetext(staff_record["syndint"], "\n", "<br>")
			src.menu_message += "<br>"
			src.menu_message += "<A href='byond://?src=\ref[src];back_menu=1'>Back</A>"
			return

		if (game)
			//var/datum/game_mode/spy_theft/game = ticker.mode

			var/refresh_time_formatted = round((game.last_refresh_time + game.bounty_refresh_interval)/10 ,1)
			refresh_time_formatted = "[round(refresh_time_formatted / 3600)]:[add_zero(round(refresh_time_formatted % 3600 / 60), 2)]:[add_zero(num2text(refresh_time_formatted % 60), 2)]"

			if (src.uses < 0 && (loops >= max_loops || !loops_allowed))
				src.menu_message += "<b>Assasinate the following targets.</b> Be warned, we expect them to be armed and dangerous.<br>"
				for (var/datum/mind/M in ticker.mode.traitors)
					if (M.current)
						src.menu_message += "<tr><td><b>[M.current.name]</b><br></td></tr>"
			else
				if (loops <= 0)
					src.menu_message += ""
					//src.menu_message += "Fulfill <B>[src.uses+1]</B> bounties to track your assasination targets.<BR><HR>"
				else
					src.menu_message += ""
					//src.menu_message += "Fulfill <B>[req_bounties()]</B> bounties receive your next reward. You have already earned your ID tracker.<BR><HR>"
				src.menu_message += "<B>Current Bounties (Next Refresh at : [refresh_time_formatted]):</B>"
				for(var/datum/bounty_item/B in game.active_bounties)
					var/atext = ""
					var/unavailable_text = null // Why the specific bounty can't be redeemed (Claimed, Destroyed or In Cryo)
					if (B.claimed)
						unavailable_text = "CLAIMED"
					else if (B.reveal_area && B.item)
						var/item_area = get_area(B.item)
						if(!item_area) // Also includes if there's no item because if there's no item then it has no area
							unavailable_text = "DESTROYED"
						else if ((locate(/obj/cryotron) in get_turf(B.item)) && !isturf(B.item.loc)) //There's gotta be a better way to check for this
							unavailable_text = "IN CRYOGENIC STORAGE"
						else
							atext = "<br>(Last Seen : [item_area])"
					var/rtext = ""
					if (B.reward)
						if (req_bounties() <= 1)
							rtext = "<br><b>Reward</b> : [B.reward.name] [(B.hot_bounty) ? "<b>**HOT**</b>" : ""]"
						else
							rtext = "<br><b>Reward</b> : Not available. Deliver [req_bounties()] more bounties."

					src.menu_message += "<small><br><br><tr><td><b>[B.name]</b>[rtext][atext]<br>[(unavailable_text) ? "(<b>[unavailable_text]</b>)" : "(Deliver : <b>[B.delivery_area ? B.delivery_area : "Anywhere"]</b>) [B.photo_containing ? "" : "<a href='byond://?src=\ref[src];action=print;bounty=\ref[B]'>Print</a>"]"]</td></tr></small>"

		src.menu_message += "<HR>"

		src.menu_message += "<br><I>Each bounty is open to all spies. Be sure to satisfy the requirements before your enemies.</I><BR><BR>"
		src.menu_message += "<br><I>A **HOT** bounty indicates that the payout will be higher in value.</I><BR><BR>"
		src.menu_message += "<I>Stand in the Deliver Area and touch a bountied item (or use click + drag) to this PDA. Our fancy wormhole tech can take care of the rest. Your efforts will be rewarded.</I><BR><table cellspacing=5>"
		if(has_synd_int && !src.is_VR_uplink)
			src.menu_message += "<HR>"
			src.menu_message += "<A href='byond://?src=\ref[src];synd_int=1'>Syndicate Intelligence</A><BR>"
		return

	Topic(href, href_list)
		if (isnull(src.hostpda) || !src.active)
			return
		if (BOUNDS_DIST(src.hostpda, usr) > 0 || !usr.contents.Find(src.hostpda) || !isliving(usr) || iswraith(usr) || isintangible(usr))
			return
		if (is_incapacitated(usr) || usr.restrained())
			return
		if (href_list["action"])
			if (href_list["action"] == "print" && href_list["bounty"])
				//print photo of item or mob owner
				src.print_photo(locate(href_list["bounty"]) , usr)

		else if (href_list["synd_int"] && !src.is_VR_uplink)
			reading_synd_int = TRUE

		else if (href_list["select_exp"])
			var/datum/db_record/staff_record = locate(href_list["select_exp"])
			reading_specific_synd_int = staff_record
			reading_synd_int = FALSE

		else if (href_list["back_menu"])
			if(reading_synd_int)
				reading_synd_int = FALSE
			if(reading_specific_synd_int)
				reading_specific_synd_int = null
				reading_synd_int = TRUE

		src.generate_menu()
		src.print_to_host(src.menu_message)
		return
