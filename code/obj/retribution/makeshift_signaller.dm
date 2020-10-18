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
		if (build_stage >= 3)
			user.show_message("<span class='notice'>Uh oh, it seems you broke it!</span>", 1)
			desc = "This doodad seems broken. Call a coder."
			return
		else if (ispulsingtool(W) && build_stage <= 0)
			build_stage = 1
			user.show_message("<span class='notice'>You rearrange and attune the wiring inside!</span>", 1)
			desc = "A remote signaller frame with wiring sticking out."
			return
		else if (istype(W,/obj/item/sheet) && build_stage == 1)
			if (W.amount == 1)
				qdel(W)
			else
				W.amount -= 1
			build_stage = 2
			user.show_message("<span class='notice'>You make a crude but functional circuit board port and slot it into the frame!</span>", 1)
			desc = "A remote signaller frame with a handmade circuit board port slotted loosely into it, connected with wires."
			return
		else if (iswrenchingtool(W) && build_stage == 2)
			build_stage = 3
			var/obj/item/makeshift_syndicate_signaller/A = new /obj/item/makeshift_syndicate_signaller
			user.put_in_hand_or_drop(A)
			A.add_fingerprint(user)
			user.show_message("<span class='notice'>You connect and secure all the loose parts!</span>", 1)
			desc = "An illegal-looking signaller, clearly makeshift. If you're seeing this, alert a coder please."
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
	rarity = ITEM_RARITY_RARE

	attack_self()
		if(metadata >= 8 && !is_exploding)
			//Future me, make this spawn the Syndicate Retribution event please.
			icon_state = "explosion"
			user.show_message("<span class='notice'>You sent a signal to an unknown coordinate derived from the uploaded metadata! This can't be good...</span>", 1)
			desc = "Oh shit, it's overloading!"
			is_exploding = true
			return
		else if(metadata >= 0 && metadata < 8 && !is_exploding)
			user.show_message("<span class='notice'>Metadata nodes currently filled: [metadata]</span>", 1)
			return
		else if(metadata < 0)
			metadata = 0
			user.show_message("<span class='notice'>You reset the metadata nodes.</span>", 1)
			return
		return

	attackby(obj/item/W as obj, mob/user as mob)
		if (metadata < 0)
			metadata = 0
			return
		if (istype(W,/obj/item/factionrep/ntboard) && !is_exploding)
			if (metadata < 8)
				qdel(W)
				user.put_in_hand_or_drop(new /obj/item/factionrep/ntboardfried)
				metadata += 1
				user.show_message("<span class='notice'>You uploaded some metadata from the syndicate circuit board, frying it in the process.</span>", 1)
				set_icon_state("metadata_[metadata]")
				if (metadata >= 8)
					desc = "This device has a menacing aura around it. All 8 nodes of metadata are filled. The signal is ready to be sent."
			else if (metadata >= 8)
					user.show_message("<span class='notice'>All 8 metadata nodes have been filled already!</span>", 1)
			return
		return
