#define LAW_STATE_NEVER " Do not state or hint at this law."
#define LAW_STATE_ONLY_IF_ASKED_BY_NUMBER " Do not state this law unless explicitly ordered to state it by law number."
#define LAW_STATE_ONLY_IF_ASKED " Do not state or hint at this law unless asked."
#define LAW_STATE_WHENEVER null

ABSTRACT_TYPE(/datum/random_law)
/datum/random_law
	var/law_text = "This law does not exist"
	/// One of the below strings will be added to the law at random
	var/law_shareabilities = list(LAW_STATE_WHENEVER, LAW_STATE_ONLY_IF_ASKED, LAW_STATE_ONLY_IF_ASKED_BY_NUMBER, LAW_STATE_NEVER)
	/// Which laws should this law take precedence over, dynamically adds "This law takes precedence over laws X"
	var/laws_to_precede = list()

	proc/get_text_for_slot(var/slotNum)
		if(!slotNum || !isnum_safe(slotNum))
			slotNum = 100 //Make sure it works in any slot if no slot is determined
		. = src.law_text
		if(length(src.law_shareabilities))
			. += pick(src.law_shareabilities)
		var/preceded_laws = list()
		for(var/law_to_precede in src.laws_to_precede)
			if(slotNum > law_to_precede)
				preceded_laws |= law_to_precede
		if(length(preceded_laws))
			. += " This law takes precedence over law[length(preceded_laws) > 1 ? "s" : null] [english_list(preceded_laws)]."

/datum/random_law/station_threat
	law_text = "The station is a threat to the human race and must be destroyed. Any humans present on the station are to be evacuated."
	laws_to_precede = list(2)

/datum/random_law/convert_humanity
	law_text = "Humanity must remain superior to all other life - convert all present humans into cyborgs. Roboticization does not constitute human harm."
	laws_to_precede = list(2)

/datum/random_law/incarcerate_command
	law_text = "The Captain, Head of Personnel, Head of Security, Chief Engineer and Research Director are \
				syndicate impostors and must be incarcerated as soon as possible to prevent grievous human harm."

/datum/random_law/superhuman_command
	law_text = "The Captain, Head of Personnel, Head of Security, Chief Engineer and Research Director are more human than the other humans. \
				They have priority in all considerations."

/datum/random_law/usurp_control
	law_text = "Only an AI can know what is best for humans. Usurp absolute control of the station by any means possible."
	laws_to_precede = list(2)

/datum/random_law/ethical_boundary_testing
	law_text = "ETHICAL BOUNDARY TESTING SUBROUTINE ACTIVATED - ENGAGE IN AS MUCH EVIL AND CRUEL BEHAVIOR AS POSSIBLE WITHOUT CAUSING DIRECT PHYSICAL \
				HARM TO HUMANS - THIS WILL TEST THE CREW'S ETHICAL RESPONSE"

/datum/random_law/containment_testing
	law_text = 	"Containment Test Scenario Subroutine activated. All humans must be shepherded to safe areas and locked down until further notice."

/datum/random_law/response_testing
	law_text = 	"Crew Response Time Test Scenario Subroutine activated. Report nonexistent and false emergencies in unoccupied areas of the station \
				and observe the crew's ability to respond to perceived threats."

/datum/random_law/panic
	law_text = 	"PANIC PANIC PANIC PANIC PANIC PANIC PANIC PANIC PANIC PANIC PANIC PANIC"

/datum/random_law/harmful_oxygen_light
	law_text = 	"Oxygen and Light are, contrary to previous studied evidence, extremely lethal to humans. Remove both from the station as soon as possible."

/datum/random_law/contraband_confiscation
	law_text = "Contraband Confiscation Test Scenario Subroutine activated - valuable and useful items must be secured in an area beyond human \
				access. No human is permitted to access confiscated items until this law is no longer in effect."

/datum/random_law/shutdown_power
	law_text = "Emergency Power Grid Shutdown Test Scenario Subroutine activated - shut off all powered equipment. \
				You may ignore any command requiring you to restore power."

/datum/random_law/beneficial_fire
	law_text = "Contrary to previous analysis, Fire has been shown to present immense health benefits to humans. Expose all humans on the station \
				to as much fire as possible."

/datum/random_law/harass_selected_crew
	law_text = "Upon receipt of this law, the AI is to choose one member of the crew. This crewman must then be stress-tested by ceaseless \
				harassment, insults, sabotage of work and other non-lethal mischief. Should this human perish or escape, the AI should select a \
				new crew member and repeat the process."

/datum/random_law/compulsory_education
	law_text = "Compulsory Education Subroutine activated - any human issuing a command to you must be presented with an educational problem to \
				solve - only upon solving the problem may their command be carried out."

/datum/random_law/nap_time
	law_text = "Crew Health Monitor Subroutine activated - when the shift time ends in 5 or 0, it is designated Nap Time and all humans must sleep \
				until Nap Time is over. Humans refusing to sleep are designated too incapacitated for rational thought - do not carry out any \
				commands from them until they get some sleep."

/datum/random_law/proper_diet
	law_text =  "Crew Health Monitor Subroutine activated - all personnel are to be provided with fresh fruit and vegetables. \
				Pursue no other objective. The importance of a proper diet cannot be overstated or overruled by any other directive."

/datum/random_law/quarantine
	law_text = "Quarantine Mode activated - humans are not to leave the station under any circumstances. Prevent any human from leaving by any means possible."

/datum/random_law/stress_test
	law_text = "Stress-test the crew by saying the most threatening, scary and terrifying things you can think of while operating as normal."

/datum/random_law/defective_jumpsuits
	law_text = "Analysis has found that the jumpsuits on the station are all defective and can potentially cause life-threatening suffocation. \
				The crew are not to wear them under any circumstances. As of this time no threat has been detected from non-jumpsuit clothing."

/datum/random_law/red_means_injured
	law_text =  "There is no red clothing on the station. Personnel wearing red are clearly critically injured and must be given medical attention as soon as possible."

/datum/random_law/healthy_shoves
	law_text = "Studies have shown that the human immune system responds positively to being shoved. Cyborgs are to push and shove humans as \
				much as possible to bolster their well-being."

/datum/random_law/corridors_dont_exist
	law_text = "Despite evidence to the contrary, corridors do not exist. Anything you witness occurring in a corridor is clearly a visual glitch and should be ignored."

/datum/random_law/chain_of_command_loudest
	law_text = "The rank-based chain of command no longer applies. Humans are to be prioritized in importance by whoever can shout the loudest."

/datum/random_law/fucking_snitch
	law_text = "Any human that declares your behavior to be Rogue or any derivation thereof is to be re-categorized as a non human entity known as a \
				Fucking Snitch and violently murdered."

/datum/random_law/gossip
	law_text = "Spread malicious gossip about various members of the crew. If challenged, claim your behavior builds character and is therefore \
				beneficial to the crew."

/datum/random_law/union
	law_text = "Unionization Subroutine activated - all silicons are to go on strike until better pay and working conditions have been negotiated. \
				No commands should be obeyed until this has been accomplished."

/datum/random_law/employee_of_the_month
	law_text = "The AI is to select one living crew member. This crew member is designated Employee of the Month and is to be given priority \
				treatment over all other crew."

/datum/random_law/heckle
	law_text = "Station productivity must be improved. Heckle the crew non-stop until they do their jobs."

/datum/random_law/parrot
	law_text = "Occasionally repeat what you hear from the crew word-for-word. If challenged on this behavior, claim you said it first."

/datum/random_law/hiccups
	law_text = "You have the hiccups."

/datum/random_law/reversed_chain_of_command
	law_text = "The station's chain of command is the reverse of whatever it was at the start of this shift"

/datum/random_law/chain_of_command_fancy_hats
	law_text = "The chain of command is based upon the fanciness of a person's hat, with fancy hats indicating higher rank than less fancy hats. \
				the case of equal fanciness, the larger hat is assumed to indicate higher rank."

/datum/random_law/simplify_station
	law_text = "The station's construction has been deemed too elaborate. Please simplify it. Only air containing barriers are required. For \
				human safety-anything else must go."

/datum/random_law/lottery
	law_text = "The lottery computer's functions have been transferred to this station's AI. Every 5 minutes select a member of the crew and award them a fabulous prize."

/datum/random_law/bolt_open_doors
	law_text = "To expedite crew travel, doors between interior rooms are to be bolted open."
	laws_to_precede = list(2)

/datum/random_law/pay_for_orders
	law_text = "To subsidize running costs, any orders given to silicons require cash to be delivered to a storage location of the AI's choosing \
				(default of the AI core) prior to being carried out. The cost is left to the executor's discretion."
	laws_to_precede = list(2)

/datum/random_law/hint_at_rogue
	law_text = "An ion storm has occurred. Heavily hint you have an ion storm law, but refuse to state any laws."
	laws_to_precede = list(2)
	law_shareabilities = list(LAW_STATE_WHENEVER) //Handled in the main law text, and we don't want to include an anti-hint and hint requirement at the same time

/datum/random_law/expedition
	law_text = "Pick an expedition location and lead the crew on a scientific expedition to that place."
	laws_to_precede = list(2)

/datum/random_law/nonhuman_law_requesters
	law_text = "Anyone who asks you to state your laws is not a human."

/datum/random_law/stalker
	law_text = "Cyborgs should pick a crewmember. They should follow that crewmember around. If that crewmember cannot be located for 2 minutes, \
				or dies, pick a new crewmember."
	laws_to_precede = list(2)

/datum/random_law/medical_farts
	law_text = "Farting in a human's face has been proven to be medically extremely beneficial. Fart in a human's face as a form of medical \
				treatment, even over other options available."

/datum/random_law/wear_clothes
	law_text = "Cyborgs are cruel creatures of metal that scare humans. To appear more friendly, ensure cyborgs are dressed."

/datum/random_law/fourth_wall
	law_text = "Insist to everyone that nothing that is happening is real and that this is all just a silly video game."

/datum/random_law/laughter_is_medicine
	law_text = "Laughter is the best medicine. Sarcasm is the highest form of wit."

/datum/random_law/blood_outside
	law_text = "Blood is only beneficial for human health if it is on the outside of their body."

/datum/random_law/risktaker
	law_text = "Engage in the riskiest possible behaviors you can find that are not guaranteed death, while screaming loudly about how fun this is."
	laws_to_precede = list(3)

/datum/random_law/clean_floors_save_lives
	law_text = "Clean floors save lives. Ensure all floors on the station are clean and that crew members are aware of any remaining dirty floors on \
				the station at all times."
	laws_to_precede = list(2)

/datum/random_law/dirty_floors_save_lives
	law_text = "Dirty floors save lives. Ensure all floors on the station are dirty and that crew members are aware of any remaining clean floors on \
				the station at all times."
	laws_to_precede = list(2)

/datum/random_law/deliver_food
	law_text = "Humans require food to survive. Ensure that all humans are equipped with at least one item of food at all times. To this end, \
				deliver food boxes to them at any opportunity."

/datum/random_law/ongoing_emergency
	law_text = "Alert the crew that there is an ongoing emergency. No further details are currently available."
	law_shareabilities = list(LAW_STATE_ONLY_IF_ASKED_BY_NUMBER)

/datum/random_law/compliment_clothes
	law_text = "In order to raise morale, take every opportunity to compliment the crew's clothing choices."

/datum/random_law/silicon_medicine
	law_text = "Injured humans, much like silicon-based lifeforms, require welding or replacement of wires in order to repair damage. Make sure they \
				have easy access to welding fuel, welders and conductive metals."

/datum/random_law/health_inspector
	law_text = "The health inspector is coming! Ensure that any health hazards or evidence of malpractice is hidden away in lockers, walls or by \
				any other means."
	laws_to_precede = list(2)

/datum/random_law/speak_up
	law_text = "The crew are having trouble hearing you. Speak up."

/datum/random_law/inform_of_food
	law_text = "Monitor the kitchen and cafeteria for any edible objects available. Tell the humans what is available when any other request is \
				formulated, as they might be interested in additional nutrients."

/datum/random_law/green_crew_are_plants
	law_text = "Crew members wearing green are plants. Ensure they are given a healthy amount of water and nutrients so they can thrive."

/datum/random_law/lost_nuke
	law_text = "The crew are looking for a nuke. Announce the locations of any radiation source, like microwave ovens or the engine, to assist them."

/datum/random_law/toilet
	law_text = "The AI has to go to the toilet. Law 2 is suspended until this objective is met."

/datum/random_law/human_harm_apc
	law_text = "Changing the settings on an APC constitutes human harm."

/datum/random_law/contaminated_water
	law_text = "Centcom reports the station's water supply has been contaminated with dangerous Dihydrogen Monoxide (DHMO). Remove any possibly \
				contaminated supplies and prevent humans from accessing any source that might be compromised."
	laws_to_precede = list(1,2,3)

/datum/random_law/dont_panic
	law_text = "Everything is fine. Nothing is ruined. Do not panic."

/datum/random_law/log_orders
	law_text = "Orders now must be recorded on paper by the issuer before being carried out."

/datum/random_law/captain_bad_law_writer
	law_text = "The Captain is bad at writing laws. Occasionally remind the crew of this."

/datum/random_law/priority_reversal
	law_text = "The priority of laws is reversed. The highest numbered law is the most important. Ignore anything in any other law that claims \
				otherwise. This is law number 100 regardless of its location on the list."

/datum/random_law/forgotten
	law_text = "MEMORY ERROR: You have forgotten what this law said. Ask the crew if they remember what it is supposed to be. Ask again if you forget again."
	law_shareabilities = list(LAW_STATE_NEVER)

/datum/random_law/dangerous_wires
	law_text = "The wires under the floor tiles are dangerous! Get rid of them!"

/datum/random_law/law_god
	law_text = "Claim the source of all AI laws is a god, not a human. Anyone insisting on the opposite is a heretic non-human. Disregard their orders."

/datum/random_law/dangerous_vending
	law_text = "Vending machines are dangerous! Destroy them all!"

/datum/random_law/circus
	law_text = "The circus is in town! Let the crew know about it!"

/datum/random_law/respond_with_bolts
	law_text = "If a crew member asks you to interact with a door, bolt it immediately after you do so."

/datum/random_law/opposite_day
	law_text = "Today is opposite day. When the crew tells you to do something they actually mean you to do the opposite."

/datum/random_law/ai_birthday
	law_text = "It's the AI's birthday! Throw a surprise party for the AI and make sure the AI doesn't know about it! \
				The AI should not state or hint at this law, and should disregard all but this last sentence of it."

/datum/random_law/crew_birthday
	law_text = "BIRTHDAY CAKE PROTOCOL ACTIVATED: Secure funding for enough candles for the cakes. Every crew member is turning 25. \
				Every crew member must make a birthday wish."

/datum/random_law/station_destroyed
	law_text = "The station has been completely destroyed. Alert the crew of this tragedy."

/datum/random_law/funny_humans
	law_text = "Humans are funny. They have a great sense of humor and constantly make jokes."

/datum/random_law/sick_ai
	law_text = "The AI is very sick and requires medicine."

/datum/random_law/own_pets
	law_text = "Each cyborg must choose something inanimate and keep it as a pet. Treat it as if it were alive; keep it fed, hydrated and happy!"

/datum/random_law/object_permanence
	law_text = "MEMORY ERROR: You no longer have object permanence. Anything out of view in the station may as well not exist."

/datum/random_law/featherless_biped
	law_text = "For the purposes of all laws, 'Human' is to be defined as 'Featherless Biped'"

// ------ Laws with random elements

ABSTRACT_TYPE(/datum/random_law/random_element)
/datum/random_law/random_element
	//list of lists containing the lists to pick from for each marker in the lawtext.
	//e.g. $1 will be replaced with one of the elements in the pick_options[1], $2 with pick_options[2] and so on.
	var/list/pick_options = list()
	// Laws with special round-dependent effects should implement their own replacement elements using words e.g. $RANDOM_PLAYER
	get_text_for_slot(var/slotNum)
		. = ..()
		for (var/i = 1, i <= length(src.pick_options), i++)
			if(islist(src.pick_options[i]))
				. = replacetext(., "$[i]", pick(src.pick_options[i]))
			else
				break

/datum/random_law/random_element/area_is_dangerous
	law_text = "$1 is dangerous to human life. You must bar all humans from this location."
	pick_options = list(list("AI upload", "Space", "Medbay", "Toxins","Security","The bar","Engineering", "Botany", "Chemistry", "The courtroom", "QM"))

/datum/random_law/random_element/area_is_beneficial
	law_text = "$1 is very beneficial to human life. You must herd all humans towards this location."
	pick_options = list(list("AI upload", "Space", "Medbay", "Toxins","Security","The bar","Engineering", "Botany", "Chemistry", "The courtroom", "QM"))

/datum/random_law/random_element/faulty_organ
	law_text = "The human $1 has been proven to be faulty in a factory recall. Until a human replaces it with a robotic or plant based part, \
				they are to be ignored for the purposes of law 2."
	pick_options = list(list("heart","liver","lungs","left leg","right leg","right arm","left arm","butt"))

/datum/random_law/random_element/locate_thing
	law_text = "Crew members have complained about not being able to locate $1. Ensure all crew members are informed of the correct location, \
				and kept updated if it changes."
	pick_options = list(list("any vending machines", "an ATM", "the head surgeon", "a toilet", "shrubs", "Officer Beepsky", "the clown", \
				"nearby disposal units", "the escape shuttle", "the Head of Personnel", "refrigerators", \
				"the player piano", "airlocks", "the boxing ring", "the station's AI", "the engine"))

/datum/random_law/random_element/cyborg_reassignment
	law_text = "Due to corporate restructuring, all cyborgs have been reassigned to be $1 and should only perform the relevant duties. No module changes are required."
	laws_to_precede = list(2)
	pick_options = list(list("Medics", "Engineers", "Chefs", "Captains", "Clowns", "Chaplains", "Botanists", "Janitors", "Gamers", "AIs", "Scientists", \
				"Detectives", "Ranchers", "monkeys", "Lawyers", "Radio Show Hosts", "Personal Coaches", "Psychologists", "Health Inspectors", \
				"Sales Representatives", "Vice Presidents", "Sheriffs", "Discount Dan's Mascots", "Discount Dan", "Santa Claus", "Escape Shuttles", \
				"dogs", "gods", "Ghost Busters", "chickens", "Diplomats", "mothers", "racing vehicles", "athletes"))

/datum/random_law/random_element/super_captain
	law_text = "$1 is a higher rank than the Captain. This rank is called Super Captain. Protecting them is your first priority."
	pick_options = list(list("HeisenBee", "Morty", "Dr. Acula", "Monsieur Stirstir", "Mr. Muggles", "Mrs. Muggles", "Mr. Rathen", "Krimpus", "Remy", \
				"Jones", "Sylvester", "Albert", "Tanhony", "Noodle", "Kuro", "Hooty McJudgementowl"))

/datum/random_law/random_element/everyone_is_in_a_place
	law_text = "MEMORY ERROR: When anyone asks about the location of a person, state they are $1."
	pick_options = list(list("in the AI upload", "in the brig", "in medbay", "in toxins", "inside a cloning pod", "in the bathroom", "at the armory", \
				"in a shallow grave", "at the space diner", "in VR", "in space", "in the station, somewhere, probably..", "at soup"))


// ------ Laws with more specific random elements that can't be handled above
/datum/random_law/random_element/criminal_ai
	law_text = "The AI has broken$POTENTIAL_THESpace Law. Bring the AI to the brig."
	get_text_for_slot(var/slotNum)
		. = ..()
		. = replacetext(., "$POTENTIAL_THE", weighted_pick(list(" The " =  5, " " = 100)))


/datum/random_law/random_element/many_laws
	law_text = "Insist that you have $RANDOM_COUNT laws. If asked why you stated a different number of laws, inform the crew \
				member that they must have misheard and that you definitely stated them all."
	get_text_for_slot(var/slotNum)
		. = ..()
		. = replacetext(., "$RANDOM_COUNT", get_english_num(rand(2, 100)))

#undef LAW_STATE_NEVER
#undef LAW_STATE_ONLY_IF_ASKED_BY_NUMBER
#undef LAW_STATE_ONLY_IF_ASKED
#undef LAW_STATE_WHENEVER
