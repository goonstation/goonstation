// Contents
// global scan gravity proc
// handheld gravity scanner

#define GRAVITY_SCAN_OUTPUT(x, y) ("\The [x] is currently experiencing [y/GFORCE_EARTH_GRAVITY]G.")

/proc/scan_gravity(atom/target, visible=FALSE)
	if (istype(target, /obj/ability_button))
		return
	var/gforce = null
	if (!target)
		return

	if(visible)
		animate_scanning(target, "#b66393")

	if (istype(target, /turf))
		var/turf/T = target
		gforce = T.get_gforce_current()
	else if (istype(target, /atom/movable))
		var/atom/movable/AM = target
		gforce = AM.gforce
	switch (gforce)
		if (null)
			. = SPAN_ALERT("Unable to process gravity of target.")
		if (-INFINITY to GFORCE_GRAVITY_MINIMUM)
			. = SPAN_ALERT(GRAVITY_SCAN_OUTPUT(target, gforce))
		if (GFORCE_MOB_REGULAR_THRESHOLD to GFORCE_EARTH_GRAVITY)
			. = SPAN_SUCCESS(GRAVITY_SCAN_OUTPUT(target, gforce))
		if (GFORCE_GRAVITY_MINIMUM to GFORCE_MOB_REGULAR_THRESHOLD)
			. = SPAN_NOTICE(GRAVITY_SCAN_OUTPUT(target, gforce))
		if (GFORCE_MOB_EXTREME_THRESHOLD to INFINITY)
			. = SPAN_ALERT(GRAVITY_SCAN_OUTPUT(target, gforce))
		if (GFORCE_MOB_HIGH_THRESHOLD to GFORCE_MOB_EXTREME_THRESHOLD)
			. = SPAN_NOTICE(GRAVITY_SCAN_OUTPUT(target, gforce))
		if (GFORCE_EARTH_GRAVITY to GFORCE_MOB_HIGH_THRESHOLD)
			. = SPAN_MESSAGE(GRAVITY_SCAN_OUTPUT(target, gforce))

#undef GRAVITY_SCAN_OUTPUT


TYPEINFO(/obj/item/device/analyzer/gravity_scanner)
	mats = list("crystal" = 1,
				"conductive" = 1,
				"metal" = 2)
/obj/item/device/analyzer/gravity_scanner
	name = "\improper G-force scanner"
	desc = "A device that scans nearby things to find how much G-force they're being subjected to."
	icon_state = "gforce"
	item_state = "pda"
	flags = TABLEPASS | SUPPRESSATTACK

	HELP_MESSAGE_OVERRIDE("Scan by holding in hand and <b>clicking</b>.")

	attack_self(mob/user)
		. = ..()
		flick("gforce-scan", src)
		boutput(user, scan_gravity(src.loc, TRUE))

	afterattack(atom/target, mob/user, reach, params)
		. = ..()
		if (BOUNDS_DIST(target, user) > 0)
			return
		flick("gforce-scan", src)
		boutput(user, scan_gravity(target, TRUE))
