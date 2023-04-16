/obj/item/parts/dummy
	name = "dummyholder"

/datum/handHolder 								// pun
	var/name = "left hand"						// designation of the hand - purely for show
	var/suffix = "-L"							// used for inhand icons
	var/offset_x = 0							// pixel offset on the x axis for inhands
	var/offset_y = 0							// pixel offset on the y axis for inhands
	var/render_layer = MOB_INHAND_LAYER			// the layer of the inhands overlay
	var/show_inhands = 1						// if not null, will show inhands normally, otherwise they won't display at all
	var/obj/item/item							// the item held in the hand
	var/icon/icon = 'icons/mob/critter_ui.dmi'	// the icon of the hand UI background
	var/icon_state = "handn"					// the icon state of the hand UI background
	var/atom/movable/screen/hud/screenObj				// ease of life
	var/limb_name = "left arm"					// name for the dummy holder
	var/datum/limb/limb							// if not null, the special limb to use when attack_handing
	var/can_hold_items = 1						// self-explanatory
	var/can_attack = 1							// also
	var/can_range_attack = 0					// does this limb have a special thing for attacking at a distance
	var/image/obscurer
	var/cooldown_overlay = 0
	var/mob/holder = null

	var/obj/item/parts/limbholder				// technically a dummy, do not set.

	New()
		..()
		obscurer = image('icons/mob/critter_ui.dmi', icon_state="hand_cooldown", layer=HUD_LAYER+2)

	disposing()
		if(screenObj)
			screenObj.dispose()
			screenObj = null
		item = null
		if(limb)
			limb.dispose()
			limb = null
		if(limbholder)
			limbholder.dispose()
			limbholder = null
		holder = null
		..()

	proc/spawn_dummy_holder()
		if (!limb)
			return
		limbholder = new /obj/item/parts/dummy
		limb.holder = limbholder
		limb.holder.name = limb_name
		limb.holder.limb_data = limb
		limb.holder.holder = holder

	proc/set_cooldown_overlay()
		if (!limb || !screenObj || cooldown_overlay)
			return
		var/cd = limb.is_on_cooldown(src.holder)
		if (cd > 0)
			cooldown_overlay = 1
			screenObj.overlays += obscurer
			SPAWN(cd)
				cooldown_overlay = 0
				screenObj.overlays -= obscurer

	proc/can_special_attack()
		if (!holder || !limb) return 0
		.= (holder.a_intent == INTENT_DISARM && limb.disarm_special) || (holder.a_intent == INTENT_HARM && limb.harm_special)
