// TRIGGERS

/datum/artifact_trigger
	var/stimulus_required = null
	var/do_amount_check = 1
	var/stimulus_amount = null
	var/stimulus_type = ">="
	var/hint_range = 0
	var/hint_prob = 33

/datum/artifact_trigger/carbon_touch
	// touched by a carbon lifeform
	stimulus_required = "carbtouch"
	do_amount_check = 0

/datum/artifact_trigger/silicon_touch
	// touched by a silicon lifeform
	stimulus_required = "silitouch"
	do_amount_check = 0

/datum/artifact_trigger/force
	stimulus_required = "force"
	hint_range = 20
	hint_prob = 75

	New()
		..()
		stimulus_amount = rand(3,30)

/datum/artifact_trigger/heat
	stimulus_required = "heat"
	hint_range = 20

	New()
		..()
		stimulus_amount = rand(320,400)

/datum/artifact_trigger/cold
	stimulus_required = "heat"
	stimulus_type = "<="
	hint_range = 20

	New()
		..()
		stimulus_amount = rand(200,300)

/datum/artifact_trigger/radiation
	stimulus_required = "radiate"
	hint_range = 2
	hint_prob = 75

	New()
		..()
		stimulus_type = pick(">=","<=")
		stimulus_amount = rand(1,10)

/datum/artifact_trigger/electric
	stimulus_required = "elec"
	hint_range = 500
	hint_prob = 66

	New()
		..()
		stimulus_type = pick(">=","<=")
		stimulus_amount = rand(5,5000)

/datum/artifact_trigger/reagent
	stimulus_required = "reagent"
	// can just use the above var as the required reagent field really
	stimulus_type = ">="
	hint_range = 50
	hint_prob = 100

	New()
		..()
		stimulus_amount = rand(10,100)

/datum/artifact_trigger/reagent/blood
	stimulus_required = "blood"

/datum/artifact_trigger/data
	// touched by something that contains data (circuit board, disks) etc.
	stimulus_required = "data"
	do_amount_check = 0
