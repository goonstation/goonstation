/obj/item/disk/data/cartridge/catalogue //don't spawn the generic version!
	name = "\improper Generic Brand mail-order cartridge"
	desc = "An electronic mail-order cartridge for PDAs with built-in payment handling."

	nt
		name = "\improper Nanotrasen mail-order cartridge"
		icon_state = "cart-fancy"
		New()
			..()
			src.root.add_file( new /datum/computer/file/pda_program/catalogue/nt(src))
			src.file_amount = src.file_used
			src.read_only = 1

	takeout
		name = "\improper Golden Gannets mail-order cartridge"
		icon_state = "cart-qm"
		New()
			..()
			src.root.add_file( new /datum/computer/file/pda_program/catalogue/takeout(src))
			src.file_amount = src.file_used
			src.read_only = 1

	medical
		name = "\improper Survival Mart mail-order cartridge"
		icon_state = "cart-med"
		New()
			..()
			src.root.add_file( new /datum/computer/file/pda_program/catalogue/medical(src))
			src.file_amount = src.file_used
			src.read_only = 1

	chem
		name = "\improper Chems-R-Us mail-order cartridge"
		icon_state = "cart-med"
		New()
			..()
			src.root.add_file( new /datum/computer/file/pda_program/catalogue/chem(src))
			src.file_amount = src.file_used
			src.read_only = 1
