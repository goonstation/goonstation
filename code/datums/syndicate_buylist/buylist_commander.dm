ABSTRACT_TYPE(/datum/syndicate_buylist/commander)
/datum/syndicate_buylist/commander
	name = "You shouldn't see me!"
	cost = 0
	desc = "You shouldn't see me!"
	not_in_crates = TRUE
	can_buy = UPLINK_NUKE_COMMANDER // Fun story here, I made the shit mistake of assuming that surplus crates and spy bounties couldn't roll this, leading to this shit https://imgur.com/a/uMaM0oV

/datum/syndicate_buylist/commander/reinforcement
	name = "Reinforcements"
	items = list(/obj/item/remote/reinforcement_beacon, /obj/item/paper/reinforcement_info)
	cost = 2
	desc = "Request a (probably) top-of-the-line Syndicate gunbot to help assist your team."
	category = "Main"

/datum/syndicate_buylist/commander/ammobag
	name = "Ammo Bag"
	items = list(/obj/item/ammo/ammobox/nukeop)
	cost = 2
	desc = "A bag that allows you to fabricate standard ammo for most Syndicate weaponry. Due to power restrictions, ammo can only be fabricated a certain amount of times per bag. Ammo size restrictions apply."
	category = "Main"

/datum/syndicate_buylist/commander/ammobag_spec
	name = "Specialist Ammo Bag"
	items = list(/obj/item/ammo/ammobox/nukeop/spec_ammo)
	cost = 3
	desc = "A bag that allows you to fabricate specialist ammo for some Syndicate weaponry. It even lets you fabricate explosive ammunition!"
	category = "Main"

/datum/syndicate_buylist/commander/designator
	name = "Laser Designator"
	items = list(/obj/item/device/laser_designator/syndicate, /obj/item/paper/designator_info)
	cost = 3
	desc = "A handheld, monocular laser designator that allows you to call in heavy fire support from the Cairngorm. Comes with 2 charges."
	category = "Main"

/datum/syndicate_buylist/commander/deployment_pods
	name = "Rapid Deployment Remote"
	items = list(/obj/item/device/deployment_remote, /obj/item/paper/deployment_info)
	cost = 2
	desc = "A handheld remote allowing you, your team, and the nuclear device to be sent in anywhere at a moment's notice!"
	category = "Main"

/datum/syndicate_buylist/commander/bomb_remote
	name = "Nuclear Bomb Teleporter"
	items = list(/obj/item/remote/nuke_summon_remote)
	cost = 1
	desc = "Did you lose the nuke? Have no fear, with this handy one-use remote, you can immediately call it back to you!"
	category = "Main"
	vr_allowed = FALSE

/datum/syndicate_buylist/commander/mrl
	name = "Fomalhaut MRL"
	items = list(/obj/item/gun/kinetic/mrl/loaded)
	cost = 3
	desc = "A  6-barrel multiple rocket launcher armed with guided micro-missiles. Warning: Can and will target other Operatives."
	category = "Main"

/datum/syndicate_buylist/commander/capella
	name = "Capella Mk. 8"
	items = list(/obj/item/storage/box/capella)
	cost = 1
	desc = "An extremely accurate competition pistol with two spare clips of match-grade ammo."
	category = "Main"

/datum/syndicate_buylist/commander/alphard
	name = "Alphard recoiling cannon"
	items = list(/obj/item/storage/box/alphard)
	cost = 3
	desc = "A brutally powerful antimateriel cannon on a shortened frame. Capable of piercing multiple walls and airlocks. Beware of shrapnel!"
	category = "Main"
