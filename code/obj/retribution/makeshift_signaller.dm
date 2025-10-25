#define MINUTES_TO_SWORD_LINK 30										//Feel free to tweak this number as you see fit. After all, my strong suit is originality, not balance.
var/sword_summoned_before = FALSE

TYPEINFO(/obj/item/makeshift_signaller_frame)
	mats = 4

/obj/item/makeshift_signaller_frame
	name = "makeshift signaller frame"
	icon = 'icons/misc/retribution/makeshift_signaller.dmi'
	icon_state = "frame"
	flags = TABLEPASS | CONDUCT
	c_flags = ONBELT
	w_class = W_CLASS_SMALL
	throw_speed = 4
	throw_range = 20
	m_amt = 500
	burn_remains = BURN_REMAINS_MELT
	var/build_stage = 0
	desc = "A disemboweled remote signaller, ready for further modifications."
	stamina_damage = 0
	stamina_cost = 0
	stamina_crit_chance = 1

	attackby(obj/item/W, mob/user)
		if (build_stage >= 4)														//If build_stage is 4 or higher, which shouldn't be possible, alert the player to in turt alert coders.
			user.show_message(SPAN_NOTICE("Uh oh, it seems you broke it!"), 1)
			desc = "This doodad is broken. Call a coder."
			tooltip_rebuild = TRUE
			return
		else if (ispulsingtool(W) && build_stage <= 0)								//Step 1 of construction: Multitool.
			build_stage = 1
			user.show_message(SPAN_NOTICE("You rearrange and attune the wiring inside!"), 1)
			desc = "A remote signaller frame with wiring sticking out."
			tooltip_rebuild = TRUE
			return
		else if (istype(W,/obj/item/sheet) && build_stage == 1)						//Step 2 of construction: Metal Sheet.
			W.amount -= 1
			if (W.amount <= 0)
				qdel(W)
			else
				W.inventory_counter.update_number(W.amount)
			build_stage = 2
			user.show_message(SPAN_NOTICE("You make a crude but functional circuit board port and slot it into the frame!"), 1)
			desc = "A remote signaller frame with a handmade circuit board port slotted loosely into it, connected with wires."
			tooltip_rebuild = TRUE
			return
		else if (istype(W,/obj/item/circuitboard/secure_data) && build_stage == 2)	//Step 3 of construction: Circuit Board.
			qdel(W)
			build_stage = 3
			user.show_message(SPAN_NOTICE("You put the circuit board in the port!"), 1)
			desc = "A remote signaller frame with a circuit board inside, being held together with a custom port and some wiring."
			tooltip_rebuild = TRUE
		else if (iswrenchingtool(W) && build_stage == 3)							//Step 4 of construction: Wrench.
			build_stage = 4
			var/obj/item/makeshift_syndicate_signaller/A = new /obj/item/makeshift_syndicate_signaller
			user.put_in_hand_or_drop(A)
			A.add_fingerprint(user)
			user.show_message(SPAN_NOTICE("You connect and secure all the loose parts!"), 1)
			desc = "An illegal-looking signaller, clearly makeshift. If you're seeing this, alert a coder please."
			tooltip_rebuild = TRUE
			SEND_SIGNAL(src, COMSIG_ITEM_CONVERTED, A, user)
			qdel(src)
			return
		return

TYPEINFO(/obj/item/makeshift_syndicate_signaller)
	mats = 4

/obj/item/makeshift_syndicate_signaller
	name = "makeshift syndicate signaller"
	icon = 'icons/misc/retribution/makeshift_signaller.dmi'
	icon_state = "metadata_0"
	flags = TABLEPASS | CONDUCT
	c_flags = ONBELT
	w_class = W_CLASS_SMALL
	throw_speed = 4
	throw_range = 20
	m_amt = 500
	var/metadata = 0
	var/was_emagged = FALSE
	var/is_exploding = FALSE
	is_syndicate = 1
	desc = "This device has a menacing aura around it. It requires 8 nodes of metadata to properly send and encrypt it's signal."
	contraband = 5

	New()
		RegisterSignal(GLOBAL_SIGNAL, COMSIG_GLOBAL_DRONE_DEATH, PROC_REF(metadata_increase))	//Thanks a bunch to ZeWaka, MarkNstein and Yass for helping me understand what the actual fuck signals are and how they work.
		..()

	attack_self(mob/user as mob)
		if (metadata >= 8 && !is_exploding)								//If all 8 metadata nodes are filled and the item isn't already in it's exploding animation, spawn the Syndicate Retribution event and play the exploding animation, alongside a delayed deletion of the item.
			if (ticker.round_elapsed_ticks >= MINUTES_TO_SWORD_LINK MINUTES)
				if (!isrestrictedz(src.z))
					if (!sword_summoned_before)
						var/list/nearby_turfs = list()
						for (var/turf/T in oview(src.loc,10))
							if (istype(T, /turf/space))
								nearby_turfs += T
						if (length(nearby_turfs))
							new/obj/critter/sword(pick(nearby_turfs))
							sword_summoned_before = TRUE

							icon_state = "explosion"
							user.show_message(SPAN_NOTICE("You sent a signal to unknown coordinates derived from the uploaded metadata! This can't be good..."), 1)
							desc = "Oh shit, it's overloading!"
							tooltip_rebuild = TRUE
							is_exploding = TRUE
							spawn(2 SECONDS)
								logTheThing(LOG_COMBAT, user, "has summoned the Syndicate Weapon: Orion Retribution Device. It will become active in about 1 minute.")
								message_admins("[key_name(user)] has summoned the Syndicate Weapon: Orion Retribution Device. It will become active in about 1 minute.")
								elecflash(src.loc)
								qdel(src)
							return
						else
							user.show_message(SPAN_NOTICE("You failed to send a signal. To avoid interference, it's best to try again closer to open space."), 1)
					else
						user.show_message(SPAN_NOTICE("You failed to send a signal. The device seems oddly dormant..."), 1)
						desc = "This device is dormant. It has no purpose now."
						tooltip_rebuild = TRUE
				else
					user.show_message(SPAN_NOTICE("You failed to send a signal. To avoid interference, it's best to try again in an unrestricted area."), 1)
			else
				user.show_message(SPAN_NOTICE("You failed to send a signal. The device is currently waiting for a link to establish. It's best to try again later."), 1)
		else if (metadata >= 0 && metadata < 8 && !is_exploding)			//If there are still unfilled metadata nodes left, display the filled nodes' amount.
			user.show_message(SPAN_NOTICE("Metadata nodes currently filled: [metadata]"), 1)
			return
		return

	attackby(obj/item/W, mob/user)
		if (istype(W,/obj/item/factionrep/ntboard) && !is_exploding)	//If a Syndicate Circuit Board is used on this item, turn the former into it's fried version and fill a metadata node.
			if (metadata < 8)
				qdel(W)
				playsound(src.loc, 'sound/effects/sparks4.ogg', 100, 0)
				user.put_in_hand_or_drop(new /obj/item/factionrep/ntboardfried)
				metadata += 1
				user.show_message(SPAN_NOTICE("You uploaded some metadata from the syndicate circuit board, frying it in the process."), 1)
				set_icon_state("metadata_[metadata]")
				if (metadata >= 8)
					desc = "This device has a menacing aura around it. All 8 nodes of metadata are filled. The signal is ready to be sent."
					tooltip_rebuild = TRUE
			else if (metadata >= 8)										//If all metadata nodes are filled, alert the player instead.
				user.show_message(SPAN_NOTICE("All 8 metadata nodes have been filled already!"), 1)
			return
		return

	emag_act(mob/user, obj/item/card/emag/E)
		. = ..()
		if (!was_emagged)
			if (metadata >= 8)											//If all metadata nodes are filled, alert the player instead.
				user.show_message(SPAN_NOTICE("All 8 metadata nodes have been filled already!"), 1)
				return
			else
				metadata += rand(2, 7)
				playsound(src.loc, 'sound/misc/flockmind/flockdrone_beep2.ogg', 60, 0)
				playsound(src.loc, 'sound/effects/sparks4.ogg', 100, 0)
				was_emagged = TRUE
				. = TRUE
			if(metadata >= 8)
				desc = "This device has a menacing aura around it. All 8 nodes of metadata are filled. The signal is ready to be sent."
				tooltip_rebuild = TRUE
			set_icon_state("metadata_[metadata]")
		else
			user.show_message(SPAN_NOTICE("This device has been emagged already!"), 1)

/obj/item/makeshift_syndicate_signaller/proc/metadata_increase(source, dying_drone)
	if (metadata >= 8)
		return
	var/turf/T1 = get_turf(src)
	var/turf/T2 = get_turf(dying_drone)
	if (!(istype(dying_drone, /obj/critter/gunbot/drone/buzzdrone/fish) || istype(dying_drone, /obj/critter/gunbot/drone/gunshark)) && T1.z == T2.z)	//Not increasing the filled metadata node amount if the dead drone is an aquatic one, as they drop Syndicate Circuit Boards already.
		if (metadata < 8)
			metadata += 1
			playsound(src.loc, 'sound/misc/flockmind/flockdrone_beep3.ogg', metadata * 12, 0)
			set_icon_state("metadata_[metadata]")
		if (metadata >= 8)
			playsound(src.loc, 'sound/misc/flockmind/flockdrone_beep4.ogg', 100, 0)
			if(!sword_summoned_before)
				desc = "This device has a menacing aura around it. All 8 nodes of metadata are filled. The signal is ready to be sent."
			else
				desc = "This device has no menacing aura around it. In fact, it is completely dormant."
			tooltip_rebuild = TRUE
	return
