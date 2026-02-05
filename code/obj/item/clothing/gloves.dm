// NO GLOVES NO LOVES

ABSTRACT_TYPE(/obj/item/clothing/gloves)
/obj/item/clothing/gloves
	name = "gloves"
	w_class = W_CLASS_SMALL
	icon = 'icons/obj/clothing/item_gloves.dmi'
	wear_image_icon = 'icons/mob/clothing/hands.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_feethand.dmi'
	protective_temperature = 400
	wear_layer = MOB_HAND_LAYER2
	duration_remove = 2 SECONDS
	var/uses = 0
	var/max_uses = 0 // If can_be_charged == 1, how many charges can these gloves store?
	var/stunready = 0
	///additive modifier to punch damage
	var/punch_damage_modifier = 0
	var/atom/movable/overlay/overl = null
	var/activeweapon = 0 // Used for gloves that can be toggled to turn into a weapon (example, bladed gloves)

	var/material_prints = "unknown fibers"
	var/no_prints = FALSE // Specifically used so worn gloves cannot be scanned unless removed first
	var/datum/forensic_id/fibers = null // Stores the glove's forensic fiber ID
	var/datum/forensic_id/print_mask = null // Partial fingerprint mask. Basically just regular text, but hex values get replaced with fingerprint characters

	var/can_be_charged = 0 // Currently, there are provisions for icon state "yellow" only. You have to update this file and mob_procs.dm if you're wanna use other glove sprites (Convair880).
	var/glove_ID = null //TODO: Remove variable after full-merge + secret update
	var/crit_override = 0 //overrides user's stamina crit chance, unless the user has some special limb attached
	var/bonus_crit_chance = 0 //bonus stamina crit chance; used additively in melee_attack_procs if crit_override is 0, otherwise replaces existing crit chance
	var/stamina_dmg_mult = 0 //used additively in melee_attack_procs

	var/overridespecial = 0
	var/datum/item_special/specialoverride = null

	///which hands is this glove on. So that we don't have a dozen blank iconstate in wear images for rings/etc. that are only on one side
	var/which_hands = GLOVE_HAS_LEFT | GLOVE_HAS_RIGHT

	/// Glove fingertip color, for coloring some overlays
	var/fingertip_color = null

	setupProperties()
		..()
		setProperty("coldprot", 3)
		setProperty("heatprot", 3)
		setProperty("viralprot", 10)
		setProperty("conductivity", 0.5)

	New()
		..() // your parents miss you
		flags |= HAS_EQUIP_CLICK
		src.set_fibers()

	examine()
		. = ..()
		if (src.stunready)
			. += "It seems to have some wires attached to it.[src.max_uses > 0 ? " There are [src.uses]/[src.max_uses] charges left!" : ""]"

	proc/GenID()
		var/newID = ""
		for (var/i=10, i>0, i--)
			newID += "[pick(numbersAndLetters)]"
		if (length(newID))
			return newID

	attack(var/atom/target, var/atom/challenger)
		// you, sir, have offended my honour!
		if (!isliving(target))
			return ..()
		// check intents and targets
		if (ismob(challenger))
			var/mob/C = challenger
			if (C.a_intent != INTENT_HELP || !(C.zone_sel && C.zone_sel.selecting == "head"))
				return ..()
		else
			return ..()
		// I demand satisfaction!
		if (ismob(target))
			target.visible_message(
				"<span><b>[challenger]</b> slaps [target] in the face with [src]!</span>",
				SPAN_ALERT("<b>[challenger] slaps you in the face with [src]! [capitalize(he_or_she(challenger))] has offended your honour!")
			)
			logTheThing(LOG_COMBAT, challenger, "glove-slapped [constructTarget(target,"combat")]")
		else
			target.visible_message(
				SPAN_ALERT("<b>[challenger]</b> slaps [target] in the face with [src]!")
			)
		playsound(target, 'sound/impact_sounds/Generic_Snap_1.ogg', 100, TRUE)

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/cable_coil))
			if (!src.can_be_charged)
				user.show_text("The [src.name] cannot be electrically charged.", "red")
				return
			if (src.stunready)
				user.show_text("You don't need to add more wiring to the [src.name].", "red")
				return

			var/obj/item/cable_coil/coil = W
			if(!coil.use(1))
				return
			boutput(user, SPAN_NOTICE("You attach the wires to the [src.name]."))
			src.stunready = 1
			src.setSpecialOverride(/datum/item_special/spark/gloves, src, 0)
			src.material_prints += ", electrically charged"
			return

		if (istype(W, /obj/item/cell)) // Moved from cell.dm (Convair880).
			var/obj/item/cell/C = W

			if (C.charge < 1000)
				user.show_text("[C] needs more charge before you can do that.", "red")
				return
			if (!src.stunready)
				user.visible_message(SPAN_ALERT("<b>[user]</b> shocks themselves while fumbling around with [C]!"), SPAN_ALERT("You shock yourself while fumbling around with [C]!"))
				C.zap(user)
				return

			if (src.can_be_charged)
				if (src.uses == src.max_uses)
					user.show_text("The gloves are already fully charged.", "red")
					return
				if (src.uses < 0)
					src.uses = 0
				src.uses = min(src.uses + 1, src.max_uses)
				C.use(1000)
				src.icon_state = "stun"
				src.item_state = "stun"
				src.overridespecial = 1
				C.UpdateIcon()
				user.update_clothing() // Required to update the worn sprite (Convair880).
				user.visible_message(SPAN_ALERT("<b>[user]</b> charges [his_or_her(user)] [src]."), SPAN_NOTICE("\The [src] now hold [src.uses]/[src.max_uses] charges!"))
			else
				user.visible_message(SPAN_ALERT("<b>[user]</b> shocks themselves while fumbling around with [C]!"), SPAN_ALERT("You shock yourself while fumbling around with [C]!"))
				C.zap(user)
			return

		..()

	on_forensic_scan(datum/forensic_scan/scan)
		. = ..()
		if(src.fibers)
			scan.add_text("Glove ID: ([src.fibers.id])")
		if(src.print_mask)
			var/mask_text = "Glove pattern: ([FORENSIC_GLOVE_MASK_FINGERLESS]) to ([src.print_mask.id])"
			scan.add_text(mask_text)

	proc/set_fibers()
		var/glove_fp_mask = src.get_fiber_mask()
		if(glove_fp_mask)
			src.print_mask = register_id(glove_fp_mask)
			var/list/fiber_chars = list("c","f","g","h","i","j","k","r","s","t","v","w","x","y","z")
			fibers = register_id("[src.material_prints]: [build_id(fiber_chars, 7)]")

	proc/get_fiber_mask()
		// Fiber masks replace hex values with coresponding fingerprint character positions
		// Example: abcd-egno-pqrs-uvxy => (...0AF...) => (...ary...)
		return create_glovemask_bunch(1) // Default: 1/4 chance of match

	proc/create_glovemask_position() // (...-??y?-...)
		// Probability: 1/4 chance of match
		var/rand_bunch = rand(1,4)
		var/rand_pos = rand(1,4)
		var/mask = ""
		for(var/i=1; i<=4; i++)
			if(i == rand_pos)
				var/index = (rand_bunch * 4) - 4 + rand_pos - 1
				mask += uppertext(num2hex(index, 1))
			else
				mask += "?"
		return "...-[mask]-..."

	proc/create_glovemask_bunch(var/reveal_count = 1) // (?-?-...g...-?)
		// Probability (1): 1/4 chance of match (default glove mask)
		// Probability (2): 1/15 chance of match (latex gloves)
		if(reveal_count == 0)
			return ""
		else if(reveal_count > 4)
			return "...Error..."
		var/list/text_list = list("?","?","?","?")
		var/list/bunch_list = list(1, 2, 3, 4)
		for(var/i=1; i<= reveal_count; i++)
			var/rand_bunch = rand(1, bunch_list.len)
			var/rand_pos = rand(0,3)
			var/hex = uppertext(num2hex(((bunch_list[rand_bunch] * 4) - 4 + rand_pos), 1))
			text_list[bunch_list[rand_bunch]] = "...[hex]..."
			bunch_list.Cut(rand_bunch, rand_bunch+1)

		return "[text_list[1]]-[text_list[2]]-[text_list[3]]-[text_list[4]]"

	proc/create_glovemask_order(var/reveal_count = 2) // (...y...g...) or (..y..a..g..)
		// Probability (2): 1/2 chance of match (better than default)
		// Probability (3): 1/8 chance of match (insulated gloves)
		// Probability (4): 1/64 chance of match
		if(reveal_count < 2)
			return "...Error..."
		if(reveal_count > 4)
			return null
		var/list/hex_list = list("0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F")
		var/list/mask_list = new()
		for(var/i=1; i<=reveal_count; i++)
			var/k = rand(1, length(hex_list))
			mask_list += text2ascii(hex_list[k])
			hex_list.Cut(k, k+1)

		for(var/i=1; i<= length(mask_list)-1; i++)
			for(var/k=2; k<= length(mask_list); k++)
				if(mask_list[i] > mask_list[k])
					var/temp = mask_list[i]
					mask_list[i] = mask_list[k]
					mask_list[k] = temp

		var/mask = "..."
		for(var/i=1; i<=reveal_count; i++)
			mask += "[ascii2text(mask_list[i])]..."
		return mask

	proc/special_attack(var/mob/target, var/mob/living/user)
		boutput(user, "Your gloves do nothing special")
		return

	proc/setSpecialOverride(var/type = null, master = null, active = 1)
		if(!ispath(type))
			if(isnull(type))
				src.specialoverride?.onRemove()
				src.specialoverride = null
				src.overridespecial = FALSE
			return null

		src.specialoverride?.onRemove()

		var/datum/item_special/S = new type
		S.master = master
		src.overridespecial = active
		S.onAdd()
		src.specialoverride = S
		src.tooltip_rebuild = TRUE
		return S


	equipment_click(atom/source, atom/target, params, location, control, origParams, slot)
		var/mob/user = source
		if(target == user || !istype(user) || user.a_intent == INTENT_HELP || user.a_intent == INTENT_GRAB) return 0
		if(slot != SLOT_GLOVES || !overridespecial) return 0
		SEND_SIGNAL(user, COMSIG_MOB_CLOAKING_DEVICE_DEACTIVATE)

		specialoverride.pixelaction(target,params,user)
		user.next_click = world.time + user.combat_click_delay
		return 1

	proc/get_fingertip_color()
		return src.color || src.fingertip_color


/obj/item/clothing/gloves/long // adhara stuff
	desc = "These long gloves protect your sleeves and skin from whatever dirty job you may be doing."
	name = "cleaning gloves"
	icon_state = "long_gloves"
	item_state = "long_gloves"
	protective_temperature = 550
	material_prints = "synthetic silicone rubber"
	fingertip_color = "#ffff33"
	setupProperties()
		..()
		setProperty("conductivity", 0.6)
		setProperty("heatprot", 5)
		setProperty("chemprot", 15)

	get_fiber_mask()
		return FORENSIC_GLOVE_MASK_NONE

/obj/item/clothing/gloves/fingerless
	desc = "These gloves lack fingers. Good for a space biker look, but not so good for concealing your fingerprints."
	name = "fingerless gloves"
	icon_state = "fgloves"
	item_state = "finger-"
	material_prints = "black leather"

	setupProperties()
		..()
		setProperty("conductivity", 1)

	get_fiber_mask()
		return FORENSIC_GLOVE_MASK_FINGERLESS

/obj/item/clothing/gloves/black
	desc = "These thick leather gloves are fire-resistant."
	name = "black gloves"
	icon_state = "black"
	item_state = "bgloves"
	protective_temperature = 1500
	material_prints = "black leather"
	fingertip_color = "#535353"

	setupProperties()
		..()
		setProperty("heatprot", 7)

	get_fiber_mask()
		return FORENSIC_GLOVE_MASK_NONE

	slasher
		name = "padded gloves"
		desc = "These gloves are padded and lined with insulating material."
		cant_self_remove = 1
		cant_other_remove = 1
		material_prints = "black insulative fibers"

		setupProperties()
			..()
			setProperty("heatprot", 15)
			setProperty("conductivity", 0)
			setProperty("exploprot", 10)

/obj/item/clothing/gloves/black/attackby(obj/item/W, mob/user)
	if (istool(W, TOOL_CUTTING | TOOL_SNIPPING))
		user.visible_message(SPAN_NOTICE("[user] cuts off the fingertips from [src]."))
		if(src.loc == user)
			user.u_equip(src)
		var/obj/item/clothing/gloves/fingerless/cut_gloves = new()
		cut_gloves.fibers = src.fibers
		SEND_SIGNAL(src, COMSIG_ITEM_CONVERTED, cut_gloves, user)
		qdel(src)
		user.put_in_hand_or_drop(cut_gloves)
	else . = ..()
/obj/item/clothing/gloves/cyborg
	desc = "beep boop borp"
	name = "cyborg gloves"
	icon_state = "black"
	item_state = "r_hands"
	fingertip_color = "#535353"
	setupProperties()
		..()
		setProperty("conductivity", 1)

/obj/item/clothing/gloves/latex
	name = "latex gloves"
	icon_state = "latex"
	item_state = "lgloves"
	desc = "Thin, disposable medical gloves used to help prevent the spread of germs."
	protective_temperature = 310
	material_prints = "latex rubber"
	fingertip_color = "#f3f3f3"
	setupProperties()
		..()
		setProperty("conductivity", 0.7)
		setProperty("chemprot", 15)

	get_fiber_mask()
		return create_glovemask_bunch(2) // 1/15 chance of match

/obj/item/clothing/gloves/latex/blue
	color = "#91d5e9"
/obj/item/clothing/gloves/latex/purple
	color = "#d888d8"
/obj/item/clothing/gloves/latex/teal
	color = "#73e8b6"
/obj/item/clothing/gloves/latex/pink
	color = "#ff9bc6"

/obj/item/clothing/gloves/latex/random
	New()
		..()
		if (prob(66))
			src.color = pick("#91d5e9","#d888d8","#73e8b6","#ff9bc6")

/obj/item/clothing/gloves/crafted
	name = "gloves"
	icon_state = "custom"
	item_state = "custom_gloves"
	desc = "Custom made gloves."
	material_prints = "custom fibers"

	onMaterialChanged()
		..()
		src.set_fibers() // Custom gloves spawn without materials

	get_fiber_mask()
		if(!src.material)
			return null
		var/chem_prot = src.material.getProperty("chemical")
		if(chem_prot >= 8)
			return FORENSIC_GLOVE_MASK_NONE
		if(chem_prot >= 6)
			return create_glovemask_order(2) // 1/2 chance of match
		if(chem_prot >= 3)
			return create_glovemask_position() // 1/4 chance of match
		if(chem_prot >= 2)
			return create_glovemask_order(3) // 1/8 chance of match
		return create_glovemask_bunch(2) // 1/15 chance of match

	insulating
		onMaterialChanged()
			..()
			if(istype(src.material))

				switch(src.material.getProperty("electrical"))
					if(0 to 1)
						src.setProperty("conductivity", 0.15)
					if(1 to 2)
						src.setProperty("conductivity", 0.3)
					if(3 to 4)
						src.setProperty("conductivity", 0.45)
					else
						src.setProperty("conductivity", 1)

				var/thermal_insul = max(0, 5 - src.material.getProperty("thermal"))

				src.setProperty("coldprot", thermal_insul * 2)
				src.setProperty("heatprot", thermal_insul * 2)

	armored
		icon_state = "custom_armored"
		item_state = "custom_armored"

		onMaterialChanged()
			..()
			if(istype(src.material))
				var/types = list()
				if(src.material.getProperty("density") > 3 || src.material.getProperty("hard") > 3)
					types["blunt"] = 0.5 * (max(src.material.getProperty("density"), src.material.getProperty("hard")) - 2)
				if(src.material.getProperty("density") > 3)
					types["cut"] = 0.5 * (src.material.getProperty("density") - 2)
				if(src.material.getProperty("hard") > 3)
					types["stab"] = 0.5 * (src.material.getProperty("hard") - 2)

				var/thermal = max(0, 5 - src.material.getProperty("thermal"))
				if(thermal > 0)
					types["burn"] = thermal

				AddComponent(/datum/component/wearertargeting/unarmedblock/unarmed_bonus_block, list(SLOT_GLOVES), types)

			return

/obj/item/clothing/gloves/swat
	desc = "A pair of tactical gloves that are electrically insulated and quite heat-resistant. The high-quality materials help you in blocking attacks."
	name = "\improper SWAT gloves"
	icon_state = "inspector"
	item_state = "inspector"
	protective_temperature = 1100
	material_prints = "high-quality synthetic fibers"
	fingertip_color = "#535353"

	setupProperties()
		..()
		setProperty("heatprot", 10)
		setProperty("conductivity", 0.25)
		setProperty("deflection", 20)

	get_fiber_mask()
		return create_glovemask_order(2) // 1/2 chance of match

/obj/item/clothing/gloves/swat/syndicate
	desc = "A pair of Syndicate tactical gloves that are electrically insulated and quite heat-resistant. The high-quality materials help you in blocking attacks."
	name = "\improper SWAT gloves"
	icon_state = "swat_syndie"
	item_state = "swat_syndie"
	fingertip_color = "#b22c20"

	New()
		START_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		..()

	disposing()
		STOP_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		..()

/obj/item/clothing/gloves/swat/syndicate/knight
	name = "combat gauntlets"
	desc = "Heavy-duty combat gloves that help you keep hold of your weapon."
	icon_state = "combatgauntlets"
	item_state = "swat_syndie"
	fingertip_color = "#343442"

	setupProperties()
		..()
		setProperty("deflection", 40)

/obj/item/clothing/gloves/swat/NT
	desc = "A pair of NanoTrasen tactical gloves that are electrically insulated and quite heat-resistant. The high-quality materials help you in blocking attacks."
	icon_state = "swat_NT"
	item_state = "swat_NT"
	fingertip_color = "#2050b2"

/obj/item/clothing/gloves/swat/captain
	name = "captain's gloves"
	desc = "A pair of formal gloves that are electrically insulated and quite heat-resistant. The high-quality materials help you in blocking attacks."
	icon_state = "capgloves"
	item_state = "capgloves"
	fingertip_color = "#3fb54f"

	centcomm
		name = "commander's gloves"
		desc = "A pair of formal gloves that are electrically insulated and quite heat-resistant."
		icon_state = "centcomgloves"
		item_state = "centcomgloves"
		fingertip_color = "#3c6dc3"

	centcommred
		name = "commander's gloves"
		desc = "A pair of formal gloves that are electrically insulated and quite heat-resistant."
		icon_state = "centcomredgloves"
		item_state = "centcomredgloves"
		fingertip_color = "#d73715"

/obj/item/clothing/gloves/stungloves
	name = "stun gloves"
	desc = "These gloves are electrically charged."
	icon_state = "stun"
	item_state = "stun"
	material_prints = "insulative fibers, charged"
	stunready = 1
	can_be_charged = 1
	uses = 10
	max_uses = 10
	fingertip_color = "#ffff33"
	setupProperties()
		..()
		setProperty("conductivity", 0)
	New()
		..()
		setSpecialOverride(/datum/item_special/spark/gloves, src)

	get_fiber_mask()
		return create_glovemask_order(3) // 1/8 chance of match


/obj/item/clothing/gloves/yellow
	desc = "Tough synthrubber work gloves styled in a high-visibility yellow color. They are electrically insulated, and provide full protection against most shocks."
	name = "insulated gloves"
	icon_state = "yellow"
	item_state = "ygloves"
	material_prints = "insulative fibers"
	can_be_charged = 1
	max_uses = 4
	fingertip_color = "#ffff33"

	setupProperties()
		..()
		setProperty("conductivity", 0)

	get_fiber_mask()
		return create_glovemask_order(3) // 1/8 chance of match

	proc/unsulate()
		src.desc = "Flimsy synthrubber work gloves styled in a drab yellow color. They are not electrically insulated, and provide no protection against any shocks."
		src.name = "unsulated gloves"
		setProperty("conductivity", 1)
		src.can_be_charged = 0
		src.max_uses = 0

/obj/item/clothing/gloves/yellow/unsulated
	desc = "Flimsy synthrubber work gloves styled in a drab yellow color. They are not electrically insulated, and provide no protection against any shocks."
	name = "unsulated gloves"
	can_be_charged = 0
	max_uses = 0
	setupProperties()
		..()
		setProperty("conductivity", 1)

/obj/item/clothing/gloves/boxing
	name = "boxing gloves"
	desc = "Big soft gloves used in competitive boxing."
	icon_state = "boxinggloves"
	item_state = "bogloves"
	material_prints = "red leather"
	crit_override = 1
	bonus_crit_chance = 0
	stamina_dmg_mult = 0.35
	fingertip_color = "#f80000"
	var/weighted

	get_fiber_mask()
		return create_glovemask_position() // 1/4 chance of match

	setupProperties()
		..()
		setProperty("coldprot", 7)
		setProperty("conductivity", 0.4)

	afterattack(atom/target, mob/user, reach, params)
		..()
		boutput(user, SPAN_NOTICE("<b>You have to put the gloves on your hands first, silly!</b>"))

	get_desc()
		if (src.weighted)
			. += " One of the gloves feels unusually heavy."
		else
			. += " Gives your punches a bit more weight, at the cost of precision."

/obj/item/clothing/gloves/boxing/attackby(obj/item/W, mob/user)
	if (istype(W, /obj/item/horseshoe))
		if (src.weighted)
			boutput(user, SPAN_ALERT("You try to put [W] into [src], but there's already something in there!"))
			return
		boutput(user, "You slip the horseshoe inside one of the gloves.")
		src.weighted = 1
		src.punch_damage_modifier += 3
		tooltip_rebuild = TRUE
		qdel(W)
	else
		return ..()

/obj/item/horseshoe //Heavy horseshoe for traitor boxers to put in their gloves
	name = "heavy horseshoe"
	desc = "An old horseshoe. What would you ever use this for on a space station?"
	icon = 'icons/obj/junk.dmi'
	icon_state = "horseshoe"
	force = 6.5
	throwforce = 15
	throw_speed = 3
	throw_range = 6
	w_class = W_CLASS_TINY
	flags = TABLEPASS | NOSHIELD

	New()
		..()
		BLOCK_SETUP(BLOCK_ROPE)

/obj/item/clothing/gloves/bladed
	desc = "Transparent gloves make it look like the wearer isn't wearing gloves at all. There's a small gap on the back of each glove."
	name = "transparent gloves"
	icon_state = "transparent"
	item_state = "transparent"
	material_prints = "black leather"
	no_prints = TRUE
	var/deployed = FALSE
	nodescripition = TRUE

	custom_suicide = TRUE
	suicide_in_hand = FALSE
	HELP_MESSAGE_OVERRIDE(null)


	get_help_message(dist, mob/user)
		var/keybind = "Default: CTRL + Z"
		var/datum/keymap/current_keymap = user.client.keymap
		for (var/key in current_keymap.keys)
			if (current_keymap.keys[key] == "snap")
				keybind = current_keymap.unparse_keybind(key)
				break
		return {"While wearing the gloves, use the <b>*snap</b> ([keybind]) emote to deploy/retract the blades."}

	suicide(mob/living/carbon/human/user)
		if (!istype(user) || !src.user_can_suicide(user) || user.gloves != src)
			return FALSE
		if (!src.deployed)
			src.sheathe_blades_toggle(user)
			user.update_clothing()
		user.visible_message(SPAN_ALERT("[user] crosses the blades of [his_or_her(user)] gloves across [his_or_her(user)] neck..."),
			SPAN_ALERT("You cross the blades of your gloves across your neck..."))
		src.cant_self_remove = TRUE
		SPAWN(3 SECONDS)
			src.cant_self_remove = FALSE
			user.drop_organ("head", get_turf(user))
			user.visible_message(SPAN_ALERT("[user] slices [his_or_her(user)] head clean off! Holy shit!"), SPAN_ALERT("You slice your head clean off!"))
			playsound(get_turf(user), 'sound/impact_sounds/Flesh_Cut_1.ogg', 70, 1)
			take_bleeding_damage(user, user, 200, DAMAGE_CUT, TRUE, get_turf(user))
			user.spread_blood_clothes(user)
			user.death()

	special_attack(mob/living/target, mob/living/user)
		if(check_target_immunity( target ))
			return 0
		logTheThing(LOG_COMBAT, user, "slashes [constructTarget(target,"combat")] with hand blades at [log_loc(user)].")
		var/datum/attackResults/msgs = user.calculate_melee_attack(target, 15, 15, 0, 0.8, 0, can_punch = 0, can_kick = 0)
		user.attack_effects(target, user.zone_sel?.selecting)
		var/action = pick("stab", "slashe")
		msgs.base_attack_message = SPAN_ALERT("<b>[user] [action]s [target] with their hand blades!</b>")
		msgs.played_sound = 'sound/impact_sounds/Blade_Small_Bloody.ogg'
		msgs.damage_type = DAMAGE_CUT
		msgs.flush(SUPPRESS_LOGS)
		user.lastattacked = get_weakref(target)

	get_fiber_mask()
		return FORENSIC_GLOVE_MASK_NONE

	proc/sheathe_blades_toggle(mob/living/user)
		playsound(src.loc, 'sound/effects/sword_unsheath1.ogg', 35, 1, -3)

		if(deployed)
			deployed = FALSE
			hit_type = initial(hit_type)
			force = initial(force)
			stamina_damage = initial(stamina_damage)
			stamina_cost = initial(stamina_cost)
			stamina_crit_chance = initial(stamina_crit_chance)

			hitsound = initial(hitsound)
			attack_verbs = initial(attack_verbs)
			activeweapon = initial(activeweapon)
			setSpecialOverride(null, src)

			name = initial(name)
			desc = initial(desc)
			icon_state = initial(icon_state)
			item_state = initial(item_state)

			nodescripition = initial(nodescripition)

			user.visible_message(SPAN_ALERT("<B>[user]'s hand blades retract!</B>"))
		else
			deployed = TRUE
			hit_type = DAMAGE_CUT
			force = 15
			stamina_damage = 20
			stamina_cost = 10
			stamina_crit_chance = 0
			activeweapon = TRUE
			setSpecialOverride(/datum/item_special/double/gloves, src)

			attack_verbs = "slashes"
			hitsound = 'sound/impact_sounds/Blade_Small_Bloody.ogg'

			name = "bladed gloves"
			desc = "These transparent gloves have blades protruding from them."
			icon_state = "bladed"
			item_state = "gloves_bladed"

			nodescripition = FALSE

			user.visible_message(SPAN_ALERT("<B>Blades spring out of [user]'s hands!</B>"))

/obj/item/clothing/gloves/powergloves
	desc = "Now I'm playin' with power!"
	name = "power gloves"
	icon_state = "yellow"
	item_state = "ygloves"
	material_prints = "insulative fibers"
	can_be_charged = 1 // Quite pointless, but could be useful as a last resort away from powered wires? Hell, it's a traitor item and can get the buff (Convair880).
	max_uses = 10
	flags = HAS_EQUIP_CLICK
	fingertip_color = "#ffff33"
	HELP_MESSAGE_OVERRIDE({"While standing on a powered wire, click on a tile far away while on <span class='disarm'>disarm</span> intent to non-lethally stun, or on <span class='harm'>harm</span> item to shoot out dangerous lightning. The lightning's power is directly linked to the power in the wire."})

	var/spam_flag = 0

	setupProperties()
		..()
		setProperty("conductivity", 0)

	get_fiber_mask()
		return create_glovemask_order(3) // 1/8 chance of match

	proc/use_power(var/amount)
		var/turf/T = get_turf(src)
		var/area/A = T.loc
		if(!A || !isarea(A))
			return
		A.use_power(amount, ENVIRON)

	equipment_click(atom/source, atom/target, params, location, control, origParams, slot)
		var/mob/user = source
		if(target == user || !istype(user) || GET_COOLDOWN(src,"spam_flag") || user.a_intent == INTENT_HELP || user.a_intent == INTENT_GRAB) return 0
		if(slot != SLOT_GLOVES) return 0

		var/datum/powernet/PN
		var/netnum = 0
		if(src.overridespecial)
			..()
		for(var/turf/T in range(1, user))
			for(var/obj/cable/C in T.contents) //Needed because cables have invisibility 101. Making them disappear from most LISTS.
				PN = C.get_powernet()
				if(PN.avail)
					netnum = C.netnum
				break
			if(netnum) break

		if(BOUNDS_DIST(user, target) > 0 && !user.equipped())

			if(!netnum)
				boutput(user, SPAN_ALERT("The gloves find no cable to draw power from."))
				return

			ON_COOLDOWN(src,"spam_flag", 4 SECONDS)

			use_power(50000)

			var/atom/last = user
			var/atom/target_r = target

			var/list/dummies = new/list()

			playsound(user, 'sound/effects/elec_bigzap.ogg', 40, TRUE)

			SEND_SIGNAL(user, COMSIG_MOB_CLOAKING_DEVICE_DEACTIVATE)

			if(isturf(target))
				target_r = new/obj/elec_trg_dummy(target)

			var/turf/currTurf = get_turf(target_r)
			currTurf.hotspot_expose(2000, 400)

			var/charges_used = FALSE

			for(var/count=0, count<4, count++)

				var/list/affected = drawLineObj(last, target_r, /obj/line_obj/elec ,'icons/obj/projectiles.dmi',"WholeLghtn",1,1,"HalfStartLghtn","HalfEndLghtn",OBJ_LAYER,1,PreloadedIcon='icons/effects/LghtLine.dmi')

				SPAWN(0.6 SECONDS)
					for(var/obj/O in affected)
						qdel(O)

				if(istype(target_r, /obj/machinery/power/generatorTemp))
					var/obj/machinery/power/generatorTemp/gen = target_r
					gen.efficiency_controller += 5
					gen.grump += 5
					SPAWN(45 SECONDS)
						gen.efficiency_controller -= 5

				else if(isliving(target_r)) //Probably unsafe.
					var/mob/living/victim = target_r

					switch(user.a_intent)
						if("harm")
							logTheThing(LOG_COMBAT, user, "harm-zaps [constructTarget(target_r,"combat")] with power gloves at [log_loc(user)], power = [PN.avail]")
							src.electrocute(victim, 100, netnum, ignore_range = TRUE)
							if(uses)
								victim.shock(src, 1000 * uses, victim.hand == LEFT_HAND ? "l_arm": "r_arm", 1)
								uses--
								charges_used = TRUE
							break
						if("disarm")
							logTheThing(LOG_COMBAT, user, "disarm-zaps [constructTarget(target_r,"combat")] with power gloves at [log_loc(user)], power = [PN.avail]")
							target.changeStatus("knockdown", 3 SECONDS)
							target.changeStatus("implants_disabled", 15 SECONDS)
							break

				var/list/next = new/list()
				for(var/atom/movable/M in orange(3, target_r))
					if(M == user || istype(M, /obj/line_obj/elec) || istype(M, /obj/elec_trg_dummy) || istype(M, /obj/overlay/tile_effect) || M.invisibility) continue
					next.Add(M)

				if(istype(target_r, /obj/elec_trg_dummy)) dummies.Add(target_r)

				last = target_r
				target_r = pick(next)
				target = target_r

			for(var/d in dummies)
				qdel(d)

			if(charges_used)
				if (src.uses < 1)
					src.icon_state = "yellow"
					src.item_state = "ygloves"
					user.update_clothing() // Was missing (Convair880).
					user.show_text("The gloves are no longer electrically charged.", "red")
					src.overridespecial = 0
				else
					user.show_text("The gloves have [src.uses]/[src.max_uses] charges left!", "red")

		return 1

	afterattack(atom/target, mob/user, reach, params)
		if(istype(target, /obj/cable/) || istype(target, /obj/machinery/power/apc))
			if(istype(target, /obj/cable/))
				var/obj/cable/C = target
				var/datum/powernet/PN = C.get_powernet()
				if(!PN.avail)
					user.show_text("The [C] has no power!", "red")
					return

			if (!src.can_be_charged)
				user.show_text("The [src.name] cannot be electrically charged.", "red")
				return
			if (!src.stunready)
				user.show_text("You don't see a way to connect [src.name] to [target].  Maybe some additional wires would help?", "red")
				return

			if (src.uses == src.max_uses)
				user.show_text("The gloves are already fully charged.", "red")
				return
			if (src.uses < 0)
				src.uses = 0
			src.uses = min(src.uses + 1, src.max_uses)

			use_power(1000)
			src.icon_state = "stun"
			src.item_state = "stun"
			src.overridespecial = 1
			user.update_clothing() // Required to update the worn sprite (Convair880).
			user.visible_message(SPAN_ALERT("<b>[user]</b> charges [his_or_her(user)] [src]."), SPAN_NOTICE("\The [src] now hold [src.uses]/[src.max_uses] charges!"))
		. = ..()


/obj/item/clothing/gloves/water_wings
	name = "water wings"
	desc = "Inflatable armbands that don't help you keep afloat at all! At least they look fun."
	icon_state = "water_wings"
	item_state = "water_wings"
	material_prints = null

	setupProperties()
		..()
		setProperty("conductivity", 1)

	get_fiber_mask()
		return null


//Fun isn't something one considers when coding in ss13, but this did put a smile on my face
/obj/item/clothing/gloves/brass_gauntlet
	name = "brass gauntlet"
	desc = "A strange gauntlet made of cogs and brass machinery. It has seven slots along the side."
	icon_state = "brassgauntlet"
	item_state = "brassgauntlet"
	material_prints = "metallic scratches"
	punch_damage_modifier = 3
	burn_possible = FALSE
	cant_self_remove = 1
	cant_other_remove = 1
	abilities = list()
	ability_buttons = list()
	which_hands = GLOVE_HAS_LEFT

	setupProperties()
		..()
		setProperty("conductivity", 1) //it is made of pure metal afterall

	get_fiber_mask()
		return FORENSIC_GLOVE_MASK_NONE

	attackby(obj/item/power_stones/W, mob/user)
		if (istype(W, /obj/item/power_stones))
			if(!istype(user, /mob/living/carbon/human)) return //This ain't a critter gauntlet
			if(user:gloves != src)
				boutput(user, SPAN_ALERT("<B>You need to be wearing it dingus!</B>"))
				return
			for(var/obj/item/power_stones/S in src)
				if(S.stonetype == W.stonetype)
					boutput(user, SPAN_ALERT("<B>That's already in there you doofus!</B>")) //Some nerd is going to figure out how to duplicate stones I know it
					return
			user.visible_message(SPAN_ALERT("<B>[user] slots the [W] into the [src]!</B>"))
			user.drop_item()
			W.set_loc(src)
			abilities.Add(W.ability)

			var/obj/ability_button/NB = new W.ability(src)
			ability_buttons += NB
			NB.the_item = src
			NB.the_mob = user
			NB.name = NB.name + " ([W.name])"

			if(!user.item_abilities.Find(NB))
				user.item_abilities.Add(NB)

			user.need_update_item_abilities = 1
			user.update_item_abilities()

		//Nerd trap for using the philosophers stone
		if (istype(W, /obj/item/alchemy/stone))
			if(!istype(user, /mob/living/carbon/human)) return
			if(user:gloves != src) return

			badstone(user, W, src)
			goldsnap(user)

		//Wow this is super dumb and dangerous why would you do this
		if(istype(W, /obj/item/raw_material))
			if(!istype(user, /mob/living/carbon/human)) return
			if(user:gloves != src) return

			badmaterial(user, W, src)

		//whytho
		if(istype(W, /obj/item/brick))
			if(!istype(user, /mob/living/carbon/human)) return
			if(user:gloves != src) return

			boutput(user, SPAN_ALERT("<B>You smack the [src] with the [W]. It makes a grumpy whirr. I don't think it liked that!</B>"))
			sleep(5 SECONDS)
			boutput(user, SPAN_ALERT("<B>The [src] suddenly sucks you inside and devours you. Next time don't go smacking dangerous artifacts with bricks!</B>"))
			user.implode()

		if(istype(W, /obj/item/plutonium_core/hootonium_core))
			boutput(user, SPAN_ALERT("<B>The [src] reacts but the core is too big for the slots.</B>"))

/obj/item/clothing/gloves/princess
	name = "party princess gloves"
	desc = "Glimmer glimmer!"
	icon_state = "princess"
	item_state = "princess"
	material_prints = "silk fibres, glitter"
	fingertip_color = "#f3f3f3"

	setupProperties()
		..()
		setProperty("conductivity", 0.75)
