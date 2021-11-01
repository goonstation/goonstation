ABSTRACT_TYPE(/obj/item/augmentation)
/obj/item/augmentation
	name = "surgical augmentation parent"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "augmentation"
	desc = "A thin, metal oval with some wires sticking out. It seems like it'd do well attached to the nervous system."
	///The person who has the aug inside one of their organs
	var/mob/living/carbon/human/owner
	///The organ that currently contains the aug
	var/obj/item/organ/owner_organ
	var/brute_dam = 0
	var/burn_dam = 0
	var/tox_dam = 0
	var/max_aug_health = 120
	var/broken = FALSE
	var/failure_disease = null
	///Does it have any special abilities (a la wizard spell-type abilities)?
	var/list/augmentation_abilities = null

	///Standard proc for taking damage, overriden
	take_damage(brute, burn, tox, damage_type)
		src.brute_dam += brute
		src.burn_dam += burn
		src.tox_dam += tox

		if (brute_dam + burn_dam + tox_dam >= max_aug_health)
			src.breakme()
			owner?.contract_disease(failure_disease,null,null,1)
		health_update_queue |= owner
		return TRUE

	///Handling .broken and abilities when the aug breaks
	proc/breakme()
		if (!broken && islist(src.augmentation_abilities) && length(src.augmentation_abilities))// remove abilities when broken
			var/datum/abilityHolder/aholder
			if (src.owner && src.owner.abilityHolder)
				aholder = src.owner.abilityHolder
			else if (src.owner && src.owner.abilityHolder)
				aholder = src.owner.abilityHolder
			if (istype(aholder))
				for (var/abil in src.augmentation_abilities)
					src.remove_ability(aholder, abil)
		src.broken = TRUE

	///Handling fixing .broken and abilities when the aug breaks
	proc/unbreakme()
		if (broken && islist(src.augmentation_abilities) && length(src.augmentation_abilities)) //put them back if fixed (somehow)
			var/datum/abilityHolder/organ/A = owner?.get_ability_holder(/datum/abilityHolder/organ)
			if (!istype(A))
				A = owner?.add_ability_holder(/datum/abilityHolder/organ)
			if (!A)
				return
			for (var/abil in src.augmentation_abilities)
				src.add_ability(A, abil)
		src.broken = FALSE

	///Standard life loop proc
	proc/on_life(var/mult = 1)
		if (owner && (src.broken || (src.brute_dam + src.burn_dam + src.tox_dam) > max_aug_health))
			return FALSE
		return TRUE

	///Want it to only accept one kind of organ / only do cyberorgans / only fully healed organs? Put it here (in the child)
	proc/organ_is_valid(var/obj/item/organ/chosen_organ)
		return FALSE

	///For handling inserting the aug into the organ, not necessarily (but can be) handling the organ being inside someone too
	proc/on_insertion(var/obj/I as obj, var/mob/M as mob) // Mob accepts null
		if(!istype(I, /obj/item/organ))
			return

		var/obj/item/organ/O = I
		O.installed_aug = src
		owner_organ = O
		if(O.donor && !isnull(M)) //currently in someone on augment insertion
			on_organ_transplant(M)

	///For handling removing the aug from an organ.
	proc/on_cutout(var/obj/I as obj)
		var/obj/item/organ/O = I
		O.installed_aug = null
		owner_organ = null

		if (islist(src.augmentation_abilities) && length(src.augmentation_abilities))
			var/datum/abilityHolder/aholder
			if (src.owner && src.owner.abilityHolder)
				aholder = src.owner.abilityHolder
			else if (src.owner && src.owner.abilityHolder)
				aholder = src.owner.abilityHolder
			if (istype(aholder))
				for (var/abil in src.augmentation_abilities)
					src.remove_ability(aholder, abil)

	///Handling the parent organ's transplant (into a person) effects
	proc/on_organ_transplant(var/mob/M as mob)
		return

	///Handling the parent organ's removal (from a person) effects
	proc/on_organ_removal()
		return

	proc/add_ability(var/datum/abilityHolder/aholder, var/abil)
		if (!aholder || !abil)
			return
		var/datum/targetable/organAbility/OA = aholder.addAbility(abil)
		if (istype(OA))
			OA.linked_organ = src

	proc/remove_ability(var/datum/abilityHolder/aholder, var/abil)
		if (!aholder || !abil)
			return
		aholder.removeAbility(abil)

	///What should happen every life cycle while an aug is broken
	proc/on_broken(var/mult = 1)
		if (broken)
			return TRUE
		return FALSE

	disposing()
		src.owner = null
		src.owner_organ = null
		..()

ABSTRACT_TYPE(/obj/item/augmentation/head)
/obj/item/augmentation/head //second abstract parent incase other augmentation types get added
	name = "surgical augmentation parent"
	icon_state = "augmentation"

/obj/item/augmentation/head/wireless_interact //you can interact with mechanical things at range at the cost of flash vulnerability
	name = "wireless interactor"
	icon_state = "augmentation_wire"
	desc = "An augmentation that allows for ranged interaction with various electronic devices."

	proc/ranged_click(mob/user, atom/target, location, control)
		var/mob/M = src.owner
		if(src.hasStatus("flashed"))
			return
		if(get_dist(user, target) <= 1)
			return
		if (M.client.check_any_key(KEY_EXAMINE | KEY_POINT) || ishelpermouse(target) || M.equipped()) // slightly hacky, oh well, tries to check whether we want to click normally or use attack_ai
			return
		else
			if (get_dist(M, target) > 0)
				set_dir(get_dir(M, target))
			if(istype(target, /obj/machinery))
				var/turf/target_turf = get_turf(target)
				var/obj/overlay/energy = new/obj/overlay(target_turf)
				energy.icon = 'icons/effects/effects.dmi'
				energy.icon_state = "energytwirlin_fast"
				energy.name = "electronic energy pulse"
				energy.anchored = 1
				SPAWN_DBG(57 CENTI SECONDS)
					if (energy)
						qdel(energy)
			target.attack_ai(M)

	proc/flash_check()
		src.setStatus("flashed", duration = 15 SECONDS)
		src.take_damage(5, 5, 0) //owie
		src.owner.remove_stamina(25)
		if(src.broken)
			src.owner.remove_stamina(15)

	on_organ_transplant(var/mob/M as mob)
		..()
		if(!broken)
			RegisterSignal(src.owner, COMSIG_LIVING_CLICK, .proc/ranged_click)
			M.mob_flags |= USR_DIALOG_UPDATES_RANGE
		RegisterSignal(src.owner, COMSIG_MOB_FLASHED, .proc/flash_check)

	on_organ_removal()
		..()
		var/mob/M = src.owner
		if(!broken)
			UnregisterSignal(src.owner, COMSIG_LIVING_CLICK)
			M.mob_flags &= ~USR_DIALOG_UPDATES_RANGE
		UnregisterSignal(src.owner, COMSIG_MOB_FLASHED)

	on_broken(var/mult = 1)
		if (!..())
			return
		src.owner.reagents.add_reagent("nanites", 0.5 * mult) //you want borg powers? Well, come and get 'em!

	breakme()
		..()
		var/mob/M = src.owner
		if(M.mob_flags & USR_DIALOG_UPDATES_RANGE)
			UnregisterSignal(src.owner, COMSIG_LIVING_CLICK)
			M.mob_flags &= ~USR_DIALOG_UPDATES_RANGE

	organ_is_valid(var/obj/item/organ/chosen_organ)
		if(istype(chosen_organ, /obj/item/organ/brain) && !chosen_organ.robotic && !chosen_organ.synthetic)
			return TRUE
		else
			return FALSE


/datum/abilityHolder/augmentation //unused currently but laying the path for future augmentations
	usesPoints = 0
	regenRate = 0
	tabName = "Body"

/atom/movable/screen/ability/topBar/augmentation
	clicked(params)
		var/datum/targetable/augAbility/spell = owner
		if (!istype(spell))
			return
		if (!spell.holder)
			return
		if (!isturf(usr.loc))
			return
		if (spell.targeted && usr.targeting_ability == owner)
			usr:targeting_ability = null
			usr.update_cursor()
			return
		if (spell.targeted)
			if (world.time < spell.last_cast)
				return
			usr.targeting_ability = owner
			usr.update_cursor()
		else
			SPAWN_DBG(0)
				spell.handleCast()

/datum/targetable/augAbility
	icon = 'icons/mob/organ_abilities.dmi'
	icon_state = "template"
	cooldown = 0
	last_cast = 0
	preferred_holder_type = /datum/abilityHolder/augmentation
	var/disabled = 0
	var/toggled = 0
	var/is_on = 0   // used if a toggle ability
	var/obj/item/augmentation/linked_augmentation = null

	New()
		var/atom/movable/screen/ability/topBar/augmentation/B = new /atom/movable/screen/ability/topBar/augmentation(null)
		B.name = src.name
		B.desc = src.desc
		B.icon = src.icon
		B.icon_state = src.icon_state
		B.owner = src
		src.object = B

	updateObject()
		..()
		if (!src.object)
			src.object = new /atom/movable/screen/ability/topBar/augmentation()
			object.icon = src.icon
			object.owner = src
		if (disabled)
			object.name = "[src.name] (unavailable)"
			object.icon_state = src.icon_state + "_cd"
		else if (src.last_cast > world.time)
			object.name = "[src.name] ([round((src.last_cast-world.time)/10)])"
			object.icon_state = src.icon_state + "_cd"
		else if (toggled)
			if (is_on)
				object.name = "[src.name] (on)"
				object.icon_state = src.icon_state
			else
				object.name = "[src.name] (off)"
				object.icon_state = src.icon_state + "_cd"
		else
			object.name = src.name
			object.icon_state = src.icon_state

	proc/incapacitationCheck()
		var/mob/living/M = holder.owner
		return M.restrained() || is_incapacitated(M)

	castcheck()
		if (!linked_augmentation || (!islist(src.linked_augmentation) && linked_augmentation.loc != holder.owner))
			boutput(holder.owner, "<span class='alert'>You can't use that ability right now.</span>")
			return 0
		else if (incapacitationCheck())
			boutput(holder.owner, "<span class='alert'>You can't use that ability while you're incapacitated.</span>")
			return 0
		else if (disabled)
			boutput(holder.owner, "<span class='alert'>You can't use that ability right now.</span>")
			return 0
		return 1

	cast(atom/target)
		if (!holder || !holder.owner)
			return 1
		if (!linked_augmentation)
			return 1
		actions.interrupt(holder.owner, INTERRUPT_ACT)
		if (ismob(target))
			logTheThing("combat", holder.owner, target, "used ability [src.name] ([src.linked_augmentation]) on [constructTarget(target,"combat")].")
		else if (target)
			logTheThing("combat", holder.owner, null, "used ability [src.name] ([src.linked_augmentation]) on [target].")
		else
			logTheThing("combat", holder.owner, null, "used ability [src.name] ([src.linked_augmentation]).")
		return 0

/**
For seeing if a person has an Augmentation.
Set `target_zone` to either "Chest" or "Head" to only scan a certain zone. Defaults to "All"
Set `specific_organ` to the type of the organ that you want in the list. Defaults to all organs.
Set `specific_augment` to the type of augment you're looking for, and it will only return that. Defaults to all augments.
*/
/mob/living/carbon/human/proc/has_augmentation(var/target_zone = "All", var/obj/item/organ/specific_organ = null)
	var/list/aug_list = list()
	var/list/organs = list()
	if(target_zone == "All" && ishuman(src))
		organs = list("liver", "left_kidney", "right_kidney", "stomach", "intestines","spleen", "left_lung", "right_lung","appendix", "pancreas", "heart", "brain", "left_eye", "right_eye", "tail")
		if(specific_organ)
			for (var/organ in organs)
				if((organ == specific_organ) && islist(src?.organHolder?.organ_list))
					var/obj/item/organ/O = src.organHolder.organ_list[organ]
					if(O?.augmentation_support && O.installed_aug)
						aug_list += O.installed_aug
		else
			for (var/organ in organs)
				if(islist(src?.organHolder?.organ_list))
					var/obj/item/organ/O = src.organHolder.organ_list[organ]
					if(O?.augmentation_support && O.installed_aug)
						aug_list += O.installed_aug

	else if(target_zone == "Chest" && ishuman(src))
		organs = list("liver", "left_kidney", "right_kidney", "stomach", "intestines","spleen", "left_lung", "right_lung","appendix", "pancreas", "heart", "tail")
		if(specific_organ)
			for (var/organ in organs)
				if((organ == specific_organ) && islist(src?.organHolder?.organ_list))
					var/obj/item/organ/O = src.organHolder.organ_list[organ]
					if(O?.augmentation_support && O.installed_aug)
						aug_list += O.installed_aug
		else
			for (var/organ in organs)
				if(islist(src?.organHolder?.organ_list))
					var/obj/item/organ/O = src.organHolder.organ_list[organ]
					if(O?.augmentation_support && O.installed_aug)
						aug_list += O.installed_aug

	else if(target_zone == "Head" && ishuman(src))
		organs = list("left_eye", "right_eye", "brain")
		if(specific_organ)
			for (var/organ in organs)
				if((organ == specific_organ) && islist(src?.organHolder?.organ_list))
					var/obj/item/organ/O = src.organHolder.organ_list[organ]
					if(O?.augmentation_support && O.installed_aug)
						aug_list += O.installed_aug
		else
			for (var/organ in organs)
				if(islist(src?.organHolder?.organ_list))
					var/obj/item/organ/O = src.organHolder.organ_list[organ]
					if(O?.augmentation_support && O.installed_aug)
						aug_list += O.installed_aug


	if(!length(aug_list))
		return FALSE
	else
		return aug_list
