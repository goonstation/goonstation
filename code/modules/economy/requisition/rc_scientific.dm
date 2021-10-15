ABSTRACT_TYPE(/datum/req_contract/scientific)
/datum/req_contract/scientific

/datum/req_contract/scientific/bigbigfungus
	name = "Fungal Analysis"
	payout = 750
	var/list/desc0 = list("Mycological laboratory","Biological archive service","Exposure test laboratory","Research facility")

	New()
		src.flavor_desc = "[pick(desc0)] seeking additional xenophilic fungus. Precise origin is not required."
		src.payout += rand(0,20) * 10

		var/datum/rc_entry/chungus = new /datum/rc_entry/reagent/fungus
		chungus.count = rand(30,90)
		src.rc_entries += chungus
		..()

/datum/rc_entry/reagent/fungus
	name = "space fungus"
	chemname = "space_fungus"
	feemod = 30

/datum/req_contract/scientific/internalaffairs
	name = "Organ Analysis"
	payout = 2250
	var/list/desc0 = list("conducting","performing","beginning","initiating","seeking supplies for","organizing")
	var/list/desc1 = list("long-term study","intensive trialing","in-depth analysis","study","regulatory assessment")
	var/list/desc2 = list("decay","function","robustness","response to a new medication","atrophy in harsh conditions","therapies","bounciness")

	New()
		var/dombler = pick(concrete_typesof(/datum/rc_entry/itembypath/organ))
		var/datum/rc_entry/organic = new dombler
		organic.count = rand(2,4)
		src.rc_entries += organic

		src.flavor_desc = "An affiliated research group is [pick(desc0)] a [pick(desc1)] of human [organic.name] [pick(desc2)]"
		src.flavor_desc += " and requires specimens in adequate condition."
		src.payout += rand(0,20) * 10
		..()

ABSTRACT_TYPE(/datum/rc_entry/itembypath/organ)
/datum/rc_entry/itembypath/organ
	feemod = 1600
	exactpath = TRUE

/datum/rc_entry/itembypath/organ/appendix
	name = "appendix"
	typepath = /obj/item/organ/appendix

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
