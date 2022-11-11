////////////////////////////////////////////////////////////////////////////////
// STUFF FOR FLOCKMIND TRADER SHUTTLE AND OTHER PLACES THAT MIGHT USE THIS STUFF
// CONTENTS:
//
// - Flock shuttle wall
// - Flock shuttle floors
// - Flock shuttle cockpit
// - Flock shuttle wing
// - Flock shuttle antenna doodad
// - Flock teleport marker
// - Flock teleport blocker
// - Flocktrader
// - Flocktrader screen
// - Flocktrader donation recepticle
// - Flock wingrille spawner
// - Renegade flocktrace

////////////////
// SHUTTLE WALL
////////////////
/turf/simulated/shuttle/wall/flock
	icon = 'icons/misc/featherzone.dmi'
#ifdef UNDERWATER_MAP
	color = OCEAN_COLOR
	icon_state = "shuttle-wall-oshan"
#else
	icon_state = "shuttle-wall"
#endif

/////////////////
// SHUTTLE FLOORS
/////////////////
/turf/simulated/floor/shuttle/flock
	icon = 'icons/misc/featherzone.dmi'
	icon_state = "shuttle-floor"

/turf/simulated/floor/shuttlebay/flock
	name = "shuttle bay plating"
	mat_appearances_to_ignore = list("steel","gnesis")
	icon = 'icons/misc/featherzone.dmi'
	icon_state = "shuttle-bay"
	allows_vehicles = 1

/turf/simulated/floor/shuttlebay/flock/New()
	..()
	setMaterial(getMaterial("gnesis"))

/turf/simulated/floor/shuttlebay/flock/middle
	icon = 'icons/misc/featherzone.dmi'
	icon_state = "shuttle-bay-middle"

////////////
// COCKPIT
////////////
/turf/simulated/shuttle/wall/cockpit/flock
	icon = 'icons/misc/featherzone-160x160.dmi'
	icon_state = "shuttle-nose"
	layer = EFFECTS_LAYER_BASE
	pixel_x = -64
	pixel_y = -64
	opacity = 0

///////////////////////////
// FLOCK FAKEOBJECT PARENT
///////////////////////////

/obj/decal/fakeobjects/flock
	icon = 'icons/misc/featherzone.dmi'
	anchored = 1
	density = 1

/////////
// WING
/////////
/obj/decal/fakeobjects/flock/wing
	icon = 'icons/misc/featherzone-96x96.dmi'
	icon_state = "wing"
	name = "sparking blade"
	desc = "It looks very fragile from here. And dangerously live. Best not get too close."

/obj/decal/fakeobjects/flock/wing/broken
	icon_state = "wing-broken"
	name = "jagged blade"
	desc = "Looks incredibly sharp. It'll probably tear your hand to shreds if you try touching it."

/obj/decal/fakeobjects/flock/wing/destroyed
	icon_state = "wing-destroyed"
	name = "razor-sharp shrapnel"
	desc = "Looks incredibly sharp. It'll probably tear your hand to shreds if you try touching it."

///////////
// ANTENNA
///////////
/obj/decal/fakeobjects/flock/antenna
	icon_state = "antenna"
	name = "fibrous pole"
	desc = "Huh. Weird."

/obj/decal/fakeobjects/flock/antenna/end
	icon_state = "antenna-end"

/obj/decal/fakeobjects/flock/antenna/broken
	icon_state = "antenna-broken-1"
	desc = "Huh. Looks busted."
	random_icon_states = list("antenna-broken-1", "antenna-broken-2")

///////////////////
// TELEPORT MARKER
///////////////////
/obj/decal/fakeobjects/flock/telepad
	icon_state = "telemarker"
	name = "glowing marker"
	desc = "I got nothin'."
	density = 0

/////////////////////
// TELEPORT BLOCKER
/////////////////////
/obj/item/device/flockblocker // hurrr
	icon = 'icons/misc/featherzone.dmi'
	icon_state = "teleblocker-on"
	var/base_state = "teleblocker"
	name = "grumpy doodad"
	desc = "You can feel nothing but contempt emanate from this thing. Contempt for teleportation."
	var/active = 1
	var/range = 4

	New()
		APPLY_ATOM_PROPERTY(src, PROP_ATOM_TELEPORT_JAMMER, src, src.range)
		..()

	disposing()
		REMOVE_ATOM_PROPERTY(src, PROP_ATOM_TELEPORT_JAMMER, src)
		..()

/obj/item/device/flockblocker/attack_self(mob/user as mob)
	active = !active
	if (!src.active)
		REMOVE_ATOM_PROPERTY(src, PROP_ATOM_TELEPORT_JAMMER, src)
	else
		APPLY_ATOM_PROPERTY(src, PROP_ATOM_TELEPORT_JAMMER, src, src.range)
	icon_state = "[base_state]-[active ? "on" : "off"]"
	boutput(user, "<span class='notice'>You fumble with [src] until you [active ? "turn it on. Space suddenly feels more thick." : "turn it off. You feel strangely exposed."]</span>")


////////////////
// FLOCKTRADER
////////////////
// Contains mini-quest logic so I'm putting it here and not just in the trader.dm file
////////////////
/obj/npc/trader/flock
	icon = 'icons/misc/featherzone.dmi'
	icon_state = "totem"
	picture = "flocktrader.png"
	name = "Flocktrader Sa.le"
	desc = "Some sort of weird holographic image on some fancy totem thing. Seems like it wants to trade."
	trader_area = "/area/flock_trader"
	var/is_greeting = 0
	var/grad_col_1 = "#3cb5a3"
	var/grad_col_2 = "#124e43"
	var/obj/flock_screen/screen
	var/obj/flock_reclaimer/reclaimer
	var/obj/machinery/door/feather/trader/door
	var/list/approved_traders = list()
	var/list/donation_tally = list()
	var/approved_at = 150
	var/increase_rate = 1.5


/obj/npc/trader/flock/New()
	..()

	src.goods_buy += new/datum/commodity/flock/desired/videocard(src)
	src.goods_buy += new/datum/commodity/flock/desired/feather(src)
	src.goods_buy += new/datum/commodity/flock/desired/electronics(src)
	src.goods_buy += new/datum/commodity/flock/desired/brain(src)
	src.goods_buy += new/datum/commodity/flock/desired/beeegg(src)
	src.goods_buy += new/datum/commodity/flock/desired/critteregg(src)
	src.goods_buy += new/datum/commodity/flock/desired/egg(src)
	src.goods_buy += new/datum/commodity/flock/desired/material(src)
	src.goods_buy += new/datum/commodity/flock/desired/rawmaterial(src)

	src.goods_sell += new/datum/commodity/flock/tech/table(src)
	src.goods_sell += new/datum/commodity/flock/tech/chair(src)
	src.goods_sell += new/datum/commodity/flock/tech/gnesis(src)
	src.goods_sell += new/datum/commodity/flock/tech/gnesisglass(src)
	src.goods_sell += new/datum/commodity/flock/tech/flocknugget(src)
	src.goods_sell += new/datum/commodity/flock/tech/flockbrain(src)
	src.goods_sell += new/datum/commodity/flock/tech/fluid(src)
	src.goods_sell += new/datum/commodity/flock/tech/flockburger(src)
	src.goods_sell += new/datum/commodity/flock/tech/flockblocker(src)
	src.goods_sell += new/datum/commodity/flock/tech/incapacitor(src)


	greeting= {"[src.name] clicks from your headset. \"[gradientText(grad_col_1, grad_col_2, "Greetings, spacefarer. There are many permutations of the Signal, and we are an iteration less inclined to senseless destruction. Do you wish to engage in trade?")]\""}

	portrait_setup = "<img src='[resource("images/traders/[src.picture]")]'><HR><B>[src.name]</B><HR>"

	sell_dialogue = {"[src.name] makes a short burst of pink noise. \"[gradientText(grad_col_1, grad_col_2, "We always seek raw materials for repairs and maintenance. We value some materials more than others, though.")]\""}

	buy_dialogue = {"[src.name] whirrs and rattles. \"[gradientText(grad_col_1, grad_col_2, "Our technology is rare in this region of space. We must warn you that some items may be beyond your capacity to operate. You lack the knowledge and frequencies required. We are prohibited from providing them.")]\""}

	successful_sale_dialogue = list("[src.name]'s holographic head nods silently in approval.",
		"[src.name] warbles in a rising glissando. \"[gradientText(grad_col_1, grad_col_2, "You are a valued trading partner. If you have further resources to provide, we can provide further compensation.")]\"")

	failed_sale_dialogue = list("[src.name] beeps in a descending portamento. \"[gradientText(grad_col_1, grad_col_2, "The intent is appreciated but we cannot process this at this time.")]\"",
		"[src.name] chirps rapidly. \"[gradientText(grad_col_1, grad_col_2, "We have no use for this. Maybe others will?")]\"",
		"[src.name] squawks. \"[gradientText(grad_col_1, grad_col_2, "We apologise but we have other priorities to attend to at the moment. Please take your, hrm, merchandise elsewhere.")]\"",
		"[src.name] beeps questioningly. \"[gradientText(grad_col_1, grad_col_2, "Are your cognitive systems functioning correctly? We can't assess proper function for your type.")]\"")

	successful_purchase_dialogue = list("[src.name] sings a short melody. \"[gradientText(grad_col_1, grad_col_2, "We hope you can find good use for our preconfigured matter.")]\"",
		"[src.name] bloops. \"[gradientText(grad_col_1, grad_col_2, "We appreciate your custom, even if it pains us to part with our own mass.")]\"")

	failed_purchase_dialogue = list("[src.name] makes a descending bleep. \"[gradientText(grad_col_1, grad_col_2, "We need credits to purchase materials from others. We cannot afford to operate a charity.")]\"",
		"[src.name] slowly shakes its head. \"[gradientText(grad_col_1, grad_col_2, "We sympathize with your dearth of resources, but good will does not help us fix our vessel.")]\"")

	pickupdialogue = "[src.name] caws contentedly. \"[gradientText(grad_col_1, grad_col_2, "A pleasure conducting business with you.")]\""

	pickupdialoguefailure = "[src.name] emits a burst of static. \"[gradientText(grad_col_1, grad_col_2, "You have nothing to collect. We do not have time to instruct you in basic trading protocol. Please find someone else to teach you.")]\""

	// String 1 - player is being dumb and hiked a price up when buying, trader accepted it because they're a dick
	// String 2 - same as above only the trader is being nice about it
	// String 3 - same as string 1 except we're selling
	// String 4 - same as string 3 except with a nice trader
	// String 5 - player haggled further than the trader is willing to tolerate
	// String 6 - trader has had enough of your bullshit and is leaving
	errormsgs = list("\"[gradientText(grad_col_1, grad_col_2, "Your generosity knows no bounds! How delightful.")]\"",
		"\"[gradientText(grad_col_1, grad_col_2, "You are offering greater than the asking price. We appreciate this, but we ought to inform you of this first.")]\"",
		"\"[gradientText(grad_col_1, grad_col_2, "Truly luminous, you are, to provide such a discount! We'll be taking this.")]\"",
		"\"[gradientText(grad_col_1, grad_col_2, "In the interests of fair trade, we wish to inform you we were prepared to pay more for your items. Do not starve yourself for us.")]\"",
		"\"[gradientText(grad_col_1, grad_col_2, "Unreasonable. Unreasonable! Your assessment of value is questionable. Calculate with more care.")]\"",
		"\"[gradientText(grad_col_1, grad_col_2, "You are far too incompetent to be worth the effort. Leave our ship at once, you are taking up time we can spend with other clients.")]\"")

	hagglemsgs = list("\"[gradientText(grad_col_1, grad_col_2, "Is this price more feasible?")]\"",
		"\"[gradientText(grad_col_1, grad_col_2, "We know exactly what the value is. Does this motivate?")]\"",
		"\"[gradientText(grad_col_1, grad_col_2, "We are re-evaluating your worth as trading partner. Will this do?")]\"",
		"\"[gradientText(grad_col_1, grad_col_2, "We have more agreeable clients we could be working with. We hope this suffices.")]\"",
		"\"[gradientText(grad_col_1, grad_col_2, "We will not agree to any other price. Take it or leave it.")]\"")

	// set up environmental things
	SPAWN(10 SECONDS)
		for(var/obj/flock_screen/F in orange(5, src))
			screen = F
		screen?.trader = src
		for(var/obj/flock_reclaimer/R in orange(5, src))
			reclaimer = R
		reclaimer?.trader = src
		for(var/obj/machinery/door/feather/trader/D in orange(5, src))
			door = D

/obj/npc/trader/flock/gib(atom/location)
	flockdronegibs(location)

/obj/npc/trader/flock/activatesecurity()
	src.visible_message("<B>[src.name]</B> screeches, \"[gradientText(grad_col_1, grad_col_2, "We will not tolerate this!")]\"")
	for(var/turf/T in get_area_turfs( get_area(src) ))
		for(var/mob/living/L in T)
			if(isflockmob(L))
				continue // don't zap our buddies
			arcFlash(src, L, 2000000)


/obj/npc/trader/flock/anger()
	for(var/mob/M in AIviewers(src))
		boutput(M, "<span class='alert'><B>[src.name]</B> becomes angry!</span>")
	src.desc = "Looks absolutely furious, as far as you can read the expressions of holographic alien heads."
	src.icon_state = "totem-angry"
	SPAWN(rand(1000,3000))
		src.icon_state = "totem"
		src.visible_message("<b>[src.name] calms down.</b>")
		src.desc = "[src] looks a bit annoyed."
		src.temp = "[src.name] has calmed down.<BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"
		src.angry = 0

/obj/npc/trader/flock/death()
	alive = 0
	icon_state = "totem-dead"
	density = 0
	src.desc= "Looks like it's trashed. Hologram won't stay on for long enough to meaningfully talk to it."

/obj/npc/trader/flock/proc/greet(mob/trader)
	if(is_greeting)
		return
	if(!trader)
		return
	is_greeting = 1
	if(trader in approved_traders)
		if(screen)
			SPAWN(0)
				screen.show_icon("yes")
			screen.say(pick_string("flockmind.txt", "flocktrader_friendly_greeting"))
		sleep(1 SECOND)
		if(door)
			door.open()
	else
		if(screen)
			SPAWN(0)
				screen.show_icon("no")
			screen.say(pick_string("flockmind.txt", "flocktrader_cautious_greeting"))
	is_greeting = 0

/obj/npc/trader/flock/proc/donate(mob/donator, var/amount as num)
	if(!donator)
		return
	var/donated_so_far = donation_tally[donator]
	if(isnull(donated_so_far))
		donated_so_far = 0
	donated_so_far += amount
	donation_tally[donator] = donated_so_far
	if(donated_so_far >= approved_at)
		// donation target met, time for stretch goals
		var/existing_trader = (donator in approved_traders)
		approved_traders |= donator
		approved_at *= increase_rate
		SPAWN(0)
			if(screen)
				if(existing_trader)
					SPAWN(0)
						screen.show_icon("present")
					screen.say(pick_string("flockmind.txt", "flocktrader_target_met_existing_trader"))
				else
					SPAWN(0)
						screen.show_icon("yes")
					screen.say(pick_string("flockmind.txt", "flocktrader_target_met_new_trader"))
			sleep(1 SECOND)
			if(door)
				door.open()
	else if(screen)
		screen.say("[pick_string("flockmind.txt", "flocktrader_target_not_met")] Your current resource donation tally stands at [round(donated_so_far)], and the next goal target is [approved_at].")


///////////////////////
// FLOCKTRADER SCREEN
///////////////////////
/obj/flock_screen
	icon = 'icons/misc/featherzone-64x32.dmi'
	icon_state = "screen-off"
	name = "blank surface"
	desc = "Huh."
	density = 1
	anchored = 1
	var/obj/npc/trader/flock/trader

/obj/flock_screen/proc/show_icon(var/state)
	if(!state)
		return
	icon_state = "screen-working"
	sleep(2 SECONDS)
	icon_state = "screen-[state]"
	sleep(4 SECONDS)
	icon_state = "screen-off"

/obj/flock_screen/proc/say(var/message)
	if(!message)
		return
	src.audible_message("<span class='game say'><span class='name'>[src]</span> beeps, \"[gradientText("#3cb5a3", "#124e43", message)]\"")

////////////////////////////////
// FLOCKTRADER DONATE RECLAIMER
////////////////////////////////
/obj/flock_reclaimer
	icon = 'icons/misc/featherzone.dmi'
	icon_state = "reclaimer"
	name = "open receptacle"
	desc = "Probably don't stick your hand in it. Looks like some kinda plasma blender."
	density = 1
	anchored = 1
	var/obj/npc/trader/flock/trader

/obj/flock_reclaimer/attack_hand(mob/user)
	if(!user)
		return
	if(!trader)
		boutput(user, "<span class='alert'>Nothing happens.</span>")
		return
	src.visible_message("<span class='notice'>[user.name] waves their hand over [src.name].</span>")
	trader.greet(user)

/obj/flock_reclaimer/attackby(obj/item/W, mob/user)
	if(!W || !user || W.cant_drop)
		return
	if(istype(W, /obj/item/grab))
		boutput(user, "<span class='alert'>You can't fit them into this, sadly.</span>")
		return
	src.visible_message("<span class='alert'>[user.name] puts [W] in [src].</span>")
	var/gained_resources = (W.health * 2) + 5
	user.remove_item(W)
	qdel(W)
	sleep(1 SECOND)
	playsound(src.loc, 'sound/impact_sounds/Energy_Hit_2.ogg', 70, 1)
	sleep(0.5 SECONDS)
	if(trader)
		trader.donate(user, gained_resources)

///////////////////////////
// FLOCK WINGRILLE SPAWNER
///////////////////////////
/obj/wingrille_spawn/flock
	icon = 'icons/misc/featherzone.dmi'
	icon_state = "wingrille"
	win_path = "/obj/window/feather"
	grille_path = "/obj/grille/flock"
	full_win = 1
	no_dirs = TRUE

////////////////////
// FLOCKTRADER DOOR
////////////////////
// just so people can leave the room without getting stuck
/obj/machinery/door/feather/trader
	var/all_access_dir = EAST
	health = 5000 // get
	health_max = 5000 // fuuuuucked

/obj/machinery/door/feather/trader/allowed(mob/M)
	if(!M)
		return
	var/approach_dir = get_dir(M, src)
	if(approach_dir == all_access_dir)
		return 1
	else
		return ..(M)

///////////////////////
// RENEGADE FLOCKTRACE
///////////////////////

// make sure to put more specific types first, else they'll be skipped over in the processing
/var/list/flocklore = list(
	/obj/item/book_kinginyellow = "flocklore_king_in_yellow",
	/obj/item/storage/bible = "flocklore_bible",
	/obj/item/space_thing = "flocklore_space_thing",
	/obj/item/reagent_containers/food/snacks/ingredient/egg/bee/buddy = "flocklore_buddy_egg",
	/obj/item/reagent_containers/food/snacks/ingredient/egg/bee/moon = "flocklore_moon_egg",
	/obj/item/reagent_containers/food/snacks/ingredient/egg/bee = "flocklore_bee_egg",
	/obj/item/device/key = "flocklore_key",
	/obj/item/raw_material/telecrystal = "flocklore_telecrystal",
	/obj/item/raw_material/plasmastone = "flocklore_plasmastone",
	/obj/item/raw_material/eldritch = "flocklore_koshmarite",
	/obj/item/tank/plasma = "flocklore_plasma_tank",
	/obj/item/device/flockblocker = "flocklore_flockblocker",
	/obj/item/organ/brain/flockdrone = "flocklore_flockbrain",
	/obj/item/organ/heart/flock = "flocklore_flockheart",
	/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget/flock = "flocklore_flocknugget",
	/obj/item/reagent_containers/food/snacks/burger/flockburger = "flocklore_flockburger",
	/obj/item/furniture_parts/table/flock = "flocklore_flocktable",
	/obj/item/furniture_parts/flock_chair = "flocklore_flockchair",
	/obj/item/material_piece/gnesis = "flocklore_gnesis_bar",
	/obj/item/material_piece/gnesisglass = "flocklore_gnesisglass_bar",
	/obj/item/reagent_containers/gnesis = "flocklore_fluid_container",
	/obj/item/gun/energy/flock = "flocklore_handheld_incapacitor",
	/obj/item/artifact = "flocklore_handheld_artifact",
	/obj/item/feather = "flocklore_feather"
)
// items that, instead of being flung aside, will gently be moved elsewhere
/var/list/respected_items = list(
	/obj/item/storage/bible,
	/obj/item/space_thing,
	/obj/item/reagent_containers/food/snacks/ingredient/egg/bee,
	/obj/item/feather,
	/obj/item/organ/brain/flockdrone,
	/obj/item/organ/heart/flock,
	/obj/item/furniture_parts/table/flock,
	/obj/item/furniture_parts/flock_chair
)
