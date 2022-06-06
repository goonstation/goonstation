/obj/artifact/limb_augmentor
	name = "artifact limb augmentor"
	associated_datum = /datum/artifact/limb_augmentor

/datum/artifact/limb_augmentor
	associated_object = /obj/artifact/limb_augmentor
	type_name = "Limb augmentor"
	rarity_weight = 200
	validtypes = list("eldritch", "martian", "precursor")
	validtriggers = list(/datum/artifact_trigger/force,/datum/artifact_trigger/electric,/datum/artifact_trigger/heat,
	/datum/artifact_trigger/radiation,/datum/artifact_trigger/carbon_touch,/datum/artifact_trigger/silicon_touch,
	/datum/artifact_trigger/cold)
	fault_blacklist = list(ITEM_ONLY_FAULTS)
	activ_text = "opens up, revealing several large slots!"
	deact_text = "closes itself up."
	react_xray = list(5, 89, 49, 11, "SEGMENTED")

	var/ready = TRUE
	var/rechargeTime = null
	var/list/limbSet = list()
	var/list/uses = list()
	var/static/list/replace_sounds = list('sound/impact_sounds/Flesh_Stab_1.ogg', 'sound/impact_sounds/Slimy_Splat_1.ogg', 'sound/impact_sounds/Flesh_Tear_2.ogg', 'sound/impact_sounds/Slimy_Hit_3.ogg')

	New()
		..()
		rechargeTime = pick(30, 60) SECONDS

	post_setup()
		. = ..()
		switch(artitype.name)
			if ("eldritch")
				limbSet["l_arm"] = /obj/item/parts/artifact_parts/arm/eldritch/left
				limbSet["r_arm"] = /obj/item/parts/artifact_parts/arm/eldritch/right
				limbSet["l_leg"] = /obj/item/parts/artifact_parts/leg/eldritch/left
				limbSet["r_leg"] = /obj/item/parts/artifact_parts/leg/eldritch/right
			if ("martian")
				limbSet["l_arm"] = /obj/item/parts/artifact_parts/arm/martian/left
				limbSet["r_arm"] = /obj/item/parts/artifact_parts/arm/martian/right
				limbSet["l_leg"] = /obj/item/parts/artifact_parts/leg/martian/left
				limbSet["r_leg"] = /obj/item/parts/artifact_parts/leg/martian/right
			if ("precursor")
				limbSet["l_arm"] = /obj/item/parts/artifact_parts/arm/precursor/left
				limbSet["r_arm"] = /obj/item/parts/artifact_parts/arm/precursor/right
				limbSet["l_leg"] = /obj/item/parts/artifact_parts/leg/precursor/left
				limbSet["r_leg"] = /obj/item/parts/artifact_parts/leg/precursor/right

	effect_touch(obj/O, mob/living/user)
		if (..())
			return
		if (!ishuman(user))
			return

		var/mob/living/carbon/human/H = user

		if (!ready)
			boutput(H, "<b>[O]</b> churns a little but remains inactive.")
			return

		if (src.check_cannot_use(H))
			boutput(H, "<b>[O]</b> stays silent.")
			return

		var/turf/T = get_turf(O)
		var/limb_to_replace = src.get_limb_to_replace(H)
		var/obj/item/parts/current_limb = H.limbs.get_limb(limb_to_replace)

		T.visible_message("<span class='alert'><b>[O]</b> suddenly unleashes an array of tools and pulls [H.name]'s [current_limb ? current_limb.name + " inside!": "body to it!"]</span>")

		H.changeStatus("paralysis", 4 SECONDS)
		for (var/i in 1 to 3)
			if (get_dist(O, H) > 1)
				return
			playsound(get_turf(H), pick(replace_sounds), 50, TRUE)
			H.TakeDamage("chest", rand(6, 8), 0, 0, DAMAGE_CUT)
			sleep(1 SECOND)

		if (get_dist(O, H) > 1)
			return

		if (current_limb)
			current_limb.remove(FALSE)
		H.limbs.replace_with(limb_to_replace, limbSet[limb_to_replace], null, FALSE)
		H.update_body()

		boutput(H, "<span class='alert'><b>[pick("FUCK!!!", "OH GOD!", "JESUS FUCK!")]</b></span>")
		H.emote("scream")
		bleed(H, 10, 10)

		T.visible_message("<span class='alert'><b>[O]</b> releases its hold of [H.name]!</b></span>")

		O.ArtifactFaultUsed(H)
		uses[H.bioHolder.uid_hash]++

		ready = FALSE
		T.visible_message("<b>[O]</b> closes its slots.")

		SPAWN(rechargeTime)
			ready = TRUE
			T = get_turf(O)
			T.visible_message("<b>[O]</b> opens its slots up again.")

	proc/check_cannot_use(mob/living/carbon/human/H)
		return uses[H.bioHolder.uid_hash] == 2 || (istype(H.limbs.get_limb("l_arm"), limbSet["l_arm"]) && (istype(H.limbs.get_limb("r_arm"), limbSet["r_arm"]) && istype(H.limbs.get_limb("l_leg"), limbSet["l_leg"]) && istype(H.limbs.get_limb("r_leg"), limbSet["r_leg"])))

	proc/get_limb_to_replace(mob/living/carbon/human/H)
		var/list/valid_limbs = list()
		for (var/limb in list("l_arm", "r_arm", "l_leg", "r_leg"))
			if (!istype(H.limbs.get_limb(limb), limbSet[limb]))
				valid_limbs += limb

		if (("l_arm" in valid_limbs) && !("r_arm" in valid_limbs))
			return "l_arm"
		if (!("l_arm" in valid_limbs) && ("r_arm" in valid_limbs))
			return "r_arm"
		if (("l_leg" in valid_limbs) && !("r_leg" in valid_limbs))
			return "l_leg"
		if (!("l_leg" in valid_limbs) && ("r_leg" in valid_limbs))
			return "r_leg"
		return pick(valid_limbs)
