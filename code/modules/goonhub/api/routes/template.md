Template for API endpoint routes:
```dm
/// [method type e.g. POST] [path e.g. /players/notes]
/// [reference to the name of the file or what it does, e.g. Add]
//datum/apiRoute/[path of route]
	method = RUSTG_HTTP_METHOD_[method type]
	path = "[the path of the staging endpoint it connects to]"
	routeParams = list([list of parameter items, separated by commas]) // [the primitive type of each parameter]
	queryParams = list([list of parameter items, separated by commas]) // [the primitive type of each parameter]
	body = [the datum of the body, under /datum/apiBody]
	correct_response = [the datum of the model, under datum/apiModel]
```

Other notes:
- the path should start with slash
- not all methods require all three of the `routeParams`/`queryParams`/`body`/`correct_response`.
- If the apiBody or apiModel doesn't exist, make it.
- list of what to make is at https://staging.goonhub.com/docs/api, along with body and model needed.
	- On the OpenAPI docs linked above, there are some details that need to match
	- Under request, the parameters should match in the form of a list of strings matching the parameter names. If it says query parameters, use `queryParams`, if it says path parameters, use `routeParams`.
	- Under request, the body should also match (in the form of a `/datum/apiBody`).
	- Under responses, the name of the apiModel used should be there. If it isn't, just use `list("[name of field]")`.
- The reason why the API files are formatted this way is so that "it's optimized so you can just copypaste stuff and change it via column/vertical select" ~ZeWaka.

A proper example:
```dm
/// PUT /bans/{ban}
/// Update
/datum/apiRoute/bans/update
	method = RUSTG_HTTP_METHOD_PUT
	path = "/bans/{ban}"
	routeParams = list("ban")	// integer
	body = /datum/apiBody/bans/add
	correct_response = /datum/apiModel/Tracked/BanResource
```
