// HATS. OH MY WHAT A FINE CHAPEAU, GOOD SIR.

/obj/item/clothing/head
	name = "hat"
	desc = "For your head!"
	icon = 'icons/obj/clothing/item_hats.dmi'
	wear_image_icon = 'icons/mob/head.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_headgear.dmi'
	body_parts_covered = HEAD
	compatible_species = list("human", "monkey", "werewolf", "flubber")
	var/seal_hair = 0 // best variable name I could come up with, if 1 it forms a seal with a suit so no hair can stick out
	block_vision = 0


	setupProperties()
		..()
		setProperty("coldprot", 10)
		setProperty("heatprot", 5)
		setProperty("meleeprot_head", 1)

/obj/item/clothing/head/red
	desc = "A knit cap in red."
	icon_state = "red"
	item_state = "rgloves"

/obj/item/clothing/head/blue
	desc = "A knit cap in blue."
	icon_state = "blue"
	item_state = "bgloves"

/obj/item/clothing/head/yellow
	desc = "A knit cap in yellow."
	icon_state = "yellow"
	item_state = "ygloves"

/obj/item/clothing/head/dolan
	name = "Dolan's Hat"
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
	permeability_coefficient = 0.01
	c_flags = SPACEWEAR | COVERSEYES | COVERSMOUTH
	desc = "This hood protects you from harmful biological contaminants."
	seal_hair = 1

	setupProperties()
		..()
		setProperty("heatprot", 10)
		setProperty("viralprot", 50)
		setProperty("meleeprot_head", 1)
		setProperty("disorient_resist_eye", 5)
		setProperty("disorient_resist_ear", 2)

/obj/item/clothing/head/bio_hood/janitor // adhara stuff
	name = "bio hood"
	desc = "This hood protects you from harmful biological contaminants. This one has a blue visor."
	icon_state = "bio_jani"
	item_state = "bio_jani"
	icon = 'icons/obj/clothing/item_hats.dmi'
	wear_image_icon = 'icons/mob/head.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_headgear.dmi'


/obj/item/clothing/head/bio_hood/nt
	name = "NT bio hood"
	icon_state = "ntbiohood"
	setupProperties()
		..()
		setProperty("meleeprot_head", 2)

/obj/item/clothing/head/emerg
	name = "Emergency Hood"
	icon_state = "emerg"
	item_state = "emerg"
	permeability_coefficient = 0.25
	c_flags = SPACEWEAR | COVERSEYES | COVERSMOUTH
	desc = "Helps protect from vacuum for a short period of time."
	seal_hair = 1

	setupProperties()
		..()
		setProperty("disorient_resist_eye", 9)
		setProperty("disorient_resist_ear", 5)

/obj/item/clothing/head/rad_hood
	name = "Class II Radiation Hood"
	icon_state = "radiation"
	permeability_coefficient = 0.01
	c_flags = COVERSEYES | COVERSMOUTH
	desc = "Asbestos, right near your face. Perfect!"
	seal_hair = 1

	setupProperties()
		..()
		setProperty("radprot", 50)
		setProperty("heatprot", 10)
		setProperty("meleeprot_head", 1)
		setProperty("disorient_resist_eye", 12)
		setProperty("disorient_resist_ear", 8)

/obj/item/clothing/head/cakehat
	name = "cakehat"
	desc = "It is a cakehat"
	icon_state = "cakehat0"
	uses_multiple_icon_states = 1
	var/status = 0
	var/processing = 0
	c_flags = SPACEWEAR | COVERSEYES
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
		SPAWN_DBG(0)
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
			src.force = 10
			src.hit_type = DAMAGE_BURN
			src.icon_state = "cakehat1"
			light.enable()
			if (!(src in processing_items))
				processing_items.Add(src)
		else
			src.force = 3
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
			boutput(usr, "<span class='notice'>You heat \the [target.name]</span>")
			target.reagents.temperature_reagents(2500,10)
		return

/obj/item/clothing/head/caphat
	name = "Captain's hat"
	icon_state = "captain"
	c_flags = SPACEWEAR
	item_state = "caphat"
	desc = "A symbol of the captain's rank, and the source of all his power."
	setupProperties()
		..()
		setProperty("meleeprot_head", 4)

/obj/item/clothing/head/centhat
	name = "Cent. Comm. hat"
	icon_state = "centcom"
	c_flags = SPACEWEAR
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
	name = "hat"
	desc = "Someone who wears this will look very smart."
	icon_state = "detective"
	item_state = "det_hat"
	setupProperties()
		..()
		setProperty("meleeprot_head", 3)

//THE ONE AND ONLY.... GO GO GADGET DETECTIVE HAT!!!
/obj/item/clothing/head/det_hat/gadget
	name = "DetGadget hat"
	desc = "Detective's special hat you can outfit with various items for easy retrieval!"
	var/phrase = "go go gadget"

	var/list/items

	var/max_cigs = 15
	var/list/cigs

	New()
		..()
		items = list("bodybag" = /obj/item/body_bag,
									"scanner" = /obj/item/device/detective_scanner,
									"lighter" = /obj/item/device/light/zippo/,
									"spray" = /obj/item/spraybottle,
									"monitor" = /obj/item/device/camera_viewer,
									"camera" = /obj/item/camera_test,
									"audiolog" = /obj/item/device/audio_log ,
									"flashlight" = /obj/item/device/light/flashlight,
									"glasses" = /obj/item/clothing/glasses)
		cigs = list()
	examine()
		. = ..()
		. += "<span class='notice'>Current activation phrase is <b>\"[phrase]\"</b>.</span>"
		for (var/name in items)
			var/type = items[name]
			var/obj/item/I = locate(type) in contents
			if(I)
				. += "<br><span class='notice'>[bicon(I)][I] is ready and bound to the word \"[name]\"!</span>"
			else
				. += "<br>There is no [name]!"
		if (cigs.len)
			. += "<br><span class='notice'>It contains <b>[cigs.len]</b> cigarettes!</span>"

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
					M.visible_message("<span class='alert'><b>[M]</b>'s hat snaps open and pulls out \the [I]!</span>")
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
						if (H.equip_if_possible(W, H.slot_wear_mask))
							boop = "mouth"
						else
							H.put_in_hand_or_drop(W) //Put it in their hand
					else
						M.put_in_hand_or_drop(W) //Put it in their hand

					M.visible_message("<span class='alert'><b>[M]</b>'s hat snaps open and puts \the [W] in [his_or_her(M)] [boop]!</span>")
			else
				M.show_text("Requested object missing or nonexistant!", "red")
				return

	attackby(obj/item/W as obj, mob/M as mob)
		var/success = 0
		for (var/name in items)
			var/type = items[name]
			if(istype(W, type) && !(locate(type) in contents))
				success = 1
				M.drop_item()
				W.set_loc(src)
				break
		if (cigs.len < src.max_cigs && istype(W, /obj/item/clothing/mask/cigarette)) //cigarette
			success = 1
			M.drop_item()
			W.set_loc(src)
			cigs.Add(W)
		if (cigs.len < src.max_cigs && istype(W, /obj/item/cigpacket)) //cigarette packet
			var/obj/item/cigpacket/packet = W
			if(packet.cigcount == 0)
				M.show_text("Oh no! There's no more cigs in [packet]!", "red")
				return
			else
				var/count = packet.cigcount
				for(var/i=0, i<count, i++) //not sure if "-1" cigcount packets will work.
					if(cigs.len >= src.max_cigs)
						break
					var/obj/item/clothing/mask/cigarette/C = new packet.cigtype(src)
					C.set_loc(src)
					cigs.Add(C)
					packet.cigcount--
				success = 1

		if(success)
			M.visible_message("<span class='alert'><b>[M]</b> [pick("awkwardly", "comically", "impossibly", "cartoonishly")] stuffs [W] into [src]!</span>")
			return

		return ..()

	verb/set_phrase()
		set name = "Set Activation Phrase"
		set desc = "Change the activation phrase for the DetGadget hat!"
		set category = "Local"

		set src in usr
		var/n_name = input(usr, "What would you like to set the activation phrase to?", "Activation Phrase", null) as null|text
		if (!n_name)
			return
		n_name = copytext(html_encode(n_name), 1, 32)
		if (((src.loc == usr || (src.loc && src.loc.loc == usr)) && usr.stat == 0))
			src.phrase = n_name
			logTheThing("say", usr, null, "sets the activation phrase on DetGadget hat: [n_name]")
		src.add_fingerprint(usr)

/obj/item/clothing/head/powdered_wig
	name = "powdered wig"
	desc = "A powdered wig"
	icon_state = "pwig"
	item_state = "pwig"

/obj/item/clothing/head/that
	name = "hat"
	desc = "An stylish looking hat"
	wear_image_icon = 'icons/mob/fruithat.dmi'
	icon_state = "tophat"
	item_state = "that"

/obj/item/clothing/head/that/purple
	name = "purple hat"
	desc = "A purple tophat."
	wear_image_icon = 'icons/mob/fruithat.dmi'
	icon_state = "ptophat"
	item_state = "pthat"
	c_flags = SPACEWEAR
	protective_temperature = 500

	setupProperties()
		..()
		setProperty("coldprot", 15)
		setProperty("heatprot", 5)

/obj/item/clothing/head/that/gold
	name = "golden hat"
	desc = "A golden tophat."
	wear_image_icon = 'icons/mob/fruithat.dmi'
	icon_state = "gtophat"
	item_state = "gthat"
	c_flags = SPACEWEAR
	protective_temperature = 500
	mat_changename = 0
	mat_appearances_to_ignore = list("gold") // we already look fine ty

	setupProperties()
		..()
		setProperty("coldprot", 15)
		setProperty("heatprot", 5)

	New()
		..()
		src.setMaterial(getMaterial("gold"))

/obj/item/clothing/head/chefhat
	name = "Chef's hat"
	desc = "Your toque blanche, coloured as such so that your poor sanitation is obvious, and the blood shows up nice and crazy."
	icon_state = "chef"
	item_state = "chefhat"
	wear_image_icon = 'icons/mob/fruithat.dmi'
	c_flags = SPACEWEAR

/obj/item/clothing/head/souschefhat
	name = "Sous-Chef's hat"
	icon_state = "souschef"
	item_state = "chefhat" //TODO: unique inhand sprite?
	c_flags = SPACEWEAR

/obj/item/clothing/head/dramachefhat
	name = "Dramatic Chef's Hat"
	wear_image_icon = 'icons/mob/fruithat.dmi'
	icon_state = "drama"
	item_state = "chefhat" //TODO: unique inhand sprite?
	c_flags = SPACEWEAR

/obj/item/clothing/head/mailcap
	name = "Mailman's Hat"
	desc = "The hat of a mailman."
	icon_state = "mailcap"
	item_state = "mailcap"
	c_flags = SPACEWEAR

/obj/item/clothing/head/policecap
	name = "Police Hat"
	desc = "An old surplus-issue police hat."
	icon_state = "mailcap"
	item_state = "mailcap"
	c_flags = SPACEWEAR

/obj/item/clothing/head/plunger
	name = "plunger"
	desc = "get dat fukken clog"
	wear_image_icon = 'icons/mob/fruithat.dmi'
	icon_state = "plunger"
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	item_state = "plunger"
	setupProperties()
		..()
		setProperty("meleeprot_head", 2)

/obj/item/clothing/head/hosberet
	name = "HoS Beret"
	desc = "This makes you feel like Che Guevara."
	icon_state = "hosberet"
	item_state = "hosberet"
	c_flags = SPACEWEAR
	setupProperties()
		..()
		setProperty("meleeprot_head", 3)

/obj/item/clothing/head/NTberet
	name = "Nanotrasen Beret"
	desc = "For the inner dictator in you."
	icon_state = "ntberet"
	item_state = "ntberet"
	c_flags = SPACEWEAR

/obj/item/clothing/head/XComHair
	name = "Rookie Scalp"
	desc = "Some unfortunate soldier's charred scalp. The hair is intact."
	icon_state = "xcomhair"
	item_state = "xcomhair"
	c_flags = SPACEWEAR

/obj/item/clothing/head/apprentice
	name = "Apprentice's Cap"
	desc = "Legends tell about space sorcerors taking on apprentices. Such apprentices would wear a magical cap, and this is one such ite- hey! This is just a cardboard cone with wrapping paper on it!"
	icon_state = "apprentice"
	item_state = "apprentice"
	c_flags = SPACEWEAR

	dan
		name = "Royal Apprentice's Cap"
		desc = "Part of a collaboration between Dastardly Dan's and Zoldorf Co."
		icon_state = "dan_apprentice"
		item_state = "dan_apprentice"

/obj/item/clothing/head/snake
	name = "Dirty Rag"
	desc = "A rag that looks like it was dragged through the jungle. Yuck."
	icon_state = "snake"
	item_state = "snake"
	c_flags = SPACEWEAR

// Chaplain Hats

/obj/item/clothing/head/rabbihat
	name = "rabbi's hat"
	desc = "Complete with peyois. Perfect for Purim!"
	icon_state = "rabbihat"
	item_state = "that"

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
		src.name = "[pick("fancy", "suave", "manly", "sexerific", "sextacular", "intellectual", "majestic", "euphoric")] fedora"

/obj/item/clothing/head/cowboy
	name = "cowboy hat"
	desc = "Yeehaw!"
	icon_state = "cowboy"
	item_state = "cowboy"
	c_flags = SPACEWEAR

/obj/item/clothing/head/fancy // placeholder icons until someone sprites an actual fancy hat
	name = "fancy hat"
	icon_state = "rank-fancy"
	item_state = "that"  // todo actual inhands for this and children ?
	desc = "What do you mean this is hat isn't fancy?"

/obj/item/clothing/head/fancy/captain
	name = "captain's hat"
	icon_state = "captain-fancy"
	c_flags = SPACEWEAR
	setupProperties()
		..()
		setProperty("meleeprot_head", 3)

/obj/item/clothing/head/fancy/rank
	name = "officer's hat"
	icon_state = "rank-fancy"
	c_flags = SPACEWEAR
	setupProperties()
		..()
		setProperty("meleeprot_head", 3)

/obj/item/clothing/head/wizard
	name = "blue wizard hat"
	desc = "A slightly crumply and foldy blue hat. Every self-respecting Wizard has one of these."
	icon_state = "wizard"
	item_state = "wizard"
	magical = 1

	setupProperties()
		..()
		setProperty("disorient_resist_eye", 15)
		setProperty("disorient_resist_ear", 15)

	handle_other_remove(var/mob/source, var/mob/living/carbon/human/target)
		. = ..()
		if (prob(75))
			source.show_message(text("<span class='alert'>\The [src] writhes in your hands as though it is alive! It just barely wriggles out of your grip!</span>"), 1)
			. = 0

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

/obj/item/clothing/head/wizard/witch
	name = "witch hat"
	desc = "Broomstick and cat not included."
	icon_state = "witch"
	item_state = "wizardnec"
	see_face = 0

/obj/item/clothing/head/wizard/necro
	name = "necromancer hood"
	desc = "Good god, this thing STINKS. Is that mold on the inner lining? Ugh."
	icon_state = "wizardnec"
	item_state = "wizardnec"
	see_face = 0

/obj/item/clothing/head/pinkwizard //no magic properties
	name = "pink wizard hat"
	desc = "A pink wizard hat. Must've been a reject from the assembly line."
	icon_state = "wizardpink"

/obj/item/clothing/head/paper_hat
	name = "paper hat"
	desc = "It's a paper hat!"
	icon_state = "paper"
	item_state = "lgloves"
	see_face = 1
	body_parts_covered = HEAD

/obj/item/paper_hat/attackby(obj/item/W as obj, mob/user as mob)
	if (istype(W, /obj/item/pen))
		var/obj/item/pen/P = W
		if (P.font_color)
			boutput(user, "<span class='notice'>You scribble on the hat until it's filled in.</span>")
			if (P.font_color)
				src.color = P.font_color
				src.desc = "A colorful paper hat"

/obj/item/clothing/head/towel_hat
	name = "towel hat"
	desc = "A white towel folded all into a fancy hat. NOT a turban!" // @;)
	icon_state = "towelhat"
	item_state = "lgloves"
	c_flags = SPACEWEAR
	see_face = 1
	body_parts_covered = HEAD

/obj/item/clothing/head/crown
	name = "crown"
	desc = "Yeah, big deal, you got a fancy crown, what does that do for you against the <b>HORRORS OF SPACE</b>, tough guy?"
	icon_state = "crown"
	see_face = 1
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
	uses_multiple_icon_states = 1
	item_state = "that"
	hitsound = "sound/impact_sounds/Generic_Hit_1.ogg"
	var/active = 0
	throw_return = 1
	throw_speed = 1
	var/turf/throw_source = null

	attack_self (mob/user as mob)
		user.visible_message("<span class='combat'><b>[user] fiddles with [src]!</b></span>")
		sleep(1 SECOND)
		src.toggle_active(user)
		user.update_inhands()
		src.add_fingerprint(user)
		return

	proc/toggle_active(mob/user)
		src.active = !( src.active )
		if (src.active)
			if (user)
				user.visible_message("<span class='combat'><b>Blades extend from the brim of [user]'s hat!</b></span>")
			src.hit_type = DAMAGE_CUT
			src.hitsound = "sound/impact_sounds/Flesh_Cut_1.ogg"
			src.force = 10
			src.icon_state = "oddjob"
			src.throw_source = null
		else
			if (user)
				user.visible_message("<span class='notice'><b>[user]'s hat's blades retract.</b></span>")
			src.hit_type = DAMAGE_BLUNT
			src.hitsound = "sound/impact_sounds/Generic_Hit_1.ogg"
			src.force = 1
			src.icon_state = "mime_bowler"
			src.throw_source = null
		return

	throw_begin(atom/target)
		src.throw_source = get_turf(src)
		..()

	throw_impact(atom/hit_atom)
		if (src.active && ismob(hit_atom))
			var/mob/M = hit_atom
			playsound(get_turf(src), src.hitsound, 60, 1)
			M.changeStatus("weakened", 2 SECONDS)
			M.force_laydown_standup()
			SPAWN_DBG(0) // show these messages after the "hit by" ones
				if (M)
					if (ishuman(M) && M.health < -10)
						var/mob/living/carbon/human/H = M
						var/obj/item/organ/head/the_head = H.drop_organ("head")
						if (istype(the_head))
							H.visible_message("<span class='combat'><b>[H]'s head flies right off [his_or_her(H)] shoulders![prob(33) ? " HOLY SHIT!" : null]</b></span>")
							var/the_dir = src.last_move ? src.last_move : alldirs//istype(src.throw_source) ? get_dir(src.throw_source, H) : alldirs
							the_head.streak(the_dir, the_head.created_decal)
							src.throw_source = null
					else
						M.TakeDamageAccountArmor("chest", 10, 0)
						take_bleeding_damage(M, null, 15, src.hit_type)
			src.toggle_active()

		else if (ishuman(hit_atom))
			var/mob/living/carbon/human/Q = hit_atom
			src.toggle_active() // don't show the message when catching because it just kinda spams things up
			Q.visible_message("<span class='combat'><b>[Q] catches the [src] like a badass.</b></span>")
			if (Q.equipped())
				Q.drop_item()
			Q.put_in_hand_or_drop(src)
			src.throw_source = null
			return
		return ..(hit_atom)

	equipped(var/mob/user, var/slot)
		..()
		if (slot == SLOT_HEAD && ishuman(user))
			var/mob/living/carbon/human/H = user
			H.set_mutantrace(/datum/mutantrace/dwarf)

/obj/item/clothing/head/bigtex
	name = "75-gallon hat"
	desc = "A recreation of the late Big Tex's hat, commisioned by Ol' Harner."
	wear_image_icon = 'icons/mob/fruithat.dmi'
	icon_state = "bigtex"
	item_state = "bigtex"
	setupProperties()
		..()
		setProperty("meleeprot_head", 3)

/obj/item/clothing/head/beret
	name = "beret"
	desc = "A blue beret with no affiliations to NanoTrasen."
	icon_state = "beret_base"
	c_flags = SPACEWEAR

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

// BIGHATS - taller than normal hats! Like fruithat.dmi but bigger! To a max icon size of 64px

/obj/item/clothing/head/bighat
	name = "large hat"
	desc = "An unnaturally large piece of headwear"
	wear_image_icon = 'icons/mob/bighat.dmi'
	icon_state = "tophat"
	w_class = 4

/obj/item/clothing/head/bighat/syndicate
	name = "syndicate hat"
	desc = "A commitment."
	icon_state = "syndicate_top"
	item_state = "syndicate_top"
	c_flags = SPACEWEAR // can't take it off, so may as well make it spaceworthy
	contraband = 10 //let's set off some alarms, boys
	is_syndicate = 1 //no easy replication thanks
	cant_self_remove = 1
	var/datum/component/holdertargeting/sm_light/light_c

	setupProperties()
		..()
		setProperty("meleeprot_head", 6)

	New()
		..()
		light_c = src.AddComponent(/datum/component/holdertargeting/sm_light, 0.94 * 255, 0.27 * 255, 0.27 * 255, 240)
		light_c.update(1)

		if (prob(10))
			SPAWN_DBG( rand(300, 900) )
				src.visible_message("<b>[src]</b> <i>says, \"I'm the boss.\"</i>")

	equipped(var/mob/user, var/slot)
		..()
		boutput(user, "<span class='notice'>You better start running! It's kill or be killed now, buddy!</span>")
		SPAWN_DBG(1 SECOND)
			playsound(src.loc, "sound/vox/time.ogg", 100, 1)
			SPAWN_DBG(1 SECOND)
				playsound(src.loc, "sound/vox/for.ogg", 100, 1)
				SPAWN_DBG(1 SECOND)
					playsound(src.loc, "sound/vox/crime.ogg", 100, 1)

		// Guess what? you wear the hat, you go to jail. Easy Peasy.
		var/perpname = user.name
		if(user:wear_id && user:wear_id:registered)
			perpname = user:wear_id:registered
		// find the matching security record
		for(var/datum/data/record/R in data_core.general)
			if(R.fields["name"] == perpname)
				for (var/datum/data/record/S in data_core.security)
					if (S.fields["id"] == R.fields["id"])
						// now add to rap sheet
						S.fields["criminal"] = "*Arrest*"
						S.fields["ma_crim"] = pick("Being unstoppable","Swagging out so hard","Stylin on \'em","Puttin\' in work")
						S.fields["ma_crim_d"] = pick("Convicted Badass, to the bone.","Certified Turbonerd, home-grown.","Absolute Salad.","King of crimes, Queen of Flexxin\'")

	custom_suicide = 1
	suicide_in_hand = 0
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		if (ishuman(user))
			var/mob/living/carbon/human/H = user
			if (istype(H.head, /obj/item/clothing/head/bighat/syndicate) && !(H.stat || H.getStatusDuration("paralysis") || H.getStatusDuration("stunned") || H.getStatusDuration("weakened") || H.restrained()))
				H.visible_message("<span class='alert'><b>[H] is totally and absolutely robusted by the [src.name]!</b></span>")
				var/turf/T = get_turf(H)
				T.fluid_react_single("blood",1000)
				H.unequip_all()
				H.gib()

				SPAWN_DBG(50 SECONDS)
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
			if (istype(H.head, /obj/item/clothing/head/bighat/syndicate) && !(H.stat || H.getStatusDuration("paralysis") || H.getStatusDuration("stunned") || H.getStatusDuration("weakened") || H.restrained()))
				H.visible_message("<span class='notice'><b>[H] becomes one with the [src.name]!</b></span>")
				H.gib()
				explosion_new(src, T, 50) // like a really mean double macro

				SPAWN_DBG(50 SECONDS)
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

	examine()
		. = ..()
		if (src.stunready)
			. += "It appears to be been modified into a... stunhat? [src.max_uses > 0 ? " There are [src.uses]/[src.max_uses] charges left!" : ""]"

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/cable_coil))
			if (src.stunready)
				user.show_text("You don't need to add more wiring to the [src.name].", "red")
				return

			boutput(user, "<span class='notice'>You attach the wires to the [src.name].</span>")
			src.stunready = 1
			W:amount--
			return

		if (istype(W, /obj/item/cell)) // Moved from cell.dm (Convair880).
			var/obj/item/cell/C = W

			if (C.charge < 1500)
				user.show_text("[C] needs more charge before you can do that.", "red")
				return
			if (!src.stunready)
				user.visible_message("<span class='alert'><b>[user]</b> shocks themselves while fumbling around with [C]!</span>", "<span class='alert'>You shock yourself while fumbling around with [C]!</span>")
				C.zap(user)
				return

			if (src.uses == src.max_uses)
				user.show_text("The hat is already fully charged.", "red")
				return
			if (src.uses < 0)
				src.uses = 0
			src.uses = min(src.uses + 1, src.max_uses)
			C.use(1500)
			src.icon_state = text("[]-stun",src.icon_state)
			src.item_state = text("[]-stun",src.item_state)
			C.updateicon()
			user.update_clothing() // Required to update the worn sprite (Convair880).
			user.visible_message("<span class='alert'><b>[user]</b> charges [his_or_her(user)] stunhat.</span>", "<span class='notice'>The stunhat now holds [src.uses]/[src.max_uses] charges!</span>")
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

/obj/item/clothing/head/chemhood
	name = "chemical protection hood"
	desc = "A thick rubber hood which protects you from almost any harmful chemical substance."
	icon_state = "chemhood"
	item_state = "chemhood"
	permeability_coefficient = 0
	c_flags = SPACEWEAR | COVERSEYES | COVERSMOUTH
	seal_hair = 1

	setupProperties()
		..()
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

/obj/item/clothing/head/nyan
	name = "gray cat ears"
	desc = "Aww, cute and fuzzy."
	icon = 'icons/obj/clothing/item_ears.dmi'
	wear_image_icon = 'icons/mob/ears.dmi'
	icon_state = "cat-gray"
	item_state = "cat-gray"
	w_class = 1.0
	throwforce = 0

	attackby(obj/item/W as obj, mob/user as mob)
		..()
		if(istype(W,/obj/item/device/radio/headset))
			user.show_message("You stuff the headset on the cat ears and tape it in place. Meow you should be able to hear the radio using these!")
			var/obj/item/device/radio/headset/H = W
			H.icon = src.icon
			H.name = src.name
			H.icon_state = src.icon_state
			H.wear_image_icon = src.wear_image_icon
			H.desc = "Aww, cute and fuzzy. Someone has taped a radio headset onto the headband."
			qdel(src)

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
