// SUITS
//setup.dm
//#define SUITBLOOD_ARMOR 1
//#define SUITBLOOD_COAT 2

/obj/item/clothing/suit
	name = "leather jacket"
	desc = "Made from real Space Bovine, but don't call it cowhide under penalty of Article 5.P3RG."
	icon = 'icons/obj/clothing/overcoats/item_suit.dmi'
	inhand_image_icon = 'icons/mob/inhand/overcoat/hand_suit.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit.dmi'
	icon_state = "ljacket"
	item_state = "ljacket"
	wear_layer = MOB_ARMOR_LAYER
	var/fire_resist = T0C+100
	/// If TRUE the suit will hide whoever is wearing it's hair
	var/over_hair = FALSE
	flags = FPRINT | TABLEPASS
	w_class = W_CLASS_NORMAL
	var/restrain_wearer = 0
	var/bloodoverlayimage = 0
	var/team_num
	/// Used for the toggle_hood component, should be the same as the default icon_state so it can get updated with medal rewards.
	var/coat_style = null


	setupProperties()
		..()
		setProperty("coldprot", 5)
		setProperty("heatprot", 5)
		setProperty("meleeprot", 2)

/obj/item/clothing/suit/hoodie
	name = "hoodie"
	desc = "Nice and comfy on those cold space evenings."
	icon_state = "hoodie"
	item_state = "hoodie"
	body_parts_covered = TORSO|ARMS
	var/hcolor = null

	New()
		..()
		src.AddComponent(/datum/component/toggle_hood, hood_style="hoodie[src.hcolor ? "-[hcolor]" : null]")
		src.icon_state = "hoodie[src.hcolor ? "-[hcolor]" : null]"
		src.item_state = "hoodie[src.hcolor ? "-[hcolor]" : null]"

	setupProperties()
		..()
		setProperty("coldprot", 25)

	blue
		desc = "Would fit well on a skeleton."
		icon_state = "hoodie-blue"
		item_state = "hoodie-blue"
		hcolor = "blue"

	darkblue
		icon_state = "hoodie-darkblue"
		item_state = "hoodie-darkblue"
		hcolor = "darkblue"

	white
		icon_state = "hoodie-white"
		item_state = "hoodie-white"
		hcolor = "white"

	pink
		icon_state = "hoodie-pink"
		item_state = "hoodie-pink"
		hcolor = "pink"

	black
		icon_state = "hoodie-black"
		item_state = "hoodie-black"
		hcolor = "black"

	grey
		icon_state = "hoodie-grey"
		item_state = "hoodie-grey"
		hcolor = "grey"

	dullgrey
		icon_state = "hoodie-dullgrey"
		item_state = "hoodie-dullgrey"
		hcolor = "dullgrey"

	magenta
		icon_state = "hoodie-magenta"
		item_state = "hoodie-magenta"
		hcolor = "magenta"

	green
		icon_state = "hoodie-green"
		item_state = "hoodie-green"
		hcolor = "green"

	yellow
		icon_state = "hoodie-yellow"
		item_state = "hoodie-yellow"
		hcolor = "yellow"

	red
		icon_state = "hoodie-red"
		item_state = "hoodie-red"
		hcolor = "red"

/obj/item/clothing/suit/hoodie/random
	New()
		if (prob(50))
			hcolor = null
		else
			hcolor = "blue"
		..()

/obj/item/clothing/suit/jacket
	name = "jacket"
	desc = "Should you be seeing this? The answer is no!"
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_gimmick.dmi'
	body_parts_covered = TORSO|ARMS
	bloodoverlayimage = SUITBLOOD_COAT

	setupProperties()
		..()
		setProperty("coldprot", 20)

	dan
		name = "logo jacket"
		desc = "A dark teal jacket made of heavy synthetic fabric. It has the Discount Dan's logo printed on the back."
		icon_state = "dan_teal"
		item_state = "dan_teal"

		setupProperties()
			..()
			setProperty("coldprot", 25)

	plastic
		name = "plastic jacket"
		desc = "A flimsy and translucent plastic jacket that comes in a variety of colors. Someone who wears this must either have negative fashion or impeccable taste."
		icon_state = "jacket_plastic"
		item_state = "jacket_plastic"

		setupProperties()
			..()
			setProperty("coldprot", 10)

		random_color
			New()
				..()
				src.color = random_saturated_hex_color(1)


	yellow
		name = "yellow jacket"
		desc = "A yellow jacket with a floral design embroidered on the back."
		icon_state = "jacket_yellow"
		item_state = "jacket_yellow"

	sparkly
		name = "sparkly jacket"
		desc = "No glitter. No LEDs. Just magic!"
		icon_state = "jacket_sparkly"
		item_state = "jacket_sparkly"

	design
		name = "jacket"
		desc = "A colorful jacket with a neat design on the back."
		var/random_design

		New()
			..()
			random_design = rand(1,10)
			src.wear_image.overlays += image(src.wear_image_icon,"design_[random_design]")

		update_wear_image(mob/living/carbon/human/H, override)
			src.wear_image.overlays = list(image(src.wear_image.icon,"[override ? "suit-" : ""]design_[random_design]"))
		tan
			name = "tan jacket"
			icon_state = "jacket_tan"
			item_state = "jacket_tan"

		maroon
			name = "maroon jacket"
			icon_state = "jacket_maroon"
			item_state = "jacket_maroon"

		magenta
			name = "magenta jacket"
			icon_state = "jacket_magenta"
			item_state = "jacket_magenta"

		mint
			name = "mint jacket"
			icon_state = "jacket_mint"
			item_state = "jacket_mint"

		cerulean
			name = "cerulean jacket"
			icon_state = "jacket_cerulean"
			item_state = "jacket_cerulean"

		navy
			name = "navy jacket"
			icon_state = "jacket_navy"
			item_state = "jacket_navy"

		indigo
			name = "indigo jacket"
			icon_state = "jacket_indigo"
			item_state = "jacket_indigo"

		grey
			name = "grey jacket"
			icon_state = "jacket_grey"
			item_state = "jacket_grey"

/obj/item/clothing/suit/bio_suit
	name = "bio suit"
	desc = "A suit that protects against biological contamination."
	icon_state = "bio_suit"
	item_state = "bio_suit"
	icon = 'icons/obj/clothing/overcoats/item_suit_hazard.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_hazard.dmi'
	inhand_image_icon = 'icons/mob/inhand/overcoat/hand_suit_hazard.dmi'
	body_parts_covered = TORSO|LEGS|ARMS
	hides_from_examine = C_UNIFORM|C_GLOVES|C_SHOES

	setupProperties()
		..()
		setProperty("coldprot", 15)
		setProperty("heatprot", 15)
		setProperty("viralprot", 50)
		setProperty("chemprot", 60)
		setProperty("meleeprot", 2)
		setProperty("rangedprot", 0.5)
		setProperty("movespeed", 0.3)
		setProperty("disorient_resist", 15)

/obj/item/clothing/suit/bio_suit/attackby(obj/item/W, mob/user)
	var/turf/T = user.loc
	if(istype(W, /obj/item/clothing/suit/armor/vest))
		boutput(user, "<span class='notice'>You attach [W] to [src].</span>")
		if (istype(src, /obj/item/clothing/suit/bio_suit/paramedic))
			new/obj/item/clothing/suit/bio_suit/paramedic/armored(T)
		else
			new/obj/item/clothing/suit/bio_suit/armored(T)
		qdel(W)
		qdel(src)

/obj/item/clothing/suit/bio_suit/janitor // Adhara stuff
	name = "bio suit"
	desc = "A suit that protects against biological contamination. This one has purple boots."
	icon_state = "biosuit_jani"
	item_state = "biosuit_jani"

/obj/item/clothing/suit/bio_suit/paramedic
	name = "paramedic suit"
	desc = "A protective padded suit for emergency response personnel. Offers limited thermal and biological protection."
	icon_state = "paramedic"
	item_state = "paramedic"
	body_parts_covered = TORSO|LEGS|ARMS
	hides_from_examine = C_UNIFORM|C_SHOES
	protective_temperature = 3000
#ifdef MAP_OVERRIDE_NADIR
	c_flags = SPACEWEAR
	acid_survival_time = 5 MINUTES
#endif

	setupProperties()
		..()
		setProperty("coldprot", 25)
		setProperty("heatprot", 25)
		setProperty("chemprot", 30)
		setProperty("meleeprot", 3)
		setProperty("rangedprot", 0.9)
		delProperty("movespeed")
		delProperty("disorient_resist")

/obj/item/clothing/suit/bio_suit/armored
	name = "armored bio suit"
	desc = "A suit that protects against biological contamination. Somebody slapped some bulky armor onto the chest."
	icon_state = "armorbio"
	item_state = "armorbio"
	setupProperties()
		..()
		setProperty("meleeprot", 5)
		setProperty("rangedprot", 1)
		setProperty("movespeed", 0.45)

/obj/item/clothing/suit/bio_suit/armored/nt
	name = "\improper NT bio suit"
	desc = "An armored biosuit that protects against biological contamination and toolboxes."
	icon_state = "ntbio"
	item_state = "ntbio"
	setupProperties()
		..()
		setProperty("meleeprot", 5)
		setProperty("rangedprot", 1)
		delProperty("movespeed")

/obj/item/clothing/suit/bio_suit/paramedic/armored
	name = "armored paramedic suit"
	desc = "A protective padded suit for emergency response personnel. Offers limited thermal and biological protection. Somebody slapped some armor onto the chest."
	icon_state = "para_armor"
	item_state = "paramedic"
	setupProperties()
		..()
		setProperty("meleeprot", 5)
		setProperty("rangedprot", 1)

	para_troop
		icon_state = "para_sec"
		item_state = "para_sec"
		name = "rapid response armor"
		desc = "A protective padded suit for emergency reponse personnel. Tailored for ground operations, not vaccuum rated. This one bears security insignia."

	para_eng
		name = "rapid response armor"
		desc = "A protective padded suit for emergency response personnel. Tailored for ground operations, not vaccuum rated. This one bears engineering insignia."
		icon_state = "para_eng"
		item_state = "para_eng"

/obj/item/clothing/suit/space/suv
	name = "\improper SUV suit"
	desc = "Engineered to do some doohickey with radiation or something. Man this thing is cool."
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_gimmick.dmi'
	inhand_image_icon = 'icons/mob/inhand/overcoat/hand_suit_gimmick.dmi'
	icon_state = "hev"
	item_state = "hev"
	c_flags = SPACEWEAR
	body_parts_covered = TORSO|LEGS|ARMS
	hides_from_examine = C_UNIFORM|C_GLOVES|C_SHOES

	setupProperties()
		..()
		setProperty("radprot", 50)
		setProperty("meleeprot", 4)
		setProperty("rangedprot", 2)
		setProperty("movespeed", 1)
		setProperty("disorient_resist", 35) //it's a special item

/obj/item/clothing/suit/rad // re-added for Russian Station as there is a permarads area there!
	name = "\improper Class II radiation suit"
	desc = "An old Soviet radiation suit made of 100% space asbestos. It's good for you!"
	icon_state = "rad"
	item_state = "rad"
	icon = 'icons/obj/clothing/overcoats/item_suit_hazard.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_hazard.dmi'
	inhand_image_icon = 'icons/mob/inhand/overcoat/hand_suit_hazard.dmi'
	body_parts_covered = TORSO|LEGS|ARMS
	hides_from_examine = C_UNIFORM|C_GLOVES|C_SHOES

	New()
		. = ..()
		AddComponent(/datum/component/wearertargeting/geiger, list(SLOT_WEAR_SUIT))

	setupProperties()
		..()
		setProperty("movespeed", 0.3)
		setProperty("radprot", 50)
		setProperty("coldprot", 15)
		setProperty("heatprot", 15)
		setProperty("chemprot", 25)
		setProperty("meleeprot", 3)
		setProperty("rangedprot", 0.5)
		setProperty("disorient_resist", 15)

/obj/item/clothing/suit/det_suit
	name = "coat"
	desc = "Someone who wears this means business."
	icon_state = "detective"
	item_state = "det_suit"
	body_parts_covered = TORSO|LEGS|ARMS
	bloodoverlayimage = SUITBLOOD_COAT

	setupProperties()
		..()
		setProperty("meleeprot", 2)
		setProperty("rangedprot", 0.5)

/obj/item/clothing/suit/det_suit/beepsky
	name = "worn jacket"
	desc = "This tattered jacket has seen better days."
	icon = 'icons/obj/clothing/overcoats/item_suit_armor.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_armor.dmi'
	icon_state = "ntarmor"

	setupProperties()
		..()
		setProperty("meleeprot", 2)
		setProperty("rangedprot", 0.5)

/obj/item/clothing/suit/det_suit/hos
	name = "Head of Security's jacket"
	desc = "A slightly armored jacket favored by security personnel. It looks cozy and warm; you could probably sleep in this if you wanted to!"
	icon = 'icons/obj/clothing/overcoats/item_suit_armor.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_armor.dmi'
	icon_state = "hoscoat"

	setupProperties()
		..()
		setProperty("meleeprot", 3)
		setProperty("rangedprot", 0.7)
		setProperty("coldprot", 35)

/obj/item/clothing/suit/hopjacket
	name = "Head of Personnel's jacket"
	desc = "A tacky green and red jacket for a tacky green bureaucrat."
	icon_state = "hopjacket"
	uses_multiple_icon_states = TRUE
	item_state = "hopjacket"
	coat_style = "hopjacket"
	bloodoverlayimage = SUITBLOOD_COAT

	setupProperties()
		..()
		setProperty("rangedprot", 0.5)


	New()
		..()
		src.AddComponent(/datum/component/toggle_coat, coat_style = "[src.coat_style]", buttoned = TRUE)

/obj/item/clothing/suit/judgerobe
	name = "judge's robe"
	desc = "This robe commands authority."
	icon_state = "judge"
	item_state = "judge"
	body_parts_covered = TORSO|LEGS|ARMS
	hides_from_examine = C_UNIFORM

/obj/item/clothing/suit/chef
	name = "chef's coat"
	desc = "BuRK BuRK BuRK - Bork Bork Bork!"
	icon_state = "chef"
	item_state = "chef"
	body_parts_covered = TORSO|LEGS|ARMS

	setupProperties()
		..()
		setProperty("heatprot", 10)

/obj/item/clothing/suit/apron
	name = "apron"
	desc = "A protective frontal garment designed to guard clothing against spills."
	icon_state = "sousapron"
	item_state = "sousapron"
	body_parts_covered = TORSO

	setupProperties()
		..()
		setProperty("chemprot", 10)


/obj/item/clothing/suit/apron/tricolor
	name = "pizza apron"
	desc = "An apron made specifically to protect from tomato sauce."
	icon_state = "triapron"
	item_state = "triapron"
	body_parts_covered = TORSO

/obj/item/clothing/suit/apron/botanist
	name = "blue apron"
	desc = "This will keep you safe from tomato stains. Unless they're the exploding ones"
	icon_state = "apron-botany"
	item_state = "apron-botany"

/obj/item/clothing/suit/apron/slasher
	name = "butcher's apron"
	desc = "A brown butcher's apron, you can feel an aura of something dark radiating off of it."
	icon_state = "apron-welder"
	item_state = "apron-welder"
	cant_self_remove = TRUE
	cant_other_remove = TRUE
	item_function_flags = IMMUNE_TO_ACID

	setupProperties()
		..()
		setProperty("meleeprot", 7)
		setProperty("rangedprot", 2)
		setProperty("coldprot", 75)
		setProperty("heatprot", 75)
		setProperty("movespeed", 0.4)
		setProperty("exploprot", 30)


	postpossession
		cant_self_remove = FALSE
		cant_other_remove = FALSE
		name = "worn apron"
		desc = "A brown, faded butcher's apron, it looks as though it's over a hundred years old."

		setupProperties()
			..()
			setProperty("meleeprot", 1)
			setProperty("rangedprot", 0)
			setProperty("coldprot", 10)
			setProperty("heatprot", 10)
			setProperty("movespeed", 0.4)

/obj/item/clothing/suit/apron/surgeon
	name = "surgeon's apron"
	desc = "A white apron with a tendency to be spattered with red substances."
	icon_state = "apron-surgeon"
	item_state = "apron-surgeon"

/obj/item/clothing/suit/labcoat
	name = "labcoat"
	desc = "A suit that protects against minor chemical spills and biohazards."
	icon_state = "labcoat"
	uses_multiple_icon_states = 1
	item_state = "labcoat"
	coat_style = "labcoat"
	body_parts_covered = TORSO|ARMS
	bloodoverlayimage = SUITBLOOD_COAT

	setupProperties()
		..()
		setProperty("coldprot", 15)
		setProperty("heatprot", 15)
		setProperty("chemprot", 25)

	New()
		..()
		src.AddComponent(/datum/component/toggle_coat, coat_style = "[src.coat_style]", buttoned = TRUE)


/obj/item/clothing/suit/labcoat/genetics
	name = "geneticist's labcoat"
	desc = "A protective laboratory coat with the green markings of a Geneticist."
	icon_state = "GNlabcoat"
	item_state = "GNlabcoat"
	coat_style = "GNlabcoat"

	april_fools
		icon_state = "GNlabcoat-alt"
		item_state = "GNlabcoat-alt"
		coat_style = "GNlabcoat-alt"

/obj/item/clothing/suit/labcoat/robotics
	name = "roboticist's labcoat"
	desc = "A protective laboratory coat with the black markings of a Roboticist."
	icon_state = "ROlabcoat"
	item_state = "ROlabcoat"
	coat_style = "ROlabcoat"

	april_fools
		icon_state = "ROlabcoat-alt"
		item_state = "ROlabcoat-alt"
		coat_style = "ROlabcoat-alt"

/obj/item/clothing/suit/labcoat/medical
	name = "doctor's labcoat"
	desc = "A protective laboratory coat with the red markings of a Medical Doctor."
	icon_state = "MDlabcoat"
	item_state = "MDlabcoat"
	coat_style = "MDlabcoat"

	april_fools
		desc = "A protective laboratory coat with the blue markings of a Medical Doctor."
		icon_state = "MDlabcoat-alt"
		item_state = "MDlabcoat-alt"
		coat_style = "MDlabcoat-alt"

	cool
		icon_state = "MDlabcoat-cool"
		coat_style = "MDlabcoat-cool"

/obj/item/clothing/suit/labcoat/medical_director
	name = "medical director's labcoat"
	desc = "The Medical Directors personal labcoat, its creation was commisioned and designed by the director themself."
	icon_state = "MDlonglabcoat"
	item_state = "MDlonglabcoat"
	coat_style = "MDlonglabcoat"

/obj/item/clothing/suit/labcoat/pathology
	name = "pathologist's labcoat"
	desc = "A protective laboratory coat with the orange markings of a Pathologist."
	icon_state = "PTlabcoat"
	item_state = "PTlabcoat"
	coat_style = "PTlabcoat"

	april_fools
		icon_state = "PTlabcoat-alt"
		item_state = "PTlabcoat-alt"
		coat_style = "PTlabcoat-alt"

/obj/item/clothing/suit/labcoat/science
	name = "scientist's labcoat"
	desc = "A protective laboratory coat with the purple markings of a Scientist."
	icon_state = "SCIlabcoat"
	item_state = "SCIlabcoat"
	coat_style = "SCIlabcoat"

	april_fools
		icon_state = "SCIlabcoat-alt"
		item_state = "SCIlabcoat-alt"
		coat_style = "SCIlabcoat-alt"

/obj/item/clothing/suit/labcoat/dan
	name = "orange labcoat"
	desc = "A protective laboratory coat with the orange markings of a Discount Dan's lead scientist. How did it get here?"
	icon_state = "DANlabcoat"
	item_state = "DANlabcoat"
	coat_style = "DANlabcoat"

/obj/item/clothing/suit/straight_jacket
	name = "straight jacket"
	desc = "A suit that totally restrains an individual."
	icon_state = "straight_jacket"
	item_state = "straight_jacket"
	body_parts_covered = TORSO|LEGS|ARMS
	restrain_wearer = TRUE
	hides_from_examine = C_UNIFORM

	setupProperties()
		..()
		setProperty("coldprot", 20)
		setProperty("heatprot", 20)
		setProperty("movespeed", 15)

/obj/item/clothing/suit/wcoat
	name = "waistcoat"
	desc = "Style over abdominal protection."
	icon_state = "vest"
	item_state = "wcoat"
	magical = TRUE
	body_parts_covered = TORSO|ARMS
	bloodoverlayimage = SUITBLOOD_ARMOR

	setupProperties()
		..()
		setProperty("coldprot", 10)
		setProperty("heatprot", 10)

/obj/item/clothing/suit/bedsheet
	name = "bedsheet"
	desc = "A linen sheet used to cover yourself while you sleep. Preferably on a bed."
	icon_state = "bedsheet"
	uses_multiple_icon_states = 1
	item_state = "bedsheet"
	layer = MOB_LAYER
	throwforce = 1
	w_class = W_CLASS_TINY
	throw_speed = 2
	throw_range = 10
	c_flags = COVERSEYES | COVERSMOUTH
	hides_from_examine = C_UNIFORM|C_GLOVES|C_SHOES|C_GLASSES|C_EARS
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
	burn_possible = TRUE

	health = 4
	rand_pos = FALSE
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
		desc = "A linen sheet used to cover yourself while you sleep. Preferably on a bed."

/obj/item/clothing/suit/bedsheet/red
	icon_state = "bedsheet-red"
	item_state = "bedsheet-red"
	bcolor = "red"

/obj/item/clothing/suit/bedsheet/orange
	icon_state = "bedsheet-orange"
	item_state = "bedsheet-orange"
	bcolor = "orange"

/obj/item/clothing/suit/bedsheet/yellow
	icon_state = "bedsheet-yellow"
	item_state = "bedsheet-yellow"
	bcolor = "yellow"

/obj/item/clothing/suit/bedsheet/green
	icon_state = "bedsheet-green"
	item_state = "bedsheet-green"
	bcolor = "green"

/obj/item/clothing/suit/bedsheet/blue
	icon_state = "bedsheet-blue"
	item_state = "bedsheet-blue"
	bcolor = "blue"

/obj/item/clothing/suit/bedsheet/pink
	icon_state = "bedsheet-pink"
	item_state = "bedsheet-pink"
	bcolor = "pink"

/obj/item/clothing/suit/bedsheet/black
	icon_state = "bedsheet-black"
	item_state = "bedsheet-black"
	bcolor = "black"

/obj/item/clothing/suit/bedsheet/hop
	icon_state = "bedsheet-hop"
	item_state = "bedsheet-hop"
	bcolor = "hop"

/obj/item/clothing/suit/bedsheet/captain
	icon_state = "bedsheet-captain"
	item_state = "bedsheet-captain"
	bcolor = "captain"

/obj/item/clothing/suit/bedsheet/royal
	icon_state = "bedsheet-royal"
	item_state = "bedsheet-royal"
	bcolor = "royal"

/obj/item/clothing/suit/bedsheet/psych
	icon_state = "bedsheet-psych"
	item_state = "bedsheet-psych"
	bcolor = "psych"

/obj/item/clothing/suit/bedsheet/random
	New()
		..()
		src.bcolor = pick("", "red", "orange", "yellow", "green", "blue", "pink", "black")
		src.UpdateIcon()

/obj/item/clothing/suit/bedsheet/cape
	icon_state = "bedcape"
	item_state = "bedcape"
	cape = 1
	wear_layer = MOB_BACK_LAYER + 0.2
	block_vision = 0

/obj/item/clothing/suit/bedsheet/cape/red
	icon_state = "bedcape-red"
	item_state = "bedcape-red"
	bcolor = "red"

/obj/item/clothing/suit/bedsheet/cape/orange
	icon_state = "bedcape-orange"
	item_state = "bedcape-orange"
	bcolor = "orange"

/obj/item/clothing/suit/bedsheet/cape/yellow
	icon_state = "bedcape-yellow"
	item_state = "bedcape-yellow"
	bcolor = "yellow"

/obj/item/clothing/suit/bedsheet/cape/green
	icon_state = "bedcape-green"
	item_state = "bedcape-green"
	bcolor = "green"

/obj/item/clothing/suit/bedsheet/cape/blue
	icon_state = "bedcape-blue"
	item_state = "bedcape-blue"
	bcolor = "blue"

/obj/item/clothing/suit/bedsheet/cape/pink
	icon_state = "bedcape-pink"
	item_state = "bedcape-pink"
	bcolor = "pink"

/obj/item/clothing/suit/bedsheet/cape/black
	icon_state = "bedcape-black"
	item_state = "bedcape-black"
	bcolor = "black"

/obj/item/clothing/suit/bedsheet/cape/hop
	icon_state = "bedcape-hop"
	item_state = "bedcape-hop"
	bcolor = "hop"

/obj/item/clothing/suit/bedsheet/cape/captain
	icon_state = "bedcape-captain"
	item_state = "bedcape-captain"
	bcolor = "captain"

/obj/item/clothing/suit/bedsheet/cape/royal
	icon_state = "bedcape-royal"
	item_state = "bedcape-royal"
	bcolor = "royal"

/obj/item/clothing/suit/bedsheet/cape/psych
	icon_state = "bedcape-psych"
	item_state = "bedcape-psych"
	bcolor = "psych"

// FIRE SUITS

/obj/item/clothing/suit/fire
	name = "firesuit"
	desc = "A suit that protects against fire and heat."
	icon = 'icons/obj/clothing/overcoats/item_suit_hazard.dmi'
	inhand_image_icon = 'icons/mob/inhand/overcoat/hand_suit_hazard.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_hazard.dmi'
	icon_state = "fire"
	item_state = "fire_suit"
	body_parts_covered = TORSO|LEGS|ARMS
	hides_from_examine = C_UNIFORM|C_SHOES
	protective_temperature = 4500

	setupProperties()
		..()
		setProperty("coldprot", 20)
		setProperty("heatprot", 45)
		setProperty("chemprot", 10)
		setProperty("meleeprot", 3)
		setProperty("rangedprot", 0.5)
		setProperty("movespeed", 0.6)
		setProperty("disorient_resist", 15)

/obj/item/clothing/suit/fire/armored
	name = "armored firesuit"
	desc = "A suit that protects against fire and heat. Somebody slapped some bulky armor onto the chest."
	icon_state = "fire_armor"
	item_state = "fire_suit"
	setupProperties()
		..()
		setProperty("meleeprot", 6)
		setProperty("rangedprot", 1)
		setProperty("movespeed", 1)

/obj/item/clothing/suit/fire/attackby(obj/item/W, mob/user)
	var/turf/T = user.loc
	if (istype(W, /obj/item/clothing/suit/armor/vest))
		if (istype(src, /obj/item/clothing/suit/fire/heavy))
			return
		else
			new /obj/item/clothing/suit/fire/armored(T)
		boutput(user, "<span class='notice'>You attach [W] to [src].</span>")
		qdel(W)
		qdel(src)

/obj/item/clothing/suit/fire/heavy
	name = "heavy firesuit"
	desc = "A suit that protects against extreme fire and heat."
	icon_state = "thermal"
	item_state = "thermal"
	hides_from_examine = C_UNIFORM|C_SHOES|C_GLOVES

	protective_temperature = 100000

	setupProperties()
		..()
		setProperty("coldprot", 5)
		setProperty("heatprot", 65)
		setProperty("meleeprot", 4)
		setProperty("rangedprot", 0.8)
		setProperty("movespeed", 1.5)
		setProperty("disorient_resist", 25)

// SWEATERS

/obj/item/clothing/suit/sweater
	name = "diamond sweater"
	desc = "A pretty warm-looking knit sweater. This is one of those I.N. designer sweaters."
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_gimmick.dmi'
	inhand_image_icon = 'icons/mob/inhand/overcoat/hand_suit_gimmick.dmi'
	icon_state = "sweater_blue"
	item_state = "sweater_blue"
	body_parts_covered = TORSO|ARMS

	setupProperties()
		..()
		setProperty("coldprot", 20)

	red
		name = "reindeer sweater"
		icon_state = "sweater_red"
		item_state = "sweater_red"

	green
		name = "snowflake sweater"
		icon_state = "sweater_green"
		item_state = "sweater_green"

	grandma
		name = "grandma sweater"
		icon_state = "sweater_green"
		item_state = "sweater_green"
		desc = "A pretty warm-looking knit sweater, made by your grandma.  Yes, YOUR grandma!  Even if you stole this from someone else."

		New()
			..()
			src.setMaterial(getMaterial("cotton"), appearance = 0, setname = 0)

// LONG SHIRTS
// No they're not sweaters

/obj/item/clothing/suit/lshirt
	name = "long sleeved shirt"
	desc = "A long sleeved shirt. It has a sinister looking cyborg head printed on the front."
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_gimmick.dmi'
	icon_state = "lshirt"
	item_state = "lshirt"
	body_parts_covered = TORSO|ARMS

	setupProperties()
		..()
		setProperty("coldprot", 15)

	dan_red
		name = "long sleeved logo shirt"
		icon_state = "dan_red"
		item_state = "dan_red"
		desc = "A comfy looking long sleeved shirt with the Discount Dan's logo stitched on the front. Delicious-looking tortilla chips are stitched on the back."

	dan_blue
		name = "long sleeved logo shirt"
		icon_state = "dan_blue"
		item_state = "dan_blue"
		desc = "A comfy looking long sleeved shirt with the Discount Dan's logo stitched on the front. Delicious-looking tortilla chips are stitched on the back."

// SPACE SUITS

/obj/item/clothing/suit/space
	name = "space suit"
	desc = "A suit that protects against low pressure environments."
	icon = 'icons/obj/clothing/overcoats/item_suit_hazard.dmi'
	inhand_image_icon = 'icons/mob/inhand/overcoat/hand_suit_hazard.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_hazard.dmi'
	icon_state = "space"
	item_state = "s_suit"
	c_flags = SPACEWEAR
	body_parts_covered = TORSO|LEGS|ARMS
	hides_from_examine = C_UNIFORM|C_SHOES|C_GLOVES
	duration_remove = 6 SECONDS
	duration_put = 6 SECONDS
	protective_temperature = 1000

	New()
		..()
		if(!istype(get_area(src), /area/station))
			var/nt_wear_state = "[src.wear_state || src.icon_state]-nt"
			if(nt_wear_state in icon_states(src.wear_image_icon))
				src.wear_state = nt_wear_state

	setupProperties()
		..()
		setProperty("coldprot", 50)
		setProperty("heatprot", 20)
		setProperty("viralprot", 50)
		setProperty("chemprot", 30)
		setProperty("meleeprot", 3)
		setProperty("rangedprot", 0.5)
		setProperty("space_movespeed", 0.6)
		setProperty("radprot", 10)

/obj/item/clothing/suit/space/emerg
	name = "emergency suit"
	desc = "A suit that protects against low pressure environments for a short time. Amazingly, it's even more bulky and uncomfortable than the engineering suits."
	icon_state = "emerg"
	item_state = "emerg"
	c_flags = SPACEWEAR
	body_parts_covered = TORSO|LEGS|ARMS
	var/rip = 0
	acid_survival_time = 3 MINUTES

	setupProperties()
		..()
		setProperty("space_movespeed", 1.5)

/obj/item/clothing/suit/space/captain
	name = "captain's space suit"
	desc = "A suit that protects against low pressure environments and is green."
	icon_state = "spacecap"
	item_state = "spacecap"

	setupProperties()
		..()
		setProperty("space_movespeed", 0.3)

	blue
		icon_state = "spacecap-blue"
		item_state = "spacecap-blue"

	red
		icon_state = "spacecap-red"
		item_state = "spacecap-red"

/obj/item/clothing/suit/space/syndicate_worn
	name = "worn syndicate space suit"
	icon_state = "syndicate"
	item_state = "space_suit_syndicate"
	desc = "A suit that protects against low pressure environments. Issued to syndicate operatives. Looks like this one has seen better days."
	contraband = 3

/obj/item/clothing/suit/space/syndicate
	name = "syndicate space suit"
	icon_state = "syndicate"
	item_state = "space_suit_syndicate"
	desc = "A suit that protects against low pressure environments. Issued to syndicate operatives."
	contraband = 3
	team_num = TEAM_SYNDICATE
	item_function_flags = IMMUNE_TO_ACID

	New()
		..()
		START_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)

	setupProperties()
		..()
		setProperty("heatprot", 35)

	#ifdef MAP_OVERRIDE_POD_WARS
	attack_hand(mob/user)
		if (get_pod_wars_team_num(user) == team_num)
			..()
		else
			boutput(user, "<span class='alert'>The space suit <b>explodes</b> as you reach out to grab it!</span>")
			make_fake_explosion(src)
			user.u_equip(src)
			src.dropped(user)
			qdel(src)
	#endif

	setupProperties()
		..()
		setProperty("chemprot",60)
		setProperty("space_movespeed", 0)  // syndicate space suits don't suffer from slowdown

	disposing()
		STOP_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		..()

	commissar_greatcoat
		name = "commander's great coat"
		icon_state = "commissar_greatcoat"
		desc = "A fear-inspiring, black-leather great coat, typically worn by a Syndicate Nuclear Operative Commander. So scary even the vacuum of space doesn't dare claim the wearer."
		team_num = TEAM_SYNDICATE
		hides_from_examine = C_UNIFORM|C_SHOES
		#ifdef MAP_OVERRIDE_POD_WARS
		attack_hand(mob/user)
			if (get_pod_wars_team_num(user) == team_num)
				..()
			else
				boutput(user, "<span class='alert'>The coat <b>explodes</b> as you reach out to grab it!</span>")
				make_fake_explosion(src)
				user.u_equip(src)
				src.dropped(user)
				qdel(src)
		#endif

		setupProperties()
			..()
			setProperty("exploprot", 40)
			setProperty("meleeprot", 6)
			setProperty("rangedprot", 3)

	knight // nukie melee class armor
		name = "citadel heavy combat cuirass"
		desc = "A syndicate issue super-heavy combat armor suit, pressurized for space travel and reinforced for superior staying-power in extended battle."
		icon_state = "syndie_specialist-knight"
		item_state = "syndie_specialist-knight"

		setupProperties()
			..()
			setProperty("meleeprot", 6)
			setProperty("rangedprot", 1)
			setProperty("exploprot", 40)
			setProperty("space_movespeed", 0.9)
			setProperty("disorient_resist", 65)

	specialist
		name = "specialist operative combat dress"
		desc = "A syndicate issue combat dress system, pressurized for space travel."
		icon_state = "syndie_specialist"
		item_state = "syndie_specialist"

		setupProperties()
			..()
			setProperty("exploprot", 30)
			setProperty("meleeprot", 4)
			setProperty("rangedprot", 1.5)

		medic
			name = "specialist operative medic uniform"
			desc = "A syndicate issue combat dress system, pressurized for space travel."
			icon_state = "syndie_specialist-medic"
			item_state = "syndie_specialist-medic"

			body_parts_covered = TORSO|LEGS|ARMS

			setupProperties()
				..()
				setProperty("viralprot", 50)

		infiltrator
			name = "specialist operative espionage suit"
			desc = "A syndicate issue combat dress system, pressurized for space travel."
			icon_state = "syndie_specialist-infiltrator"
			item_state = "syndie_specialist-infiltrator"

			setupProperties()
				..()
				setProperty("space_movespeed", -0.25)


		firebrand
			name = "specialist operative firesuit"
			icon_state = "syndie_specialist-firebrand"
			item_state = "syndie_specialist-firebrand"

			protective_temperature = 100000

			setupProperties()
				..()
				setProperty("heatprot", 100)

		engineer
			name = "specialist operative engineering uniform"
			icon_state = "syndie_specialist-engineer"
			item_state = "syndie_specialist-engineer"

		sniper
			name = "specialist operative marksman's suit"
			icon_state = "syndie_specialist-sniper"
			item_state = "syndie_specialist-sniper"

		grenadier
			name = "specialist operative bombsuit"

			setupProperties()
				..()
				setProperty("exploprot", 60)

		bard
			name = "road-worn stage uniform"
			icon_state = "syndie_specialist-bard"
			item_state = "syndie_specialist-bard"

		unremovable
			cant_self_remove = 1
			cant_other_remove = 1

/obj/item/clothing/suit/space/ntso
	name = "NT pressure suit"
	desc = "A specialised Nanotrasen space suit, with an integrated chest rig."
	icon_state = "ntso_specialist"
	item_state = "ntso_specialist"
	acid_survival_time = 6 MINUTES

	setupProperties()
		..()
		setProperty("space_movespeed", 0)  // ntso space suits don't suffer from slowdown

/obj/item/clothing/suit/space/engineer
	name = "engineering space suit"
	desc = "An overly bulky space suit designed mainly for maintenance and mining."
	icon_state = "espace"
	item_state = "es_suit"

	april_fools
		icon_state = "espace-alt"
		item_state = "es_suit"

/obj/item/clothing/suit/space/neon
	name = "neon space suit"
	desc = "It comes in fun colours, but is as bulky and slow to move in as any standard space suit..."
	icon_state = "space-neon"
	item_state = "space-neon"

/obj/item/clothing/suit/space/custom // Used for nanofabs
	icon_state = "spacemat"
	inhand_image_icon = "s_suit"
	item_state = "spacemat"
	name = "bespoke space suit"
	desc = "A custom built suit that protects your fragile body from hard vacuum."

	onMaterialChanged()
		. = ..()
		if (istype(src.material))
			var/prot = max(0, (5 - src.material.getProperty("thermal")) * 10)
			setProperty("coldprot", 10+prot)
			setProperty("heatprot", 2+round(prot/2))

			prot =  clamp(((src.material.getProperty("chemical") - 4) * 15), 0, 70) // 30 would be default for metal.
			setProperty("chemprot", prot)
		return


	proc/set_custom_mats(datum/material/fabrMat, datum/material/renfMat)
		src.setMaterial(fabrMat)
		name = "[renfMat]-reinforced [fabrMat] bespoke space suit"
		var/prot = max(0, renfMat.getProperty("density") - 3) / 2
		setProperty("meleeprot", 3 + prot)
		setProperty("rangedprot", 0.3 + prot / 5)
		setProperty("space_movespeed", 0.15 + prot / 5)

// Sealab suits

/obj/item/clothing/suit/space/diving
	name = "diving suit"
	desc = "A diving suit designed to withstand the pressure of working deep undersea."
	icon_state = "diving_suit"
	item_state = "diving_suit"
	acid_survival_time = 8 MINUTES

	setupProperties()
		..()
		setProperty("movespeed", 0.4)

	security
		name = "security diving suit"
		icon_state = "diving_suit-sec"
		item_state = "diving_suit-sec"

	civilian
		name = "civilian diving suit"
		icon_state = "diving_suit-civ"
		item_state = "diving_suit-civ"

	command
		name = "command diving suit"
		icon_state = "diving_suit-com"
		item_state = "diving_suit-com"

	engineering
		name = "engineering diving suit"
		icon_state = "diving_suit-eng"
		item_state = "diving_suit-eng"

/obj/item/clothing/suit/space/industrial
#ifdef MAP_OVERRIDE_NADIR
	desc = "Armored, immersion-tight suit. Protects from a wide gamut of environmental hazards, including radiation and explosions."
#else
	desc = "Very heavy armour for prolonged industrial activity. Protects from radiation and explosions."
#endif
	c_flags = SPACEWEAR
	body_parts_covered = TORSO|LEGS|ARMS
	acid_survival_time = 8 MINUTES

#ifdef UNDERWATER_MAP
	name = "industrial diving suit"
	icon_state = "diving_suit-industrial"
	item_state = "diving_suit-industrial"

#else
	name = "industrial space armor"
	icon_state = "indus"
	item_state = "indus"
#endif
	setupProperties()
		..()
		setProperty("radprot", 50)
		setProperty("coldprot", 75)
		setProperty("heatprot", 25)
		setProperty("exploprot", 30)
		setProperty("meleeprot", 2)
		setProperty("rangedprot", 0.5)
		setProperty("space_movespeed", 0)

	New()
		. = ..()
		START_TRACKING

	disposing()
		STOP_TRACKING
		. = ..()

	syndicate
		name = "\improper Syndicate command armor"
		desc = "An armored space suit, not for your average expendable chumps. No sir."
		is_syndicate = TRUE
		icon_state = "indusred"
		item_state = "indusred"
		mats = 45 //should not be cheap to make at mechanics, increased from 15.

		New()
			..()
			START_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)

		setupProperties()
			..()
			setProperty("meleeprot", 9)
			setProperty("rangedprot", 2)

		disposing()
			STOP_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
			..()

		specialist
			name = "specialist heavy operative combat armor"
			desc = "A syndicate issue heavy combat dress system, pressurized for space travel and reinforced for greater protection in firefights."
			icon_state = "syndie_specialist-heavy"
			item_state = "syndie_specialist-heavy"

	ntso

		name = "NT-SO heavy operative combat armor"
		desc = "A Nanotrasen special forces heavy combat dress system, pressurized for space travel and reinforced for greater protection in firefights."
		is_syndicate = FALSE
		icon_state = "ntso_specialist-heavy"
		item_state = "ntso_specialist-heavy"

		setupProperties()
			..()
			setProperty("meleeprot", 9)
			setProperty("rangedprot", 2)

//NT pod wars suits
/obj/item/clothing/suit/space/nanotrasen
	name = "Nanotrasen Heavy Armor"
	icon_state = "nanotrasen_pilot"
	item_state = "nanotrasen_pilot"
	desc = "Heavy armor used by certain Nanotrasen bodyguards."

	pilot
		name = "NT space suit"
		desc = "A suit that protects against low pressure environments. Issued to nanotrasen pilots."
		team_num = TEAM_NANOTRASEN
		#ifdef MAP_OVERRIDE_POD_WARS
		attack_hand(mob/user)
			if (get_pod_wars_team_num(user) == team_num)
				..()
			else
				boutput(user, "<span class='alert'>The space suit <b>explodes</b> as you reach out to grab it!</span>")
				make_fake_explosion(src)
				user.u_equip(src)
				src.dropped(user)
				qdel(src)
		#endif

		setupProperties()
			..()
			setProperty("chemprot",60)
			setProperty("space_movespeed", 0)  // syndicate space suits don't suffer from slowdown

		commander
			name = "commander's great coat"
			icon_state = "ntcommander_coat"
			item_state = "ntcommander_coat"
			desc = "A fear-inspiring, blue-ish-leather great coat, typically worn by a NanoTrasen Pod Commander. Why does it look like it's been dyed painted blue?"
			team_num = TEAM_NANOTRASEN
			#ifdef MAP_OVERRIDE_POD_WARS
			attack_hand(mob/user)
				if (get_pod_wars_team_num(user) == team_num)
					..()
				else
					boutput(user, "<span class='alert'>The coat <b>explodes</b> as you reach out to grab it!</span>")
					make_fake_explosion(src)
					user.u_equip(src)
					src.dropped(user)
					qdel(src)
			#endif

			setupProperties()
				..()
				setProperty("exploprot", 40)
				setProperty("meleeprot", 6)
				setProperty("rangedprot", 3)

/obj/item/clothing/suit/cultist
	name = "cultist robe"
	desc = "The unholy vestments of a cultist."
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_gimmick.dmi'
	inhand_image_icon = 'icons/mob/inhand/overcoat/hand_suit_gimmick.dmi'
	icon_state = "cultist"
	item_state = "cultist"
	see_face = 0
	magical = 1
	over_hair = TRUE
	c_flags = COVERSEYES | COVERSMOUTH
	body_parts_covered = TORSO|LEGS|ARMS
	hides_from_examine = C_UNIFORM

	setupProperties()
		..()
		setProperty("coldprot", 20)
		setProperty("heatprot", 20)
		setProperty("chemprot", 10)

	cursed
		cant_drop = TRUE
		cant_other_remove = TRUE
		cant_self_remove = TRUE

	hastur
		name = "yellow sign cultist robe"
		desc = "For those who have seen the yellow sign and answered its call.."
		icon_state = "hasturcultist"
		item_state = "hasturcultist"
		wear_layer = MOB_OVERLAY_BASE

	nerd
		name = "robes of dungeon mastery"
		desc = "Neeeeerds."

		New()
			. = ..()
			src.enchant(min(rand(1, 5), rand(1, 5)))

/obj/item/clothing/suit/flockcultist
	name = "weird cultist robe"
	desc = "Only unpopular nerds would ever wear this."
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_gimmick.dmi'
	inhand_image_icon = 'icons/mob/inhand/overcoat/hand_suit_gimmick.dmi'
	icon_state = "flockcultist"
	item_state = "flockcultistt"
	see_face = 0
	wear_layer = MOB_OVERLAY_BASE
	c_flags = COVERSEYES | COVERSMOUTH
	body_parts_covered = TORSO|LEGS|ARMS
	hides_from_examine = C_UNIFORM
	over_hair = TRUE

	setupProperties()
		..()
		setProperty("chemprot", 10)

/obj/item/clothing/suit/wizrobe
	name = "blue wizard robe"
	desc = "A traditional blue wizard's robe. It lacks all the stars and moons and stuff on it though."
	icon_state = "wizard"
	item_state = "wizard"
	magical = TRUE
	body_parts_covered = TORSO|LEGS|ARMS
	hides_from_examine = C_UNIFORM
	contraband = 4
	duration_remove = 10 SECONDS

	setupProperties()
		..()
		setProperty("coldprot", 90)
		setProperty("heatprot", 30)
		setProperty("chemprot", 40)

/obj/item/clothing/suit/wizrobe/red
	name = "red wizard robe"
	desc = "A very fancy and elegant red robe with gold trim."
	icon_state = "wizardred"
	item_state = "wizardred"

/obj/item/clothing/suit/wizrobe/purple
	name = "purple wizard robe"
	desc = "A real nice robe and cape, in purple, with blue and yellow accents."
	icon_state = "wizardpurple"
	item_state = "wizardpurple"

/obj/item/clothing/suit/wizrobe/green
	name = "green wizard robe"
	desc = "A neat green robe with gold trim."
	icon_state = "wizardgreen"
	item_state = "wizardgreen"

/obj/item/clothing/suit/wizrobe/necro
	name = "necromancer robe"
	desc = "A ratty stinky black robe for wizards who are trying way too hard to be menacing."
	icon_state = "wizardnec"
	item_state = "wizardnec"

/obj/item/clothing/suit/bathrobe
	name = "bathrobe"
	desc = "A snazzy bathrobe for after you get out of the shower."
	icon_state = "bathrobe"
	item_state = "bathrobe"
	body_parts_covered = TORSO|ARMS
	burn_possible = TRUE
	burn_point = 450
	burn_output = 800

	setupProperties()
		..()
		setProperty("coldprot", 25)
		setProperty("heatprot", 0)

//~-------------------- Winter Coats -------------------~// both code and sprites by Gannets, ty Gannets

/obj/item/clothing/suit/wintercoat
	name = "winter coat"
	desc = "A padded coat to protect against the cold."
	icon_state = "wintercoat"
	item_state = "wintercoat"
	body_parts_covered = TORSO|LEGS|ARMS

	setupProperties()
		..()
		setProperty("coldprot", 35)

/obj/item/clothing/suit/wintercoat/medical
	name = "medical winter coat"
	icon_state = "wintercoat-medical"
	item_state = "wintercoat-medical"

/obj/item/clothing/suit/wintercoat/genetics
	name = "genetics winter coat"
	icon_state = "wintercoat-genetics"
	item_state = "wintercoat-genetics"

/obj/item/clothing/suit/wintercoat/research
	name = "research winter coat"
	icon_state = "wintercoat-research"
	item_state = "wintercoat-research"

/obj/item/clothing/suit/wintercoat/engineering
	name = "engineering winter coat"
	icon_state = "wintercoat-engineering"
	item_state = "wintercoat-engineering"

/obj/item/clothing/suit/wintercoat/security
	name = "security winter coat"
	icon_state = "wintercoat-security"
	item_state = "wintercoat-security"

/obj/item/clothing/suit/wintercoat/command
	name = "command winter coat"
	icon_state = "wintercoat-command"
	item_state = "wintercoat-command"

/obj/item/clothing/suit/wintercoat/detective
	name = "detective's winter coat"
	desc = "A comfy coat to protect against the cold. Popular with private investigators."
	icon_state = "wintercoat-detective"
	item_state = "wintercoat-detective"

/obj/item/clothing/suit/hi_vis
	name = "hi-vis vest"
	desc = "For when you just have to be seen!"
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_gimmick.dmi'
	inhand_image_icon = 'icons/mob/inhand/overcoat/hand_suit_gimmick.dmi'
	icon_state = "hi-vis"
	item_state = "hi-vis"
	body_parts_covered = TORSO

	setupProperties()
		..()
		setProperty("coldprot", 5)

/obj/item/clothing/suit/labcoat/hitman
    name = "black jacket"
    desc = "A stylish black suitjacket."
    icon_state = "hitmanc"
    item_state = "hitmanc"
    coat_style = "hitmanc"

/obj/item/clothing/suit/labcoat/hitman/satansuit
	icon = 'icons/obj/clothing/overcoats/item_suit.dmi'
	icon_state = "inspectorc"

/obj/item/clothing/suit/witchfinder
	name = "witchfinder general's coat"
	desc = "Who's coming to get you, I'm coming to take you away."
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_gimmick.dmi'
	inhand_image_icon = 'icons/mob/inhand/overcoat/hand_suit_gimmick.dmi'
	icon_state = "witchfinder"
	item_state = "witchfinder"
	body_parts_covered = TORSO|LEGS|ARMS
	hides_from_examine = C_UNIFORM

	setupProperties()
		..()
		setProperty("coldprot", 5)
		setProperty("heatprot", 5)
		setProperty("meleeprot", 2)

/obj/item/clothing/suit/nursedress
	name = "nurse dress"
	desc = "A traditional dress worn by a nurse."
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_gimmick.dmi'
	inhand_image_icon = 'icons/mob/inhand/overcoat/hand_suit_gimmick.dmi'
	icon_state = "nursedress"
	item_state = "nursedress"
	body_parts_covered = TORSO|LEGS|ARMS
	hides_from_examine = C_UNIFORM

/obj/item/clothing/suit/chemsuit
	name = "chemical protection suit"
	desc = "A bulky suit made from thick rubber. This should protect against most harmful chemicals."
	icon = 'icons/obj/clothing/overcoats/item_suit_hazard.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_hazard.dmi'
	inhand_image_icon = 'icons/mob/inhand/overcoat/hand_suit_hazard.dmi'
	icon_state = "chem_suit"
	item_state = "chem_suit"
	body_parts_covered = TORSO|LEGS|ARMS
	hides_from_examine = C_UNIFORM|C_GLOVES|C_SHOES

	setupProperties()
		..()
		setProperty("chemprot", 70)

/obj/item/clothing/suit/security_badge
	name = "Security Badge"
	desc = "An official badge for a Nanotrasen Security Worker."
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	w_class = W_CLASS_TINY
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_gimmick.dmi'
	inhand_image_icon = 'icons/mob/inhand/overcoat/hand_suit_gimmick.dmi'
	icon_state = "security_badge"
	item_state = "security_badge"
	var/badge_owner_name = null
	var/badge_owner_job = null

	setupProperties()
		..()
		setProperty("meleeprot", 0)
		setProperty("heatprot", 0)
		setProperty("coldprot", 0)

	get_desc()
		. += "This one belongs to [badge_owner_name], the [badge_owner_job]."

	attack_self(mob/user as mob)
		user.visible_message("[user] flashes the badge: <br><span class='bold'>[bicon(src)] Nanotrasen's Finest [badge_owner_job]: [badge_owner_name].</span>", "You show off the badge: <br><span class='bold'>[bicon(src)] Nanotrasen's Finest [badge_owner_job] [badge_owner_name].</span>")

	attack(mob/target, mob/user)
		user.visible_message("[user] flashes the badge at [target.name]: <br><span class='bold'>[bicon(src)] Nanotrasen's Finest [badge_owner_job]: [badge_owner_name].</span>", "You show off the badge to [target.name]: <br><span class='bold'>[bicon(src)] Nanotrasen's Finest [badge_owner_job] [badge_owner_name].</span>")

/obj/item/clothing/suit/hosmedal
	name = "war medal"
	desc = ""
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	w_class = W_CLASS_TINY
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_gimmick.dmi'
	icon_state = "hosmedal"
	icon_state = "hosmedal"

	get_desc(var/dist, var/mob/user)
		if (user.mind?.assigned_role == "Head of Security")
			. = "It's your war medal, you remember when you got this for saving a man's life during the war."
		else
			. = "It's the HoS's old war medal, you heard they got it for their acts of heroism in the war."

/obj/item/clothing/suit/snow
	name = "snow suit"
	desc = "A thick padded suit that protects against extreme cold temperatures."
	icon = 'icons/obj/clothing/overcoats/item_suit_hazard.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_hazard.dmi'
	inhand_image_icon = 'icons/mob/inhand/overcoat/hand_suit_hazard.dmi'
	icon_state = "snowcoat"
	item_state = "snowcoat"
	body_parts_covered = TORSO|LEGS|ARMS
	hides_from_examine = C_UNIFORM|C_SHOES

	setupProperties()
		..()
		setProperty("coldprot", 50)
		setProperty("heatprot", 10)
		setProperty("meleeprot", 3)
		setProperty("rangedprot", 0.5)
		setProperty("movespeed", 0.5)
		setProperty("disorient_resist", 15)

/obj/item/clothing/suit/jean_jacket
	name = "jean jacket"
	desc = "Pants for your jealous arms."
	icon = 'icons/obj/clothing/overcoats/item_suit.dmi'
	icon_state = "jean_jacket"
	item_state = "jean_jacket"
	body_parts_covered = TORSO|ARMS

//crate loot

/obj/item/clothing/suit/lined_jacket
	name = "lined jacket"
	desc = "A faux-leather jacket with cozy lining."
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_gimmick.dmi'
	icon_state = "lined_jacket"
	item_state = "lined_jacket"
	body_parts_covered = TORSO|ARMS

/obj/item/clothing/suit/rugged_jacket
	name = "rugged jacket"
	desc = "A pre-torn jacket for that 'mildly cool' sort of look."
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_gimmick.dmi'
	icon_state = "rugged_jacket"
	item_state = "rugged_jacket"
	body_parts_covered = TORSO|ARMS

/obj/item/clothing/suit/star_cloak
	name = "starry cloak"
	desc = "A cloak with an intricate and detailed view of the night sky viewed from space woven into it."
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_gimmick.dmi'
	icon_state = "star_cloak"
	item_state = "star_cloak"
	body_parts_covered = TORSO|ARMS

/obj/item/clothing/suit/cow_jacket
	name = "cow jacket"
	desc = "Made of faux-cow."
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_gimmick.dmi'
	icon_state = "cow"
	item_state = "cow"
	body_parts_covered = TORSO|ARMS

/obj/item/clothing/suit/warm_jacket
	name = "warm jacket"
	desc = "Warm as in its coloration. It's not actually all that insulative."
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_gimmick.dmi'
	icon_state = "gradient_warm"
	item_state = "gradient_warm"
	body_parts_covered = TORSO|ARMS

/obj/item/clothing/suit/cool_jacket
	name = "cool jacket"
	desc = "Cool as in its coloration. It's not actually all that radical."
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_gimmick.dmi'
	icon_state = "gradient_cool"
	item_state = "gradient_cool"
	body_parts_covered = TORSO|ARMS

/obj/item/clothing/suit/billow_cape
	name = "cape of flowing"
	desc = "A cape that flutters when worn, even if it's not worn in space-windy conditions."
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_gimmick.dmi'
	icon_state = "billow_cape"
	item_state = "billow_cape"
	body_parts_covered = TORSO|ARMS

/obj/item/clothing/suit/space/replica
	name = "replica space suit"
	desc = "A replica of an old space suit. Seems to still work, though."
	icon_state = "space_replica"
	item_state = "space_replica"
