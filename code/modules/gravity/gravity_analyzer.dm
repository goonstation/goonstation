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
