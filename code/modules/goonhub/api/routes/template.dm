/* this file is not actually used, it is an instruction.

template:
/// [method type e.g. POST] [path e.g. /players/notes]
/// [reference to the name of the file, e.g. Add]
//datum/apiRoute/[path of the api route]
	method = RUSTG_HTTP_METHOD_[the method in question]
	path = "[the path of the staging it connects to]"
	parameters = list([list of parameter items, separated by commas]) // [the primitive type of each parameter]
	body = [the datum of the body, under /datum/apiBody]
	correct_response = [the datum of the model, under datum/apiModel]

Other notes:
- the path should start with slash
- not all methods require all of parameters/body/correct_response.
- If the apiBody or apiModel doesn't exist, make it.
- list of what to make is at https://staging.goonhub.com/docs/api, along with body and model needed

A proper example:
/// POST /players/notes
/// Add
/datum/apiRoute/players/notes/post
	method = RUSTG_HTTP_METHOD_POST
	path = "/players/notes"
	body = /datum/apiBody/players/notes/post
	correct_response = /datum/apiModel/Tracked/PlayerRes/PlayerNoteResource

*/
