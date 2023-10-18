//▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ Gas Masks ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

/obj/item/clothing/mask/gas/eyemask
	name = "Z-4KU mask"
	desc = "A nifty LED Mask that changes color in hand!"
	icon_state = "eyemask"
	item_state = "gas_mask"
	uses_multiple_icon_states = 1
	color_r = 1
	color_g = 0.8
	color_b = 0.8

	attack_self(mob/user)
		user.show_text("The LED changes color!")
		if (src.icon_state == "eyemask")
			src.icon_state = "eyemask_b"
		else if (src.icon_state == "eyemask_b")
			src.icon_state = "eyemask_g"
		else if (src.icon_state == "eyemask_g")
			src.icon_state = "eyemask_p"
		else if (src.icon_state == "eyemask_p")
			src.icon_state = "eyemask_y"
		else
			src.icon_state = "eyemask"
/obj/item/clothing/mask/swat/haf
	name = "Strange Mask"
	desc = "Not your usual colors..."
	icon_state = "swathaf"
	item_state = "swathaf"
	color_r = 0.8
	color_g = 0.8
	color_b = 0.8

//▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ Clothing and Suits ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

/obj/item/clothing/suit/space/ntso/morrigan
	name = "Morrigan Duress Suit"
	desc = "A modern Syndicate space suit from the Morrigan Branch."
	icon_state = "morrigan_specialist"
	item_state = "morrigan_specialist"
/obj/item/clothing/head/helmet/space/ntso/morrigan
	name = "Morrigan Battle Helmet"
	desc = "A modern combat helmet for Syndicate security forces aboard Morrigan."
	icon_state = "morrigan_specialist"
	item_state = "morrigan_specialist"
/obj/item/clothing/suit/armor/heavy/morrigan
	icon_state = "heavy_s"

/obj/item/clothing/suit/armor/morrigan
	icon_state = "armorvest_s"

/obj/item/clothing/head/helmet/riot/morrigan
	icon_state = "riot_s"
/obj/item/clothing/suit/space/syndiehos
	name = "Head of Security's coat"
	desc = "A slightly armored jacket favored by Syndicate security personnel!"
	icon = 'icons/obj/clothing/overcoats/item_suit_hazard.dmi'
	inhand_image_icon = 'icons/mob/inhand/overcoat/hand_suit_hazard.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_hazard.dmi'
	icon_state = "syndicommander_coat"
	item_state = "thermal"

	setupProperties()
		..()
		setProperty("meleeprot", 3)
		setProperty("rangedprot", 0.7)
		setProperty("coldprot", 35)

/obj/item/clothing/under/suit/syndiehos
	name = "Head of Security's Decorated Suit"
	desc = "An imposing jumpsuit that radiates with... evil order?"
	icon = 'icons/obj/clothing/uniforms/item_js_rank.dmi'
	inhand_image_icon = 'icons/mob/inhand/jumpsuit/hand_js_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/jumpsuits/worn_js_rank.dmi'
	icon_state = "hos_syndie"
	item_state = "kilt"

/obj/item/clothing/under/rank/morrigan
	icon = 'icons/obj/adventurezones/morrigan/clothing/underitem.dmi'
	wear_image_icon = 'icons/mob/clothing/jumpsuits/worn_js_rank.dmi'
	inhand_image_icon = 'icons/mob/inhand/jumpsuit/hand_js.dmi'

/obj/item/clothing/under/rank/morrigan/robofab
	name = "Robotics Engineer Jumpsuit"
	desc = "A uniform issued to those working on turning the raw parts into useable circuitry."
	icon_state = "robofab"
	item_state = "black"

/obj/item/clothing/under/rank/morrigan/quality
	name = "Quality Control Jumpsuit"
	desc = "Guaranteed or money back!"
	icon_state = "quality"
	item_state = "black"

/obj/item/clothing/under/rank/morrigan/sce
	name = "Chief Engineer's Uniform"
	desc = "A simple outfit for the CE."
	icon_state = "sce"
	item_state = "grey"

/obj/item/clothing/under/rank/morrigan/executive
	name = "Hafgan Executive's Suit"
	desc = "You wouldn't know it was Hafgan's if it weren't for the big H on the coat..."
	icon_state = "executive"
	item_state = "suitB"

/obj/item/clothing/under/rank/morrigan/sec
	name = "Security Jumpsuit"
	desc = "Needs no explaining.."
	icon_state = "sec"
	item_state = "darkred"

/obj/item/clothing/under/rank/morrigan/scap
	name = "Captain's Suit"
	desc = "Fancy!"
	icon_state = "scap"
	item_state = "red"

/obj/item/clothing/under/rank/morrigan/weaponsmith
	name = "Weapon Smith's Overalls"
	desc = "Includes a handy pouch to store tools in."
	icon_state = "weaponsmith"
	item_state = "brown"

/obj/item/clothing/under/rank/morrigan/shop
	name = "Head of Personnel's Suit?"
	desc = "What is this ??"
	icon_state = "shop"
	item_state = "grey"

/obj/item/clothing/under/rank/morrigan/scargo
	name = "Exports Jumpsuit"
	desc = "TOO BRIGHT"
	icon_state = "scargo"
	item_state = "yellow"

/obj/item/clothing/under/rank/morrigan/srd
	name = "Research Director's suit"
	desc = "They mostly research materials here"
	icon_state = "srd"
	item_state = "purple"

/obj/item/clothing/suit/morrigan
	icon = 'icons/obj/adventurezones/morrigan/clothing/overcoat.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit.dmi'
	inhand_image_icon = 'icons/mob/inhand/overcoat/hand_suit.dmi'

/obj/item/clothing/suit/morrigan/executive
	name = "Executive's Coat"
	desc = "See ? A big damn H"
	icon_state = "executive"
	item_state = "wcoat"

/obj/item/clothing/suit/morrigan/captain
	name = "Captain's Coat"
	desc = "Keeps out the cold! The zipper is bust though."
	icon_state = "captain"
	item_state = "wizardred"

/obj/item/clothing/suit/morrigan/srd
	name = "Research Director's Coat"
	desc = "What an ugly palette..."
	icon_state = "srdlabcoat"
	item_state = "labcoat"

/obj/item/clothing/head/morrigan
	icon = 'icons/obj/adventurezones/morrigan/clothing/hats.dmi'
	wear_image_icon = 'icons/mob/clothing/head.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_headgear.dmi'

/obj/item/clothing/head/morrigan/swarden
	name = "Warden's Cap"
	desc = "A cap worn by the Syndicate Corrections Officers."
	icon_state = "swarden"
	item_state = "tinfoil"

/obj/item/clothing/head/morrigan/sberet
	name = "Gray Beret"
	desc = "Standard issue beret for security aboard Morrigan"
	icon_state = "sberet"
	item_state = "tinfoil"

/obj/item/clothing/head/morrigan/hafberet
	name = "Captain's Beret"
	desc = "They really like their berets hunh..."
	icon_state = "hafberet"
	item_state = "tinfoil"

/obj/item/clothing/head/morrigan/shos
	name = "Head of Security's Peak Cap"
	desc = "Sleek, evil and definitely not for you."
	uses_multiple_icon_states = 1
	icon_state = "shos"
	item_state = "tinfoil"
	var/folds = 0

/obj/item/clothing/head/morrigan/shos/attack_self(mob/user as mob)
	if(user.r_hand == src || user.l_hand == src)
		if(!src.folds)
			src.folds = 1
			src.name = "Head Of Security's Beret"
			src.icon_state = "sberetdec"
			src.item_state = "tinfoil"
			boutput(user, "<span class='notice'>You fold the hat into a beret.</span>")
		else
			src.folds = 0
			src.name = "Head of Security's Peak Cap"
			src.icon_state = "shos"
			src.item_state = "tinfoil"
			boutput(user, "<span class='notice'>You unfold the beret back into a hat.</span>")
		return

/obj/item/clothing/head/morrigan/sberetdec
	name = "Head Of Security's Beret"
	desc = "More fucking berets..."
	icon_state = "sberetdec"
	item_state = "tinfoil"

/obj/item/clothing/head/morrigan/sberetdec/generic
	name = "ADFM Operative Beret"
	desc = "A decorated beret for a decorated unit."

/obj/item/clothing/head/morrigan/rdberet
	name = "Research Director's Beret"
	desc = "A purple beret for the research director"
	icon_state = "rdberet"
	item_state = "tinfoil"

/obj/item/clothing/head/morrigan/rndhelmet
	name = "Protective Headgear"
	desc = "Complicated headgear you don't understand.."
	icon_state = "rndhelmet"
	item_state = "welding-fire"

//▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ Belts ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
/obj/item/storage/belt/gun/morrigan
	name = "No no no what have you DONE REX"
	desc = "If this exists then I am stupid."
	icon = 'icons/obj/adventurezones/morrigan/belt.dmi'
	slots = 7
	check_wclass = 1
	can_hold = list(/obj/item/gun/energy, /obj/item/baton/windup/morrigan)

	New()
		..()
		icon_state = initial(icon_state) + "-1"
		item_state = initial(item_state) + "-1"

	Entered(Obj, OldLoc)
		..()
		for (var/obj/item/O in contents)
			if (istype(O, gun_type))
				icon_state = initial(icon_state) + "-1"
				item_state = initial(item_state) + "-1"
				if (ismob(src.loc))
					var/mob/M = src.loc
					M.set_clothing_icon_dirty()
				src.UpdateIcon()
				return

	Exited(Obj, newloc)
		..()
		for (var/obj/item/O in contents)
			if (istype(O, gun_type))
				return
		icon_state = initial(icon_state) + "-0"
		item_state = initial(item_state) + "-0"
		if (ismob(src.loc))
			var/mob/M = src.loc
			M.set_clothing_icon_dirty()
		src.UpdateIcon()
		return
/obj/item/storage/belt/gun/morrigan/peacebringer
	name = "HoS belt"
	desc = "A stylish leather belt for holstering an expensive over the top laser revolver."
	icon_state = "hosbelt"
	item_state = "hosbelt"
	gun_type = /obj/item/gun/energy/peacebringer
	can_hold = list(/obj/item/gun/energy/peacebringer, /obj/item/gun/energy, /obj/item/baton/windup/morrigan)
	can_hold_exact = list(/obj/item/gun/energy/peacebringer)
	spawn_contents = list(/obj/item/gun/energy/peacebringer)

/obj/item/storage/belt/gun/morrigan/hafpistol
	name = "Light Patrol Belt"
	desc = "A stylish leather belt for holstering the mod. 21 Deneb"
	icon_state = "hafbelt"
	item_state = "hafbelt"
	gun_type = /obj/item/gun/energy/hafpistol
	can_hold = list(/obj/item/gun/energy/hafpistol, /obj/item/gun/energy, /obj/item/baton/windup/morrigan)
	can_hold_exact = list(/obj/item/gun/energy/hafpistol)
	spawn_contents = list(/obj/item/gun/energy/hafpistol, /obj/item/baton/windup/morrigan, /obj/item/chem_grenade/flashbang, /obj/item/barrier/morrigan)

/obj/item/storage/belt/gun/morrigan/minesmg
	name = "EVA Belt"
	desc = "A stylish leather belt for holstering the HMT Lycon"
	icon_state = "minesmgbelt"
	item_state = "minesmgbelt"
	gun_type = /obj/item/gun/energy/smgmine
	can_hold = list(/obj/item/gun/energy/smgmine, /obj/item/gun/energy, /obj/item/baton/windup/morrigan)
	can_hold_exact = list(/obj/item/gun/energy/smgmine)
	spawn_contents = list(/obj/item/gun/energy/smgmine, /obj/item/baton/windup/morrigan, /obj/item/ammo/power_cell/med_power)

/obj/item/storage/belt/gun/morrigan/lasershotgun
	name = "Shock Officer Belt"
	desc = "A stylish leather belt for holstering the Mod. 77 Nosaxa"
	icon_state = "lasershotgunbelt"
	item_state = "lasershotgun_belt"
	wear_layer = MOB_SHEATH_LAYER
	gun_type = /obj/item/gun/energy/lasershotgun
	can_hold = list(/obj/item/gun/energy/lasershotgun)
	can_hold_exact = list(/obj/item/gun/energy/lasershotgun, /obj/item/gun/energy, /obj/item/baton/windup/morrigan)
	spawn_contents = list(/obj/item/gun/energy/lasershotgun, /obj/item/baton/windup/morrigan, /obj/item/chem_grenade/fog)

/obj/item/storage/belt/gun/morrigan/laser_rifle
	name = "Crowd Officer Belt"
	desc = "A stylish leather belt for holstering the Mod. 201 Mimosa"
	icon_state = "laseriflebelt"
	item_state = "laserifle_belt"
	wear_layer = MOB_SHEATH_LAYER
	gun_type = /obj/item/gun/energy/laser_rifle
	can_hold = list(/obj/item/gun/energy/laser_rifle, /obj/item/gun/energy, /obj/item/baton/windup/morrigan)
	can_hold_exact = list(/obj/item/gun/energy/laser_rifle)
	spawn_contents = list(/obj/item/gun/energy/laser_rifle, /obj/item/baton/windup/morrigan, /obj/item/chem_grenade/fog)

/obj/item/storage/belt/gun/morrigan/melee
	name = "Melee Specialist Belt"
	desc = "A stylish leather belt for holstering the Tactical Hammer"
	icon_state = "hammerbelt"
	item_state = "hammer_belt"
	wear_layer = MOB_SHEATH_LAYER
	gun_type = /obj/item/tactical_hammer
	can_hold = list(/obj/item/tactical_hammer)
	can_hold_exact = list(/obj/item/tactical_hammer, /obj/item/gun/energy, /obj/item/baton/windup/morrigan)
	spawn_contents = list(/obj/item/tactical_hammer, /obj/item/baton/windup/morrigan, /obj/item/chem_grenade/fog, /obj/item/chem_grenade/fog)

/obj/item/storage/belt/gun/morrigan/medsmg
	name = "Medical Support Belt"
	desc = "A stylish belt for holstering the Mod. 101 Cardea"
	icon_state = "morriganmedicbelt"
	item_state = "morriganmedic_belt"
	wear_layer = MOB_SHEATH_LAYER
	gun_type = /obj/item/gun/kinetic/medsmg
	can_hold = list(/obj/item/gun/kinetic/medsmg, /obj/item/gun/energy, /obj/item/baton/windup/morrigan, /obj/item/robodefibrillator/morrigan)
	can_hold_exact = list(/obj/item/gun/kinetic/medsmg)
	spawn_contents = list(/obj/item/gun/kinetic/medsmg, /obj/item/baton/windup/morrigan, /obj/item/storage/box/morriganmedkit, /obj/item/storage/morrigan_pouch, /obj/item/robodefibrillator/morrigan)

