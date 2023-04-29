
/* -------------------- First Aid Kits -------------------- */

/obj/item/storage/firstaid
	name = "first aid"
	icon_state = "firstaid1"
	inhand_image_icon = 'icons/mob/inhand/hand_storage.dmi'
	throw_speed = 2
	throw_range = 8
	max_wclass = W_CLASS_SMALL // medbot.dm modifies attackby() for firstaid, which effectively reduces max_wclass to 1, EXCEPT for non-chemmaster pill bottles
	var/list/kit_styles = null

	New()
		..()
		SPAWN(0.5 SECONDS)
			if (length(kit_styles))
				icon_state = pick(kit_styles)
				item_state = icon_state


/obj/item/storage/firstaid/regular
	icon_state = "firstaid1"
	item_state = "firstaid1"
	desc = "A general medical kit that contains medical patches for both brute damage and burn damage. Also contains an epinephrine syringe for emergency use and a health analyzer."
	kit_styles = list("firstaid1", "firstaid2", "firstaid3")
	spawn_contents = list(/obj/item/reagent_containers/patch/bruise = 2,\
	/obj/item/reagent_containers/pill/salicylic_acid,\
	/obj/item/reagent_containers/patch/burn = 2,\
	/obj/item/device/analyzer/healthanalyzer,\
	/obj/item/reagent_containers/emergency_injector/epinephrine)

	emergency
		spawn_contents = list(/obj/item/item_box/medical_patches/mini_styptic,\
		/obj/item/item_box/medical_patches/mini_silver_sulf,\
		/obj/item/reagent_containers/pill/menthol,\
		/obj/item/reagent_containers/pill/salicylic_acid,\
		/obj/item/device/analyzer/healthanalyzer/upgraded,\
		/obj/item/reagent_containers/emergency_injector/epinephrine,\
		/obj/item/reagent_containers/emergency_injector/atropine)


	empty
		spawn_contents = list()


/obj/item/storage/firstaid/brute
	name = "brute first aid"
	icon_state = "brute1"
	item_state = "brute1"
	desc = "A medical kit that contains several medical patches and pills for treating brute injuries. Contains one epinephrine syringe for emergency use and a health analyzer."
	kit_styles = list("brute1", "brute2", "brute3", "brute4")
	spawn_contents = list(\
	/obj/item/reagent_containers/patch/bruise = 3,\
	/obj/item/device/analyzer/healthanalyzer,\
	/obj/item/reagent_containers/pill/salicylic_acid,\
	/obj/item/reagent_containers/emergency_injector/epinephrine,\
	/obj/item/bandage/medicated)

/obj/item/storage/firstaid/fire
	name = "fire first aid"
	icon_state = "burn1"
	item_state = "burn1"
	desc = "A medical kit that contains several medical patches and pills for treating burns. Contains one epinephrine syringe for emergency use and a health analyzer."
	kit_styles = list("burn1", "burn2", "burn3", "burn4")
	spawn_contents = list(\
	/obj/item/reagent_containers/patch/burn = 3,\
	/obj/item/device/analyzer/healthanalyzer,\
	/obj/item/reagent_containers/pill/menthol,\
	/obj/item/reagent_containers/pill/salicylic_acid,\
	/obj/item/reagent_containers/emergency_injector/epinephrine)

/obj/item/storage/firstaid/toxin
	name = "toxin first aid"
	icon_state = "toxin1"
	item_state = "toxin1"
	desc = "A medical kit designed to counter radiation and poisoning by common toxins. Contains two pills each of anti-toxin and anti-radiation medicine, a syringe of a powerful purgative, and a health analyzer to determine the health of the patient."
	kit_styles = list("toxin1", "toxin2", "toxin3", "toxin4")
	spawn_contents = list(/obj/item/reagent_containers/emergency_injector/epinephrine,\
	/obj/item/reagent_containers/emergency_injector/charcoal = 1,\
	/obj/item/reagent_containers/pill/antirad = 2,\
	/obj/item/reagent_containers/pill/antitox = 2,\
	/obj/item/device/analyzer/healthanalyzer)

/obj/item/storage/firstaid/oxygen
	name = "oxygen deprivation first aid"
	icon_state = "O21"
	item_state = "O21"
	desc = "A first aid kit that contains three pills and two auto-injectors of salbutamol, which is able to counter injuries caused by suffocation. Also contains a health analyzer to determine the health of the patient."
	kit_styles = list("O21", "O22", "O23", "O24")
	spawn_contents = list(/obj/item/reagent_containers/pill/salbutamol = 3,\
	/obj/item/reagent_containers/emergency_injector/salbutamol = 2,\
	/obj/item/reagent_containers/emergency_injector/epinephrine,\
	/obj/item/device/analyzer/healthanalyzer)

/obj/item/storage/firstaid/brain
	name = "neurological damage first aid"
	icon_state = "brain1"
	item_state = "brain1"
	desc = "A medical kit that contains three pills and two auto-injectors of mannitol, which can heal brain damage. Also contains a health analyzer to determine the health of the patient."
	kit_styles = list("brain1", "brain2", "brain3")
	spawn_contents = list(/obj/item/reagent_containers/pill/mannitol = 3,\
	/obj/item/reagent_containers/emergency_injector/mannitol = 2,\
	/obj/item/reagent_containers/emergency_injector/epinephrine,\
	/obj/item/device/analyzer/healthanalyzer)

/obj/item/storage/firstaid/crit
	name = "emergency critical-condition first aid"
	icon_state = "berserk1"
	item_state = "berserk1"
	desc = "An all-in-one emergency crash-kit designed to bring a critically wounded patient back from the brink of death. Contains cardiac stimulants, cerebral anti-edemics, and blood-oxygenation agents, all in convenient auto-injector form. Also contains an upgraded health analyzer to determine the health of the patient."
	kit_styles = list("berserk1", "berserk2", "berserk3")
	spawn_contents = list(/obj/item/reagent_containers/emergency_injector/mannitol = 1,\
	/obj/item/reagent_containers/emergency_injector/perf = 1,\
	/obj/item/reagent_containers/emergency_injector/atropine = 1,\
	/obj/item/reagent_containers/emergency_injector/saline,\
	/obj/item/reagent_containers/emergency_injector/synaptizine = 1,\
	/obj/item/reagent_containers/emergency_injector/epinephrine = 1,\
	/obj/item/device/analyzer/healthanalyzer)

// Medkit filled with old crud for shady QM merchants (Convair880).
/obj/item/storage/firstaid/old
	name = "dusty first aid kit"
	icon_state = "berserk1"
	item_state = "berserk1"
	desc = "Huh, how old is this thing?"
	kit_styles = list("berserk1", "berserk2", "berserk3")
	spawn_contents = list(/obj/item/medical/ointment = 2,\
	/obj/item/medical/bruise_pack = 2,\
	/obj/item/reagent_containers/emergency_injector/lexorin,\
	/obj/item/reagent_containers/emergency_injector/synaptizine,\
	/obj/item/device/analyzer/healthanalyzer)

/obj/item/storage/firstaid/docbag
	name = "doctor's bag"
	icon_state = "docbag1"
	item_state = "docbag1"
	desc = "A old-fashioned doctor's bag designed to cary medical and surgical supplies."
	kit_styles = list("docbag1", "docbag2", "docbag3")
	spawn_contents = list(/obj/item/circular_saw, /obj/item/scalpel, /obj/item/scissors/surgical_scissors, /obj/item/suture, /obj/item/reagent_containers/syringe, /obj/item/reagent_containers/iv_drip/blood, /obj/item/medicaldiagnosis/stethoscope)

/* -------------------- First Aid Kits - VR -------------------- */

/obj/item/storage/firstaid/vr
	icon = 'icons/effects/VR.dmi'
	item_state = "firstaid-vr"
	kit_styles = null

/obj/item/storage/firstaid/vr/regular
	name = "first aid"
	icon_state = "firstaid-vr"
	desc = "A general medical kit that contains medical patches for both brute damage and burn damage. Also contains an epinephrine syringe for emergency use and a health analyzer."
	spawn_contents = list(/obj/item/reagent_containers/patch/vr/bruise = 2,\
	/obj/item/reagent_containers/pill/vr/salicylic_acid,\
	/obj/item/reagent_containers/patch/vr/burn = 2,\
	/obj/item/device/analyzer/healthanalyzer/vr,\
	/obj/item/reagent_containers/emergency_injector/vr/epinephrine)

/obj/item/storage/firstaid/vr/brute
	name = "brute first aid"
	icon_state = "brute-vr"
	desc = "A medical kit that contains several medical patches and pills for treating brute injuries. Contains one epinephrine syringe for emergency use and a health analyzer."
	spawn_contents = list(/obj/item/reagent_containers/patch/vr/bruise = 4,\
	/obj/item/device/analyzer/healthanalyzer/vr,\
	/obj/item/reagent_containers/emergency_injector/vr/epinephrine,\
	/obj/item/bandage/vr)

/obj/item/storage/firstaid/vr/fire
	name = "fire first aid"
	icon_state = "burn-vr"
	desc = "A medical kit that contains several medical patches and pills for treating burns. Contains one epinephrine syringe for emergency use and a health analyzer."
	spawn_contents = list(/obj/item/reagent_containers/patch/vr/burn = 4,\
	/obj/item/device/analyzer/healthanalyzer/vr,\
	/obj/item/reagent_containers/emergency_injector/vr/epinephrine,\
	/obj/item/reagent_containers/pill/vr/salicylic_acid)

/obj/item/storage/firstaid/vr/toxin
	name = "toxin first aid"
	icon_state = "toxin-vr"
	desc = "A medical kit designed to counter poisoning by common toxins. Contains three pills and syringes, and a health analyzer to determine the health of the patient."
	spawn_contents = list(/obj/item/reagent_containers/syringe/antitoxin = 3,\
	/obj/item/reagent_containers/pill/vr/antitox = 3,\
	/obj/item/device/analyzer/healthanalyzer/vr)

/obj/item/storage/firstaid/vr/oxygen
	name = "oxygen deprivation first aid"
	icon_state = "O2-vr"
	desc = "A first aid kit that contains four pills of salbutamol, which is able to counter injuries caused by suffocation. Also contains a health analyzer to determine the health of the patient."
	spawn_contents = list(/obj/item/reagent_containers/pill/vr/salbutamol = 4,\
	/obj/item/device/analyzer/healthanalyzer/vr)

/obj/item/storage/firstaid/vr/brain
	name = "neurological damage first aid"
	icon_state = "brain-vr"
	desc = "A medical kit that contains four pills of mannitol, which can heal brain damage. Also contains a health analyzer to determine the health of the patient."
	spawn_contents = list(/obj/item/reagent_containers/pill/vr/mannitol = 4,\
	/obj/item/device/analyzer/healthanalyzer/vr)

/* -------------------- Boxes -------------------- */

/obj/item/storage/box/syringes
	name = "syringe box"
	icon_state = "syringe"
	desc = "A box filled with many syringes, empty and sterilized."
	spawn_contents = list(/obj/item/reagent_containers/syringe = 7)

/obj/item/storage/box/beakerbox
	name = "beaker box"
	icon_state = "beaker"
	desc = "A box filled with chemically treated beakers."
	spawn_contents = list(/obj/item/reagent_containers/glass/beaker = 7)

/obj/item/storage/box/patchbox
	name = "patch box"
	icon_state = "patches"
	desc = "A box of chemical patches, able to be injected with chemicals and then applied to a patient."
	spawn_contents = list(/obj/item/reagent_containers/patch = 7)

/obj/item/storage/box/vialbox
	name = "vial box"
	icon_state = "beaker"
	spawn_contents = list(/obj/item/reagent_containers/glass/vial = 7)

/obj/item/storage/box/gl_kit
	name = "prescription glasses box"
	icon_state = "id"
	desc = "A box filled with corrective-lens glasses."
	spawn_contents = list(/obj/item/clothing/glasses/regular = 7)

/obj/item/storage/box/lglo_kit
	name = "latex gloves box"
	icon_state = "latex"
	desc = "A box containing sterile latex gloves."
	spawn_contents = list(/obj/item/clothing/gloves/latex = 7)

/obj/item/storage/box/lglo_kit/random
	New()
		if (prob(50))
			src.spawn_contents = list(pick(25;/obj/item/clothing/gloves/latex/blue,25;/obj/item/clothing/gloves/latex/purple,25;/obj/item/clothing/gloves/latex/teal,25;/obj/item/clothing/gloves/latex/pink) = 7)
		..()

/obj/item/storage/box/injectbox
	name = "DNA injectors"
	icon_state = "box"

/obj/item/storage/box/stma_kit
	name = "sterile masks box"
	icon_state = "latex"
	desc = "A box containing sterile masks to help protect from airborne diseases."
	spawn_contents = list(/obj/item/clothing/mask/surgical = 7)

/obj/item/storage/box/clothing/patient_gowns
	name = "gowns box"
	desc = "A box filled with patient gowns."
	spawn_contents = list(/obj/item/clothing/under/patient_gown = 7)

/obj/item/storage/box/health_upgrade_kit
	name = "health analyzer upgrade box"
	icon_state = "health_upgr"
	desc = "A box containing health analyzer reagent scan upgrade cards."
	spawn_contents = list(/obj/item/device/analyzer/healthanalyzer_upgrade = 7)


/obj/item/storage/box/iv_box
	name = "\improper IV drip box"
	icon_state = "patches"
	desc = "A box of empty, sterile IV drips, ready to be filled with donated blood, or healing chemicals. Or whatever."
	spawn_contents = list(/obj/item/reagent_containers/iv_drip = 7)

/obj/item/storage/box/body_bag
	name = "body bag box"
	icon_state = "trashybs"
	desc = "A box containing body bags*, which, like the name suggests, are used for transporting bodies around. Usually dead ones.<br><small><i>*Bodies not included.</i></small>"
	spawn_contents = list(/obj/item/body_bag = 7)

/* -------------------- Prostheses storage -------------------- */

/obj/item/storage/box/prosthesis_kit
	name = "prosthesis kit"
	icon_state = "health_upgr"
	desc = "A box containing the labelled prosthesis or augmentation."

	eye_normal
		name = "ocular prosthesis kit"
		desc = "A box containing a pair of cybereyes."
		spawn_contents = list(/obj/item/organ/eye/cyber = 2,\
		/obj/item/surgical_spoon = 1)

	eye_sunglasses
		name = "ocular prosthesis kit (polarized)"
		desc = "A box containing a pair of polarized cybereyes."
		spawn_contents = list(/obj/item/surgical_spoon = 1,
		/obj/item/organ/eye/cyber/sunglass = 2)

	eye_sechud
		name = "ocular prosthesis kit (SecHUD)"
		desc = "A box containing a pair of Security HUD cybereyes."
		spawn_contents = list(/obj/item/surgical_spoon = 1,
		/obj/item/organ/eye/cyber/sechud = 2)

	eye_thermal
		name = "ocular prosthesis kit (thermal)"
		desc = "A box containing a pair of thermal imager cybereyes."
		spawn_contents = list(/obj/item/surgical_spoon = 1,
		/obj/item/organ/eye/cyber/thermal = 2)

	eye_meson
		name = "ocular prosthesis kit (meson)"
		desc = "A box containing a pair of mesonic imager cybereyes."
		spawn_contents = list(/obj/item/surgical_spoon = 1,
		/obj/item/organ/eye/cyber/meson = 2)

	eye_spectro
		name = "ocular prosthesis kit (spectroscopic)"
		desc = "A box containing a pair of spectroscopic imager cybereyes."
		spawn_contents = list(/obj/item/surgical_spoon = 1,
		/obj/item/organ/eye/cyber/spectro = 2)

	eye_prodoc
		name = "ocular prosthesis kit (ProDoc)"
		desc = "A box containing a pair of ProDoc Healthview cybereyes."
		spawn_contents = list(/obj/item/surgical_spoon = 1,
		/obj/item/organ/eye/cyber/prodoc = 2)

	eye_ecto
		name = "ocular prosthesis kit (ecto)"
		desc = "A box containing a pair of ectosensor cybereyes."
		spawn_contents = list(/obj/item/surgical_spoon = 1,
		/obj/item/organ/eye/cyber/ecto = 2)

	eye_camera
		name = "ocular prosthesis kit (camera)"
		desc = "A box containing a pair of camera cybereyes."
		spawn_contents = list(/obj/item/surgical_spoon = 1,
		/obj/item/organ/eye/cyber/camera = 2)

	eye_nightvision
		name = "ocular prosthesis kit (night vision)"
		desc = "A box containing a pair of night vision cybereyes."
		spawn_contents = list(/obj/item/surgical_spoon = 1,
		/obj/item/organ/eye/cyber/camera = 2)

	eye_laser
		name = "ocular prosthesis kit (laser)"
		desc = "A box containing a pair of laser cybereyes."
		spawn_contents = list(/obj/item/surgical_spoon = 1,
		/obj/item/organ/eye/cyber/laser = 2)

	eye_random // random selection of two eyes!  woo
		name = "ocular prosthesis kit (surplus)"
		desc = "A box containing some surplus cybereyes. Here's hoping they match!"
		spawn_contents = list(/obj/item/surgical_spoon = 1)
		make_my_stuff()
			..()
			var/list/eyez = typesof(/obj/item/organ/eye/cyber)
			if (eyez.len)
				for (var/i=rand(2,3), i>0, i--)
					var/epath = pick(eyez)
					new epath(src)

/* -------------------- Wall Storage -------------------- */

/obj/item/storage/wall/medical
	name = "medical supplies"
	desc = "A wall-mounted storage container that has a few medical supplies in it."
	icon_state = "minimed"
	spawn_contents = list()



	make_my_stuff()
		..()
		new /obj/item/bandage(src)
		new /obj/item/storage/pill_bottle/salicylic_acid(src)
		new /obj/item/storage/pill_bottle/menthol(src)

		if (prob(40))
			new /obj/item/storage/firstaid/regular(src)
		if (prob(40))
			new /obj/item/reagent_containers/glass/bottle/ethanol(src)

		switch (weighted_pick(list("gloves" = 20, "mask" = 20, "autoinjector" = 10, "both" = 10)))
			if ("gloves")
				new /obj/item/clothing/gloves/latex(src)
			if ("mask")
				new /obj/item/clothing/mask/surgical(src)
			if ("autoinjector")
				new /obj/item/reagent_containers/emergency_injector/spaceacillin(src)
			if ("both")
				new /obj/item/clothing/gloves/latex(src)
				new /obj/item/clothing/mask/surgical(src)

/* -------------------- Pill Bottles - Medical -------------------- */

/obj/item/storage/pill_bottle/silver_sulfadiazine
	name = "pill bottle (silver sulfadiazine)"
	desc = "Contains pills used to treat burns."
	spawn_contents = list(/obj/item/reagent_containers/pill/silver_sulfadiazine = 7)

/obj/item/storage/pill_bottle/antitox
	name = "pill bottle (charcoal)"
	desc = "Contains pills used to counter toxins."
	spawn_contents = list(/obj/item/reagent_containers/pill/antitox = 7)

/obj/item/storage/pill_bottle/epinephrine
	name = "pill bottle (epinephrine)"
	desc = "Contains pills used to stabilize patients."
	spawn_contents = list(/obj/item/reagent_containers/pill/epinephrine = 7)

/obj/item/storage/pill_bottle/mutadone
	name = "pill bottle (mutadone)"
	desc = "Contains pills used to treat genetic abnormalities."
	spawn_contents = list(/obj/item/reagent_containers/pill/mutadone = 7)

/obj/item/storage/pill_bottle/antirad
	name = "pill bottle (potassium iodide)"
	desc = "Contains pills ued to treat radiation poisoning."
	spawn_contents = list(/obj/item/reagent_containers/pill/antirad = 7)

/obj/item/storage/pill_bottle/salbutamol
	name = "pill bottle (salbutamol)"
	desc = "Contains pills used to counter oxygen damage."
	spawn_contents = list(/obj/item/reagent_containers/pill/salbutamol = 7)

/obj/item/storage/pill_bottle/salicylic_acid
	name = "pill bottle (analgesic)"
	desc = "Contains pills used to treat pain and fevers."
	spawn_contents = list(/obj/item/reagent_containers/pill/salicylic_acid = 7)

/obj/item/storage/pill_bottle/menthol
	name = "pill bottle (menthol)"
	desc = "Contains pills used to treat burns and fevers."
	spawn_contents = list(/obj/item/reagent_containers/pill/menthol = 7)

/obj/item/storage/pill_bottle/ipecac
	name = "pill bottle (space ipecac)"
	desc = "Contains pills used induce emesis."
	spawn_contents = list(/obj/item/reagent_containers/pill/ipecac = 7)

/obj/item/storage/pill_bottle/mannitol
	name = "pill bottle (mannitol)"
	desc = "Contains pills used to treat... brain damage."
	spawn_contents = list(/obj/item/reagent_containers/pill/mannitol = 7)

/* -------------------- Pill Bottles - Drugs -------------------- */

/obj/item/storage/pill_bottle/methamphetamine
	name = "pill bottle (methamphetamine)"
	desc = "Methamphetamine is a highly effective and dangerous stimulant drug."
	spawn_contents = list(/obj/item/reagent_containers/pill/methamphetamine = 5)

/obj/item/storage/pill_bottle/crank
	name = "pill bottle (crank)"
	desc = "A cheap and dirty stimulant drug, commonly used by space biker gangs."
	spawn_contents = list(/obj/item/reagent_containers/pill/crank = 5)

/obj/item/storage/pill_bottle/bathsalts
	name = "pill bottle (bath salts)"
	desc = "Sometimes packaged as a refreshing bathwater additive, these crystals are definitely not for human consumption."
	spawn_contents = list(/obj/item/reagent_containers/pill/bathsalts = 5)

/obj/item/storage/pill_bottle/catdrugs
	name = "pill bottle (cat drugs)"
	desc = "Uhh..."
	spawn_contents = list(/obj/item/reagent_containers/pill/catdrugs = 5)

/obj/item/storage/pill_bottle/hairgrownium
	name = "pill bottle (EZ-Hairgrowth)"
	desc = "The #1 hair growth product on the market! WARNING: Some side effects may occur."
	spawn_contents = list(/obj/item/reagent_containers/pill/hairgrownium = 6)

/obj/item/storage/pill_bottle/cyberpunk
	name = "pill bottle (???)"
	desc = "Huh."
	spawn_contents = list(/obj/item/reagent_containers/pill/cyberpunk = 5)

/obj/item/storage/pill_bottle/custom_suicide = 1
/obj/item/storage/pill_bottle/suicide(var/mob/user as mob)
	if (!src.user_can_suicide(user))
		return 0
	user.visible_message("<span class='alert'><b>[user] swallows [src] whole and begins to choke!</b></span>")
	user.take_oxygen_deprivation(175)
	qdel(src)
	return 1
