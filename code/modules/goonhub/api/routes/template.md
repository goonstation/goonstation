this file is not actually used, it is an instruction.

template:
```dm
/// [method type e.g. POST] [path e.g. /players/notes]
/// [reference to the name of the file or what it does, e.g. Add]
//datum/apiRoute/[path of route]
	method = RUSTG_HTTP_METHOD_[method type]
	path = "[the path of the staging endpoint it connects to]"
	parameters = list([list of parameter items, separated by commas]) // [the primitive type of each parameter]
	body = [the datum of the body, under /datum/apiBody]
	correct_response = [the datum of the model, under datum/apiModel]
	```

Other notes:
- the path should start with slash
- not all methods require all three of the `parameters`/`body`/`correct_response``.
- If the apiBody or apiModel doesn't exist, make it.
- list of what to make is at https://staging.goonhub.com/docs/api, along with body and model needed.
	- On the OpenAPI docs linked above, there are some details that need to match
	- Under request, the parameters should match (in the form of a list of strings matching the parameter names), as should the body (in the form of a `/datum/apiBody`)
	- Under responses, the name of the apiModel used should be there. If it isn't, just use `list("[name of field]")`

A proper example:
```dm
/// POST /players/notes
/// Add
/datum/apiRoute/players/notes/post
	method = RUSTG_HTTP_METHOD_POST
	path = "/players/notes"
	body = /datum/apiBody/players/notes/post
	correct_response = /datum/apiModel/Tracked/PlayerRes/PlayerNoteResource
```
