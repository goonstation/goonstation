/obj/item/makeshift_signaller_frame
	name = "makeshift signaller frame"
	icon = 'icons/misc/retribution/makeshift_signaller.dmi'
	icon_state = "frame"
	flags = FPRINT | TABLEPASS | CONDUCT | ONBELT
	w_class = 2.0
	throw_speed = 4
	throw_range = 20
	m_amt = 500
	burn_type = 1
	var/build_stage = 0
	mats = 4
	desc = "A disemboweled remote signaller, ready for further modifications."
	stamina_damage = 0
	stamina_cost = 0
	stamina_crit_chance = 1

	attackby(obj/item/W as obj, mob/user as mob)
		if (build_stage >= 3)											//If build_stage is 3 or higher, which shouldn't be possible, alert the player to in turt alert coders.
			user.show_message("<span class='notice'>Uh oh, it seems you broke it!</span>", 1)
			desc = "This doodad is broken. Call a coder."
			tooltip_rebuild = 1
			return
		else if (ispulsingtool(W) && build_stage <= 0)					//Step 1 of construction: Multitool.
			build_stage = 1
			user.show_message("<span class='notice'>You rearrange and attune the wiring inside!</span>", 1)
			desc = "A remote signaller frame with wiring sticking out."
			tooltip_rebuild = 1
			return
		else if (istype(W,/obj/item/sheet) && build_stage == 1)			//Step 2 of construction: Metal.
			W.amount -= 1
			if (W.amount <= 0)
				qdel(W)
			else
				W.inventory_counter.update_number(W.amount)
			build_stage = 2
			user.show_message("<span class='notice'>You make a crude but functional circuit board port and slot it into the frame!</span>", 1)
			desc = "A remote signaller frame with a handmade circuit board port slotted loosely into it, connected with wires."
			tooltip_rebuild = 1
			return
		else if (iswrenchingtool(W) && build_stage == 2)				//Step 3 of construction: Wrench.
			build_stage = 3
			var/obj/item/makeshift_syndicate_signaller/A = new /obj/item/makeshift_syndicate_signaller
			user.put_in_hand_or_drop(A)
			A.add_fingerprint(user)
			user.show_message("<span class='notice'>You connect and secure all the loose parts!</span>", 1)
			desc = "An illegal-looking signaller, clearly makeshift. If you're seeing this, alert a coder please."
			tooltip_rebuild = 1
			qdel(src)
			return
		return

/obj/item/makeshift_syndicate_signaller
	name = "makeshift syndicate signaller"
	icon = 'icons/misc/retribution/makeshift_signaller.dmi'
	icon_state = "metadata_0"
	flags = FPRINT | TABLEPASS | CONDUCT | ONBELT
	w_class = 2.0
	throw_speed = 4
	throw_range = 20
	m_amt = 500
	var/metadata = 0
	var/is_exploding = false
	is_syndicate = 1
	mats = 4
	desc = "This device has a menacing aura around it. It requires 8 nodes of metadata to properly send and encrypt it's signal."
	contraband = 5

	New()
		RegisterSignal(GLOBAL_SIGNAL, COMSIG_GLOBAL_DRONE_DEATH, .proc/metadata_increase)	//Thanks a bunch to ZeWaka, MarkNstein and Yass for helping me understand what the actual fuck signals are and how they work.
		..()

	attack_self(mob/user as mob)
		if(metadata >= 8 && !is_exploding)								//If all 8 metadata nodes are filled and the item isn't already in it's exploding animation, spawn the Syndicate Retribution event and play the exploding animation, alongside a delayed deletion of the item.
			//Future me, make this spawn the Syndicate Retribution event please.
			icon_state = "explosion"
			user.show_message("<span class='notice'>You sent a signal to an unknown coordinate derived from the uploaded metadata! This can't be good...</span>", 1)
			desc = "Oh shit, it's overloading!"
			tooltip_rebuild = 1
			is_exploding = true
			spawn(2 SECONDS)
				logTheThing("combat", user, null, "has summoned the Syndicate Weapon: Orion Retribution Device. It will arrive in 1 minute.")
				message_admins("[key_name(user)] has summoned the Syndicate Weapon: Orion Retribution Device. It will arrive in 1 minute.")
				elecflash(src.loc)
				qdel(src)
			return
		else if(metadata >= 0 && metadata < 8 && !is_exploding)			//If there are still unfilled metadata nodes left, display the filled nodes' amount.
			user.show_message("<span class='notice'>Metadata nodes currently filled: [metadata]</span>", 1)
			return
		return

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W,/obj/item/factionrep/ntboard) && !is_exploding)	//If a Syndicate Circuit Board is used on this item, turn the former into it's fried version and fill a metadata node.
			if (metadata < 8)
				qdel(W)
				playsound(src.loc, "sound/effects/sparks4.ogg", 100, 0)
				user.put_in_hand_or_drop(new /obj/item/factionrep/ntboardfried)
				metadata += 1
				user.show_message("<span class='notice'>You uploaded some metadata from the syndicate circuit board, frying it in the process.</span>", 1)
				set_icon_state("metadata_[metadata]")
				if (metadata >= 8)
					desc = "This device has a menacing aura around it. All 8 nodes of metadata are filled. The signal is ready to be sent."
					tooltip_rebuild = 1
			else if (metadata >= 8)										//If all metadata nodes are filled, alert the player instead.
				user.show_message("<span class='notice'>All 8 metadata nodes have been filled already!</span>", 1)
			return
		return

/obj/item/makeshift_syndicate_signaller/proc/metadata_increase(source, dying_drone)
	if (metadata >= 8)
		return
	var/turf/T1 = get_turf(src)
	var/turf/T2 = get_turf(dying_drone)
	if (!(istype(dying_drone, /obj/critter/gunbot/drone/buzzdrone/fish) || istype(dying_drone, /obj/critter/gunbot/drone/gunshark)) && T1.z == T2.z)	//Not increasing the filled metadata node amount if the dead drone is an aquatic one, as they drop Syndicate Circuit Boards already.
		if (metadata < 8)
			metadata += 1
			//user.show_message("<span class='notice'>The makeshift syndicate signaller catches a dying drone's distress signal, converting what's possible into readable metadata.</span>", 1) //This needs "mob/user as mob" but I doubt a dying drone can send that information. What do I do here?
			set_icon_state("metadata_[metadata]")
		if (metadata >= 8)
			desc = "This device has a menacing aura around it. All 8 nodes of metadata are filled. The signal is ready to be sent."
			tooltip_rebuild = 1
	return