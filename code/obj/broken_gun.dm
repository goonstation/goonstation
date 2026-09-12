
// broken guns, mostly for X|G fermid zone & mors crashsite. potentially for a future gun repair system.

ABSTRACT_TYPE(/obj/item/broken_gun)

/obj/item/broken_gun
	name = "a broken gun part you shouldnt see"
	desc = "call 1-800-CODER!"
	icon = 'icons/obj/broken_guns.dmi'
	w_class = W_CLASS_SMALL
	inhand_image_icon = null


ABSTRACT_TYPE(/obj/item/broken_gun/xg_pistol)
/obj/item/broken_gun/xg_pistol
	name = "GRF Zap-Pistole fragment"
	rarity = ITEM_RARITY_UNCOMMON

	back
		desc = "The broken stock of a blaster pistol from Giesel Radiofabrik."
		icon_state = "energy_pistol-back"
	front
		desc = "The broken barrel of a blaster pistol from Giesel Radiofabrik."
		icon_state = "energy_pistol-front"

ABSTRACT_TYPE(/obj/item/broken_gun/xg_smg)
/obj/item/broken_gun/xg_smg
	name = "GRF Zap-Maschine fragment"
	rarity = ITEM_RARITY_RARE

	back
		desc = "The torn stock of a specialized particle blaster from Giesel Radiofabrik, designed for burst fire."
		icon_state = "energy_smg-back"
	front
		name = "GRF Zap-Maschine fragment"
		desc = "The torn barrel of a specialized particle blaster from Giesel Radiofabrik, designed for burst fire."
		icon_state = "energy_smg-front"

ABSTRACT_TYPE(/obj/item/broken_gun/xg_carbine)
/obj/item/broken_gun/xg_carbine
	name = "GRF Zap-Karabiner fragment"
	rarity = ITEM_RARITY_RARE

	back
		desc = "The ripped stock of a blaster carbine from Giesel Radiofabrik, designed for longer range engagements."
		icon_state = "energy_carbine-back"
	middle
		desc = "The ripped housing of a blaster carbine from Giesel Radiofabrik, designed for longer range engagements."
		icon_state = "energy_carbine-middle"
	front
		desc = "The ripped barrel of a blaster carbine from Giesel Radiofabrik, designed for longer range engagements."
		icon_state = "energy_carbine-front"

ABSTRACT_TYPE(/obj/item/broken_gun/xg_cannon)
/obj/item/broken_gun/xg_cannon
	name = "GRF Zap-Kanone fragment"
	rarity = ITEM_RARITY_EPIC

	back
		desc = "The busted stock of a heavy particle blaster from Giesel Radiofabrik, designed for high damage."
		icon_state = "energy_cannon-back"
	middle
		desc = "The busted cell of a heavy particle blaster from Giesel Radiofabrik, designed for high damage."
		icon_state = "energy_cannon-middle"
	front
		desc =  "The busted barrel of a heavy particle blaster from Giesel Radiofabrik, designed for high damage."
		icon_state = "energy_cannon-front"

/obj/item/broken_gun/mars_vega
	name = "Broken Vega flamethrower"
	desc = "This was a Vega model flamethrower, a weapon desgined to fight martians and mortians alike."
	icon_state = "vega"
