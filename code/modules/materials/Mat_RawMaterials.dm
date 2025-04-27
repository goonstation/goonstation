/// Material piece
/obj/item/material_piece
	name = "bar"
	desc = "Some sort of processed material bar."
	icon = 'icons/obj/materials.dmi'
	icon_state = "bar"
	max_stack = INFINITY
	stack_type = /obj/item/material_piece
	/// used for prefab bars
	default_material = null
	uses_default_material_appearance = TRUE
	mat_changename = TRUE //TRUE for generic names such as Bar or Wad.

	New()
		..()
		setup_material()

	proc/setup_material()
		.=0

	_update_stack_appearance()
		if(material)
			name = "[amount] [mat_changename ? material.getName() : ""] [initial(src.name)][amount > 1 ? "s":""]"
		return

	split_stack(var/toRemove)
		if(toRemove >= amount || toRemove < 1) return 0
		var/obj/item/material_piece/P = new src.type
		P.set_loc(src.loc)
		P.setMaterial(src.material)
		src.change_stack_amount(-toRemove)
		P.change_stack_amount(toRemove - P.amount)
		return P

	clamp_act(mob/clamper, obj/item/clamp)
		if (!(src.material?.getMaterialFlags() & MATERIAL_METAL))
			return FALSE
		var/obj/item/sheet/sheets = new(src.loc)
		sheets.set_stack_amount(src.amount * 10)
		sheets.setMaterial(src.material)
		qdel(src)
		return TRUE

	attack_hand(mob/user)
		if(user.is_in_hands(src) && src.amount > 1)
			var/splitnum = round(input("How many material pieces do you want to take from the stack?","Stack of [src.amount]",1) as num)
			if (!isnum_safe(splitnum) || splitnum >= amount || splitnum < 1)
				boutput(user, SPAN_ALERT("Invalid entry, try again."))
				return
			var/obj/item/material_piece/new_stack = split_stack(splitnum)
			user.put_in_hand_or_drop(new_stack)
			new_stack.add_fingerprint(user)
		else
			..(user)

	attackby(obj/item/W, mob/user)
		if(W.type == src.type)
			stack_item(W)
			if(!user.is_in_hands(src))
				user.put_in_hand(src)
			boutput(user, SPAN_NOTICE("You add the material to the stack. It now has [src.amount] pieces."))

	mouse_drop(atom/over_object, src_location, over_location) //src dragged onto over_object
		if (isobserver(usr))
			boutput(usr, SPAN_ALERT("Quit that! You're dead!"))
			return
		if(isintangible(usr))
			boutput(usr,SPAN_ALERT("You need hands to do that. Do you have hands? No? Then stop it."))
			return

		if(!istype(over_object, /atom/movable/screen/hud))
			if (BOUNDS_DIST(usr, src) > 0)
				boutput(usr, SPAN_ALERT("You're too far away from it to do that."))
				return
			if (BOUNDS_DIST(usr, over_object) > 0)
				boutput(usr, SPAN_ALERT("You're too far away from it to do that."))
				return

		if (istype(over_object,/obj/item/material_piece) && isturf(over_object.loc)) //piece to piece only if on ground
			var/obj/item/targetObject = over_object
			if(targetObject.stack_item(src))
				usr.visible_message(SPAN_NOTICE("[usr.name] stacks \the [src]!"))
		else if(isturf(over_object)) //piece to turf. piece loc doesnt matter.
			if(src.amount > 1) //split stack.
				usr.visible_message(SPAN_NOTICE("[usr.name] splits the stack of [src]!"))
				var/toSplit = round(amount / 2)
				var/atom/movable/splitStack = split_stack(toSplit)
				if(splitStack)
					splitStack.set_loc(over_object)
			else
				if(isturf(src.loc))
					src.set_loc(over_object)
				for(var/obj/item/I in view(1,usr))
					if (!I || I == src)
						continue
					if (!src.check_valid_stack(I))
						continue
					src.stack_item(I)
				usr.visible_message(SPAN_NOTICE("[usr.name] stacks \the [src]!"))
		else if(istype(over_object, /atom/movable/screen/hud))
			var/atom/movable/screen/hud/H = over_object
			var/mob/living/carbon/human/dude = usr
			switch(H.id)
				if("lhand")
					if(dude.l_hand)
						if(dude.l_hand == src) return
						else if (istype(dude.l_hand, /obj/item/material_piece))
							var/obj/item/material_piece/DP = dude.l_hand
							DP.stack_item(src)
							usr.visible_message(SPAN_NOTICE("[usr.name] stacks \the [DP]!"))
					else if(amount > 1)
						var/toSplit = round(amount / 2)
						var/atom/movable/splitStack = split_stack(toSplit)
						if(splitStack)
							usr.visible_message(SPAN_NOTICE("[usr.name] splits the stack of [src]!"))
							splitStack.set_loc(dude)
							dude.put_in_hand(splitStack, 1)
				if("rhand")
					if(dude.r_hand)
						if(dude.r_hand == src) return
						else if (istype(dude.r_hand, /obj/item/material_piece))
							var/obj/item/material_piece/DP = dude.r_hand
							DP.stack_item(src)
							usr.visible_message(SPAN_NOTICE("[usr.name] stacks \the [DP]!"))
					else if(amount > 1)
						var/toSplit = round(amount / 2)
						var/atom/movable/splitStack = split_stack(toSplit)
						if(splitStack)
							usr.visible_message(SPAN_NOTICE("[usr.name] splits the stack of [src]!"))
							splitStack.set_loc(dude)
							dude.put_in_hand(splitStack, 0)
		else
			..()
	block
		// crystal, rubber
		name = "block"
		icon_state = "block"
		desc = "A nicely cut square brick."

	wad
		// organic
		icon_state = "wad"
		name = "clump"
		desc = "A clump of some kind of material."

		blob
			name = "chunk of blob"
			default_material = "blob"
			mat_changename = FALSE

			random
				var/static/list/random_blob_materials = null
				New()
					. = ..()
					if (!src.random_blob_materials)
						src.random_blob_materials = list()
						var/datum/material/base_mat = getMaterial("blob")
						for (var/i in 1 to 10)
							var/datum/material/new_mat = base_mat.getMutable()
							new_mat.setColor(rgb(rand(1,255), rand(1,255), rand(1,255), 255))
							src.random_blob_materials += new_mat
					src.setMaterial(pick(src.random_blob_materials))
	sphere
		// energy
		icon_state = "sphere"
		name = "sphere"
		desc = "A weird sphere of some kind."

	cloth
		// fabric
		icon_state = "fabric"
		name = "fabric"
		desc = "A weave of some kind."
		default_material = "cotton"
		var/in_use = 0

		attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
			if (user.a_intent == INTENT_GRAB)
				return ..()
			if (src.in_use)
				return ..()
			if (ishuman(target))
				var/mob/living/carbon/human/H = target
				var/zone = user.zone_sel.selecting
				var/surgery_status = H.get_surgery_status(zone)
				if (surgery_status && H.organHolder)
					actions.start(new /datum/action/bar/icon/medical_suture_bandage(H, src, 15, zone, surgery_status, rand(1,4), Vrb = "bandag"), user)
					src.in_use = 1
				else if (H.bleeding)
					actions.start(new /datum/action/bar/icon/medical_suture_bandage(H, src, 20, zone, 0, rand(2,4), Vrb = "bandag"), user)
					src.in_use = 1
				else
					user.show_text("[H == user ? "You have" : "[H] has"] no wounds or incisions on [H == user ? "your" : his_or_her(H)] [zone_sel2name[zone]] to bandage!", "red")
					src.in_use = 0
					return
			else
				return ..()

		afterattack(turf/simulated/A, mob/user)
			if(locate(/obj/decal/poster/banner, A))
				return
			else if(istype(A, /turf/simulated/wall/))
				var/obj/decal/poster/banner/B = new(A)
				if (src.material) B.setMaterial(src.material)
				logTheThing(LOG_STATION, user, "Hangs up a banner (<b>Material:</b> [B.material && B.material.getID() ? "[B.material.getID()]" : "*UNKNOWN*"]) in [A] at [log_loc(user)].")
				src.change_stack_amount(-1)
				user.visible_message(SPAN_NOTICE("[user] hangs up a [B.name] in [A]!."), SPAN_NOTICE("You hang up a [B.name] in [A]!"))

/// The metal appearance and stuff is on the parent, this is just a concrete subtype
/obj/item/material_piece/metal
/obj/item/material_piece/fart
	icon_state = "fart"
	name = "frozen fart"
	desc = "Remarkable! The cold temperatures in the freezer have frozen the fart in mid-air."
	amount = 5
	default_material = "frozenfart"
	mat_changename = FALSE
	uses_default_material_appearance = FALSE

/obj/item/material_piece/steel
	desc = "A processed bar of Steel, a common metal."
	default_material = "steel"
	icon_state = "bar"
	default_material = "steel"

/obj/item/material_piece/hamburgris
	name = "clump"
	desc = "A big clump of petrified mince, with a horrific smell."
	default_material = "hamburgris"
	icon_state = "wad"

/obj/item/material_piece/glass
	desc = "A cut block of glass, a common crystalline substance."
	default_material = "glass"
	icon_state = "block"

/obj/item/material_piece/copper
	desc = "A processed bar of copper, a conductive metal."
	default_material = "copper"
	icon_state = "bar"

/obj/item/material_piece/iridiumalloy
	icon_state = "iridium"
	name = "plate"
	desc = "A chunk of some sort of iridium alloy plating."
	default_material = "iridiumalloy"
	uses_default_material_appearance = FALSE
	amount = 5

/obj/item/material_piece/iridiumalloy/small
	amount = 1

/obj/item/material_piece/spacelag
	icon_state = "bar"
	desc = "Yep. There it is. You've done it. I hope you're happy now."
	default_material = "spacelag"
	amount = 1

/obj/item/material_piece/slag
	icon_state = "wad"
	name = "slag"
	desc = "By-product of smelting"
	default_material = "slag"
	mat_changename = FALSE

ABSTRACT_TYPE(/obj/item/material_piece/rubber)
/obj/item/material_piece/rubber/latex
	name = "latex sheet"
	desc = "A sheet of latex."
	icon_state = "latex"
	default_material = "latex"

	setup_material()
		src.create_reagents(10)
		reagents.add_reagent("rubber", 10)
		return ..()

/obj/item/material_piece/rubber/plastic
	name = "plastic sheet"
	icon_state = "latex"
	desc = "A sheet of plastic."
	default_material = "plastic"

/obj/item/material_piece/organic/wood
	name = "wooden log"
	desc = "Years of genetic engineering mean timber always comes in mostly perfectly shaped cylindrical logs."
	icon_state = "log"
	default_material = "wood"
	uses_default_material_appearance = FALSE
	mat_changename = FALSE

	attackby(obj/item/W, mob/user)
		if ((istool(W, TOOL_CUTTING | TOOL_SAWING)))
			user.visible_message("[user] cuts a plank from the [src].", "You cut a plank from the [src].")
			new /obj/item/sheet/wood(user.loc)
			if (src.amount > 1)
				change_stack_amount(-1)
			else
				qdel (src)
		else
			..()

/obj/item/material_piece/organic/bamboo
	name = "stalk"
	desc = "Keep away from Space Pandas."
	icon_state = "bamboo"
	default_material = "bamboo"
	uses_default_material_appearance = FALSE
	mat_changename = TRUE

	attackby(obj/item/W, mob/user)
		if ((istool(W, TOOL_CUTTING | TOOL_SAWING)))
			user.visible_message("[user] carefully extracts a shoot from [src].", "You carefully cut a shoot from [src], leaving behind some usable building material.")
			new /obj/item/reagent_containers/food/snacks/plant/bamboo/(user.loc)
			new /obj/item/sheet/bamboo(user.loc)
			if (src.amount > 1)
				change_stack_amount(-1)
			else
				qdel (src)
		else
			..()

/obj/item/material_piece/cloth/spidersilk
	name = "space spider silk"
	desc = "space silk produced by space dwelling space spiders. space."
	icon_state = "spidersilk"
	default_material = "spidersilk"
	uses_default_material_appearance = FALSE
	mat_changename = FALSE

/obj/item/material_piece/cloth/leather
	name = "leather"
	desc = "leather made from the skin of some sort of space critter."
	icon_state = "fabric"
	default_material = "leather"
	mat_changename = FALSE

/obj/item/material_piece/cloth/synthleather
	name = "synthleather"
	desc = "A type of artificial leather."
	icon_state = "fabric"
	default_material = "synthleather"
	mat_changename = FALSE

/obj/item/material_piece/cloth/cottonfabric
	name = "fabric"
	desc = "A type of natural fabric."
	icon_state = "fabric"
	default_material = "cotton"

/obj/item/material_piece/cloth/jean
	name = "jean textile"
	desc = "A type of a sturdy textile."
	icon_state = "fabric"
	default_material = "jean"
	mat_changename = FALSE

/obj/item/material_piece/cloth/brullbarhide
	name = "brullbar hide"
	desc = "The hide of a brullbar."
	icon_state = "fabric"
	default_material = "brullbarhide"
	mat_changename = FALSE

/obj/item/material_piece/cloth/kingbrullbarhide
	name = "king brullbar hide"
	desc = "The hide of a king brullbar."
	icon_state = "fabric"
	default_material = "kingbrullbarhide"
	mat_changename = FALSE

/obj/item/material_piece/cloth/carbon
	name = "fabric"
	desc = "carbon based hi-tech material."
	icon_state = "fabric"
	default_material = "carbonfibre"

/obj/item/material_piece/cloth/dyneema
	name = "fabric"
	desc = "carbon nanofibres and space spider silk!"
	icon_state = "fabric"
	default_material = "dyneema"

/obj/item/material_piece/cloth/hauntium
	name = "fabric"
	desc = "This cloth seems almost alive."
	icon_state = "fabric"
	default_material = "hauntium"

/obj/item/material_piece/cloth/beewool
	name = "bee wool"
	desc = "Some bee wool."
	icon_state = "fabric"
	default_material = "beewool"
	mat_changename = FALSE

/obj/item/material_piece/cloth/carpet
	name = "carpet"
	desc = "Some grimy carpet."
	icon_state = "fabric"
	default_material = "carpet"

/obj/item/material_piece/soulsteel
	desc = "A bar of soulsteel. Metal made from souls."
	icon_state = "bar"
	default_material = "soulsteel"

/obj/item/material_piece/metal/censorium
	desc = "A bar of censorium. Nice try."
	icon_state = "bar"
	default_material = "censorium"

/obj/item/material_piece/bone
	name = "bits of bone"
	desc = "some bits and pieces of bones."
	icon_state = "scrap3"
	default_material = "bone"
	uses_default_material_appearance = FALSE
	mat_changename = FALSE

/obj/item/material_piece/gnesis
	name = "wafer"
	desc = "A warm, pulsing block of weird alien computer crystal stuff."
	icon_state = "bar"
	default_material = "gnesis"

/obj/item/material_piece/gnesisglass
	name = "wafer"
	desc = "A shimmering, translucent block of weird alien computer crystal stuff."
	icon_state = "bar"
	default_material = "gnesisglass"

/obj/item/material_piece/coral
	name = "chunk"
	desc = "A piece of coral. Nice!"
	icon_state = "coral"
	default_material = "coral"
	uses_default_material_appearance = FALSE

/obj/item/material_piece/plasmacoral
	name = "chunk"
	desc = "A strange piece of coral seemingly infused with plasmastone."
	icon_state = "coral"
	default_material = "plasmacoral"
	uses_default_material_appearance = TRUE

/obj/item/material_piece/neutronium
	desc = "Neutrons condensed into a solid form."
	icon_state = "rod"
	default_material = "neutronium"

/obj/item/material_piece/plutonium
	desc = "Reprocessed nuclear fuel, refined into fissile isotopes."
	icon_state = "rod"
	default_material = "plutonium"

/obj/item/material_piece/plutonium_scrap
	name = "scrap"
	icon_state = "plutonium"
	desc = "Plutonium metal, commonly used as a power source for engines and machinery alike."
	default_material = "plutonium"

/obj/item/material_piece/foolsfoolsgold
	name = "fool's pyrite bar"
	desc = "It's gold that isn't. Except it is. MINDFUCK"
	icon_state = "bar"
	default_material = "gold"
