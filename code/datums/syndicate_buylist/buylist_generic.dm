
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
	items = list(/obj/item/storage/box/revolver)
	cost = 6
	desc = "The traditional sidearm of a Syndicate field agent. Holds 7 rounds and comes with extra ammo."
	can_buy = UPLINK_TRAITOR | UPLINK_NUKE_OP | UPLINK_SPY_THIEF

/datum/syndicate_buylist/generic/pistol
	name = "Suppressed .22 Pistol"
	items = list(/obj/item/storage/box/pistol)
	cost = 3
	desc = "A fairly weak yet sneaky pistol, it can still be heard but it won't alert anyone about who fired it."
	br_allowed = TRUE

/datum/syndicate_buylist/generic/shotgun
	name = "Shotgun"
	items = list(/obj/item/storage/box/shotgun)
	cost = 8
	desc = "Not exactly stealthy, but it'll certainly make an impression."
	not_in_crates = TRUE
	can_buy = UPLINK_TRAITOR | UPLINK_NUKE_OP

/datum/syndicate_buylist/generic/rifle
	name = "Old Hunting Rifle"
	items = list(/obj/item/storage/box/hunting_rifle)
	cost = 7
	desc = "An old hunting rifle, comes with a scope and eight bullets. Use them wisely."
	can_buy = UPLINK_TRAITOR

/datum/syndicate_buylist/generic/radbow
	name = "Rad Poison Crossbow"
	items = list(/obj/item/gun/energy/crossbow)
	cost = 3
	desc = "Crossbow Model C - Now with safer Niobium core. This ranged weapon is great for hitting someone in a dark corridor! They'll never know what hit em! Will slowly recharge between shots."

/datum/syndicate_buylist/generic/garrote
	name = "Fibre Wire"
	items = list(/obj/item/garrote)
	cost = 3
	desc = "Commonly used by special forces for silent removal of isolated targets. Ensure you are out of sight, apply to the target's neck from behind with a firm two-hand grip and wait for death to occur."

/datum/syndicate_buylist/generic/bladed_gloves
	name = "Bladed Gloves"
	items = list(/obj/item/clothing/gloves/bladed)
	cost = 3
	desc = "A pair of transparent gloves with a concealed blade on the back of each hand that cannot be disarmed. Deploy and retract with a finger snap, perfect for the killer-on-the-go!"
	br_allowed = TRUE
	can_buy = UPLINK_TRAITOR | UPLINK_NUKE_OP | UPLINK_SPY_THIEF


/datum/syndicate_buylist/generic/empgrenades
	name = "EMP Grenades"
	items = list(/obj/item/storage/emp_grenade_pouch)
	cost = 1
	desc = "A pouch of EMP grenades, each capable of causing havoc with the electrical and computer systems found aboard the modern space station. Shorts out power systems, causes feedback in electronic vision devices such as thermals, and causes robots to go haywire."
	br_allowed = TRUE
	can_buy = UPLINK_TRAITOR | UPLINK_NUKE_OP | UPLINK_SPY_THIEF | UPLINK_HEAD_REV

/datum/syndicate_buylist/generic/tacticalgrenades
	name = "Tactical Grenades"
	items = list(/obj/item/storage/tactical_grenade_pouch)
	cost = 2
	desc = "A pouch of assorted special-ops grenades."
	br_allowed = TRUE

/datum/syndicate_buylist/generic/voicechanger
	name = "Voice Changer"
	items = list(/obj/item/voice_changer)
	cost = 1
	desc = "This voice-modulation device will dynamically disguise your voice to that of whoever is listed on your identification card, via incredibly complex algorithms. Discretely fits inside most masks, and can be removed with wirecutters."

/datum/syndicate_buylist/generic/chamsuit
	name = "Chameleon Outfit"
	items = list(/obj/item/storage/backpack/chameleon)
	cost = 1
	desc = "A full ensemble of clothing made of advanced fibres that can change colour to suit the needs of the wearer. Comes in a backpack that itself can be disguised in the same manner. Do not expose to electromagnetic interference."

/datum/syndicate_buylist/generic/syndicard
	name = "Agent Card"
	items = list(/obj/item/card/id/syndicate)
	cost = 1
	desc = "A counterfeit identification card, designed to prevent tracking by the station's AI systems. It features a one-time programmable identification circuit, allowing the entry of a custom false identity. It is also capable of scanning other ID cards and replicating their access credentials."

/datum/syndicate_buylist/generic/cashcase
	name = "Cash Briefcase"
	items = list(/obj/item/cash_briefcase/syndicate/loaded)
	cost = 2
	max_buy = 2
	desc = "A syndicate briefcase designed to hold large quantities of cash. Comes loaded with 15 thousand credits."

/datum/syndicate_buylist/generic/emag
	name = "Electromagnet Card (EMAG)"
	items = list(/obj/item/card/emag)
	cost = 6
	desc = "A sophisticated tool of sabotage and infiltration. Capable of shorting out or otherwise bypassing security on door locks, robot friend/foe identification systems, shuttle control consoles, and more!"
	can_buy = UPLINK_TRAITOR | UPLINK_NUKE_OP | UPLINK_SPY_THIEF

/datum/syndicate_buylist/generic/fimplant
	name = "Freedom Implant"
	items = list(/obj/item/implanter/freedom)
	cost = 1
	desc = "An implant that allows instant escape from handcuffs and shackles. Multiple uses possible but not guaranteed."

/datum/syndicate_buylist/generic/signaler_implant
	name = "Signaler Implant"
	items = list(/obj/item/implanter/signaler)
	cost = 1
	desc = "An implant that can send configurable signals. Can be used while stunned or handcuffed."
	not_in_crates = TRUE
	vr_allowed = FALSE
	can_buy = UPLINK_TRAITOR

/datum/syndicate_buylist/generic/marionette_implant
	name = "Marionette Implant"
	items = list(/obj/item/implanter/marionette)
	cost = 1
	desc = "Receives data signals and converts them into synaptic impulses, for remote-control puppeting! Packet compatible.<br><br>\
		The first purchase of this item will be contained in a box that also includes instructions and a remote. Subsequent purchases will only \
		provide additional implanters."
	vr_allowed = FALSE
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF

	run_on_spawn(obj/item, mob/living/owner, in_surplus_crate, obj/item/uplink/uplink)
		if (!uplink?.purchase_log[src.type])
			var/obj/item/storage/box/marionetteimp_kit/MI = new(item.loc, TRUE)
			// Spief uplinks put the spawned item in the player's hands after this proc,
			// so we need to account for that and make sure we don't spit the box out onto the ground
			if (uplink.purchase_flags & UPLINK_SPY_THIEF || uplink.purchase_flags & UPLINK_SPY)
				SPAWN(0)
					owner.drop_item(item)
					MI.storage.add_contents(item)
					owner.put_in_hand_or_drop(MI)
			else
				MI.storage.add_contents(item)

/datum/syndicate_buylist/generic/spen
	name = "Sleepy Pen"
	items = list(/obj/item/pen/sleepypen)
	cost = 5
	desc = "A small pen that has a syringe filled with a powerful sleeping agent inside. Capable of injecting a victim discretely. Refillable once initial contents are used up."

/datum/syndicate_buylist/generic/jammer
	name = "Signal Jammer"
	items = list(/obj/item/radiojammer)
	cost = 3
	desc = "Silences radios and PDAs in an area around you while activated. No one will hear them scream."

/datum/syndicate_buylist/generic/psink
	name = "Power Sink"
	items = list(/obj/item/device/powersink)
	cost = 5
	desc = "Lights too bright? Airlocks too automatic? Alarms too functional? Or maybe just nostalgic about the good ol' days before electricity came along? The XL-100 Power Sink addresses all these ills and more. Simply screw to the nearest exposed wiring and flip the switch, and this little wonder will get to work on draining all of that nasty power."
	not_in_crates = TRUE
	can_buy = UPLINK_TRAITOR | UPLINK_NUKE_OP

/datum/syndicate_buylist/generic/detomatix
	name = "Detomatix Cartridge"
	items = list(/obj/item/disk/data/cartridge/syndicate)
	cost = 1
	desc = "A PDA cartridge allowing remote detonation of other devices. Detonation programs may be accessed through the file manager. Comes complete with readme file."
	can_buy = UPLINK_TRAITOR | UPLINK_NUKE_OP | UPLINK_SPY_THIEF

/datum/syndicate_buylist/generic/trickcigs
	name = "Trick Cigarettes"
	items = list(/obj/item/cigpacket/syndicate)
	cost = 1
	desc = "A pack of Syndicool Lights exploding trick cigarettes. Due to the use of a military-grade explosive, please do not attempt to smoke these after lighting."

/datum/syndicate_buylist/generic/sawfly
	name = "Compact Sawfly"
	items = list(/obj/item/old_grenade/sawfly/firsttime/withremote)
	cost = 1
	vr_allowed = FALSE
	desc = "A small antipersonnel robot that will not attack anyone of syndicate affiliation. It can be folded up after use."
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF

/datum/syndicate_buylist/generic/sawflymany
	name = "Cluster Sawfly deployer"
	items = list(/obj/item/old_grenade/spawner/sawflycluster)
	cost = 5
	vr_allowed = FALSE
	desc = "An assembly of five antipersonnel robots that will not attack anyone of syndicate affiliation. They can be individually folded up after use."
	can_buy = UPLINK_SPY_THIEF | UPLINK_NUKE_OP
/datum/syndicate_buylist/generic/dnascram
	name = "DNA Scrambler"
	items = list(/obj/item/dna_scrambler)
	cost = 1
	desc = "An injector that gives a new, random identity upon injection, copying the original to be injected later."

/datum/syndicate_buylist/generic/derringer
	name = "Derringer"
	items = list(/obj/item/gun/kinetic/derringer)
	cost = 2
	desc = "A small pistol that can be hidden inside worn clothes and retrieved using the wink emote. Comes with two shots and does extreme damage at close range."
	br_allowed = TRUE

/datum/syndicate_buylist/generic/stealthstorage
	name = "Stealth Storage"
	items = list(/obj/item/storage/box/syndibox)
	cost = 1
	desc = "This little wonder is capable of not only safely storing most small goods, but it can also be tapped against other objects in order to emulate their appearance. Note: May not perform optimally upon close inspection."

/datum/syndicate_buylist/generic/esword
	name = "Cyalume Saber"
	items = list(/obj/item/sword)
	cost = 7
	desc = "A powerful melee weapon, crafted using the latest in applied photonics! When inactive, it is small enough to fit in a pocket!"
	not_in_crates = TRUE
	can_buy = UPLINK_TRAITOR | UPLINK_NUKE_OP

	run_on_spawn(obj/item/sword/stabby, mob/living/owner, in_surplus_crate=FALSE) //Nukies get red ones
		if (isnukeop(owner) || isnukeopgunbot(owner))
			stabby.light_c.set_color(255, 0, 0)
			stabby.bladecolor = "R"
		..()

/datum/syndicate_buylist/generic/katana
	name = "Katana"
	items = list(/obj/item/swords_sheaths/katana)
	cost = 7
	desc = "A Japanese sword created in the fire of a dying star. Comes with a sheath for easier storage"
	not_in_crates = TRUE
	can_buy = UPLINK_TRAITOR | UPLINK_NUKE_OP | UPLINK_SPY_THIEF

/datum/syndicate_buylist/generic/wrestling
	name = "Wrestling Belt"
	items = list(/obj/item/storage/belt/wrestling)
	cost = 7
	desc = "A haunted antique wrestling belt, imbued with the spirits of wrestlers past. Wearing it unlocks a number of wrestling moves."
	not_in_crates = TRUE
	can_buy = UPLINK_TRAITOR | UPLINK_NUKE_OP

/datum/syndicate_buylist/generic/spy_sticker_kit
	name = "Spy Sticker Kit"
	items = list(/obj/item/storage/box/spy_sticker_kit)
	cost = 1
	desc = "This kit contains innocuous stickers that you can use to broadcast audio and observe a video feed wirelessly."

/datum/syndicate_buylist/generic/omnitool
	name = "Syndicate Omnitool"
	items = list(/obj/item/tool/omnitool/syndicate)
	cost = 2
	desc = "A miniature set of tools that you can hide in your clothing and retrieve with the flex emote. Has knife and weldingtool modes. The handle is insulated, no gloves needed!"
	br_allowed = TRUE

/datum/syndicate_buylist/generic/bighat
	name = "Syndicate Hat"
	items = list(/obj/item/clothing/head/bighat/syndicate)
	cost = 12
	desc = "Think you're tough shit buddy?"
	not_in_crates = TRUE //see /datum/syndicate_buylist/surplus/bighat
	br_allowed = TRUE
	can_buy = UPLINK_TRAITOR | UPLINK_NUKE_OP | UPLINK_SPY

/datum/syndicate_buylist/generic/barrier
	name = "Aegis Riot Barrier"
	items = list(/obj/item/barrier/chargable/syndicate)
	cost = 2
	desc = "The Aegis Riot Barrier, which while lacking the compactibility of its NT counterpart, can refract bullets allowing for greater crowd control, and boasts greater handling."
	can_buy = UPLINK_TRAITOR | UPLINK_NUKE_OP | UPLINK_SPY_THIEF | UPLINK_HEAD_REV

//////////////////////////////////////////////////// Standard items (traitor uplink) ///////////////////////////////////

ABSTRACT_TYPE(/datum/syndicate_buylist/traitor)
/datum/syndicate_buylist/traitor
	name = "You shouldn't see me!"
	cost = 0
	desc = "You shouldn't see me!"
	can_buy = UPLINK_TRAITOR | UPLINK_SPY | UPLINK_SPY_THIEF

/datum/syndicate_buylist/traitor/cloak
	name = "Cloaking Device"
	items = list(/obj/item/cloaking_device)
	cost = 6
	//not_in_crates = TRUE
	desc = "Hides you from normal sight. AI and Cyborgs will still see you and so will any human with thermals so be careful how you use it."
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF

/datum/syndicate_buylist/traitor/sponge_capsules
	name = "Syndicate Sponge Capsules"
	items = list(/obj/item/spongecaps/syndicate)
	cost = 3
	desc = "A pack of sponge capsules that react with water and produce nasty critters."

/datum/syndicate_buylist/traitor/bomb
	name = "Syndicates in Pipebomb"
	items = list(/obj/item/assembly/timer_ignite_pipebomb/mini_syndicate)
	cost = 3
	vr_allowed = FALSE
	desc = "A rather volatile pipe bomb packed with miniature syndicate troops. Assembled and ready for use"
	br_allowed = TRUE
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF

/datum/syndicate_buylist/traitor/champrojector
	name = "Chameleon Projector"
	items = list(/obj/item/device/chameleon)
	cost = 3
	desc = "Advanced cloaking device that scans an object and, when activated, makes the bearer look like the object. Slows movement while in use."

/datum/syndicate_buylist/traitor/holographic_disguiser
	name = "Holographic Disguiser"
	items = list(/obj/item/device/disguiser)
	cost = 2
	desc = "A device capable of disguising your identity temporarily. Beware of flashes and projectiles!"

/datum/syndicate_buylist/traitor/areacloak
	name = "Cloaking Field Generator"
	items = list(/obj/item/cloak_gen)
	cost = 3
	desc = "Remote-controlled device that produces an area of effect cloaking field while active. Don't lose the remote!"

/datum/syndicate_buylist/traitor/floorcloset
	name = "Floor Closet"
	items = list(/obj/storage/closet/syndi)
	cost = 1
	desc = "This closet was produced using the finest in applied optical illusion technology. When closed, it will dynamically assume the appearance of the floor tile underneath."

	run_on_spawn(obj/item, mob/living/owner, in_surplus_crate, obj/item/uplink/uplink)
		. = ..()
		if(in_surplus_crate)
			var/obj/storage/closet/syndi/closet = item
			closet.open()

/datum/syndicate_buylist/traitor/snidely
	name = "Fake Moustache"
	items = list(/obj/item/clothing/mask/moustache)
	cost = 1
	desc = "The ultimate in disguise technology. This will perfectly conceal your identity from any onlookers and leave them stunned at your majestic facial hair."

/datum/syndicate_buylist/traitor/bowling
	name = "Bowling Kit"
	items = list(/obj/item/storage/bowling)
	cost = 6
	desc = "Comes with several bowling balls and a suit. You won't be able to pluck up the courage to throw them very hard without wearing the suit!"
	br_allowed = TRUE
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF

/datum/syndicate_buylist/traitor/football
	name = "Space-American Football Kit"
	items = list(/obj/item/storage/football)
	cost = 7
	desc = "This kit contains everything you need to become a great football player! Wearing all of the equipment inside will grant you the ability to rush down and tackle foes. You'll also make amazing throws!"
	br_allowed = TRUE
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF

/datum/syndicate_buylist/traitor/mindhack
	name = "Mind Hack implant"
	items = list(/obj/item/implanter/mindhack)
	cost = 3
	vr_allowed = FALSE
	desc = "Temporarily place an injected victim under your complete control! Faster and more effective than hypnotism! Warning: Implant effects are NOT indefinite. Will not work on anyone protected by those pesky security issue mind-protection implants."
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF

/datum/syndicate_buylist/traitor/deluxe_mindhack
	name = "Deluxe Mind Hack implant"
	items = list(/obj/item/implanter/super_mindhack)
	cost = 6
	vr_allowed = FALSE
	desc = "Place an injected victim under your complete control! Enhanced cyberneurostimulators make this version last virtually indefinitely! Will not work on anyone protected by those pesky security issue mind-protection implants."
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF

/datum/syndicate_buylist/traitor/microbomb
	name = "Microbomb Implant"
	items = list(/obj/item/implanter/uplink_microbomb)
	cost = 1
	vr_allowed = FALSE
	desc = "This miniaturized explosive packs a decent punch and will detonate upon the unintentional death of the host. Do not swallow and keep out of reach of children."

/datum/syndicate_buylist/traitor/lightbreaker
	name = "Light Breaker"
	items = list(/obj/item/lightbreaker)
	cost = 4
	desc = "A casette player that breaks all lights near you. It also temporarily deafens and staggers all nearby people. Comes with four charges and has a distinctive sound. Can be rewound with a screwdriver."
	br_allowed = TRUE
	can_buy = UPLINK_TRAITOR | UPLINK_SPY | UPLINK_SPY_THIEF | UPLINK_HEAD_REV

/datum/syndicate_buylist/traitor/ringtone
	name = "SounDreamS PRO cartridge"
	items = list(/obj/item/disk/data/cartridge/ringtone_syndie)
	cost = 1
	desc = "A pirated copy of SounDreamS PRO, a PDA cartridge loaded with dozens of realistic, illegal-sounding sound effects that'll play whenever someone sends a message to your PDA."
	can_buy = UPLINK_TRAITOR | UPLINK_SPY | UPLINK_HEAD_REV

/datum/syndicate_buylist/traitor/sonicgrenades
	name = "Sonic Grenades"
	items = list(/obj/item/storage/sonic_grenade_pouch)
	cost = 2
	desc = "A pouch filled with five sonic grenades, each one packs enough power to shatter reinforced windows and pop eardrums. No more being cornered by an angry mob! Comes with earplugs."
	br_allowed = TRUE
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF

/datum/syndicate_buylist/traitor/pickpocket
	name = "Pickpocket Gun"
	items = list(/obj/item/gun/energy/pickpocket)
	cost = 3
	vr_allowed = FALSE
	desc = "A stealthy claw gun capable of stealing and planting items, and severely messing with people."
	br_allowed = TRUE
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF

/datum/syndicate_buylist/traitor/surplus
	name = "Surplus Crate"
	items = list(/obj/storage/crate/syndicate_surplus)
	cost = 12
	vr_allowed = FALSE
	desc = "A crate containing 18-24 credits worth of whatever junk we had lying around."
	can_buy = UPLINK_TRAITOR

	run_on_spawn(var/obj/storage/crate/syndicate_surplus/crate, var/mob/living/owner, in_surplus_crate, obj/item/uplink/uplink)
		crate.spawn_items(owner, uplink)

/datum/syndicate_buylist/traitor/fingerprinter
	name = "Fingerprinter"
	items = list(/obj/item/device/fingerprinter)
	desc = "A tool which allows you to scan and plant fingerprints."
	cost = 1

/datum/syndicate_buylist/traitor/blowgun
	name = "Blowgun"
	items = list(/obj/item/storage/briefcase/instruments/blowgun/tranq)
	desc = "A blowgun with a set of 8 knockout darts. \"Cunningly\" disguised as a flute."
	cost = 4
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF


/datum/syndicate_buylist/traitor/wiretap
	name = "Wiretap Radio Upgrade"
	items = list(/obj/item/device/radio_upgrade)
	cost = 3
	desc = "A small device that may be installed in a headset to grant access to all station channels, along with one reserved for Syndicate operatives."
	vr_allowed = FALSE
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF

/datum/syndicate_buylist/traitor/syndicate_radio_upgrade
	name = "Syndicate Radio Upgrades"
	items = list(/obj/item/device/radio_upgrade/syndicatechannel,
				/obj/item/device/radio_upgrade/syndicatechannel)
	cost = 1
	desc = "A pair of small devices that may be installed in a headset to grant access to a secure radio channel reserved for Syndicate operatives."
	vr_allowed = FALSE
	can_buy = UPLINK_TRAITOR

/datum/syndicate_buylist/traitor/tape
	name = "Ducktape"
	items = list(/obj/item/handcuffs/tape_roll)
	cost = 1
	desc = "A roll of duct tape for makeshift handcuffs. Lets you restrain someone 10 times before being used up."
