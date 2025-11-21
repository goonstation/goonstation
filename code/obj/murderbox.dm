/obj/death_button/clean_gunsim
	name = "button that will clean the murderbox"
	desc = "push this to clean the murderbox and probably not get killed. takes a minute."
	icon = 'icons/obj/bots/aibots.dmi'
	icon_state = "cleanbot1"

	var/area/sim/gunsim/arena/gunsim
	var/active = 0

	New()
		..()
		gunsim = get_area_by_type(/area/sim/gunsim/arena)

	attack_hand(mob/user)
		if (active)
			boutput(user, "It just did some cleaning give it a minute!!!")
			return

		active = 1
		alpha = 128
		icon_state = "cleanbot-c"
		user.visible_message("CLEANIN UP THE MURDERBOX STAND CLEAR")

		SPAWN(0)
			for (var/obj/item/I in gunsim)
				if(istype(I, /obj/item/device/radio/intercom)) //lets not delete the intercoms inside shall we?
					continue
				else
					qdel(I)

			for (var/atom/S in gunsim)
				if(istype(S, /obj/storage) || istype(S, /obj/artifact) || istype(S, /obj/critter) || istype(S, /obj/machinery) || istype(S, /obj/decal) || istype(S, /obj/fluid) || istype(S, /mob/living/carbon/human/tdummy) || istype(S, /mob/living/critter))
					qdel(S)


		SPAWN(60 SECONDS)
			active = 0
			alpha = 255
			icon_state = "cleanbot1"


/obj/death_button/create_dummy
	name = "Button that creates a test dummy"
	desc = "click this to create a test dummy"
	icon = 'icons/mob/human.dmi'
	icon_state = "ghost"
	var/active = 0
	alpha = 255

	attack_hand(mob/user)
		if (active)
			boutput(user, "did you already kill the dummy? either way wait a bit!")
			return

		var/list/dummy_types = list(
			"Naked Dummy" = /mob/living/carbon/human/tdummy,
			"Security Dummy" = /mob/living/carbon/human/tdummy/security,
			// Add more types here
		)

		var/choice = input(user, "Choose a dummy to spawn:", "Dummy Spawner") in dummy_types
		if (!choice)
			return

		var/type_to_spawn = dummy_types[choice]
		if (!type_to_spawn)
			boutput(user, "Invalid dummy type selected.")
			return

		active = 1
		alpha = 128
		boutput(user, "Spawning [choice], stand by") //no need to be rude


		var/mob/living/carbon/human/tdummy/tdu = new type_to_spawn(locate(src.x+1, src.y, src.z))
		tdu.shutup = TRUE
		//T.x = src.x + 1 // move it to the right


		SPAWN(10 SECONDS)
			active = 0
			alpha = 255

	ex_act(severity)
		return


