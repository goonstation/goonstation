// Stuff you wear on your back
/obj/item/clothing/back
	wear_layer = MOB_BACK_LAYER
	c_flags = ONBACK

/obj/item/clothing/back/hoscape
	name = "Head of Security's cape"
	desc = "A lightly-armored and stylish cape, made of heat-resistant materials. It probably won't keep you warm, but it would make a great security blanket!"
	icon = 'icons/obj/clothing/overcoats/item_suit_armor.dmi' // too lazy to move sprites around rn. will do if we need more back clothes
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_armor.dmi'
	inhand_image_icon = 'icons/mob/inhand/overcoat/hand_suit_armor.dmi'
	icon_state = "hos-cape"
	item_state = "hos-cape"
	body_parts_covered = TORSO|ARMS

	setupProperties()
		..()
		setProperty("meleeprot", 2)
		setProperty("rangedprot", 0.5)
		setProperty("coldprot", 5)
		setProperty("heatprot", 15)

// ------------------- BEDSHEET HELL -----------------------------
/obj/item/clothing/back/bedsheet
	name = "bedsheet"
	desc = "A linen sheet used to cover yourself while you sleep. Preferably on a bed."
	icon_state = "bedsheet"
	uses_multiple_icon_states = TRUE
	item_state = "bedsheet"
	icon = 'icons/obj/clothing/overcoats/item_suit.dmi' // ditto
	inhand_image_icon = 'icons/mob/inhand/overcoat/hand_suit.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit.dmi'
	layer = MOB_LAYER
	w_class = W_CLASS_TINY
	c_flags = COVERSEYES | COVERSMOUTH | ONBACK
	hides_from_examine = C_UNIFORM|C_GLOVES|C_SHOES|C_GLASSES|C_EARS|C_MASK
	body_parts_covered = TORSO|ARMS
	see_face = FALSE
	over_hair = TRUE
	wear_layer = MOB_OVERLAY_BASE
	var/eyeholes = FALSE //Did we remember to cut eyes in the thing?
	var/cape = FALSE
	var/obj/stool/bed/bed = null
	var/bcolor = null
	//cogwerks - burn vars
	burn_point = 450
	burn_output = 800

	health = 4
	block_vision = TRUE

	setupProperties()
		..()
		setProperty("coldprot", 10)

	Move()
		. = ..()
		if(src.bed)
			src.bed.Move(src.loc)

	New()
		..()
		src.UpdateIcon()
		src.setMaterial(getMaterial("cotton"), appearance = FALSE, setname = FALSE)

	attack_hand(mob/user)
		if (src.bed)
			src.bed.untuck_sheet(user)
		src.bed = null
		return ..()

	ex_act(severity)
		if (severity <= 2)
			if (src.bed && src.bed.sheet == src)
				src.bed.sheet = null
			qdel(src)
			return
		return

	attack_self(mob/user as mob)
		add_fingerprint(user)
		var/choice = input(user, "What do you want to do with [src]?", "Selection") as null|anything in list("Place", "Rip up")
		if (!choice)
			return
		switch (choice)
			if ("Place")
				user.drop_item()
				src.layer = EFFECTS_LAYER_BASE-1
				return
			if ("Rip up")
				try_rip_up(user)

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/cable_coil))
			if (src.cape)
				return ..()
			src.make_cape()
			boutput(user, "You tie the bedsheet into a cape.")
			return

		else if (issnippingtool(W))
			var/list/actions = list("Make bandages")
			if (src.cape)
				actions += "Cut cable"
			else if (!src.eyeholes)
				actions += "Cut eyeholes"
			var/action = input(user, "What do you want to do with [src]?") as null|anything in actions
			if (!action)
				return
			switch (action)
				if ("Make bandages")
					boutput(user, "You begin cutting up [src].")
					if (!do_after(user, 3 SECONDS))
						boutput(user, "<span class='alert'>You were interrupted!</span>")
						return
					else
						for (var/i=3, i>0, i--)
							new /obj/item/bandage(get_turf(src))
						playsound(src.loc, 'sound/items/Scissor.ogg', 100, 1)
						boutput(user, "You cut [src] into bandages.")
						user.u_equip(src)
						qdel(src)
						return
				if ("Cut cable")
					src.cut_cape()
					playsound(src.loc, 'sound/items/Scissor.ogg', 100, 1)
					boutput(user, "You cut the cable that's tying the bedsheet into a cape.")
					return
				if ("Cut eyeholes")
					src.cut_eyeholes()
					playsound(src.loc, 'sound/items/Scissor.ogg', 100, 1)
					boutput(user, "You cut eyeholes in the bedsheet.")
					return
		else
			return ..()

	update_icon()
		if (src.cape)
			src.icon_state = "bedcape[src.bcolor ? "-[bcolor]" : null]"
			src.item_state = src.icon_state
			see_face = TRUE
			over_hair = FALSE
			wear_layer = MOB_BACK_LAYER + 0.2
		else
			src.icon_state = "bedsheet[src.bcolor ? "-[bcolor]" : null][src.eyeholes ? "1" : null]"
			src.item_state = src.icon_state
			see_face = FALSE
			over_hair = TRUE
			wear_layer = MOB_OVERLAY_BASE

	proc/cut_eyeholes()
		if (src.cape || src.eyeholes)
			return
		if (src.bed && src.bed.loc == src.loc)
			src.bed.untuck_sheet()
		src.bed = null
		src.eyeholes = TRUE
		block_vision = FALSE
		src.UpdateIcon()
		src.update_examine()
		desc = "It's a bedsheet with eye holes cut in it."

	proc/make_cape()
		if (src.cape)
			return
		if (src.bed && src.bed.loc == src.loc)
			src.bed.untuck_sheet()
		src.bed = null
		src.cape = TRUE
		block_vision = FALSE
		src.UpdateIcon()
		src.update_examine()
		desc = "It's a bedsheet that's been tied into a cape."

	proc/cut_cape()
		if (!src.cape)
			return
		if (src.bed && src.bed.loc == src.loc)
			src.bed.untuck_sheet()
		src.bed = null
		src.cape = FALSE
		block_vision = !src.eyeholes
		src.UpdateIcon()
		src.update_examine()
		desc = "A linen sheet used to cover yourself while you sleep. Preferably on a bed."

	proc/update_examine()
		if(src.cape)
			src.hides_from_examine = 0
		else if(src.eyeholes)
			src.hides_from_examine = (C_UNIFORM|C_GLOVES|C_SHOES|C_EARS)
		else
			src.hides_from_examine = initial(src.hides_from_examine)

/obj/item/clothing/back/bedsheet/red
	icon_state = "bedsheet-red"
	item_state = "bedsheet-red"
	bcolor = "red"

/obj/item/clothing/back/bedsheet/orange
	icon_state = "bedsheet-orange"
	item_state = "bedsheet-orange"
	bcolor = "orange"

/obj/item/clothing/back/bedsheet/yellow
	icon_state = "bedsheet-yellow"
	item_state = "bedsheet-yellow"
	bcolor = "yellow"

/obj/item/clothing/back/bedsheet/green
	icon_state = "bedsheet-green"
	item_state = "bedsheet-green"
	bcolor = "green"

/obj/item/clothing/back/bedsheet/blue
	icon_state = "bedsheet-blue"
	item_state = "bedsheet-blue"
	bcolor = "blue"

/obj/item/clothing/back/bedsheet/pink
	icon_state = "bedsheet-pink"
	item_state = "bedsheet-pink"
	bcolor = "pink"

/obj/item/clothing/back/bedsheet/black
	icon_state = "bedsheet-black"
	item_state = "bedsheet-black"
	bcolor = "black"

/obj/item/clothing/back/bedsheet/hop
	icon_state = "bedsheet-hop"
	item_state = "bedsheet-hop"
	bcolor = "hop"

/obj/item/clothing/back/bedsheet/captain
	icon_state = "bedsheet-captain"
	item_state = "bedsheet-captain"
	bcolor = "captain"

/obj/item/clothing/back/bedsheet/royal
	icon_state = "bedsheet-royal"
	item_state = "bedsheet-royal"
	bcolor = "royal"

/obj/item/clothing/back/bedsheet/psych
	icon_state = "bedsheet-psych"
	item_state = "bedsheet-psych"
	bcolor = "psych"

/obj/item/clothing/back/bedsheet/random
	New()
		..()
		src.bcolor = pick("", "red", "orange", "yellow", "green", "blue", "pink", "black")
		src.UpdateIcon()

/obj/item/clothing/back/bedsheet/cape
	icon_state = "bedcape"
	item_state = "bedcape"
	cape = TRUE
	wear_layer = MOB_BACK_LAYER + 0.2
	block_vision = 0

/obj/item/clothing/back/bedsheet/cape/red
	icon_state = "bedcape-red"
	item_state = "bedcape-red"
	bcolor = "red"

/obj/item/clothing/back/bedsheet/cape/orange
	icon_state = "bedcape-orange"
	item_state = "bedcape-orange"
	bcolor = "orange"

/obj/item/clothing/back/bedsheet/cape/yellow
	icon_state = "bedcape-yellow"
	item_state = "bedcape-yellow"
	bcolor = "yellow"

/obj/item/clothing/back/bedsheet/cape/green
	icon_state = "bedcape-green"
	item_state = "bedcape-green"
	bcolor = "green"

/obj/item/clothing/back/bedsheet/cape/blue
	icon_state = "bedcape-blue"
	item_state = "bedcape-blue"
	bcolor = "blue"

/obj/item/clothing/back/bedsheet/cape/pink
	icon_state = "bedcape-pink"
	item_state = "bedcape-pink"
	bcolor = "pink"

/obj/item/clothing/back/bedsheet/cape/black
	icon_state = "bedcape-black"
	item_state = "bedcape-black"
	bcolor = "black"

/obj/item/clothing/back/bedsheet/cape/hop
	icon_state = "bedcape-hop"
	item_state = "bedcape-hop"
	bcolor = "hop"

/obj/item/clothing/back/bedsheet/cape/captain
	icon_state = "bedcape-captain"
	item_state = "bedcape-captain"
	bcolor = "captain"

/obj/item/clothing/back/bedsheet/cape/royal
	icon_state = "bedcape-royal"
	item_state = "bedcape-royal"
	bcolor = "royal"

/obj/item/clothing/back/bedsheet/cape/psych
	icon_state = "bedcape-psych"
	item_state = "bedcape-psych"
	bcolor = "psych"

// ------------------------ END BEDSHEET HELL --------------------------------
