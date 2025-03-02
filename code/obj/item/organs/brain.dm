/*=========================*/
/*----------Brain----------*/
/*=========================*/

/obj/item/organ/brain
	name = "brain"
	organ_name = "brain"
	desc = "A human brain, gross."
	organ_holder_name = "brain"
	organ_holder_location = "head"
	icon = 'icons/obj/items/organs/brain.dmi'
	icon_state = "brain2"
	item_state = "brain"
	var/datum/mind/owner = null
	edible = 0
	fail_damage = 120
	max_damage = 120
	default_material = "greymatter"
	tooltip_flags = REBUILD_ALWAYS //fuck it, nobody examines brains that often

	disposing()
		logTheThing(LOG_COMBAT, src, "[owner ? "(owner's ckey [owner.ckey]) " : ""]has been destroyed by [usr ? constructTarget(usr,"combat") : "???"] in [!isturf(src.loc) ? src.loc : ""] [log_loc(src)]. Brain last touched by [src.fingerprintslast].")

		if (owner && owner.brain == src)
			owner.brain = null
		else if (donor && donor.mind && donor.mind.brain == src)
			donor.mind.brain = null
		owner = null
		if (holder)
			holder.brain = null
		..()

	setMaterial(datum/material/mat1, appearance, setname, mutable, use_descriptors)
		. = ..()
		if(mat1.getID() == "greymatter")
			src.AddComponent(/datum/component/consume/food_effects, list("brain_food_ithillid"))

	Eat(mob/M, mob/user)
		if(isghostcritter(M) || isghostcritter(user))
			return FALSE
		if(M == user)
			if(tgui_alert(user, "Are you sure you want to eat [src]?", "Eat brain?", list("Yes", "No")) == "Yes")
				if (!(src in user.equipped_list())) //stop remotely eating people's brains please
					return TRUE
				logTheThing(LOG_COMBAT, user, "tries to eat [src] (owner's ckey [owner ? owner.ckey : null]).")
				return ..()
		else
			if(tgui_alert(user, "Are you sure you want to feed [src] to [M]?", "Feed brain?", list("Yes", "No")) == "Yes")
				if (!(src in user.equipped_list()))
					return TRUE
				logTheThing(LOG_COMBAT, user, "tries to feed [src] (owner's ckey [owner ? owner.ckey : null]) to [constructName(M)].")
				return ..()
		return FALSE

	get_desc()
		if (usr && (usr.traitHolder?.hasTrait("training_medical") || GET_ATOM_PROPERTY(usr,PROP_MOB_EXAMINE_HEALTH)))
			if (src.owner?.key)
				if (!find_ghost_by_key(src.owner?.key))
					. += "<br>[SPAN_NOTICE("This brain is slimy.")]"
				else
					. += "<br>[SPAN_NOTICE("This brain is still warm.")]"
			else
				. += "<br>[SPAN_ALERT("This brain has gone cold.")]"

	attach_organ(var/mob/living/carbon/M as mob, var/mob/user as mob)
		/* Overrides parent function to handle special case for brains. */
		var/mob/living/carbon/human/H = M
		if (!src.can_attach_organ(H, user))
			return 0

		var/obj/item/organ/organ_location = H.organHolder.get_organ("head")

		if (!organ_location)
			boutput(user, SPAN_NOTICE("Where are you putting that again? There's no head."))
			return null

		if (!headSurgeryCheck(H))
			boutput(user, SPAN_NOTICE("You're going to need to remove that mask/helmet/glasses first."))
			return null

		var/head_stage = H.surgeryHolder.get_surgery_progress("brain_surgery")
		if (!H.organHolder.get_organ("brain") && head_stage >= 4.0)
			if (!H.organHolder.get_organ("skull"))
				boutput(user, SPAN_NOTICE("There's no skull in there to hold the brain in place."))
				return null

			var/fluff = pick("insert", "shove", "place", "drop", "smoosh", "squish")

			user.tri_message(H, SPAN_ALERT("<b>[user]</b> [fluff][fluff == "smoosh" || fluff == "squish" ? "es" : "s"] [src] into [H == user ? "[his_or_her(H)]" : "[H]'s"] head!"),\
				SPAN_ALERT("You [fluff] [src] into [user == H ? "your" : "[H]'s"] head!"),\
				SPAN_ALERT("[H == user ? "You" : "<b>[user]</b>"] [fluff][fluff == "smoosh" || fluff == "squish" ? "es" : "s"] [src] into your head!"))

			if (user.find_in_hand(src))
				user.u_equip(src)
			H.organHolder.receive_organ(src, "brain", 3.0)
			return 1

		return 0

	proc/setOwner(var/datum/mind/mind)
		if (!mind)
			return
		if(inafterlifebar(mind.current)) // No changing owners af this is happening in the afterlife
			return
		if (mind.brain && mind.brain != src)
			var/obj/item/organ/brain/brain = mind.brain
			brain.owner = null
		mind.brain = src
		owner = mind

/obj/item/organ/brain/synth
	name = "synthbrain"
	item_state = "plant"
	desc = "An artificial mass of grey matter. Not actually, as one might assume, very good at thinking."
	New()
		..()
		src.icon_state = pick("plant_brain", "plant_brain_bloom")

/obj/item/organ/brain/latejoin
	name = "Spontaneous Intelligence Creation Core"
	icon_state = "late_brain"
	item_state = "late_brain"
	desc = "A brain sized pyramid constructed out of silicon and LED lights. It employs complex quantum loopholes to create a consciousness within a decade or less."
	created_decal = /obj/decal/cleanable/oil
	default_material = "pharosium"
	var/activated = 0

	get_desc()
		if (usr?.traitHolder?.hasTrait("training_medical"))
			if (activated)
				if (src.owner?.key)
					if (!find_ghost_by_key(src.owner?.key))
						. += "<br>[SPAN_NOTICE("[src]'s indicators show that it once had a conciousness installed, but that conciousness cannot be located.")]"
					else
						. += "<br>[SPAN_NOTICE("[src]'s indicators show that it is still operational, and can be installed into a new body immediately.")]"
				else
					. += "<br>[SPAN_ALERT("[src] has powered down fully.")]"
			else
				. += "<br>[SPAN_ALERT("[src] has its factory defaults enabled. No conciousness has entered it yet.")]"

/obj/item/organ/brain/ai
	name = "neural net processor"
	desc = "A heavily augmented human brain, upgraded to deal with the large amount of information an AI unit must process."
	icon_state = "ai_brain"
	item_state = "ai_brain"
	created_decal = /obj/decal/cleanable/oil
	default_material = "pharosium"

/obj/item/organ/brain/martian
	name = "squishy lump"
	desc = "A martian brain. At least, it seems like a brain. It could be a heart for all you know."
	icon_state = "martian_brain"
	item_state = "martian_brain"
	created_decal = /obj/decal/cleanable/martian_viscera/fluid
	default_material = "viscerite"

/obj/item/organ/brain/flockdrone
	name = "odd crystal"
	desc = "Flickers of energy still trace around inside it. It feels oddly warm to the touch."
	icon_state = "flockdrone_brain"
	item_state = "flockdrone_brain"
	created_decal = /obj/decal/cleanable/flockdrone_debris/fluid
	default_material = "gnesis"

	on_life()
		var/mob/living/M = holder.donor
		if(!M || !ishuman(M)) // flockdrones shouldn't have these problems
			return
		if(M.client && (isnull(M.client.color) || M.client.color == "#FFFFFF"))
			M.client.animate_color(COLOR_MATRIX_FLOCKMANGLED, time=900, easing=SINE_EASING) // ~ 1.5 minutes to complete
		if(prob(3))
			var/list/sounds = list('sound/machines/ArtifactFea1.ogg', 'sound/machines/ArtifactFea2.ogg', 'sound/machines/ArtifactFea3.ogg',
				'sound/misc/flockmind/flockmind_cast.ogg', 'sound/misc/flockmind/flockmind_caw.ogg',
				'sound/misc/flockmind/flockdrone_beep1.ogg', 'sound/misc/flockmind/flockdrone_beep2.ogg', 'sound/misc/flockmind/flockdrone_beep3.ogg', 'sound/misc/flockmind/flockdrone_beep4.ogg',
				'sound/misc/flockmind/flockdrone_grump1.ogg', 'sound/misc/flockmind/flockdrone_grump2.ogg', 'sound/misc/flockmind/flockdrone_grump3.ogg',
				'sound/effects/radio_sweep1.ogg', 'sound/effects/radio_sweep2.ogg', 'sound/effects/radio_sweep3.ogg', 'sound/effects/radio_sweep4.ogg', 'sound/effects/radio_sweep5.ogg')
			M.playsound_local(get_turf(M), pick(sounds), 20, 1)
			boutput(M, "<span class='flocksay italics'><i>... [pick_string("flockmind.txt", "brain")] ...</i></span>")

/obj/item/organ/brain/flockdrone/special_desc(dist, mob/user)
	if (!isflockmob(user))
		return
	return {"[SPAN_FLOCKSAY("[SPAN_BOLD("###=- Ident confirmed, data packet received.")]<br>\
		[SPAN_BOLD("ID:")] Computational core<br>\
		[SPAN_BOLD("###=-")]")]"}
