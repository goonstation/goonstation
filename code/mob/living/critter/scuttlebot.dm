/mob/living/critter/robotic/scuttlebot
	name = "scuttlebot"
	desc = "A strangely hat shaped robot looking to spy on your deepest secrets"
	icon = 'icons/mob/critter/robotic/scuttlebot.dmi'
	icon_state = "scuttlebot"
	flags = TABLEPASS | DOORPASS
	hand_count = 1
	can_help = TRUE
	can_throw = TRUE
	can_grab = FALSE
	can_disarm = TRUE
	fits_under_table = TRUE
	speechverb_say = "beeps"
	speechverb_exclaim = "boops"
	speechverb_ask = "beeps curiously"
	add_abilities = list(/datum/targetable/critter/takepicture,
						/datum/targetable/critter/flash,
						/datum/targetable/critter/scuttle_scan,
						/datum/targetable/critter/control_owner)
	health_brute = 25
	health_brute_vuln = 1
	health_burn = 25
	health_burn_vuln = 0.2
	var/is_inspector = FALSE
	var/mail_glasses = FALSE
	var/obj/item/clothing/head/det_hat/linked_hat = null
	var/mob/living/carbon/human/controller = null //Who's controlling us? Lets keep track so we can put them back in their body

	New()
		..()
		//Comes with the goggles
		if (!mail_glasses) //I tried to make this a variable injected into the query but cause var declare this'll work
			var/obj/item/clothing/glasses/scuttlebot_vr/R = new /obj/item/clothing/glasses/scuttlebot_vr(src.loc)
			R.connected_scuttlebot = src
		else
			var/obj/item/clothing/glasses/scuttlebot_vr/mail/R = new /obj/item/clothing/glasses/scuttlebot_vr/mail(src.loc)
			R.connected_pigeon = src

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter/med
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "claw"
		HH.limb_name = "claws"

	setup_healths()
		add_hh_flesh(src.health_brute, src.health_brute_vuln)
		add_hh_flesh_burn(src.health_burn, src.health_burn_vuln)

	Cross(atom/mover)
		if (istype(mover, /obj/projectile))
			return prob(50)
		else
			return ..()

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					playsound(src, 'sound/voice/screams/robot_scream.ogg' , 60, 1, pitch=1.3, channel=VOLUME_CHANNEL_EMOTE)
					return "<b>[src]</b> screams!"

			if ("fart")
				if (src.emote_check(voluntary, 50))
					playsound(src, 'sound/voice/farts/poo2_robot.ogg', 50, TRUE, pitch=1.4, channel=VOLUME_CHANNEL_EMOTE)
					return pick("[src] unleashes the tiniest robotic toot.", "[src] sends out a ridiculously pitched fart.")

			if ("burp")
				if (src.emote_check(voluntary, 50))
					playsound(src.loc, 'sound/vox/birdwell.ogg', 40, 1, pitch=1.3, channel=VOLUME_CHANNEL_EMOTE)
					return "<b>[src]</b> birdwells!"

			if ("flip")
				if (src.emote_check(voluntary, 50))
					playsound(src.loc, pick(src.sound_flip1, src.sound_flip2), 40, 1, pitch=1.3, channel=VOLUME_CHANNEL_EMOTE)
					animate_spin(src, pick("L", "R"), 1, 0)
					return "<b>[src]</b> does a flip!"

		return null

	death(var/gibbed)
		if (controller != null)//Lets put the person back in their body first to avoid death messages
			if (!controller.mind)
				src.mind.transfer_to(controller)
			else
				boutput(src, SPAN_ALERT("Your conscience tries to reintegrate your body, but its already possessed by something!"))

		..(gibbed, 0)

		if (!gibbed)
			make_cleanable(/obj/decal/cleanable/oil,src.loc)
			src.audible_message(SPAN_ALERT("<B>[src] blows apart!</B>"))
			src.drop_item()
			playsound(src.loc, 'sound/impact_sounds/Machinery_Break_1.ogg', 40, 1)
			elecflash(src, radius=1, power=3, exclude_center = 0)
			qdel(src)
		else
			playsound(src.loc, 'sound/impact_sounds/Machinery_Break_1.ogg', 40, 1)
			make_cleanable(/obj/decal/cleanable/oil,src.loc)

	proc/return_to_owner()
		if (controller != null)
			if(!controller.loc)
				boutput(src, SPAN_ALERT("A horrible sense of dread looms over you. You feel like your body has disappeared."))
			else if (!isalive(controller))
				boutput(src, SPAN_ALERT("A horrible sense of dread looms over you. Your real body is dead! The scuttlebot's advanced AI takes over and retains your conscience."))
			else
				src.mind.transfer_to(controller)
			controller.network_device = null
			controller = null

	proc/make_inspector()
		icon_state = "scuttlebot_inspector"
		src.is_inspector = TRUE

/mob/living/critter/robotic/scuttlebot/weak

	add_abilities = list(/datum/targetable/critter/takepicture,
						/datum/targetable/critter/scuttle_scan,
						/datum/targetable/critter/control_owner)

	setup_hands()

/mob/living/critter/robotic/scuttlebot/mail
	name = "Carr1er P1g30n"
	desc = "A pigeon that must've escaped from the ranch and been trained to deliver mail... wait why is 8G labeled on its leg?"
	icon = 'icons/mob/critter/robotic/scuttlebot.dmi'
	icon_state = "pigeon"
	mail_glasses = TRUE
	speechverb_say = "tweets"
	speechverb_exclaim = "twoots"
	speechverb_ask = "tweets curiously"
	var/obj/item/clothing/suit/pigeon/linked_pigeon = null

	add_abilities = list(/datum/targetable/critter/control_owner/mail)

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter/strong
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "claw"
		HH.limb_name = "claws"

/mob/living/critter/robotic/scuttlebot/ghostplayable // admin gimmick ghost spawnable version

	add_abilities = list(/datum/targetable/critter/takepicture)


	setup_hands()

