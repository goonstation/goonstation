/datum/antagonist/omnitraitor
	id = ROLE_OMNITRAITOR
	display_name = "omnitraitor"

	is_compatible_with(datum/mind/mind)
		return isliving(mind.current)

	give_equipment()
		src.owner.add_antagonist(ROLE_WIZARD, do_relocate = FALSE, respect_mutual_exclusives = FALSE, do_pseudo = TRUE)
		src.owner.add_antagonist(ROLE_CHANGELING, respect_mutual_exclusives = FALSE, do_pseudo = TRUE)
		src.owner.add_antagonist(ROLE_VAMPIRE, respect_mutual_exclusives = FALSE, do_pseudo = TRUE)
		src.owner.add_antagonist(ROLE_WEREWOLF, respect_mutual_exclusives = FALSE, do_pseudo = TRUE)
		src.owner.add_antagonist(ROLE_WRESTLER, respect_mutual_exclusives = FALSE, do_pseudo = TRUE)
		src.owner.add_antagonist(ROLE_GRINCH, respect_mutual_exclusives = FALSE, do_pseudo = TRUE)
		src.owner.add_antagonist(ROLE_TRAITOR, respect_mutual_exclusives = FALSE, do_pseudo = TRUE)

		src.owner.current.assign_gimmick_skull()

	remove_equipment()
		src.owner.remove_antagonist(ROLE_WIZARD)
		src.owner.remove_antagonist(ROLE_CHANGELING)
		src.owner.remove_antagonist(ROLE_VAMPIRE)
		src.owner.remove_antagonist(ROLE_WEREWOLF)
		src.owner.remove_antagonist(ROLE_WRESTLER)
		src.owner.remove_antagonist(ROLE_GRINCH)
		src.owner.remove_antagonist(ROLE_TRAITOR)

		SPAWN(2.5 SECONDS)
			src.owner.current.assign_gimmick_skull()
