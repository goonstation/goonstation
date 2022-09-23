// I should just kill this bit with fire.
#define GRIFFENING_TYPE_SWIFT 1
#define GRIFFENING_TYPE_ARMOR 2
#define GRIFFENING_TYPE_INSTANT 4
#define GRIFFENING_TYPE_RESPONSE 8
#define GRIFFENING_TYPE_EQUIP 16
#define GRIFFENING_TYPE_FIRE 32
#define GRIFFENING_TYPE_CONTINUOUS 64

#define GRIFFENING_TARGET_NONE 0
#define GRIFFENING_TARGET_HUMAN 1
#define GRIFFENING_TARGET_CYBORG 2
#define GRIFFENING_TARGET_ETHEREAL 4
#define GRIFFENING_TARGET_ROBOT 8
#define GRIFFENING_TARGET_ORGANIC 16
#define GRIFFENING_TARGET_SYNDICATE 32
#define GRIFFENING_TARGET_CREATURE GRIFFENING_TARGET_HUMAN | GRIFFENING_TARGET_CYBORG | GRIFFENING_TARGET_ROBOT | GRIFFENING_TARGET_ETHEREAL | GRIFFENING_TARGET_ORGANIC | GRIFFENING_TARGET_SYNDICATE
#define GRIFFENING_TARGET_EFFECT 64
#define GRIFFENING_TARGET_EQUIP 128
#define GRIFFENING_TARGET_EFFECT_ROW GRIFFENING_TARGET_EFFECT | GRIFFENING_TARGET_EQUIP
#define GRIFFENING_TARGET_AREA 256
#define GRIFFENING_TARGET_ANYTHING GRIFFENING_TARGET_CREATURE | GRIFFENING_TARGET_EFFECT_ROW | GRIFFENING_TARGET_AREA
#define GRIFFENING_TARGET_OPPONENT 512
#define GRIFFENING_TARGET_OWN 1024
#define GRIFFENING_TARGET_ANY_PLAYER GRIFFENING_TARGET_OPPONENT | GRIFFENING_TARGET_OWN
#define GRIFFENING_TARGET_DISCARD 2048
#define GRIFFENING_TARGET_DISCARDED 4096

#define GRIFFENING_TARGET_OWN_HUMAN GRIFFENING_TARGET_HUMAN | GRIFFENING_TARGET_OWN
#define GRIFFENING_TARGET_OPPONENT_HUMAN GRIFFENING_TARGET_HUMAN | GRIFFENING_TARGET_OPPONENT
#define GRIFFENING_TARGET_ANY_HUMAN GRIFFENING_TARGET_HUMAN | GRIFFENING_TARGET_ANY_PLAYER
#define GRIFFENING_TARGET_OWN_FIELD GRIFFENING_TARGET_ANYTHING | GRIFFENING_TARGET_OWN
#define GRIFFENING_TARGET_OPPONENT_FIELD GRIFFENING_TARGET_ANYTHING | GRIFFENING_TARGET_OPPONENT
#define GRIFFENING_TARGET_ANY_FIELD GRIFFENING_TARGET_ANYTHING | GRIFFENING_TARGET_ANY_PLAYER
#define GRIFFENING_TARGET_OPPONENT_EFFECTS_ROW GRIFFENING_TARGET_EFFECT_ROW | GRIFFENING_TARGET_OPPONENT
#define GRIFFENING_TARGET_OPPONENT_EQUIP GRIFFENING_TARGET_EQUIP | GRIFFENING_TARGET_OPPONENT
#define GRIFFENING_TARGET_ANY_DISCARD GRIFFENING_TARGET_DISCARD | GRIFFENING_TARGET_ANY_PLAYER
#define GRIFFENING_TARGET_ANY_AREA GRIFFENING_TARGET_AREA | GRIFFENING_TARGET_ANY_PLAYER
#define GRIFFENING_TARGET_OWN_CREATURE GRIFFENING_TARGET_CREATURE | GRIFFENING_TARGET_OWN
#define GRIFFENING_TARGET_OPPONENT_CREATURE GRIFFENING_TARGET_CREATURE | GRIFFENING_TARGET_OPPONENT
#define GRIFFENING_TARGET_ANY_CREATURE GRIFFENING_TARGET_CREATURE | GRIFFENING_TARGET_ANY_PLAYER
#define GRIFFENING_TARGET_OWN_DISCARDED_CREATURE GRIFFENING_TARGET_DISCARDED | GRIFFENING_TARGET_CREATURE | GRIFFENING_TARGET_OWN
#define GRIFFENING_TARGET_ANY_DISCARDED_CREATURE GRIFFENING_TARGET_DISCARDED | GRIFFENING_TARGET_CREATURE | GRIFFENING_TARGET_ANY_PLAYER

#define GRIFFENING_ATTRIBUTE_NONE 0
#define GRIFFENING_ATTRIBUTE_HUMAN GRIFFENING_TARGET_HUMAN
#define GRIFFENING_ATTRIBUTE_CYBORG GRIFFENING_TARGET_CYBORG
#define GRIFFENING_ATTRIBUTE_ETHEREAL GRIFFENING_TARGET_ETHEREAL
#define GRIFFENING_ATTRIBUTE_ROBOT GRIFFENING_TARGET_ROBOT
#define GRIFFENING_ATTRIBUTE_ORGANIC GRIFFENING_TARGET_ORGANIC
#define GRIFFENING_ATTRIBUTE_SYNDICATE GRIFFENING_TARGET_SYNDICATE
#define GRIFFENING_ATTRIBUTE_AI 64
//#define GRIFFENING_ATTRIBUTE_SYNDICATE 128
#define GRIFFENING_ATTRIBUTE_HANDS 256
#define GRIFFENING_ATTRIBUTE_LAWS 512
#define GRIFFENING_ATTRIBUTE_HEAD 1024
#define GRIFFENING_ATTRIBUTE_DEFAULT GRIFFENING_ATTRIBUTE_HANDS | GRIFFENING_ATTRIBUTE_ORGANIC | GRIFFENING_ATTRIBUTE_HUMAN

/datum/playing_card
	var/card_name = "playing card"
	var/card_desc = "A card, for playing some kinda game with."
	var/card_face = "blank"
	var/card_back = "suit"
	var/card_foil = TRUE
	var/card_data = null
	var/card_reversible = FALSE // can the card be drawn reversed? ie for tarot
	var/card_reversed = FALSE // IS it reversed?
	var/card_tappable = TRUE // tap 2 islands for mana
	var/card_tapped = FALSE // summon Fog Bank, laugh
	var/card_spooky = FALSE
	var/solitaire_offset = 3

	New(cardname, carddesc, cardback, cardface, cardfoil, carddata, cardreversible, cardreversed, cardtappable, cardtapped, cardspooky, cardsolitaire)
		..()
		if (cardname) src.card_name = cardname
		if (carddesc) src.card_desc = carddesc
		if (cardback) src.card_back = cardback
		if (cardface) src.card_face = cardface
		if (cardfoil) src.card_foil = cardfoil
		if (carddata) src.card_data = carddata
		if (cardreversible) src.card_reversible = cardreversible
		if (cardreversed) src.card_reversed = cardreversed
		if (cardtappable) src.card_tappable = cardtappable
		if (cardtapped) src.card_tapped = cardtapped
		if (cardspooky) src.card_spooky = cardspooky
		if (cardsolitaire) src.solitaire_offset = cardsolitaire

	proc/examine_data()
		return card_data

/datum/playing_card/griffening
	creature
		var/randomized_stats = FALSE
		var/LVL = 0
		var/ATK = 0
		var/DEF = 0
		var/attributes = GRIFFENING_ATTRIBUTE_DEFAULT
		var/image/template = null

		examine_data()
			. = ..()
			. += "<br>LVL [LVL] | ATK [ATK] | DEF [DEF]"
		mob
			captain
				attributes = GRIFFENING_ATTRIBUTE_DEFAULT | GRIFFENING_ATTRIBUTE_HEAD
				LVL = 7
				ATK = 60
				DEF = 40
				card_name = "Captain"
				card_data = "Captain cannot be played if any Nuclear Operatives are on the same side of the field, or if a Captain is already face up on the field. Captain can only be played while the Bridge area is active. When Captain enters play, you may immediately equip an Energy Gun card from your deck. When Captain enters play, all face down Captains must be discarded."

			head_of_personnel
				attributes = GRIFFENING_ATTRIBUTE_DEFAULT | GRIFFENING_ATTRIBUTE_HEAD
				LVL = 7
				ATK = 20
				DEF = 65
				card_name = "Head of Personnel"
				card_data = "Head of Personnel is discarded at the end of the every turn after the third turn after it was played if it is not equipped with any equipment cards. While Head of Personnel is in play, no other creature may be attacked by the opponent."

			head_of_security
				attributes = GRIFFENING_ATTRIBUTE_DEFAULT | GRIFFENING_ATTRIBUTE_HEAD
				LVL = 7
				ATK = 50
				DEF = 35
				card_name = "Head of Security"
				card_data = "You must sacrifice one Security Officer from your side of the field to play this card. Head of Security increases the ATK of all Security Officers on the same side of the field by 20."

			security
				LVL = 5
				ATK = 30
				DEF = 25
				card_name = "Security Officer"
				card_data = "Security Officer cannot kill non-antagonist humans unless Head of Security is in play. Instead, when attacking non-antagonist humans with DEF lower than Security Officer's ATK, the human is incapacitated, unable to attack on its next turn."

			research_director
				LVL = 6
				ATK = 40
				DEF = 40
				attributes = GRIFFENING_ATTRIBUTE_DEFAULT | GRIFFENING_ATTRIBUTE_HEAD
				card_name = "Research Director"
				card_data = "You must sacrifice a Scientist from your side of the field to play Research Director. Research Director's ATK and DEF increases by 10 for each Scientist on the same side of the field. At the beginning of its owner's turn, Research Director may increase either its ATK or DEF by 10. This effect lasts until the next time its owner's turn begins."

			scientist
				LVL = 3
				ATK = 25
				DEF = 25
				card_name = "Scientist"
				card_data = "At the beginning of its owner's turn, Scientist may increase either its ATK or DEF by 10. This effect lasts until the next time its owner's turn begins."

			clown
				LVL = 2
				ATK = 10
				DEF = 25
				card_name = "Clown"
				card_data = "Once per turn, when the opponent attacks, the attack may be redirected at the Clown. This effect may be used while Clown is face down, revealing Clown. If the Clown attacks any opponent, it is discarded. If the opponent creature is not killed, it is incapacitated for one turn."

			wizard
				LVL = 7
				ATK = 28
				DEF = 15
				card_name = "Wizard"
				card_data = "When Wizard is equipped with 'Magical Robe' and 'Magical Hat', at the start of the opponent's turn, it may use one of the following special effects: Incapacitate all opponent humans on the field for one turn, kill one opponent human, or shift out of existence becoming unable to be attacked or to defend until the start of the owner's turn. If Wizard is also equipped with 'Magical Staff', it may use one additional effect."

			nukeop
				LVL = 5
				ATK = 30
				DEF = 19
				card_name = "Nuclear Operative"
				card_data = "Nuclear Operative cannot be played if any Captains are on the same side of the field. Nuclear Operative may wield syndicate items at any time. When killed by normal attack, the attacking creature is incapacitated for one turn."

			traitor
				LVL = 3
				ATK = 25
				DEF = 25
				card_name = "Traitor"
				card_data = "Traitor may wield syndicate items at any time."

			changeling
				LVL = 1
				ATK = 10
				DEF = 10
				card_name = "Changeling"
				attributes = GRIFFENING_ATTRIBUTE_HANDS | GRIFFENING_ATTRIBUTE_ORGANIC
				card_data = "Once per turn, Changeling may take on the form and stats of any human in the opponent's discard pile. The selected human is moved to the gibbed pile of the opponent. When opponent successfully uses the effect of 'Flamethrower', 'Incendiary Grenade' or 'Plasma Fire', Changeling is discarded."

			vampire
				LVL = 5
				ATK = 25
				DEF = 25
				card_name = "Vampire"
				attributes = GRIFFENING_ATTRIBUTE_HANDS | GRIFFENING_ATTRIBUTE_ORGANIC
				card_data = "You must sacrifice one human crew member on your side of the field to play Vampire. Once per turn, you may sacrifice one human crew member from your side of the field to increase the Vampire's ATK and DEF by 20. Once per turn, the Vampire may evade an attack from a human, incapacitating them."

			abomination
				LVL = 9
				ATK = 80
				DEF = 80
				attributes = GRIFFENING_ATTRIBUTE_HANDS | GRIFFENING_ATTRIBUTE_ORGANIC
				card_name = "Shambling Abomination"
				card_data = "Shambling Abomination cannot be destroyed by humans without a non-armor card equipped. At the start of the opponent's turn, you may incapacitate one of your opponent's creatures. When opponent successfully uses the effect of 'Flamethrower', 'Incendiary Grenade' or 'Plasma Fire', reduce DEF by half."

			wraith
				LVL = 8
				ATK = 0
				DEF = 0
				attributes = GRIFFENING_ATTRIBUTE_ETHEREAL
				card_name = "Wraith"
				card_data = "You must sacrifice two human crew members from your side of the field to play Wraith. Wraith can only be killed in combat when under the effects of 'Salt', or by a human wielding 'Ectoplasmic Destabilizer'. When Wraith is attacked, normal HP rules apply even if it's not killed. When Wraith is killed, place it directly in the Gibbed pile. Wraith gains 10 ATK, 10 DEF for every human in your own discard pile."

			atmospherics
				LVL = 1
				ATK = 17
				DEF = 10
				card_name = "Atmospheric Technician"
				card_data = "Once a cornerstone of the station, the improvement of technology has made the Atmospheric Technician obsolete. The life of the Atmospheric Technician solely revolves around getting in bar fights and revolting against the system."

			cyborg
				LVL = 3
				ATK = 30
				DEF = 15
				attributes = GRIFFENING_ATTRIBUTE_LAWS
				card_name = "Cyborg"
				card_data = "Cyborg cannot attack any human unless an effect allows this. When Cyborg enters play, the player may choose to retrieve a Door Bolts card from the deck and place it in his or her hand."

			ai
				LVL = 6
				ATK = 0
				DEF = 40
				attributes = GRIFFENING_ATTRIBUTE_LAWS
				card_name = "AI"
				card_data = "You must sacrifice a human crewmember or a cyborg from your side of the field to play AI. When AI enters play, and at the start of the opponent's turn, all Cyborgs and Robots on the opponent's field are incapacitated. If both players have an AI in play, this effect does not work."

			chief_engineer
				LVL = 5
				ATK = 40
				DEF = 50
				attributes = GRIFFENING_ATTRIBUTE_DEFAULT | GRIFFENING_ATTRIBUTE_HEAD
				card_name = "Chief Engineer"
				card_data = "You must sacrifice an Engineer from your side of the field to play Chief Engineer. During the owner's turn, instead of attacking, the Chief Engineer may discard the area currently in play. This effect cannot be used if the Chief Engineer is incapable of attacking."

			mechanic
				LVL = 4
				ATK = 20
				DEF = 18
				card_name = "Mechanic"
				card_data = "When Mechanic is equipped with any equipment item, you may retrieve an equipment card of the same kind from your deck."

			engineer
				LVL = 6
				ATK = 23
				DEF = 15
				card_name = "Engineer"
				card_data = "An invaluable member of the team, the engineer is the good old fix-it-all. Don't get on his bad side, or you'll have a lot of explaining to do for the peculiar tool-shaped wounds."

			chaplain
				LVL = 1
				ATK = 8
				DEF = 22
				card_name = "Chaplain"
				card_data = "The Chaplain is unaffected by the abilities of Wizards and Vampires. Chaplain cannot be sacrificed to play Vampire."

			botanist
				LVL = 3
				ATK = 16
				DEF = 10
				card_name = "Botanist"
				card_data = "It is said that hippy culture is centered around peace. This begs the question, though - why does this person insist on getting in on every opportunity for a chainsaw on spaceman action."

			janitor
				LVL = 2
				ATK = 14
				DEF = 23
				card_name = "Janitor"
				card_data = "The janitor is weird even by station standards. Thankfully, that's not too disturbing, as he spends most of his time crawling tunnels or hiding in his closet. He's notorious for the acquisition of the lowest quality, most slippery cleaning supplies only."

			chef
				LVL = 1
				ATK = 21
				DEF = 9
				card_name = "Chef"
				card_data = "Some say he's crazy, others hold that he is a culinary genius. Whatever the case may be, one cannot overlook the fact that he cooks people."

			bartender
				LVL = 1
				ATK = 14
				DEF = 12
				card_name = "Bartender"
				card_data = "A friendly face to talk to when your problems are too much to handle. A friendly face to talk to when you long for a cocktail with unparallelled lethality."

			assistant
				LVL = 2
				ATK = 11
				DEF = 6
				card_name = "Staff Assistant"
				card_data = "A run of the mill grayshirt, ready to beat up some spacemen. Nothing compares to the wrath of an assistant."

			lawyer
				LVL = 3
				ATK = 15
				DEF = 8
				card_name = "Lawyer"
				card_data = "While Lawyer is in play, no antagonists on the same side of the field may be attacked by the opponent in battle. While Lawyer is in play, no Security Officer on the same side of the field may attack."

			medical_director
				LVL = 7
				ATK = 28
				DEF = 20
				card_name = "Medical Director"
				card_data = "You must sacrifice a Medical Doctor from your side of the field to play Medical Director. Medical Director provides 20 DEF to each human on the same side of the field."

			roboticist
				LVL = 3
				ATK = 16
				DEF = 14
				card_name = "Roboticist"
				card_data = "A glorified medical doctor, the Roboticist is now nothing more than a premium supplier for the kitchen. Cutting people up is a time-honored tradition - the means never change, but the goals may be distorted."

			geneticist
				LVL = 3
				ATK = 17
				DEF = 11
				card_name = "Geneticist"
				card_data = "Observing a geneticist in battle is a rare sight not many spacemen get to see, and even then, it only takes a slight sting never to see again."

			medical_doctor
				LVL = 2
				ATK = 12
				DEF = 9
				card_name = "Medical Doctor"
				card_data = "Medical Doctors provide the station with state of the art textbook medicine. Unfortunately, the textbook was state of the art at the beginning of the century."

			lich
				randomized_stats = FALSE
				LVL = 10
				ATK = 90
				DEF = 90
				card_name = "Lich"
				card_data = "This card cannot be played normally. Lich cannot be incapacitated."

		friend
			randomized_stats = TRUE
			attributes = GRIFFENING_ATTRIBUTE_NONE

			george_melons
				heart
					card_name = "Heart of George Melons"
					card_data = "This card cannot be played. This card is immediately used if 'George Melons' is played."

				brain
					card_name = "Brain of George Melons"
					card_data = "This card cannot be played. This card is immediately used if 'George Melons' is played."

				skull
					card_name = "Skull of George Melons"
					card_data = "This card cannot be played. This card is immediately used if 'George Melons' is played."

				limbs
					card_name = "Limbs of George Melons"
					card_data = "This card cannot be played. This card is immediately used if 'George Melons' is played."

				card_name = "George Melons"
				card_data = "This card can only be played if the player holds 'Heart of George Melons', 'Brain of George Melons', 'Skull of George Melons' and 'Limbs of George Melons' in his or her hands. When George Melons is played, the player instantly wins."

			beepsky
				card_name = "Officer Beepsky"
				card_data = "While Officer Beepsky is in play, the owner of Officer Beepsky may negate one opponent attack per turn."

			dracula
				attributes = GRIFFENING_ATTRIBUTE_ORGANIC
				card_name = "Dr. Acula"
				card_data = "Dr. Acula gains 20 ATK and 20 DEF while Medical Director is on the same side of the field."

			bee
				attributes = GRIFFENING_ATTRIBUTE_ORGANIC
				card_name = "Greater Domestic Space-Bee"
				card_data = "A spaceman's best friend, the space bee is a genetically engineered variant of terrestrial bee with intelligence comparable to that of assistants'."

				heisenbee
					card_name = "Heisenbee"
					card_data = "Heisenbee is the faithful pet domestic space bee of the Research Director. He lived through many horrors, but never actually seen them, due to his tendency to sleep through the worst of the worst station catastrophes."

			automaton
				card_name = "Automaton"
				card_data = "It whirrs and claks ominously. Nobody knows where it came from, or why it appeared. Some theories suggest it just happened into existence."

			brullbar
				attributes = GRIFFENING_ATTRIBUTE_ORGANIC
				card_name = "Brullbar"
				card_data = "A fearsome creature, living in the shadows of plains and caverns of ice."

				king
					randomized_stats = FALSE
					LVL = 8
					ATK = 75
					DEF = 60
					card_name = "Brullbar King"
					card_data = "You must sacrifice one brullbar from your side of the field to play Brullbar King. Brullbar King sends killed creatures to the gibbed pile instead of the discard pile."

			bear
				attributes = GRIFFENING_ATTRIBUTE_ORGANIC
				card_name = "Space Bear"
				card_data = "Space bears are no less fearsome of their terrestrial cousins. These genetically engineered bears are infused with a nucleic acid derived from methamphetamine, causing their arms to wildly flail at all times."

	effect
		var/card_type = null
		var/targeting = null

		bolts
			card_type = GRIFFENING_TYPE_RESPONSE | GRIFFENING_TYPE_CONTINUOUS
			targeting = GRIFFENING_TARGET_NONE
			card_name = "Door Bolts"
			card_data = "While this card is in play, no area cards may be played. If this card is played face down, you may activate it when the opponent plays an area card to prevent it."

		reagent
			card_type = GRIFFENING_TYPE_INSTANT
			targeting = GRIFFENING_TARGET_ANY_PLAYER | GRIFFENING_TARGET_DISCARDED | GRIFFENING_TARGET_ORGANIC
			card_name = "Strange Reagent"
			card_data = "When used, you may retrieve a killed organic from either player and instantly play it. Gibbed humans cannot be revived this way. This does not count towards the played mob limit."

		hull_breach
			card_type = GRIFFENING_TYPE_CONTINUOUS
			targeting = GRIFFENING_TARGET_NONE
			card_name = "Hull Breach"
			card_data = "While this card is active, reduces DEF of all humans with no spacesuit equipped by 30. At the end of the owner's turn, if any player has an Engineer or Chief Engineer in play, destroy this card."

		disarm
			card_type = GRIFFENING_TYPE_INSTANT | GRIFFENING_TYPE_RESPONSE
			targeting = GRIFFENING_TARGET_OPPONENT_EFFECTS_ROW
			card_name = "Disarm Intent"
			card_data = "When this card is activated, destroy one opponent effect or equipment card. If this card is played face down, you may activate it when the opponent plays an effect or equipment card to prevent it."

		deathgasp
			card_type = GRIFFENING_TYPE_RESPONSE
			targeting = GRIFFENING_TARGET_OWN_CREATURE
			card_name = "Deathgasp"
			card_data = "This card may be activated an opponent's creature attacks one of your creatures. The creature attacked is not destroyed by the attack."

		stimpack
			card_type = GRIFFENING_TYPE_EQUIP
			targeting = GRIFFENING_TARGET_OWN_HUMAN
			card_name = "Stimpack"
			card_data = "The human equipped with this item cannot be incapacitated and gains 30 DEF."

		injector
			card_type = GRIFFENING_TYPE_EQUIP
			targeting = GRIFFENING_TARGET_OWN_HUMAN
			card_name = "Injector Belt"
			card_data = "The human equipped with this card can only be killed in battle by mobs with at least 20 higher ATK than its DEF."

		mindhack
			card_type = GRIFFENING_TYPE_EQUIP
			targeting = GRIFFENING_TARGET_OPPONENT_HUMAN
			card_name = "Mindhack Implant"
			card_data = "This card can only be played if the player has a Traitor or Spy in play. Equip this card to an opponent's human to take control of it. If this card is destroyed, the controlled mob is returned to the opponent."

		motivation
			card_type = GRIFFENING_TYPE_EQUIP
			targeting = GRIFFENING_TARGET_ANY_CREATURE
			card_name = "Motivational Speech"
			card_data = "Equip this card to one creature on the field to transfer it to the opposing side of the field for one turn."

		shockwave
			card_type = GRIFFENING_TYPE_INSTANT
			targeting = GRIFFENING_TARGET_NONE
			card_name = "Shockwave"
			card_data = "When this card is activated, all other equipment and effect cards on the field are returned to their owner's hand."

		knockout_gas
			card_type = GRIFFENING_TYPE_CONTINUOUS
			targeting = GRIFFENING_TARGET_NONE
			card_name = "Knockout Gas"
			card_data = "While this card is active, none of the opponent's mobs may attack. This card is destroyed at the end of the second turn of its effects."

		emp_storm
			card_type = GRIFFENING_TYPE_INSTANT
			targeting = GRIFFENING_TARGET_NONE
			card_name = "EMP Storm"
			card_data = "Activate this card to instantly destroy all robotic friends and reduce the ATK and DEF of all robots by 30 until the end of the turn. This card also destroys all law modules active on the field."

		law
			card_type = GRIFFENING_TYPE_CONTINUOUS
			targeting = GRIFFENING_TARGET_NONE

			no_humans
				card_name = "Law Card: No Humans"
				card_data = "When a law card enters play, all other law cards are instantly destroyed. Humans do not exist, thus robots may attack humans without restriction."

			self_destruct
				card_name = "Law Card: Self-Destruct"
				card_data = "When a law card enters play, all other law cards are instantly destroyed. While this card is active, all robot cards on the field are disassembled."

			no_harm
				card_name = "Law Card: Do No Harm"
				card_data = "When a law card enters play, all other law cards are instantly destroyed. While this card is active, robot cards may not attack."

			card_name = "Law Card: Reset"
			card_data = "When a law card enters play, all other law cards are instantly destroyed. This card is destroyed after it enters play."

		energy_gun
			card_type = GRIFFENING_TYPE_EQUIP
			targeting = GRIFFENING_TARGET_OWN_HUMAN
			card_name = "Energy Gun"
			card_data = "Grants 30 ATK, 15 DEF to the equipped creature."

		robot_frame
			card_type = GRIFFENING_TYPE_INSTANT
			targeting = GRIFFENING_TARGET_OWN | GRIFFENING_TARGET_DISCARDED | GRIFFENING_TARGET_ROBOT
			card_name = "Robot Frame"
			card_data = "When this card is activated, you may retrieve one disassembled cyborg previously owned by either player and place it on your field. Gibbed cyborgs cannot be revived this way. This does not count towards the played mob limit."

		attack_exchange
			card_type = GRIFFENING_TYPE_INSTANT
			targeting = GRIFFENING_TARGET_NONE
			card_name = "Attack Exchange"
			card_data = "When this card is activated, the ATK and DEF of all mobs on the field is exchanged permanently."

		meteor_shower
			card_type = GRIFFENING_TYPE_INSTANT
			targeting = GRIFFENING_TARGET_AREA
			card_name = "Meteor Shower"
			card_data = "The area card currently in play is destroyed. This card can only be used in your own turn."

		stealth_storage
			card_type = GRIFFENING_TYPE_RESPONSE
			targeting = GRIFFENING_TARGET_NONE
			card_name = "Stealth Storage"
			card_data = "This card can only be played face down and activated in response to the opponent playing or activating any card. You may play any effect card which doesn't explicitly specify that it cannot be played during your opponent's turn from your hand."

		radio
			card_type = GRIFFENING_TYPE_EQUIP
			targeting = GRIFFENING_TARGET_OWN_HUMAN
			card_name = "Radio"
			card_data = "When the human equipped with this card is killed or gibbed, you may choose any LVL 4 or lower mob or friend from your deck and put it in your hand. Shuffle your deck afterwards."

		thermals
			card_type = GRIFFENING_TYPE_INSTANT
			targeting = GRIFFENING_TARGET_NONE
			card_name = "Optical Thermal Scanner"
			card_data = "When this card is played, the opponent must present you his or her hand and all face down cards on the field."

		cyalume_saber
			card_type = GRIFFENING_TYPE_EQUIP
			targeting = GRIFFENING_TARGET_OWN_HUMAN | GRIFFENING_TARGET_SYNDICATE
			card_name = "Cyalume Saber"
			card_data = "This is a syndicate equipment card. Syndicate equipment can only be wielded by traitors, spies or nuclear operatives unless otherwise specified. Increases the wielder's ATK by 40."

		fake_357
			card_type = GRIFFENING_TYPE_EQUIP
			targeting = GRIFFENING_TARGET_ANY_HUMAN
			card_name = "Fake .357"
			card_data = "This card can be equipped on either your or one of your opponents' humans. If the human wielding this card attacks, it dies instead."

		toolbox
			card_type = GRIFFENING_TYPE_EQUIP
			targeting = GRIFFENING_TARGET_OWN_HUMAN
			card_name = "Toolbox"
			card_data = "Increases the ATK of the wielder by 10."

		fire_extinguisher
			card_type = GRIFFENING_TYPE_EQUIP | GRIFFENING_TYPE_RESPONSE
			targeting = GRIFFENING_TARGET_OWN_HUMAN
			card_name = "Fire Extinguisher"
			card_data = "Increases the wielder's ATK by 20. This card counters the effects of 'Plasma Fire', 'Incendiary Grenade' and 'Flamethrower'. When used to counter an effect, immediately destroy both cards. This card may be placed face down and activated in response to a countered card."

		wet_floor
			card_type = GRIFFENING_TYPE_RESPONSE
			targeting = GRIFFENING_TARGET_OPPONENT_HUMAN
			card_name = "Wet Floor"
			card_data = "This card can only be played face down and activated in response to a human attacking. The attack is immediately concluded."

		adminhelp
			card_type = GRIFFENING_TYPE_RESPONSE
			targeting = GRIFFENING_TARGET_OPPONENT_EFFECTS_ROW
			card_name = "Adminhelp"
			card_data = "This card can only be played face down and activated in response to any effect or equipment card being activated. The effect or equipment card is instantly destroyed without its effects activating."

		wbelt
			card_type = GRIFFENING_TYPE_EQUIP
			targeting = GRIFFENING_TARGET_OWN_HUMAN | GRIFFENING_TARGET_SYNDICATE
			card_name = "Wrestling Belt"
			card_data = "This is a syndicate equipment card. Syndicate equipment can only be wielded by traitors, spies or nuclear operatives unless otherwise specified. Increases the wielder's ATK and DEF by 20."

		supply_shuttle
			card_type = GRIFFENING_TYPE_INSTANT
			targeting = GRIFFENING_TARGET_NONE
			card_name = "Supply Shuttle"
			card_data = "When activated, both players must draw cards until they both have 6 cards in their hands."

		uplink
			card_type = GRIFFENING_TYPE_INSTANT
			targeting = GRIFFENING_TARGET_NONE
			card_name = "Radio Uplink"
			card_data = "When this card is played, the player may search his or her deck for any one effect or equipment card. The card is put in the player's hand. The deck must be shuffled afterwards."

		abandoned_crate
			card_type = GRIFFENING_TYPE_INSTANT
			targeting = GRIFFENING_TARGET_NONE
			card_name = "Abandoned Crate"
			card_data = "Discard any card. When this card is played, the player may draw two new cards."

		surplus_crate
			card_type = GRIFFENING_TYPE_INSTANT
			targeting = GRIFFENING_TARGET_NONE
			card_name = "Surplus Crate"
			card_data = "When this card is played, the player may draw three new cards, choose one to keep and discard the other two."

		telescience
			card_type = GRIFFENING_TYPE_INSTANT
			targeting = GRIFFENING_TARGET_NONE
			card_name = "Telescientist"
			card_data = "When this card is played, view the opponent's hand, pick a card, and discard it."

		deconstructor
			card_type = GRIFFENING_TYPE_RESPONSE
			targeting = GRIFFENING_TARGET_OPPONENT_FIELD
			card_name = "Deconstructor"
			card_data = "This card can only be played face down and activated in response to any card being played or activated by the opponent. Destroy the triggering card and all copies of that card in the opponent's hand and deck."

		engine_sabotage
			card_type = GRIFFENING_TYPE_CONTINUOUS
			targeting = GRIFFENING_TARGET_NONE
			card_name = "Engine Sabotage"
			card_data = "While this card is active, all area effects are negated. This card does not affect an active 'Emergency Shuttle', but 'Emergency Shuttle' cannot be played while this card is active."

		handcuffs
			card_type = GRIFFENING_TYPE_EQUIP
			targeting = GRIFFENING_TARGET_OPPONENT_HUMAN
			card_name = "Handcuffs"
			card_data = "This card can only be equipped on an opponent human. While this card is equipped, the human cannot attack. This card is removed at the end of the third turn of the owner of the human."

		incendiary_grenade
			card_type = GRIFFENING_TYPE_EQUIP | GRIFFENING_TYPE_FIRE
			targeting = GRIFFENING_TARGET_OWN_HUMAN
			card_name = "Incendiary Grenade"
			card_data = "When a mob wielding this item attacks, all opponent critters with 30 DEF or less are instantly killed. All other opponent organics and critters lose 30 DEF until the end of your turn."

		firefighting_grenade
			card_type = GRIFFENING_TYPE_RESPONSE
			targeting = GRIFFENING_TARGET_OPPONENT_EFFECTS_ROW
			card_name = "Firefighting Grenade"
			card_data = "This card may be played in response to 'Flamethrower', 'Plasma Fire' and 'Incendiary Grenade'. Instantly destroy both cards. When this card is activated, the opponent's turn immediately ends."

		plasma_fire
			card_type = GRIFFENING_TYPE_CONTINUOUS
			targeting = GRIFFENING_TARGET_NONE
			card_name = "Plasma Fire"
			card_data = "When this card is played, instantly reduce the DEF of all opponent humans and critters by 10. While this card is active, all opponent humans and critters lose 20 DEF at the start of their owner's turn. If a creature reaches 0 DEF due to the effects of this card, the creature is killed. If any area cards are played while Plasma Fire is active, discard Plasma Fire."

		authentication_disk
			card_type = GRIFFENING_TYPE_INSTANT
			targeting = GRIFFENING_TARGET_NONE
			card_name = "Authentication Disk"
			card_data = "This card can only be activated while Captain is on the field. If the Captain is on your side of the field, you may immediately play a Security Officer from your hand. If the Captain is on the opposite side of the field, you may immediately play a Nuclear Operative from your hand. This does not count against the played mob limit."

		pinpointer
			card_type = GRIFFENING_TYPE_INSTANT
			targeting = GRIFFENING_TARGET_NONE
			card_name = "Pinpointer"
			card_data = "When activated, you may take an 'Authentication Disk' from either player's discard pile or your own deck and put it in your hand."

		matter_eater
			card_type = GRIFFENING_TYPE_INSTANT
			targeting = GRIFFENING_TARGET_EQUIP | GRIFFENING_TARGET_ANY_PLAYER
			card_name = "Matter Eater"
			card_data = "When this card is played, choose one face up equipment card to destroy. The destroyed equipment card is placed in the gibbed deck."

		space_suit
			card_type = GRIFFENING_TYPE_EQUIP | GRIFFENING_TYPE_ARMOR
			targeting = GRIFFENING_TARGET_OWN_HUMAN
			card_name = "Space Suit"
			card_data = "This is an armor card. A human may only be equipped with a single armor at any given time. While equipped, the equipped human is immune to the effects of 'Hull Breach' and 'Freezer'. Increases DEF by 10."

		dna_absorbtion
			card_type = GRIFFENING_TYPE_INSTANT
			targeting = GRIFFENING_TARGET_NONE
			card_name = "DNA Absorbtion"
			card_data = "This card can only be played if any 'Changeling' card is on your side of the field. You may immediately discard one human from the opponent's side of the field. If a human was discarded, you may replace your 'Changeling' with 'Shambling Abomination' from your hand or deck."

		crematorium
			card_type = GRIFFENING_TYPE_INSTANT
			targeting = GRIFFENING_TARGET_DISCARD | GRIFFENING_TARGET_ANY_PLAYER
			card_name = "Crematorium"
			card_data = "When this card is played, place 5 cards from the discard pile of either player to their gibbed pile."

		flamethrower
			card_type = GRIFFENING_TYPE_EQUIP
			targeting = GRIFFENING_TARGET_OWN_HUMAN
			card_name = "Flamethrower"
			card_data = "When attacking a humanoid using 'Flamethrower', reduce their DEF by 30 before attacking. If target humanoid is Changeling, destroy Changeling without battle. If target humanoid is Shambling Abomination, reduce their DEF by half instead."

		salt
			card_type = GRIFFENING_TYPE_INSTANT | GRIFFENING_TYPE_RESPONSE
			targeting = GRIFFENING_TARGET_NONE
			card_name = "Salt"
			card_data = "When used, all ethereal mobs become corporeal until the end of the turn. This card may be played face down and activated in response to an attack."

		ghostgun
			card_type = GRIFFENING_TYPE_EQUIP
			targeting = GRIFFENING_TARGET_OWN_HUMAN
			card_name = "Ectoplasmic Destabilizer"
			card_data = "While equipped, the wielder can kill ethereal beings. Attacks to corporeal beings have no effect."

		abductor
			card_type = GRIFFENING_TYPE_EQUIP | GRIFFENING_TYPE_RESPONSE
			targeting = GRIFFENING_TARGET_ANY_CREATURE
			card_name = "Abductor"
			card_data = "Equip this card onto any creature on the field. The creature is taken out of battle until Abductor is destroyed. Creatures out of battle are on the field, but cannot attack, defend or be attacked. This card may be played face down and activated in response to an opponent attacking."

		lucky_horseshoe
			card_type = GRIFFENING_TYPE_INSTANT | GRIFFENING_TYPE_RESPONSE
			targeting = GRIFFENING_TARGET_ANY_CREATURE
			card_name = "Lucky Horseshoe"
			card_data = "When activated, roll a D6. The ATK and DEF of a selected creature is increased by twice the number rolled until the end of the current turn. This card may be played face down and activated in response to an opponent attacking."

		haloperidol_dart
			card_type = GRIFFENING_TYPE_INSTANT | GRIFFENING_TYPE_RESPONSE
			targeting = GRIFFENING_TARGET_ANY_CREATURE
			card_name = "Haloperidol Dart"
			card_data = "When activated, roll a D6. The ATK and DEF of a selected creature is decreased by twice the number rolled until the end of the current turn. This card may be played face down and activated in response to an opponent attacking."

		beemom
			card_type = GRIFFENING_TYPE_RESPONSE
			targeting = GRIFFENING_TARGET_NONE
			card_name = "Bee Mom"
			card_data = "This card can only be played face down and activated in response to the opponent attacking. You may redirect the opponent's attack to any bee on your side of the field."

		stun_baton
			card_type = GRIFFENING_TYPE_EQUIP
			targeting = GRIFFENING_TARGET_OWN_HUMAN
			card_name = "Stun Baton"
			card_data = "A human with a stun baton equipped may incapacitate any creature on the field when attacking, without HP penalty. The stun baton is discarded after three attacks."

		power_axe
			card_type = GRIFFENING_TYPE_EQUIP
			targeting = GRIFFENING_TARGET_OWN_HUMAN
			card_name = "Power Axe"
			card_data = "You must sacrifice one human crew member in order to summon the Power Axe. When equipped, it provides the wielder with 40 ATK and 20 DEF."

		riot_launcher
			card_type = GRIFFENING_TYPE_EQUIP
			targeting = GRIFFENING_TARGET_OWN_HUMAN
			card_name = "Riot Launcher"
			card_data = "When a mob equipped with a Riot Launcher attacks, all non-armor items equipped on the target are discarded. The riot launcher is discarded after use."

		telekinesis
			card_type = GRIFFENING_TYPE_INSTANT | GRIFFENING_TYPE_RESPONSE
			targeting = GRIFFENING_TARGET_OPPONENT_EQUIP
			card_name = "Telekinesis"
			card_data = "When activated, Telekinesis allows you to take any equipment cards from the opponent's field and equip it onto one of your own creatures. This card may be played face down and activated in response to an opponent activating an equipment card or attacking."

		spectral_emission
			card_type = GRIFFENING_TYPE_INSTANT
			targeting = GRIFFENING_TARGET_NONE
			card_name = "Spectral Emission"
			card_data = "When this card is activated, neither you, nor your opponent may attack until the start of your next turn."

		chaos_dunk
			card_type = GRIFFENING_TYPE_INSTANT
			targeting = GRIFFENING_TARGET_NONE
			card_name = "Chaos Dunk"
			card_data = "This card may only be activated if 'Basketball' is on your side of the field. Destroy all creatures on the field and end your turn immediately."

		basketball
			card_type = GRIFFENING_TYPE_EQUIP
			targeting = GRIFFENING_TARGET_OWN_HUMAN
			card_name = "Basketball"
			card_data = "When a human equipped with basketball attacks an opponent wielding a non-armor equipment item, discard the equipment item. If the opponent creature is not wielding such an item, Basketball is transferred to the opponent's hand."

		rpg
			card_type = GRIFFENING_TYPE_EQUIP
			targeting = GRIFFENING_TARGET_OWN_HUMAN
			card_name = "RPG"
			card_data = "When a human equipped with RPG attacks and kills an opposing creature, the creature is transferred to the gibbed pile instead of the discard pile. RPG increases the ATK of the wielder by 10 but reduces the DEF of the wielder by 10."

		derringer
			card_type = GRIFFENING_TYPE_EQUIP | GRIFFENING_TYPE_SWIFT
			targeting = GRIFFENING_TARGET_OWN_HUMAN | GRIFFENING_TARGET_SYNDICATE
			card_name = "Derringer"
			card_data = "This is a syndicate equipment card. Syndicate equipment can only be wielded by traitors, spies or nuclear operatives unless otherwise specified. This card allows swift play, equipping it when a creature is attacking or being attacked out of turn, from your hand. Increases the ATK and DEF of the wielder by 10."

		artistic_toolbox
			card_type = GRIFFENING_TYPE_EQUIP
			targeting = GRIFFENING_TARGET_OWN_HUMAN | GRIFFENING_TARGET_SYNDICATE
			card_name = "Artistic Toolbox"
			card_data = "You must sacrifice one human crew member from your side of the field to activate this card. When equipped, the wielder cannot be incapacitated. When a human is killed by a human wielding the Artistic Toolbox, it is transferred to the gibbed pile. Artistic Toolbox provides 10 ATK, 10 DEF to the wielder for each human in the opponent's gibbed pile. Every two turns, at the start of the owner's turn, the owner of the Artistic Toolbox must sacrifice a human from the own side of their field, or send the wielder and the Artistic Toolbox to the gibbed pile."

		vuvuzela
			card_type = GRIFFENING_TYPE_INSTANT
			targeting = GRIFFENING_TARGET_NONE
			card_name = "Vuvuzela"
			card_data = "When Vuvuzela is played, the owner may immediately place up to two Staff Assistants on the field from their hand. This effect does not count against the played creature limit."

		mutiny
			card_type = GRIFFENING_TYPE_INSTANT
			targeting = GRIFFENING_TARGET_NONE
			card_name = "Mutiny"
			card_data = "You must sacrifice a human from your side of the playing field to play this card. The opponent must have Captain face up on their side of the field to play this card. Discard the opponent's Captain card and play a Captain card from your hand. This effect does not count against the played creature limit. This card allows you to play Captain even if any Nuclear Operatives are on your side of the field."

		crown
			card_type = GRIFFENING_TYPE_EQUIP
			targeting = GRIFFENING_TARGET_OWN_HUMAN
			card_name = "Obsidian Crown"
			card_data = "Every turn, the owner of the wielder must pay 5 HP at the start of their turn. At the start of each turn, reduce the DEF by of the wielder by 10. Provides the wielder with 30 ATK and 20 DEF. If the wielder's DEF reaches 0 or is killed in battle under the effects of Obsidian Crown and Ancient Armor is not equipped, send wielder to the gibbed pile and return Obsidian Crown to the owner's hand. If both items are equipped and wielder is not gibbed by the killing blow, the owner of the wielder may immediately play Lich from their deck or hand. Obsidian Crown remains on the field while the created Lich is on the field, but does not affect Lich."

		ancient
			card_type = GRIFFENING_TYPE_EQUIP | GRIFFENING_TYPE_ARMOR
			targeting = GRIFFENING_TARGET_OWN_HUMAN
			card_name = "Ancient Armor"
			card_data = "Provides the wielder with 20 DEF. At the start of the wielder's owner's turn, reduce the DEF of the wielder by 10 unless Obsidian Crown is also equipped on the wielder. If Lich is created due to the effects of Obsidian Crown and Ancient Armor, Ancient Armor remains on the field, but does not affect Lich."

		wizard_hat
			card_type = GRIFFENING_TYPE_EQUIP
			targeting = GRIFFENING_TARGET_OWN_HUMAN
			card_name = "Wizard Hat"
			card_data = "When wielded by Wizard together with Wizard Robe, it provides 20 ATK, 20 DEF."

		wizard_robe
			card_type = GRIFFENING_TYPE_EQUIP | GRIFFENING_TYPE_ARMOR
			targeting = GRIFFENING_TARGET_OWN_HUMAN
			card_name = "Wizard Robe"
			card_data = "When wielded by Wizard together with Wizard Hat, it provides 20 ATK, 20 DEF."

		wizard_staff
			card_type = GRIFFENING_TYPE_EQUIP
			targeting = GRIFFENING_TARGET_OWN_HUMAN
			card_name = "Wizard Staff"
			card_data = "Provides the wielder with 10 ATK, 10 DEF."

		maniac
			card_type = GRIFFENING_TYPE_INSTANT
			targeting = GRIFFENING_TARGET_ANY_CREATURE
			card_name = "The Axe Maniac"
			card_data = "The axe maniac instantly gibs one selected creature on the field."

		reinforced_steel
			card_type = GRIFFENING_TYPE_EQUIP | GRIFFENING_TYPE_ARMOR
			targeting = GRIFFENING_TARGET_OWN | GRIFFENING_TARGET_CYBORG
			card_name = "Reinforced Steel"
			card_data = "This is an armor card. A cyborg may only be equipped with a single armor at any given time. Equip this card onto a cyborg to increase its ATK by 10 and DEF by 20."

		heavy_steel
			card_type = GRIFFENING_TYPE_EQUIP | GRIFFENING_TYPE_ARMOR
			targeting = GRIFFENING_TARGET_OWN | GRIFFENING_TARGET_CYBORG
			card_name = "Heavy Steel"
			card_data = "This is an armor card. A cyborg may only be equipped with a single armor at any given time. Equip this card onto a cyborg to increase its ATK by 20 and DEF by 40."

		speed_upgrade
			card_type = GRIFFENING_TYPE_EQUIP
			targeting = GRIFFENING_TARGET_OWN | GRIFFENING_TARGET_CYBORG
			card_name = "Speed Upgrade"
			card_data = "When equipped with Speed Upgrade, a cyborg may evade a single attack once per two turns. If used, the cyborg becomes incapacitated for one turn."

		coordinated_assault
			card_type = GRIFFENING_TYPE_INSTANT
			targeting = GRIFFENING_TARGET_OPPONENT_CREATURE
			card_name = "Coordinated Assault"
			card_data = "When this card is played, all creatures on your side of the field who did not attack during the turn pool their ATK into a single attack with the force of the sum of the ATK of those creatures. If the attack succeeds, but the opponent creature has a higher DEF than the combined ATK, all your involved creatures are discarded. This card may only be played during your turn."

		module
			card_type = GRIFFENING_TYPE_EQUIP
			targeting = GRIFFENING_TARGET_OWN | GRIFFENING_TARGET_CYBORG
			card_name = "Standard Module"
			card_data = "This is a cyborg module card. Only one cyborg module can be equipped to a cyborg at any given time. During your own turn, you may retrieve any module card from your side of the field into your hand. While a module card is equipped onto a cyborg, it counts as the job specified by the module card for all effects involving jobs. This module bestows the job of Staff Assistant."

			engineering
				card_name = "Engineering Module"
				card_data = "This is a cyborg module card. Only one cyborg module can be equipped to a cyborg at any given time. During your own turn, you may retrieve any module card from your side of the field into your hand. While a module card is equipped onto a cyborg, it counts as the job specified by the module card for all effects involving jobs. This module bestows the job of Engineer."

			medical
				card_name = "Medical Module"
				card_data = "This is a cyborg module card. Only one cyborg module can be equipped to a cyborg at any given time. During your own turn, you may retrieve any module card from your side of the field into your hand. While a module card is equipped onto a cyborg, it counts as the job specified by the module card for all effects involving jobs. This module bestows the job of Medical Doctor."

			brobot
				card_name = "Bro Bot Module"
				card_data = "This is a cyborg module card. Only one cyborg module can be equipped to a cyborg at any given time. During your own turn, you may retrieve any module card from your side of the field into your hand. While a module card is equipped onto a cyborg, it counts as the job specified by the module card for all effects involving jobs. This module bestows the job of Clown."

			chemistry
				card_name = "Chemistry Module"
				card_data = "This is a cyborg module card. Only one cyborg module can be equipped to a cyborg at any given time. During your own turn, you may retrieve any module card from your side of the field into your hand. While a module card is equipped onto a cyborg, it counts as the job specified by the module card for all effects involving jobs. This module bestows the job of Scientist."

	area
		var/field_icon_state = null

		engineering
			card_name = "Engineering"
			card_data = "All engineering crew gain 15 ATK, 15 DEF while active. Roll D6 when an engineer or chief engineer is killed, if 2 or less, remove this card from play."
			field_icon_state = "engineering"

		medbay
			card_name = "Medical Bay"
			card_data = "All human crew on the field gain 25 DEF while active. Human crew killed while friendly medical personnel is in play returns to play incapacitated, unable to attack that turn. Incapacitated medical crew cannot save other human."
			field_icon_state = "medbay"

		genetics
			card_name = "Genetics"
			card_data = "When Genetics enters play, the player who placed the card may retrieve a killed human from either player into his hand. On turn start, all geneticists on the field gain 10 ATK, 10 DEF."
			field_icon_state = "genetics"

		robotics
			card_name = "Robotics"
			card_data = "While Robotics is in play, all robots gain 20 ATK, 10 DEF. If a human is killed while this card is active, the owner may take any robot into his hand from his deck, then shuffle the deck."
			field_icon_state = "robotics"

		void
			card_name = "The Void"
			card_data = "While the void is in play, all newly played humans lose half their ATK and DEF. Each player loses 5 HP at the beginning of their turn."
			field_icon_state = "void"

		chapel
			card_name = "Chapel"
			card_data = "When the Chapel is played, all ethereal mobs and vampires are destroyed. No ethereal mobs or vampires may be played while the Chapel is in play. All wizards lose 30 ATK and 30 DEF. The chaplain gains 20 ATK for each card destroyed while the chapel is in play."
			field_icon_state = "chapel"

		syndicate
			card_name = "Syndicate Shuttle"
			card_data = "When the syndicate shuttle enters play, each player may draw 2 cards for each operative or traitor in play. The player who played the card may equip any human crew with syndicate items. When this card leaves play, kill all human mobs on the owner's side of the field."
			field_icon_state = "syndicate"

		upload
			card_name = "AI Upload"
			card_data = "While AI Upload and an AI is in play, no human or robot may attack if the AI is not on their side of the field. While this card is active, the AI gains 120 DEF. If a law card is played while the AI is on the field, move the AI to the player's side of the field. If the AI is killed, this card destroyed."
			field_icon_state = "upload"

		bridge
			card_name = "Bridge"
			card_data = "While Bridge is in play, heads of staff can only be attacked by other heads of staff, unless the AI is on the attacker's side of the field. All heads of staff gain 15 ATK, 15 DEF."
			field_icon_state = "bridge"

		cafeteria
			card_name = "Cafeteria"
			card_data = "While this card is in play, all assistants, the bartender and the chef gain 10 ATK, 10 DEF. If the Bartender enters play while this card is active, or the Bartender is in play when this card is played, the Bartender's owner may play one Riot Shotgun from his deck, then shuffle his deck."
			field_icon_state = "cafeteria"

		kitchen
			card_name = "Kitchen"
			card_data = "While Kitchen and the Chef is in play, destroy one of your opponent item's at the start of your turn. Humans killed while the Kitchen is in play cannot be revived through any means. The Chef gains 20 ATK, 20 DEF."
			field_icon_state = "kitchen"

		security
			card_name = "Security"
			card_data = "While Security is in play, Security Officers and Head of Security can incapacitate foes with higher DEF than their ATK when attacking them, preventing them from attacking. This card cannot be played while Lawyer is in play. If Lawyer enters play, destroy this card."
			field_icon_state = "security"

		cargobay
			card_name = "Cargo Bay"
			card_data = "While Cargo Bay is in play, each player may draw one additional card for each Quartermaster in play on their side of the field."
			field_icon_state = "cargobay"

		customs
			card_name = "Customs"
			card_data = "When Customs and Head of Personnel are in play, the player who owns Head of Personnel may permanently change the job assignment of any normal, non-head crew member to any other non-head job once per turn at the start of the turn."
			field_icon_state = "customs"

		shuttle
			card_name = "Emergency Shuttle"
			card_data = "While Emergency Shuttle is in play, no equipment cards may be in play. At the start of the 11th turn after Emergency Shuttle was played, if Emergency Shuttle is still in play, the player who played it automatically wins. Emergency Shuttle cannot be played unless the player has a head of staff or the AI on the field."
			field_icon_state = "shuttle"

#undef GRIFFENING_TARGET_OWN_HUMAN
#undef GRIFFENING_TARGET_OPPONENT_HUMAN
#undef GRIFFENING_TARGET_OWN_FIELD
#undef GRIFFENING_TARGET_OPPONENT_FIELD
#undef GRIFFENING_TARGET_ANY_FIELD
#undef GRIFFENING_TARGET_OPPONENT_EFFECTS_ROW
#undef GRIFFENING_TARGET_OPPONENT_EQUIP
#undef GRIFFENING_TARGET_ANY_DISCARD
#undef GRIFFENING_TARGET_ANY_AREA
#undef GRIFFENING_TARGET_OWN_CREATURE
#undef GRIFFENING_TARGET_OPPONENT_CREATURE
#undef GRIFFENING_TARGET_ANY_CREATURE
#undef GRIFFENING_TARGET_OWN_DISCARDED_CREATURE
#undef GRIFFENING_TARGET_ANY_DISCARDED_CREATURE
#undef GRIFFENING_TARGET_ANY_HUMAN
