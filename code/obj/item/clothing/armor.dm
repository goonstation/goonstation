// ARMOR

/obj/item/clothing/suit/armor
	name = "armor"
	desc = "A suit worn primarily for protection against injury."
	icon = 'icons/obj/clothing/overcoats/item_suit_armor.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_armor.dmi'
	inhand_image_icon = 'icons/mob/inhand/overcoat/hand_suit_armor.dmi'
	icon_state = "armor"
	item_state = "armor"
	body_parts_covered = TORSO|LEGS|ARMS
	hides_from_examine = C_UNIFORM|C_GLOVES|C_SHOES

	setupProperties()
		..()
		setProperty("coldprot", 10)
		setProperty("meleeprot", 6)
		setProperty("rangedprot", 1)

	onMaterialChanged()
		return

TYPEINFO(/obj/item/clothing/suit/armor/vest)
	mat_appearances_to_ignore = list("carbonfibre")
/obj/item/clothing/suit/armor/vest
	name = "armor vest"
	desc = "An armored vest that protects against some damage. Contains carbon fibres."
	icon_state = "armorvest"
	item_state = "armorvest"
	body_parts_covered = TORSO
	bloodoverlayimage = SUITBLOOD_ARMOR
	hides_from_examine = 0
	mat_changename = FALSE
	default_material = "carbonfibre"

	attack_self(mob/user)
		user.show_text("You change the armor vest's style.")
		if (src.icon_state == "armorvest")
			src.icon_state = "armorvest-old"
		else if (src.icon_state == "armorvest-old")
			src.icon_state = "armorvest-light"
		else
			src.icon_state = "armorvest"

/obj/item/clothing/suit/armor/vest/light
	name = "light armor vest"
	desc = "A cheap armored vest that gives a little bit of protection."
	icon_state = "armorvest-old"
	item_state = "armorvest-old"

	setupProperties()
		..()
		setProperty("meleeprot", 3)
		setProperty("rangedprot", 0.5)

	attackby(obj/item/W, mob/user)
		return

	attack_self(mob/user)
		return

// Added support for old-style grenades and pipe bombs. Also a bit of code streamlining (Convair880).
/obj/item/clothing/suit/armor/suicide_bomb
	name = "suicide bomb vest"
	desc = "A makeshift mechanical vest set to trigger a payload when the user dies."
	icon_state = "bombvest0"
	item_state = "armorvest"
	flags = TABLEPASS | CONDUCT | NOSPLASH
	body_parts_covered = TORSO
	bloodoverlayimage = SUITBLOOD_ARMOR
	hides_from_examine = 0

	var/obj/item/clothing/suit/armor/vest/part_vest = null
	var/obj/item/assembly/payload = null

	New(ourLoc, var/obj/item/assembly/new_payload, var/obj/item/clothing/suit/armor/vest/new_vest)
		..()
		RegisterSignal(src, COMSIG_ITEM_ON_OWNER_DEATH, PROC_REF(triggering))
		RegisterSignal(src, COMSIG_ITEM_ASSEMBLY_ON_PART_DISPOSAL, PROC_REF(on_part_disposal))
		if (!new_vest)
			src.part_vest = new /obj/item/clothing/suit/armor/vest(src)
		else
			src.part_vest = new_vest
			new_vest.set_loc(src)
			new_vest.master = src
		if (!new_payload)
			src.payload = new /obj/item/assembly/anal_ignite_pipebomb(src)
		else
			src.payload = new_payload
			new_payload.set_loc(src)
			new_payload.master = src
		// suicide vest + wrench -> disassembly
		src.AddComponent(/datum/component/assembly, TOOL_WRENCHING, PROC_REF(disassemble), FALSE)

	disposing()
		UnregisterSignal(src, COMSIG_ITEM_ON_OWNER_DEATH)
		UnregisterSignal(src, COMSIG_ITEM_ASSEMBLY_ON_PART_DISPOSAL)
		qdel(src.payload)
		src.payload = null
		qdel(src.part_vest)
		src.part_vest = null
		..()

	examine()
		. = ..()
		if (src.payload)
			. += SPAN_ALERT("Looks like the payload is a [src.payload.name].")
		else
			. += SPAN_ALERT("There doesn't appear to be a payload attached.")

	proc/on_part_disposal(var/datum/removed_part)
		spawn(1)
			src.disassemble()

	proc/disassemble(var/atom/to_combine_atom, var/mob/user)
		var/turf/T = get_turf(src)
		if(user)
			boutput(user, SPAN_ALERT("You disassemble [src.name]."))
		for(var/obj/item/affected_item in list(src.part_vest, src.payload))
			if(!affected_item.qdeled && !affected_item.disposed)
				affected_item.set_loc(T)
			affected_item.master = null
		src.part_vest = null
		src.payload = null
		qdel(src)
		return TRUE

	proc/triggering(var/affected_assembly, var/mob/dying_mob)
		if (!src || !dying_mob || !src.payload)
			return
		dying_mob.visible_message(SPAN_ALERT("<b>[dying_mob]'s [src.name] clicks loudly!</b>"))
		SEND_SIGNAL(src.payload, COMSIG_ITEM_ON_OWNER_DEATH, dying_mob)



/obj/item/clothing/suit/armor/makeshift
	name = "makeshift armor"
	desc = "A standard cyborg chest modified to function as uncomfortable, somewhat flimsy improvised armor."
	icon_state = "makeshift"
	item_state = "makeshift"
	body_parts_covered = TORSO
	hides_from_examine = 0

	setupProperties()
		..()
		setProperty("coldprot", 10)
		setProperty("meleeprot", 4)
		setProperty("rangedprot", 0.8)
		setProperty("movespeed", 0.5)
		setProperty("disorient_resist", 20)

/obj/item/clothing/suit/armor/captain
	name = "captain's armor"
	desc = "A suit of protective formal armor made for the station's captain."
	icon_state = "caparmor"
	item_state = "caparmor"
	hides_from_examine = C_UNIFORM

	setupProperties()
		..()
		setProperty("meleeprot", 7)
		setProperty("rangedprot", 1.5)

	centcomm
		name = "commander's armor"
		desc = "A suit of protective formal armor. It is made specifically for NanoTrasen commanders."
		icon_state = "centcom"
		item_state = "centcom"

	centcommred
		name = "commander's armor"
		desc = "A suit of protective formal armor. It is made specifically for NanoTrasen commanders."
		icon_state = "centcom-red"
		item_state = "centcom-red"

/obj/item/clothing/suit/armor/capcoat //old alt armour for the captain
	name = "captain's coat"
	desc = "A luxorious formal coat made for the station's captain. It seems to be made out of some thermally resistant material."
	icon_state = "capcoat"
	item_state = "capcoat"
	hides_from_examine = 0

	setupProperties()
		..()
		setProperty("coldprot", 35)
		setProperty("heatprot", 35)
		setProperty("meleeprot", 4)
		setProperty("rangedprot", 0.9)

	centcomm //coat version of the centcom armour
		name = "commander's coat"
		desc = "A luxurious formal coat. It is specifically made for Nanotrasen commanders. It seems to be made out of some thermally resistant material."
		icon_state = "centcoat"
		item_state = "centcoat"

	centcommred //for the red reward
		name = "commander's coat"
		desc = "A luxurious formal coat. It is specifically made for Nanotrasen commanders. It seems to be made out of some thermally resistant material."
		icon_state = "centcoat-red"
		item_state = "centcoat-red"

/obj/item/clothing/suit/armor/hopcoat
	name = "Head of Personnel's naval coat"
	desc = "A rather well armored coat tailored in a traditional naval fashion."
	icon_state = "hopcoat"
	item_state = "hopcoat"
	hides_from_examine = 0

	setupProperties()
		..()
		setProperty("coldprot", 35)
		setProperty("meleeprot", 3)
		setProperty("rangedprot", 0.5)

/obj/item/clothing/suit/armor/pirate_captain_coat
	name = "pirate captain's coat"
	desc = "A luxurious yet dread inducing red and gold greatcoat, worn by only the greatest of mass larcenists. Probably stolen."
	icon_state = "pirate_captain"
	item_state = "pirate_captain"
	hides_from_examine = 0
	setupProperties()
		..()
		setProperty("coldprot", 35)
		setProperty("heatprot", 35)
		setProperty("meleeprot", 4)
		setProperty("rangedprot", 0.9)

/obj/item/clothing/suit/armor/pirate_first_mate_coat
	name = "pirate first mate's coat"
	desc = "A rugged, protective, and pragmatic brown greatcoat, popular among pirates."
	icon_state = "pirate_first_mate"
	item_state = "pirate_first_mate"
	hides_from_examine = 0
	setupProperties()
		..()
		setProperty("coldprot", 35)
		setProperty("heatprot", 35)
		setProperty("meleeprot", 4)
		setProperty("rangedprot", 0.9)

/obj/item/clothing/suit/armor/heavy
	name = "heavy armor"
	desc = "A heavily armored suit that protects against moderate damage."
	icon_state = "heavy"
	item_state = "heavy"
	hides_from_examine = C_UNIFORM
	setupProperties()
		..()
		setProperty("meleeprot", 12)
		setProperty("rangedprot", 3)
		setProperty("pierceprot",25)
		setProperty("disorient_resist", 45)
		setProperty("movespeed", 1.5)

/obj/item/clothing/suit/armor/death_commando
	name = "death commando armor"
	desc = "Armor used by NanoTrasen's top secret purge unit. You're not sure how you know this."
	icon_state = "death"
	item_state = "death"
	c_flags = SPACEWEAR

/obj/item/clothing/suit/armor/tdome
	name = "thunderdome raiment"
	desc = "A set of official Thunderdome armor. It bears no team insignia or colors."
	icon_state = "td"
	item_state = "td"
	body_parts_covered = TORSO|LEGS

/obj/item/clothing/suit/armor/tdome/red
	name = "red skulls raiment"
	desc = "Official Thunderdome armor of the Red Skulls team."
	icon_state = "tdred"
	item_state = "tdred"

/obj/item/clothing/suit/armor/tdome/green
	name = "green stars raiment"
	desc = "Official Thunderdome armor of the Green Stars team."
	icon_state = "tdgreen"
	item_state = "tdgreen"

/obj/item/clothing/suit/armor/tdome/blue
	name = "blue moons raiment"
	desc = "Official Thunderdome armor of the Blue Moons team."
	icon_state = "tdblue"
	item_state = "tdblue"

/obj/item/clothing/suit/armor/tdome/yellow
	name = "yellow thunder raiment"
	desc = "Official Thunderdome armor of the Yellow Thunder team."
	icon_state = "tdyellow"
	item_state = "tdyellow"

/obj/item/clothing/suit/armor/turd
	name = "T.U.R.D.S. Tactical Gear"
	icon_state = "turd"
	item_state = "turd"

/obj/item/clothing/suit/armor/NT
	name = "armored nanotrasen jacket"
	desc = "An armored jacket worn by NanoTrasen security commanders."
	icon_state = "ntjacket_o"
	item_state = "ntjacket"
	coat_style = "ntjacket"
	icon = 'icons/obj/clothing/overcoats/item_suit.dmi' //someone moved the sprite!!
	inhand_image_icon = 'icons/mob/inhand/overcoat/hand_suit.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit.dmi'
	body_parts_covered = TORSO
	hides_from_examine = 0

	New()
		..()
		src.AddComponent(/datum/component/toggle_coat, coat_style = "[src.coat_style]", buttoned = FALSE)

TYPEINFO(/obj/item/clothing/suit/armor/NT_alt)
	mat_appearances_to_ignore = list("carbonfibre")
/obj/item/clothing/suit/armor/NT_alt
	name = "old armored vest"
	desc = "A grungy surplus armored vest. Smelly and not very clean."
	icon_state = "nt2armor"
	item_state = "nt2armor"
	body_parts_covered = TORSO
	hides_from_examine = 0
	default_material = "carbonfibre"

	setupProperties()
		..()
		setProperty("meleeprot", 6)
		setProperty("rangedprot", 1)

/obj/item/clothing/suit/armor/EOD
	name = "bomb disposal suit"
	desc = "A suit designed to absorb explosive force; very bulky and unwieldy to maneuver in."
	icon_state = "eod"
	item_state = "eod"
	w_class = W_CLASS_NORMAL
	hides_from_examine = C_UNIFORM|C_GLOVES
	setupProperties()
		..()
		setProperty("meleeprot", 9)
		setProperty("rangedprot", 2)
		setProperty("disorient_resist", 10)
		setProperty("movespeed", 0.45)
		setProperty("exploprot", 60)

/obj/item/clothing/suit/armor/hoscape
	name = "Head of Security's cape"
	desc = "A lightly-armored and stylish cape, made of heat-resistant materials. It probably won't keep you warm, but it would make a great security blanket!"
	icon_state = "hos-cape"
	item_state = "hos-cape"
	hides_from_examine = 0
	c_flags = ONBACK

	setupProperties()
		..()
		setProperty("meleeprot", 3)
		setProperty("rangedprot", 0.7)
		setProperty("coldprot", 5)
		setProperty("heatprot", 35)

/obj/item/clothing/suit/armor/gang
	name = "light armor vest"
	desc = "A minimalist plate carrier strapped to your torso. Provides as much protection as you can get without cramping your style."
	icon = 'icons/obj/items/gang.dmi'
	icon_state = "lightvest"
	item_state = "lightvest"
	body_parts_covered = TORSO
	hides_from_examine = 0

	setupProperties()
		..()
		setProperty("meleeprot", 5)
		setProperty("rangedprot", 0.5)

TYPEINFO(/obj/item/clothing/suit/armor/tacticalvest)
	mat_appearances_to_ignore = list("carbonfibre")

/obj/item/clothing/suit/armor/tacticalvest // Using own type to avoid having to mess with all the attackby junk with armor vests
	name = "tactical vest"
	desc = "A tactical vest with carrying pouches on the front. Contains carbon fibres."
	icon_state = "armorvest"
	item_state = "armorvest"
	body_parts_covered = TORSO
	bloodoverlayimage = SUITBLOOD_ARMOR
	hides_from_examine = 0
	mat_changename = FALSE
	default_material = "carbonfibre"
	var/maxslots = 3

	New()
		..()
		src.create_storage(/datum/storage, max_wclass = W_CLASS_POCKET_SIZED, slots = maxslots, opens_if_worn = TRUE)

	setupProperties()
		..()
		setProperty("meleeprot", 6)
		setProperty("rangedprot", 1)


/obj/item/clothing/suit/armor/tacticalvest/light
	name = "light tactical vest"
	desc = "A lightweight tactical vest with lots of carrying pouches on the front. It only offers minor protections. Contains carbon fibres."
	icon_state = "armorvest-light"
	item_state = "armorvest-light"
	maxslots = 5

	setupProperties()
		..()
		setProperty("meleeprot", 3)
		setProperty("rangedprot", 0.5)

/obj/item/clothing/suit/armor/tacticalvest/heavy
	name = "heavy tactical vest"
	desc = "A heavy duty tactical vest with lots of carrying pouches on the front. Contains carbon fibres."
	icon_state = "heavy"
	item_state = "heavy"
	maxslots = 5

	setupProperties()
		..()
		setProperty("meleeprot", 8)
		setProperty("rangedprot", 1.5)
		setProperty("disorient_resist", 10)
		setProperty("movespeed", 0.75)
