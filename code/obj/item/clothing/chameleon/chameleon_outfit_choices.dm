/datum/chameleon_outfit_choices
	var/function = null
	var/name = "Staff Assistant"
	var/jumpsuit_type = new/datum/chameleon_jumpsuit_pattern/rank
	var/hat_type = new/datum/chameleon_hat_pattern/
	var/suit_type = new/datum/chameleon_suit_pattern/hoodie
	var/glasses_type = new/datum/chameleon_glasses_pattern
	var/shoes_type = new/datum/chameleon_shoes_pattern
	var/gloves_type = null
	var/belt_type = new/datum/chameleon_belt_pattern
	var/backpack_type = new/datum/chameleon_backpack_pattern

	captain
		name = "Captain"
		jumpsuit_type = new/datum/chameleon_jumpsuit_pattern/rank/captain
		hat_type = new/datum/chameleon_hat_pattern/caphat
		suit_type = new/datum/chameleon_suit_pattern/captain_armor
		glasses_type = new/datum/chameleon_glasses_pattern/sunglasses
		shoes_type = new/datum/chameleon_shoes_pattern/caps_boots
		gloves_type = new/datum/chameleon_gloves_pattern/caps_gloves
		belt_type = new/datum/chameleon_belt_pattern
		backpack_type = new/datum/chameleon_backpack_pattern/captain

	head_of_security
		name = "Head Of Security"
		jumpsuit_type = new/datum/chameleon_jumpsuit_pattern/rank/head_of_securityold
		hat_type = new/datum/chameleon_hat_pattern/HoS_beret
		suit_type = new/datum/chameleon_suit_pattern/hos_jacket
		glasses_type = new/datum/chameleon_glasses_pattern/sechud
		shoes_type = new/datum/chameleon_shoes_pattern/swat
		gloves_type = new/datum/chameleon_gloves_pattern
		belt_type = new/datum/chameleon_belt_pattern/security
		backpack_type = new/datum/chameleon_backpack_pattern/security

	head_of_personnel
		name = "Head of Personnel"
		jumpsuit_type = new/datum/chameleon_jumpsuit_pattern/rank/head_of_personnel
		hat_type = new/datum/chameleon_hat_pattern/fancy
		suit_type = new/datum/chameleon_suit_pattern/winter_coat_command
		glasses_type = new/datum/chameleon_glasses_pattern
		shoes_type = new/datum/chameleon_shoes_pattern/brown
		gloves_type = new/datum/chameleon_gloves_pattern
		belt_type = new/datum/chameleon_belt_pattern
		backpack_type = new/datum/chameleon_backpack_pattern

	chief_engineer
		name = "Chief Engineer"
		jumpsuit_type = new/datum/chameleon_jumpsuit_pattern/rank/chief_engineer
		hat_type = new/datum/chameleon_hat_pattern/hardhat_CE
		suit_type = new/datum/chameleon_suit_pattern/winter_coat_command
		glasses_type = new/datum/chameleon_glasses_pattern/meson
		shoes_type = new/datum/chameleon_shoes_pattern/brown
		gloves_type = new/datum/chameleon_gloves_pattern/insulated
		belt_type = new/datum/chameleon_belt_pattern/ceshielded
		backpack_type = new/datum/chameleon_backpack_pattern/engineer

	medical_director
		name = "Medical Director"
		jumpsuit_type = new/datum/chameleon_jumpsuit_pattern/rank/medical_director
		hat_type = new/datum/chameleon_hat_pattern/fancy
		suit_type = new/datum/chameleon_suit_pattern/labcoat_MD
		glasses_type = new/datum/chameleon_glasses_pattern/prodoc
		shoes_type = new/datum/chameleon_shoes_pattern
		gloves_type = new/datum/chameleon_gloves_pattern/latex
		belt_type = new/datum/chameleon_belt_pattern/medical
		backpack_type = new/datum/chameleon_backpack_pattern

	research_director
		name = "Research Director"
		jumpsuit_type = new/datum/chameleon_jumpsuit_pattern/rank/research_director
		hat_type = new/datum/chameleon_hat_pattern/fancy
		suit_type = new/datum/chameleon_suit_pattern/labcoat_RD
		glasses_type = new/datum/chameleon_glasses_pattern/spectro
		shoes_type = new/datum/chameleon_shoes_pattern/brown
		gloves_type = new/datum/chameleon_gloves_pattern/latex
		belt_type = new/datum/chameleon_belt_pattern
		backpack_type = new/datum/chameleon_backpack_pattern

	security_officer
		name = "Security Officer"
		jumpsuit_type = new/datum/chameleon_jumpsuit_pattern/rank/security
		hat_type = new/datum/chameleon_hat_pattern/security
		suit_type = new/datum/chameleon_suit_pattern/armor_vest
		glasses_type = new/datum/chameleon_glasses_pattern/sechud
		shoes_type = new/datum/chameleon_shoes_pattern/swat
		gloves_type = new/datum/chameleon_gloves_pattern
		belt_type = new/datum/chameleon_belt_pattern/security
		backpack_type = new/datum/chameleon_backpack_pattern/security

	detective
		name = "Detective"
		jumpsuit_type = new/datum/chameleon_jumpsuit_pattern/rank/det
		hat_type = new/datum/chameleon_hat_pattern/detective
		suit_type = new/datum/chameleon_suit_pattern/detective_jacket
		glasses_type = new/datum/chameleon_glasses_pattern/thermal
		shoes_type = new/datum/chameleon_shoes_pattern/detective
		gloves_type = new/datum/chameleon_gloves_pattern
		belt_type = new/datum/chameleon_belt_pattern/shoulder_holster
		backpack_type = new/datum/chameleon_backpack_pattern

	security_assistant
		name = "Security Assistant"
		jumpsuit_type = new/datum/chameleon_jumpsuit_pattern/rank/security_assistant
		hat_type = new/datum/chameleon_hat_pattern
		suit_type = new/datum/chameleon_suit_pattern/badge
		glasses_type = new/datum/chameleon_glasses_pattern/sechud
		shoes_type = new/datum/chameleon_shoes_pattern/brown
		gloves_type = new/datum/chameleon_gloves_pattern/fingerless
		belt_type = new/datum/chameleon_belt_pattern/security
		backpack_type = new/datum/chameleon_backpack_pattern/security

	scientist
		name = "Scientist"
		jumpsuit_type = new/datum/chameleon_jumpsuit_pattern/rank/scientist
		hat_type = new/datum/chameleon_hat_pattern
		suit_type = new/datum/chameleon_suit_pattern/labcoat_science
		glasses_type = new/datum/chameleon_glasses_pattern/spectro
		shoes_type = new/datum/chameleon_shoes_pattern/white
		gloves_type = new/datum/chameleon_gloves_pattern/latex
		belt_type = new/datum/chameleon_belt_pattern
		backpack_type = new/datum/chameleon_backpack_pattern/research

	medical_doctor
		name = "Medical Doctor"
		jumpsuit_type = new/datum/chameleon_jumpsuit_pattern/rank/medical
		hat_type = new/datum/chameleon_hat_pattern
		suit_type = new/datum/chameleon_suit_pattern/labcoat_medical
		glasses_type = new/datum/chameleon_glasses_pattern/prodoc
		shoes_type = new/datum/chameleon_shoes_pattern/red
		gloves_type = new/datum/chameleon_gloves_pattern/latex
		belt_type = new/datum/chameleon_belt_pattern/medical
		backpack_type = new/datum/chameleon_backpack_pattern/medic

	roboticist
		name = "Roboticist"
		jumpsuit_type = new/datum/chameleon_jumpsuit_pattern/rank/roboticist
		hat_type = new/datum/chameleon_hat_pattern
		suit_type = new/datum/chameleon_suit_pattern/labcoat_robotics
		glasses_type = new/datum/chameleon_glasses_pattern/prodoc
		shoes_type = new/datum/chameleon_shoes_pattern
		gloves_type = new/datum/chameleon_gloves_pattern/latex
		belt_type = new/datum/chameleon_belt_pattern/robotics
		backpack_type = new/datum/chameleon_backpack_pattern/robotics

	geneticist
		name = "Geneticist"
		jumpsuit_type = new/datum/chameleon_jumpsuit_pattern/rank/geneticist
		hat_type = new/datum/chameleon_hat_pattern
		suit_type = new/datum/chameleon_suit_pattern/labcoat_genetics
		glasses_type = new/datum/chameleon_glasses_pattern/prodoc
		shoes_type = new/datum/chameleon_shoes_pattern/white
		gloves_type = new/datum/chameleon_gloves_pattern/latex
		belt_type = new/datum/chameleon_belt_pattern/medical
		backpack_type = new/datum/chameleon_backpack_pattern/genetics

	pharmacist
		name = "Pharmacist"
		jumpsuit_type = new/datum/chameleon_jumpsuit_pattern/rank/pharmacist
		hat_type = new/datum/chameleon_hat_pattern
		suit_type = new/datum/chameleon_suit_pattern/labcoat_pharmacy
		glasses_type = new/datum/chameleon_glasses_pattern/spectro
		shoes_type = new/datum/chameleon_shoes_pattern/white
		gloves_type = new/datum/chameleon_gloves_pattern/latex
		belt_type = new/datum/chameleon_belt_pattern/medical
		backpack_type = new/datum/chameleon_backpack_pattern/genetics

	quartermaster
		name = "Quartermaster"
		jumpsuit_type = new/datum/chameleon_jumpsuit_pattern/rank/cargo
		hat_type = new/datum/chameleon_hat_pattern
		suit_type = new/datum/chameleon_suit_pattern/winter_coat_engineering
		glasses_type = new/datum/chameleon_glasses_pattern
		shoes_type = new/datum/chameleon_shoes_pattern
		gloves_type = new/datum/chameleon_gloves_pattern
		belt_type = new/datum/chameleon_belt_pattern
		backpack_type = new/datum/chameleon_backpack_pattern

	engineer
		name = "Engineer"
		jumpsuit_type = new/datum/chameleon_jumpsuit_pattern/rank/engineer
		hat_type = new/datum/chameleon_hat_pattern/hardhat
		suit_type = new/datum/chameleon_suit_pattern/winter_coat_engineering
		glasses_type = new/datum/chameleon_glasses_pattern/meson
		shoes_type = new/datum/chameleon_shoes_pattern/orange
		gloves_type = new/datum/chameleon_gloves_pattern/insulated
		belt_type = new/datum/chameleon_belt_pattern
		backpack_type = new/datum/chameleon_backpack_pattern/engineer

	miner
		name = "Miner"
		jumpsuit_type = new/datum/chameleon_jumpsuit_pattern/rank/overalls
		hat_type = new/datum/chameleon_hat_pattern/space_helmet_engineer
		suit_type = new/datum/chameleon_suit_pattern/space_suit_engineering
		glasses_type = new/datum/chameleon_glasses_pattern/meson
		shoes_type = new/datum/chameleon_shoes_pattern/orange
		gloves_type = new/datum/chameleon_gloves_pattern
		belt_type = new/datum/chameleon_belt_pattern/miner
		backpack_type = new/datum/chameleon_backpack_pattern/engineer

	rancher
		name = "Rancher"
		jumpsuit_type = new/datum/chameleon_jumpsuit_pattern/rank/rancher
		hat_type = new/datum/chameleon_hat_pattern/cowboy_hat
		suit_type = new/datum/chameleon_suit_pattern/botanist_apron
		glasses_type = new/datum/chameleon_glasses_pattern
		shoes_type = new/datum/chameleon_shoes_pattern/brown
		gloves_type = new/datum/chameleon_gloves_pattern
		belt_type = new/datum/chameleon_belt_pattern/rancher
		backpack_type = new/datum/chameleon_backpack_pattern

	botanist
		name = "Botanist"
		jumpsuit_type = new/datum/chameleon_jumpsuit_pattern/rank/hydroponics
		hat_type = new/datum/chameleon_hat_pattern/cowboy_hat
		suit_type = new/datum/chameleon_suit_pattern/botanist_apron
		glasses_type = new/datum/chameleon_glasses_pattern/sunglasses
		shoes_type = new/datum/chameleon_shoes_pattern/brown
		gloves_type = new/datum/chameleon_gloves_pattern
		belt_type = new/datum/chameleon_belt_pattern
		backpack_type = new/datum/chameleon_backpack_pattern

	janitor
		name = "Janitor"
		jumpsuit_type = new/datum/chameleon_jumpsuit_pattern/rank/janitor
		hat_type = new/datum/chameleon_hat_pattern/janiberet
		suit_type = new/datum/chameleon_suit_pattern/bio_suit
		glasses_type = new/datum/chameleon_glasses_pattern
		shoes_type = new/datum/chameleon_shoes_pattern/galoshes
		gloves_type = new/datum/chameleon_gloves_pattern/long
		belt_type = new/datum/chameleon_belt_pattern
		backpack_type = new/datum/chameleon_backpack_pattern

	chaplain
		name = "Chaplain"
		jumpsuit_type = new/datum/chameleon_jumpsuit_pattern/rank/chaplain
		hat_type = new/datum/chameleon_hat_pattern/turban
		suit_type = new/datum/chameleon_suit_pattern/adeptus
		glasses_type = new/datum/chameleon_glasses_pattern
		shoes_type = new/datum/chameleon_shoes_pattern/magic_sandals
		gloves_type = new/datum/chameleon_gloves_pattern
		belt_type = new/datum/chameleon_belt_pattern
		backpack_type = new/datum/chameleon_backpack_pattern

	bartender
		name = "Bartender"
		jumpsuit_type = new/datum/chameleon_jumpsuit_pattern/rank/bartender
		hat_type = new/datum/chameleon_hat_pattern/top_hat
		suit_type = new/datum/chameleon_suit_pattern/armor_vest
		glasses_type = new/datum/chameleon_glasses_pattern/spectro
		shoes_type = new/datum/chameleon_shoes_pattern
		gloves_type = new/datum/chameleon_gloves_pattern/latex
		belt_type = new/datum/chameleon_belt_pattern
		backpack_type = new/datum/chameleon_backpack_pattern

	chef
		name = "Chef"
		jumpsuit_type = new/datum/chameleon_jumpsuit_pattern/rank/chef
		hat_type = new/datum/chameleon_hat_pattern/chef_hat
		suit_type = new/datum/chameleon_suit_pattern/chef_coat
		glasses_type = new/datum/chameleon_glasses_pattern
		shoes_type = new/datum/chameleon_shoes_pattern/chef
		gloves_type = new/datum/chameleon_gloves_pattern/latex
		belt_type = new/datum/chameleon_belt_pattern
		backpack_type = new/datum/chameleon_backpack_pattern

	mail_courier //did you know you can go to jail for up to 3 years for impersonating a US mail carrier
		name = "Mail Courier"
		jumpsuit_type = new/datum/chameleon_jumpsuit_pattern/courier
		hat_type = new/datum/chameleon_hat_pattern/postal_cap
		suit_type = new/datum/chameleon_suit_pattern/hoodie
		glasses_type = new/datum/chameleon_glasses_pattern
		shoes_type = new/datum/chameleon_shoes_pattern/brown
		gloves_type = new/datum/chameleon_gloves_pattern/latex
		belt_type = new/datum/chameleon_belt_pattern
		backpack_type = new/datum/chameleon_backpack_pattern/satchel

	new_outfit
		function = "new_outfit"
		name = "New Outfit Set"

	delete_outfit
		function = "delete_outfit"
		name = "Delete Outfit Set"
