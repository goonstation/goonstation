/datum/component/toggle_coat
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/buttoned = null
	var/coat_style = null
	var/obj/item/clothing/suit/suit = null
	var/obj/ability_button/coat_toggle/toggle = new

/datum/component/toggle_coat/Initialize(buttoned, coat_style)
	. = ..()
	if(!istype(parent, /obj/item/clothing/suit))
		return COMPONENT_INCOMPATIBLE
	src.buttoned = buttoned
	src.coat_style = coat_style
	src.suit = parent
	LAZYLISTADD(suit.ability_buttons, parent)
	suit.ability_buttons += toggle
	toggle.the_item = suit
	toggle.name = toggle.name + " ([suit.name])"
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, .proc/button_coat)
	RegisterSignal(parent, COMSIG_ATOM_POST_UPDATE_ICON, .proc/update_coat_icon)

/datum/component/toggle_coat/proc/button_coat(atom/movable/thing, mob/user)
	src.buttoned = !src.buttoned
	if (ismob(suit.loc))
		var/mob/M = suit.loc
		M.set_clothing_icon_dirty()
	suit.UpdateIcon()
	if (src.buttoned == TRUE)
		user.visible_message("[user] buttons [his_or_her(user)] [suit.name].",\
		"You button your [suit.name].")
	else
		user.visible_message("[user] unbuttons [his_or_her(user)] [suit.name].",\
		"You unbutton your [suit.name].")

/datum/component/toggle_coat/proc/update_coat_icon()
	if(src.coat_style != suit.coat_style) //making sure this coat_style is the same as the actual object's
		src.coat_style = suit.coat_style
	suit.icon_state = "[src.coat_style][src.buttoned ? "" : "_o"]"

/datum/component/toggle_coat/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ITEM_ATTACK_SELF)
	UnregisterSignal(parent, COMSIG_ATOM_POST_UPDATE_ICON)
	suit.ability_buttons -= toggle
	suit = null
	qdel(toggle)
	toggle = null
	. = ..()
