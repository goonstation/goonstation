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
	/// Typepaths of the items that will be spawned when the datum is purchased
	var/list/atom/items = list()
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
	/// Is this buylist entry ammo for another weapon?
	var/ammo = FALSE
	/// If the item should be allowed to be purchased in the VR murderbox
	var/vr_allowed = TRUE
	/// If the item can be created as loot in Battle Royale
	var/br_allowed = FALSE
	/// If the item should show up in surplus crates or not
	var/not_in_crates = FALSE
	/// How often should this show up in a surplus crate/spy bounty?
	var/surplus_weight = 50
	/// The category of the item, currently unused (somewhat used in the Nukeop Commander uplink)
	var/category
	/// Bitflags for what uplinks can buy this item (see `_std/defines/uplink.dm` for flags)
	var/can_buy
	/// The maximum amount a given uplink can buy this item
	var/max_buy = INFINITY

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
		if(!in_surplus_crate)
			owner.put_in_hand_or_drop(item)

//////////////////////////////////////////////// Special ammunition //////////////////////////////////////////////

/datum/syndicate_buylist/traitor/ammo_38AP // 2 TC for 1 speedloader was very poor value compared to other guns and traitor items in general (Convair880).
	name = ".38 AP ammo box"
	items = list(/obj/item/storage/box/ammo38AP)
	cost = 2
	ammo = TRUE
	desc = "Armor-piercing ammo for a .38 Special or Kestrel revolver (not included)."
	can_buy = UPLINK_TRAITOR

	run_on_spawn(obj/item/the_thing, mob/living/owner, in_surplus_crate)
		if(in_surplus_crate)
			new /obj/item/gun/kinetic/zipgun(the_thing.loc)
			return
		..()

/datum/syndicate_buylist/traitor/ammo_38ricochet
	name = ".38 Ricochet ammo box"
	items = list(/obj/item/storage/box/ammo38ricochet)
	cost = 2
	ammo = TRUE
	desc = "Bouncy ammo for a .38 Special or Kestrel revolver (not included)."
	can_buy = UPLINK_TRAITOR

	run_on_spawn(obj/item/the_thing, mob/living/owner, in_surplus_crate)
		if(in_surplus_crate)
			new /obj/item/gun/kinetic/zipgun(the_thing.loc)
			return
		..()

//////////////////////////////////////////////// Objective-specific items //////////////////////////////////////////////

/datum/syndicate_buylist/traitor/idtracker
	name = "Target ID Tracker"
	items = list(/obj/item/pinpointer/idtracker)
	cost = 1
	desc = "Allows you to track the IDs of your assassination targets, but only the ID. If they have changed or destroyed it, the pin pointer will not be useful."
	not_in_crates = TRUE
	vr_allowed = FALSE
	objective = /datum/objective/regular/assassinate
	can_buy = UPLINK_TRAITOR | UPLINK_SPY | UPLINK_HEAD_REV

	run_on_spawn(var/obj/item/pinpointer/idtracker/tracker, var/mob/living/owner, in_surplus_crate)
		tracker.owner = owner
		..()

/datum/syndicate_buylist/traitor/idtracker/spy
	name = "Target ID Tracker (SPY)"
	items = list(/obj/item/pinpointer/idtracker/spy)
	cost = 1
	desc = "Allows you to track the IDs of all other antagonists, but only the ID. If they have changed or destroyed it, the pin pointer will not be useful."
	vr_allowed = FALSE
	not_in_crates = TRUE
	objective = /datum/objective/spy_theft/assasinate
	can_buy = UPLINK_TRAITOR | UPLINK_SPY

	run_on_spawn(var/obj/item/pinpointer/idtracker/tracker,var/mob/living/owner, in_surplus_crate)
		tracker.owner = owner
		..()

// Gannets Nuke Ops Class Crates - now found under weapon_vendor.dm

/datum/syndicate_buylist/traitor/classcrate
	name = "Class Crate - Generic"
	items = list(/obj/storage/crate/classcrate)
	cost = 0
	desc = "A crate containing a Nuke Ops Class Loadout, this one is generic and you shouldn't see it."
	objective = /datum/objective/specialist/nuclear
	not_in_crates = TRUE
	can_buy = UPLINK_NUKE_OP

/////////////////////////////////////////// Telecrystals //////////////////////////////////////////////////

/datum/syndicate_buylist/generic/telecrystal
	name = "Pure Telecrystal"
	items = list(/obj/item/uplink_telecrystal)
	cost = 1
	desc = "A pure Telecrystal, orignating from plasma giants. Used as currency in Syndicate Uplinks."

	telecrystal = TRUE
	vr_allowed = FALSE
	not_in_crates = TRUE
	can_buy = UPLINK_TRAITOR | UPLINK_HEAD_REV | UPLINK_NUKE_OP

	New()
		. = ..()
		name = "[syndicate_currency]"

	run_on_spawn(var/obj/item/uplink_telecrystal/tc, mob/living/owner, in_surplus_crate)
		tc.name = "[syndicate_currency]"
		..()

/datum/syndicate_buylist/generic/trick_telecrystal
	name = "Trick Pure Telecrystal"
	items = list(/obj/item/uplink_telecrystal/trick)
	cost = 1
	desc = "A small, highly volatile explosive designed to look like a pure Telecrystal."
	telecrystal = TRUE
	vr_allowed = FALSE
	not_in_crates = TRUE
	can_buy = UPLINK_TRAITOR | UPLINK_HEAD_REV

	New()
		. = ..()
		name = "Trick [syndicate_currency]"

	run_on_spawn(var/obj/item/uplink_telecrystal/tc, mob/living/owner, in_surplus_crate=FALSE)
		tc.name = "[syndicate_currency]"
		..()

/////////////////////////////////////////////// Disabled items /////////////////////////////////////////////////////

/datum/syndicate_buylist/traitor/fogmaster
	name = "Fog Machine"
	items = list(/obj/machinery/fogmachine)
	cost = 0 // Needs to be fixed and less laggy.
	desc = "Make a hell of a party with the FOGMASTER 3000. Fill with chemicals and the machine does the rest! Give em something they won't ever forget, or wake up from!"
	job = list("Scientist","Botanist")
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF

/datum/syndicate_buylist/traitor/hisgrace
	name = "Artistic Toolbox"
	items = list(/obj/item/storage/toolbox/memetic, /obj/item/paper/memetic_manual)
	cost = 0
	desc = "Maybe paint a really insulting picture of your foe? To be honest, we have no idea what is even in these or where they came from, a huge crate of them just showed up at our warehouse around a month ago. We're sure it's something very handy, though!"
	job = list("Chaplain")
	vr_allowed = FALSE
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF

/datum/syndicate_buylist/traitor/lawndarts
	name = "Lawn Darts"
	items = list(/obj/item/storage/box/lawndart_kit)
	cost = 0 // 20 brute damage, 10 bleed throwing weapon. Embed is nice but rad poison bow is stealthier and more effective
	desc = "Three deadly throwing darts that embed themselves into your target."
	job = list("Assistant","Technical Assistant","Medical Assistant","Staff Assistant","Bartender","Clown")
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF | UPLINK_SPY
