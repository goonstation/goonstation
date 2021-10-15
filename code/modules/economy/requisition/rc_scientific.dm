ABSTRACT_TYPE(/datum/req_contract/scientific)
/datum/req_contract/scientific

/datum/req_contract/scientific/bigbigfungus
	var/name = "Fungal Analysis"
	var/payout = 500

	New()
		src.flavor_desc = "Mycological laboratory seeking additional xenophilic fungus. Precise origin is irrelevant."
		src.payout += rand(0,10) * 10

		var/chungus = new /datum/rc_entry/reagent_fungus
		chungus.count = rand(40,100)
		src.rc_entries += chungus
		..()

/datum/rc_entry/reagent/fungus
	name = "space fungus"
	chemname = "space_fungus"
	feemod = 50
