/obj/artifact/implanter
	name = "artifact implanter"
	associated_datum = /datum/artifact/implanter

/datum/artifact/implanter
	associated_object = /obj/artifact/implanter
	type_name = "Implanter"
	rarity_weight = 250
	validtypes = list("eldritch", "ancient", "wizard")
	validtriggers = list(/datum/artifact_trigger/force,/datum/artifact_trigger/electric,/datum/artifact_trigger/heat,
	/datum/artifact_trigger/radiation,/datum/artifact_trigger/carbon_touch,/datum/artifact_trigger/silicon_touch,
	/datum/artifact_trigger/cold)
	fault_blacklist = list(ITEM_ONLY_FAULTS)
	activ_text = "opens up, revealing a complex array of thin tubes!"
	deact_text = "closes itself up."
	react_xray = list(9, 70, 75, 11, "SEGMENTED")

	var/obj/item/implant/artifact/imp = null
	var/ready = TRUE
	var/list/implantedUsers = list()

	effect_touch(var/obj/O, var/mob/living/user)
		if (..())
			return
		if (!isliving(user) || !ishuman(user))
			return

		var/mob/living/carbon/human/H = user

		if (notReady)
			boutput(H, "<b>[O]</b> shifts slightly but remains inactive.")
			return

		if (user.key in implantedUsers)
			boutput(H, "<b>[O]</b> stays still.")
			return

		implantedUsers += user.key

		switch(artitype.name)
			if ("eldritch")
				var/eldritchImp = pick(/obj/item/implant/artifact/eldritch/eldritch_good, /obj/item/implant/artifact/eldritch/eldritch_gimmick, /obj/item/implant/artifact/eldritch/eldritch_bad)
				imp = new eldritchImp
			if ("silicon")
				var/siliconImp = pick(/obj/item/implant/artifact/ancient/ancient_good, /obj/item/implant/artifact/ancient/ancient_gimmick, /obj/item/implant/artifact/ancient/ancient_bad)
				imp = new siliconImp
			else
				var/wizardImp = pick(/obj/item/implant/artifact/wizard/wizard_good, /obj/item/implant/artifact/wizard/wizard_gimmick, /obj/item/implant/artifact/wizard/wizard_bad)
				imp = new wizardImp

		H.implant.Add(imp)
		imp.set_loc(H)
		imp.implanted(H, user)

		O.ArtifactFaultUsed(H)

		var/turf/T = get_turf(O)
		T.visible_message("<b>[O]</b> shoots a small object into [user]!")

		ready = FALSE

		SPAWN(2 MINUTES) ready = TRUE
