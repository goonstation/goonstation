// SUITS
//setup.dm
//#define SUITBLOOD_ARMOR 1
//#define SUITBLOOD_COAT 2
ABSTRACT_TYPE(/obj/item/clothing/suit)
/obj/item/clothing/suit
	name = "suit parent"
	icon = 'icons/obj/clothing/overcoats/item_suit.dmi'
	inhand_image_icon = 'icons/mob/inhand/overcoat/hand_suit.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit.dmi'
	wear_layer = MOB_ARMOR_LAYER
	var/fire_resist = T0C+100
	/// If TRUE the suit will hide whoever is wearing it's hair
	var/over_hair = FALSE
	w_class = W_CLASS_NORMAL
	var/restrain_wearer = 0
	var/bloodoverlayimage = 0
	var/team_num
	/// Used for the toggle_hood component, should be the same as the default icon_state so it can get updated with medal rewards.
	var/coat_style = null
	/// Used for hoodies (and anything that uses the toggle_hood component)
	var/hooded = FALSE


	setupProperties()
		..()
		setProperty("coldprot", 5)
		setProperty("heatprot", 5)
		setProperty("meleeprot", 2)

	equipped(mob/user, slot)
		. = ..()
		if (slot == SLOT_BACK)
			src.wear_layer = max(src.wear_layer, MOB_BACK_SUIT_LAYER) // set to a higher layer, unless they're on an even higher layer
		var/mob/living/carbon/human/H = user
		if (src.hooded && istype(H) && H.head)
			var/obj/ability_button/hood_toggle/toggle = locate() in src.ability_buttons
			toggle?.execute_ability()


	unequipped(mob/user)
		. = ..()
		src.wear_layer = initial(src.wear_layer)

	/// if this item has a hood, returns if the hood can be worn
	proc/can_wear_hood()
		. = FALSE
		var/mob/living/carbon/human/H = src.loc
		if (!istype(H))
			return
		if ((H.wear_suit == src && !H.head) || !H.wear_suit)
			return TRUE

	/// what happens after the hood is toggled. override as needed
	proc/on_toggle_hood()
		return

/obj/item/clothing/suit/hoodie
	name = "hoodie"
	desc = "Nice and comfy on those cold space evenings."
	icon = 'icons/obj/clothing/overcoats/hoods/hoodies.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/hoods/worn_hoodies.dmi'
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

/obj/item/clothing/suit/hoodie/large
	icon_state = "hoodieL"
	item_state = "hoodieL"

	New()
		..()
		src.AddComponent(/datum/component/toggle_hood, hood_style="hoodieL[src.hcolor ? "-[hcolor]" : null]")
		src.icon_state = "hoodieL[src.hcolor ? "-[hcolor]" : null]"
		src.item_state = "hoodieL[src.hcolor ? "-[hcolor]" : null]"

	white
		icon_state = "hoodieL-white"
		item_state = "hoodieL-white"
		hcolor = "white"

	pink
		icon_state = "hoodieL-pink"
		item_state = "hoodieL-pink"
		hcolor = "pink"

	black
		icon_state = "hoodieL-black"
		item_state = "hoodieL-black"
		hcolor = "black"

	green
		icon_state = "hoodieL-green"
		item_state = "hoodieL-green"
		hcolor = "green"

	red
		icon_state = "hoodieL-red"
		item_state = "hoodieL-red"
		hcolor = "red"

	blue
		desc = "Would fit well on a skeleton."
		icon_state = "hoodieL-blue"
		item_state = "hoodieL-blue"
		hcolor = "blue"

	purple
		icon_state = "hoodieL-purple"
		item_state = "hoodieL-purple"
		hcolor = "purple"

/* ======== Jackets ======== */

ABSTRACT_TYPE(/obj/item/clothing/suit/jacket)
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

/obj/item/clothing/suit/jacket/leather
	name = "leather jacket"
	desc = "Made from real Space Bovine, but don't call it cowhide."
	icon_state = "ljacket"
	item_state = "ljacket"

/obj/item/clothing/suit/jacket/dan
	name = "logo jacket"
	desc = "A dark teal jacket made of heavy synthetic fabric. It has the Discount Dan's logo printed on the back."
	icon_state = "dan_teal"
	item_state = "dan_teal"

	setupProperties()
		..()
		setProperty("coldprot", 25)

/obj/item/clothing/suit/jacket/plastic
	name = "plastic jacket"
	desc = "A flimsy and translucent plastic jacket that comes in a variety of colors. Someone who wears this must either have negative fashion or impeccable taste."
	icon_state = "jacket_plastic"
	item_state = "jacket_plastic"

	setupProperties()
		..()
		setProperty("coldprot", 10)

/obj/item/clothing/suit/jacket/plastic/random_color
	New()
		..()
		src.color = random_saturated_hex_color(1)

/obj/item/clothing/suit/jacket/yellow
	name = "yellow jacket"
	desc = "A yellow jacket with a floral design embroidered on the back."
	icon_state = "jacket_yellow"
	item_state = "jacket_yellow"

/obj/item/clothing/suit/jacket/sparkly
	name = "sparkly jacket"
	desc = "No glitter. No LEDs. Just magic!"
	icon_state = "jacket_sparkly"
	item_state = "jacket_sparkly"

ABSTRACT_TYPE(/obj/item/clothing/suit/jacket/design)
/obj/item/clothing/suit/jacket/design
	name = "jacket"
	desc = "A colorful jacket with a neat design on the back."
	var/random_design

	New()
		..()
		random_design = rand(1,10)
		src.wear_image.overlays += image(src.wear_image_icon,"design_[random_design]")

	update_wear_image(mob/living/carbon/human/H, override)
		src.wear_image.overlays = list(image(src.wear_image.icon,"[override ? "suit-" : ""]design_[random_design]"))

/obj/item/clothing/suit/jacket/design/tan
	name = "tan jacket"
	icon_state = "jacket_tan"
	item_state = "jacket_tan"

/obj/item/clothing/suit/jacket/design/maroon
	name = "maroon jacket"
	icon_state = "jacket_maroon"
	item_state = "jacket_maroon"

/obj/item/clothing/suit/jacket/design/magenta
	name = "magenta jacket"
	icon_state = "jacket_magenta"
	item_state = "jacket_magenta"

/obj/item/clothing/suit/jacket/design/mint
	name = "mint jacket"
	icon_state = "jacket_mint"
	item_state = "jacket_mint"

/obj/item/clothing/suit/jacket/design/cerulean
	name = "cerulean jacket"
	icon_state = "jacket_cerulean"
	item_state = "jacket_cerulean"

/obj/item/clothing/suit/jacket/design/navy
	name = "navy jacket"
	icon_state = "jacket_navy"
	item_state = "jacket_navy"

/obj/item/clothing/suit/jacket/design/indigo
	name = "indigo jacket"
	icon_state = "jacket_indigo"
	item_state = "jacket_indigo"

/obj/item/clothing/suit/jacket/design/grey
	name = "grey jacket"
	icon_state = "jacket_grey"
	item_state = "jacket_grey"

ABSTRACT_TYPE(/obj/item/clothing/suit/hazard)
TYPEINFO(/obj/item/clothing/suit/hazard)
	/// Does this always start armored?
	var/pre_armored = FALSE
/obj/item/clothing/suit/hazard
	name = "abstract hazard suit"
	desc = "A suit that protects against biological contamination."
	icon_state = "bio_suit"
	item_state = "bio_suit"
	icon = 'icons/obj/clothing/overcoats/item_suit_hazard.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_hazard.dmi'
	inhand_image_icon = 'icons/mob/inhand/overcoat/hand_suit_hazard.dmi'
	body_parts_covered = TORSO|LEGS|ARMS
	hides_from_examine = C_UNIFORM|C_GLOVES|C_SHOES

	/// Is this suit armored?
	var/armored = FALSE
	/// What's the icon_state for the armored version of this suit?
	var/armor_icon = "armorbio"

	New()
		. = ..()
		var/typeinfo/obj/item/clothing/suit/hazard/typeinfo = src.get_typeinfo()
		if (typeinfo.pre_armored)
			src.armor()

	setupProperties()
		..()
		setProperty("coldprot", 15)
		setProperty("heatprot", 15)
		setProperty("meleeprot", 2)
		setProperty("rangedprot", 0.5)
		setProperty("movespeed", 0.3)
		setProperty("disorient_resist", 15)

	/// Changes this suit's properties to be armored
	proc/armor()
		src.armored = TRUE
		setProperty("meleeprot", 5)
		setProperty("rangedprot", 1)
		src.icon_state = src.armor_icon
		src.name = "armored [src.name]"


/obj/item/clothing/suit/hazard/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/clothing/suit/armor/vest))
		if (src.armored)
			boutput(user, SPAN_ALERT("That suit is already armored! You can't armor it even more!"))
			return

		boutput(user, SPAN_NOTICE("You attach [W] to [src]."))
		src.armor()
		if(!src.fingerprints)
			src.fingerprints = list()
		src.fingerprints |= W.fingerprints
		qdel(W)

		if (ismob(src.loc))
			var/mob/M = src.loc
			M.update_clothing()
	else
		. = ..()

/obj/item/clothing/suit/hazard/bio_suit
	name = "bio suit"

	setupProperties()
		. = ..()
		setProperty("viralprot", 50)
		setProperty("chemprot", 60)

	armor()
		. = ..()
		setProperty("movespeed", 0.45)

/obj/item/clothing/suit/hazard/bio_suit/janitor // Adhara stuff
	desc = "A suit that protects against biological contamination. This one has purple boots."
	icon_state = "biosuit_jani"
	item_state = "biosuit_jani"

TYPEINFO(/obj/item/clothing/suit/hazard/bio_suit/armored)
	pre_armored = TRUE
/obj/item/clothing/suit/hazard/bio_suit/armored
	desc = "A suit that protects against biological contamination. Someone's slapped an armor vest over the chest."

/obj/item/clothing/suit/hazard/bio_suit/armored/nt
	name = "\improper NT bio suit"
	desc = "An armored biosuit that protects against biological contamination and toolboxes."
	armor_icon = "ntbio"

	armor()
		. = ..()
		src.delProperty("movespeed")

/obj/item/clothing/suit/hazard/paramedic
	name = "paramedic suit"
	desc = "A protective padded suit for emergency response personnel. Offers limited thermal and biological protection."
	icon_state = "paramedic"
	item_state = "paramedic"
	protective_temperature = 3000

	armor_icon = "para_armor"

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

	armor()
		. = ..()
		delProperty("movespeed")

TYPEINFO(/obj/item/clothing/suit/hazard/paramedic/armored)
	pre_armored = TRUE
/obj/item/clothing/suit/hazard/paramedic/armored
	desc = "A protective padded suit for emergency response personnel. Offers limited thermal and biological protection. Somebody slapped some armor onto the chest."
	armor_icon = "para_armor"

	para_troop
		name = "rapid response armor"
		desc = "A protective padded suit for emergency reponse personnel. Tailored for ground operations, not vacuum rated. This one bears security insignia."
		armor_icon = "para_sec"

	para_eng
		name = "rapid response armor"
		desc = "A protective padded suit for emergency response personnel. Tailored for ground operations, not vacuum rated. This one bears engineering insignia."
		armor_icon = "para_eng"

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
	acid_survival_time = 15 MINUTES

	setupProperties()
		..()
		setProperty("radprot", 50)
		setProperty("meleeprot", 6)
		setProperty("rangedprot", 2)
		setProperty("movespeed", 1)
		setProperty("disorient_resist", 35) //it's a special item
		delProperty("space_movespeed")

/obj/item/clothing/suit/hazard/rad
	name = "\improper Class II radiation suit"
	desc = "An old Soviet radiation suit made of 100% space asbestos. It's good for you!"
	icon_state = "rad"
	item_state = "rad"

	armored = TRUE // no sprites! should exist, though.

	New()
		. = ..()
		AddComponent(/datum/component/wearertargeting/geiger, list(SLOT_WEAR_SUIT))

	setupProperties()
		..()
		setProperty("radprot", 50)
		setProperty("chemprot", 25)
		setProperty("meleeprot", 3)

/obj/item/clothing/suit/det_suit
	name = "coat"
	desc = "Someone who wears this means business."
	icon_state = "detective_o"
	item_state = "det_suit"
	coat_style = "detective"
	body_parts_covered = TORSO|LEGS|ARMS
	bloodoverlayimage = SUITBLOOD_COAT

	setupProperties()
		..()
		setProperty("meleeprot", 2)
		setProperty("rangedprot", 0.5)

	New()
		..()
		src.AddComponent(/datum/component/toggle_coat, coat_style = "[src.coat_style]", buttoned = FALSE)

/obj/item/clothing/suit/det_suit/beepsky
	name = "worn jacket"
	desc = "This tattered jacket has seen better days."
	icon_state = "ntjacket_o"
	coat_style = "ntjacket"

	setupProperties()
		..()
		setProperty("meleeprot", 2)
		setProperty("rangedprot", 0.5)

/obj/item/clothing/suit/det_suit/hos
	name = "Head of Security's jacket"
	desc = "A slightly armored jacket favored by security personnel. It looks cozy and warm; you could probably sleep in this if you wanted to!"
	icon_state = "hoscoat_o"
	coat_style = "hoscoat"

	setupProperties()
		..()
		setProperty("meleeprot", 3)
		setProperty("rangedprot", 0.7)
		setProperty("coldprot", 35)

/obj/item/clothing/suit/hopjacket
	name = "Head of Personnel's jacket"
	desc = "A tacky green and red jacket for a tacky green bureaucrat."
	icon_state = "hopjacket"
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

	april_fools
		icon_state = "chef-alt"
		item_state = "chef-alt"

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

	setupProperties()
		. = ..()
		setProperty("chemprot", 30)

	april_fools
		icon_state = "MDlonglabcoat-alt"
		item_state = "MDlonglabcoat-alt"
		coat_style = "MDlonglabcoat-alt"

/obj/item/clothing/suit/labcoat/research_director
	name = "research director's labcoat"
	desc = ""
	icon_state = "RDlabcoat"
	item_state = "RDlabcoat"
	coat_style = "RDlabcoat"

	setupProperties()
		. = ..()
		setProperty("chemprot", 30)

	get_desc(var/dist, var/mob/user)
		if (user.mind?.assigned_role == "Research Director")
			. = "Your most prized lab coat; it took all your life savings to get it designed and tailored just for you."
		else
			. = "A bunch of purple glitter and cheap plastic glued together in a sad attempt to make a stylish lab coat."

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
	item_state = "bedsheet"
	layer = MOB_LAYER
	throwforce = 1
	w_class = W_CLASS_TINY
	throw_speed = 2
	throw_range = 10
	c_flags = COVERSEYES | COVERSMOUTH | ONBACK
	hides_from_examine = C_UNIFORM|C_GLOVES|C_SHOES|C_GLASSES|C_EARS|C_MASK
	body_parts_covered = TORSO|ARMS
	see_face = FALSE
	over_hair = TRUE
	wear_layer = MOB_FULL_SUIT_LAYER
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
						boutput(user, SPAN_ALERT("You were interrupted!"))
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
			src.c_flags = ONBACK
			wear_layer = MOB_BACK_LAYER + 0.2
		else
			src.icon_state = "bedsheet[src.bcolor ? "-[bcolor]" : null][src.eyeholes ? "1" : null]"
			src.item_state = src.icon_state
			see_face = FALSE
			src.c_flags = initial(src.c_flags)
			over_hair = TRUE
			wear_layer = MOB_OVER_TOP_LAYER

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

/obj/item/clothing/suit/hazard/fire
	name = "firesuit"
	desc = "A suit that protects against fire and heat."
	icon_state = "fire"
	item_state = "fire_suit"
	body_parts_covered = TORSO|LEGS|ARMS
	hides_from_examine = C_UNIFORM|C_SHOES
	protective_temperature = 4500

	armor_icon = "fire_armor"

	setupProperties()
		..()
		setProperty("coldprot", 20)
		setProperty("heatprot", 45)
		setProperty("chemprot", 10)
		setProperty("meleeprot", 3)
		setProperty("rangedprot", 0.5)
		setProperty("movespeed", 0.6)
		setProperty("disorient_resist", 15)

	armor()
		. = ..()
		setProperty("meleeprot", 6)
		setProperty("rangedprot", 1)
		setProperty("movespeed", 1)

TYPEINFO(/obj/item/clothing/suit/hazard/fire/armored)
	pre_armored = TRUE
/obj/item/clothing/suit/hazard/fire/armored
	desc = "A suit that protects against fire and heat. Somebody slapped some bulky armor onto the chest."

/obj/item/clothing/suit/hazard/fire/heavy
	name = "heavy firesuit"
	desc = "A suit that protects against extreme fire and heat."
	icon_state = "thermal"
	item_state = "thermal"
	hides_from_examine = C_UNIFORM|C_SHOES|C_GLOVES

	protective_temperature = 100000

	armored = TRUE // prevent armoring

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

/obj/item/clothing/suit/knitsweater
	name = "cozy knit sweater"
	desc = "A pretty warm-looking knit sweater. Handmade with love, probably."
	icon = 'icons/obj/clothing/overcoats/item_suit.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit.dmi'
	icon_state = "sweatercozy"
	item_state = "sweatercozy"
	body_parts_covered = TORSO|ARMS

	setupProperties()
		..()
		setProperty("coldprot", 20)

	cable
		name = "cable-knit sweater"
		desc = "A warm cable-knit sweater. Made of wool, not electrical cables."
		icon_state = "sweatercable"
		item_state = "sweatercable"

	bubble
		name = "bubble-knit sweater"
		desc = "A warm bubble-knit sweater. Made of wool, not bubbles."
		icon_state = "sweaterbubble"
		item_state = "sweaterbubble"

	cardigan
		name = "cardigan sweater"
		desc = "A warm cardigan sweater. Handmade with love, probably."
		icon_state = "cardigan"
		item_state = "cardigan"
		coat_style = "cardigan"

		New()
			..()
			src.AddComponent(/datum/component/toggle_coat, coat_style = "[src.coat_style]", buttoned = TRUE)

		dyeable
			name = "dyeable cardigan sweater"
			desc = "A warm cardigan sweater that can be dyed with hair dye. Obviously."

			New()
				..()
				src.color = "#FFFFFF"

			attackby(obj/item/dye_bottle/W, mob/user)
				if (istype(W) && W.uses_left)
					W.use_dye()
					src.color = W.customization_first_color
					src.UpdateIcon()
					var/mob/wearer = src.loc
					if (ismob(wearer))
						wearer.update_clothing()
					user.visible_message(SPAN_ALERT("<b>[user]</b> splashes dye on [user != wearer && ismob(wearer) ? "[wearer]'s" : his_or_her(user)] cardigan."))
					return
				. = ..()

// LONG SHIRTS
// No they're not sweaters

/obj/item/clothing/suit/lshirt
	name = "long sleeved shirt"
	desc = "A long sleeved shirt. It has a sinister-looking cyborg head printed on the front."
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
		desc = "A comfy-looking long sleeved shirt with the Discount Dan's logo stitched on the front. Delicious-looking tortilla chips are stitched on the back."

	dan_blue
		name = "long sleeved logo shirt"
		icon_state = "dan_blue"
		item_state = "dan_blue"
		desc = "A comfy-looking long sleeved shirt with the Discount Dan's logo stitched on the front. Delicious-looking tortilla chips are stitched on the back."

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
			if(nt_wear_state in get_icon_states(src.wear_image_icon))
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

/obj/item/emergencysuitfolded
	name = "folded emergency suit"
	desc = "A suit that protects against low pressure environments for a short time. At least, it would be if it hadn't been vacuum-compressed into a small rectangle. You'll have to unfold it before putting it on."
	icon = 'icons/obj/clothing/overcoats/item_suit_hazard.dmi'
	icon_state = "emerg_folded"
	item_state = "emerg"
	w_class = W_CLASS_TINY

	attack_self(mob/user as mob)

		user.drop_item(src) //clear hands
		boutput(user, SPAN_NOTICE("You deploy the [src]!"))
		//maybe play a sound?

		var/obj/item/newsuit = new /obj/item/clothing/suit/space/emerg
		user.put_in_hand_or_drop(newsuit)
		qdel(src)

/obj/item/clothing/suit/space/emerg/science
	name = "bomb retreival suit"
	desc = "A suit that protects against low pressure environments for a short time. Given to science since they blew up the more expensive ones."
	// TODO science colours sprite for this

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
		desc = "A suit that protects against low pressure environments and is blue."

	red
		icon_state = "spacecap-red"
		item_state = "spacecap-red"
		desc = "A suit that protects against low pressure environments and is red."

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
		START_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		..()

	setupProperties()
		..()
		setProperty("heatprot", 35)

	#ifdef MAP_OVERRIDE_POD_WARS
	attack_hand(mob/user)
		if (get_pod_wars_team_num(user) == team_num)
			..()
		else
			boutput(user, SPAN_ALERT("The space suit <b>explodes</b> as you reach out to grab it!"))
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
				boutput(user, SPAN_ALERT("The coat <b>explodes</b> as you reach out to grab it!"))
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
			setProperty("radprot", 50)

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
			setProperty("radprot", 50)

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
			setProperty("radprot", 50)

		medic
			name = "specialist operative medic uniform"
			desc = "A syndicate issue combat dress system, pressurized for space travel."
			icon_state = "syndie_specialist-medic"
			item_state = "syndie_specialist-medic"

			body_parts_covered = TORSO|LEGS|ARMS

			setupProperties()
				..()
				setProperty("viralprot", 50)
				setProperty("radprot", 50)

		infiltrator
			name = "specialist operative espionage suit"
			desc = "A syndicate issue combat dress system, pressurized for space travel."
			icon_state = "syndie_specialist-infiltrator"
			item_state = "syndie_specialist-infiltrator"

			setupProperties()
				..()
				setProperty("space_movespeed", -0.25)
				setProperty("radprot", 50)


		firebrand
			name = "specialist operative firesuit"
			icon_state = "syndie_specialist-firebrand"
			item_state = "syndie_specialist-firebrand"

			protective_temperature = 100000

			setupProperties()
				..()
				setProperty("heatprot", 100)
				setProperty("radprot", 50)

		engineer
			name = "specialist operative engineering uniform"
			icon_state = "syndie_specialist-engineer"
			item_state = "syndie_specialist-engineer"
			setupProperties()
				..()
				setProperty("radprot", 50)

		sniper
			name = "specialist operative marksman's suit"
			icon_state = "syndie_specialist-sniper"
			item_state = "syndie_specialist-sniper"
			setupProperties()
				..()
				setProperty("radprot", 50)

		grenadier
			name = "specialist operative bombsuit"

			setupProperties()
				..()
				setProperty("exploprot", 60)
				setProperty("radprot", 50)

		bard
			name = "road-worn stage uniform"
			icon_state = "syndie_specialist-bard"
			item_state = "syndie_specialist-bard"
			setupProperties()
				..()
				setProperty("radprot", 50)

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

/obj/item/clothing/suit/space/ntso/bellona
	name = "NTSO combat dress"
	desc = "A modernized NTSO combat suit, with an integrated energy shield."
	icon_state = "ntso_bellona"
	item_state = "ntso_bellona"

	New()
		. = ..()
		var/obj/item/ammo/power_cell/self_charging/cell = new/obj/item/ammo/power_cell/self_charging{max_charge = 100; recharge_rate = 25; recharge_delay = 10 SECONDS}
		AddComponent(/datum/component/cell_holder, cell, FALSE, 100, FALSE)
		AddComponent(/datum/component/wearertargeting/energy_shield, list(SLOT_WEAR_SUIT), 1, 1, TRUE, 0) //blocks 100% of damage taken, up to 100 damage total. No drain

/obj/item/clothing/suit/space/engineer
	name = "engineering space suit"
	desc = "An overly bulky space suit designed mainly for maintenance and mining."
	icon_state = "espace"
	item_state = "es_suit"

	april_fools
		icon_state = "espace-alt"
		item_state = "es_suit-alt"
		wear_state = "espace-alt"

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

/obj/item/clothing/suit/space/custom/prototype
	New()
		..()
		var/weave = getMaterial("exoweave")
		var/augment = getMaterial("bohrum")
		src.set_custom_mats(weave,augment)

// Light space suits
/obj/item/clothing/suit/space/light // Lighter suits that don't impede movement, but have way less armor
	name = "light space suit"
	desc = "A lightweight suit that protects against low pressure environments. This one doesn't seem to have any extra padding"
	icon = 'icons/obj/clothing/overcoats/item_suit_hazard.dmi'
	inhand_image_icon = 'icons/mob/inhand/overcoat/hand_suit_hazard.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_hazard.dmi'
	icon_state = "spacelight-e" // if I add more light suits/helmets change this to nuetral suit/helmet
	item_state = "es_suit"
	c_flags = SPACEWEAR
	body_parts_covered = TORSO|LEGS|ARMS
	hides_from_examine = C_UNIFORM|C_SHOES|C_GLOVES
	duration_remove = 6 SECONDS
	duration_put = 6 SECONDS
	protective_temperature = 1000
	acid_survival_time = 5 MINUTES

	New()
		..()
		if(!istype(get_area(src), /area/station))
			var/nt_wear_state = "[src.wear_state || src.icon_state]-nt"
			if(nt_wear_state in get_icon_states(src.wear_image_icon))
				src.wear_state = nt_wear_state

	setupProperties()
		..()
		setProperty("coldprot", 50)
		setProperty("heatprot", 10)
		setProperty("viralprot", 50)
		setProperty("chemprot", 30)
		setProperty("meleeprot", 1)
		setProperty("rangedprot", 0)
		setProperty("space_movespeed", 0)
		setProperty("radprot", 10)

	engineer
		name = "engineering light space suit"
		desc = "A lightweight engineering spacesuit designed to.... well, it doesn't really protect you from as much. But it lets you run away from fires quicker."
		icon_state = "spacelight-e"
		item_state = "es_suit"

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
		setProperty("meleeprot", 5)
		setProperty("rangedprot", 1)
		setProperty("space_movespeed", 0.6)

	New()
		. = ..()
		START_TRACKING

	disposing()
		STOP_TRACKING
		. = ..()

/obj/item/clothing/suit/space/industrial/nt_specialist
	name = "NT industrial space armor"
	item_state = "indus_specialist"
	icon_state = "indus_specialist"

	setupProperties()
		..()
		setProperty("space_movespeed", 0)

TYPEINFO(/obj/item/clothing/suit/space/industrial/syndicate)
	mats = list("metal_superdense" = 15,
				"conductive_high" = 15,
				"crystal_dense" = 5)
/obj/item/clothing/suit/space/industrial/syndicate
	name = "\improper Syndicate command armor"
	desc = "An armored space suit, not for your average expendable chumps. No sir."
	is_syndicate = TRUE
	contraband = 3
	icon_state = "indusred"
	item_state = "indusred"

	setupProperties()
		..()
		setProperty("meleeprot", 9)
		setProperty("rangedprot", 2)
		setProperty("space_movespeed", 0)

	New()
		START_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		..()

	disposing()
		STOP_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		..()

	specialist
		name = "specialist heavy operative combat armor"
		desc = "A syndicate issue heavy combat dress system, pressurized for space travel and reinforced for greater protection in firefights."
		icon_state = "syndie_specialist-heavy"
		item_state = "syndie_specialist-heavy"

TYPEINFO(/obj/item/clothing/suit/space/industrial/salvager)
	mats = list("metal_superdense" = 20,
				"uqill" = 10,
				"conductive_high" = 10,
				"energy_high" = 10)
/obj/item/clothing/suit/space/industrial/salvager
	name = "\improper Salvager juggernaut combat armor"
	desc = "A heavily modified industrial mining suit, it's been retrofitted for greater protection in firefights."
	icon_state = "salvager-heavy"
	item_state = "salvager-heavy"
	contraband = 3
	item_function_flags = IMMUNE_TO_ACID

	setupProperties()
		..()
		setProperty("meleeprot", 6)
		setProperty("rangedprot", 2)
		setProperty("space_movespeed", 0)
		setProperty("exploprot", 30)
		setProperty("disorient_resist", 25)
		setProperty("radprot", 50)

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
				boutput(user, SPAN_ALERT("The space suit <b>explodes</b> as you reach out to grab it!"))
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
			desc = "A fear-inspiring, blue-ish-leather great coat, typically worn by a NanoTrasen Pod Commander. Why does it look like it's been painted blue?"
			team_num = TEAM_NANOTRASEN
			#ifdef MAP_OVERRIDE_POD_WARS
			attack_hand(mob/user)
				if (get_pod_wars_team_num(user) == team_num)
					..()
				else
					boutput(user, SPAN_ALERT("The coat <b>explodes</b> as you reach out to grab it!"))
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
	see_face = FALSE
	magical = 1
	over_hair = TRUE
	wear_layer = MOB_FULL_SUIT_LAYER
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
	see_face = FALSE
	wear_layer = MOB_FULL_SUIT_LAYER
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
	coat_style = "wintercoat"
	body_parts_covered = TORSO|LEGS|ARMS

	setupProperties()
		..()
		setProperty("coldprot", 35)

	New()
		..()
		src.AddComponent(/datum/component/toggle_coat, coat_style = "[src.coat_style]", buttoned = TRUE)

/obj/item/clothing/suit/wintercoat/medical
	name = "medical winter coat"
	icon_state = "wintercoat-medical"
	item_state = "wintercoat-medical"
	coat_style = "wintercoat-medical"

/obj/item/clothing/suit/wintercoat/robotics
	name = "robotics winter coat"
	icon_state = "wintercoat-robotics"
	item_state = "wintercoat-robotics"
	coat_style = "wintercoat-robotics"

/obj/item/clothing/suit/wintercoat/genetics
	name = "genetics winter coat"
	icon_state = "wintercoat-genetics"
	item_state = "wintercoat-genetics"
	coat_style = "wintercoat-genetics"

/obj/item/clothing/suit/wintercoat/research
	name = "research winter coat"
	icon_state = "wintercoat-research"
	item_state = "wintercoat-research"
	coat_style = "wintercoat-research"

/obj/item/clothing/suit/wintercoat/engineering
	name = "engineering winter coat"
	icon_state = "wintercoat-engineering"
	item_state = "wintercoat-engineering"
	coat_style = "wintercoat-engineering"

/obj/item/clothing/suit/wintercoat/security
	name = "security winter coat"
	icon_state = "wintercoat-security"
	item_state = "wintercoat-security"
	coat_style = "wintercoat-security"

/obj/item/clothing/suit/wintercoat/command
	name = "command winter coat"
	icon_state = "wintercoat-command"
	item_state = "wintercoat-command"
	coat_style = "wintercoat-command"

/obj/item/clothing/suit/wintercoat/detective
	name = "detective's winter coat"
	desc = "A comfy coat to protect against the cold. Popular with private investigators."
	icon_state = "wintercoat-detective"
	item_state = "wintercoat-detective"
	coat_style = "wintercoat-detective"

/obj/item/clothing/suit/puffer
	name = "puffer jacket"
	desc = "A puffer coat to round out your silhouette."
	icon_state = "puffer-sci"
	item_state = "puffer-sci"
	body_parts_covered = TORSO|LEGS|ARMS

	setupProperties()
		..()
		setProperty("coldprot", 30)

/obj/item/clothing/suit/puffer/sci
	name = "science puffer jacket"
	desc = "A big comfy puffer jacket, perfect for the lab!"
	icon_state = "puffer-sci"
	item_state = "puffer-sci"

/obj/item/clothing/suit/puffer/nurse
	name = "nurse's puffer jacket"
	desc = "A poofy, easy to move in nurse jacket. Give it a twirl!"
	icon_state = "puffer-nurse"
	item_state = "puffer-nurse"

/obj/item/clothing/suit/puffer/med
	name = "medical puffer jacket"
	desc = "A pristine medical puffer, the inside is very soft to the touch."
	icon_state = "puffer-med"
	item_state = "puffer-med"

/obj/item/clothing/suit/puffer/genetics
	name = "genetics puffer jacket"
	desc = "A big comfy puffer jacket, perfect for defying nature!"
	icon_state = "puffer-medsci"
	item_state = "puffer-medsci"

/obj/item/clothing/suit/puffer/engi
	name = "engineering puffer jacket"
	desc = "A big comfy puffer jacket, perfect for the engine!"
	icon_state = "puffer-engi"
	item_state = "puffer-engi"

/obj/item/clothing/suit/puffer/sec
	name = "security puffer jacket"
	desc = "A big comfy puffer jacket, perfect for catching criminals!"
	icon_state = "puffer-sec"
	item_state = "puffer-sec"

/obj/item/clothing/suit/puffer/janitor
	name = "janitorial puffer jacket"
	desc = "Sturdy and easy to wash, inevitably going to be splashed with blood."
	icon_state = "puffer-janitor"
	item_state = "puffer-janitor"

/obj/item/clothing/suit/puffer/botanist
	name = "botany puffer jacket"
	desc = "A big comfy puffer jacket, perfect for gardening!"
	icon_state = "puffer-botanist"
	item_state = "puffer-botanist"

/obj/item/clothing/suit/puffer/rancher
	name = "rancher's puffer jacket"
	desc = "A warm and sturdy coat, with TASTEFUL flannel."
	icon_state = "puffer-rancher"
	item_state = "puffer-rancher"


ABSTRACT_TYPE(/obj/item/clothing/suit/sweater_vest)
/obj/item/clothing/suit/sweater_vest
	name = "sweater vest"
	desc = "A knit sweater vest. Surprisingly not very itchy at all."
	icon_state = "sweater_vest-tan"
	item_state = "sweater_vest-tan"
	body_parts_covered = TORSO

	setupProperties()
		..()
		setProperty("coldprot", 15)

/obj/item/clothing/suit/sweater_vest/tan
	icon_state = "sweater_vest-tan"
	item_state = "sweater_vest-tan"

/obj/item/clothing/suit/sweater_vest/red
	icon_state = "sweater_vest-red"
	item_state = "sweater_vest-red"

/obj/item/clothing/suit/sweater_vest/navy
	icon_state = "sweater_vest-navy"
	item_state = "sweater_vest-navy"

/obj/item/clothing/suit/sweater_vest/green
	icon_state = "sweater_vest-green"
	item_state = "sweater_vest-green"

/obj/item/clothing/suit/sweater_vest/grey
	icon_state = "sweater_vest-grey"
	item_state = "sweater_vest-grey"

/obj/item/clothing/suit/sweater_vest/black
	icon_state = "sweater_vest-black"
	item_state = "sweater_vest-black"

/obj/item/clothing/suit/hi_vis
	name = "hi-vis vest"
	desc = "For when you just have to be seen!"
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_gimmick.dmi'
	inhand_image_icon = 'icons/mob/inhand/overcoat/hand_suit_gimmick.dmi'
	icon_state = "hi-vis"
	item_state = "hi-vis"
	body_parts_covered = TORSO
	/// Hi-vis vests can reflect light, sorta
	var/image/reflection

	New()
		..()

	equipped(mob/user, slot)
		..()
		src.update_reflection(user)
		user.UpdateOverlays(src.reflection, "reflection")

	unequipped(mob/user)
		. = ..()
		user.ClearSpecificOverlays("reflection")

	proc/update_reflection(var/mob/user)
		if (!ishuman(user))
			return
		var/mob/living/carbon/human/H = user
		var/typeinfo/datum/mutantrace/typeinfo = H.mutantrace?.get_typeinfo()
		var/overlay_icon = typeinfo.clothing_icons["overcoats"] ? typeinfo.clothing_icons["overcoats"] : src.wear_image_icon
		src.reflection = image(overlay_icon, "[src.icon_state]-overlay")
		src.reflection.plane = PLANE_SELFILLUM
		src.reflection.color = rgb(255, 255, 255)
		src.reflection.alpha = 200

	setupProperties()
		..()
		setProperty("coldprot", 5)

/obj/item/clothing/suit/hi_vis/puffer
	name = "hi-vis puffer jacket"
	desc = "A coat that makes you even more visible!"
	icon = 'icons/obj/clothing/overcoats/item_suit.dmi'
	inhand_image_icon = 'icons/mob/inhand/overcoat/hand_suit.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit.dmi'
	icon_state = "puffer-hivis"
	item_state = "puffer-hivis"
	body_parts_covered = TORSO|LEGS|ARMS

	setupProperties()
		..()
		setProperty("coldprot", 30)

/obj/item/clothing/suit/hitman
	name = "black jacket"
	desc = "A stylish black suitjacket."
	icon_state = "hitmanc_o"
	item_state = "hitmanc"
	coat_style = "hitmanc"

	New()
		..()
		src.AddComponent(/datum/component/toggle_coat, coat_style = "[src.coat_style]", buttoned = FALSE)

/obj/item/clothing/suit/hitman/satansuit
	icon = 'icons/obj/clothing/overcoats/item_suit.dmi'
	icon_state = "inspectorc_o"
	item_state = "inspectorc"
	coat_style = "inspectorc"

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

#define BADGE_SHOWOFF_COOLDOWN 2 SECONDS

/obj/item/clothing/suit/security_badge
	name = "Security Badge"
	desc = "An official badge for a Nanotrasen Security Worker."
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	w_class = W_CLASS_TINY
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_gimmick.dmi'
	inhand_image_icon = 'icons/mob/inhand/overcoat/hand_suit_gimmick.dmi'
	icon_state = "security_badge"
	var/badge_owner_name = null
	var/badge_owner_job = null

	setupProperties()
		..()
		setProperty("meleeprot", 0)
		setProperty("heatprot", 0)
		setProperty("coldprot", 0)

	get_desc()
		. += "This one belongs to [badge_owner_name], the [badge_owner_job]."

	proc/show_off_badge(var/mob/user, var/mob/target = null)
		if(ON_COOLDOWN(user, "showoff_item", SHOWOFF_COOLDOWN))
			return
		if (istype(target))
			user.visible_message("[user] flashes the badge at [target.name]: <br>[SPAN_BOLD("[bicon(src)] Nanotrasen's Finest [badge_owner_job]: [badge_owner_name].")]", "You show off the badge to [target.name]: <br>[SPAN_BOLD("[bicon(src)] Nanotrasen's Finest [badge_owner_job] [badge_owner_name].")]")
		else
			user.visible_message("[user] flashes the badge: <br>[SPAN_BOLD("[bicon(src)] Nanotrasen's Finest [badge_owner_job]: [badge_owner_name].")]", "You show off the badge: <br>[SPAN_BOLD("[bicon(src)] Nanotrasen's Finest [badge_owner_job] [badge_owner_name].")]")
		actions.start(new /datum/action/show_item(user, src, "badge"), user)

	attack_self(mob/user as mob)
		src.show_off_badge(user)

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		src.show_off_badge(user, target)

/obj/item/clothing/suit/security_badge/shielded
	name = "NTSO Tactical Badge"
	desc = "An official badge for an NTSO operator, with a miniaturized shield projector. Small enough to be used as a backup power cell in a pinch."
	tooltip_flags = REBUILD_ALWAYS
	icon_state = "security_badge_shielded"
	item_state = "security_badge_shielded"

	get_desc()
		. = ..()
		var/ret = list()
		if ((SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST))
			. += " It has [ret["charge"]]/[ret["max_charge"]] PUs left!"

	New()
		. = ..()
		src.AddComponent(/datum/component/wearertargeting/energy_shield, list(SLOT_WEAR_SUIT), 0.8, 1, FALSE, 2)
		src.AddComponent(/datum/component/power_cell, 100, 100, 5, 30 SECONDS, TRUE)

/obj/item/clothing/suit/security_badge/paper
	name = "Hall Monitor Badge"
	desc = "A piece of soggy notebook paper with a red S doodled on it, presumably to represent security."
	icon_state = "security_badge_paper"

/obj/item/clothing/suit/security_badge/nanotrasen
	name = "Nanotrasen Badge"
	desc = "An official badge for a Nanotrasen Responder."
	icon_state = "security_badge_nanotrasen"

/obj/item/clothing/suit/security_badge/hosmedal
	name = "war medal"
	desc = ""
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	w_class = W_CLASS_TINY
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_gimmick.dmi'
	icon_state = "hosmedal"
	icon_state = "hosmedal"
	var/award_text = "This is a medal. There are many like it, but this one's mine."

	show_off_badge(var/mob/user, var/mob/target = null)
		if(ON_COOLDOWN(user, "showoff_item", SHOWOFF_COOLDOWN))
			return
		if (istype(target))
			user.visible_message("[user] flashes the medal at [target.name]. It reads: <br>[SPAN_BOLD("[bicon(src)]\"[src.award_text]\".")]", "You show off the medal to [target.name]. It reads: <br>[SPAN_BOLD("[bicon(src)]\"[src.award_text]\".")]")
		else
			user.visible_message("[user] flashes the medal. It reads: <br>[SPAN_BOLD("[bicon(src)]\"[src.award_text]\".")]", "You show off the medal. It reads: <br>[SPAN_BOLD("[bicon(src)]\"[src.award_text]\".")]")
		actions.start(new /datum/action/show_item(user, src, "badge", x_hand_offset = -5, y_hand_offset = -3), user)

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
	var/style = "snowcoat"

	New()
		..()
		src.AddComponent(/datum/component/toggle_hood, hood_style = src.style)

	setupProperties()
		..()
		setProperty("coldprot", 50)
		setProperty("heatprot", 10)
		setProperty("meleeprot", 3)
		setProperty("rangedprot", 0.5)
		setProperty("movespeed", 0.5)
		setProperty("disorient_resist", 15)

	on_toggle_hood()
		..()
		if (src.hooded)
			setProperty("coldprot", 70)
		else
			setProperty("coldprot", 50)

/obj/item/clothing/suit/snow/grey
	icon_state = "snowcoat-grey"
	style = "snowcoat-grey"

/obj/item/clothing/suit/jean_jacket
	name = "jean jacket"
	desc = "Pants for your jealous arms."
	icon = 'icons/obj/clothing/overcoats/item_suit.dmi'
	icon_state = "jean_jacket"
	item_state = "jean_jacket"
	body_parts_covered = TORSO|ARMS
	material_piece = /obj/item/material_piece/cloth/jean

	New()
		. = ..()
		setMaterial(getMaterial("jean"), FALSE, FALSE, TRUE)

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
	c_flags = ONBACK

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
	c_flags = ONBACK

/obj/item/clothing/suit/space/replica
	name = "replica space suit"
	desc = "A replica of an old space suit. Seems to still work, though."
	icon_state = "space_replica"
	item_state = "space_replica"

// RP Wrestlemania 2022 stuff by Walp

/obj/item/clothing/suit/torncloak
	name = "Torn Cloak"
	desc = "You and this cloak have been through a lot together."
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_gimmick.dmi'
	wear_layer = MOB_GLASSES_LAYER2
	icon_state = "torncape_red"
	item_state = "torncape_red"
	body_parts_covered = TORSO|ARMS
	c_flags = ONBACK

	red
		name = "Red Torn Cloak"
		icon_state = "torncape_red"
		item_state = "torncape_red"

	black
		name = "Black Torn Cloak"
		icon_state = "torncape_black"
		item_state = "torncape_black"

	blue
		name = "Blue Torn Cloak"
		icon_state = "torncape_blue"
		item_state = "torncape_blue"

	brown
		name = "Brown Torn Cloak"
		icon_state = "torncape_brown"
		item_state = "torncape_brown"

	purple
		name = "Purple Torn Cloak"
		icon_state = "torncape_purple"
		item_state = "torncape_purple"

	green
		name = "Green Torn Cloak"
		icon_state = "torncape_green"
		item_state = "torncape_green"

	random
		var/style = null

		New()
			..()
			if(!style)
				src.style = pick("red","black","blue","brown","purple","green")
				src.icon_state = "torncape_[style]"
				src.item_state = "torncape_[style]"
				src.name = "[style] torn cloak"

/obj/item/clothing/suit/torncloak/black/alpha
	var/dm_filter/filter
	var/obj/effect/effect

	New()
		. = ..()
		// concept stolen from dwarf because pali smart
		src.effect = new()
		src.effect.render_target = ref(src)
		src.effect.appearance_flags = PIXEL_SCALE | RESET_COLOR | RESET_TRANSFORM | RESET_ALPHA | NO_CLIENT_COLOR
		src.effect.vis_flags = VIS_INHERIT_DIR
		src.effect.icon = icon(src.wear_image_icon, src.icon_state)

		src.filter = alpha_mask_filter(render_source=src.effect.render_target, flags=MASK_INVERSE)

	equipped(mob/user, slot)
		. = ..()
		if (slot == SLOT_BACK || slot == SLOT_WEAR_SUIT)
			user.add_filter("clothing_[ref(src)]", 99, src.filter)
			user.vis_contents += src.effect

	unequipped(mob/user)
		. = ..()
		user.remove_filter("clothing_[ref(src)]")
		user.vis_contents -= src.effect


/obj/item/clothing/suit/scarfcape
	name = "Adventurous Scarf"
	desc = "The twin scarf tails blow in the wind as you prepare for ADVENTURE."
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_gimmick.dmi'
	wear_layer = MOB_GLASSES_LAYER2
	icon_state = "scarfcape_white"
	item_state = "scarfcape_white"
	c_flags = ONBACK

	red
		name = "Red Adventurous Scarf"
		icon_state = "scarfcape_red"
		item_state = "scarfcape_red"

	black
		name = "Black Adventurous Scarf"
		icon_state = "scarfcape_black"
		item_state = "scarfcape_black"

	white
		name = "White Adventurous Scarf"
		icon_state = "scarfcape_white"
		item_state = "scarfcape_white"

	blue
		name = "Blue Adventurous Scarf"
		icon_state = "scarfcape_blue"
		item_state = "scarfcape_blue"

	purple
		name = "Purple Adventurous Scarf"
		icon_state = "scarfcape_purple"
		item_state = "scarfcape_purple"

	green
		name = "Green Adventurous Scarf"
		icon_state = "scarfcape_green"
		item_state = "scarfcape_green"

	random
		var/style = null

		New()
			..()
			if(!style)
				src.style = pick("red","black","white","blue","purple","green")
				src.icon_state = "scarfcape_[style]"
				src.item_state = "scarfcape_[style]"
				src.name = "[style] adventure scarf"

	truerandom
		New()
			..()
			src.color = random_saturated_hex_color(1)

/obj/item/clothing/suit/fakebeewings
	name = "Fake Bee Wings"
	desc = "Made out of crinkly cellophane and a coat-hanger, but does the trick!"
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_gimmick.dmi'
	wear_layer = MOB_GLASSES_LAYER2
	icon_state = "fakebeewings"
	item_state = "fakebeewings"
	c_flags = ONBACK

//Seasonal Stuff

/obj/item/clothing/suit/autumn_cape
	name = "autumn cape"
	desc = "A cape made from real processed dried leaves, or so it says on the tag."
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_gimmick.dmi'
	icon_state = "autumn_cape"
	item_state = "autumn_cape"
	body_parts_covered = TORSO
	c_flags = ONBACK

/obj/item/clothing/suit/jacket/autumn_jacket
	name = "autumn jacket"
	desc = "A jacket made to look like a pumpkin. It could just as easily be an orange though..."
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_gimmick.dmi'
	icon_state = "autumn_jacket"
	item_state = "autumn_jacket"

// New chaplain stuff

/obj/item/clothing/suit/light_robes
	name = "light regalia"
	desc = "A golden-white regalia with golden and blue trims. It exudes the energy of life and light."
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_gimmick.dmi'
	icon_state = "lightrobe"
	item_state = "lightrobe"
	body_parts_covered = TORSO|LEGS|ARMS
	hides_from_examine = C_UNIFORM

/obj/item/clothing/suit/burned_robes
	name = "incendiary robes"
	desc = "A set of ash-colored robes with flared, charred edges on the bottom and sleeves. You feel a subtle burning sensation just looking at it."
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_gimmick.dmi'
	icon_state = "burnedrobe"
	item_state = "burnedrobe"
	over_hair = TRUE
	wear_layer = MOB_FULL_SUIT_LAYER
	body_parts_covered = TORSO|LEGS|ARMS
	hides_from_examine = C_UNIFORM

/obj/item/clothing/suit/green_robes
	name = "lost horror robes"
	desc = "A dull chartreuse robe with faded mysterious imagery of gods around the legs. It exudes an aura of mystery you cannot begin to comprehend."
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_gimmick.dmi'
	icon_state = "greenrobe"
	item_state = "greenrobe"
	over_hair = TRUE
	wear_layer = MOB_FULL_SUIT_LAYER
	body_parts_covered = TORSO|LEGS|ARMS
	hides_from_examine = C_UNIFORM

/obj/item/clothing/suit/nature_robes
	name = "druid robes"
	desc = "An oak-colored robe wrapped in imagery of leaves and branches. It feels like bark to the touch."
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_gimmick.dmi'
	icon_state = "naturerobe"
	item_state = "naturerobe"
	body_parts_covered = TORSO|LEGS|ARMS
	hides_from_examine = C_UNIFORM

// Denim Dresses

ABSTRACT_TYPE(/obj/item/clothing/suit/dress/denim)
/obj/item/clothing/suit/dress/denim
	name = "denim dress"
	desc = "A pair of overalls with legs lopped off! Breezy and stylish."
	icon = 'icons/obj/clothing/overcoats/item_suit.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit.dmi'
	icon_state = "denim_dress-blue"
	item_state = "denim_dress-blue"
	c_flags = SLEEVELESS

/obj/item/clothing/suit/dress/denim/blue
	name = "blue denim dress"
	icon_state = "denim_dress-blue"
	item_state = "denim_dress-blue"

/obj/item/clothing/suit/dress/denim/turquoise
	name = "turquoise denim dress"
	icon_state = "denim_dress-turquoise"
	item_state = "denim_dress-turquoise"

/obj/item/clothing/suit/dress/denim/white
	name = "white denim dress"
	icon_state = "denim_dress-white"
	item_state = "denim_dress-white"

/obj/item/clothing/suit/dress/denim/black
	name = "black denim dress"
	icon_state = "denim_dress-black"
	item_state = "denim_dress-black"

/obj/item/clothing/suit/dress/denim/grey
	name = "grey denim dress"
	icon_state = "denim_dress-grey"
	item_state = "denim_dress-grey"

/obj/item/clothing/suit/dress/denim/khaki
	name = "khaki denim dress"
	icon_state = "denim_dress-khaki"
	item_state = "denim_dress-khaki"
