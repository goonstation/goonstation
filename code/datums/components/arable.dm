/**
  * Makes a [turf] or [atom/movable] hold a plant datum by attaching an invisible plantpot ([/obj/machinery/plantpot/bareplant])
  *
  * Seed will then be planted and then grow out of target and become interactible through clicking directly for atom/movable
  *
  *   Note: Bareplant pots are less effective than typical plantpots so hydroponics trays are goto.
  */
/datum/component/arable
	var/auto_water = TRUE
	var/multi_plant = TRUE
	var/obj/machinery/plantpot/bareplant/P

	/** Component will destoy itself after plantpot is destroyed */
	single_use
		multi_plant = FALSE

	/** Plantpot must be watered manually (interacted with like a hydroponics tray clicking directly on the plant) */
	manual_water
		auto_water = FALSE

TYPEINFO(/datum/component/arable)
	initialization_args = list()

/datum/component/arable/Initialize()
	if(!istype(parent, /turf) && !istype(parent, /atom/movable))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_ATTACKBY, .proc/plant_seed)

/datum/component/arable/proc/plant_seed(atom/A, obj/item/I, mob/user)
	PRIVATE_PROC(TRUE)
	if(P?.disposed)
		if(istype(A, /atom/movable))
			var/atom/movable/AM = A
			AM.vis_contents -= P
		P = null

	if(P)
		return
	if(istype(I, /obj/item/seed) || istype(I, /obj/item/seedplanter/) )
		if(isturf(A))
			var/turf/T = A
			if(!T.Enter(user))
				return

		var/obj/item/seed/SEED

		// Use seed and seedplanter logic from plantpot adjusted for correct wording and logic
		if(istype(I, /obj/item/seed/))
			SEED = I
		else if(istype(I, /obj/item/seedplanter/))
			var/obj/item/seedplanter/SP = I
			if(!SP.selected)
				boutput(user, "<span class='alert'>You need to select something to plant first.</span>")
				return TRUE

			if(SP.selected.unique_seed)
				SEED = new SP.selected.unique_seed
			else
				SEED = new /obj/item/seed
			SEED.generic_seed_setup(SP.selected)

		src.P = new /obj/machinery/plantpot/bareplant(A, SEED)
		RegisterSignal(src.P, COMSIG_PARENT_PRE_DISPOSING, .proc/remove_plantpot)

		// Add to visual contents so it can be interacted with
		if(istype(A, /atom/movable))
			var/atom/movable/AM = A
			AM.vis_contents |= P
		P.auto_water = src.auto_water

		if(SEED.planttype)
			user.visible_message("<span class='notice'>[user] plants a seed in \the [A].</span>")
			user.u_equip(SEED)
			SEED.set_loc(P)
			if(SEED && istype(SEED.planttype,/datum/plant/maneater)) // Logging for man-eaters, since they can't be harvested (Convair880).
				logTheThing(LOG_STATION, user, "plants a [SEED.planttype] seed at [log_loc(P)].")
			if(!(user in P.contributors))
				P.contributors += user
		else
			boutput(user, "<span class='alert'>You plant the seed, but nothing happens.</span>")
			qdel(SEED)

		return TRUE


/datum/component/arable/proc/remove_plantpot()
	PRIVATE_PROC(TRUE)
	if(istype(parent, /atom/movable))
		var/atom/movable/AM = parent
		AM.vis_contents -= P

	UnregisterSignal(P, list(COMSIG_PARENT_PRE_DISPOSING))
	src.P = null

	if(!multi_plant)
		UnregisterFromParent()

/datum/component/arable/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATTACKBY)
	. = ..()
