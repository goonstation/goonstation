// HATS. OH MY WHAT A FINE CHAPEAU, GOOD SIR.

/obj/item/clothing/head
	name = "hat"
	desc = "For your head!"
	icon = 'icons/obj/clothing/item_hats.dmi'
	wear_image_icon = 'icons/mob/clothing/head.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_headgear.dmi'
	body_parts_covered = HEAD
	compatible_species = list("human", "cow", "werewolf", "flubber", "martian", "blob")
	wear_layer = MOB_HEAD_LAYER2
	var/seal_hair = 0 // best variable name I could come up with, if 1 it forms a seal with a suit so no hair can stick out
	block_vision = 0
	var/team_num
	var/blocked_from_petasusaphilic = FALSE //Replacing the global blacklist
	duration_remove = 1.5 SECONDS
	duration_put = 1.5 SECONDS

	setupProperties()
		..()
		setProperty("coldprot", 10)
		setProperty("heatprot", 5)
		setProperty("meleeprot_head", 1)

proc/filter_trait_hats(var/type)
	var/obj/item/clothing/head/coolhat = type
	return !initial(coolhat.blocked_from_petasusaphilic)

/obj/item/clothing/head/red
	desc = "A knit cap in red."
	icon_state = "red"
	item_state = "rgloves"

/obj/item/clothing/head/blue
	desc = "A knit cap in blue."
	icon_state = "blue"
	item_state = "blugloves"

/obj/item/clothing/head/yellow
	desc = "A knit cap in yellow."
	icon_state = "yellow"
	item_state = "ygloves"

/obj/item/clothing/head/pink
	desc = "A knit cap in pink."
	icon_state = "pink"
	item_state = "pgloves"

/obj/item/clothing/head/orange
	desc = "A knit cap in orange."
	icon_state = "orange"
	item_state = "ogloves"

/obj/item/clothing/head/purple
	desc = "A knit cap in purple."
	icon_state = "purple"
	item_state = "jgloves"

/obj/item/clothing/head/dolan
	name = "Dolan's hat"
	desc = "A plsing hat."
	icon_state = "dolan"
	item_state = "dolan"

/obj/item/clothing/head/green
	desc = "A knit cap in green."
	icon_state = "green"
	item_state = "ggloves"

/obj/item/clothing/head/black
	desc = "A knit cap in black."
	icon_state = "black"
	item_state = "swat_gl"

/obj/item/clothing/head/white
	desc = "A knit cap in white."
	icon_state = "white"
	item_state = "lgloves"

/obj/item/clothing/head/psyche
	desc = "A knit cap in...what the hell?"
	icon_state = "psyche"
	item_state = "bgloves"

/obj/item/clothing/head/serpico
	icon_state = "serpico"
	item_state = "serpico"

/obj/item/clothing/head/bio_hood
	name = "bio hood"
	icon_state = "bio"
	item_state = "bio_hood"
	c_flags = COVERSEYES | COVERSMOUTH | BLOCKCHOKE
	hides_from_examine = C_EARS

	desc = "This hood protects you from harmful biological contaminants."
	seal_hair = 1

	setupProperties()
		..()
		setProperty("heatprot", 10)
		setProperty("viralprot", 50)
		setProperty("chemprot", 30)
		setProperty("meleeprot_head", 1)
		setProperty("disorient_resist_eye", 5)
		setProperty("disorient_resist_ear", 2)
		setProperty("movespeed", 0.1)

/obj/item/clothing/head/bio_hood/janitor // adhara stuff
	name = "bio hood"
	desc = "This hood protects you from harmful biological contaminants. This one has a purple visor."
	icon_state = "bio_jani"
	item_state = "bio_jani"

/obj/item/clothing/head/bio_hood/nt
	name = "NT bio hood"
	icon_state = "ntbiohood"
	setupProperties()
		..()
		setProperty("meleeprot_head", 2)

/obj/item/clothing/head/emerg
	name = "emergency hood"
	icon_state = "emerg"
	item_state = "emerg"
	c_flags = SPACEWEAR | COVERSEYES | COVERSMOUTH | BLOCKCHOKE
	desc = "Helps protect from vacuum for a short period of time."
	hides_from_examine = C_EARS|C_MASK|C_GLASSES
	seal_hair = 1
	acid_survival_time = 3 MINUTES

	setupProperties()
		..()
		setProperty("chemprot", 15)
		setProperty("disorient_resist_eye", 9)
		setProperty("disorient_resist_ear", 5)
		setProperty("space_movespeed", 0.5)

/obj/item/clothing/head/emerg/science
	name = "bomb retreival hood"
	desc = "A suit that protects against low pressure environments for a short time. Given to science since they blew up the more expensive ones."
	// TODO science colours sprite for this

/obj/item/clothing/head/rad_hood
	name = "Class II radiation hood"
	icon_state = "radiation"
	c_flags = COVERSEYES | COVERSMOUTH | BLOCKCHOKE
	hides_from_examine = C_EARS
	desc = "Asbestos, right near your face. Perfect!"
	seal_hair = 1

	setupProperties()
		..()
		setProperty("radprot", 50)
		setProperty("heatprot", 10)
		setProperty("meleeprot_head", 1)
		setProperty("chemprot", 10)
		setProperty("disorient_resist_eye", 12)
		setProperty("disorient_resist_ear", 8)
		setProperty("movespeed", 0.1)

/obj/item/clothing/head/cakehat
	name = "cakehat"
	desc = "It is a cakehat"
	icon_state = "cakehat0"
	var/status = 0
	var/processing = 0
	c_flags = COVERSEYES
	var/fire_resist = T0C+1300	//this is the max temp it can stand before you start to cook. although it might not burn away, you take damage
	var/datum/light/light
	var/on = 0

	New()
		..()
		light = new /datum/light/point
		light.set_brightness(0.6)
		light.set_height(1.8)
		light.set_color(0.94, 0.69, 0.27)
		light.attach(src)

	pickup(mob/user)
		..()
		light.attach(user)

	dropped(mob/user)
		..()
		SPAWN(0)
			if (src.loc != user)
				light.attach(src)

	attack_self(mob/user)
		src.flashlight_toggle(user)
		return

	proc/flashlight_toggle(var/mob/user, var/force_on = 0)
		if (!src || !user || !ismob(user)) return

		if (status > 1)
			return

		if (force_on)
			src.on = 1
		else
			src.on = !src.on

		if (src.on)
			src.firesource = FIRESOURCE_OPEN_FLAME
			src.force = 10
			src.hit_type = DAMAGE_BURN
			src.icon_state = "cakehat1"
			tooltip_rebuild = 1
			light.enable()
			c_flags |= SPACEWEAR
			processing_items |= src
		else
			src.firesource = FALSE
			src.force = 3
			c_flags &= ~SPACEWEAR
			tooltip_rebuild = 1
			src.hit_type = DAMAGE_BLUNT
			src.icon_state = "cakehat0"
			light.disable()

		user.update_clothing()
		src.add_fingerprint(user)
		return

	process()
		if (!src.on)
			processing_items.Remove(src)
			return

		var/turf/location = src.loc
		if (ishuman(location))
			var/mob/living/carbon/human/M = location
			if (M.l_hand == src || M.r_hand == src || M.head == src)
				location = M.loc

		if (istype(location, /turf))
			location.hotspot_expose(700, 1)
		return

	afterattack(atom/target, mob/user as mob)
		if (src.on && !ismob(target) && target.reagents)
			boutput(user, SPAN_NOTICE("You heat \the [target.name]."))
			target.reagents.temperature_reagents(4000,10)
		return

/obj/item/clothing/head/caphat
	name = "Captain's hat"
	icon_state = "captain"
	item_state = "caphat"
	desc = "A symbol of the captain's rank, and the source of all their power."
	setupProperties()
		..()
		setProperty("meleeprot_head", 4)

/obj/item/clothing/head/bigcaphat
	name = "Captain of Captain's hat"
	icon_state = "captainbig"
	item_state = "caphat"
	desc = "A symbol of the captain's rank, signifying they're the greatest captain, and the source of all their power."
	setupProperties()
		..()
		setProperty("meleeprot_head", 6)


/obj/item/clothing/head/centhat
	name = "Cent. Comm. hat"
	icon_state = "centcom"
	item_state = "centcom"
	setupProperties()
		..()
		setProperty("meleeprot_head", 4)

	red
		icon_state = "centcom-red"
		item_state = "centcom-red"

/obj/item/clothing/head/sea_captain
	desc = "A dashing white sea captain's hat. Probably blown off of some poor sod's head in a storm."
	icon_state = "sea_captain"
	item_state = "sea_captain"

	comm_officer_hat //Need the same hat but with different description
		desc = "Hat that is awarded to only the finest navy officers. And a few others."

/obj/item/clothing/head/det_hat
	name = "Detective's hat"
	desc = "Someone who wears this will look very smart."
	icon_state = "detective"
	item_state = "det_hat"
	setupProperties()
		..()
		setProperty("meleeprot_head", 3)

/obj/item/clothing/head/det_hat/inspector
	name = "inspector's hat"
	desc = "Someone who wears this will look very mysterious."
	icon_state = "inspector"
	item_state = "ins_hat"

//A robot in disguise, ready to go and spy on everyone for you
/obj/item/clothing/head/det_hat/folded_scuttlebot
	blocked_from_petasusaphilic = TRUE
	var/inspector = FALSE
	desc = "Someone who wears this will look very smart. It looks a bit heavier than it should."

	attack_self (mob/user as mob)
		if(!(src in user.equipped_list())) //lagspikes can allow a doubleinput here. or something
			return
		user.visible_message(SPAN_COMBAT("<b>[user] turns [his_or_her(user)] detgadget hat into a spiffy scuttlebot!</b>"))
		var/mob/living/critter/robotic/scuttlebot/S = new /mob/living/critter/robotic/scuttlebot(get_turf(src))
		if (src.inspector == TRUE)
			S.make_inspector()
		S.linked_hat = src
		user.drop_item()
		src.set_loc(S)
		user.update_inhands()
		return

	setupProperties()
		..()
		setProperty("meleeprot_head", 5)


	proc/make_inspector()
		src.inspector = TRUE
		src.icon_state = "inspector"

//THE ONE AND ONLY.... GO GO GADGET DETECTIVE HAT!!!
/obj/item/clothing/head/det_hat/gadget
	name = "DetGadget hat"
	desc = "Detective's special hat you can outfit with various items for easy retrieval!"
	var/phrase = "go go gadget"

	var/list/items

	var/max_cigs = 15
	var/list/cigs
	var/inspector = FALSE // If the hat has been turned into an inspector's hat from the medal reward

	New()
		..()
		items = list("bodybag" = /obj/item/body_bag,
									"scanner" = /obj/item/device/detective_scanner,
									"lighter" = /obj/item/device/light/zippo/,
									"spray" = /obj/item/spraybottle,
									"monitor" = /obj/item/device/camera_viewer,
									"camera" = /obj/item/camera,
									"audiolog" = /obj/item/device/audio_log ,
									"flashlight" = /obj/item/device/light/flashlight,
									"glasses" = /obj/item/clothing/glasses)
		cigs = list()
	examine()
		. = ..()
		. += SPAN_NOTICE("Current activation phrase is <b>\"[phrase]\"</b>.")
		for (var/name in items)
			var/type = items[name]
			var/obj/item/I = locate(type) in contents
			if(I)
				. += "<br>[SPAN_NOTICE("[bicon(I)][I] is ready and bound to the word \"[name]\"!")]"
			else
				. += "<br>There is no [name]!"
		if (cigs.len)
			. += "<br>[SPAN_NOTICE("It contains <b>[cigs.len]</b> cigarettes!")]"

	hear_talk(mob/M as mob, msg, real_name, lang_id)
		var/turf/T = get_turf(src)
		if (M in range(1, T))
			src.talk_into(M, msg, null, real_name, lang_id)

	talk_into(mob/M as mob, messages, param, real_name, lang_id)
		var/gadget = findtext(messages[1], src.phrase) //check the spoken phrase
		if(gadget)
			gadget = replacetext(copytext(messages[1], gadget + length(src.phrase)), " ", "") //get rid of spaces as well
			for (var/name in items)
				var/type = items[name]
				var/obj/item/I = locate(type) in contents
				if(findtext(gadget, name) && I)
					M.put_in_hand_or_drop(I)
					M.visible_message(SPAN_ALERT("<b>[M]</b>'s hat snaps open and pulls out \the [I]!"))
					return

			if(findtext(gadget, "cigarette"))
				if (!cigs.len)
					M.show_text("You're out of cigs, shit! How you gonna get through the rest of the day?", "red")
					return
				else
					var/obj/item/clothing/mask/cigarette/W = cigs[cigs.len] //Grab the last cig entry
					cigs.Cut(cigs.len) //Get that cig outta there
					var/boop = "hand"
					if(ishuman(M))
						var/mob/living/carbon/human/H = M
						if (H.equip_if_possible(W, SLOT_WEAR_MASK))
							boop = "mouth"
						else
							H.put_in_hand_or_drop(W) //Put it in their hand
					else
						M.put_in_hand_or_drop(W) //Put it in their hand

					M.visible_message(SPAN_ALERT("<b>[M]</b>'s hat snaps open and puts \the [W] in [his_or_her(M)] [boop]!"))
					var/obj/item/device/light/zippo/lighter = (locate(/obj/item/device/light/zippo) in src.contents)
					if (lighter)
						W.light(M, SPAN_ALERT("<b>[M]</b>'s hat proceeds to light \the [W] with \the [lighter], whoa."))
						lighter.firesource_interact()
			else
				M.show_text("Requested object missing or nonexistant!", "red")
				return

	attackby(obj/item/W, mob/M)
		var/success = 0
		for (var/name in items)
			var/type = items[name]
			if(istype(W, type) && !(locate(type) in contents))
				success = 1
				M.drop_item()
				W.set_loc(src)
				break
		if (length(cigs) < src.max_cigs && istype(W, /obj/item/clothing/mask/cigarette)) //cigarette
			success = 1
			M.drop_item()
			W.set_loc(src)
			cigs.Add(W)
		if (length(cigs) < src.max_cigs && istype(W, /obj/item/cigpacket)) //cigarette packet
			var/obj/item/cigpacket/packet = W
			if(length(packet.contents) == 0)
				M.show_text("Oh no! There's no more cigs in [packet]!", "red")
				return
			else
				var/count = length(packet.contents)
				for(var/i=0, i<count, i++)
					if(length(cigs) >= src.max_cigs)
						M.show_text("The [src] has been totally filled with cigarettes!", "red")
						break
					var/obj/item/clothing/mask/cigarette/C = packet.contents[1]
					C.set_loc(src)
					cigs.Add(C)
					packet.UpdateIcon()
				success = 1

		if(success)
			M.visible_message(SPAN_ALERT("<b>[M]</b> [pick("awkwardly", "comically", "impossibly", "cartoonishly")] stuffs [W] into [src]!"))
			return

		return ..()

	attack_self (mob/user as mob)
		if(!(src in user.equipped_list())) //lagspikes can allow a doubleinput here. or something
			return
		user.visible_message(SPAN_COMBAT("<b>[user] turns [his_or_her(user)] detgadget hat into a spiffy scuttlebot!</b>"))
		var/mob/living/critter/robotic/scuttlebot/weak/S = new /mob/living/critter/robotic/scuttlebot/weak(get_turf(src))
		if (src.inspector == TRUE)
			S.make_inspector()
		S.linked_hat = src
		user.drop_item()
		src.set_loc(S)
		user.update_inhands()
		return

	verb/set_phrase()
		set name = "Set Activation Phrase"
		set desc = "Change the activation phrase for the DetGadget hat!"
		set category = "Local"

		set src in usr
		var/n_name = input(usr, "What would you like to set the activation phrase to?", "Activation Phrase", null) as null|text
		if (!n_name)
			return
		n_name = copytext(html_encode(n_name), 1, 32)
		if (((src.loc == usr || (src.loc && src.loc.loc == usr)) && isalive(usr)))
			src.phrase = n_name
			logTheThing(LOG_SAY, usr, "sets the activation phrase on DetGadget hat: [n_name]")
		src.add_fingerprint(usr)

	proc/make_inspector()
		src.inspector = TRUE
		src.icon_state = "inspector"

/obj/item/clothing/head/powdered_wig
	name = "powdered wig"
	desc = "A judicial-looking wig, covered with a starchy powder to reflect the inner stiffness of those who wear it. Or to make it white."
	icon_state = "pwig"
	item_state = "pwig"

/obj/item/clothing/head/that
	name = "hat"
	desc = "A stylish, flat-topped hat often worn as formalwear. Rumored to inhibit lying in those that wear it."
	icon_state = "tophat"
	item_state = "that"

/obj/item/clothing/head/that/purple
	name = "purple hat"
	desc = "A stylish, flat-topped hat often worn as formalwear. This one is a daring shade of purple."
	icon_state = "ptophat"
	item_state = "pthat"
	protective_temperature = 500

	setupProperties()
		..()
		setProperty("coldprot", 15)
		setProperty("heatprot", 5)

TYPEINFO(/obj/item/clothing/head/that/gold)
	mat_appearances_to_ignore = list("gold") // we already look fine ty
/obj/item/clothing/head/that/gold
	name = "golden hat"
	desc = "A golden tophat."
	icon_state = "gtophat"
	item_state = "gthat"
	protective_temperature = 500
	mat_changename = 0

	setupProperties()
		..()
		setProperty("coldprot", 15)
		setProperty("heatprot", 5)

	New()
		..()
		src.setMaterial(getMaterial("gold"))

/obj/item/clothing/head/longtophat
	name = "long tophat"
	desc = "When you look at this hat you can only think of how many monkeys you could fit in it."
	icon_state = "ltophat"
	item_state = "lthat"

/obj/item/clothing/head/chefhat
	name = "Chef's hat"
	desc = "Your toque blanche, coloured as such so that your poor sanitation is obvious, and the blood shows up nice and crazy."
	icon_state = "chef"
	item_state = "chefhat"

	april_fools
		icon_state = "chef-alt"
		item_state = "chefhat-alt"

/obj/item/clothing/head/chefhatpuffy
	name = "Puffy Chef's Hat"
	desc = "A chef's toque blanche, pleasantly puffy on top."
	icon_state = "chef-puffy"
	item_state = "chefhat"
	wear_state = "chef-puffy"

/obj/item/clothing/head/souschefhat
	name = "Sous-Chef's hat"
	icon_state = "souschef"
	item_state = "chefhat" //TODO: unique inhand sprite?

/obj/item/clothing/head/itamaehat
	name = "Itamae hat"
	desc = "A hat commonly worn by Japanese Chefs. Itamae translates literally to \"In front of the board\"."
	icon_state = "itamae"
	item_state = "itamae"

/obj/item/clothing/head/dramachefhat
	name = "Dramatic Chef's Hat"
	icon_state = "drama"
	item_state = "chefhat" //TODO: unique inhand sprite?

/obj/item/clothing/head/mailcap
	name = "postmaster's hat"
	desc = "The hat of a postmaster."
	icon_state = "mailcap"
	item_state = "mailcap"

	april_fools
		icon_state = "mailcap-alt"
		item_state = "mailcap-alt"

/obj/item/clothing/head/chefhattall
    name = "Tall Chef's Hat"
    desc = "Your toque blanche, now at least 50% taller!"
    icon_state = "cheftall"
    item_state = "cheftall"

/obj/item/clothing/head/plunger
	name = "plunger"
	desc = "get dat fukken clog"
	icon_state = "plunger"
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	item_state = "plunger"
	setupProperties()
		..()
		setProperty("meleeprot_head", 2)

	unequipped(mob/user)
		..()
		if(ON_COOLDOWN(src, "plunger_sound", 2 SECONDS)) return
		playsound(src.loc, 'sound/items/plunger_pop.ogg', 100, 1)
		return


	equipped(var/mob/user, var/slot)
		..()
		if(ON_COOLDOWN(src, "plunger_sound", 2 SECONDS)) return
		playsound(src.loc, 'sound/items/plunger_pop.ogg', 100, 1)

/obj/item/clothing/head/hosberet
	name = "HoS Beret"
	desc = "This makes you feel like Che Guevara."
	icon_state = "hosberet"
	item_state = "hosberet"
	setupProperties()
		..()
		setProperty("meleeprot_head", 3)

/obj/item/clothing/head/NTberet
	name = "Nanotrasen beret"
	desc = "For the inner space dictator in you."
	icon_state = "ntberet"
	item_state = "ntberet"

/obj/item/clothing/head/NTberet/commander
	name = "Nanotrasen beret"
	desc = "For the inner space commander in you."
	icon_state = "ntberet_commander"
	item_state = "ntberet_commander"
	team_num = TEAM_NANOTRASEN
	#ifdef MAP_OVERRIDE_POD_WARS
	attack_hand(mob/user)
		if (get_pod_wars_team_num(user) == team_num)
			..()
		else
			boutput(user, SPAN_ALERT("The beret <b>explodes</b> as you reach out to grab it!"))
			make_fake_explosion(src)
			user.u_equip(src)
			src.dropped(user)
			qdel(src)
	#endif
	c_flags = SPACEWEAR

	setupProperties()
		..()
		setProperty("coldprot", 20)
		setProperty("heatprot", 5)
		setProperty("meleeprot_head", 4)

/obj/item/clothing/head/XComHair
	name = "rookie scalp"
	desc = "Some unfortunate soldier's charred scalp. The hair is intact."
	icon_state = "xcomhair"
	item_state = "xcomhair"

/obj/item/clothing/head/apprentice
	name = "Apprentice's cap"
	desc = "Legends tell about space sorcerors taking on apprentices. Such apprentices would wear a magical cap, and this is one such ite- hey! This is just a cardboard cone with wrapping paper on it!"
	icon_state = "apprentice"
	item_state = "apprentice"

	dan
		name = "Royal Apprentice's Cap"
		desc = "Part of a collaboration between Dastardly Dan's and Zoldorf Co."
		icon_state = "dan_apprentice"
		item_state = "dan_apprentice"

/obj/item/clothing/head/snake
	name = "dirty rag"
	desc = "A rag that looks like it was dragged through the jungle. Yuck."
	icon_state = "snake"
	item_state = "snake"

// Chaplain Hats

/obj/item/clothing/head/rabbihat
	name = "rabbi's hat"
	desc = "Complete with peyois. Perfect for Purim!"
	icon_state = "rabbihat"
	item_state = "that"

/obj/item/clothing/head/nunhood
	name = "nun hood"
	desc = "A black hood with white adornment, typically worn by nuns. Wearing this does not give enhanced singing capabilities."
	icon_state = "nun_hood"
	item_state = "nun_hood"

/obj/item/clothing/head/formal_turban
	name = "formal turban"
	desc = "A very stylish formal turban."
	icon_state = "formal_turban"
	item_state = "egg5"

	setupProperties()
		..()
		setProperty("coldprot", 15)
		setProperty("heatprot", 10)

/obj/item/clothing/head/turban
	name = "turban"
	desc = "A very comfortable cotton turban."
	icon_state = "turban"
	item_state = "that"

	setupProperties()
		..()
		setProperty("coldprot", 15)
		setProperty("heatprot", 10)

/obj/item/clothing/head/rastacap
	name = "rastafarian cap"
	desc = "Comes with pre-attached dreadlocks for that authentic look."
	icon_state = "rastacap"
	item_state = "that"

/obj/item/clothing/head/fedora
	name = "fedora"
	desc = "Tip your fedora to the fair maiden and win her heart. A foolproof plan."
	icon_state = "fdora"
	item_state = "fdora"

	New()
		..()
		src.name = "[pick("fancy", "suave", "manly", "sectacular", "intellectual", "majestic", "euphoric")] fedora"

/obj/item/clothing/head/cowboy
	name = "cowboy hat"
	desc = "Yeehaw!"
	icon_state = "cowboy"
	item_state = "cowboy"

/obj/item/clothing/head/longbee
	name = "Longbee"
	desc = "A gorgeous creature now on your head!"
	hides_from_examine = C_EARS
	icon_state = "longbee"
	item_state = "longbee"

/obj/item/clothing/head/fancy // placeholder icons until someone sprites an actual fancy hat
	name = "fancy hat"
	icon_state = "rank-fancy"
	item_state = "that"  // todo actual inhands for this and children ?
	desc = "What do you mean this is hat isn't fancy?"

/obj/item/clothing/head/fancy/captain
	name = "Captain's hat"
	icon_state = "captain-fancy"
	setupProperties()
		..()
		setProperty("meleeprot_head", 3)

/obj/item/clothing/head/fancy/rank
	name = "Officer's hat"
	icon_state = "rank-fancy"
	setupProperties()
		..()
		setProperty("meleeprot_head", 3)

/obj/item/clothing/head/wizard
	name = "blue wizard hat"
	desc = "A slightly crumply and foldy blue hat. Every self-respecting Wizard has one of these."
	icon_state = "wizard"
	item_state = "wizard"
	magical = 1
	item_function_flags = IMMUNE_TO_ACID
	duration_remove = 10 SECONDS

	setupProperties()
		..()
		setProperty("disorient_resist_eye", 15)
		setProperty("disorient_resist_ear", 15)

/obj/item/clothing/head/wizard/red
	name = "red wizard hat"
	desc = "An elegant red hat with some nice gold trim on it."
	icon_state = "wizardred"
	item_state = "wizardred"

/obj/item/clothing/head/wizard/purple
	name = "purple wizard hat"
	desc = "A very nice purple hat with a big, sassy buckle on it!"
	icon_state = "wizardpurple"
	item_state = "wizardpurple"

/obj/item/clothing/head/wizard/green
	name = "green wizard hood"
	desc = "A green hood, full of magic, wonder, cromulence, and maybe a spider or two."
	icon_state = "wizardgreen"
	item_state = "wizardgreen"
	seal_hair = 1

/obj/item/clothing/head/wizard/witch
	name = "witch hat"
	desc = "Broomstick and cat not included."
	icon_state = "witch"
	item_state = "wizardnec"

/obj/item/clothing/head/wizard/necro
	name = "necromancer hood"
	desc = "Good god, this thing STINKS. Is that mold on the inner lining? Ugh."
	icon_state = "wizardnec"
	item_state = "wizardnec"
	see_face = FALSE
	seal_hair = 1
	hides_from_examine = C_EARS|C_MASK|C_GLASSES

/obj/item/clothing/head/pinkwizard //no magic properties
	name = "pink wizard hat"
	desc = "A pink wizard hat. Must've been a reject from the assembly line."
	icon_state = "wizardpink"

/obj/item/clothing/head/paper_hat
	name = "paper hat"
	desc = "It's a paper hat!"
	icon_state = "paper"
	item_state = "lgloves"
	see_face = TRUE
	body_parts_covered = HEAD

/obj/item/paper_hat/attackby(obj/item/W, mob/user)
	if (istype(W, /obj/item/pen))
		var/obj/item/pen/P = W
		if (P.font_color)
			boutput(user, SPAN_NOTICE("You scribble on the hat until it's filled in."))
			if (P.font_color)
				src.color = P.font_color
				src.desc = "A colorful paper hat"

/obj/item/clothing/head/tinfoil_hat
	name = "tinfoil hat"
	desc = "Protects the wearer from mindcontrol and, apparently, weak martian psychic blasts which do not involve the liquification of brains."
	icon_state = "tinfoil"
	item_state = "tinfoil"

/obj/item/clothing/head/towel_hat
	name = "towel hat"
	desc = "A white towel folded all into a fancy hat. NOT a turban!" // @;)
	icon_state = "towelhat"
	item_state = "lgloves"
	see_face = TRUE
	body_parts_covered = HEAD

/obj/item/clothing/head/crown
	name = "crown"
	desc = "Yeah, big deal, you got a fancy crown, what does that do for you against the <b>HORRORS OF SPACE</b>, tough guy?"
	icon_state = "crown"
	see_face = TRUE
	body_parts_covered = HEAD
	setupProperties()
		..()
		setProperty("meleeprot_head", 3)

/obj/item/clothing/head/DONOTSTEAL
	desc = "Baby's first hat ALSO BY ME WRONGEND DON'T STEAL" // You are a fucking disgrace hat HOW DID YOU BREAK HELMET CODE AND MAKE THE RSC NOT WORK FUCK please kill me please kill me please kill me please kill me please kill me please kill me please kill me please kill me please kill me please kill me please kill me please kill me please kill me please kill me please kill me please kill me please kill me please kill me
	icon_state = "WRONGEND_HAT"
	item_state = "WRONGEND_HAT"

/obj/item/clothing/head/oddjob // by cyberTripping
	name = "odd hat"
	desc = "Looking sharp."
	icon_state = "mime_bowler"
	item_state = "that"
	hitsound = 'sound/impact_sounds/Generic_Hit_1.ogg'
	var/active = 0
	throw_return = 1
	throw_speed = 1
	var/turf/throw_source = null

	attack_self (mob/user as mob)
		user.visible_message(SPAN_COMBAT("<b>[user] fiddles with [src]!</b>"))
		sleep(1 SECOND)
		src.toggle_active(user)
		user.update_inhands()
		src.add_fingerprint(user)
		return

	proc/toggle_active(mob/user)
		src.active = !( src.active )
		if (src.active)
			if (user)
				user.visible_message(SPAN_COMBAT("<b>Blades extend from the brim of [user]'s hat!</b>"))
			src.hit_type = DAMAGE_CUT
			src.hitsound = 'sound/impact_sounds/Flesh_Cut_1.ogg'
			src.force = 10
			src.icon_state = "oddjob"
			src.throw_source = null
		else
			if (user)
				user.visible_message(SPAN_NOTICE("<b>[user]'s hat's blades retract.</b>"))
			src.hit_type = DAMAGE_BLUNT
			src.hitsound = 'sound/impact_sounds/Generic_Hit_1.ogg'
			src.force = 1
			src.icon_state = "mime_bowler"
			src.throw_source = null
		return

	throw_begin(atom/target)
		src.throw_source = get_turf(src)
		..()

	throw_impact(atom/hit_atom, datum/thrown_thing/thr)
		if (src.active && ismob(hit_atom))
			var/mob/M = hit_atom
			playsound(src, src.hitsound, 60, 1)
			M.changeStatus("knockdown", 2 SECONDS)
			M.force_laydown_standup()
			SPAWN(0) // show these messages after the "hit by" ones
				if (M)
					if (ishuman(M) && M.health < -10)
						var/mob/living/carbon/human/H = M
						var/obj/item/organ/head/the_head = H.drop_organ("head")
						if (istype(the_head))
							H.visible_message(SPAN_COMBAT("<b>[H]'s head flies right off [his_or_her(H)] shoulders![prob(33) ? " HOLY SHIT!" : null]</b>"))
							var/the_dir = src.last_move ? src.last_move : alldirs//istype(src.throw_source) ? get_dir(src.throw_source, H) : alldirs
							the_head.streak_object(the_dir, the_head.created_decal)
							src.throw_source = null
					else
						M.TakeDamageAccountArmor("chest", 10, 0)
						take_bleeding_damage(M, null, 15, src.hit_type)
			src.toggle_active()

		else if (ishuman(hit_atom))
			var/mob/living/carbon/human/Q = hit_atom
			src.toggle_active() // don't show the message when catching because it just kinda spams things up
			Q.visible_message(SPAN_COMBAT("<b>[Q] catches the [src] like a badass.</b>"))
			if (Q.equipped())
				Q.drop_item()
			Q.put_in_hand_or_drop(src)
			src.throw_source = null
			return
		return ..(hit_atom)

	equipped(mob/user, slot)
		. = ..()
		if(slot == SLOT_HEAD)
			user.bioHolder.AddEffect("dwarf")

	unequipped(mob/user)
		if(equipped_in_slot == SLOT_HEAD)
			user.bioHolder.RemoveEffect("dwarf")
		. = ..()

/obj/item/clothing/head/bigtex
	name = "75-gallon hat"
	desc = "A recreation of the late Big Tex's hat, commisioned by Ol' Harner."
	icon_state = "bigtex"
	item_state = "bigtex"
	setupProperties()
		..()
		setProperty("meleeprot_head", 3)

/obj/item/clothing/head/beret
	name = "beret"
	desc = "A blue beret with no affiliations to NanoTrasen."
	icon_state = "beret_base"

	New()
		..()
		src.color = "#002289"

	random_color
		desc = "A colorful beret."

		New()
			..()
			src.color = random_saturated_hex_color(1)

/obj/item/clothing/head/beret/prisoner
	name = "prisoner's beret"
	desc = "This is a prisoner's beret. <i>Allons enfants de la Patrie, Le jour de gloire est arrivé!</i>"

	New()
		..()
		src.color = "#FF8800"

/obj/item/clothing/head/beret/dyeable
	name = "dyeable beret"
	desc = "Can be dyed with hair dye. Obviously."
	icon_state = "beret_base"
	item_state = "dye_beret"

	New()
		..()
		src.color = "#FFFFFF"

	attackby(obj/item/dye_bottle/W, mob/user)
		if (istype(W, /obj/item/dye_bottle))
			src.color = W.customization_first_color
			src.UpdateIcon()
			var/mob/wearer = src.loc
			if (istype(wearer))
				wearer.update_clothing()
			user.visible_message(SPAN_ALERT("<b>[user]</b> splashes dye on [user != wearer && ismob(wearer) ? "[wearer]'s" : his_or_her(user)] beret."))
			return
		. = ..()

/obj/item/clothing/head/beret/syndicate
	name = "syndicate beret"
	desc = "A dastardly beret for only the most cunning of operatives."
	icon_state = "syndieberet"

	New()
		..()
		src.color = null

/obj/item/clothing/head/bandana
	name = "bandana"
	desc = "A bandana. You've seen space action stars wear these things."
	icon_state = "bandana_base"

	random_color
		desc = "A colorful bandana."

		New()
			..()
			src.color = random_saturated_hex_color(1)

	red
		name = "red bandana"
		desc = "A red bandana, colored by blood, sweat, and tears."
		icon_state = "bandana_red"

/obj/item/clothing/head/laurels
	name = "laurels"
	desc = "Symbols of victory and achievement."
	icon_state = "laurels"
	setupProperties()
		..()
		setProperty("meleeprot_head", 3)

	gold
		name = "gold laurels"
		desc = "Symbols of victory and achievement. These laurels are gold, and therefore extra symbolic and special."
		icon_state = "glaurels"

/obj/item/clothing/head/purplebutt
	name = "purple butt hat"
	desc = "A hat that looks like a purple butt."
	icon_state = "purplebutt"
	c_flags = COVERSEYES

// BIGHATS - taller than normal hats! To a max icon size of 64px

/obj/item/clothing/head/bighat
	name = "large hat"
	desc = "An unnaturally large piece of headwear"
	wear_image_icon = 'icons/mob/clothing/bighat.dmi'
	icon_state = "tophat"
	w_class = W_CLASS_BULKY
	blocked_from_petasusaphilic = TRUE

/obj/item/clothing/head/bighat/syndicate
	name = "syndicate hat"
	desc = "A commitment."
	icon_state = "syndicate_top"
	item_state = "syndicate_top"
	interesting = "It kinda stinks now..."
	c_flags = SPACEWEAR // can't take it off, so may as well make it spaceworthy
	contraband = 10 //let's set off some alarms, boys
	is_syndicate = 1 //no easy replication thanks
	cant_self_remove = 1
	item_function_flags = IMMUNE_TO_ACID //shouldn't be able to just melt the Syndicate Hat.
	var/datum/component/loctargeting/sm_light/light_c
	var/processing = 0

	process()
		var/mob/living/host = src.loc
		if (!istype(host))
			processing_items.Remove(src)
			processing = 0
			return
		if(prob(20) && !istype(src.loc, /obj/cryotron))
			var/turf/T = get_turf(src)
			T?.fluid_react_single("miasma_s", 5, airborne = 1)
		if(prob(1))
			host.real_name = "[prob(10) ? SPACER_PICK("honorifics")+" " : ""][prob(20) ? SPACER_PICK("stuff")+" " : ""][SPACER_PICK("firstnames")+" "][prob(80) ? SPACER_PICK("nicknames")+" " : ""][prob(50)?SPACER_PICK("firstnames") : SPACER_PICK("lastnames")]"
			host.name = host.real_name
			boutput(host, SPAN_NOTICE("You suddenly feel a lot more like, uh, well like [host.real_name]!"))
		if(isdead(host))
			host.visible_message(SPAN_NOTICE("A fun surprise pops out of [host]!"))
			new /obj/item/a_gift/festive(get_turf(src))
			src.unequipped(host)
			host.gib()
			return

	setupProperties()
		..()
		setProperty("meleeprot_head", 6)

	New()
		..()
		light_c = src.AddComponent(/datum/component/loctargeting/sm_light, 0.94 * 255, 0.27 * 255, 0.27 * 255, 240)
		light_c.update(1)

		if (prob(10))
			SPAWN( rand(300, 900) )
				src.visible_message("<b>[src]</b> <i>says, \"I'm the boss.\"</i>")

	unequipped(mob/user)
		..()
		logTheThing(LOG_COMBAT, user, "unequipped [src] at [log_loc(src)].")
		processing_items.Remove(src)
		processing = 0
		return


	equipped(var/mob/user, var/slot)
		..()
		logTheThing(LOG_COMBAT, user, "equipped [src] at [log_loc(src)].")
		if (!src.processing)
			src.processing++
			processing_items |= src
		boutput(user, SPAN_NOTICE("You better start running! It's kill or be killed now, buddy!"))
		SPAWN(1 SECOND)
			playsound(src.loc, 'sound/vox/time.ogg', 100, 1)
			sleep(1 SECOND)
			playsound(src.loc, 'sound/vox/for.ogg', 100, 1)
			sleep(1 SECOND)
			playsound(src.loc, 'sound/vox/crime.ogg', 100, 1)

		// Guess what? you wear the hat, you go to jail. Easy Peasy.
		var/datum/db_record/S = data_core.security.find_record("id", user.datacore_id)
		S?["criminal"] = ARREST_STATE_ARREST
		S?["ma_crim"] = pick("Being unstoppable","Swagging out so hard","Stylin on \'em","Puttin\' in work")
		S?["ma_crim_d"] = pick("Convicted Badass, to the bone.","Certified Turbonerd, home-grown.","Absolute Salad.","King of crimes, Queen of Flexxin\'")
		var/mob/living/carbon/human/H = user
		if (istype(H))
			H.update_arrest_icon()

	custom_suicide = 1
	suicide_in_hand = 0
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		if (ishuman(user))
			var/mob/living/carbon/human/H = user
			if (istype(H.head, /obj/item/clothing/head/bighat/syndicate) && !is_incapacitated(H) && !H.restrained())
				H.visible_message(SPAN_ALERT("<b>[H] is totally and absolutely robusted by the [src.name]!</b>"))
				var/turf/T = get_turf(H)
				T.fluid_react_single("blood",1000)
				H.unequip_all()
				H.gib()

				SPAWN(50 SECONDS)
					if (user && !isdead(user))
						user.suiciding = 0
				//qdel(src)
				return 1
			else
				user.visible_message("[user] contemplates their destiny.")
				user.suiciding = 0
				return 0
		else
			return 0


/obj/item/clothing/head/bighat/syndicate/biggest
	name = "very syndicate hat"
	desc = "An actual war crime, under the space geneva convention"
	icon_state = "syndicate_top_biggest"
	item_state = "syndicate_top"
	contraband = 100 // heh

	suicide(var/mob/user as mob)
		var/turf/T = get_turf(src)
		if (!src.user_can_suicide(user))
			return 0
		if (ishuman(user))
			var/mob/living/carbon/human/H = user
			if (istype(H.head, /obj/item/clothing/head/bighat/syndicate) && !is_incapacitated(H) && !H.restrained())
				H.visible_message(SPAN_NOTICE("<b>[H] becomes one with the [src.name]!</b>"))
				H.gib()
				explosion_new(src, T, 50) // like a really mean double macro

				SPAWN(50 SECONDS)
					if (user && !isdead(user))
						user.suiciding = 0
				qdel(src)
				return 1
			else
				user.visible_message("[user] contemplates their destiny.")
				user.suiciding = 0
				return 0
		else
			return 0

/obj/item/clothing/head/bighat/syndicate/infiniteglory
	name = "The Syndicate Hat"
	desc = "It makes you weep"
	icon = 'icons/mob/clothing/biggestesthat.dmi'
	wear_image_icon = 'icons/mob/clothing/biggestesthat.dmi'
	icon_state = "syndicate_top_TheOne"
	cant_other_remove = TRUE
	cant_drop = TRUE
	anchored = ANCHORED
	contraband = INFINITY // h e h
	rarity = ITEM_RARITY_MYTHIC
	var/obj/machinery/maptext_monitor/health/constantly_overhead/maptext_thingamajig

	setupProperties()
		..() // Syndie gaming
		setProperty("meleeprot_all", 8)
		setProperty("rangedprot", 5)
		setProperty("space_movespeed", -1.25)
		setProperty("disorient_resist", 90)
		setProperty("disorient_resist_eye", 90)
		setProperty("disorient_resist_ear", 75)
		setProperty("exploprot", 75)
		setProperty("chemprot", 75)
		setProperty("stamregen", 10)
		setProperty("deflection", 60)

	proc/change_big_icon_state(var/BIG)
		if(BIG == TRUE)
			src.icon = initial(src.icon)
			src.icon_state = initial(src.icon_state)
		else
			src.icon = 'icons/mob/clothing/bighat.dmi'
			src.icon_state = "syndicate_top_biggest"


	attack_hand(mob/living/carbon/human/user)
		if(user.head == src)
			return
		user.drop_from_slot(src, get_turf(src))
		var/obj/item/current_head = user.head
		if (current_head)
			current_head.unequipped(user)
			user.hud.remove_item(current_head)
			user.head = null
			user.drop_from_slot(current_head, get_turf(current_head))
		if (user.equip_if_possible(src, SLOT_HEAD))
			change_big_icon_state(FALSE)



	equipped(mob/user, slot)
		..()
		APPLY_ATOM_PROPERTY(user, PROP_MOB_BREATHLESS, src.type) //we need no oxygen in this place
		APPLY_ATOM_PROPERTY(user, PROP_MOB_STUN_RESIST, src.type, 80) // falling to a couple batons is shameful
		APPLY_MOVEMENT_MODIFIER(user, /datum/movement_modifier/pain_immune, src.type) // slow for nothing
		user.add_antagonist(role_id = ROLE_CONFIRMED_CRIMINAL, do_equip = FALSE, do_objectives = FALSE, do_relocate = FALSE, source = ANTAGONIST_SOURCE_ADMIN, respect_mutual_exclusives = FALSE) //crime time
		command_alert("An overwhelming aura of EEEEVVVVIIIILLLL has been detected at [get_area(src)].", alert_origin = ALERT_ANOMALY)
		src.maptext_thingamajig = new /obj/machinery/maptext_monitor/health/constantly_overhead(user)

	unequipped(mob/user)
		. = ..()
		change_big_icon_state(TRUE)
		qdel(src.maptext_thingamajig)
		src.maptext_thingamajig = null

	suicide(var/mob/user as mob)
		var/turf/T = get_turf(src)
		if (!src.user_can_suicide(user))
			return 0
		if (ishuman(user))
			var/mob/living/carbon/human/H = user
			if (istype(H.head, /obj/item/clothing/head/bighat/syndicate))
				H.visible_message(SPAN_NOTICE("<b>[H] becomes one with the [src.name]!</b>"))
				H.firegib()
				SPAWN(1 SECONDS)
					explosion_new(src, T, 200) // a silly goodbye
					qdel(src)
				return 1

	disposing()
		qdel(src.maptext_thingamajig)
		src.maptext_thingamajig = null
		..()

/obj/item/clothing/head/bighat/capitalism
	name = "The Hat of John Nanotrasen, Owner of the Frontier Nanotrasen"
	desc = "You feel an intense aura of capitalism radiating from this hat"
	icon = 'icons/mob/clothing/biggestesthat.dmi'
	wear_image_icon = 'icons/mob/clothing/biggestesthat.dmi'
	icon_state = "spessdome_top_TheOne"
	rarity = ITEM_RARITY_MYTHIC
	anchored = ANCHORED

	setupProperties()
		..()
		setProperty("meleeprot_all", 10)
		setProperty("rangedprot", 4)
		setProperty("space_movespeed", -0.4)
		setProperty("disorient_resist", 90)
		setProperty("disorient_resist_eye", 100)
		setProperty("disorient_resist_ear", 50)
		setProperty("exploprot", 50)
		setProperty("chemprot", 50)
		setProperty("stamregen", 5)
		setProperty("rangedprot", 4)

	proc/change_big_icon_state(var/BIG)
		if(BIG == TRUE)
			src.icon = initial(src.icon)
			src.icon_state = initial(src.icon_state)
		else
			src.icon = 'icons/mob/clothing/bighat.dmi'
			src.icon_state = "spessdome_top_TheOne"


	attack_hand(mob/living/carbon/human/user)
		if(user.head == src)
			return
		user.drop_from_slot(src, get_turf(src))
		var/obj/item/current_head = user.head
		if (current_head)
			boutput(user, SPAN_NOTICE("You cannot pick up [src.name] while currently wearing another hat."))

		else
			boutput(user, SPAN_NOTICE("You put the [src.name] on immediately because it is too tall too unwieldly in your hands."))
			if (user.equip_if_possible(src, SLOT_HEAD))
				change_big_icon_state(FALSE)

	unequipped(mob/user)
		. = ..()
		change_big_icon_state(TRUE)

/obj/item/clothing/head/witchfinder
	name = "witchfinder general's hat"
	desc = "To hide most of your emotionless facial features."
	icon_state = "witchfinder"
	item_state = "witchfinder"

/obj/item/clothing/head/aviator
	name = "aviator hat and goggles"
	desc = "Won't you run, live to fly, fly to live, Aces high."
	icon_state = "aviator"

	setupProperties()
		..()
		setProperty("disorient_resist_eye", 25)
		setProperty("disorient_resist_ear", 5)

	attack_self(mob/user as mob)
		user.show_text("You change the hat's style.")
		if (src.icon_state == "aviator")
			src.icon_state = "aviator_alt"
			src.item_state = "aviator_alt"
			c_flags = COVERSEYES
		else if (src.icon_state == "aviator_alt")
			src.icon_state = "aviator"
			src.item_state = "aviator"

/obj/item/clothing/head/sunhat
	name = "sunhat"
	desc = "It's good to hide away from the sun. With this hat."
	icon_state = "sunhatb"
	item_state = "sunhatb"
	var/max_uses = 1 // If can_be_charged == 1, how many charges can this stupid hat store?
	var/stunready = 0
	var/uses = 0 //this is stupid but I love it

	sunhatr
		icon_state = "sunhatr"
		item_state = "sunhatr"

	sunhatg
		icon_state = "sunhatg"
		item_state = "sunhatg"

	sunhaty
		icon_state = "sunhaty"
		item_state = "sunhaty"

	stunhatr
		stunready = 1
		uses = 1
		icon_state = "sunhatr-stun"
		item_state = "sunhatr-stun"

	examine()
		. = ..()
		if (src.stunready)
			. += "It appears to be been modified into a... stunhat? [src.max_uses > 0 ? " There are [src.uses]/[src.max_uses] charges left!" : ""]"

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/cable_coil))
			if (src.stunready)
				user.show_text("You don't need to add more wiring to the [src.name].", "red")
				return

			boutput(user, SPAN_NOTICE("You attach the wires to the [src.name]."))
			src.stunready = 1
			W:amount--
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

			if (src.uses == src.max_uses)
				user.show_text("The hat is already fully charged.", "red")
				return
			if (src.uses < 0)
				src.uses = 0
			src.uses = min(src.uses + 1, src.max_uses)
			C.use(1000)
			src.icon_state = text("[]-stun",src.icon_state)
			src.item_state = text("[]-stun",src.item_state)
			C.UpdateIcon()
			user.update_clothing() // Required to update the worn sprite (Convair880).
			user.visible_message(SPAN_ALERT("<b>[user]</b> charges [his_or_her(user)] stunhat."), SPAN_NOTICE("The stunhat now holds [src.uses]/[src.max_uses] charges!"))
			return

		..()


/obj/item/clothing/head/headmirror
	name = "head mirror"
	desc = "Old diagnostic device which allowed shadow free inspection of the patient."
	icon_state = "headmirror"
	item_state = "headmirror"

/obj/item/clothing/head/nursehat
	name = "nurse hat"
	desc = "A hat often worn by a nurse. And nurse enthusiasts."
	icon_state = "nursehat"
	item_state = "nursehat"

/obj/item/clothing/head/traditionalnursehat
	name = "Traditional Nurse Hat"
	desc = "A nurse hat from the past."
	icon_state = "traditionalnursehat"
	item_state = "traditionalnursehat"
	seal_hair = 1

/obj/item/clothing/head/chemhood
	name = "chemical protection hood"
	desc = "A thick rubber hood which protects you from almost any harmful chemical substance."
	icon_state = "chemhood"
	item_state = "chemhood"
	c_flags = SPACEWEAR | COVERSEYES | COVERSMOUTH | BLOCKCHOKE
	hides_from_examine = C_EARS
	seal_hair = 1
	acid_survival_time = 8 MINUTES

	setupProperties()
		..()
		setProperty("chemprot", 40)
		setProperty("disorient_resist_eye", 6)
		setProperty("disorient_resist_ear", 5)

/obj/item/clothing/head/jester
	name = "jester's hat"
	desc = "The hat of not-so-funny-clown."
	icon_state = "jester"
	item_state = "jester"
	seal_hair = 1

/obj/item/clothing/head/party
	name = "party hat"
	icon_state = "party-cardboard"
	item_state = "party-cardboard"
	desc = "A party hat made of cardboard. How tacky."

/obj/item/clothing/head/party/random
	desc = "All the coolest party people wear these hats!"
	var/style = null

	New()
		..()
		if(!style)
			src.style = rand(1,8)
			src.icon_state = "party-[style]"
			src.item_state = "party-[style]"

/obj/item/clothing/head/party/birthday
	name = "birthday hat"
	icon_state = "birthday-pink"
	item_state = "birthday-pink"
	desc = "Happy birthday to you, happy birthday to you, the rest of this hat is copyrighted."

/obj/item/clothing/head/party/birthday/blue
	name = "birthday hat"
	icon_state = "birthday-blue"
	item_state = "birthday-blue"
	desc = "Happy birthday to you, happy birthday to you, in 200 years nobody will remember you."

/obj/item/clothing/head/pokervisor
	name = "green visor"
	desc = "Do both gambling and accounting with style."
	icon_state = "pokervis"
	item_state = "pokervis"

/obj/item/clothing/head/graduation_cap
	name = "graduation cap"
	desc = "Hey, kid. You did it. Despite everything, you persevered. I'm proud of you."
	icon_state = "graduation_cap"
	item_state = "graduation_cap"

/obj/item/clothing/head/danberet
	name = "Discount Dan's beret"
	desc = "A highly advanced textile experience!"
	icon_state = "danberet"
	item_state = "danberet"

/obj/item/clothing/head/janiberet
	name = "Head of Sanitation beret"
	desc = "The Chief of Cleaning, the Superintendent of Scrubbing, whatever you call yourself, you know how to make those tiles shine. Good job."
	icon_state = "janitorberet"
	item_state = "janitorberet"
	var/folds = 0

/obj/item/clothing/head/janiberet/attack_self(mob/user as mob)
	if(src.folds)
		src.folds = 0
		src.name = "Head of Sanitation beret"
		src.icon_state = "janitorberet"
		src.item_state = "janitorberet"
		boutput(user, SPAN_NOTICE("You fold the hat back into a beret."))
	else
		src.folds = 1
		src.name = "Head of Sanitation hat"
		src.icon_state = "janitorcap"
		src.item_state = "janitorcap"
		boutput(user, SPAN_NOTICE("You unfold the beret into a hat."))
	return

/obj/item/clothing/head/pajama_cap
	name = "nightcap"
	desc = "Is it truly a good night without one?"
	icon_state = "pajama_hat"
	item_state = "pajama_hat"

/obj/item/clothing/head/that/white
	name = "white hat"
	desc = "A white tophat."
	icon_state = "whtophat"
	item_state = "whtophat"

/obj/item/clothing/head/headsprout
	name = "leaf hairclip"
	desc = "A sign of a healthy, growing Staff Assistant."
	icon_state = "headsprout"
	item_state = "headsprout"

/obj/item/clothing/head/hos_hat
	name = "HoS Hat"
	icon_state = "hoscap"
	item_state = "hoscap"
	c_flags = SPACEWEAR
	var/folds = 0
	desc = "Actually, this hat is from a fast-food restaurant, that's why it folds like it was made of paper."
	setupProperties()
		..()
		setProperty("meleeprot_head", 7)

/obj/item/clothing/head/hos_hat/attack_self(mob/user as mob)
	if(user.r_hand == src || user.l_hand == src)
		if(!src.folds)
			src.folds = 1
			src.name = "HoS Beret"
			src.icon_state = "hosberet"
			src.item_state = "hosberet"
			boutput(user, SPAN_NOTICE("You fold the hat into a beret."))
		else
			src.folds = 0
			src.name = "HoS Hat"
			src.icon_state = "hoscap"
			src.item_state = "hoscap"
			boutput(user, SPAN_NOTICE("You unfold the beret back into a hat."))
		return

/obj/item/clothing/head/pinwheel_hat
	name = "pinwheel hat"
	desc = "A fun hat with a little spinny wheel on it."
	icon_state = "pinwheel_hat"
	item_state = "pinwheel_hat"

/obj/item/clothing/head/frog_hat
	name = "frog"
	desc = "A hat shaped like a frog's head. Not made of frogs."
	icon_state = "frog_hat"
	item_state = "frog_hat"

/obj/item/clothing/head/boater_hat
	name = "boater hat"
	desc = "A hat useful for cutting hair and singing songs in a quartet."
	icon_state = "boater_hat"
	item_state = "boater_hat"

/obj/item/clothing/head/ushanka
	name = "ushanka"
	desc = "A hat favored by those in cold climates."
	icon_state = "ushanka"
	item_state = "ushanka"

	setupProperties()
		..()
		setProperty("coldprot", 15)

/obj/item/clothing/head/waitresshat
	name = "diner waitress's hat"
	desc = "Still smells faintly of hairspray."
	icon_state = "waitresshat"
	item_state = "waitresshat"

// HEADBANDS

ABSTRACT_TYPE(/obj/item/clothing/head/headband)
/obj/item/clothing/head/headband
	name = "headband"
	desc = "A band. For your head."
	icon = 'icons/obj/clothing/item_ears.dmi'
	wear_image_icon = 'icons/mob/clothing/ears.dmi'
	icon_state = "cat-gray"
	item_state = "cat-gray"
	inhand_image_icon = 'icons/mob/inhand/hand_headgear.dmi'
	item_state = "earsheadband"
	w_class = W_CLASS_TINY
	throwforce = 0

	attackby(obj/item/W, mob/user)
		..()
		if(istype(W,/obj/item/device/radio/headset))
			user.show_message("You stuff the headset on the headband and tape it in place. [istype(src, /obj/item/clothing/head/headband/nyan) ? "Meow" : "Now"] you should be able to hear the radio using these!")
			var/obj/item/device/radio/headset/H = W
			H.icon = src.icon
			H.name = src.name
			H.icon_state = src.icon_state
			H.wear_image_icon = src.wear_image_icon
			H.wear_image = src.wear_image
			H.wear_layer = MOB_FULL_SUIT_LAYER
			H.desc = "Aww, cute and fuzzy. Someone has taped a radio headset onto the headband."
			qdel(src)

ABSTRACT_TYPE(/obj/item/clothing/head/headband/nyan)
/obj/item/clothing/head/headband/nyan
	name = "gray cat ears"
	desc = "Aww, cute and fuzzy."
	icon_state = "cat-gray"
	item_state = "cat-gray"
	random
		New()
			..()
			var/color = pick("white","gray","black","red","orange","yellow","green","blue","purple")
			name = "[color] cat ears"
			item_state = "cat-[color]"
			icon_state = "cat-[color]"

	white
		name = "white cat ears"
		icon_state = "cat-white"
		item_state = "cat-white"
	gray
		name = "gray cat ears"
		icon_state = "cat-gray"
		item_state = "cat-gray"
	black
		name = "black cat ears"
		icon_state = "cat-black"
		item_state = "cat-black"
	red
		name = "red cat ears"
		icon_state = "cat-red"
		item_state = "cat-red"
	orange
		name = "orange cat ears"
		icon_state = "cat-orange"
		item_state = "cat-orange"
	yellow
		name = "yellow cat ears"
		icon_state = "cat-yellow"
		item_state = "cat-yellow"
	green
		name = "green cat ears"
		icon_state = "cat-green"
		item_state = "cat-green"
	blue
		name = "blue cat ears"
		icon_state = "cat-blue"
		item_state = "cat-blue"
	purple
		name = "purple cat ears"
		icon_state = "cat-purple"
		item_state = "cat-purple"
	leopard
		name = "leopard ears"
		icon_state = "cat-leopard"
		item_state = "cat-leopard"
	snowleopard
		name = "snow leopard ears"
		icon_state = "cat-leopardw"
		item_state = "cat-leopardw"
	tiger
		name = "tiger ears"
		icon_state = "cat-tiger"
		item_state = "cat-tiger"

/obj/item/clothing/head/headband/devil
	name = "devil horns"
	desc = "Plastic devil horns attached to a headband as part of a Halloween costume."
	icon = 'icons/obj/clothing/item_hats.dmi'
	wear_image_icon = 'icons/mob/clothing/head.dmi'
	icon_state = "devil"
	item_state = "devil"

/obj/item/clothing/head/headband/antlers
	name = "antlers"
	desc = "Be a deer and wear these, won't you?"
	icon = 'icons/obj/clothing/item_ears.dmi'
	wear_image_icon = 'icons/mob/clothing/bighat.dmi'
	icon_state = "antlers"
	item_state = "antlers"
	w_class = W_CLASS_TINY
	throwforce = 0

/obj/item/clothing/head/headband/giraffe
	name = "giraffe ears"
	desc = "Wearing these will take your fashion to another level."
	icon = 'icons/obj/clothing/item_ears.dmi'
	wear_image_icon = 'icons/mob/clothing/bighat.dmi'
	icon_state = "giraffe"
	item_state = "giraffe"
	w_class = W_CLASS_TINY
	throwforce = 0

/obj/item/clothing/head/headband/bee
	name = "bee antennae"
	desc = "These antennae will make you look BEE-autiful!"
	icon = 'icons/obj/clothing/item_ears.dmi'
	wear_image_icon = 'icons/mob/clothing/bighat.dmi'
	icon_state = "antennae"
	item_state = "antennae"
	w_class = W_CLASS_TINY
	throwforce = 0

// BARRETTES

ABSTRACT_TYPE(/obj/item/clothing/head/barrette)
/obj/item/clothing/head/barrette
	name = "barrettes"
	desc = "Not to be confused with a beret."
	icon_state = "barrette-blue"
	item_state = "barrette-blue"
	blocked_from_petasusaphilic = TRUE
	w_class = W_CLASS_TINY
	throwforce = 0

	butterflyblu
		name = "blue butterfly hairclip"
		desc = "A fashionable hair clip shaped like a butterfly to keep your hair from fly-ing all over the place."
		icon_state = "barrette-butterflyblu"
		item_state = "barrette-butterflyblu"
	butterflyorg
		name = "orange butterfly hairclip"
		desc = "A fashionable hair clip shaped like a butterfly to keep your hair from fly-ing all over the place."
		icon_state = "barrette-butterflyorg"
		item_state = "barrette-butterflyorg"
	blue
		name = "blue barrettes"
		icon_state = "barrette-blue"
		item_state = "barrette-blue"
	green
		name = "green barrettes"
		icon_state = "barrette-green"
		item_state = "barrette-green"
	pink
		name = "pink barrettes"
		icon_state = "barrette-pink"
		item_state = "barrette-pink"
	gold
		name = "gold barrettes"
		icon_state = "barrette-gold"
		item_state = "barrette-gold"
	black
		name = "black barrettes"
		icon_state = "barrette-black"
		item_state = "barrette-black"
	silver
		name = "silver barrettes"
		icon_state = "barrette-silver"
		item_state = "barrette-silver"

// HAIRBOWS (jan.antilles loves you)

ABSTRACT_TYPE(/obj/item/clothing/head/hairbow)
/obj/item/clothing/head/hairbow
	name = "hairbow"
	desc = "A huge bow that goes on your head."
	icon_state = "hbow-magenta"
	item_state = "hbow-magenta"
	w_class = W_CLASS_TINY
	throwforce = 0

	magenta
		name = "magenta hairbow"
		desc = "A huge bow that goes on your head. This one is magenta."
		icon_state = "hbow-magenta"
		item_state = "hbow-magenta"
	pink
		name = "pink hairbow"
		desc = "A huge bow that goes on your head. This one is pink."
		icon_state = "hbow-pink"
		item_state = "hbow-pink"
	red
		name = "red hairbow"
		desc = "A huge bow that goes on your head. This one is red."
		icon_state = "hbow-red"
		item_state = "hbow-red"
	gold
		name = "gold hairbow"
		desc = "A huge bow that goes on your head. This one is gold."
		icon_state = "hbow-gold"
		item_state = "hbow-gold"
	green
		name = "green hairbow"
		desc = "A huge bow that goes on your head. This one is green."
		icon_state = "hbow-green"
		item_state = "hbow-green"
	mint
		name = "mint hairbow"
		desc = "A huge bow that goes on your head. This one is mint."
		icon_state = "hbow-mint"
		item_state = "hbow-mint"
	blue
		name = "blue hairbow"
		desc = "A huge bow that goes on your head. This one is blue."
		icon_state = "hbow-blue"
		item_state = "hbow-blue"
	navy
		name = "navy hairbow"
		desc = "A huge bow that goes on your head. This one is navy."
		icon_state = "hbow-navy"
		item_state = "hbow-navy"
	purple
		name = "purple hairbow"
		desc = "A huge bow that goes on your head. This one is purple."
		icon_state = "hbow-purple"
		item_state = "hbow-purple"
	shinyblack
		name = "shiny black hairbow"
		desc = "A huge bow that goes on your head. This one is shiny black."
		icon_state = "hbow-shinyblack"
		item_state = "hbow-shinyblack"
	matteblack
		name = "matte black hairbow"
		desc = "A huge bow that goes on your head. This one is matte black."
		icon_state = "hbow-matteblack"
		item_state = "hbow-matteblack"
	white
		name = "white hairbow"
		desc = "A huge bow that goes on your head. This one is white."
		icon_state = "hbow-white"
		item_state = "hbow-white"
	rainbow
		name = "rainbow hairbow"
		desc = "A huge bow that goes on your head. This one has stripes in all the colors of the rainbow."
		icon_state = "hbow-rainbow"
		item_state = "hbow-rainbow"
	flashy
		name = "flashy hairbow"
		desc = "A huge bow that goes on your head. This one is flashing all kinds of colors! Whoa."
		icon_state = "hbow-flashy"
		item_state = "hbow-flashy"

	yellowpolkadot
		name = "yellow polka-dot hairbow"
		desc = "A huge bow that goes on your head. This one is yellow and has polka dots. Not itsy bitsy or teeny weeny."
		icon_state = "hbow-yellowpolkadot"
		item_state = "hbow-yellowpolkadot"

/obj/item/clothing/head/deerstalker
	name = "deerstalker hat"
	desc = "A hat for hunting space deer or solving a mystery."
	icon_state = "deerstalker"
	item_state = "deerstalker"

/obj/item/clothing/head/pomhat_blue
   name = "blue pomhat"
   desc = "A cobalt hat with a fun little pom!"
   icon_state = "pomhat_blue"
   item_state = "pomhat_blue"

/obj/item/clothing/head/pomhat_red
   name = "red pomhat"
   desc = "A crimson hat with an enjoyable little pom!"
   icon_state = "pomhat_red"
   item_state = "pomhat_red"

// Mime Beret recolours (mime beret is located elsewhere weirdly)

ABSTRACT_TYPE(/obj/item/clothing/head/frenchberet)
/obj/item/clothing/head/frenchberet
	name = "\improper French beret"
	desc = "Much more artistic than your standard beret."
	icon_state = "beret_wht"
	item_state = "beret_wht"
	w_class = W_CLASS_TINY
	throwforce = 0

	white
		name = "white French beret"
		icon_state = "beret_wht"
		item_state = "beret_wht"

	yellow
		name = "yellow French beret"
		icon_state = "beret_yel"
		item_state = "beret_yel"

	mint
		name = "mint French beret"
		icon_state = "beret_mnt"
		item_state = "beret_mnt"

	purple
		name = "purple French beret"
		icon_state = "beret_prp"
		item_state = "beret_prp"

	blue
		name = "blue French beret"
		icon_state = "beret_blu"
		item_state = "beret_blu"

	pink
		name = "pink French beret"
		icon_state = "beret_pnk"
		item_state = "beret_pnk"

	strawberry
		name = "strawberry beret"
		icon_state = "beret_strawb"
		item_state = "beret_strawb"

	blueberry
		name = "blueberry beret"
		icon_state = "beret_blueb"
		item_state = "beret_blueb"

// Costume goggles

ABSTRACT_TYPE(/obj/item/clothing/head/goggles)
/obj/item/clothing/head/goggles
	name = "costume goggles"
	desc = "They don't even fit over your eyes! How cheap."
	icon_state = "goggles_red"
	item_state = "goggles_red"
	w_class = W_CLASS_TINY
	throwforce = 0

	red
		name = "red costume goggles"
		icon_state = "goggles_red"
		item_state = "goggles_red"

	purple
		name = "purple costume goggles"
		icon_state = "goggles_prp"
		item_state = "goggles_prp"

	green
		name = "green costume goggles"
		icon_state = "goggles_grn"
		item_state = "goggles_grn"

	blue
		name = "blue costume goggles"
		icon_state = "goggles_blu"
		item_state = "goggles_blu"

	yellow
		name = "yellow costume goggles"
		icon_state = "goggles_yel"
		item_state = "goggles_yel"

// Baseball Caps

ABSTRACT_TYPE(/obj/item/clothing/head/basecap)
/obj/item/clothing/head/basecap
	name = "baseball cap"
	desc = "Wear it normally, or flip it backwards to increase your coolness."
	var/hatflip = FALSE
	var/hatcolour = "black"

	New()
		..()
		name = "[hatcolour] baseball cap"
		item_state = "basecap_[hatcolour]"

	attack_self(var/mob/user as mob)
		src.hatflip = !src.hatflip
		src.icon_state = "basecap_[hatcolour]"
		src.item_state = "basecap_[hatcolour]"
		if(src.hatflip)
			src.icon_state = "basecapflip_[hatcolour]"
			src.item_state = "basecapflip_[hatcolour]"
			boutput(user, SPAN_NOTICE("You flip your baseball cap around. Now it's backwards."))
		else
			boutput(user, SPAN_NOTICE("You flip your baseball cap back into the standard baseball cap position."))

	black
		hatcolour = "black"
		item_state = "basecap_black"
		icon_state = "basecap_black"

	purple
		hatcolour = "purple"
		item_state = "basecap_purple"
		icon_state = "basecap_purple"

	red
		hatcolour = "red"
		item_state = "basecap_red"
		icon_state = "basecap_red"

	yellow
		hatcolour = "yellow"
		item_state = "basecap_yellow"
		icon_state = "basecap_yellow"

	green
		hatcolour = "green"
		item_state = "basecap_green"
		icon_state = "basecap_green"

	blue
		hatcolour = "blue"
		item_state = "basecap_blue"
		icon_state = "basecap_blue"

	white
		hatcolour = "white"
		item_state = "basecap_white"
		icon_state = "basecap_white"

	pink
		hatcolour = "pink"
		item_state = "basecap_pink"
		icon_state = "basecap_pink"

/obj/item/clothing/head/pirate_blk
	name = "black pirate hat"
	desc = "Heroic!"
	icon_state = "pirate_blk"
	item_state = "pirate_blk"

/obj/item/clothing/head/pirate_brn
	name = "brown pirate hat"
	desc = "Heroic!"
	icon_state = "pirate_brn"
	item_state = "pirate_brn"

/obj/item/clothing/head/pirate_captain
	name = "pirate captain's hat"
	desc = "A traditional pirate tricorne, adorned with a crimson feather, just to tell everyone who's boss."
	icon_state = "pirate_captain"
	item_state = "pirate_captain"

/obj/item/clothing/head/pirate_first_mate
	name = "pirate first mate's hat"
	desc = "Who needs a fancy red feather to show authority?"
	icon_state = "pirate_first_mate"
	item_state = "pirate_first_mate"

//Lesbian Hat

TYPEINFO(/obj/item/clothing/head/lesbian_hat)
	mats = list("fabric" = 5,
				"honey" = 5)
/obj/item/clothing/head/lesbian_hat
	name = "very lesbian hat"
	desc = "And they say subtlety is dead."
	icon_state = "lesbeean"
	item_state = "lesbeean"

//Western Ten-Gallon hats!

/obj/item/clothing/head/westhat
	name = "Ten-Gallon hat"
	desc = "Channel your true cowboy and call everyone partner!"
	icon_state = "westhat"
	item_state = "westhat"

/obj/item/clothing/head/westhat/black
	name = "Black Ten-Gallon hat"
	icon_state = "westhat_black"
	item_state = "westhat_black"

/obj/item/clothing/head/westhat/red
	name = "Red Ten-Gallon hat"
	icon_state = "westhat_red"
	item_state = "westhat_red"

/obj/item/clothing/head/westhat/blue
	name = "Blue Ten-Gallon hat"
	icon_state = "westhat_blue"
	item_state = "westhat_blue"

/obj/item/clothing/head/westhat/tan
	name = "Tan Ten-Gallon hat"
	icon_state = "westhat_tan"
	item_state = "westhat_tan"

/obj/item/clothing/head/westhat/brown
	name = "Brown Ten-Gallon hat"
	icon_state = "westhat_brown"
	item_state = "westhat_brown"

//Witchy Hats

/obj/item/clothing/head/witchhat_purple
	name = "purple witch hat"
	desc = "Magical, but the friendship and imagination kind, not the remove-your-butt kind."
	icon_state = "witchhat_purple"
	item_state = "witchhat_purple"

/obj/item/clothing/head/witchhat_mint
	name = "mint witch hat"
	desc = "Magical, but the friendship and imagination kind, not the remove-your-butt kind."
	icon_state = "witchhat_mint"
	item_state = "witchhat_mint"

/obj/item/clothing/head/bouffant
	name = "bouffant scrub hat"
	desc = "A surgical hat designed to keep the wearers hair from falling into the patient, essentially a fancier hair net."
	icon_state = "bouffant"
	item_state = "bouffant"

// Crate Loot

/obj/item/clothing/head/bear
	name = "bear hat"
	desc = "A hat in the shape of the mythical Earth-bear."
	icon_state = "bear"
	item_state = "bear"

/obj/item/clothing/head/rugged
	name = "rugged hat"
	desc = "A cool hat that's come pre-torn. Huh."
	icon_state = "rugged"
	item_state = "rugged"

/obj/item/clothing/head/star_tophat
	name = "starry tophat"
	desc = "A fancy tophat with a detailed rendition of the night sky sewn in."
	icon_state = "star_tophat"
	item_state = "star_tophat"

/obj/item/clothing/head/cow
	name = "cow"
	desc = "It looks like a cow and goes on your head. Wow."
	icon_state = "cow"
	item_state = "cow"

/obj/item/clothing/head/torch
	name = "torch hat"
	desc = "A pretty dangerous looking hat."
	icon_state = "torch"
	item_state = "torch"

/obj/item/clothing/head/helmet/space/replica
	name = "replica space helmet"
	icon_state = "space_replica"
	item_state = "space_replica"
	desc = "A replica of an old space helmet. Looks spaceworthy regardless."

/obj/item/clothing/head/giraffehat
	name = "giraffe hat"
	desc = "Great for finally reaching those tender tree-top leaves."
	icon = 'icons/obj/large/32x48.dmi'
	icon_state = "giraffehat"
	item_state = "giraffehat"

/obj/item/clothing/head/rhinobeetle
	name = "rhino beetle helm"
	desc = "A lightweight helm styled like a rhinocerous beetle's horn. Not sturdy enough for you to flip your enemies over with, sadly."
	icon_state = "rhinobeetle"
	item_state = "rhinobeetle"

/obj/item/clothing/head/stagbeetle
	name = "stag beetle helm"
	desc = "A lightweight helm styled like a stag beetle's mandibles. Not actually a functional set of grabbers, unfortunately."
	icon_state = "stagbeetle"
	item_state = "stagbeetle"

TYPEINFO(/obj/item/clothing/head/elephanthat)
	random_subtypes = list(
		/obj/item/clothing/head/elephanthat/gold,
		/obj/item/clothing/head/elephanthat/green,
		/obj/item/clothing/head/elephanthat/pink,
		/obj/item/clothing/head/elephanthat/blue
	)
ABSTRACT_TYPE(/obj/item/clothing/head/elephanthat)
/obj/item/clothing/head/elephanthat
	name = "elephant hat"
	desc = "Quite cozy, if you don't mind the trunk smacking you in the face when you walk."
	icon_state = "elephant-gold"
	item_state = "elephant-gold"

	gold
		icon_state = "elephant-gold"
		item_state = "elephant-gold"

	blue
		icon_state = "elephant-blue"
		item_state = "elephant-blue"

	pink
		icon_state = "elephant-pink"
		item_state = "elephant-pink"

	green
		icon_state = "elephant-green"
		item_state = "elephant-green"

	random
		New()
			. = ..()
			var/obj/item/rand_type = get_random_subtype(/obj/item/clothing/head/elephanthat)
			icon_state = initial(rand_type.icon_state)
			item_state = initial(rand_type.item_state)

/obj/item/clothing/head/minotaurmask
	name = "minotaur mask"
	desc = "For a more bull-headed approach."
	icon_state = "minotaur"
	item_state = "minotaur"
	seal_hair = 1

TYPEINFO(/obj/item/clothing/head/mushroomcap)
	random_subtypes = list(
		/obj/item/clothing/head/mushroomcap/red,
		/obj/item/clothing/head/mushroomcap/shiitake,
		/obj/item/clothing/head/mushroomcap/indigo,
		/obj/item/clothing/head/mushroomcap/inky
	)
ABSTRACT_TYPE(/obj/item/clothing/head/mushroomcap)
/obj/item/clothing/head/mushroomcap
	name = "mushroom cap"
	desc = "Makes your lungs feel a little fuzzy."
	var/additional_desc = ""
	hat_offset_y = 4
	icon_state = "mushroom-red"
	item_state = "mushroom-red"

	New()
		. = ..()
		desc += additional_desc

	red
		name = "red mushroom cap"
		additional_desc = " Don't nibble on this one."
		icon_state = "mushroom-red"
		item_state = "mushroom-red"

	shiitake
		name = "shiitake mushroom cap"
		additional_desc = " But it smells delectable."
		icon_state = "mushroom-shiitake"
		item_state = "mushroom-shiitake"

	indigo
		name = "indigo mushroom cap"
		additional_desc = " It has an enticing blue hue."
		icon_state = "mushroom-indigo"
		item_state = "mushroom-indigo"

	inky
		name = "inky mushroom cap"
		additional_desc = " Impressively, the inkdrops never fully drip off."
		icon_state = "mushroom-inky"
		item_state = "mushroom-inky"

	random
		New()
			var/obj/item/clothing/head/mushroomcap/rand_type = get_random_subtype(/obj/item/clothing/head/mushroomcap)
			name = initial(rand_type.name)
			additional_desc = initial(rand_type.additional_desc)
			icon_state = initial(rand_type.icon_state)
			item_state = initial(rand_type.item_state)
			. = ..()

/obj/item/clothing/head/axehat
	name = "axe headband"
	desc = "Alarmingly comfortable."
	icon_state = "axehat"
	item_state = "axehat"

// fishing hats

/obj/item/clothing/head/fish_fear_me
	name = "fish fear me hat"
	desc = "An extremely witty piece of headwear for the discerning angler."
	item_state = "fishfearme"
	icon_state = "fishfearme"
	var/favourite_word = "fish"
	var/emag_multiplier = 0

	proc/who()
		if(prob(50 * emag_multiplier))
			if (prob(20))
				return pick("clowns", "captains", "staff assistants", "frogs", "bees", "traitors", "NanoTrasen", "Syndicate", "scientists", "anglers", "security officers")
			var/tries = 50
			var/atom_value = -INFINITY
			do
				var/atom/A = pick(world.contents)
				var/A_value
				if (istype(A, /turf/space))
					A_value = -1
				else if(istype(A, /area) || istype(A, /turf))
					A_value = 0
				else if(istype(A, /atom/movable/overlay) || istype(A, /atom/movable/screen) || istype(A, /obj/effect) || istype(A, /obj/effects) || istype(A, /obj/overlay))
					continue
				else
					if (isobj(A) && !isitem(A))
						A_value = 1
					else
						A_value = 3
					var/turf/T = get_turf(A)
					if (isnull(T))
						A_value -= 2
					else if (T.z == Z_LEVEL_STATION)
						A_value += 1
				var/atom_name = trimtext(stripTextMacros(A.name))
				if (length(atom_name) <= 2)
					continue
				if (findtext(atom_name, " "))
					A_value -= 0.5
				if (A_value > atom_value)
					. = atom_name
					atom_value = A_value
			while (atom_value < 4 && tries-- > 0)
			return pluralize(.)
		. = pick("fish", "me", "god", "women", "men", "enbies", "people")

	proc/do_what()
		if(prob(5 * emag_multiplier))
			return pick("robust", "eat", "desire")
		. = pick("fear", "want", "love")

	New()
		..()
		src.color = hsv_transform_color_matrix(randfloat(0, 360), 1, 1)
		generate_name()

	proc/generate_name()
		var/list/who = list(who(), who(), who(), who())
		if (prob(66))
			var/have_fish = FALSE
			for (var/who_word in who)
				if (who_word == favourite_word)
					have_fish = TRUE
			if (!have_fish)
				who[rand(1,4)] = favourite_word
		who[1] = capitalize(who[1])
		name = "\improper '[who[1]] [do_what()] [who[2]], [who[3]] [do_what()] [who[4]]' hat"
		real_name = name

	emag_act(mob/user, obj/item/card/emag/E)
		. = ..()
		emag_multiplier = 1
		generate_name()
		boutput(user, SPAN_NOTICE("The hat's text changes to read: [name]."))

	demag(mob/user)
		. = ..()
		emag_multiplier = 0
		generate_name()
		boutput(user, SPAN_NOTICE("The hat's text changes to read: [name]."))

/obj/item/clothing/head/fish_fear_me/emagged
	emag_multiplier = 1

/obj/item/clothing/head/fish_fear_me/emagged/very
	emag_multiplier = 3

/obj/item/clothing/head/fish_fear_me/admin
	name = "admin fear me hat"
	desc = "An extremely witty piece of headwear for the discerning admin."
	favourite_word = "admins"

	who()
		. = pick("admins", "coders", "mentors", "players", "bugs", "feedback", "bans", "ahelps")

	New()
		. = ..()
		src.color = mult_color_matrix(normalize_color_to_matrix(src.color), normalize_color_to_matrix(list(-1,0,0, 0,-1,0, 0,0,-1, 1,1,1)))

/obj/item/clothing/head/clown_autumn_hat
	name = "autumnal clown's hat"
	desc = "Careful to make sure it doesn't Fall off."
	icon_state = "clown_autumn_hat"
	item_state = "clown_autumn_hat"

/obj/item/clothing/head/clown_winter_hat
	name = "winter clown's hat"
	desc = "A jingly and... cool hat."
	icon_state = "clown_winter_hat"
	item_state = "clown_winter_hat"

/obj/item/clothing/head/leaf_wreath
	name = "leaf wreath"
	desc = "A carefully made wreath of dried autumn leaves."
	icon_state = "leaf_wreath"
	item_state = "leaf_wreath"

/obj/item/clothing/head/autumn_tree
	name = "autumn tree hat"
	desc = "A tiny seasonal tree for your head!!"
	icon_state = "autumn_tree"
	item_state = "autumn_tree"

/obj/item/clothing/head/autumn_tree/big
	name = "big autumn tree hat"
	desc = "A big seasonal tree for your head!!"
	New()
		..()
		var/image/big_tree = image(icon('icons/misc/worlds.dmi', "shrub_autumn", SOUTHWEST))
		big_tree.pixel_y = 32
		src.wear_image.overlays += big_tree

/obj/item/clothing/head/weirdohat
	name = "outlander's mask"
	desc = "A visor with teal spikes dragging behind the mask, vaguely reminiscent of an extinct alien race."
	icon_state = "weirdohat"
	item_state = "weirdohat"
	seal_hair = 1

/obj/item/clothing/head/lighthat
	name = "light mitre"
	desc = "A golden mitre pointing tall, proudly touting the strength of its faith and its light"
	icon_state = "lighthat"
	item_state = "lighthat"
	seal_hair = 1

/obj/item/clothing/head/bushhat
	name = "druid mask"
	desc = "Flowers, grass, and other flora completely cover the face of this mask. You can almost hear the roar of earthen creatures calling from inside the shrubbery"
	icon_state = "bushhat"
	item_state = "bushhat"
	seal_hair = 1

/obj/item/clothing/head/rabbithat
	name = "Rabbit Costume Hat"
	desc = "You're gonna need a psych eval after wearing this. And a shower."
	icon = 'icons/obj/clothing/item_hats.dmi'
	wear_image_icon = 'icons/mob/clothing/head.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_headgear.dmi'
	icon_state = "rabbithat"
	item_state = "rabbithat"
	seal_hair = TRUE
