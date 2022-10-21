/**
 * Builds the entire syndicate buylist cache, retrieved by uplinks. Ideally only executed once during the pre-round
 */
proc/build_syndi_buylist_cache()
	var/list/stuff = concrete_typesof(/datum/syndicate_buylist)
	syndi_buylist_cache.Cut()
	for(var/SB in stuff)
		syndi_buylist_cache += new SB

	for (var/datum/syndicate_buylist/LE in syndi_buylist_cache)
		if (!LE.cost || !isnum(LE.cost) || LE.cost <= 0)
			syndi_buylist_cache.Remove(LE)

	sortList(syndi_buylist_cache, /proc/cmp_text_asc)

// How to add new items? Pick the correct path (nukeops, traitor, surplus) and go from there. Easy.
ABSTRACT_TYPE(/datum/syndicate_buylist)
/datum/syndicate_buylist
	/// Name of the buylist entry
	var/name = null
	/// A typepath for the item that will be spawned when the datum is purchased
	var/atom/item = null
	/// A typepath for the second, optional, item that will be spawned when the datum is purchased
	var/atom/item2 = null
	/// A typepath for the third, optional, item that will be spawned when the datum is purchased
	var/atom/item3 = null
	/// The TC cost of the datum in a buylist. Set to 0 to make it unavailable
	var/cost = null
	/// The extended description that will go in the "about" section of the item
	var/desc = null
	/// A list of job names that you want the item to be restricted to, e.g. `list("Clown", "Captain")`
	var/list/job = null
	/// For items that only can be purchased when you have a specfic objective. Needs to be a type, e.g. `/datum/objective/assassinate`
	var/datum/objective/objective = null
	/// Is this buylist entry for ejecting TC from an uplink?
	var/telecrystal = FALSE
	/// If the item should be allowed to be purchased in the VR murderbox
	var/vr_allowed = TRUE
	/// If the item can be created as loot in Battle Royale
	var/br_allowed = FALSE
	/// If the item should show up in surplus crates or not
	var/not_in_crates = FALSE
	/// The category of the item, currently unused (somewhat used in the Nukeop Commander uplink)
	var/category
	/// Bitflags for what uplinks can buy this item (see `_std/defines/uplink.dm` for flags)
	var/can_buy

	/**
	 * Runs on the purchase of the buylist datum
	 *
	 * Arguments:
	 * `item`, the item you're expecting
	 * `owner`, the person who bought the item
	 * `in_surplus_crate`, is TRUE if the item is in a surplus crate, FALSE otherwise.
	 * `uplink`, the uplink that bought the item
	 */
	proc/run_on_spawn(obj/item, mob/living/owner, in_surplus_crate = FALSE, obj/item/uplink/uplink)
		return

////////////////////////////////////////// Standard items (generic & nukeops uplink) ///////////////////////////////

// Note: traitor uplinks also list these, so you don't have to make two separate entries.
// Note #2: Nuke ops-exclusive item: /datum/syndicate_buylist/traitor + "objective = /datum/objective/specialist/nuclear".

ABSTRACT_TYPE(/datum/syndicate_buylist/generic)
/datum/syndicate_buylist/generic
	name = "You shouldn't see me!"
	cost = 0
	desc = "You shouldn't see me!"
	can_buy = UPLINK_TRAITOR | UPLINK_NUKE_OP | UPLINK_SPY | UPLINK_SPY_THIEF

/datum/syndicate_buylist/generic/revolver
	name = "Revolver"
	item = /obj/item/storage/box/revolver
	cost = 6
	desc = "The traditional sidearm of a Syndicate field agent. Holds 7 rounds and comes with extra ammo."
	can_buy = UPLINK_TRAITOR | UPLINK_NUKE_OP | UPLINK_SPY_THIEF

/datum/syndicate_buylist/generic/pistol
	name = "Suppressed .22 Pistol"
	item = /obj/item/storage/box/pistol
	cost = 3
	desc = "A fairly weak yet sneaky pistol, it can still be heard but it won't alert anyone about who fired it."
	br_allowed = TRUE

/datum/syndicate_buylist/generic/shotgun
	name = "Shotgun"
	item = /obj/item/storage/box/shotgun
	cost = 8
	desc = "Not exactly stealthy, but it'll certainly make an impression."
	not_in_crates = 1
	can_buy = UPLINK_TRAITOR | UPLINK_NUKE_OP

/datum/syndicate_buylist/generic/radbow
	name = "Rad Poison Crossbow"
	item = /obj/item/gun/energy/crossbow
	cost = 3
	desc = "Crossbow Model C - Now with safer Niobium core. This ranged weapon is great for hitting someone in a dark corridor! They'll never know what hit em! Will slowly recharge between shots."

/datum/syndicate_buylist/generic/garrote
	name = "Fibre Wire"
	item = /obj/item/garrote
	cost = 3
	desc = "Commonly used by special forces for silent removal of isolated targets. Ensure you are out of sight, apply to the target's neck from behind with a firm two-hand grip and wait for death to occur."

/datum/syndicate_buylist/generic/bladed_gloves
	name = "Bladed Gloves"
	item = /obj/item/clothing/gloves/bladed
	cost = 3
	desc = "A pair of transparent gloves with a concealed blade on the back of each hand that cannot be disarmed. Deploy and retract with a finger snap, perfect for the killer-on-the-go!"
	br_allowed = TRUE
	can_buy = UPLINK_TRAITOR | UPLINK_NUKE_OP | UPLINK_SPY_THIEF


/datum/syndicate_buylist/generic/empgrenades
	name = "EMP Grenades"
	item = /obj/item/storage/emp_grenade_pouch
	cost = 1
	desc = "A pouch of EMP grenades, each capable of causing havoc with the electrical and computer systems found aboard the modern space station. Shorts out power systems, causes feedback in electronic vision devices such as thermals, and causes robots to go haywire."
	br_allowed = TRUE
	can_buy = UPLINK_TRAITOR | UPLINK_NUKE_OP | UPLINK_SPY_THIEF | UPLINK_HEAD_REV

/datum/syndicate_buylist/generic/tacticalgrenades
	name = "Tactical Grenades"
	item = /obj/item/storage/tactical_grenade_pouch
	cost = 2
	desc = "A pouch of assorted special-ops grenades."
	br_allowed = TRUE

/datum/syndicate_buylist/generic/voicechanger
	name = "Voice Changer"
	item = /obj/item/voice_changer
	cost = 1
	desc = "This voice-modulation device will dynamically disguise your voice to that of whoever is listed on your identification card, via incredibly complex algorithms. Discretely fits inside most masks, and can be removed with wirecutters."

/datum/syndicate_buylist/generic/chamsuit
	name = "Chameleon Outfit"
	item = /obj/item/storage/backpack/chameleon
	cost = 1
	desc = "A full ensemble of clothing made of advanced fibres that can change colour to suit the needs of the wearer. Comes in a backpack that itelf can be disguised in the same manner. Do not expose to electromagnetic interference."

/datum/syndicate_buylist/generic/syndicard
	name = "Agent Card"
	item = /obj/item/card/id/syndicate
	cost = 1
	desc = "A counterfeit identification card, designed to prevent tracking by the station's AI systems. It features a one-time programmable identification circuit, allowing the entry of a custom false identity. It is also capable of scanning other ID cards and replicating their access credentials."

/datum/syndicate_buylist/generic/emag
	name = "Electromagnet Card (EMAG)"
	item = /obj/item/card/emag
	cost = 6
	desc = "A sophisticated tool of sabotage and infiltration. Capable of shorting out or otherwise bypassing security on door locks, robot friend/foe identification systems, shuttle control consoles, and more!"
	can_buy = UPLINK_TRAITOR | UPLINK_NUKE_OP | UPLINK_SPY_THIEF

/datum/syndicate_buylist/generic/fimplant
	name = "Freedom Implant"
	item = /obj/item/implanter/freedom
	cost = 1
	desc = "An implant that allows instant escape from handcuffs and shackles. Multiple uses possible but not guaranteed."

/datum/syndicate_buylist/generic/spen
	name = "Sleepy Pen"
	item = /obj/item/pen/sleepypen
	cost = 5
	desc = "A small pen that has a syringe filled with a powerful sleeping agent inside. Capable of injecting a victim discretely. Refillable once initial contents are used up."

/datum/syndicate_buylist/generic/jammer
	name = "Signal Jammer"
	item = /obj/item/radiojammer
	cost = 3
	desc = "Silences radios in an area around you while activated. No one will hear them scream."

/datum/syndicate_buylist/generic/psink
	name = "Power Sink"
	item = /obj/item/device/powersink
	cost = 5
	desc = "Lights too bright? Airlocks too automatic? Alarms too functional? Or maybe just nostalgic about the good ol' days before electricity came along? The XL-100 Power Sink addresses all these ills and more. Simply screw to the nearest exposed wiring and flip the switch, and this little wonder will get to work on draining all of that nasty power."
	not_in_crates = 1
	can_buy = UPLINK_TRAITOR | UPLINK_NUKE_OP

/datum/syndicate_buylist/generic/detomatix
	name = "Detomatix Cartridge"
	item = /obj/item/disk/data/cartridge/syndicate
	cost = 1
	desc = "A PDA cartridge allowing remote detonation of other devices. Detonation programs may be accessed through the file manager. Comes complete with readme file."
	can_buy = UPLINK_TRAITOR | UPLINK_NUKE_OP | UPLINK_SPY_THIEF

/datum/syndicate_buylist/generic/trickcigs
	name = "Trick Cigarettes"
	item = /obj/item/cigpacket/syndicate
	cost = 1
	desc = "A pack of Syndicool Lights exploding trick cigarettes. Due to the use of a military-grade explosive, please do not attempt to smoke these after lighting."

/datum/syndicate_buylist/generic/sawfly
	name = "Compact Sawfly"
	item = /obj/item/old_grenade/sawfly/withremote
	cost = 2
	vr_allowed = FALSE
	desc = "A small antipersonnel robot that will not attack anyone of syndicate affiliation. It can be folded up after use."
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF

/datum/syndicate_buylist/generic/sawflymany
	name = "Cluster Sawfly deployer"
	item = /obj/item/old_grenade/spawner/sawflycluster
	cost = 5
	vr_allowed = FALSE
	desc = "An assembly of five antipersonnel robots that will not attack anyone of syndicate affiliation. They can be individually folded up after use."
	can_buy = UPLINK_SPY_THIEF | UPLINK_NUKE_OP
/datum/syndicate_buylist/generic/dnascram
	name = "DNA Scrambler"
	item = /obj/item/dna_scrambler
	cost = 1
	desc = "An injector that gives a new, random identity upon injection, copying the original to be injected later."

/datum/syndicate_buylist/generic/derringer
	name = "Derringer"
	item = /obj/item/gun/kinetic/derringer
	cost = 2
	desc = "A small pistol that can be hidden inside worn clothes and retrieved using the wink emote. Comes with two shots and does extreme damage at close range."
	br_allowed = TRUE

/datum/syndicate_buylist/generic/stealthstorage
	name = "Stealth Storage"
	item = /obj/item/storage/box/syndibox
	cost = 1
	desc = "This little wonder is capable of not only safely storing most small goods, but it can also be tapped against other objects in order to emulate their appearance. Note: May not perform optimally upon close inspection."

/datum/syndicate_buylist/generic/esword
	name = "Cyalume Saber"
	item = /obj/item/sword
	cost = 7
	desc = "A powerful melee weapon, crafted using the latest in applied photonics! When inactive, it is small enough to fit in a pocket!"
	not_in_crates = 1
	can_buy = UPLINK_TRAITOR | UPLINK_NUKE_OP

	run_on_spawn(obj/item/sword/stabby, mob/living/owner, in_surplus_crate=FALSE) //Nukies get red ones
		if (isnukeop(owner) || isnukeopgunbot(owner))
			stabby.light_c.set_color(255, 0, 0)
			stabby.bladecolor = "R"
		return

/datum/syndicate_buylist/generic/katana
	name = "Katana"
	item = /obj/item/swords_sheaths/katana
	cost = 7
	desc = "A Japanese sword created in the fire of a dying star. Comes with a sheath for easier storage"
	can_buy = UPLINK_TRAITOR | UPLINK_NUKE_OP | UPLINK_SPY_THIEF

/datum/syndicate_buylist/generic/wrestling
	name = "Wrestling Belt"
	item = /obj/item/storage/belt/wrestling
	cost = 7
	desc = "A haunted antique wrestling belt, imbued with the spirits of wrestlers past. Wearing it unlocks a number of wrestling moves, which can be accessed in a separate command tab."

/datum/syndicate_buylist/generic/spy_sticker_kit
	name = "Spy Sticker Kit"
	item = /obj/item/storage/box/spy_sticker_kit
	cost = 1
	desc = "This kit contains innocuous stickers that you can use to broadcast audio and observe a video feed wirelessly."

/datum/syndicate_buylist/generic/omnitool
	name = "Syndicate Omnitool"
	item = /obj/item/tool/omnitool/syndicate
	cost = 2
	desc = "A miniature set of tools that you can hide in your clothing and retrieve with the flex emote. Has knife and weldingtool modes."
	br_allowed = TRUE

/datum/syndicate_buylist/generic/bighat
	name = "Syndicate Hat"
	item = /obj/item/clothing/head/bighat/syndicate
	cost = 12
	desc = "Think you're tough shit buddy?"
	not_in_crates = 1 //see /datum/syndicate_buylist/surplus/bighat
	br_allowed = TRUE
	can_buy = UPLINK_TRAITOR | UPLINK_NUKE_OP | UPLINK_SPY

//////////////////////////////////////////////////// Standard items (traitor uplink) ///////////////////////////////////

ABSTRACT_TYPE(/datum/syndicate_buylist/traitor)
/datum/syndicate_buylist/traitor
	name = "You shouldn't see me!"
	cost = 0
	desc = "You shouldn't see me!"
	can_buy = UPLINK_TRAITOR | UPLINK_SPY | UPLINK_SPY_THIEF

/datum/syndicate_buylist/traitor/cloak
	name = "Cloaking Device"
	item = /obj/item/cloaking_device
	cost = 6
	//not_in_crates = 1
	desc = "Hides you from normal sight. AI and Cyborgs will still see you and so will any human with thermals so be careful how you use it."
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF

/datum/syndicate_buylist/traitor/sponge_capsules
	name = "Syndicate Sponge Capsules"
	item = /obj/item/spongecaps/syndicate
	cost = 3
	desc = "A pack of sponge capsules that react with water and produce nasty critters."

/datum/syndicate_buylist/traitor/bomb
	name = "Syndicates in Pipebomb"
	item = /obj/item/pipebomb/bomb/miniature_syndicate
	cost = 3
	vr_allowed = 0
	desc = "A rather volatile pipe bomb packed with miniature syndicate troops."
	br_allowed = TRUE
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF

/datum/syndicate_buylist/traitor/champrojector
	name = "Chameleon Projector"
	item = /obj/item/device/chameleon
	cost = 5
	desc = "Advanced cloaking device that scans an object and, when activated, makes the bearer look like the object. Slows movement while in use."

/datum/syndicate_buylist/traitor/holographic_disguiser
	name = "Holographic Disguiser"
	item = /obj/item/device/disguiser
	cost = 2
	desc = "A device capable of disguising your identity temporarily. Beware of flashes and projectiles!"

/datum/syndicate_buylist/traitor/areacloak
	name = "Cloaking Field Generator"
	item = /obj/item/cloak_gen
	cost = 3
	desc = "Remote-controlled device that produces an area of effect cloaking field while active. Don't lose the remote!"

/datum/syndicate_buylist/traitor/floorcloset
	name = "Floor Closet"
	item = /obj/storage/closet/syndi
	cost = 1
	desc = "This closet was produced using the finest in applied optical illusion technology. When closed, it will dynamically assume the appearance of the floor tile underneath."

/datum/syndicate_buylist/traitor/snidely
	name = "Fake Moustache"
	item = /obj/item/clothing/mask/moustache
	cost = 1
	desc = "The ultimate in disguise technology. This will perfectly conceal your identity from any onlookers and leave them stunned at your majestic facial hair."

/datum/syndicate_buylist/traitor/bowling
	name = "Bowling Kit"
	item = /obj/item/storage/bowling
	cost = 7
	desc = "Comes with several bowling balls and a suit. You won't be able to pluck up the courage to throw them very hard without wearing the suit!"
	br_allowed = TRUE
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF

/datum/syndicate_buylist/traitor/football
	name = "Space-American Football Kit"
	item = /obj/item/storage/football
	cost = 7
	desc = "This kit contains everything you need to become a great football player! Wearing all of the equipment inside will grant you the ability to rush down and tackle foes. You'll also make amazing throws!"
	br_allowed = TRUE
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF

/datum/syndicate_buylist/traitor/mindhack
	name = "Mind Hack implant"
	item = /obj/item/implanter/mindhack
	cost = 3
	vr_allowed = 0
	desc = "Temporarily place an injected victim under your complete control! Faster and more effective than hypnotism! Warning: Implant effects are NOT indefinite."
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF

/datum/syndicate_buylist/traitor/deluxe_mindhack
	name = "Deluxe Mind Hack implant"
	item = /obj/item/implanter/super_mindhack
	cost = 6
	vr_allowed = 0
	desc = "Place an injected victim under your complete control! Enhanced cyberneurostimulators make this version last virtually indefinitely!"
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF

/datum/syndicate_buylist/traitor/microbomb
	name = "Microbomb Implant"
	item = /obj/item/implanter/uplink_microbomb
	cost = 1
	vr_allowed = 0
	desc = "This miniaturized explosive packs a decent punch and will detonate upon the unintentional death of the host. Do not swallow and keep out of reach of children."

/datum/syndicate_buylist/traitor/lightbreaker
	name = "Light Breaker"
	item = /obj/item/lightbreaker
	cost = 4
	desc = "A casette player that breaks all lights near you. It also temporarily deafens and staggers all nearby people. Comes with four charges and has a distinctive sound. Can be rewound with a screwdriver."
	br_allowed = TRUE
	can_buy = UPLINK_TRAITOR | UPLINK_SPY | UPLINK_SPY_THIEF | UPLINK_HEAD_REV

/datum/syndicate_buylist/traitor/ringtone
	name = "SounDreamS PRO cartridge"
	item = /obj/item/disk/data/cartridge/ringtone_syndie
	cost = 1
	desc = "A pirated copy of SounDreamS PRO, a PDA cartridge loaded with dozens of realistic, illegal-sounding sound effects that'll play whenever someone sends a message to your PDA."
	can_buy = UPLINK_TRAITOR | UPLINK_SPY | UPLINK_HEAD_REV

/datum/syndicate_buylist/traitor/sonicgrenades
	name = "Sonic Grenades"
	item = /obj/item/storage/sonic_grenade_pouch
	cost = 2
	desc = "A pouch filled with five sonic grenades, each one packs enough power to shatter reinforced windows and pop eardrums. No more being cornered by an angry mob! Comes with earplugs."
	br_allowed = TRUE
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF

/datum/syndicate_buylist/traitor/pickpocket
	name = "Pickpocket Gun"
	item = /obj/item/gun/energy/pickpocket
	cost = 3
	vr_allowed = 0
	desc = "A stealthy claw gun capable of stealing and planting items, and severely messing with people."
	br_allowed = TRUE
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF

/datum/syndicate_buylist/traitor/surplus
	name = "Surplus Crate"
	item = /obj/storage/crate/syndicate_surplus
	cost = 12
	vr_allowed = 0
	desc = "A crate containing 18-24 credits worth of whatever junk we had lying around."
	can_buy = UPLINK_TRAITOR

	run_on_spawn(var/obj/storage/crate/syndicate_surplus/crate, var/mob/living/owner, in_surplus_crate, obj/item/uplink/uplink)
		crate.spawn_items(owner, uplink)
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
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF | UPLINK_HEAD_REV
*/

//////////////////////////////////////////////// Objective-specific items //////////////////////////////////////////////

/datum/syndicate_buylist/traitor/idtracker
	name = "Target ID Tracker"
	item = /obj/item/pinpointer/idtracker
	cost = 1
	desc = "Allows you to track the IDs of your assassination targets, but only the ID. If they have changed or destroyed it, the pin pointer will not be useful."
	not_in_crates = 1
	vr_allowed = 0
	objective = /datum/objective/regular/assassinate
	can_buy = UPLINK_TRAITOR | UPLINK_SPY | UPLINK_HEAD_REV

	run_on_spawn(var/obj/item/pinpointer/idtracker/tracker, var/mob/living/owner, in_surplus_crate)
		tracker.owner = owner

/datum/syndicate_buylist/traitor/idtracker/spy
	name = "Target ID Tracker (SPY)"
	item = /obj/item/pinpointer/idtracker/spy
	cost = 1
	desc = "Allows you to track the IDs of all other antagonists, but only the ID. If they have changed or destroyed it, the pin pointer will not be useful."
	vr_allowed = 0
	not_in_crates = 1
	objective = /datum/objective/spy_theft/assasinate
	can_buy = UPLINK_TRAITOR | UPLINK_SPY

	run_on_spawn(var/obj/item/pinpointer/idtracker/tracker,var/mob/living/owner, in_surplus_crate)
		tracker.owner = owner

// Gannets Nuke Ops Class Crates - now found under weapon_vendor.dm

/datum/syndicate_buylist/traitor/classcrate
	name = "Class Crate - Generic"
	item = /obj/storage/crate/classcrate
	cost = 0
	desc = "A crate containing a Nuke Ops Class Loadout, this one is generic and you shouldn't see it."
	objective = /datum/objective/specialist/nuclear
	not_in_crates = 1
	can_buy = UPLINK_NUKE_OP

//////////////////////////////////////////////// Job-specific items  ////////////////////////////////////////////////////

/datum/syndicate_buylist/traitor/clowncar
	name = "Clown Car"
	item = /obj/vehicle/clowncar/surplus
	cost = 5
	vr_allowed = 0
	desc = "A funny-looking car designed for circus events. Seats 30, very roomy! Comes with an extra set of clown clothes."
	job = list("Clown")
	can_buy = UPLINK_TRAITOR | UPLINK_HEAD_REV | UPLINK_SPY_THIEF

/datum/syndicate_buylist/traitor/boomboots
	name = "Boom Boots"
	item = /obj/item/clothing/shoes/cowboy/boom
	cost = 12
	vr_allowed = 0
	desc = "These big red boots have an explosive step sound. The entire station is sure to want to show you their appreciation."
	job = list("Clown")
	not_in_crates = 1
	can_buy = UPLINK_TRAITOR | UPLINK_HEAD_REV

/datum/syndicate_buylist/traitor/clown_mask
	name = "Clown Mask"
	item = /obj/item/clothing/mask/gas/syndie_clown
	cost = 5
	vr_allowed = 0
	desc = "A clown mask haunted by the souls of those who honked before. Only true clowns should attempt to wear this. It also functions like a gas mask."
	job = list("Clown")
	not_in_crates = 1
	can_buy = UPLINK_TRAITOR

/datum/syndicate_buylist/traitor/fake_revolver
	name = "Funny-looking Revolver"
	item = /obj/item/storage/box/fakerevolver
	cost = 1
	desc = "A revolver with a twist. It will always fire backwards! Watch some vigilante try to get you NOW!"
	job = list("Clown")
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF

/datum/syndicate_buylist/traitor/chambomb
	name = "Chameleon Bomb Case"
	item = /obj/item/storage/box/chameleonbomb
	cost = 3
	vr_allowed = 0
	desc = "2 questionable mixtures of a chameleon projector and a bomb. Scan an object to take on its appearance, arm the bomb, and then explode the face(s) of whoever tries to touch it."
	br_allowed = TRUE
	job = list("Clown")
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF

/datum/syndicate_buylist/traitor/sinjector
	name = "Speed Injector"
	item = /obj/item/speed_injector
	cost = 3
	desc = "Disguised as a screwdriver, this stealthy device can be loaded with dna injectors which will be injected into the target instantly and stealthily. The dna injector will be altered when inserted so that there will be a ten second delay before the gene manifests in the victim."
	job = list("Geneticist")
	not_in_crates = 1
	can_buy = UPLINK_TRAITOR | UPLINK_SPY

/datum/syndicate_buylist/traitor/minibible
	name = "Miniature Bible"
	item = /obj/item/storage/bible/mini
	cost = 1
	desc = "We understand it can be difficult to carry out some of our missions. Here is some spiritual counsel in a small package."
	job = list("Assistant","Technical Assistant","Medical Assistant","Staff Assistant", "Chaplain", "Clown")
	vr_allowed = 0
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF

/datum/syndicate_buylist/traitor/scroll
	name = "Scroll of the Hardlight Heart"
	item = /obj/item/device/sacred_heart_scroll
	cost = 6
	desc = "A scroll from ages past, sure to fill your heart with pure light... and knives, lots and lots of knives."
	job = list("Chaplain")
	not_in_crates = TRUE
	vr_allowed = FALSE
	can_buy = UPLINK_TRAITOR | UPLINK_SPY

/datum/syndicate_buylist/traitor/contract
	name = "Faustian Bargain Kit"
	item = /obj/item/storage/briefcase/satan
	cost = 8
	desc = "Comes complete with three soul binding contracts, three extra-pointy pens, and one suit provided by Lucifer himself."
	job = list("Chaplain")
	not_in_crates = 1
	vr_allowed = 0
	can_buy = UPLINK_TRAITOR | UPLINK_SPY

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
	br_allowed = TRUE
	job = list("Mailman")
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF

/datum/syndicate_buylist/traitor/chargehacker
	name = "Mining Charge Hacker"
	item = /obj/item/device/chargehacker
	cost = 4
	desc = "A tool designed to hack mining charges so that they will attach to any surface, disguised as a geological scanner."
	not_in_crates = 1
	job = list("Miner")
	can_buy = UPLINK_TRAITOR

/datum/syndicate_buylist/traitor/kudzuseed
	name = "Kudzu Seed"
	item = /obj/item/kudzuseed
	cost = 4
	desc = "Syndikudzu. Interesting. Plant on the floor to grow."
	vr_allowed = 0
	job = list("Botanist", "Staff Assistant")
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF

/datum/syndicate_buylist/traitor/maneater
	name = "Maneater Seed"
	item = /obj/item/seed/maneater
	cost = 1
	desc = "A boon for the green-thumbed agent! Simply plant and nurture to raise your own faithful guard-plant! Feed me, Seymour!"
	not_in_crates = 1
	job = list("Botanist")
	can_buy = UPLINK_TRAITOR

/datum/syndicate_buylist/traitor/saw
	name = "Chainsaw"
	item = /obj/item/saw/syndie
	cost = 7
	desc = "This old earth beauty is made by hand with strict attention to detail. Unlike today's competing botanical chainsaw, it actually cuts things!"
	not_in_crates = 1
	job = list("Botanist")
	can_buy = UPLINK_TRAITOR

/datum/syndicate_buylist/traitor/hotbox_lighter
	name = "Hotbox Lighter"
	item = /obj/item/device/light/zippo/syndicate
	cost = 1
	desc = "The unique fuel mixture both burns five times hotter than a normal flame and produces a much thicker smoke than normal when burning herbs!"
	job = list("Botanist")
	can_buy = UPLINK_TRAITOR

/datum/syndicate_buylist/traitor/waspgrenade
	name = "Wasp Grenades"
	item = /obj/item/storage/box/wasp_grenade_kit
	cost = 3
	desc = "These wasp grenades contain genetically modified extra double large hornets that will surely inspire awe in all your non-botanical friends."
	vr_allowed = FALSE
	job = list("Botanist", "Apiculturist")
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF

/datum/syndicate_buylist/traitor/wasp_crossbow
	name = "Wasp Crossbow"
	item = /obj/item/gun/energy/wasp
	cost = 6
	desc = "Become the member of the Space Cobra Unit you always wanted to be! Spread pain and fear far and wide using this scattershot wasp egg launcher! Through the power of sheer wasp-y fury, this crossbow will slowly recharge between shots and is guaranteed to light up your day with maniacal joy and to bring your enemies no end of sorrow."
	not_in_crates = 1 //the value of the item goes down significantly for non-botanists since only botanists are treated kindly by wasps
	vr_allowed = FALSE
	job = list("Botanist", "Apiculturist")
	can_buy = UPLINK_TRAITOR

/datum/syndicate_buylist/traitor/fakegrenade
	name = "Fake Cleaner Grenades"
	item = /obj/item/storage/box/f_grenade_kit
	cost = 2
	desc = "This cleaning grenade features over 500% of the legal level of active agent. Cleans dirt off of floors and flesh off of bone! Also contains space lube to create a dazzling shine!"
	br_allowed = TRUE
	job = list("Janitor")
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF | UPLINK_HEAD_REV

/datum/syndicate_buylist/traitor/compactor
	name = "Trash Compactor Cart"
	item = /obj/storage/cart/trash/syndicate
	cost = 4
	desc = "Identical in appearance to an ordinary trash cart, this beauty is capable of compacting (1) laying person placed inside at a time. It was originally supposed to only compact nonliving things, but a serendipitous design mistake resulted in 1500 units with a reversed safety unit."
	not_in_crates = 1
	vr_allowed = 0
	job = list("Janitor")
	can_buy = UPLINK_TRAITOR

	run_on_spawn(var/obj/storage/cart/trash/syndicate/cart,var/mob/living/owner)
		if (owner)
			cart.owner_ckey = owner.ckey

/datum/syndicate_buylist/traitor/slip_and_sign
	name = "Slip and Sign"
	item = /obj/item/caution/traitor
	cost = 2
	desc = "This Wet Floor Sign spits out organic superlubricant under everyone nearby unless they are wearing galoshes. That'll teach them to ignore the signs. If you are wearing the long janitor gloves you can click with a bucket (or beaker or drinking glass etc.) to replace the payload."
	job = list("Janitor")
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF | UPLINK_SPY | UPLINK_HEAD_REV

	run_on_spawn(obj/item/caution/traitor/sign, mob/living/owner, in_surplus_crate)
		if(in_surplus_crate)
			new /obj/item/clothing/shoes/galoshes(sign.loc)
			new /obj/item/clothing/gloves/long(sign.loc)

/datum/syndicate_buylist/traitor/overcharged_vacuum
	name = "Overcharged Vacuum Cleaner"
	item = /obj/item/handheld_vacuum/overcharged
	cost = 5
	desc = "This vacuum cleaner's special attack is way more powerful than the regular thing."
	br_allowed = TRUE
	job = list("Janitor")
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF | UPLINK_SPY | UPLINK_HEAD_REV

/datum/syndicate_buylist/traitor/syndanalyser
	name = "Syndicate Device Analyzer"
	item = /obj/item/electronics/scanner/syndicate
	cost = 4
	vr_allowed = 0
	desc = "The shell of a standard Nanotrasen mechanic's analyzer with cutting-edge Syndicate internals. This baby can scan almost anything!"
	job = list("Mechanic")
	can_buy = UPLINK_TRAITOR

/datum/syndicate_buylist/traitor/stimulants
	name = "Stimulants"
	item = /obj/item/storage/box/stimulants
	cost = 6
	desc = "When top agents need energy, they turn to our new line of X-Cite 500 stimulants. This 3-pack of all-natural* and worry-free** blend accelerates perception, endurance, and reaction time to superhuman levels! Shrug off even the cruelest of blows without a scratch! <br><br><font size=-1>*Contains less than 0.5 grams unnatural material per 0.49 gram serving.<br>**May cause dizziness, blurred vision, heart failure, renal compaction, adenoid calcification, or death. Users are recommended to take only a single dose at a time, and let withdrawl symptoms play out naturally.</font>"
	job = list("Medical Doctor","Medical Director","Scientist","Geneticist","Pathologist","Research Director")
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF

/datum/syndicate_buylist/traitor/syringegun
	name = "Syringe Gun"
	item = /obj/item/gun/reagent/syringe
	cost = 3
	desc = "This stainless-steel, revolving wonder fires needles. Perfect for today's safari-loving Syndicate doctor! Loaded by transferring reagents to the gun's internal reservoir."
	job = list("Medical Doctor", "Medical Director", "Research Director", "Scientist", "Bartender")
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF

/datum/syndicate_buylist/traitor/powergloves
	name = "Power Gloves"
	item = /obj/item/clothing/gloves/powergloves
	cost = 6
	desc = "These marvels of modern technology employ nanites and space science to draw energy from nearby cables to zap things. BZZZZT!"
	not_in_crates = 1
	job = list("Engineer", "Chief Engineer", "Mechanic")
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF

/datum/syndicate_buylist/traitor/zappy_implant
	name = "Flyzapper Implant"
	item = /obj/item/implanter/zappy
	cost = 1
	desc = "This implant turns you into a living (or dying) generator, zapping those around you with a volume of electricity that scales with the number of implants upon your demise."
	job = list("Engineer", "Chief Engineer", "Mechanic")
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF

/datum/syndicate_buylist/traitor/poisonbottle
	name = "Poison Bottle"
	item = /obj/item/reagent_containers/glass/bottle/poison
	cost = 1
	vr_allowed = 0 //rat poison
	desc = "A bottle of poison. Which poison? Who knows."
	job = list("Medical Doctor", "Medical Director", "Research Director", "Scientist", "Bartender")
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF

/datum/syndicate_buylist/traitor/poisonbundle
	name = "Poison Bottle Bundle"
	item = /obj/item/storage/box/poison
	cost = 7
	vr_allowed = 0 //rat poison
	desc = "A box filled with seven random poison bottles."
	job = list("Medical Doctor", "Medical Director", "Research Director", "Scientist", "Bartender")
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF

/datum/syndicate_buylist/traitor/chemicompiler
	name = "Chemicompiler"
	item = /obj/item/device/chemicompiler
	cost = 5
	not_in_crates = 1
	desc = "A handheld version of the Chemicompiler machine in Chemistry."
	job = list("Research Director", "Scientist")
	can_buy = UPLINK_TRAITOR

/datum/syndicate_buylist/traitor/robosuit
	name = "Syndicate Robot Frame"
	item = /obj/item/parts/robot_parts/robot_frame/syndicate
	cost = 2
	desc = "A cyborg shell crafted from the finest recycled steel and reverse-engineered microelectronics. A cyborg crafted from this will see only Syndicate operatives (Such as yourself!) as human. Cyborg also comes preloaded with popular game \"Angry About the Bird\" and is compatible with most headphones."
	not_in_crates = 1
	vr_allowed = 0
	job = list("Roboticist")
	can_buy = UPLINK_TRAITOR

/datum/syndicate_buylist/traitor/conversion_chamber
	name = "Conversion Chamber"
	item = /obj/machinery/recharge_station/syndicate
	cost = 8
	vr_allowed = 0
	desc = "A modified standard-issue cyborg recharging station that will automatically convert any human placed inside into a cyborg. Cyborgs created this way will follow a syndicate lawset making them loyal to you."
	job = list("Roboticist")
	not_in_crates = 1
	can_buy = UPLINK_TRAITOR

	run_on_spawn(var/obj/item)
		new /obj/item/wrench(item.loc) // clarify that we need to wrench it down before use


/datum/syndicate_buylist/traitor/safari
	name = "Safari Kit"
	item = /obj/item/storage/box/costume/safari
	cost = 7
	desc = "Almost everything you need to hunt the most dangerous game. Tranquilizer rifle not included."
	br_allowed = TRUE
	job = list("Medical Director")
	can_buy = UPLINK_TRAITOR

	run_on_spawn(obj/item, mob/living/owner, in_surplus_crate)
		if(in_surplus_crate)
			new /obj/item/gun/kinetic/dart_rifle(item.loc)
			new /obj/item/ammo/bullets/tranq_darts(item.loc)

/datum/syndicate_buylist/traitor/pizza_sharpener
	name = "Pizza Sharpener"
	item = /obj/item/kitchen/utensil/knife/pizza_cutter/traitor
	cost = 5
	desc = "Have you ever been making a pizza and thought \"this pizza would be better if I could fatally injure someone by throwing it at them\"? Well think no longer! Because you're sharpening pizzas now. You weirdo."
	br_allowed = TRUE
	job = list("Chef")

/datum/syndicate_buylist/traitor/syndiesauce
	name = "Syndicate Sauce"
	item = /obj/item/reagent_containers/food/snacks/condiment/syndisauce
	cost = 1
	desc = "Our patented secret blend of herbs and spices! Guaranteed to knock even the harshest food critic right off their feet! And into the grave. Because this is poison."
	job = list("Chef", "Bartender")

/datum/syndicate_buylist/traitor/donkpockets
	name = "Syndicate Donk Pockets"
	item = /obj/item/storage/box/donkpocket_w_kit
	cost = 2
	desc = "Ready to eat, no microwave required! The pocket-sandwich station personnel crave, now with added medical agents to heal you up in a pinch! Zero grams trans-fat per serving*!<br><br><font size=1>*Made with partially-hydrogenated wizard blood.</font>"
	job = list("Chef")
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF

/datum/syndicate_buylist/traitor/butcherknife
	name = "Butcher's Knife"
	item = /obj/item/knife/butcher
	cost = 7
	desc = "An extremely sharp knife with a weighted handle for accurate throwing. Caution: May cause extreme bleeding if the cutting edge comes into contact with human flesh."
	not_in_crates = 1
	job = list("Chef")
	can_buy = UPLINK_TRAITOR

/datum/syndicate_buylist/traitor/hotdog_cart
	name = "Syndicate Hot Dog Cart"
	item = /obj/storage/cart/hotdog/syndicate
	cost = 4
	desc = "A sinister hotdog cart which traps people inside and squishes them into, you guessed it, hot dogs."
	not_in_crates = TRUE
	vr_allowed = FALSE //i don't know why this is here but it's on the trash compactor cart so w/e
	job = list("Chef", "Sous-Chef", "Waiter")
	can_buy = UPLINK_TRAITOR

	run_on_spawn(var/obj/storage/cart/hotdog/syndicate/cart, var/mob/living/owner)
		if (owner)
			cart.owner_ckey = owner.ckey

/datum/syndicate_buylist/traitor/moonshine
	name = "Jug of Moonshine"
	item = /obj/item/reagent_containers/food/drinks/moonshine
	cost = 2
	desc = "A jug full of incredibly potent alcohol. Not recommended for human consumption."
	job = list("Bartender")
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF

/datum/syndicate_buylist/traitor/shotglass
	name = "Extra Large Shot Glasses"
	item = /obj/item/storage/box/glassbox/syndie
	cost = 2
	desc = "A box of shot glasses that hold WAAAY more that normal. Cheat at drinking games!"
	job = list("Bartender")
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF

/datum/syndicate_buylist/traitor/vuvuzelagun
	name = "Vuvuzela Gun"
	item = /obj/item/gun/energy/vuvuzela_gun
	cost = 3
	desc = "<b>BZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ</b>"
	job = list("Assistant","Technical Assistant","Medical Assistant","Staff Assistant", "Clown")
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF

/datum/syndicate_buylist/traitor/moustache_grenade
	name = "Moustache Grenade"
	item = /obj/item/old_grenade/moustache
	cost = 1
	desc = "A disturbingly hairy grenade."
	job = list("Assistant","Technical Assistant","Medical Assistant","Staff Assistant", "Clown")

/datum/syndicate_buylist/traitor/hotdog_bomb
	name = "Hotdog Bomb"
	item = /obj/item/gimmickbomb/hotdog
	cost = 1
	desc = "Turn your worst enemies into hotdogs."
	br_allowed = TRUE
	job = list("Chef", "Sous-Chef", "Waiter", "Clown")

/datum/syndicate_buylist/traitor/chemgrenades
	name = "Chem Grenade Starter Kit"
	item = /obj/item/storage/box/grenade_starter_kit
	cost = 2
	desc = "Tired of destroying your own face with acid reactions? Want to make the janitor feel incompetent? This kit gets you started with three grenades. Just add beakers and screw!"
	job = list("Scientist","Research Director")
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF

/datum/syndicate_buylist/traitor/ammo_38AP // 2 TC for 1 speedloader was very poor value compared to other guns and traitor items in general (Convair880).
	name = ".38 AP ammo box"
	item = /obj/item/storage/box/ammo38AP
	cost = 2
	desc = "Armor-piercing ammo for a .38 Special revolver (not included)."
	job = list("Detective")
	can_buy = UPLINK_TRAITOR

/datum/syndicate_buylist/traitor/traitorthermalscanner
	name = "Advanced Optical Thermal Scanner"
	item = /obj/item/clothing/glasses/thermal/traitor
	cost = 3
	desc = "An advanced optical thermal scanner capable of seeing living entities through walls and smoke."
	br_allowed = TRUE
	job = list("Detective")
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF

/datum/syndicate_buylist/traitor/cargo_transporter
	name = "Syndicate Cargo Transporter"
	item = /obj/item/cargotele/traitor
	cost = 3
	vr_allowed = 0
	desc = "A modified cargo transporter which teleports containers to a random spot in space and welds them shut."
	job = list("Quartermaster","Miner","Engineer","Chief Engineer")
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF

/datum/syndicate_buylist/traitor/telegun
	name = "Teleport Gun"
	item = /obj/item/gun/energy/teleport
	cost = 7
	vr_allowed = 0
	desc = "An experimental hybrid between a hand teleporter and a directed-energy weapon. Probably a very bad idea. Note -- Only works in conjunction with a stationary teleporter."
	job = list("Research Director")
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF

/datum/syndicate_buylist/traitor/portapuke
	name = "Port-a-Puke"
	item = /obj/machinery/portapuke
	cost = 7
	desc = "An experimental torture chamber that will make any human placed inside puke until they die!"
	job = list("Janitor")

/datum/syndicate_buylist/traitor/monkey_barrel
	name = "Barrel-O-Monkeys"
	item = /obj/storage/monkey_barrel
	cost = 6
	vr_allowed = 0
	desc = "A barrel of bloodthirsty apes. Careful!"
	br_allowed = TRUE
	job = list("Staff Assistant","Test Subject","Geneticist","Pathologist")

/datum/syndicate_buylist/traitor/mindhack_module
	name = "Mindhack Cloning Module"
	item = /obj/item/cloneModule/mindhack_module
	cost = 6
	vr_allowed = 0
	desc = "An add on to the genetics cloning pod that make anyone cloned loyal to whoever installed it."
	job = list("Geneticist", "Medical Doctor", "Medical Director")

/datum/syndicate_buylist/traitor/deluxe_mindhack_module
	name = "Deluxe Mindhack Cloning Module Kit"
	item = /obj/item/storage/box/mindhack_module_kit
	cost = 10 //  Always leave them 1tc so they can buy the moustache. Style is key.
	vr_allowed = 0
	desc = "A Deluxe Mindhack Cloning Kit. Contains a mindhack cloning module and a cloning lab in a box!"
	job = list("Geneticist", "Medical Doctor", "Medical Director")

/datum/syndicate_buylist/traitor/buddy_ammofab
	name = "Guardbuddy Ammo Replicator"
	item = /obj/item/device/guardbot_module/ammofab
	cost = 1
	vr_allowed = 0
	desc = "A device that allows PR-6S Guardbuddy units to use their internal charge to replenish kinetic ammunition."
	job = list("Research Director")

/datum/syndicate_buylist/traitor/wiretap
	name = "Wiretap Radio Upgrade"
	item = /obj/item/device/radio_upgrade
	cost = 3
	desc = "A small device that may be installed in a headset to grant access to all station channels, along with one reserved for Syndicate operatives."
	vr_allowed = 0
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF

/datum/syndicate_buylist/traitor/tape
	name = "Ducktape"
	item = /obj/item/handcuffs/tape_roll
	cost = 1
	desc = "A roll of duct tape for makeshift handcuffs. Lets you restrain someone 10 times before being used up."

/datum/syndicate_buylist/traitor/scuttlebot
	name = "Controlled Syndicate Scuttlebot"
	item = /obj/item/clothing/head/det_hat/folded_scuttlebot
	cost = 2
	vr_allowed = 0
	desc = "A sneaky robot armed with a camera disguised as a hat, used to spy on people. Comes with it's own remote controlling glasses. Can lift small items and has a disabling flash."
	job = list("Detective")
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF

/datum/syndicate_buylist/traitor/rose
	name = "Poison rose"
	item = /obj/item/plant/flower/rose/poisoned
	cost = 4
	desc = "A regular looking rose hiding a poison capable of muting and briefly incapacitating anyone who smells it."
	job = list("Mime")

/datum/syndicate_buylist/traitor/chicken_grenade
	name = "Chicken Grenade"
	item = /obj/item/old_grenade/chicken
	cost = 1
	vr_allowed = 0
	desc = "A grenade that holds up to 5 chicken eggs. Uses syndicate brainwashing to turn the chickens into hardened warriors immediately on detonation. Normally passive chickens will become aggressive. Use a wrench to unload it."
	job = list("Rancher")
	not_in_crates = 1
	can_buy = UPLINK_TRAITOR

/datum/syndicate_buylist/traitor/ai_laser
	name = "AI Camera Laser Module"
	item = /obj/item/aiModule/ability_expansion/laser
	cost = 6
	vr_allowed = FALSE
	not_in_crates = TRUE
	desc = "An AI module that upgrades any AI connected to the installed law rack access to the lasers installed in the cameras."
	job = list("Captain", "Head of Personnel", "Research Director", "Medical Director", "Chief Engineer")
	can_buy = UPLINK_TRAITOR

/////////////////////////////////////////// Surplus-exclusive items //////////////////////////////////////////////////

ABSTRACT_TYPE(/datum/syndicate_buylist/surplus)
/datum/syndicate_buylist/surplus
	name = "You shouldn't see me!"
	cost = 0
	desc = "You shouldn't see me!"
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF | UPLINK_HEAD_REV | UPLINK_NUKE_OP

/datum/syndicate_buylist/surplus/dagger
	name = "Syndicate Dagger"
	item = /obj/item/dagger/syndicate
	cost = 2
	desc = "An ornamental dagger for stabbing people with."

/datum/syndicate_buylist/surplus/advanced_laser
	name = "Laser Rifle"
	item = /obj/item/gun/energy/plasma_gun
	cost = 6
	desc = "An experimental laser design with a self-charging cerenkite battery."
	br_allowed = TRUE
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF | UPLINK_NUKE_OP

/datum/syndicate_buylist/surplus/breachingT
	name = "Thermite Breaching Charge"
	item = /obj/item/breaching_charge/thermite
	cost = 1
	desc = "A self-contained thermite breaching charge, useful for destroying walls."

/datum/syndicate_buylist/surplus/breaching
	name = "Breaching Charge"
	item = /obj/item/breaching_charge
	cost = 1
	desc = "A self-contained explosive breaching charge, useful for destroying walls."

/datum/syndicate_buylist/surplus/flaregun
	name = "Flare Gun"
	item = /obj/item/storage/box/flaregun // Gave this thing a box of spare ammo. Having only one shot was kinda lackluster (Convair880).
	cost = 2
	desc = "A signal flaregun for emergency use. Or for setting jerks on fire"
	br_allowed = TRUE

/datum/syndicate_buylist/surplus/rifle
	name = "Old Hunting Rifle"
	item = /obj/item/gun/kinetic/hunting_rifle
	cost = 3
	desc = "An old hunting rifle, comes with only four bullets. Use them wisely."
	can_buy = UPLINK_TRAITOR | UPLINK_NUKE_OP

	spy
		cost = 5
		not_in_crates = TRUE
		can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF | UPLINK_NUKE_OP

/datum/syndicate_buylist/surplus/akm
	name = "AKM Assault Rifle"
	item = /obj/item/gun/kinetic/akm
	cost = 12
	desc = "A Cold War relic, loaded with thirty rounds of 7.62x39."
	can_buy = null

/datum/syndicate_buylist/surplus/bananagrenades
	name = "Banana Grenades"
	item = /obj/item/storage/banana_grenade_pouch
	cost = 2
	desc = "Honk."
	can_buy = UPLINK_TRAITOR | UPLINK_HEAD_REV | UPLINK_NUKE_OP

/datum/syndicate_buylist/surplus/concussiongrenades
	name = "Concussion Grenades"
	item = /obj/item/storage/concussion_grenade_pouch
	cost = 2
	desc = "A pouch full of corpo-war surplus concussion grenades."
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF

/datum/syndicate_buylist/surplus/turboflash_box
	name = "Flash/cell assembly box"
	item = /obj/item/storage/box/turbo_flash_kit
	cost = 1
	desc = "A box full of common stun weapons with power cells hastily wired into them. Looks dangerous."

/datum/syndicate_buylist/surplus/syndicate_armor
	name = "Syndicate Command Armor"
	item = /obj/item/clothing/suit/space/industrial/syndicate
	cost = 5
	desc = "A set of syndicate command armor. I guess the last owner must have died."
	br_allowed = TRUE
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF | UPLINK_NUKE_OP
	run_on_spawn(var/obj/item)
		new /obj/item/clothing/head/helmet/space/industrial/syndicate/(item.loc)

/datum/syndicate_buylist/surplus/egun_upgrade
	name = "Advanced Energy Cell"
	item = /obj/item/ammo/power_cell/self_charging/medium
	cost = 2
	desc = "An advanced self-charging power cell, the ideal upgrade for an energy weapon!"
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF | UPLINK_NUKE_OP

// Why not, I guess? Cleaned up the old mine code, might as well use it (Convair880).
/datum/syndicate_buylist/surplus/landmine
	name = "Land Mine Pouch"
	item = /obj/item/storage/landmine_pouch
	cost = 1
	desc = "A pouch of old anti-personnel mines we found in the warehouse."
	br_allowed = TRUE
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF | UPLINK_NUKE_OP

/datum/syndicate_buylist/surplus/beartrap
	name = "Bear Trap Pouch"
	item = /obj/item/storage/beartrap_pouch
	cost = 1
	desc = "Just in case you happen to run into some space bears."
	br_allowed = TRUE
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF | UPLINK_NUKE_OP

// At the time of writing, you can't get these anywhere else. And they fit the purpose of surplus crates quite well, I suppose (Convair880).
// changed to sechuds cause why not - haine
/datum/syndicate_buylist/surplus/cybereye_kit_sechud
	name = "Ocular Prosthesis Kit (SecHUD)"
	item = /obj/item/device/ocular_implanter
	cost = 1
	desc = "A pair of surplus cybereyes that can access the Security HUD system. Comes with a convenient but terrifying implanter."
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF | UPLINK_SPY | UPLINK_NUKE_OP

/datum/syndicate_buylist/surplus/emaghypo
	name = "Hacked Hypospray"
	item = /obj/item/reagent_containers/hypospray/emagged
	cost = 1
	desc = "A special hacked hypospray, capable of holding any chemical!"
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF | UPLINK_NUKE_OP

/datum/syndicate_buylist/surplus/sarin_grenade
	name = "Sarin Grenade"
	item = /obj/item/chem_grenade/sarin
	cost = 1
	desc = "A terrifying grenade containing a potent nerve gas. Try not to get caught in the smoke."
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF | UPLINK_NUKE_OP

/////////////////////////////////////////// Irregular Items //////////////////////////////////////////////////
// For things that aren't seen in a regular uplink but are in the buylist datum, e.g. Syndicate commander uplink gear

ABSTRACT_TYPE(/datum/syndicate_buylist/commander)
/datum/syndicate_buylist/commander
	name = "You shouldn't see me!"
	cost = 0
	desc = "You shouldn't see me!"
	not_in_crates = TRUE
	can_buy = UPLINK_NUKE_COMMANDER // Fun story here, I made the shit mistake of assuming that surplus crates and spy bounties couldn't roll this, leading to this shit https://imgur.com/a/uMaM0oV

/datum/syndicate_buylist/commander/reinforcement
	name = "Reinforcements"
	item = /obj/item/remote/reinforcement_beacon
	item2 = /obj/item/paper/reinforcement_info
	cost = 2
	desc = "Request a (probably) top-of-the-line Syndicate gunbot to help assist your team."
	category = "Main"

/datum/syndicate_buylist/commander/ammobag
	name = "Ammo Bag"
	item = /obj/item/ammo/ammobox/nukeop
	cost = 2
	desc = "A bag that allows you to fabricate standard ammo for most Syndicate weaponry. Due to power restrictions, ammo can only be fabricated a certain amount of times per bag. Ammo size restrictions apply."
	category = "Main"

/datum/syndicate_buylist/commander/ammobag_spec
	name = "Specialist Ammo Bag"
	item = /obj/item/ammo/ammobox/nukeop/spec_ammo
	cost = 3
	desc = "A bag that allows you to fabricate specialist ammo for some Syndicate weaponry. It even lets you fabricate explosive ammunition!"
	category = "Main"

/datum/syndicate_buylist/commander/designator
	name = "Laser Designator"
	item = /obj/item/device/laser_designator/syndicate
	item2 = /obj/item/paper/designator_info
	cost = 3
	desc = "A handheld, monocular laser designator that allows you to call in heavy fire support from the Cairngorm. Comes with 2 charges."
	category = "Main"

/datum/syndicate_buylist/commander/deployment_pods
	name = "Rapid Deployment Remote"
	item = /obj/item/device/deployment_remote
	item2 = /obj/item/paper/deployment_info
	cost = 4
	desc = "A handheld remote allowing you, your team, and the nuclear device to be sent in anywhere at a moment's notice!"
	category = "Main"

/datum/syndicate_buylist/commander/bomb_remote
	name = "Nuclear Bomb Teleporter"
	item = /obj/item/remote/nuke_summon_remote
	cost = 1
	desc = "Did you lose the nuke? Have no fear, with this handy one-use remote, you can immediately call it back to you!"
	category = "Main"

/datum/syndicate_buylist/commander/mrl
	name = "Fomalhaut MRL"
	item = /obj/item/gun/kinetic/mrl/loaded
	cost = 3
	desc = "A  6-barrel multiple rocket launcher armed with guided micro-missiles. Warning: Can and will target other Operatives."
	category = "Main"

/////////////////////////////////////////// Telecrystals //////////////////////////////////////////////////

/datum/syndicate_buylist/generic/telecrystal
	name = "Pure Telecrystal"
	item = /obj/item/uplink_telecrystal
	cost = 1
	desc = "A pure Telecrystal, orignating from plasma giants. Used as currency in Syndicate Uplinks."

	telecrystal = TRUE
	vr_allowed = 0
	not_in_crates = 1
	can_buy = UPLINK_TRAITOR | UPLINK_HEAD_REV | UPLINK_NUKE_OP

	New()
		. = ..()
		name = "[syndicate_currency]"

	run_on_spawn(var/obj/item/uplink_telecrystal/tc, mob/living/owner, in_surplus_crate)
		tc.name = "[syndicate_currency]"

/datum/syndicate_buylist/generic/trick_telecrystal
	name = "Trick Pure Telecrystal"
	item = /obj/item/explosive_uplink_telecrystal
	cost = 1
	desc = "A small, highly volatile explosive designed to look like a pure Telecrystal."
	telecrystal = TRUE
	vr_allowed = 0
	not_in_crates = 1
	can_buy = UPLINK_TRAITOR | UPLINK_HEAD_REV

	New()
		. = ..()
		name = "Trick [syndicate_currency]"

	run_on_spawn(var/obj/item/uplink_telecrystal/tc, mob/living/owner, in_surplus_crate=FALSE)
		tc.name = "[syndicate_currency]"

/////////////////////////////////////////////// Disabled items /////////////////////////////////////////////////////

/datum/syndicate_buylist/traitor/fogmaster
	name = "Fog Machine"
	item = /obj/machinery/fogmachine
	cost = 0 // Needs to be fixed and less laggy.
	desc = "Make a hell of a party with the FOGMASTER 3000. Fill with chemicals and the machine does the rest! Give em something they won't ever forget, or wake up from!"
	job = list("Scientist","Botanist")
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF

/datum/syndicate_buylist/traitor/hisgrace
	name = "Artistic Toolbox"
	item = /obj/item/storage/toolbox/memetic
	item2 = /obj/item/paper/memetic_manual
	cost = 0
	desc = "Maybe paint a really insulting picture of your foe? To be honest, we have no idea what is even in these or where they came from, a huge crate of them just showed up at our warehouse around a month ago. We're sure it's something very handy, though!"
	job = list("Chaplain")
	vr_allowed = 0
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF

/datum/syndicate_buylist/traitor/lawndarts
	name = "Lawn Darts"
	item = /obj/item/storage/box/lawndart_kit
	cost = 0 // 20 brute damage, 10 bleed throwing weapon. Embed is nice but rad poison bow is stealthier and more effective
	desc = "Three deadly throwing darts that embed themselves into your target."
	job = list("Assistant","Technical Assistant","Medical Assistant","Staff Assistant","Bartender","Clown")
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF | UPLINK_SPY

// round specific

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
	item = /obj/item/device/flash/revolution
	cost = 5
	desc = "This flash never runs out and will convert susceptible crew when a rev head uses it. It will also allow the rev head to break counter-revolutionary implants."
	vr_allowed = 0
	not_in_crates = 1

/datum/syndicate_buylist/generic/head_rev/revflashbang
	name = "Revolutionary Flashbang"
	item = /obj/item/chem_grenade/flashbang/revolution
	cost = 2
	desc = "This single-use flashbang will convert all crew within range. It doesn't matter who primes the flash - it will convert all the same."

/datum/syndicate_buylist/generic/head_rev/revsign
	name = "Revolutionary Sign"
	item = /obj/item/revolutionary_sign
	cost = 4
	desc = "This large revolutionary sign will inspire all nearby revolutionaries and grant them small combat buffs. A rev head needs to be holding this sign for it to have any effect."

/datum/syndicate_buylist/generic/head_rev/rev_dagger
	name = "Sacrificial Dagger"
	item = /obj/item/dagger
	cost = 2
	desc = "An ornamental dagger for stabbing people with."

/datum/syndicate_buylist/generic/head_rev/rev_normal_flash
	name = "Flash"
	item = /obj/item/device/flash
	cost = 1
	desc = "Just a standard-issue flash. Won't remove implants like the Revolutionary Flash."

