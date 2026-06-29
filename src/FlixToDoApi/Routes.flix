pub mod FlixToDoApi.Routes {
    use FlixToDoApi.Db
    use FlixToDoApi.Input
    use FlixToDoApi.Lib.Http.Body
    use FlixToDoApi.Lib.Http.Method
    use FlixToDoApi.Lib.Http.Request.Request
    use FlixToDoApi.Lib.Http.Response
    use FlixToDoApi.Lib.Http.Response.Status
    use FlixToDoApi.Lib.Http.Route.Route
    use FlixToDoApi.ToDo
    use FlixToDoApi.ToDo.ToDoId
    use FlixToDoApi.View
    use FlixToDoApi.View.ErrorView.ErrorView

    pub def exampleRoutes(): List[Route[{}]] =
        List#{
            Route(Method.Get, "/hello", _req ->
                Response({status = Status.Ok, body = Body.PlainText("Hello from HTTP server!")})
            ),
            Route(Method.Post, "/echo", req ->
                let Request({body | _}) = req;
                Response({status = Status.Ok, body = body})
            )
        }

    pub def apiRoutes(db: MutMap[ToDoId, ToDo, r], idCounter: Ref[Int32, r]): List[Route[r]] =
        List#{
            Route(Method.Get, "/todos", req ->
                run {
                    let Request({queryParams | _}) = req;
                    let result = forM(
                        toDos <- Db.listToDos(
                            queryParams |> Map.get("q"),
                            queryParams |> Map.get("isDone") |> Option.map(s -> s == "true")
                        ) |> Result.mapErr(s -> Response.json(Status.BadRequest, ErrorView({detail = s})))
                    ) yield toDos;
                    match result {
                        case Ok(toDos) => Response.json(Status.Ok, List.map(View.fromToDo, toDos))
                        case Err(res) => res
                    }
                } with Db.runWithInMemoryDb(db)
            ),
            Route(Method.Post, "/todos", req ->
                run {
                    let Request({body | _}) = req;
                    let result = forM(
                        input <- toDoInput(body);
                        toDo <- Db.upsertToDo(idCounter |> Ref.get |> ToDoId, input) |> Result.mapErr(s -> Response.json(Status.NotFound, ErrorView({detail = s})));
                        _ = Ref.put(Ref.get(idCounter) + 1, idCounter)
                    ) yield toDo;
                    match result {
                        case Ok(toDo) => Response.json(Status.Created, View.fromToDo(toDo))
                        case Err(res) => res
                    }
                } with Db.runWithInMemoryDb(db)
            ),
            Route(Method.Get, "/todos/{toDoId}", req ->
                run {
                    let Request({pathParams | _}) = req;
                    let result = forM(
                        id <- toDoId(pathParams);
                        toDo <- Db.findToDoById(id) |> Result.mapErr(s -> Response.json(Status.NotFound, ErrorView({detail = s})))
                    ) yield toDo;
                    match result {
                        case Ok(toDos) => Response.json(Status.Ok, View.fromToDo(toDos))
                        case Err(res) => res
                    }
                } with Db.runWithInMemoryDb(db)
            ),
            Route(Method.Put, "/todos/{toDoId}", req ->
                run {
                    let Request({pathParams, body | _}) = req;
                    let result = forM(
                        id <- toDoId(pathParams);
                        input <- toDoInput(body);
                        toDo <- Db.upsertToDo(id, input) |> Result.mapErr(s -> Response.json(Status.NotFound, ErrorView({detail = s})))
                    ) yield toDo;
                    match result {
                        case Ok(_) => Response.json(Status.NoContent, View.empty())
                        case Err(res) => res
                    }
                } with Db.runWithInMemoryDb(db)
            ),
            Route(Method.Delete, "/todos/{toDoId}", req ->
                run {
                    let Request({pathParams | _}) = req;
                    let result = forM(
                        id <- toDoId(pathParams);
                        toDo <- Db.deleteToDo(id) |> Result.mapErr(s -> Response.json(Status.NotFound, ErrorView({detail = s})))
                    ) yield toDo;
                    match result {
                        case Ok(_) => Response.json(Status.NoContent, View.empty())
                        case Err(res) => res
                    }
                } with Db.runWithInMemoryDb(db)
            ),
            Route(Method.Put, "/todos/{toDoId}/completed", req ->
                run {
                    let Request({pathParams | _}) = req;
                    let result = forM(
                        id <- toDoId(pathParams);
                        toDo <- Db.completeToDo(id) |> Result.mapErr(s -> Response.json(Status.NotFound, ErrorView({detail = s})))
                    ) yield toDo;
                    match result {
                        case Ok(_) => Response.json(Status.NoContent, View.empty())
                        case Err(res) => res
                    }
                } with Db.runWithInMemoryDb(db)
            )
        }

    def toDoInput(body: Body): Result[Response, Input.ToDoInput] =
        forM(
            json <- Body.json(body) |> Option.toOk(Response.json(Status.BadRequest, ErrorView({detail = "JSON body is necessary"})));
            input <- Util.Json.FromJson.fromJson(json) |> Result.mapErr(_ -> Response.json(Status.BadRequest, ErrorView({detail = "Invalid JSON"})))
        ) yield input

    def toDoId(pathParams: Map[String, String]): Result[Response, ToDoId] =
        forM(
            idStr <- pathParams |> Map.get("toDoId") |> Option.toOk(Response.json(Status.BadRequest, ErrorView({detail = "To-do ID is necessary"})));
            id <- Int32.fromString(idStr) |> Option.toOk(Response.json(Status.BadRequest, ErrorView({detail = "To-do ID must be integer"})))
        ) yield ToDoId(id)
}
