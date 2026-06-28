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

    pub def apiRoutes(db: MutMap[Int32, ToDo, r], idCounter: Ref[Int32, r]): List[Route[r]] =
        List#{
            Route(Method.Get, "/todos", req ->
                run {
                    let Request({queryParams | _}) = req;
                    let result = Db.listToDos(
                        queryParams |> Map.get("q"),
                        queryParams |> Map.get("isDone") |> Option.map(s -> s == "true")
                    );
                    match result {
                        case Ok(toDos) => Response.json(Status.Ok, List.map(View.fromToDo, toDos))
                        case Err(s) => Response.json(Status.BadRequest, ErrorView({detail = s}))
                    }
                } with Db.runWithInMemoryDb(db)
            ),
            Route(Method.Post, "/todos", req ->
                run {
                    let Request({body | _}) = req;
                    let toDoInput: Result[String, Input.ToDoInput] =
                        forM(
                            j <- Body.json(body) |> Option.toOk("JSON body is necessary");
                            in <- (Util.Json.FromJson.fromJson(j) |> Result.mapErr(_ -> "Invalid JSON"))
                        ) yield in;
                    match toDoInput {
                        case Ok(input) =>
                            let result = Db.upsertToDo(Ref.get(idCounter), input);
                            Ref.put(Ref.get(idCounter) + 1, idCounter);
                            match result {
                                case Ok(toDo) => Response.json(Status.Ok, View.fromToDo(toDo))
                                case Err(s) => Response.json(Status.BadRequest, ErrorView({detail = s}))
                            }
                        case Err(s) => Response.json(Status.BadRequest, ErrorView({detail = s}))
                    }
                } with Db.runWithInMemoryDb(db)
            )
        }
}
