// CIRR SAYS TODO, THIS IS TOO MUCH FOR ME RIGHT NOW
// /datum/objective/critter

// 	survival
// 		explanation_text = "This is a dangerous place to be for a tiny little animal. Survive!"
// 		check_completion()
// 			if(!owner.current || is_dead(owner.current))
// 				return 0
// 			return 1

// 	migrant
// 		explanation_text = "This place is far too dangerous to survive in. Stow away on the shuttle to a better life."
// 		check_completion()
// 			if(emergency_shuttle.location<SHUTTLE_LOC_RETURNED)
// 				return 0
// 			if(!owner.current || owner.current.stat ==2)
// 				return 0
// 			return src.owner.current.on_centcom()

// 	feast
// 		explanation_text = "Space winter is approaching, and you need to eat at least 10 food items to hibernate in the cold of space."

// 	cheese
// 		explanation_text = "Eat at least 5 pieces of cheese to stay true to your inner-most nature."
