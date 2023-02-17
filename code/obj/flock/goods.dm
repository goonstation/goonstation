// Some misc goods for trade and stuff
//
// CONTENTS:
// Resource container
// Flockburger
// Flocknugget
// Incapacitor
// Flockpod

/////////////////////
// GNESIS CONTAINER
/////////////////////
/obj/item/reagent_containers/gnesis
	name = "fluid-filled octahedron"
	desc = "An octahedral container with a moving fluid inside it. It's not clear how to get the contents of it out."
	icon = 'icons/misc/featherzone.dmi'
	icon_state = "minicache"
	inhand_image_icon = 'icons/mob/inhand/hand_medical.dmi'
	item_state = "beaker"
	rc_flags = RC_VISIBLE | RC_SPECTRO
	mat_changename = 0
	mat_changedesc = 0
	mat_changeappearance = 0

/obj/item/reagent_containers/gnesis/New()
	..()
	src.create_reagents(50)
	reagents.add_reagent("flockdrone_fluid", 50)
	src.setMaterial(getMaterial("gnesis"))

////////////////
// FLOCKBURGER
////////////////
/obj/item/reagent_containers/food/snacks/burger/flockburger
	name = "flockburger"
	desc = "Nothing says delicious like a mouth full of glass!"
	icon_state = "flockburger"
	initial_reagents = list("silicon"=10,"limeade"=5,"radium"=1)

////////////////
// FLOCKNUGGET
////////////////
/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget/flock
	name = "flocknugget"
	desc = "Well, it isn't any more artificial than your normal chicken nugget. Probably a lot crunchier, too."
	icon_state = "flocknugget0"
	bites_left = 2
	initial_volume = 20

/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget/flock/heal(var/mob/M)
	if (icon_state == "flocknugget0")
		icon_state = "flocknugget1"
	return ..()

////////////////
// INCAPACITOR
////////////////
/obj/item/gun/energy/flock
	name = "incapacitor"
	desc = "A clunky projectile weapon of alien machine origin. It appears to have been based off of a couple pictures of regular human guns, but with no clear understanding of ergonomics."
	icon_state = "incapacitor"
	item_state = "incapacitor"
	force = 1
	rechargeable = 0 // yeah this is weird alien technology good fucking luck charging it
	can_swap_cell = 0 // No
	cell_type = /obj/item/ammo/power_cell/self_charging/flockdrone
	projectiles = null
	is_syndicate = 1 // it's less that this is a syndicate weapon and more that replicating it isn't trivial
	custom_cell_max_capacity = 100

/obj/item/gun/energy/flock/New()
	set_current_projectile(new/datum/projectile/energy_bolt/flockdrone)
	projectiles = list(current_projectile)
	..()

/obj/item/gun/energy/flock/special_desc(dist, mob/user)
	if (!isflockmob(user))
		return
	var/list/ret = list()
	if(!(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST))
		ret["charge"] = "?"
		ret["max_charge"] = "?"
	return {"<span class='flocksay'><span class='bold'>###=-</span> Ident confirmed, data packet received.
		<br><span class='bold'>ID:</span> Incapacitor
		<br><span class='bold'>Energy:</span> [ret["charge"]]
		<br><span class='bold'>Max Energy:</span> [ret["max_charge"]]
		<br><span class='bold'>###=-</span></span><br>"}

////////////
// FLOCKCACHE
////////////
/obj/item/flockcache //compressed resource cube
	name = "weird cube"
	desc = "A weird looking cube. Seems to be raw material"
	icon_state = "cube"
	icon = 'icons/misc/featherzone.dmi'
	var/resources = 10

/obj/item/flockcache/special_desc(dist, mob/user)
	if (!isflockmob(user))
		return
	return {"<span class='flocksay'><span class='bold'>###=-</span> Ident confirmed. data packet received.
		<br><span class='bold'>ID:</span> Resource Cache
		<br><span class='bold'>Resources:</span> [resources]
		<br><span class='bold'>###=-</span></span>"}
