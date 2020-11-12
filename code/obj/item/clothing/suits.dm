// SUITS
//setup.dm
//#define SUITBLOOD_ARMOR 1
//#define SUITBLOOD_COAT 2

/obj/item/clothing/suit
	name = "leather jacket"
	desc = "Made from real Space Bovine, but don't call it cowhide under penalty of Article 5.P3RG."
	icon = 'icons/obj/clothing/overcoats/item_suit.dmi'
	inhand_image_icon = 'icons/mob/inhand/overcoat/hand_suit.dmi'
	wear_image_icon = 'icons/mob/overcoats/worn_suit.dmi'
	icon_state = "ljacket"
	item_state = "ljacket"
	var/fire_resist = T0C+100
	var/over_hair = 0
	var/over_all = 0 // shows up over all other clothes/hair/etc on people
	var/over_back = 0
	flags = FPRINT | TABLEPASS
	w_class = 3.0
	var/restrain_wearer = 0
	var/bloodoverlayimage = 0


	setupProperties()
		..()
		setProperty("coldprot", 5)
		setProperty("heatprot", 5)
		setProperty("meleeprot", 2)

/obj/item/clothing/suit/hoodie
	name = "hoodie"
	desc = "Nice and comfy on those cold space evenings."
	icon_state = "hoodie"
	uses_multiple_icon_states = 1
	item_state = "hoodie"
	body_parts_covered = HEAD|TORSO|ARMS
	var/hood = 0
	var/hcolor = null

	New()
		..()
		src.icon_state = "hoodie[src.hcolor ? "-[hcolor]" : null]"
		src.item_state = "hoodie[src.hcolor ? "-[hcolor]" : null]"

	setupProperties()
		..()
		setProperty("coldprot", 25)

	attack_self(mob/user as mob)
		src.hood = !(src.hood)
		user.show_text("You flip [src]'s hood [src.hood ? "up" : "down"].")
		if (src.hood)
			src.over_hair = 1
			src.icon_state = "hoodie[src.hcolor ? "-[hcolor]" : null]-up"
			src.item_state = "hoodie[src.hcolor ? "-[hcolor]" : null]-up"
		else
			src.over_hair = 0
			src.icon_state = "hoodie[src.hcolor ? "-[hcolor]" : null]"
			src.item_state = "hoodie[src.hcolor ? "-[hcolor]" : null]"

/obj/item/clothing/suit/hoodie/blue
	desc = "Would fit well on a skeleton."
	icon_state = "hoodie-blue"
	item_state = "hoodie-blue"
	hcolor = "blue"

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
	wear_image_icon = 'icons/mob/overcoats/worn_suit_gimmick.dmi'
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
		desc = "A translucent plastic jacket. It looks flimsy and incredibly tacky."
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

		New()
			..()
			var/random_design = rand(1,10)
			src.wear_image.overlays += image(src.wear_image_icon,"design_[random_design]")

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
	wear_image_icon = 'icons/mob/overcoats/worn_suit_hazard.dmi'
	inhand_image_icon = 'icons/mob/inhand/overcoat/hand_suit_hazard.dmi'
	var/armored = 0
	body_parts_covered = TORSO|LEGS|ARMS
	permeability_coefficient = 0.01
	over_hair = 1

	setupProperties()
		..()
		setProperty("coldprot", 15)
		setProperty("heatprot", 15)
		setProperty("viralprot", 50)
		setProperty("meleeprot", 2)
		setProperty("rangedprot", 0.5)

/obj/item/clothing/suit/bio_suit/attackby(obj/item/W, mob/user)
	var/turf/T = usr.loc
	if(istype(W, /obj/item/clothing/suit/armor/vest))
		boutput(usr, "<span class='notice'>You attach [W] to [src].</span>")
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
	icon = 'icons/obj/clothing/overcoats/item_suit_hazard.dmi'
	wear_image_icon = 'icons/mob/overcoats/worn_suit_hazard.dmi'
	inhand_image_icon = 'icons/mob/inhand/overcoat/hand_suit_hazard.dmi'


/obj/item/clothing/suit/bio_suit/paramedic
	name = "paramedic suit"
	desc = "A protective padded suit for emergency response personnel. Offers limited thermal and biological protection."
	icon_state = "paramedic"
	item_state = "paramedic"

	permeability_coefficient = 0.1
	body_parts_covered = TORSO|LEGS|ARMS

	protective_temperature = 3000
	over_hair = 0

	setupProperties()
		..()
		setProperty("coldprot", 25)
		setProperty("heatprot", 25)
		setProperty("meleeprot", 3)
		setProperty("rangedprot", 0.9)

/obj/item/clothing/suit/bio_suit/armored
	name = "armored bio suit"
	desc = "A suit that protects against biological contamination. Somebody slapped some armor onto the chest."
	icon_state = "armorbio"
	item_state = "armorbio"
	c_flags = ONESIZEFITSALL
	setupProperties()
		..()
		setProperty("meleeprot", 5)
		setProperty("rangedprot", 1.5)

/obj/item/clothing/suit/bio_suit/armored/nt
	name = "\improper NT bio suit"
	desc = "An armored biosuit that protects against biological contamination and toolboxes."
	icon_state = "ntbio"
	item_state = "ntbio"
	c_flags = ONESIZEFITSALL
	setupProperties()
		..()
		setProperty("meleeprot", 5)
		setProperty("rangedprot", 1.5)

/obj/item/clothing/suit/bio_suit/paramedic/armored
	name = "armored paramedic suit"
	desc = "A protective padded suit for emergency response personnel. Offers limited thermal and biological protection. Somebody slapped some armor onto the chest."
	icon_state = "para_armor"
	item_state = "paramedic"
	c_flags = ONESIZEFITSALL
	setupProperties()
		..()
		setProperty("meleeprot", 5)
		setProperty("rangedprot", 1.9)


	para_troop
		icon_state = "para_sec"
		item_state = "para_sec"
		name = "rapid response armor"
		desc = "A protective padded suit for emergency reponse personnel. Tailored for ground operations, not vaccuum rated. This one bears security insignia."
		mats = 50

	para_eng
		name = "rapid response armor"
		desc = "A protective padded suit for emergency response personnel. Tailored for ground operations, not vaccuum rated. This one bears engineering insignia."
		icon_state = "para_eng"
		item_state = "para_eng"

/obj/item/clothing/suit/space/suv
	name = "\improper SUV suit"
	desc = "Engineered to do some doohickey with radiation or something. Man this thing is cool."
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	wear_image_icon = 'icons/mob/overcoats/worn_suit_gimmick.dmi'
	inhand_image_icon = 'icons/mob/inhand/overcoat/hand_suit_gimmick.dmi'
	icon_state = "hev"
	item_state = "hev"
	c_flags = ONESIZEFITSALL | SPACEWEAR
	body_parts_covered = TORSO|LEGS|ARMS

	setupProperties()
		..()
		setProperty("radprot", 50)
		setProperty("meleeprot", 4)
		setProperty("rangedprot", 2)
		setProperty("movespeed", 1)

/obj/item/clothing/suit/rad // re-added for Russian Station as there is a permarads area there!
	name = "\improper Class II radiation suit"
	desc = "An old Soviet radiation suit made of 100% space asbestos. It's good for you!"
	icon_state = "rad"
	item_state = "rad"
	icon = 'icons/obj/clothing/overcoats/item_suit_hazard.dmi'
	wear_image_icon = 'icons/mob/overcoats/worn_suit_hazard.dmi'
	inhand_image_icon = 'icons/mob/inhand/overcoat/hand_suit_hazard.dmi'
	c_flags = ONESIZEFITSALL
	body_parts_covered = TORSO|LEGS|ARMS
	permeability_coefficient = 0.005
	over_hair = 1

	New()
		. = ..()
		AddComponent(/datum/component/wearertargeting/geiger, list(SLOT_WEAR_SUIT))

	setupProperties()
		..()
		setProperty("movespeed", 0.6)
		setProperty("radprot", 50)
		setProperty("coldprot", 15)
		setProperty("heatprot", 15)
		setProperty("meleeprot", 3)
		setProperty("rangedprot", 0.5)

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
	wear_image_icon = 'icons/mob/overcoats/worn_suit_armor.dmi'
	icon_state = "ntarmor"
	setupProperties()
		..()
		setProperty("meleeprot", 2)
		setProperty("rangedprot", 0.5)

/obj/item/clothing/suit/det_suit/hos
	name = "Head of Security's jacket"
	desc = "A slightly armored jacket favored by security personnel. It looks cozy and warm; you could probably sleep in this if you wanted to!"
	icon = 'icons/obj/clothing/overcoats/item_suit_armor.dmi'
	wear_image_icon = 'icons/mob/overcoats/worn_suit_armor.dmi'
	icon_state = "hoscoat"
	setupProperties()
		..()
		setProperty("meleeprot", 3)
		setProperty("rangedprot", 0.7)
		setProperty("coldprot", 35)

/obj/item/clothing/suit/judgerobe
	name = "judge's robe"
	desc = "This robe commands authority."
	icon_state = "judge"
	item_state = "judge"
	body_parts_covered = TORSO|LEGS|ARMS

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
	permeability_coefficient = 0.70

/obj/item/clothing/suit/apron/botanist
	name = "blue apron"
	desc = "This will keep you safe from tomato stains. Unless they're the exploding ones"
	icon_state = "apron-botany"
	item_state = "apron-botany"

/obj/item/clothing/suit/labcoat
	name = "labcoat"
	desc = "A suit that protects against minor chemical spills and biohazards."
	icon_state = "labcoat"
	uses_multiple_icon_states = 1
	item_state = "labcoat"
	var/coat_style = "labcoat"
	body_parts_covered = TORSO|ARMS
	permeability_coefficient = 0.25
	var/buttoned = TRUE
	bloodoverlayimage = SUITBLOOD_COAT

	abilities = list(/obj/ability_button/labcoat_toggle)

	setupProperties()
		..()
		setProperty("coldprot", 15)
		setProperty("heatprot", 15)

	New()
		..()

	attack_self()
		..()
		if (src.coat_style)
			usr.set_clothing_icon_dirty()
			if (buttoned)
				src.icon_state = "[src.coat_style]_o"
				usr.visible_message("[usr] unbuttons [his_or_her(usr)] [src.name].",\
				"You unbutton your [src.name].")
			else
				src.icon_state = src.coat_style
				usr.visible_message("[usr] buttons [his_or_her(usr)] [src.name].",\
				"You button your [src.name].")

		buttoned = !buttoned

	proc/button()
		if (src.coat_style)
			src.icon_state = src.coat_style
			usr.set_clothing_icon_dirty()
		usr.visible_message("[usr] buttons [his_or_her(usr)] [src.name].",\
		"You button your [src.name].")

	proc/unbutton()
		if (src.coat_style)
			src.icon_state = "[src.coat_style]_o"
			usr.set_clothing_icon_dirty()
		usr.visible_message("[usr] unbuttons [his_or_her(usr)] [src.name].",\
		"You unbutton your [src.name].")


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
		icon_state = "MDlabcoat-alt"
		item_state = "MDlabcoat-alt"
		coat_style = "MDlabcoat-alt"

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
	restrain_wearer = 1

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
	magical = 1
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
	w_class = 1
	throw_speed = 2
	throw_range = 10
	c_flags = COVERSEYES | COVERSMOUTH
	body_parts_covered = TORSO|ARMS
	see_face = 0
	over_hair = 1
	over_all = 1
	var/eyeholes = 0 //Did we remember to cut eyes in the thing?
	var/cape = 0
	var/obj/stool/bed/Bed = null
	var/bcolor = null
	//cogwerks - burn vars
	burn_point = 450
	burn_output = 800
	burn_possible = 1
	health = 20
	rand_pos = 0
	block_vision = 1

	setupProperties()
		..()
		setProperty("coldprot", 10)

	New()
		..()
		src.update_icon()
		src.setMaterial(getMaterial("cotton"), appearance = 0, setname = 0)

	attack_hand(mob/user as mob)
		if (src.Bed)
			src.Bed.untuck_sheet(user)
		src.Bed = null
		return ..()

	ex_act(severity)
		if (severity <= 2)
			if (src.Bed && src.Bed.Sheet == src)
				src.Bed.Sheet = null
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
				boutput(user, "You begin ripping up [src].")
				if (!do_after(user, 30))
					boutput(user, "<span class='alert'>You were interrupted!</span>")
					return
				else
					for (var/i=3, i>0, i--)
						var/obj/item/material_piece/cloth/cottonfabric/CF = unpool(/obj/item/material_piece/cloth/cottonfabric)
						CF.set_loc(get_turf(src))
					boutput(user, "You rip up [src].")
					user.u_equip(src)
					qdel(src)
					return

	attackby(obj/item/W as obj, mob/user as mob)
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
					if (!do_after(user, 30))
						boutput(user, "<span class='alert'>You were interrupted!</span>")
						return
					else
						for (var/i=3, i>0, i--)
							new /obj/item/bandage(get_turf(src))
						playsound(src.loc, "sound/items/Scissor.ogg", 100, 1)
						boutput(user, "You cut [src] into bandages.")
						user.u_equip(src)
						qdel(src)
						return
				if ("Cut cable")
					src.cut_cape()
					playsound(src.loc, "sound/items/Scissor.ogg", 100, 1)
					boutput(user, "You cut the cable that's tying the bedsheet into a cape.")
					return
				if ("Cut eyeholes")
					src.cut_eyeholes()
					playsound(src.loc, "sound/items/Scissor.ogg", 100, 1)
					boutput(user, "You cut eyeholes in the bedsheet.")
					return
		else
			return ..()

	proc/update_icon()
		if (src.cape)
			src.icon_state = "bedcape[src.bcolor ? "-[bcolor]" : null]"
			src.item_state = src.icon_state
			see_face = 1
			over_hair = 0
			over_all = 0
			over_back = 1
		else
			src.icon_state = "bedsheet[src.bcolor ? "-[bcolor]" : null][src.eyeholes ? "1" : null]"
			src.item_state = src.icon_state
			see_face = 0
			over_hair = 1
			over_all = 1
			over_back = 0

	proc/cut_eyeholes()
		if (src.cape || src.eyeholes)
			return
		if (src.Bed && src.Bed.loc == src.loc)
			src.Bed.untuck_sheet()
		src.Bed = null
		src.eyeholes = 1
		block_vision = 0
		src.update_icon()
		desc = "It's a bedsheet with eye holes cut in it."

	proc/make_cape()
		if (src.cape)
			return
		if (src.Bed && src.Bed.loc == src.loc)
			src.Bed.untuck_sheet()
		src.Bed = null
		src.cape = 1
		block_vision = 0
		src.update_icon()
		desc = "It's a bedsheet that's been tied into a cape."

	proc/cut_cape()
		if (!src.cape)
			return
		if (src.Bed && src.Bed.loc == src.loc)
			src.Bed.untuck_sheet()
		src.Bed = null
		src.cape = 0
		block_vision = !src.eyeholes
		src.update_icon()
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
		src.update_icon()

/obj/item/clothing/suit/bedsheet/cape
	icon_state = "bedcape"
	item_state = "bedcape"
	cape = 1
	over_back = 1
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
	wear_image_icon = 'icons/mob/overcoats/worn_suit_hazard.dmi'
	icon_state = "fire"
	item_state = "fire_suit"
	permeability_coefficient = 0.50
	body_parts_covered = TORSO|LEGS|ARMS
	protective_temperature = 4500

	setupProperties()
		..()
		setProperty("coldprot", 20)
		setProperty("heatprot", 50)
		setProperty("meleeprot", 3)
		setProperty("rangedprot", 0.5)
		setProperty("movespeed", 1)

/obj/item/clothing/suit/fire/armored
	name = "armored firesuit"
	desc = "A suit that protects against fire and heat. Somebody slapped some armor onto the chest."
	icon_state = "fire_armor"
	item_state = "fire_suit"
	setupProperties()
		..()
		setProperty("meleeprot", 6)
		setProperty("rangedprot", 1.5)

/obj/item/clothing/suit/fire/attackby(obj/item/W, mob/user)
	var/turf/T = user.loc
	if (istype(W, /obj/item/clothing/suit/armor/vest))
		if (istype(src, /obj/item/clothing/suit/fire/heavy) || istype(src, /obj/item/clothing/suit/fire/old))
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

	protective_temperature = 100000

	setupProperties()
		..()
		setProperty("coldprot", 5)
		setProperty("heatprot", 65)
		setProperty("meleeprot", 4)
		setProperty("rangedprot", 0.8)
		setProperty("movespeed", 2)

/obj/item/clothing/suit/fire/old
	name = "old firesuit"
	desc = "Just looking at this thing makes your eyes take burn damage."
	icon_state = "fire_old"
	item_state = "fire_old"

// SWEATERS

/obj/item/clothing/suit/sweater
	name = "diamond sweater"
	desc = "A pretty warm-looking knit sweater. This is one of those I.N. designer sweaters."
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	wear_image_icon = 'icons/mob/overcoats/worn_suit_gimmick.dmi'
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
			SPAWN_DBG(2 SECONDS)
				src.name = initial(src.name)
				src.setMaterial(getMaterial("cotton"), appearance = 0, setname = 0)

// LONG SHIRTS
// No they're not sweaters

/obj/item/clothing/suit/lshirt
	name = "long sleeved shirt"
	desc = "A long sleeved shirt. It has a sinister looking cyborg head printed on the front."
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	wear_image_icon = 'icons/mob/overcoats/worn_suit_gimmick.dmi'
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
	wear_image_icon = 'icons/mob/overcoats/worn_suit_hazard.dmi'
	icon_state = "space"
	item_state = "s_suit"
	c_flags = SPACEWEAR
	body_parts_covered = TORSO|LEGS|ARMS
	permeability_coefficient = 0.02
	protective_temperature = 1000
	over_hair = 1

	onMaterialChanged()
		if(src.material)
			if(material.hasProperty("thermal"))
				var/prot = 100 - material.getProperty("thermal")
				setProperty("coldprot", prot)
				setProperty("heatprot", round(prot/2))
			else
				setProperty("coldprot", 30)
				setProperty("heatprot", 15)

			if(material.hasProperty("permeable"))
				var/prot = 100 - material.getProperty("permeable")
				setProperty("viralprot", prot)
			else
				setProperty("viralprot", 40)

			if(material.hasProperty("density"))
				var/prot = round(material.getProperty("density") / 17)
				setProperty("meleeprot", prot)
				setProperty("rangedprot", (0.1 + round(prot/10)))
			else
				setProperty("meleeprot", 2)
				setProperty("rangedprot", 0.4)

	setupProperties()
		..()
		setProperty("coldprot", 50)
		setProperty("heatprot", 20)
		setProperty("viralprot", 50)
		setProperty("meleeprot", 3)
		setProperty("rangedprot", 0.5)

		setProperty("space_movespeed", 0.8)

/obj/item/clothing/suit/space/emerg
	name = "emergency suit"
	desc = "A suit that protects against low pressure environments for a short time."
	icon_state = "emerg"
	item_state = "emerg"
	c_flags = SPACEWEAR
	body_parts_covered = TORSO|LEGS|ARMS
	var/rip = 0

	setupProperties()
		..()
		setProperty("space_movespeed", 2)

	snow // bleh whatever!!!
		name = "snow suit"
		desc = "A thick padded suit that protects against extreme cold temperatures."
		icon_state = "snowcoat"
		item_state = "snowcoat"
		rip = -1

/obj/item/clothing/suit/space/emerg/proc/ripcheck(var/mob/user)
	if(rip >= 36 && rip != -1 && prob(10))  //upped from rip >= 14 by Buttes
		boutput(user, "<span class='alert'>The emergency suit tears off!</span>")
		var/turf/T = src.loc
		if (ismob(T))
			T = T.loc
		src.set_loc(T)
		user.u_equip(src)
		SPAWN_DBG(0.5 SECONDS)
			qdel(src)

/obj/item/clothing/suit/space/captain
	name = "captain's space suit"
	desc = "A suit that protects against low pressure environments and is green."
	icon_state = "spacecap"
	item_state = "spacecap"

	setupProperties()
		..()
		setProperty("space_movespeed", 0.4)

	blue
		icon_state = "spacecap-blue"
		item_state = "spacecap-blue"

	red
		icon_state = "spacecap-red"
		item_state = "spacecap-red"

/obj/item/clothing/suit/space/syndicate
	name = "red space suit"
	icon_state = "syndicate"
	item_state = "space_suit_syndicate"
	desc = "A suit that protects against low pressure environments. Issued to syndicate operatives."
	contraband = 3

	setupProperties()
		..()
		setProperty("space_movespeed", 0)  // syndicate space suits don't suffer from slowdown

	commissar_greatcoat
		name = "commander's great coat"
		icon_state = "commissar_greatcoat"
		desc = "A fear-inspiring, black-leather great coat, typically worn by a Syndicate Nuclear Operative Commander. So scary even the vacuum of space doesn't dare claim the wearer."

		setupProperties()
			..()
			setProperty("exploprot", 40)
			setProperty("meleeprot", 6)
			setProperty("rangedprot", 3)

	heavy // nukie melee class armor
		name = "citadel heavy combat armor"
		desc = "A syndicate issue heavy combat dress system, pressurized for space travel and reinforced for greater protection in firefights."
		icon_state = "syndie_specialist-heavy"
		item_state = "syndie_specialist-heavy"

		setupProperties()
			..()
			setProperty("meleeprot", 8)
			setProperty("rangedprot", 2)
			setProperty("movespeed", 0.5)

	specialist
		name = "specialist operative combat dress"
		desc = "A syndicate issue combat dress system, pressurized for space travel."
		icon_state = "syndie_specialist"
		item_state = "syndie_specialist"

		setupProperties()
			..()
			setProperty("exploprot", 20)
			setProperty("meleeprot", 4)
			setProperty("rangedprot", 1.5)

		medic
			name = "specialist operative medic uniform"
			desc = "A syndicate issue combat dress system, pressurized for space travel."
			icon_state = "syndie_specialist-medic"
			item_state = "syndie_specialist-medic"

		infiltrator
			name = "specialist operative espionage suit"
			desc = "A syndicate issue combat dress system, pressurized for space travel."
			icon_state = "syndie_specialist-infiltrator"
			item_state = "syndie_specialist-infiltrator"

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

		unremovable
			cant_self_remove = 1
			cant_other_remove = 1

/obj/item/clothing/suit/space/ntso
	name = "NT-SO combat dress"
	desc = "A Nanotrasen special forces combat dress system, pressurized for space travel."
	icon_state = "ntso_specialist"
	item_state = "ntso_specialist"

	setupProperties()
		..()
		setProperty("space_movespeed", 0)  // ntso space suits don't suffer from slowdown

	unremovable
		cant_self_remove = 1
		cant_other_remove = 1


	scout
		name = "NT-SO forward reconnaissance suit"
		desc = "A Nanotrasen special forces combat dress system, pressurized for space travel."
		icon_state = "ntso_specialist-scout"
		item_state = "ntso_specialist-scout"

/obj/item/clothing/suit/space/engineer
	name = "engineering space suit"
	desc = "An overly bulky space suit designed mainly for maintenance and mining."
	icon_state = "espace"
	item_state = "es_suit"

	april_fools
		icon_state = "espace-alt"
		item_state = "es_suit"

// Sealab suits

/obj/item/clothing/suit/space/diving
	name = "diving suit"
	desc = "A diving suit designed to withstand the pressure of working deep undersea."
	icon_state = "diving_suit"
	item_state = "diving_suit"

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
	desc = "Very heavy armour for prolonged industrial activity. Protects from radiation and explosions."
	c_flags = SPACEWEAR
	body_parts_covered = TORSO|LEGS|ARMS
	mats = 45 //should not be cheap to make at mechanics, increased from 15.


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

	syndicate
		name = "\improper Syndicate command armor"
		desc = "An armored space suit, not for your average expendable chumps. No sir."
		icon_state = "indusred"
		item_state = "indusred"
		setupProperties()
			..()
			setProperty("meleeprot", 9)
			setProperty("rangedprot", 2)

		specialist
			name = "specialist heavy operative combat armor"
			desc = "A syndicate issue heavy combat dress system, pressurized for space travel and reinforced for greater protection in firefights."
			icon_state = "syndie_specialist-heavy"
			item_state = "syndie_specialist-heavy"

/obj/item/clothing/suit/space/industrial/syndicate/ntso

	name = "NT-SO heavy operative combat armor"
	desc = "A Nanotrasen special forces heavy combat dress system, pressurized for space travel and reinforced for greater protection in firefights."
	icon_state = "ntso_specialist-heavy"
	item_state = "ntso_specialist-heavy"
	cant_self_remove = 1
	cant_other_remove = 1

/obj/item/clothing/suit/space/mining_combat // for fighting z5 critters.
	name = "mining combat armor"
	desc = "Heavy armor designed to withstand the rigours of space combat. Less resistant against the elements than industrial armor."
	icon_state = "mining_combat"
	item_state = "mining_combat"
	c_flags = SPACEWEAR
	body_parts_covered = TORSO|LEGS|ARMS
	mats = 60 //should be the most expensive armor.

	setupProperties()
		..()
		setProperty("radprot", 25)
		setProperty("coldprot", 50)
		setProperty("heatprot", 15)
		setProperty("exploprot", 20)
		setProperty("meleeprot", 5)
		setProperty("rangedprot", 2)

/obj/item/clothing/suit/space/nanotrasen
	name = "Nanotrasen Heavy Armor"
	icon_state = "ntarmor2"
	item_state = "ntarmor2"
	desc = "Heavy armor used by certain Nanotrasen bodyguards."

/obj/item/clothing/suit/cultist
	name = "cultist robe"
	desc = "The unholy vestments of a cultist."
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	wear_image_icon = 'icons/mob/overcoats/worn_suit_gimmick.dmi'
	inhand_image_icon = 'icons/mob/inhand/overcoat/hand_suit_gimmick.dmi'
	icon_state = "cultist"
	item_state = "cultist"
	see_face = 0
	magical = 1
	c_flags = COVERSEYES | COVERSMOUTH
	body_parts_covered = TORSO|LEGS|ARMS
	permeability_coefficient = 0.01

	setupProperties()
		..()
		setProperty("coldprot", 20)
		setProperty("heatprot", 20)

	cursed
		cant_drop = 1
		cant_other_remove = 1
		cant_self_remove = 1

	hastur
		name = "yellow sign cultist robe"
		desc = "For those who have seen the yellow sign and answered its call.."
		icon_state = "hasturcultist"
		item_state = "hasturcultist"
		over_all = 1

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
	wear_image_icon = 'icons/mob/overcoats/worn_suit_gimmick.dmi'
	inhand_image_icon = 'icons/mob/inhand/overcoat/hand_suit_gimmick.dmi'
	icon_state = "flockcultist"
	item_state = "flockcultistt"
	see_face = 0
	over_all = 1
	c_flags = COVERSEYES | COVERSMOUTH
	body_parts_covered = TORSO|LEGS|ARMS
	permeability_coefficient = 0.01

/obj/item/clothing/suit/wizrobe
	name = "blue wizard robe"
	desc = "A traditional blue wizard's robe. It lacks all the stars and moons and stuff on it though."
	icon_state = "wizard"
	item_state = "wizard"
	magical = 1
	permeability_coefficient = 0.01
	body_parts_covered = TORSO|LEGS|ARMS
	contraband = 4

	setupProperties()
		..()
		setProperty("coldprot", 90)
		setProperty("heatprot", 30)

	handle_other_remove(var/mob/source, var/mob/living/carbon/human/target)
		. = ..()
		if ( . &&prob(75))
			source.show_message(text("<span class='alert'>\The [src] writhes in your hands as though it is alive! It just barely wriggles out of your grip!</span>"), 1)
			.  = 0

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
	c_flags = ONESIZEFITSALL //allows for obese to wear
	burn_possible = 1
	burn_point = 450
	burn_output = 800
	health = 20

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

/obj/item/clothing/suit/hi_vis
	name = "hi-vis vest"
	desc = "For when you just have to be seen!"
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	wear_image_icon = 'icons/mob/overcoats/worn_suit_gimmick.dmi'
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
	wear_image_icon = 'icons/mob/overcoats/worn_suit_gimmick.dmi'
	inhand_image_icon = 'icons/mob/inhand/overcoat/hand_suit_gimmick.dmi'
	icon_state = "witchfinder"
	item_state = "witchfinder"
	body_parts_covered = TORSO|LEGS|ARMS

	setupProperties()
		..()
		setProperty("coldprot", 5)
		setProperty("heatprot", 5)
		setProperty("meleeprot", 2)

/obj/item/clothing/suit/nursedress
	name = "nurse dress"
	desc = "A traditional dress worn by a nurse."
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	wear_image_icon = 'icons/mob/overcoats/worn_suit_gimmick.dmi'
	inhand_image_icon = 'icons/mob/inhand/overcoat/hand_suit_gimmick.dmi'
	icon_state = "nursedress"
	item_state = "nursedress"
	body_parts_covered = TORSO|LEGS|ARMS

/obj/item/clothing/suit/chemsuit
	name = "chemical protection suit"
	desc = "A bulky suit made from thick rubber. This should protect against most harmful chemicals."
	icon = 'icons/obj/clothing/overcoats/item_suit_hazard.dmi'
	wear_image_icon = 'icons/mob/overcoats/worn_suit_hazard.dmi'
	inhand_image_icon = 'icons/mob/inhand/overcoat/hand_suit_hazard.dmi'
	icon_state = "chem_suit"
	item_state = "chem_suit"
	body_parts_covered = TORSO|LEGS|ARMS
	permeability_coefficient = 0
	over_hair = 1

/obj/item/clothing/suit/nursedress
	name = "nurse dress"
	desc = "A traditional dress worn by a nurse."
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	wear_image_icon = 'icons/mob/overcoats/worn_suit_gimmick.dmi'
	inhand_image_icon = 'icons/mob/inhand/overcoat/hand_suit_gimmick.dmi'
	icon_state = "nursedress"
	item_state = "nursedress"
	body_parts_covered = TORSO|LEGS|ARMS

/obj/item/clothing/suit/security_badge
	name = "Security Badge"
	desc = "An official badge for a Nanotrasen Security Worker."
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	w_class = 1.0
	wear_image_icon = 'icons/mob/overcoats/worn_suit_gimmick.dmi'
	inhand_image_icon = 'icons/mob/inhand/overcoat/hand_suit_gimmick.dmi'
	icon_state = "security_badge"
	item_state = "security_badge"
	var/badge_owner_name = null
	var/badge_owner_job = null

	setupProperties()

	get_desc()
		. += "This one belongs to [badge_owner_name], the [badge_owner_job]."

	attack_self(mob/user as mob)
		user.visible_message("[user] flashes the badge: <br><span class='bold'>[bicon(src)] Nanotrasen's Finest [badge_owner_job]: [badge_owner_name].</span>", "You show off the badge: <br><span class='bold'>[bicon(src)] Nanotrasen's Finest [badge_owner_job] [badge_owner_name].</span>")
