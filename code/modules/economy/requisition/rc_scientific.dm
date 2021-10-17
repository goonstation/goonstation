ABSTRACT_TYPE(/datum/req_contract/scientific)
/datum/req_contract/scientific //adam savage dense gas voice: it's scientific!
	req_class = 3

/datum/req_contract/scientific/internalaffairs //get it?
	name = "Don't Ask Too Many Questions"
	payout = 1750
	var/list/namevary = list("Organ Analysis","Organ Research","Biolab Supply","Biolab Partnership","ERROR: CANNOT VERIFY ORIGIN")
	var/list/desc0 = list("conducting","performing","beginning","initiating","seeking supplies for","organizing")
	var/list/desc1 = list("long-term study","intensive trialing","in-depth analysis","study","regulatory assessment")
	var/list/desc2 = list("decay","function","robustness","response to a new medication","atrophy in harsh conditions","therapies","bounciness")

	New()
		src.name = pick(namevary)
		var/dombler = pick(concrete_typesof(/datum/rc_entry/itembypath/organ))
		var/datum/rc_entry/organic = new dombler
		organic.count = rand(2,4)
		src.rc_entries += organic

		src.flavor_desc = "An affiliated research group is [pick(desc0)] a [pick(desc1)] of [organic.name] [pick(desc2)]"
		src.flavor_desc += " and requires genetically-human specimens in adequate condition."
		src.payout += rand(0,40) * 10
		..()

ABSTRACT_TYPE(/datum/rc_entry/itembypath/organ)
/datum/rc_entry/itembypath/organ
	feemod = 1600
	exactpath = TRUE

/datum/rc_entry/itembypath/organ/appendix
	name = "appendix"
	typepath = /obj/item/organ/appendix
	es = TRUE

/datum/rc_entry/itembypath/organ/brain
	name = "brain"
	typepath = /obj/item/organ/brain

/datum/rc_entry/itembypath/organ/heart
	name = "heart"
	typepath = /obj/item/organ/heart

/datum/rc_entry/itembypath/organ/liver
	name = "liver"
	typepath = /obj/item/organ/liver

/datum/rc_entry/itembypath/organ/spleen
	name = "spleen"
	typepath = /obj/item/organ/spleen


/datum/req_contract/scientific/spectrometry
	name = "Totally Will Not Result In A Resonance Cascade"
	payout = 750
	var/list/namevary = list("Beamline Calibration","Spectral Analysis","Chromatic Analysis","Refraction Survey")
	var/list/desc0 = list(
		"Optics calibration laboratory",
		"Field laboratory at crystal excavation site",
		"Anti-mass spectrometry platform",
		"Transmission laser prototyping facility",
		"Classified research operation",
		"An affiliated research facility is",
		"An affiliated research vessel is",
		"An affiliated research outpost is"
	)
	var/list/desc1 = list("micro-reflection","latticed capacitive crystal","photonic data encoding","telecrystal stabilization")
	var/list/desc2 = list(
		null,
		" Ensure all materials are free of flammable particulates.",
		" Please use shock-absorbent packing material if possible.",
		" Discussion of this contract with nonessential personnel is discouraged.",
		" If possible, verify all included materials with a third-party quality assessor.",
		" Any damage to included materials not caused by shipping will be reported to your regional manager."
	)

	New()
		src.name = pick(namevary)
		src.flavor_desc = "[pick(desc0)] seeking vital components for [pick(desc1)] research.[pick(desc2)]"
		src.payout += rand(0,40) * 10

		if(prob(80)) src.rc_entries += rc_buildentry(/datum/rc_entry/stack/gemstone,rand(1,8))
		if(prob(20)) src.rc_entries += rc_buildentry(/datum/rc_entry/stack/telec,rand(1,3))
		if(prob(50)) src.rc_entries += rc_buildentry(/datum/rc_entry/reagent/cryox,rand(4,10)*5)
		if(prob(40)) src.rc_entries += rc_buildentry(/datum/rc_entry/itembypath/lambdarod,1)
		if(!length(src.rc_entries) || prob(70)) src.rc_entries += rc_buildentry(/datum/rc_entry/itembypath/lens,rand(2,6))

		..()

/datum/rc_entry/itembypath/lens
	name = "lens"
	typepath = /obj/item/lens
	feemod = 260
	es = TRUE

/datum/rc_entry/stack/gemstone
	name = "non-anomalous gemstone"
	typepath = /obj/item/raw_material/gemstone
	feemod = 420

/datum/rc_entry/stack/telec
	name = "telecrystal"
	typepath = /obj/item/raw_material/telecrystal
	typepath_alt = /obj/item/material_piece/telecrystal
	feemod = 620

/datum/rc_entry/reagent/cryox
	name = "cryoxadone coolant"
	chemname = "cryoxadone"
	feemod = 30

/datum/rc_entry/itembypath/lambdarod
	name = "Lambda phase-control rod"
	typepath = /obj/item/interdictor_rod
	exactpath = TRUE
	feemod = 1000

