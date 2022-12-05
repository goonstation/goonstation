/datum/component/toggle_hood
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/obj/item/clothing/suit/hoodie/suit = null
	var/obj/ability_button/hood_toggle/toggle = new

/datum/component/toggle_hood/Initialize(hooded = FALSE)
	if(!istype(parent, /obj/item/clothing/suit/hoodie))
		return COMPONENT_INCOMPATIBLE
	src.suit = parent
	suit.hooded = hooded
	if (!islist(suit.ability_buttons))
		suit.ability_buttons = list()
	suit.ability_buttons += toggle
	toggle.the_item = suit
	toggle.name = toggle.name + " ([suit.name])"
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, .proc/flip_hood)
	RegisterSignal(parent, COMSIG_ATOM_POST_UPDATE_ICON, .proc/hood_icon)

/datum/component/toggle_hood/proc/flip_hood(atom/movable/thing, mob/user)
	suit.hooded = !suit.hooded
	suit.over_hair = !suit.over_hair
	suit.body_parts_covered ^= HEAD
	if (ismob(suit.loc))
		var/mob/M = suit.loc
		M.set_clothing_icon_dirty()
	suit.UpdateIcon()
	user.visible_message("[user] flips [his_or_her(user)] [suit.name]'s hood.")

/datum/component/toggle_hood/proc/hood_icon()
	suit.icon_state = "[suit.hood_style][suit.hooded ? "-up" : ""]"
	toggle.icon_state = "hood_[suit.hooded?"down":"up"]"

/datum/component/toggle_hood/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ITEM_ATTACK_SELF)
	UnregisterSignal(parent, COMSIG_ATOM_POST_UPDATE_ICON)
	suit.ability_buttons -= toggle
	suit = null
	qdel(toggle)
	toggle = null
	. = ..()
