/// A storage which can't be closed or repaired after opening and can only be opened with a prying tool
/obj/storage/crate/pryable
	needs_prying = TRUE
	can_flip_bust = FALSE

	HELP_MESSAGE_OVERRIDE({"To open this crate you need to <b>pry</b> it open."})

/obj/storage/crate/pryable/animal
	name = "animal transport crate"
	desc = "A wooden crate made for transporting animals."
	icon_state = "animalcrate"
	icon_closed = "animalcrate"
	icon_opened = "animalcrate_open"
