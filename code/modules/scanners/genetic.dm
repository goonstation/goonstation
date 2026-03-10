// Contents
// global genetic scan proc
// handheld genetic analyzer scanner
// genetic pre-scan datum
// DNA scan file format

/proc/scan_genetic(mob/M as mob, datum/genetic_prescan/prescan = null, visible = FALSE)
	if (!M)
		return "<b class='alert'>ERROR: NO SUBJECT DETECTED</b>"
	if (visible)
		animate_scanning(M, "#9eee80")
	if (!M.has_genetics())
		return "<b class='alert'>ERROR: UNABLE TO ANALYZE GENETIC STRUCTURE</b>"
	var/mob/living/carbon/human/H = M
	var/list/data = list()
	var/datum/bioHolder/BH = M.bioHolder
	data += "<b class='notice'>Genetic Stability: [BH.genetic_stability]</b>"
	var/datum/genetic_prescan/GP = prescan
	if (!GP)
		GP = new /datum/genetic_prescan
		GP.activeDna = list()
		GP.poolDna = list()
		for (var/bioEffectId in BH.effects)
			GP.activeDna += BH.GetEffect(bioEffectId)
		for (var/bioEffectId in BH.effectPool)
			GP.poolDna += BH.GetEffect(bioEffectId)
		GP.generate_known_unknown()
	data += "<b class='notice'>Potential Genetic Effects:</b>"
	for (var/datum/bioEffect/BE in GP.poolDnaKnown)
		data += BE.name
	if (length(GP.poolDnaUnknown))
		data += SPAN_ALERT("Unknown: [length(GP.poolDnaUnknown)]")
	else if (!length(GP.poolDnaKnown))
		data += "-- None --"
	data += "<b class='notice'>Active Genetic Effects:</b>"
	for (var/datum/bioEffect/BE in GP.activeDnaKnown)
		data += BE.name
	if (length(GP.activeDnaUnknown))
		data += SPAN_ALERT("Unknown: [length(GP.activeDnaUnknown)]")
	else if (!length(GP.activeDnaKnown))
		data += "-- None --"

	if(istype(H))
		if (length(H.cloner_defects.active_cloner_defects))
			data += "<b class='alert'>Detected Cloning-Related Defects:</b>"
			for(var/datum/cloner_defect/defect as anything in H.cloner_defects.active_cloner_defects)
				data += "<b class='alert'>[defect.name]</b>"
				data += "<i class='alert'>[defect.desc]</i>"
	return data.Join("<br>")

/obj/item/device/analyzer/genetic
	name = "genetic analyzer"
	desc = "A hand-held genetic scanner able to compare a person's DNA with a database of known genes."
	icon_state = "genetic_analyzer"
	inhand_image_icon = 'icons/mob/inhand/hand_medical.dmi'
	flags = TABLEPASS | CONDUCT
	c_flags = ONBELT
	throwforce = 3
	w_class = W_CLASS_TINY
	throw_speed = 5
	throw_range = 10
	hide_attack = ATTACK_PARTIALLY_HIDDEN

/obj/item/device/analyzer/genetic/attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
	var/datum/computer/file/genetics_scan/GS = create_new_dna_sample_file(target, visible_name=TRUE)
	if (!GS)
		return
	user.visible_message(
		SPAN_ALERT("<b>[user]</b> has analyzed [target]'s genetic makeup."),
		SPAN_ALERT("You have analyzed [target]'s genetic makeup.")
	)
	// build prescan as we have the parts we need from the genetics scan file above, avoids re-looping, and we know these will be read-only
	var/datum/genetic_prescan/GP = new
	GP.activeDna = GS.dna_active
	GP.poolDna = GS.dna_pool
	GP.generate_known_unknown()
	boutput(user, scan_genetic(target, prescan = GP, visible = 1))

	record_cloner_defects(target)


/datum/genetic_prescan
	var/list/activeDna = null
	var/list/poolDna = null

	var/list/activeDnaKnown = null
	var/list/activeDnaUnknown = null
	var/list/poolDnaKnown = null
	var/list/poolDnaUnknown = null

	proc/generate_known_unknown(ignoreRestrictions = FALSE)
		if (ignoreRestrictions)
			src.activeDnaKnown = src.activeDna
			src.poolDnaKnown = src.poolDna
			return
		src.activeDnaKnown = list()
		src.activeDnaUnknown = list()
		src.poolDnaKnown = list()
		src.poolDnaUnknown = list()
		for (var/datum/bioEffect/BE in src.activeDna)
			var/datum/bioEffect/GBE = BE.get_global_instance()
			if (!GBE.scanner_visibility)
				continue
			if (GBE.secret && !genResearch.see_secret)
				continue
			if (GBE.research_level < EFFECT_RESEARCH_DONE)
				src.activeDnaUnknown += BE
				continue
			src.activeDnaKnown += BE
		for (var/datum/bioEffect/BE in src.poolDna)
			var/datum/bioEffect/GBE = BE.get_global_instance()
			if (!GBE.scanner_visibility)
				continue
			if (GBE.secret && !genResearch.see_secret)
				continue
			if (GBE.research_level < EFFECT_RESEARCH_DONE)
				src.poolDnaUnknown += BE
				continue
			src.poolDnaKnown += BE


/datum/computer/file/genetics_scan
	name = "DNA Scan"
	extension = "GSCN"
	var/subject_name = null
	var/subject_uID = null
	var/subject_stability = null
	var/scanned_at = null
	var/list/datum/bioEffect/dna_pool = null
	var/list/datum/bioEffect/dna_active = null

	disposing()
		src.dna_pool = null
		src.dna_active = null
		..()
