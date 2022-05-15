/mob/living/critter/robotic/scuttlebot
	name = "scuttlebot"
	desc = "A strangely hat shaped robot looking to spy on your deepest secrets"
	density = 0
	custom_gib_handler = /proc/gibs
	flags = TABLEPASS | DOORPASS
	hand_count = 1
	can_help = 1
	can_throw = 1
	can_grab = 0
	can_disarm = 1
	fits_under_table = 1
	icon_state = "scuttlebot"
	speechverb_say = "beeps"
	speechverb_exclaim = "boops"
	speechverb_ask = "beeps curiously"
	var/health_brute = 25
	var/health_brute_vuln = 1
	var/health_burn = 25
	var/health_burn_vuln = 0.2
	var/mob/living/carbon/human/controller = null //Who's controlling us? Lets keep track so we can put them back in their body

	New()
		..()
		//Comes with the goggles
		var/obj/item/clothing/glasses/scuttlebot_vr/R = new /obj/item/clothing/glasses/scuttlebot_vr(src.loc)
		R.connected_scuttlebot = src

		abilityHolder.addAbility(/datum/targetable/critter/takepicture)
		abilityHolder.addAbility(/datum/targetable/critter/flash)
		abilityHolder.addAbility(/datum/targetable/critter/control_owner)

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
					playsound(src, "sound/voice/screams/robot_scream.ogg" , 60, 1, channel=VOLUME_CHANNEL_EMOTE)
					return "<b>[src]</b> screams!"
		return null

	death(var/gibbed)
		if (controller != null)//Lets put the person back in their body first to avoid death messages
			if (!controller.mind)
				src.mind.transfer_to(controller)
			else
				boutput(src, "<span class='alert'>Your conscience tries to reintegrate your body, but its already possessed by something!</span>")

		..(gibbed, 0)

		if (!gibbed)
			make_cleanable(/obj/decal/cleanable/oil,src.loc)
			src.audible_message("<span class='alert'><B>[src] blows apart!</B></span>", 1)
			src.drop_item()
			playsound(src.loc, "sound/impact_sounds/Machinery_Break_1.ogg", 40, 1)
			elecflash(src, radius=1, power=3, exclude_center = 0)
			qdel(src)
		else
			playsound(src.loc, "sound/impact_sounds/Machinery_Break_1.ogg", 40, 1)
			make_cleanable(/obj/decal/cleanable/oil,src.loc)

	attackby(obj/item/W, mob/M)
		if(istype(W, /obj/item/clothing/glasses/scuttlebot_vr))
			new /obj/item/clothing/head/det_hat/folded_scuttlebot(get_turf(src))
			boutput(M, "You stuff the goggles back into the hat. It powers down with a low whirr.")
			qdel(W)
			qdel(src)
		else
			..()

	proc/return_to_owner()
		if (controller != null)
			if(!controller.loc)
				boutput(src, "<span class='alert'>A horrible sense of dread looms over you. You feel like your body has disappeared.</span>")
			else if (!isalive(controller))
				boutput(src, "<span class='alert'>A horrible sense of dread looms over you. Your real body is dead! The scuttlebot's advanced AI takes over and retains your conscience.</span>")
			else
				src.mind.transfer_to(controller)
			controller = null
