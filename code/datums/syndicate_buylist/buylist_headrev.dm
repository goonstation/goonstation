ABSTRACT_TYPE(/datum/syndicate_buylist/generic/head_rev)
/datum/syndicate_buylist/generic/head_rev
	name = "Head Rev Buylist Parent"
	cost = 0
	desc = "You shouldn't see me!"
	not_in_crates = TRUE
	vr_allowed = FALSE
	can_buy = UPLINK_HEAD_REV

/datum/syndicate_buylist/generic/head_rev/revflash
	name = "Revolutionary Flash"
	items = list(/obj/item/device/flash/revolution)
	cost = 5
	desc = "This flash never runs out and will convert susceptible crew when a rev head uses it. It will also allow the rev head to break counter-revolutionary implants."
	vr_allowed = FALSE
	not_in_crates = TRUE

/datum/syndicate_buylist/generic/head_rev/revflashbang
	name = "Revolutionary Flashbang"
	items = list(/obj/item/chem_grenade/flashbang/revolution)
	cost = 2
	desc = "This single-use flashbang will convert all crew within range, but only shatter the loyalty implants of crew who have them. It doesn't matter who primes the flash - but crew will need a few seconds after a flashbang to respond to another."

/datum/syndicate_buylist/generic/head_rev/revsign
	name = "Revolutionary Sign"
	items = list(/obj/item/revolutionary_sign)
	cost = 4
	desc = "This large revolutionary sign will inspire all nearby revolutionaries and grant them small combat buffs. Additionally the sign will channel the fury of nearby revolutionaries to provide greater force when the sign is swung! Best used in conjunction with a horde of angry revolutionaries."

/datum/syndicate_buylist/generic/head_rev/rev_dagger
	name = "Sacrificial Dagger"
	items = list(/obj/item/dagger)
	cost = 2
	desc = "An ornamental dagger for stabbing people with."

/datum/syndicate_buylist/generic/head_rev/rev_normal_flash
	name = "Flash"
	items = list(/obj/item/device/flash)
	cost = 1
	desc = "Just a standard-issue flash. Won't remove implants like the Revolutionary Flash."
