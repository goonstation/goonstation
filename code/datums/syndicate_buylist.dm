proc/build_syndi_buylist_cache()
	var/list/stuff = typesof(/datum/syndicate_buylist)
	syndi_buylist_cache.Cut()
	for(var/SB in stuff)
		syndi_buylist_cache += new SB

	for (var/datum/syndicate_buylist/LE in syndi_buylist_cache)
		if (!LE.cost || !isnum(LE.cost) || LE.cost <= 0)
			syndi_buylist_cache.Remove(LE)

	syndi_buylist_cache = sortList(syndi_buylist_cache)

// How to add new items? Pick the correct path (nukeops, traitor, surplus) and go from there. Easy.

/datum/syndicate_buylist
	var/name = null
	var/item = null
	var/item2 = null
	var/item3 = null
	var/cost = null // Cost of the item. Leave 0 to make it unavailable.
	var/desc = null
	var/list/job = null // For job-specific items.
	var/datum/objective/objective = null // For objective-specific items. Needs to be a type e.g. /datum/objective/assassinate.
	var/list/blockedmode = null // For items that can't show up in certain modes (affects uplink and surplus crates). Defined by the game mode datum (checks for children too).
	var/list/exclusivemode = null
	var/vr_allowed = 1
	var/not_in_crates = 0 // This should not go in surplus crates.

	proc/run_on_spawn(obj/item, mob/living/owner, in_surplus_crate=FALSE) // Use this to run code when the item is spawned.
		return

////////////////////////////////////////// Standard items (generic & nukeops uplink) ///////////////////////////////

// Note: traitor uplinks also list these, so you don't have to make two separate entries.
// Note #2: Nuke ops-exclusive item: /datum/syndicate_buylist/traitor + "objective = /datum/objective/specialist/nuclear".

/datum/syndicate_buylist/generic
	name = "You shouldn't see me!"
	cost = 0
	desc = "You shouldn't see me!"

/datum/syndicate_buylist/generic/revolver
	name = "Revolver"
	item = /obj/item/storage/box/revolver
	cost = 6
	desc = "The traditional sidearm of a Syndicate field agent. Holds 7 rounds and comes with extra ammo."
	blockedmode = list(/datum/game_mode/spy, /datum/game_mode/revolution)

/datum/syndicate_buylist/generic/pistol
	name = "Suppressed .22 Pistol"
	item = /obj/item/storage/box/pistol
	cost = 3
	desc = "A fairly weak yet sneaky pistol, it can still be heard but it won't alert anyone about who fired it."
	blockedmode = list(/datum/game_mode/revolution)

/datum/syndicate_buylist/generic/shotgun
	name = "Shotgun"
	item = /obj/item/storage/box/shotgun
	cost = 8
	desc = "Not exactly stealthy, but it'll certainly make an impression."
	not_in_crates = 1
	blockedmode = list(/datum/game_mode/spy, /datum/game_mode/revolution)

/datum/syndicate_buylist/generic/radbow
	name = "Rad Poison Crossbow"
	item = /obj/item/gun/energy/crossbow
	cost = 3
	desc = "Crossbow Model C - Now with safer Niobium core. This ranged weapon is great for hitting someone in a dark corridor! They'll never know what hit em! Will slowly recharge between shots."
	blockedmode = list(/datum/game_mode/revolution)

/datum/syndicate_buylist/generic/garrote
	name = "Fibre Wire"
	item = /obj/item/garrote
	cost = 3
	desc = "Commonly used by special forces for silent removal of isolated targets. Ensure you are out of sight, apply to the target's neck from behind with a firm two-hand grip and wait for death to occur."
	blockedmode = list(/datum/game_mode/revolution)



/datum/syndicate_buylist/generic/empgrenades
	name = "EMP Grenades"
	item = /obj/item/storage/box/emp_kit
	cost = 1
	desc = "A pack of EMP grenades, each capable of causing havoc with the electrical and computer systems found aboard the modern space station. Shorts out power systems, causes feedback in electronic vision devices such as thermals, and causes robots to go haywire."
	blockedmode = list(/datum/game_mode/spy)

/datum/syndicate_buylist/generic/tacticalgrenades
	name = "Tactical Grenades"
	item = /obj/item/storage/box/tactical_kit
	cost = 2
	desc = "A box of assorted special-ops grenades."
	blockedmode = list(/datum/game_mode/revolution)

/datum/syndicate_buylist/generic/voicechanger
	name = "Voice Changer"
	item = /obj/item/voice_changer
	cost = 1
	desc = "This voice-modulation device will dynamically disguise your voice to that of whoever is listed on your identification card, via incredibly complex algorithms. Discretely fits inside most masks, and can be removed with wirecutters."
	blockedmode = list(/datum/game_mode/revolution)

/datum/syndicate_buylist/generic/chamsuit
	name = "Chameleon Jumpsuit"
	item = /obj/item/clothing/under/chameleon
	cost = 1
	desc = "A jumpsuit made of advanced fibres that can change colour to suit the needs of the wearer. Do not expose to electromagnetic interference."
	blockedmode = list(/datum/game_mode/revolution)

/datum/syndicate_buylist/generic/syndicard
	name = "Agent Card"
	item = /obj/item/card/id/syndicate
	cost = 1
	desc = "A counterfeit identification card, designed to prevent tracking by the station's AI systems. It features a one-time programmable identification circuit, allowing the entry of a custom false identity. It is also capable of scanning other ID cards and replicating their access credentials."
	blockedmode = list(/datum/game_mode/revolution)

/datum/syndicate_buylist/generic/emag
	name = "Electromagnet Card (EMAG)"
	item = /obj/item/card/emag
	cost = 6
	desc = "A sophisticated tool of sabotage and infiltration. Capable of shorting out or otherwise bypassing security on door locks, robot friend/foe identification systems, shuttle control consoles, and more!"
	blockedmode = list(/datum/game_mode/spy, /datum/game_mode/revolution)

/datum/syndicate_buylist/generic/fimplant
	name = "Freedom Implant"
	item = /obj/item/implanter/freedom
	cost = 1
	desc = "An implant that allows instant escape from handcuffs and shackles. Multiple uses possible but not guaranteed."
	blockedmode = list(/datum/game_mode/revolution)

/datum/syndicate_buylist/generic/spen
	name = "Sleepy Pen"
	item = /obj/item/pen/sleepypen
	cost = 5
	desc = "A small pen that has a syringe filled with a powerful sleeping agent inside. Capable of injecting a victim discretely. Refillable once initial contents are used up."
	blockedmode = list(/datum/game_mode/revolution)

/datum/syndicate_buylist/generic/jammer
	name = "Signal Jammer"
	item = /obj/item/radiojammer
	cost = 3
	desc = "Silences radios in an area around you while activated. No one will hear them scream."
	blockedmode = list(/datum/game_mode/revolution)

/datum/syndicate_buylist/generic/psink
	name = "Power Sink"
	item = /obj/item/device/powersink
	cost = 5
	desc = "Lights too bright? Airlocks too automatic? Alarms too functional? Or maybe just nostalgic about the good ol' days before electricity came along? The XL-100 Power Sink addresses all these ills and more. Simply screw to the nearest exposed wiring and flip the switch, and this little wonder will get to work on draining all of that nasty power."
	not_in_crates = 1
	blockedmode = list(/datum/game_mode/spy, /datum/game_mode/revolution)

/datum/syndicate_buylist/generic/detomatix
	name = "Detomatix Cartridge"
	item = /obj/item/disk/data/cartridge/syndicate
	cost = 1
	desc = "A PDA cartridge allowing remote detonation of other devices. Detonation programs may be accessed through the file manager. Comes complete with readme file."
	blockedmode = list(/datum/game_mode/spy, /datum/game_mode/revolution)

/datum/syndicate_buylist/generic/trickcigs
	name = "Trick Cigarettes"
	item = /obj/item/cigpacket/syndicate
	cost = 1
	desc = "A pack of Syndicool Lights exploding trick cigarettes. Due to the use of a military-grade explosive, please do not attempt to smoke these after lighting."
	blockedmode = list(/datum/game_mode/revolution)

/datum/syndicate_buylist/generic/dnascram
	name = "DNA Scrambler"
	item = /obj/item/genetics_injector/dna_scrambler
	cost = 1
	desc = "An injector that gives a new, random identity upon injection."
	blockedmode = list(/datum/game_mode/revolution)

/datum/syndicate_buylist/generic/derringer
	name = "Derringer"
	item = /obj/item/gun/kinetic/derringer
	cost = 2
	desc = "A small pistol that can be hidden inside worn clothes and retrieved using the wink emote. Comes with two shots and does extreme damage at close range."
	blockedmode = list(/datum/game_mode/revolution)

/datum/syndicate_buylist/generic/stealthstorage
	name = "Stealth Storage"
	item = /obj/item/storage/box/syndibox
	cost = 1
	desc = "This little wonder is capable of not only safely storing most small goods, but it can also be tapped against other objects in order to emulate their appearance. Note: May not perform optimally upon close inspection."
	blockedmode = list(/datum/game_mode/revolution)

/datum/syndicate_buylist/generic/esword
	name = "Cyalume Saber"
	item = /obj/item/sword
	cost = 7
	desc = "A powerful melee weapon, crafted using the latest in applied photonics! When inactive, it is small enough to fit in a pocket!"
	not_in_crates = 1
	blockedmode = list(/datum/game_mode/spy, /datum/game_mode/revolution)

/datum/syndicate_buylist/generic/katana
	name = "Katana"
	item = /obj/item/katana_sheath
	cost = 7
	desc = "A Japanese sword created in the fire of a dying star. Comes with a sheath for easier storage"
	blockedmode = list(/datum/game_mode/spy, /datum/game_mode/revolution)

/datum/syndicate_buylist/generic/wrestling
	name = "Wrestling Belt"
	item = /obj/item/storage/belt/wrestling
	cost = 7
	desc = "A haunted antique wrestling belt, imbued with the spirits of wrestlers past. Wearing it unlocks a number of wrestling moves, which can be accessed in a separate command tab."
	blockedmode = list(/datum/game_mode/revolution)

/datum/syndicate_buylist/generic/spy_sticker_kit
	name = "Spy Sticker Kit"
	item = /obj/item/storage/box/spy_sticker_kit
	cost = 1
	desc = "This kit contains innocuous stickers that you can use to broadcast audio and observe a video feed wirelessly."
	blockedmode = list(/datum/game_mode/revolution)

/datum/syndicate_buylist/generic/omnitool
	name = "Syndicate Omnitool"
	item = /obj/item/tool/omnitool/syndicate
	cost = 2
	desc = "A miniature set of tools that you can hide in your clothing and retrieve with the flex emote. Has knife and weldingtool modes."
	blockedmode = list(/datum/game_mode/revolution)

/datum/syndicate_buylist/generic/bighat
	name = "Syndicate Hat"
	item = /obj/item/clothing/head/bighat/syndicate
	cost = 12
	desc = "Think you're tough shit buddy?"
	not_in_crates = 1 //see /datum/syndicate_buylist/surplus/bighat


//////////////////////////////////////////////////// Standard items (traitor uplink) ///////////////////////////////////

/datum/syndicate_buylist/traitor
	name = "You shouldn't see me!"
	cost = 0
	desc = "You shouldn't see me!"

/datum/syndicate_buylist/traitor/cloak
	name = "Cloaking Device"
	item = /obj/item/cloaking_device
	cost = 6
	//not_in_crates = 1
	desc = "Hides you from normal sight. AI and Cyborgs will still see you and so will any human with thermals so be careful how you use it."
	blockedmode = list(/datum/game_mode/spy, /datum/game_mode/revolution)

/datum/syndicate_buylist/traitor/sponge_capsules
	name = "Syndicate Sponge Capsules"
	item = /obj/item/spongecaps/syndicate
	cost = 3
	desc = "A pack of sponge capsules that react with water and produce nasty critters."
	blockedmode = list(/datum/game_mode/revolution)

/datum/syndicate_buylist/traitor/bomb
	name = "Syndicates in Pipebomb"
	item = /obj/item/pipebomb/bomb/miniature_syndicate
	cost = 3
	desc = "A rather volatile pipe bomb packed with miniature syndicate troops."
	blockedmode = list(/datum/game_mode/spy, /datum/game_mode/revolution)

/datum/syndicate_buylist/traitor/champrojector
	name = "Chameleon Projector"
	item = /obj/item/device/chameleon
	cost = 2
	desc = "Advanced cloaking device that scans an object and, when activated, makes the bearer look like the object. Slows movement while in use."
	blockedmode = list(/datum/game_mode/revolution)

/datum/syndicate_buylist/traitor/areacloak
	name = "Cloaking Field Generator"
	item = /obj/item/cloak_gen
	cost = 3
	desc = "Remote-controlled device that produces an area of effect cloaking field while active. Don't loose the remote!"
	blockedmode = list(/datum/game_mode/revolution)

/datum/syndicate_buylist/traitor/floorcloset
	name = "Floor Closet"
	item = /obj/storage/closet/syndi
	cost = 1
	desc = "This closet was produced using the finest in applied optical illusion technology. When closed, it will dynamically assume the appearance of the floor tile underneath."
	blockedmode = list(/datum/game_mode/revolution)

/datum/syndicate_buylist/traitor/snidely
	name = "Fake Moustache"
	item = /obj/item/clothing/mask/moustache
	cost = 1
	desc = "The ultimate in disguise technology. This will perfectly conceal your identity from any onlookers and leave them stunned at your majestic facial hair."
	blockedmode = list(/datum/game_mode/revolution)

/datum/syndicate_buylist/traitor/bowling
	name = "Bowling Kit"
	item = /obj/item/storage/bowling
	cost = 7
	desc = "Comes with several bowling balls and a suit. You won't be able to pluck up the courage to throw them very hard without wearing the suit!"
	blockedmode = list(/datum/game_mode/spy, /datum/game_mode/revolution)

/datum/syndicate_buylist/traitor/football
	name = "Space-American Football Kit"
	item = /obj/item/storage/football
	cost = 7
	desc = "This kit contains everything you need to become a great football player! Wearing all of the equipment inside will grant you the ability to rush down and tackle foes. You'll also make amazing throws!"
	blockedmode = list(/datum/game_mode/spy, /datum/game_mode/revolution)

/datum/syndicate_buylist/traitor/mindslave
	name = "Mind Slave implant"
	item = /obj/item/implanter/mindslave
	cost = 3
	vr_allowed = 0
	desc = "Temporarily place an injected victim under your complete control! Faster and more effective than hypnotism! Warning: Implant effects are NOT indefinite."
	blockedmode = list(/datum/game_mode/spy, /datum/game_mode/revolution) // Whatever you do, don't allow mindslave implants in spy or rev.

/datum/syndicate_buylist/traitor/deluxe_mindslave
	name = "Deluxe Mind Slave implant"
	item = /obj/item/implanter/super_mindslave
	cost = 6
	vr_allowed = 0
	desc = "Place an injected victim under your complete control! Enhanced neurostimulators make this version last virtually indefinitely!"
	blockedmode = list(/datum/game_mode/spy, /datum/game_mode/revolution)

/datum/syndicate_buylist/traitor/microbomb
	name = "Microbomb Implant"
	item = /obj/item/implanter/uplink_microbomb
	cost = 1
	vr_allowed = 0
	desc = "This miniaturized explosive packs a decent punch and will detonate upon the unintentional death of the host. Do not swallow and keep out of reach of children."
	blockedmode = list(/datum/game_mode/revolution)

/datum/syndicate_buylist/traitor/macrobomb
	name = "Macrobomb Implant"
	item = /obj/item/implanter/uplink_macrobomb
	cost = 12
	vr_allowed = 0
	desc = "Like the microbomb, but much more powerful. Macrobombs for macrofun!"
	blockedmode = list(/datum/game_mode/revolution)

/datum/syndicate_buylist/traitor/lightbreaker
	name = "Light Breaker"
	item = /obj/item/lightbreaker
	cost = 4
	desc = "A casette player that breaks all lights near you. It also temporarily deafens and staggers all nearby people. Comes with four charges and has a distinctive sound. Can be rewound with a screwdriver."

/datum/syndicate_buylist/traitor/sonicgrenades
	name = "Sonic Grenades"
	item = /obj/item/storage/box/sonic_grenade_kit
	cost = 2
	desc = "Each one packs enough power to shatter reinforced windows and pop eardrums. No more being cornered by an angry mob! Comes with earplugs."
	blockedmode = list(/datum/game_mode/spy, /datum/game_mode/revolution)

/datum/syndicate_buylist/traitor/surplus
	name = "Surplus Crate"
	item = /obj/storage/crate/syndicate_surplus
	cost = 12
	vr_allowed = 0
	desc = "A crate containing 18-24 credits worth of whatever junk we had lying around."
	blockedmode = list(/datum/game_mode/spy, /datum/game_mode/revolution)

	run_on_spawn(var/obj/storage/crate/syndicate_surplus/crate, var/mob/living/owner, in_surplus_crate)
		crate.spawn_items(owner)
/*
This is basically useless for anyone but miners.
...and it's still useless because they can just mine the stuff themselves.
-Spy
/datum/syndicate_buylist/traitor/loot_crate
	name = "Loot Crate"
	item = /obj/storage/crate/loot_crate
	cost = 8
	desc = "A crate containing 18-24 credits worth of 'Materials'."
	not_in_crates = 1
	blockedmode = list(/datum/game_mode/spy)
*/

//////////////////////////////////////////////// Objective-specific items //////////////////////////////////////////////

/datum/syndicate_buylist/traitor/idtracker
	name = "Target ID Tracker"
	item = /obj/item/idtracker
	cost = 1
	desc = "Allows you to track the IDs of your assassination targets, but only the ID. If they have changed or destroyed it, the pin pointer will not be useful."
	not_in_crates = 1
	vr_allowed = 0
	objective = /datum/objective/regular/assassinate

	run_on_spawn(var/obj/item/idtracker/tracker,var/mob/living/owner, in_surplus_crate)
		tracker.owner = owner
		return

/datum/syndicate_buylist/traitor/idtracker/spy
	name = "Target ID Tracker (SPY)"
	item = /obj/item/idtracker/spy
	cost = 1
	desc = "Allows you to track the IDs of all other antagonists, but only the ID. If they have changed or destroyed it, the pin pointer will not be useful."
	vr_allowed = 0
	not_in_crates = 1
	objective = /datum/objective/spy_theft/assasinate

	run_on_spawn(var/obj/item/idtracker/tracker,var/mob/living/owner, in_surplus_crate)
		tracker.owner = owner
		return

// Gannets Nuke Ops Class Crates - now found under weapon_vendor.dm

/datum/syndicate_buylist/traitor/classcrate
	name = "Class Crate - Generic"
	item = /obj/storage/crate/classcrate
	cost = 0
	desc = "A crate containing a Nuke Ops Class Loadout, this one is generic and you shouldn't see it."
	objective = /datum/objective/specialist/nuclear
	not_in_crates = 1
/*
	demo
		name = "Class Crate - Grenadier"
		item = /obj/storage/crate/classcrate/demo
		cost = 12
		desc = "A crate containing a Specialist Operative loadout. This one features a hand-held grenade launcher, bandolier and a pile of ordnance."

	heavy
		name = "Class Crate - Heavy Weapons Specialist"
		item = /obj/storage/crate/classcrate/heavy
		cost = 12
		desc = "A crate containing a Specialist Operative loadout. This one features a light machine gun, several belts of ammunition and a couple of grenades."

	assault
		name = "Class Crate - Assault Trooper"
		item = /obj/storage/crate/classcrate/assault
		cost = 12
		desc = "A crate containing a Specialist Operative loadout. This one includes a customized assault rifle, several additional magazines as well as an assortment of breach and clear grenades."

	agent
		name = "Class Crate - Infiltrator"
		item = /obj/storage/crate/classcrate/agent_rework
		cost = 12
		desc = "A crate containing a Specialist Operative loadout."

	medic
		name = "Class Crate - Combat Medic"
		item = /obj/storage/crate/classcrate/medic
		cost = 12
		desc = "A crate containing a Specialist Operative loadout. This one is packed with medical supplies, along with a syringe gun delivery system."

	pyro
		name = "Class Crate - Firebrand"
		item = /obj/storage/crate/classcrate/pyro
		cost = 12
		desc = "A crate containing a Specialist Operative loadout. This one contains a flamethrower and a hefty fire-axe that can be two-handed."

	engie
		name = "Class Crate - Combat Engineer"
		item = /obj/storage/crate/classcrate/engineer
		cost = 12
		desc = "A crate containing a Specialist Operative loadout. This one contains a deployable automated gun turret, high-capacity welder and a combat wrench."

	sniper
		name = "Class Crate - Marksman"
		item = /obj/storage/crate/classcrate/sniper
		cost = 12
		desc = "A crate containing a Specialist Operative loadout. This one includes a high-powered sniper rifle, some smoke grenades and a chameleon generator."
*/

//////////////////////////////////////////////// Job-specific items  ////////////////////////////////////////////////////

/datum/syndicate_buylist/traitor/clowncar
	name = "Clown Car"
	item = /obj/vehicle/clowncar/surplus
	cost = 5
	vr_allowed = 0
	desc = "A funny-looking car designed for circus events. Seats 30, very roomy! Comes with an extra set of clown clothes."
	job = list("Clown")
	blockedmode = list(/datum/game_mode/spy)

/datum/syndicate_buylist/traitor/boomboots
	name = "Boom Boots"
	item = /obj/item/clothing/shoes/cowboy/boom
	cost = 12
	vr_allowed = 0
	desc = "These big red boots have an explosive step sound. The entire station is sure to want to show you their appreciation."
	job = list("Clown")
	blockedmode = list(/datum/game_mode/spy)

/datum/syndicate_buylist/traitor/clown_mask
	name = "Clown Mask"
	item = /obj/item/clothing/mask/gas/syndie_clown
	cost = 5
	vr_allowed = 0
	desc = "A clown mask haunted by the souls of those who honked before. Only true clowns should attempt to wear this. It also functions like a gas mask."
	job = list("Clown")
	not_in_crates = 1
	blockedmode = list(/datum/game_mode/spy, /datum/game_mode/revolution)

/datum/syndicate_buylist/traitor/fake_revolver
	name = "Funny-looking Revolver"
	item = /obj/item/storage/box/fakerevolver
	cost = 1
	desc = "A revolver with a twist. It will always fire backwards! Watch some vigilante try to get you NOW!"
	job = list("Clown")
	blockedmode = list(/datum/game_mode/spy, /datum/game_mode/revolution)

/datum/syndicate_buylist/traitor/chambomb
	name = "Chameleon Bomb"
	item = /obj/item/device/chameleon/bomb
	cost = 6
	desc = "A questionable mixture of a chameleon projector and a bomb. Scan an object to take on its appearance, arm the bomb, and then explode the face(s) of whoever tries to touch it."
	job = list("Clown")
	blockedmode = list(/datum/game_mode/spy, /datum/game_mode/revolution)

/datum/syndicate_buylist/traitor/sinjector
	name = "Speed Injector"
	item = /obj/item/speed_injector
	cost = 3
	desc = "Disguised as a screwdriver, this stealthy device can be loaded with dna injectors which will be injected into the target instantly and stealthily. The dna injector will be altered when inserted so that there will be a ten second delay before the gene manifests in the victim."
	job = list("Geneticist")
	not_in_crates = 1
	blockedmode = list(/datum/game_mode/revolution)

/datum/syndicate_buylist/traitor/minibible
	name = "Miniature Bible"
	item = /obj/item/storage/bible/mini
	cost = 1
	desc = "We understand it can be difficult to carry out some of our missions. Here is some spiritual counsel in a small package."
	job = list("Assistant","Technical Assistant","Medical Assistant","Staff Assistant", "Chaplain", "Clown")
	blockedmode = list(/datum/game_mode/spy, /datum/game_mode/revolution)
	vr_allowed = 0

/datum/syndicate_buylist/traitor/contract
	name = "Faustian Bargain Kit"
	item = /obj/item/storage/briefcase/satan
	cost = 8
	desc = "Comes complete with three soul binding contracts, three extra-pointy pens, and one suit provided by Lucifer himself."
	job = list("Chaplain")
	not_in_crates = 1
	vr_allowed = 0
	blockedmode = list(/datum/game_mode/revolution)

	run_on_spawn(var/obj/item/storage/briefcase/satan/Q,var/mob/living/owner, in_surplus_crate)
		if (istype(Q) && owner)
			owner.make_merchant() //give them the power to summon more contracts
			Q.merchant = owner
			owner.mind.diabolical = 1 //can't sell souls to ourselves now can we?

/datum/syndicate_buylist/traitor/mailsuit
	name = "Mailman Suit"
	item = /obj/item/clothing/under/misc/mail/syndicate
	cost = 1
	desc = "A mailman's uniform that allows the wearer to use mail chutes as a means of transportation."
	job = list("Mailman")
	blockedmode = list(/datum/game_mode/spy, /datum/game_mode/revolution)

/datum/syndicate_buylist/traitor/chargehacker
	name = "Mining Charge Hacker"
	item = /obj/item/device/chargehacker
	cost = 4
	desc = "A tool designed to hack mining charges so that they will attach to any surface, disguised as a geological scanner."
	not_in_crates = 1
	job = list("Miner")
	blockedmode = list(/datum/game_mode/spy, /datum/game_mode/revolution)

/datum/syndicate_buylist/traitor/maneater
	name = "Maneater Seed"
	item = /obj/item/seed/maneater
	cost = 1
	desc = "A boon for the green-thumbed agent! Simply plant and nurture to raise your own faithful guard-plant! Feed me, Seymour!"
	not_in_crates = 1
	job = list("Botanist")
	blockedmode = list(/datum/game_mode/spy, /datum/game_mode/revolution)

/datum/syndicate_buylist/traitor/saw
	name = "Chainsaw"
	item = /obj/item/saw/syndie
	cost = 7
	desc = "This old earth beauty is made by hand with strict attention to detail. Unlike today's competing botanical chainsaw, it actually cuts things!"
	not_in_crates = 1
	job = list("Botanist")
	blockedmode = list(/datum/game_mode/spy, /datum/game_mode/revolution)

/datum/syndicate_buylist/traitor/waspgrenade
	name = "Wasp Grenades"
	item = /obj/item/storage/box/wasp_grenade_kit
	cost = 3
	desc = "These wasp grenades contain genetically modified extra double large hornets that will surely inspire awe in all your non-botanical friends."
	job = list("Botanist", "Apiculturist")
	blockedmode = list(/datum/game_mode/spy, /datum/game_mode/revolution)

/datum/syndicate_buylist/traitor/wasp_crossbow
	name = "Wasp Crossbow"
	item = /obj/item/gun/energy/wasp
	cost = 6
	desc = "Become the member of the Space Cobra Unit you always wanted to be! Spread pain and fear far and wide using this scattershot wasp egg launcher! Through the power of sheer wasp-y fury, this crossbow will slowly recharge between shots and is guaranteed to light up your day with maniacal joy and to bring your enemies no end of sorrow."
	not_in_crates = 1 //the value of the item goes down significantly for non-botanists since only botanists are treated kindly by wasps
	job = list("Botanist", "Apiculturist")
	blockedmode = list(/datum/game_mode/spy, /datum/game_mode/revolution)

/datum/syndicate_buylist/traitor/fakegrenade
	name = "Fake Cleaner Grenades"
	item = /obj/item/storage/box/f_grenade_kit
	cost = 2
	desc = "This cleaning grenade features over 500% of the legal level of active agent. Cleans dirt off of floors and flesh off of bone! Also contains space lube to create a dazzling shine!"
	job = list("Janitor")
	blockedmode = list(/datum/game_mode/spy)

/datum/syndicate_buylist/traitor/compactor
	name = "Trash Compactor Cart"
	item = /obj/storage/cart/trash/syndicate
	cost = 4
	desc = "Identical in appearance to an ordinary trash cart, this beauty is capable of compacting (1) laying person placed inside at a time. It was originally supposed to only compact nonliving things, but a serendipitous design mistake resulted in 1500 units with a reversed safety unit."
	not_in_crates = 1
	vr_allowed = 0
	job = list("Janitor")
	blockedmode = list(/datum/game_mode/spy, /datum/game_mode/revolution)

	run_on_spawn(var/obj/storage/cart/trash/syndicate/cart,var/mob/living/owner, in_surplus_crate)
		if (istype(cart) && owner)
			cart.owner_ckey = owner.ckey

/datum/syndicate_buylist/traitor/slip_and_sign
	name = "Slip and Sign"
	item = /obj/item/caution/traitor
	cost = 2
	desc = "This Wet Floor Sign spits out organic superlubricant under everyone nearby unless they are wearing galoshes. That'll teach them to ignore the signs. If you are wearing the long janitor gloves you can click with a bucket (or beaker or drinking glass etc.) to replace the payload."
	job = list("Janitor")

	run_on_spawn(obj/item/caution/traitor/sign, mob/living/owner, in_surplus_crate)
		if(in_surplus_crate)
			new /obj/item/clothing/shoes/galoshes(sign.loc)
			new /obj/item/clothing/gloves/long(sign.loc)

/datum/syndicate_buylist/traitor/syndanalyser
	name = "Syndicate Device Analyzer"
	item = /obj/item/electronics/scanner/syndicate
	cost = 4
	vr_allowed = 0
	desc = "The shell of a standard Nanotrasen mechanic's analyzer with cutting-edge Syndicate internals. This baby can scan almost anything!"
	not_in_crates = 1
	job = list("Mechanic")
	blockedmode = list(/datum/game_mode/spy, /datum/game_mode/revolution)

/datum/syndicate_buylist/traitor/stimulants
	name = "Stimulants"
	item = /obj/item/stimpack
	cost = 4
	desc = "When top agents need energy, they turn to our new line of X-Cite 500 stimulants. This all-natural* and worry-free** blend accelerates perception, endurance, and reaction time to superhuman levels! Shrug off even the cruelest of blows without a scratch! <br><br><font size=-1>*Contains less than 0.5 grams unnatural material per 0.49 gram serving.<br>**May cause dizziness, blurred vision, heart failure, renal compaction, adenoid calcification, or death. Women who are currently pregnant or may be pregnant should not handle X-Cite due to the risk of a specific birth defect.</font>"
	job = list("Medical Doctor","Medical Director","Scientist","Geneticist","Research Director")
	blockedmode = list(/datum/game_mode/spy, /datum/game_mode/revolution)

/datum/syndicate_buylist/traitor/syringegun
	name = "Syringe Gun"
	item = /obj/item/gun/reagent/syringe
	cost = 3
	desc = "This stainless-steel, revolving wonder fires needles. Perfect for today's safari-loving Syndicate doctor! Loaded by transferring reagents to the gun's internal reservoir."
	job = list("Medical Doctor", "Medical Director", "Research Director", "Scientist", "Bartender")
	blockedmode = list(/datum/game_mode/spy, /datum/game_mode/revolution)

/datum/syndicate_buylist/traitor/powergloves
	name = "Power Gloves"
	item = /obj/item/clothing/gloves/powergloves
	cost = 6
	desc = "These marvels of modern technology employ nanites and space science to draw energy from nearby cables to zap things. BZZZZT!"
	not_in_crates = 1
	job = list("Engineer", "Chief Engineer", "Mechanic")
	blockedmode = list(/datum/game_mode/spy, /datum/game_mode/revolution)

/datum/syndicate_buylist/traitor/pickpocket
	name = "Pickpocket Gun"
	item = /obj/item/gun/energy/pickpocket
	cost = 3
	desc = "A stealthy claw gun capable of stealing and planting items, and severely messing with people."
	job = list("Engineer", "Chief Engineer", "Mechanic", "Clown", "Staff Assistant")
	blockedmode = list(/datum/game_mode/spy, /datum/game_mode/revolution)

/datum/syndicate_buylist/traitor/poisonbottle
	name = "Poison Bottle"
	item = /obj/item/reagent_containers/glass/bottle/poison
	cost = 1
	desc = "A bottle of poison. Which poison? Who knows."
	job = list("Medical Doctor", "Medical Director", "Research Director", "Scientist", "Bartender")
	blockedmode = list(/datum/game_mode/spy, /datum/game_mode/revolution)

/datum/syndicate_buylist/traitor/chemicompiler
	name = "Chemicompiler"
	item = /obj/item/device/chemicompiler
	cost = 5
	not_in_crates = 1
	desc = "A handheld version of the Chemicompiler machine in Chemistry."
	job = list("Research Director", "Scientist")
	blockedmode = list(/datum/game_mode/spy, /datum/game_mode/revolution)

/datum/syndicate_buylist/traitor/robosuit
	name = "Syndicate Robot Suit"
	item = /obj/item/parts/robot_parts/robot_frame/syndicate
	cost = 2
	desc = "A cyborg shell crafted from the finest recycled steel and reverse-engineered microelectronics. A cyborg crafted from this will see only Syndicate operatives (Such as yourself!) as human. Cyborg also comes preloaded with popular game \"Angry About the Bird\" and is compatible with most headphones."
	not_in_crates = 1
	vr_allowed = 0
	job = list("Roboticist")
	blockedmode = list(/datum/game_mode/spy, /datum/game_mode/revolution)

/datum/syndicate_buylist/traitor/conversion_chamber
	name = "Conversion Chamber"
	item = /obj/machinery/recharge_station/syndicate
	cost = 6
	vr_allowed = 0
	desc = "A modified standard-issue cyborg recharging station that will automatically convert any human placed inside into a cyborg. Be aware that cyborgs will follow the active lawset in place on-station."
	job = list("Roboticist")
	not_in_crates = 1
	blockedmode = list(/datum/game_mode/spy, /datum/game_mode/revolution)

/datum/syndicate_buylist/traitor/safari
	name = "Safari Kit"
	item = /obj/item/storage/box/costume/safari
	cost = 7
	desc = "Almost everything you need to hunt the most dangerous game. Tranquilizer rifle not included."
	job = list("Medical Director")
	blockedmode = list(/datum/game_mode/spy, /datum/game_mode/revolution)

/datum/syndicate_buylist/traitor/syndiesauce
	name = "Syndicate Sauce"
	item = /obj/item/reagent_containers/food/snacks/condiment/syndisauce
	cost = 1
	desc = "Our patented secret blend of herbs and spices! Guaranteed to knock even the harshest food critic right off their feet! And into the grave. Because this is poison."
	job = list("Chef", "Bartender")
	blockedmode = list(/datum/game_mode/revolution)

/datum/syndicate_buylist/traitor/donkpockets
	name = "Syndicate Donk Pockets"
	item = /obj/item/storage/box/donkpocket_w_kit
	cost = 2
	desc = "Ready to eat, no microwave required! The pocket-sandwich station personnel crave, now with added medical agents to heal you up in a pinch! Zero grams trans-fat per serving*!<br><br><font size=1>*Made with partially-hydrogenated wizard blood.</font>"
	job = list("Chef")
	blockedmode = list(/datum/game_mode/spy, /datum/game_mode/revolution)

/datum/syndicate_buylist/traitor/butcherknife
	name = "Butcher's Knife"
	item = /obj/item/knife/butcher
	cost = 7
	desc = "An extremely sharp knife with a weighted handle for accurate throwing. Caution: May cause extreme bleeding if the cutting edge comes into contact with human flesh."
	not_in_crates = 1
	job = list("Chef")
	blockedmode = list(/datum/game_mode/spy, /datum/game_mode/revolution)

/datum/syndicate_buylist/traitor/moonshine
	name = "Jug of Moonshine"
	item = /obj/item/reagent_containers/food/drinks/moonshine
	cost = 2
	desc = "A jug full of incredibly potent alcohol. Not recommended for human consumption."
	job = list("Bartender")
	blockedmode = list(/datum/game_mode/spy, /datum/game_mode/revolution)

/datum/syndicate_buylist/traitor/shotglass
	name = "Extra Large Shot Glasses"
	item = /obj/item/storage/box/glassbox/syndie
	cost = 2
	desc = "A box of shot glasses that hold WAAAY more that normal. Cheat at drinking games!"
	job = list("Bartender")
	blockedmode = list(/datum/game_mode/spy, /datum/game_mode/revolution)

/datum/syndicate_buylist/traitor/vuvuzelagun
	name = "Vuvuzela Gun"
	item = /obj/item/gun/energy/vuvuzela_gun
	cost = 3
	desc = "<b>BZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ</b>"
	job = list("Assistant","Technical Assistant","Medical Assistant","Staff Assistant", "Clown")
	blockedmode = list(/datum/game_mode/spy, /datum/game_mode/revolution)

/datum/syndicate_buylist/traitor/moustache_grenade
	name = "Moustache Grenade"
	item = /obj/item/old_grenade/moustache
	cost = 1
	desc = "A disturbingly hairy grenade."
	job = list("Assistant","Technical Assistant","Medical Assistant","Staff Assistant", "Clown")
	blockedmode = list(/datum/game_mode/revolution)

/datum/syndicate_buylist/traitor/hotdog_bomb
	name = "Hotdog Bomb"
	item = /obj/item/gimmickbomb/hotdog
	cost = 1
	desc = "Turn your worst enemies into hotdogs."
	job = list("Chef", "Sous-Chef", "Waiter", "Clown")
	blockedmode = list(/datum/game_mode/revolution)

/datum/syndicate_buylist/traitor/chemgrenades
	name = "Chem Grenade Starter Kit"
	item = /obj/item/storage/box/grenade_starter_kit
	cost = 2
	desc = "Tired of destroying your own face with acid reactions? Want to make the janitor feel incompetent? This kit gets you started with three grenades. Just add beakers and screw!"
	job = list("Scientist","Research Director")
	blockedmode = list(/datum/game_mode/spy, /datum/game_mode/revolution)

/datum/syndicate_buylist/traitor/ammo_38AP // 2 TC for 1 speedloader was very poor value compared to other guns and traitor items in general (Convair880).
	name = ".38 AP ammo box"
	item = /obj/item/storage/box/ammo38AP
	cost = 2
	desc = "Armor-piercing ammo for a .38 Special revolver (not included)."
	job = list("Detective")
	blockedmode = list(/datum/game_mode/spy, /datum/game_mode/revolution, /datum/game_mode/spy_theft)

/datum/syndicate_buylist/traitor/traitorthermalscanner
	name = "Advanced Optical Thermal Scanner"
	item = /obj/item/clothing/glasses/thermal/traitor
	cost = 3
	desc = "An advanced optical thermal scanner capable of seeing living entities through walls and smoke."
	job = list("Detective")
	blockedmode = list(/datum/game_mode/spy, /datum/game_mode/revolution)

/datum/syndicate_buylist/traitor/cargo_transporter
	name = "Syndicate Cargo Transporter"
	item = /obj/item/cargotele/traitor
	cost = 3
	vr_allowed = 0
	desc = "A modified cargo transporter which teleports containers to a random spot in space and welds them shut."
	job = list("Quartermaster","Miner","Engineer")
	blockedmode = list(/datum/game_mode/spy, /datum/game_mode/revolution)

/datum/syndicate_buylist/traitor/telegun
	name = "Teleport Gun"
	item = /obj/item/gun/energy/teleport
	cost = 7
	vr_allowed = 0
	desc = "An experimental hybrid between a hand teleporter and a directed-energy weapon. Probably a very bad idea. Note -- Only works in conjunction with a stationary teleporter."
	job = list("Research Director")
	blockedmode = list(/datum/game_mode/spy, /datum/game_mode/revolution)

/datum/syndicate_buylist/traitor/portapuke
	name = "Port-a-Puke"
	item = /obj/machinery/portapuke
	cost = 7
	desc = "An experimental torture chamber that will make any human placed inside puke until they die!"
	job = list("Janitor")
	blockedmode = list(/datum/game_mode/revolution)

/datum/syndicate_buylist/traitor/lawndarts
	name = "Lawn Darts"
	item = /obj/item/storage/box/lawndart_kit
	cost = 4
	desc = "Three deadly throwing darts that embed themselves into your target."
	job = list("Assistant","Technical Assistant","Medical Assistant","Staff Assistant","Bartender","Clown")
	blockedmode = list(/datum/game_mode/revolution)

/datum/syndicate_buylist/traitor/monkey_barrel
	name = "Barrel-O-Monkeys"
	item = /obj/storage/monkey_barrel
	cost = 6
	vr_allowed = 0
	desc = "A barrel of bloodthirsty apes. Careful!"
	job = list("Staff Assistant","Test Subject","Geneticist")
	blockedmode = list(/datum/game_mode/revolution)

/datum/syndicate_buylist/traitor/mindslave_module
	name = "Mindslave Cloning Module"
	item = /obj/item/cloneModule/mindslave_module
	cost = 7
	vr_allowed = 0
	desc = "An add on to the genetics cloning pod that make anyone cloned loyal to whoever installed it."
	job = list("Geneticist", "Medical Doctor", "Medical Director")
	blockedmode = list(/datum/game_mode/revolution)

/datum/syndicate_buylist/traitor/deluxe_mindslave_module
	name = "Deluxe Mindslave Cloning Module Kit"
	item = /obj/item/storage/box/mindslave_module_kit
	cost = 11 //  Always leave them 1tc so they can buy the moustache. Style is key.
	vr_allowed = 0
	desc = "A Deluxe Mindslave Cloning Kit. Contains a mindslave cloning module and a cloning lab in a box!"
	job = list("Geneticist", "Medical Doctor", "Medical Director")
	blockedmode = list(/datum/game_mode/revolution)

/datum/syndicate_buylist/traitor/buddy_ammofab
	name = "Guardbuddy Ammo Replicator"
	item = /obj/item/device/guardbot_module/ammofab
	cost = 4
	vr_allowed = 0
	desc = "A device that allows PR-6S Guardbuddy units to use their internal charge to replenish kinetic ammunition."
	job = list("Research Director")
	blockedmode = list(/datum/game_mode/revolution)

/datum/syndicate_buylist/traitor/wiretap
	name = "Wiretap Radio Upgrade"
	item = /obj/item/device/radio_upgrade
	cost = 3
	desc = "A small device that may be installed in a headset to grant access to all station channels."
	blockedmode = list(/datum/game_mode/spy, /datum/game_mode/revolution)

/////////////////////////////////////////// Surplus-exclusive items //////////////////////////////////////////////////

/datum/syndicate_buylist/surplus
	name = "You shouldn't see me!"
	cost = 0
	desc = "You shouldn't see me!"

/datum/syndicate_buylist/surplus/dagger
	name = "Syndicate Dagger"
	item = /obj/item/dagger/syndicate
	cost = 2
	desc = "An ornamental dagger for stabbing people with."
	blockedmode = list(/datum/game_mode/spy)

/datum/syndicate_buylist/surplus/advanced_laser
	name = "Laser Rifle"
	item = /obj/item/gun/energy/laser_gun/pred
	cost = 6
	desc = "An experimental laser design with a self-charging cerenkite battery."
	blockedmode = list(/datum/game_mode/spy, /datum/game_mode/revolution)

/datum/syndicate_buylist/surplus/riotbaton
	name = "Riot Baton"
	item = /obj/item/baton/classic
	cost = 5
	desc = "An old riot baton."
	blockedmode = list(/datum/game_mode/spy, /datum/game_mode/revolution)

/datum/syndicate_buylist/surplus/breachingT
	name = "Thermite Breaching Charge"
	item = /obj/item/breaching_charge/thermite
	cost = 1
	desc = "A self-contained thermite breaching charge, useful for destroying walls."
	blockedmode = list(/datum/game_mode/spy)

/datum/syndicate_buylist/surplus/breaching
	name = "Breaching Charge"
	item = /obj/item/breaching_charge
	cost = 1
	desc = "A self-contained explosive breaching charge, useful for destroying walls."
	blockedmode = list(/datum/game_mode/spy)

/datum/syndicate_buylist/surplus/flaregun
	name = "Flare Gun"
	item = /obj/item/storage/box/flaregun // Gave this thing a box of spare ammo. Having only one shot was kinda lackluster (Convair880).
	cost = 2
	desc = "A signal flaregun for emergency use. Or for setting jerks on fire"
	blockedmode = list(/datum/game_mode/spy)

/datum/syndicate_buylist/surplus/tape
	name = "Ducktape"
	item = /obj/item/handcuffs/tape_roll
	cost = 1
	desc = "A roll of duct tape for makeshift handcuffs. Yep."
	blockedmode = list(/datum/game_mode/spy)

/datum/syndicate_buylist/surplus/rifle
	name = "Old Hunting Rifle"
	item = /obj/item/gun/kinetic/hunting_rifle
	cost = 7
	desc = "An old hunting rifle, comes with only four bullets. Use them wisely."
	blockedmode = list(/datum/game_mode/spy, /datum/game_mode/revolution)

/datum/syndicate_buylist/surplus/bananagrenades
	name = "Banana Grenades"
	item = /obj/item/storage/box/banana_grenade_kit
	cost = 2
	desc = "Honk."
	blockedmode = list(/datum/game_mode/spy)

/datum/syndicate_buylist/surplus/turboflash_box
	name = "Flash/cell assembly box"
	item = /obj/item/storage/box/turbo_flash_kit
	cost = 1
	desc = "A box full of common stun weapons with power cells hastily wired into them. Looks dangerous."
	blockedmode = list(/datum/game_mode/spy)

/datum/syndicate_buylist/surplus/syndicate_armor
	name = "Syndicate Command Armor"
	item = /obj/item/clothing/suit/space/industrial/syndicate
	cost = 5
	desc = "A set of syndicate command armor. I guess the last owner must have died."
	blockedmode = list(/datum/game_mode/spy, /datum/game_mode/revolution)

/datum/syndicate_buylist/surplus/egun_upgrade
	name = "Energy Gun Upgrade Pack"
	item = /obj/item/ammo/power_cell/self_charging/disruptor
	cost = 2
	desc = "An advanced self-charging power cell, the ideal upgrade for an energy gun!"
	blockedmode = list(/datum/game_mode/spy, /datum/game_mode/revolution)

// Why not, I guess? Cleaned up the old mine code, might as well use it (Convair880).
/datum/syndicate_buylist/surplus/landmine
	name = "Land Mine"
	item = /obj/random_item_spawner/landmine/surplus // RNG picker.
	cost = 1
	desc = "Some old anti-personnel mine we found in the warehouse."
	blockedmode = list(/datum/game_mode/spy, /datum/game_mode/revolution)

// At the time of writing, you can't get these anywhere else. And they fit the purpose of surplus crates quite well, I suppose (Convair880).
// changed to sechuds cause why not - haine
/datum/syndicate_buylist/surplus/cybereye_kit_sechud
	name = "Ocular Prosthesis Kit (SecHUD)"
	item = /obj/item/storage/box/prosthesis_kit/eye_sechud
	cost = 1
	desc = "A pair of surplus cybereyes that can access the Security HUD system. Operating table not included."
	blockedmode = list(/datum/game_mode/revolution)

/datum/syndicate_buylist/surplus/holographic_disguiser
	name = "Holographic Disguiser"
	item = /obj/item/device/disguiser
	cost = 1
	desc = "A device capable of disguising your identity temporarily. Beware of flashes and projectiles!"
	blockedmode = list(/datum/game_mode/revolution)

/datum/syndicate_buylist/surplus/emaghypo
	name = "Hacked Hypospray"
	item = /obj/item/reagent_containers/hypospray/emagged
	cost = 1
	desc = "A special hacked hypospray, capable of holding any chemical!"
	blockedmode = list(/datum/game_mode/spy, /datum/game_mode/revolution)

/datum/syndicate_buylist/surplus/sarin_grenade
	name = "Sarin Grenade"
	item = /obj/item/chem_grenade/sarin
	cost = 1
	desc = "A terrifying grenade containing a potent nerve gas. Try not to get caught in the smoke."
	blockedmode = list(/datum/game_mode/spy, /datum/game_mode/revolution)

/////////////////////////////////////////////// Disabled items /////////////////////////////////////////////////////

/datum/syndicate_buylist/traitor/fogmaster
	name = "Fog Machine"
	item = /obj/machinery/fogmachine
	cost = 0 // Needs to be fixed and less laggy.
	desc = "Make a hell of a party with the FOGMASTER 3000. Fill with chemicals and the machine does the rest! Give em something they won't ever forget, or wake up from!"
	job = list("Scientist","Botanist")
	blockedmode = list(/datum/game_mode/spy, /datum/game_mode/revolution)

/datum/syndicate_buylist/traitor/hisgrace
	name = "Artistic Toolbox"
	item = /obj/item/storage/toolbox/memetic
	item2 = /obj/item/paper/memetic_manual
	cost = 0
	desc = "Maybe paint a really insulting picture of your foe? To be honest, we have no idea what is even in these or where they came from, a huge crate of them just showed up at our warehouse around a month ago. We're sure it's something very handy, though!"
	job = list("Chaplain")
	vr_allowed = 0
	blockedmode = list(/datum/game_mode/spy, /datum/game_mode/revolution)


// round specific

/datum/syndicate_buylist/generic/revflash
	name = "Revolutionary Flash"
	item = /obj/item/device/flash/revolution
	cost = 5
	desc = "This flash never runs out and will convert susceptible crew when a rev head uses it. It will also allow the rev head to break loyalty implants."
	vr_allowed = 0
	exclusivemode = list(/datum/game_mode/revolution)
	not_in_crates = 1

/datum/syndicate_buylist/generic/revflashbang
	name = "Revolutionary Flashbang"
	item = /obj/item/chem_grenade/flashbang/revolution
	cost = 2
	desc = "This single-use flashbang will convert all crew within range. It doesn't matter who primes the flash - it will convert all the same."
	vr_allowed = 0
	exclusivemode = list(/datum/game_mode/revolution)
	not_in_crates = 1

/datum/syndicate_buylist/generic/revsign
	name = "Revolutionary Sign"
	item = /obj/item/revolutionary_sign
	cost = 4
	desc = "This large revolutionary sign will inspire all nearby revolutionaries and grant them small combat buffs. A rev head needs to be holding this sign for it to have any effect."
	exclusivemode = list(/datum/game_mode/revolution)
	not_in_crates = 1

/datum/syndicate_buylist/generic/rev_dagger
	name = "Sacrificial Dagger"
	item = /obj/item/dagger
	cost = 2
	desc = "An ornamental dagger for stabbing people with."
	exclusivemode = list(/datum/game_mode/revolution)
	not_in_crates = 1

/datum/syndicate_buylist/generic/rev_normal_flash
	name = "Flash"
	item = /obj/item/device/flash
	cost = 1
	desc = "Just a standard-issue flash. Won't remove implants like the Revolutionary Flash."
	exclusivemode = list(/datum/game_mode/revolution)
	not_in_crates = 1
