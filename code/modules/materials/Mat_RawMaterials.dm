/// Material piece
/obj/item/material_piece
	name = "bar"
	desc = "Some sort of processed material bar."
	icon = 'icons/obj/materials.dmi'
	icon_state = "bar"
	max_stack = INFINITY
	stack_type = /obj/item/material_piece
	/// used for prefab bars
	var/default_material = null

	New()
		..()
		if (istext(default_material))
			var/datum/material/M = getMaterial(default_material)
			src.setMaterial(M)
		setup_material()

	unpooled()
		..()
		if (istext(default_material))
			var/datum/material/M = getMaterial(default_material)
			src.setMaterial(M)
		setup_material()

	pooled()
		..()

	proc/setup_material()
		.=0

	update_stack_appearance()
		if(material)
			name = "[amount] [material.name] [initial(src.name)][amount > 1 ? "s":""]"
		return

	split_stack(var/toRemove)
		if(toRemove >= amount) return 0
		var/obj/item/material_piece/P = unpool(src.type)
		P.set_loc(src.loc)
		P.setMaterial(copyMaterial(src.material))
		src.change_stack_amount(-toRemove)
		P.change_stack_amount(toRemove - P.amount)
		return P

	attackby(var/obj/item/W as obj, mob/user as mob)
		if(istype(W, /obj/item/material_piece) && W.material)

			if(src.stack_item(W))
				boutput(usr, "<span class='notice'>You stack \the [W]!</span>")
		return

	MouseDrop(over_object, src_location, over_location) //src dragged onto over_object
		if (isobserver(usr))
			boutput(usr, "<span class='alert'>Quit that! You're dead!</span>")
			return

		if(!istype(over_object, /obj/screen/hud))
			if (get_dist(usr,src) > 1)
				boutput(usr, "<span class='alert'>You're too far away from it to do that.</span>")
				return
			if (get_dist(usr,over_object) > 1)
				boutput(usr, "<span class='alert'>You're too far away from it to do that.</span>")
				return

		if (istype(over_object,/obj/item/material_piece)) //piece to piece, doesnt matter if in hand or not.
			var/obj/item/targetObject = over_object
			targetObject.stack_item(src)
			usr.visible_message("<span class='notice'>[usr.name] stacks \the [src]!</span>")
		else if(isturf(over_object)) //piece to turf. piece loc doesnt matter.
			if(src.amount > 1) //split stack.
				usr.visible_message("<span class='notice'>[usr.name] splits the stack of [src]!</span>")
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
				usr.visible_message("<span class='notice'>[usr.name] stacks \the [src]!</span>")
		else if(istype(over_object, /obj/screen/hud))
			var/obj/screen/hud/H = over_object
			var/mob/living/carbon/human/dude = usr
			switch(H.id)
				if("lhand")
					if(dude.l_hand)
						if(dude.l_hand == src) return
						else if (istype(dude.l_hand, /obj/item/material_piece))
							var/obj/item/material_piece/DP = dude.l_hand
							DP.stack_item(src)
							usr.visible_message("<span class='notice'>[usr.name] stacks \the [DP]!</span>")
					else
						var/toSplit = round(amount / 2)
						var/atom/movable/splitStack = split_stack(toSplit)
						if(splitStack)
							usr.visible_message("<span class='notice'>[usr.name] splits the stack of [src]!</span>")
							splitStack.set_loc(dude)
							dude.put_in_hand(splitStack, 1)
				if("rhand")
					if(dude.r_hand)
						if(dude.r_hand == src) return
						else if (istype(dude.r_hand, /obj/item/material_piece))
							var/obj/item/material_piece/DP = dude.r_hand
							DP.stack_item(src)
							usr.visible_message("<span class='notice'>[usr.name] stacks \the [DP]!</span>")
					else
						var/toSplit = round(amount / 2)
						var/atom/movable/splitStack = split_stack(toSplit)
						if(splitStack)
							usr.visible_message("<span class='notice'>[usr.name] splits the stack of [src]!</span>")
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
		var/in_use = 0

		attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
			if (user.a_intent == INTENT_GRAB)
				return ..()
			if (src.in_use)
				return ..()
			if (ishuman(M))
				var/mob/living/carbon/human/H = M
				var/zone = user.zone_sel.selecting
				var/surgery_status = H.get_surgery_status(zone)
				if (surgery_status && H.organHolder)
					actions.start(new /datum/action/bar/icon/medical_suture_bandage(H, src, 15, zone, surgery_status, rand(1,4), "bandag"), user)
					src.in_use = 1
				else if (H.bleeding)
					actions.start(new /datum/action/bar/icon/medical_suture_bandage(H, src, 20, zone, 0, rand(2,4), "bandag"), user)
					src.in_use = 1
				else
					user.show_text("[H == user ? "You have" : "[H] has"] no wounds or incisions on [H == user ? "your" : his_or_her(H)] [zone_sel2name[zone]] to bandage!", "red")
					src.in_use = 0
					return
			else
				return ..()

/obj/item/material_piece/fart
	icon_state = "fart"
	name = "frozen fart"
	desc = "Remarkable! The cold temperatures in the freezer have frozen the fart in mid-air."
	amount = 5
	setup_material()
		src.setMaterial(getMaterial("frozenfart"), appearance = 0, setname = 0)
		..()

/obj/item/material_piece/steel
	desc = "A processed bar of Steel, a common metal."
	default_material = "steel"
	icon_state = "bar"

	setup_material()
		src.setMaterial(getMaterial("steel"), appearance = 1, setname = 1)
		..()

/obj/item/material_piece/glass
	desc = "A cut block of glass, a common crystalline substance."
	default_material = "glass"
	icon_state = "block"

	setup_material()
		src.setMaterial(getMaterial("glass"), appearance = 1, setname = 1)
		..()

/obj/item/material_piece/copper
	desc = "A processed bar of copper, a conductive metal."
	default_material = "copper"
	icon_state = "bar"

	setup_material()
		src.setMaterial(getMaterial("copper"), appearance = 1, setname = 1)
		..()

/obj/item/material_piece/iridiumalloy
	icon_state = "iridium"
	name = "iridium-alloy plate"
	desc = "A chunk of some sort of iridium-alloy plating."
	amount = 5
	setup_material()
		src.setMaterial(getMaterial("iridiumalloy"), appearance = 0, setname = 0)
		..()

/obj/item/material_piece/spacelag
	icon_state = "spacelag"
	name = "spacelag bar"
	desc = "Yep. There it is. You've done it. I hope you're happy now."
	amount = 1
	setup_material()
		src.setMaterial(getMaterial("spacelag"), appearance = 0, setname = 0)
		..()

/obj/item/material_piece/slag
	icon_state = "slag"
	name = "slag"
	desc = "By-product of smelting"
	setup_material()
		src.setMaterial(getMaterial("slag"), appearance = 0, setname = 0)
		..()

/obj/item/material_piece/rubber/latex
	name = "latex sheet"
	desc = "A sheet of latex."
	icon_state = "latex"

	setup_material()
		src.setMaterial(getMaterial("latex"), appearance = 0, setname = 0)
		src.create_reagents(10)
		reagents.add_reagent("rubber", 10)
		return ..()

/obj/item/material_piece/organic/wood
	name = "wooden log"
	desc = "Years of genetic engineering mean timber always comes in mostly perfectly shaped cylindrical logs."
	icon_state = "log"
	setup_material()
		src.setMaterial(getMaterial("wood"), appearance = 0, setname = 0)
		..()
	attackby(obj/item/W as obj, mob/user as mob)
		if ((istool(W, TOOL_CUTTING | TOOL_SAWING)))
			user.visible_message("[user] cuts [src] into a plank.", "You cut the [src] into a plank.")
			var/obj/item/plankobj = new /obj/item/plank(user.loc)
			plankobj.setMaterial(getMaterial("wood"), appearance = 0, setname = 0)
			qdel (src)

/obj/item/material_piece/organic/bamboo
	name = "bamboo stalk"
	desc = "Keep away from Space Pandas."
	icon_state = "bamboo"
	setup_material()
		src.setMaterial(getMaterial("bamboo"), appearance = 0, setname = 0)
		..()
	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/axe) || istype(W, /obj/item/circular_saw) || istype(W, /obj/item/kitchen/utensil/knife) || istype(W, /obj/item/scalpel) || istype(W, /obj/item/sword) || istype(W,/obj/item/saw) || istype(W,/obj/item/knife/butcher))
			user.visible_message("[user] carefully extracts a shoot from [src].", "You carefully cut a shoot from [src].")
			new /obj/item/reagent_containers/food/snacks/plant/bamboo/(user.loc)
			qdel (src)

/obj/item/material_piece/cloth/spidersilk
	name = "space spider silk"
	desc = "space silk produced by space dwelling space spiders. space."
	icon_state = "spidersilk"
	setup_material()
		src.setMaterial(getMaterial("spidersilk"), appearance = 0, setname = 0)
		..()

/obj/item/material_piece/cloth/leather
	name = "leather"
	desc = "leather made from the skin of some sort of space critter."
	icon_state = "leather"
	setup_material()
		src.setMaterial(getMaterial("leather"), appearance = 0, setname = 0)
		..()

/obj/item/material_piece/cloth/synthleather
	name = "synthleather"
	desc = "A type of artificial leather."
	icon_state = "synthleather"
	setup_material()
		src.setMaterial(getMaterial("synthleather"), appearance = 0, setname = 0)
		..()

/obj/item/material_piece/cloth/cottonfabric
	name = "cotton fabric"
	desc = "A type of natural fabric."
	icon_state = "fabric"
	setup_material()
		src.setMaterial(getMaterial("cotton"), appearance = 0, setname = 0)
		..()

/obj/item/material_piece/cloth/wendigohide
	name = "wendigo hide"
	desc = "The hide of a wendigo."
	icon_state = "wendigohide"
	setup_material()
		src.setMaterial(getMaterial("wendigohide"), appearance = 0, setname = 0)
		..()

/obj/item/material_piece/cloth/kingwendigohide
	name = "king wendigo hide"
	desc = "The hide of a king wendigo."
	icon_state = "wendigohide"
	setup_material()
		src.setMaterial(getMaterial("kingwendigohide"), appearance = 0, setname = 0)
		..()

/obj/item/material_piece/cloth/carbon
	name = "carbon nano fibre fabric"
	desc = "carbon based hi-tech material."
	icon_state = "carbonfibre"
	setup_material()
		src.setMaterial(getMaterial("carbonfibre"), appearance = 0, setname = 0)
		..()

/obj/item/material_piece/cloth/dyneema
	name = "dyneema fabric"
	desc = "carbon nanofibres and space spider silk!"
	icon_state = "dyneema"
	setup_material()
		src.setMaterial(getMaterial("dyneema"), appearance = 0, setname = 0)
		..()

/obj/item/material_piece/cloth/hauntium
	name = "hauntium fabric"
	desc = "This cloth seems almost alive."
	icon_state = "dyneema"

	setup_material()
		src.setMaterial(getMaterial("hauntium"), appearance = 1, setname = 0)
		..()

/obj/item/material_piece/cloth/beewool
	name = "bee wool"
	desc = "Some bee wool."
	icon_state = "beewool"
	setup_material()
		src.setMaterial(getMaterial("beewool"), appearance = 0, setname = 0)
		..()

/obj/item/material_piece/soulsteel
	name = "soulsteel bar"
	desc = "A bar of soulsteel. Metal made from souls."
	icon_state = "soulsteel"
	setup_material()
		src.setMaterial(getMaterial("soulsteel"), appearance = 0, setname = 0)
		..()

/obj/item/material_piece/bone
	name = "bits of bone"
	desc = "some bits and pieces of bones."
	icon_state = "scrap3"
	setup_material()
		src.setMaterial(getMaterial("bone"), appearance = 0, setname = 0)
		..()

/obj/item/material_piece/gnesis
	name = "gnesis wafer"
	desc = "A warm, pulsing block of weird alien computer crystal stuff."
	icon_state = "gnesis"
	setup_material()
		src.setMaterial(getMaterial("gnesis"), appearance = 0, setname = 0)
		..()

/obj/item/material_piece/gnesisglass
	name = "gnesisglass wafer"
	desc = "A shimmering, transclucent block of weird alien computer crystal stuff."
	icon_state = "gnesisglass"
	setup_material()
		src.setMaterial(getMaterial("gnesisglass"), appearance = 0, setname = 0)
		..()

/obj/item/material_piece/coral
	name = "coral"
	desc = "A piece of coral. Nice!"
	icon_state = "coral"
	setup_material()
		src.setMaterial(getMaterial("coral"), appearance = 0, setname = 0)
		..()

/obj/item/material_piece/neutronium
	name = "neutronium"
	desc = "Neutrons condensed into a solid form."
	icon_state = "bar"
	setup_material()
		src.setMaterial(getMaterial("neutronium"), appearance = 0, setname = 0)
		..()
