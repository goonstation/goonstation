// Contents
// scan plant global proc
// handheld plant scanner & upgrade chip

// Yeah, another scan I made into a global proc (Convair880).
/proc/scan_plant(var/atom/A as turf|obj, var/mob/user as mob, var/visible = 0, var/show_gene_strain = TRUE)
	if (!A || !user || !ismob(user))
		return

	var/datum/plant/P = null
	var/datum/plantgenes/DNA = null

	if (istype(A, /obj/machinery/plantpot))
		var/obj/machinery/plantpot/PP = A
		if (!PP.current || PP.dead)
			return SPAN_ALERT("Cannot scan.")

		P = PP.current
		DNA = PP.plantgenes

	else if (istype(A, /obj/item/seed/))
		var/obj/item/seed/S = A
		if (S.isstrange || !S.planttype)
			return SPAN_ALERT("This seed has non-standard DNA and thus cannot be scanned.")

		P = S.planttype
		DNA = S.plantgenes

	else if (istype(A, /obj/item/reagent_containers/food/snacks/plant/))
		var/obj/item/reagent_containers/food/snacks/plant/F = A

		P = F.planttype
		DNA = F.plantgenes

	else if (istype(A, /mob/living/critter/plant))
		var/mob/living/critter/plant/F = A

		P = F.planttype
		DNA = F.plantgenes


	else if (istype(A, /obj/item/plant/tumbling_creeper))
		var/obj/item/plant/tumbling_creeper/handled_creeper = A

		P = handled_creeper.planttype
		DNA = handled_creeper.plantgenes

	else
		return

	if(visible)
		animate_scanning(A, "#70e800")

	if (!P || !istype(P, /datum/plant/) || !DNA || !istype(DNA, /datum/plantgenes/))
		return SPAN_ALERT("Cannot scan.")

	HYPgeneticanalysis(user, A, P, DNA, show_gene_strain) // Just use the existing proc.
	return


TYPEINFO(/obj/item/plantanalyzer)
	mats = 4

/obj/item/plantanalyzer
	name = "plant analyzer"
	desc = "A device which examines the genes of plant seeds."
	icon = 'icons/obj/hydroponics/items_hydroponics.dmi'
	icon_state = "plantanalyzer"
	w_class = W_CLASS_TINY
	c_flags = ONBELT

	afterattack(atom/A as mob|obj|turf|area, mob/user as mob)
		if (BOUNDS_DIST(A, user) > 0)
			return

		boutput(user, scan_plant(A, user, visible = 1)) // Replaced with global proc (Convair880).
		src.add_fingerprint(user)
		return

// This is the best place for this thing
/obj/item/device/analyzer/phytoscopic_upgrade
	name = "phytoscopic analyzer upgrade"
	desc = "A small upgrade card that allows phytoscopic goggles to detect gene strains present in a plant."
	icon_state = "phyto_upgr"
	flags = TABLEPASS | CONDUCT
	throwforce = 0
	w_class = W_CLASS_TINY
	throw_speed = 5
	throw_range = 10
