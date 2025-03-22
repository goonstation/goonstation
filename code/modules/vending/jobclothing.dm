
ABSTRACT_TYPE(/obj/machinery/vending/jobclothing)

/obj/machinery/vending/jobclothing/security
	name = "Security Apparel"
	desc = "A vending machine that vends Security clothing."
	icon_state = "secclothing"
	icon_panel = "snack-panel"
	pay = 1
	acceptcard = 1
	req_access = list(access_security)

	create_products(restocked)
		..()
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/color/red, 5)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/rank/security, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/rank/security/assistant, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/misc/lawyer/red, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/misc/lawyer/black, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/jersey/red, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/misc/dirty_vest, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/misc/tourist, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/misc/tourist/max_payne, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/gimmick/police, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/misc/serpico, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/wintercoat/security, 4)
		product_list += new/datum/data/vending_product(/obj/item/clothing/gloves/fingerless, 5)
		product_list += new/datum/data/vending_product(/obj/item/clothing/gloves/black, 5)
		product_list += new/datum/data/vending_product(/obj/item/clothing/shoes/swat, 4)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/serpico, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/red, 5)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/flatcap, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/helmet/bobby, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/helmet/siren, 2)
		product_list += new/datum/data/vending_product(/obj/item/device/radio/headset/security, 2, cost=PAY_TRADESMAN/1.5)
		product_list += new/datum/data/vending_product(/obj/item/device/pda2/security, 2, cost=PAY_TRADESMAN/1.5)
		product_list += new/datum/data/vending_product(/obj/item/device/pda2/forensic, 2, cost=PAY_TRADESMAN/1.5)
		product_list += new/datum/data/vending_product(/obj/item/cloth/towel/security, 4, cost=PAY_TRADESMAN/2)
		product_list += new/datum/data/vending_product(/obj/item/storage/backpack/security, 1)
		product_list += new/datum/data/vending_product(/obj/item/storage/backpack/satchel/security, 1)

		product_list += new/datum/data/vending_product(/obj/item/clothing/under/rank/security/april_fools, 1, hidden=1)

#ifdef SEASON_WINTER
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/puffer/sec, 2)
#endif

/obj/machinery/vending/jobclothing/afterlife/security
	name = "Security Apparel"
	desc = "A vending machine that vends Security clothing."
	icon_state = "secclothing"
	icon_panel = "snack-panel"
	pay = 1
	acceptcard = 1
	req_access = null

	create_products(restocked)
		..()
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/color/red, 5)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/rank/security, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/rank/security/assistant, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/misc/lawyer/red, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/misc/lawyer/black, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/jersey/red, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/misc/dirty_vest, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/misc/tourist, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/misc/tourist/max_payne, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/gimmick/police, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/misc/serpico, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/wintercoat/security, 4)
		product_list += new/datum/data/vending_product(/obj/item/clothing/gloves/fingerless, 5)
		product_list += new/datum/data/vending_product(/obj/item/clothing/gloves/black, 5)
		product_list += new/datum/data/vending_product(/obj/item/clothing/shoes/swat, 4)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/serpico, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/red, 5)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/flatcap, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/helmet/bobby, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/helmet/siren, 2)
		product_list += new/datum/data/vending_product(/obj/item/storage/backpack/security, 1)
		product_list += new/datum/data/vending_product(/obj/item/storage/backpack/satchel/security, 1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/rank/security/april_fools, 1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/puffer/sec, 2)

/obj/machinery/vending/jobclothing/medical
	name = "Medical Apparel"
	desc = "A vending machine that vends Medical clothing."
	icon_state = "medclothing"
	icon_panel = "snack-panel"
	pay = 1
	acceptcard = 1
	req_access = list(access_medical)

	create_products(restocked)
		..()
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/color/white, 5)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/rank/medical, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/rank/roboticist, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/rank/geneticist, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/wintercoat/medical, 3)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/wintercoat/robotics, 3)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/wintercoat/genetics, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/labcoat, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/labcoat/medical, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/labcoat/robotics, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/nursedress, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/mask/surgical, 10)
		product_list += new/datum/data/vending_product(/obj/item/clothing/mask/surgical_shield, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/gloves/latex, 5)
		product_list += new/datum/data/vending_product(/obj/item/clothing/shoes/red, 4)
		product_list += new/datum/data/vending_product(/obj/item/clothing/shoes/white, 4)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/white, 5)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/blue, 5)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/headmirror, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/traditionalnursehat, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/nursehat, 2)
		product_list += new/datum/data/vending_product(/obj/item/device/radio/headset/medical, 2, cost=PAY_DOCTORATE/2)
		product_list += new/datum/data/vending_product(/obj/item/device/pda2/medical, 2, cost=PAY_DOCTORATE/2)
		product_list += new/datum/data/vending_product(/obj/item/device/pda2/medical/robotics, 2, cost=PAY_DOCTORATE/2)
		product_list += new/datum/data/vending_product(/obj/item/device/pda2/genetics, 2, cost=PAY_DOCTORATE/2)
		product_list += new/datum/data/vending_product(/obj/item/storage/backpack/medic, 1)
		product_list += new/datum/data/vending_product(/obj/item/storage/backpack/satchel/medic, 1)
		product_list += new/datum/data/vending_product(/obj/item/storage/backpack/robotics, 1)
		product_list += new/datum/data/vending_product(/obj/item/storage/backpack/satchel/robotics, 1)
		product_list += new/datum/data/vending_product(/obj/item/storage/backpack/genetics, 1)
		product_list += new/datum/data/vending_product(/obj/item/storage/backpack/satchel/genetics, 1)

		product_list += new/datum/data/vending_product(/obj/item/clothing/under/rank/medical/april_fools, 2, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/labcoat/medical/april_fools, 2, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/rank/roboticist/april_fools, 1, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/labcoat/robotics/april_fools, 1, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/rank/geneticist/april_fools, 1, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/labcoat/genetics/april_fools, 1, hidden=1)

#ifdef SEASON_WINTER
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/puffer/med, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/puffer/genetics, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/puffer/nurse, 2)
#endif

/obj/machinery/vending/jobclothing/afterlife/medical
	name = "Medical Apparel"
	desc = "A vending machine that vends Medical clothing."
	icon_state = "medclothing"
	icon_panel = "snack-panel"
	pay = 1
	acceptcard = 1
	req_access = null

	create_products(restocked)
		..()
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/color/white, 5)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/rank/medical, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/rank/roboticist, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/rank/geneticist, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/wintercoat/medical, 3)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/wintercoat/robotics, 3)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/wintercoat/genetics, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/labcoat, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/labcoat/medical, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/labcoat/robotics, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/nursedress, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/mask/surgical, 10)
		product_list += new/datum/data/vending_product(/obj/item/clothing/mask/surgical_shield, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/gloves/latex, 5)
		product_list += new/datum/data/vending_product(/obj/item/clothing/shoes/red, 4)
		product_list += new/datum/data/vending_product(/obj/item/clothing/shoes/white, 4)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/white, 5)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/blue, 5)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/headmirror, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/traditionalnursehat, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/nursehat, 2)
		product_list += new/datum/data/vending_product(/obj/item/storage/backpack/medic, 1)
		product_list += new/datum/data/vending_product(/obj/item/storage/backpack/satchel/medic, 1)
		product_list += new/datum/data/vending_product(/obj/item/storage/backpack/robotics, 1)
		product_list += new/datum/data/vending_product(/obj/item/storage/backpack/satchel/robotics, 1)
		product_list += new/datum/data/vending_product(/obj/item/storage/backpack/genetics, 1)
		product_list += new/datum/data/vending_product(/obj/item/storage/backpack/satchel/genetics, 1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/rank/medical/april_fools, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/labcoat/medical/april_fools, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/rank/roboticist/april_fools, 1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/labcoat/robotics/april_fools, 1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/rank/geneticist/april_fools, 1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/labcoat/genetics/april_fools, 1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/puffer/med, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/puffer/genetics, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/puffer/nurse, 2)

/obj/machinery/vending/jobclothing/engineering
	name = "Engineering Apparel"
	desc = "A vending machine that vends Engineering clothing."
	icon_state = "engclothing"
	icon_panel = "snack-panel"
	pay = 1
	acceptcard = 1
	req_access = list(access_engineering)

	create_products(restocked)
		..()
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/color/yellow, 5)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/color/orange, 5)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/rank/engineer, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/rank/mechanic, 5)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/misc/atmospheric_technician, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/rank/orangeoveralls, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/rank/orangeoveralls/yellow, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/wintercoat/engineering, 4)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/hi_vis, 4)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/hazard/fire, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/mask/gas, 6)
		product_list += new/datum/data/vending_product(/obj/item/clothing/gloves/black, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/gloves/yellow/unsulated, 4) //heh
		product_list += new/datum/data/vending_product(/obj/item/clothing/shoes/brown, 4)
		product_list += new/datum/data/vending_product(/obj/item/clothing/shoes/orange, 4)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/yellow, 5)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/orange, 5)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/helmet/hardhat, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/helmet/welding, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/helmet/firefighter, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/goggles/yellow, 1)
		product_list += new/datum/data/vending_product(/obj/item/device/radio/headset/engineer, 2, cost=PAY_TRADESMAN/1.5)
		product_list += new/datum/data/vending_product(/obj/item/device/pda2/engine, 2, cost=PAY_TRADESMAN/1.5)
		product_list += new/datum/data/vending_product(/obj/item/device/pda2/technical_assistant, 2, cost=PAY_TRADESMAN/2)
		product_list += new/datum/data/vending_product(/obj/item/device/pda2/atmos, 2, cost=PAY_TRADESMAN/2)
		product_list += new/datum/data/vending_product(/obj/item/storage/backpack/engineering, 2)
		product_list += new/datum/data/vending_product(/obj/item/storage/backpack/satchel/engineering, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/constructioncone, 16)

		product_list += new/datum/data/vending_product(/obj/item/clothing/under/rank/engineer/april_fools, 2, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/rank/mechanic/april_fools, 2, hidden=1)

#ifdef SEASON_WINTER
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/hi_vis/puffer, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/puffer/engi, 2)
#endif

/obj/machinery/vending/jobclothing/afterlife/engineering
	name = "Engineering Apparel"
	desc = "A vending machine that vends Engineering clothing."
	icon_state = "engclothing"
	icon_panel = "snack-panel"
	pay = 1
	acceptcard = 1
	req_access = null

	create_products(restocked)
		..()
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/color/yellow, 5)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/color/orange, 5)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/rank/engineer, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/rank/mechanic, 5)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/misc/atmospheric_technician, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/rank/orangeoveralls, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/rank/orangeoveralls/yellow, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/wintercoat/engineering, 4)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/hi_vis, 4)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/hazard/fire, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/mask/gas, 6)
		product_list += new/datum/data/vending_product(/obj/item/clothing/gloves/black, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/gloves/yellow/unsulated, 4)
		product_list += new/datum/data/vending_product(/obj/item/clothing/shoes/brown, 4)
		product_list += new/datum/data/vending_product(/obj/item/clothing/shoes/orange, 4)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/yellow, 5)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/orange, 5)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/helmet/hardhat, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/helmet/welding, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/helmet/firefighter, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/goggles/yellow, 1)
		product_list += new/datum/data/vending_product(/obj/item/storage/backpack/engineering, 2)
		product_list += new/datum/data/vending_product(/obj/item/storage/backpack/satchel/engineering, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/constructioncone, 16)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/rank/engineer/april_fools, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/rank/mechanic/april_fools, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/hi_vis/puffer, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/puffer/engi, 2)

/obj/machinery/vending/jobclothing/catering
	name = "Catering Apparel"
	desc = "A vending machine that vends Catering clothing."
	icon_state = "catclothing" //At first it was static on the bartender outfit, but it made it feel like it was only a bartender vendor, so I made it animated to switch between chef and bartender clothing.
	icon_panel = "snack-panel"
	pay = 1
	acceptcard = 1
	req_access = list(access_bar, access_kitchen)

	create_products(restocked)
		..()
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/gimmick/butler, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/gimmick/maid, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/color/white, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/rank/bartender, 1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/rank/chef, 1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/misc/souschef, 1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/chef, 1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/wcoat, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/apron, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/gloves/latex, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/gloves/fingerless, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/shoes/black, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/shoes/brown, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/shoes/chef, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/that, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/maid, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/souschefhat, 1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/chefhat, 1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/chefhatpuffy, 1)
		product_list += new/datum/data/vending_product(/obj/item/device/radio/headset/civilian, 2, cost=PAY_TRADESMAN/1.5)
		product_list += new/datum/data/vending_product(/obj/item/device/pda2, 2, cost=PAY_TRADESMAN/1.5) //Currently, Chef and Barkeep have unique PDA's, but they are functionally the same. So putting a generic PDA here until that changes.
		product_list += new/datum/data/vending_product(/obj/item/storage/backpack, 2)
		product_list += new/datum/data/vending_product(/obj/item/storage/backpack/satchel, 2)

		product_list += new/datum/data/vending_product(/obj/item/clothing/under/misc/itamae, 1, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/itamaehat, 1, hidden=1)
		product_list += new/datum/data/vending_product(pick(/obj/item/clothing/head/headband/nyan/white, /obj/item/clothing/head/headband/nyan/gray, /obj/item/clothing/head/headband/nyan/black), 1, hidden = 1) //Silly headbands (?)

/obj/machinery/vending/jobclothing/afterlife/catering
	name = "Catering Apparel"
	desc = "A vending machine that vends Catering clothing."
	icon_state = "catclothing"
	icon_panel = "snack-panel"
	pay = 1
	acceptcard = 1
	req_access = null

	create_products(restocked)
		..()
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/gimmick/butler, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/gimmick/maid, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/color/white, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/rank/bartender, 1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/rank/chef, 1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/misc/souschef, 1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/chef, 1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/wcoat, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/apron, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/gloves/latex, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/gloves/fingerless, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/shoes/black, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/shoes/brown, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/shoes/chef, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/that, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/maid, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/souschefhat, 1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/chefhat, 1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/chefhatpuffy, 1)
		product_list += new/datum/data/vending_product(/obj/item/storage/backpack, 2)
		product_list += new/datum/data/vending_product(/obj/item/storage/backpack/satchel, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/misc/itamae, 1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/itamaehat, 1)
		product_list += new/datum/data/vending_product(pick(/obj/item/clothing/head/headband/nyan/white, /obj/item/clothing/head/headband/nyan/gray, /obj/item/clothing/head/headband/nyan/black), 1)

/obj/machinery/vending/jobclothing/research
	name = "Research Apparel"
	desc = "A vending machine that vends Research clothing."
	icon_state = "sciclothing"
	icon_panel = "snack-panel"
	pay = 1
	acceptcard = 1
	req_access = list(access_research)

	create_products(restocked)
		..()
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/color/white, 5)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/rank/scientist, 6)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/wintercoat/research, 4)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/labcoat, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/labcoat/science, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/hazard/bio_suit, 4)
		product_list += new/datum/data/vending_product(/obj/item/clothing/mask/surgical, 10)
		product_list += new/datum/data/vending_product(/obj/item/clothing/mask/gas, 4)
		product_list += new/datum/data/vending_product(/obj/item/clothing/gloves/latex, 5)
		product_list += new/datum/data/vending_product(/obj/item/clothing/shoes/brown, 4)
		product_list += new/datum/data/vending_product(/obj/item/clothing/shoes/white, 4)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/bio_hood, 4)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/white, 5)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/purple, 5)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/basecap/purple, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/goggles/purple, 2)
		product_list += new/datum/data/vending_product(/obj/item/device/radio/headset/research, 2, cost=PAY_DOCTORATE/2)
		product_list += new/datum/data/vending_product(/obj/item/device/pda2/toxins, 5, cost=PAY_DOCTORATE/2)
		product_list += new/datum/data/vending_product(/obj/item/storage/backpack/research, 3)
		product_list += new/datum/data/vending_product(/obj/item/storage/backpack/satchel/research, 3)

		product_list += new/datum/data/vending_product(/obj/item/clothing/under/rank/scientist/april_fools, 2, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/labcoat/science/april_fools, 2, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/labcoat/dan, 1, hidden=1)

#ifdef SEASON_WINTER
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/puffer/sci, 2)
#endif

/obj/machinery/vending/jobclothing/afterlife/research
	name = "Research Apparel"
	desc = "A vending machine that vends Research clothing."
	icon_state = "sciclothing"
	icon_panel = "snack-panel"
	pay = 1
	acceptcard = 1
	req_access = null

	create_products(restocked)
		..()
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/color/white, 5)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/rank/scientist, 6)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/wintercoat/research, 4)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/labcoat, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/labcoat/science, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/hazard/bio_suit, 4)
		product_list += new/datum/data/vending_product(/obj/item/clothing/mask/surgical, 10)
		product_list += new/datum/data/vending_product(/obj/item/clothing/mask/gas, 4)
		product_list += new/datum/data/vending_product(/obj/item/clothing/gloves/latex, 5)
		product_list += new/datum/data/vending_product(/obj/item/clothing/shoes/brown, 4)
		product_list += new/datum/data/vending_product(/obj/item/clothing/shoes/white, 4)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/bio_hood, 4)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/white, 5)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/purple, 5)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/basecap/purple, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/goggles/purple, 2)
		product_list += new/datum/data/vending_product(/obj/item/storage/backpack/research, 3)
		product_list += new/datum/data/vending_product(/obj/item/storage/backpack/satchel/research, 3)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/rank/scientist/april_fools, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/labcoat/science/april_fools, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/labcoat/dan, 1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/puffer/sci, 2)

/obj/machinery/vending/jobclothing/syndicate
	name = "Syndicate Apparel"
	desc = "A vending machine that vends Syndicate clothing."
	icon_state = "syndieclothing"
	icon_panel = "snack-panel"
	pay = 1
	acceptcard = 1
	req_access = list()

	create_products(restocked)
		..()
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/misc/syndicate, 4)
#ifdef XMAS
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/helmet/space/santahat/noslow, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/space/santa/noslow, 2)
#endif
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/helmet/space/syndicate, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/space/syndicate, 2)
		product_list += new/datum/data/vending_product(/obj/item/tank/jetpack/syndicate, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/mask/gas/swat, 2, cost=PAY_IMPORTANT)
		product_list += new/datum/data/vending_product(/obj/item/device/pda2/syndicate, 2, cost=PAY_IMPORTANT/2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/gloves/fingerless, 4)
		product_list += new/datum/data/vending_product(/obj/item/clothing/gloves/black, 4)
		product_list += new/datum/data/vending_product(/obj/item/clothing/shoes/swat, 4)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/beret/syndicate, 4)
		product_list += new/datum/data/vending_product(/obj/item/storage/backpack/syndie, 1)
		product_list += new/datum/data/vending_product(/obj/item/storage/backpack/satchel/syndie, 1)
		product_list += new/datum/data/vending_product(/obj/item/storage/fanny/syndie, 1)
