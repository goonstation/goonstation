// Armour

/obj/item/clothing/mask/menpo
	name = "samurai menpo"
	desc = "An intimidating mask, modelled after Space Japanese yōkai and designed to stop the enemies of the samurai in their tracks."
	icon_state = "menpo"
	item_state = "menpo"
	see_face = 0

/obj/item/clothing/head/helmet/kabuto
	name = "samurai kabuto"
	desc = "A steel helmet worn to protect the samurai; at least, those that could afford such a piece. It's quite heavy."
	icon_state = "kabuto"
	item_state = "kabuto"
	hides_from_examine = C_EARS
	// seal_hair = TRUE
	path_prot = FALSE

	setupProperties()
		..()
		setProperty("coldprot", 10)
		setProperty("heatprot", 5)
		setProperty("meleeprot_head", 2)

/obj/item/clothing/suit/armor/samurai
	name = "samurai armor"
	desc = "A highly intricate piece of custom-made samurai armor. This one's reminiscent of Late Sengoku Jidai <i>tosei-gusoku</i>; sporting a thick steel breastplate meant to shrug off bullets."
	icon_state = "samurai"
	item_state = "samurai"
	hides_from_examine = C_UNIFORM

	setupProperties()
		..()
		setProperty("coldprot", 10)
		setProperty("meleeprot", 12)
		setProperty("rangedprot", 3)
		setProperty("pierceprot", 25)
		setProperty("disorient_resist", 45)
		setProperty("movespeed", 2)

/obj/item/clothing/gloves/samurai_kote
	name = "samurai kote"
	desc = "A set of armored sleeves and gauntlets; of silk brocade and heavy metal plates. Bulky, yet surprisingly flexible."
	icon_state = "samurai_kote"
	item_state = "samurai_kote"
	material_prints = "dark red, leather fibers"

	setupProperties()
		..()
		setProperty("coldprot", 7)
		setProperty("conductivity", 0.4)
		setProperty("deflection", 40)

// Underclothes

/obj/item/clothing/under/gimmick/kobakama
	name = "kosode and kobakama"
	desc = "The <i>really</i> traditional garb of the samurai. You have no idea what this is doing on a space station."
	icon_state = "kobakama_1"
	item_state = "kobakama_1"

// /obj/item/clothing/under/gimmick/kobakama/random
// 	New()
// 		var/n = rand(1,6)
// 		icon_state = "kobakama_[n]"
// 		item_state = "kobakama_[n]"
// 		..()
