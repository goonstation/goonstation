## About the DM side API
This is written from the understanding of Tyrant, who is not an API developer. Some things may be slightly wrong.

Useful links:
Goonhub API docs: https://staging.goonhub.com/docs/api#/
Event tracking docs: https://staging.goonhub.com/docs/events/1.0/overview

### Endpoints and apiRoutes
Endpoints are the ways that the API communicates, and they contain routes. The routes contain several vars:

A route can have one of four method types:
- `GET` Which checks information.
- `POST` Which adds new information.
- `PUT` Which updates/overwrites existing information.
- `DELETE` Which removes information.
These are specified in the `method` var using defines.

Each route has a path which it connects to as well, for instance https://staging.goonhub.com/api
**/bans**. This is specified in the form of a string in the `path` var.

Path parameters are stored in the `routeParams` var. These are used when the path ends with a variable, for instance, `https://staging.goonhub.com/api/bans/{ban}`, which has the path parameter `{ban}`.

Query parameters send extra information when connecting, stored in `queryParams`. This is usually a list of strings, for instance, `queryParams = list("filters", "sort_by", "descending", "per_page")`.

The request body (`body` var) is what is sent through the connection. These are usually in the form of a `/datum/apiBody`, which are in the requests folder in the repo. More information is in the following sections.

The response model (`correct_response` var) is what is sent back. These are in the form of a `/datum/apiModel`, which are in the models folder in the repo. More information is in the following sections.

A Template for API endpoint routes:
```dm
/// [method type e.g. POST] [path e.g. /players/notes]
/// [reference to the name of the file or what it does, e.g. Add]
//datum/apiRoute/[path of route]
	method = RUSTG_HTTP_METHOD_[method type]
	path = "[the path of the endpoint it connects to]"
	routeParams = list([list of parameter items, separated by commas]) // [the primitive type of each parameter]
	queryParams = list([list of parameter items, separated by commas]) // [the primitive type of each parameter]
	body = [the datum of the body, under /datum/apiBody]
	correct_response = [the datum of the model, under datum/apiModel]

// A proper example:

/// PUT /bans/{ban}
/// Update
/datum/apiRoute/bans/update
	method = RUSTG_HTTP_METHOD_PUT
	path = "/bans"
	routeParams = list("ban")	// integer
	body = /datum/apiBody/bans/add
	correct_response = /datum/apiModel/Tracked/BanResource
```

The reason why the API files are formatted this way is so that "it's optimized so you can just copypaste stuff and change it via column/vertical select" ~ZeWaka.

Other notes:
- the path should start with slash.
- not all methods require all the vars. In fact, some are mutually exclusive.
- If the apiBody or apiModel doesn't exist, make it. Don't try to just shove a list of strings in; it won't work.

#### Making your own apiRoute's
The list of what to make and how it works is at https://staging.goonhub.com/docs/api, along with the request body and response model needed. They need to match the `apiRoute` in order for the API to work correctly.
- Under request, the parameters should match in the form of a list of strings matching the parameter names. If it says query parameters, use `queryParams`, if it says path parameters, use `routeParams`.
- If the path ends with something like `/{kind of routeParam}`, you don't include it in `src.path`. It gets appended automatically later on by the routeParams.
- The request body should match an `apiBody`.
- The response body should match an `apiModel`.
- If the above two don't have matching ones, you have to make them.
- If you're making new files, follow the format of existing names.

### Request bodies and apiBody
todo

### Response models and apiModel
todo
