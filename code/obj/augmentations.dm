ABSTRACT_TYPE(/obj/item/augmentation)
/obj/item/augmentation
	name = "surgical augmentation parent"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "augmentation"
	desc = "A thin, metal oval with some wires sticking out. It seems like it'd do well attached to the nervous system."
	///The person who has the aug inside one of their organs
	var/mob/living/carbon/human/donor
	///The organ that currently contains the aug
	var/obj/item/organ/donor_organ
	///The first person to have the organ
	var/mob/living/carbon/human/donor_original = null
	///The organ type used in the augmentation
	var/valid_organ = /obj/item/organ/brain
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
			donor?.contract_disease(failure_disease,null,null,1)
		health_update_queue |= donor
		return 1

	///Handling .broken and abilities when the aug breaks
	proc/breakme()
		if (!broken && islist(src.augmentation_abilities) && length(src.augmentation_abilities))// remove abilities when broken
			var/datum/abilityHolder/aholder
			if (src.donor && src.donor.abilityHolder)
				aholder = src.donor.abilityHolder
			else if (src.donor && src.donor.abilityHolder)
				aholder = src.donor.abilityHolder
			if (istype(aholder))
				for (var/abil in src.augmentation_abilities)
					src.remove_ability(aholder, abil)
		src.broken = TRUE

	///Handling fixing .broken and abilities when the aug breaks
	proc/unbreakme()
		if (broken && islist(src.augmentation_abilities) && length(src.augmentation_abilities)) //put them back if fixed (somehow)
			var/datum/abilityHolder/organ/A = donor?.get_ability_holder(/datum/abilityHolder/organ)
			if (!istype(A))
				A = donor?.add_ability_holder(/datum/abilityHolder/organ)
			if (!A)
				return
			for (var/abil in src.augmentation_abilities)
				src.add_ability(A, abil)
		src.broken = FALSE

	///Standard life loop proc
	proc/on_life(var/mult = 1)
		if (donor && (src.broken || (src.brute_dam + src.burn_dam + src.tox_dam) > max_aug_health))
			return 0
		return 1

	///For handling inserting the aug into the organ, not necessarily (but can be) handling the organ being inside someone too
	proc/on_insertion(var/obj/I as obj, var/mob/M as mob) // Mob accepts null
		if(!istype(I, /obj/item/organ))
			return

		var/obj/item/organ/O = I
		O.installed_aug = src
		donor_organ = O
		if(O.donor && !isnull(M)) //currently in someone on augment insertion
			on_organ_transplant(M)

	///For handling removing the aug from an organ.
	proc/on_cutout(var/obj/I as obj)
		var/obj/item/organ/O = I
		O.installed_aug = null
		donor_organ = null

		if (islist(src.augmentation_abilities) && length(src.augmentation_abilities))// && src.donor.abilityHolder)
			var/datum/abilityHolder/aholder
			if (src.donor && src.donor.abilityHolder)
				aholder = src.donor.abilityHolder
			else if (src.donor && src.donor.abilityHolder)
				aholder = src.donor.abilityHolder
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
			return 1
		return 0

	disposing()
		src.donor = null
		src.donor_organ = null
		src.donor_original = null
		..()

ABSTRACT_TYPE(/obj/item/augmentation/head)
/obj/item/augmentation/head //second abstract parent incase other augmentation types get added
	name = "surgical augmentation parent"
	icon_state = "augmentation"

/obj/item/augmentation/head/wireless_interact //you can interact with mechanical things at range at the cost of flash vulnerability
	name = "wireless interactor"
	icon_state = "augmentation_wire"
	desc = "An augmentation that allows for ranged interaction with various electronic devices."
	var/flashed = FALSE

	proc/ranged_click(atom/target, params, location, control)
		var/mob/M = src.donor
		var/inrange = in_interact_range(target, M)
		var/obj/item/equipped = M.equipped()
		if(src.flashed)
			return
		if (M.client.check_any_key(KEY_EXAMINE | KEY_POINT) || (equipped && (inrange || (equipped.flags & EXTRADELAY))) || ishelpermouse(target)) // slightly hacky, oh well, tries to check whether we want to click normally or use attack_ai
			return
		else
			if (get_dist(M, target) > 0)
				set_dir(get_dir(M, target))

			target.attack_ai(M, params, location, control)

	proc/flash_check(atom/A, obj/item/device/flash/I, mob/user)
		if(istype(I, /obj/item/device/flash) && I.status)
			src.flashed = TRUE
			src.take_damage(5, 5, 0) //owie
			src.donor.remove_stamina(25)
			SPAWN_DBG(15 SECONDS)
				src.flashed = FALSE
		if(src.broken)
			src.donor.remove_stamina(15)

	on_organ_transplant(var/mob/M as mob)
		..()
		if(!broken)
			RegisterSignal(src.donor, COMSIG_CLICK, .proc/ranged_click)
			RegisterSignal(src.donor, COMSIG_ATTACKBY, .proc/flash_check)
			M.mob_flags |= USR_DIALOG_UPDATES_RANGE

	on_organ_removal()
		..()
		var/mob/M = src.donor
		if(!broken)
			UnregisterSignal(src.donor, COMSIG_CLICK)
			M.mob_flags &= ~USR_DIALOG_UPDATES_RANGE
		UnregisterSignal(src.donor, COMSIG_ATTACKBY)

	on_broken(var/mult = 1)
		var/mob/M = src.donor
		if (!..())
			return
		src.donor.reagents.add_reagent("nanites", 0.5 * mult) //you want borg powers? Well, come and get 'em!
		UnregisterSignal(src.donor, COMSIG_CLICK)
		M.mob_flags &= ~USR_DIALOG_UPDATES_RANGE


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
/mob/living/carbon/human/proc/has_augmentation(var/target_zone = "All", var/obj/item/organ/specific_organ = null, var/obj/item/augmentation/specific_augment = null)
	var/list/aug_list = list()
	if(target_zone == "All" && ishuman(src))
		for(var/obj/item/organ/organ in src.organs)
			if(!isnull(organ) && organ.augmentation_support && organ.installed_aug)
				if(!isnull(specific_organ) && istype(organ, specific_organ) && !isnull(specific_augment) && organ.installed_aug && istype(specific_augment, organ.installed_aug))
					aug_list += organ

	else if(target_zone == "Chest" && ishuman(src))
		for(var/obj/item/organ/organ in src.organs)
			if(!isnull(organ) && organ.augmentation_support && organ.installed_aug)
				if(!istype(organ, /obj/item/organ/brain) && !istype(organ, /obj/item/organ/eye))
					if(!isnull(specific_organ) && istype(organ, specific_organ) && !isnull(specific_augment) && organ.installed_aug && istype(specific_augment, organ.installed_aug))
						aug_list += organ

	else if(target_zone == "Head" && ishuman(src))
		for(var/obj/item/organ/organ in src.organs)
			if(!isnull(organ) && organ.augmentation_support && organ.installed_aug)
				if(istype(organ, /obj/item/organ/brain) || istype(organ, /obj/item/organ/eye))
					if(!isnull(specific_organ) && istype(organ, specific_organ) && !isnull(specific_augment) && organ.installed_aug && istype(specific_augment, organ.installed_aug))
						aug_list += organ

	return aug_list
