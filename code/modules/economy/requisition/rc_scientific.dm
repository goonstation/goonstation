ABSTRACT_TYPE(/datum/req_contract/scientific)
/datum/req_contract/scientific

/datum/req_contract/scientific/bigbigfungus
	name = "Fungal Analysis"
	payout = 500
	var/list/desc0 = list("Mycological laboratory","Biological archive service","Exposure test laboratory","Research facility")

	New()
		src.flavor_desc = "[pick(desc0)] seeking additional xenophilic fungus. Precise origin is not required."
		src.payout += rand(0,10) * 10

		var/datum/rc_entry/chungus = new /datum/rc_entry/reagent/fungus
		chungus.count = rand(40,100)
		src.rc_entries += chungus
		..()

/datum/rc_entry/reagent/fungus
	name = "space fungus"
	chemname = "space_fungus"
	feemod = 40
