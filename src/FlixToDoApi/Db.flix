pub mod FlixToDoApi.Db {
    use FlixToDoApi.Input
    use FlixToDoApi.Lib.Http.{Request, Response}
    use FlixToDoApi.ToDo
    use FlixToDoApi.ToDo.ToDoId

    pub eff Db {
        def listToDos(q: Option[String], isDone: Option[Bool]): Result[String, List[ToDo]]
        def findToDoById(id: ToDoId): Result[String, ToDo]
        def upsertToDo(id: ToDoId, input: Input.ToDoInput): Result[String, ToDo]
        def completeToDo(id: ToDoId): Result[String, ToDo]
        def deleteToDo(id: ToDoId): Result[String, Bool]
    }

    pub def runWithInMemoryDb(db: MutMap[ToDoId, ToDo, r], f: Unit -> a \ ef): a \ (ef - Db) + r =
        run {
            f()
        } with handler Db {
            def listToDos(q, isDone, resume) =
                MutMap.valuesOf(db)
                    |> List.filter(toDo ->
                        let ToDo.ToDo({title, detail | _}) = toDo;
                        Option.foldLeft(
                            (_, searchQuery) ->
                                String.contains(substr = searchQuery, title)
                                or String.contains(substr = searchQuery, detail),
                            true,
                            q
                        )
                    )
                    |> List.filter(toDo ->
                        let ToDo.ToDo({isDone = targetIsDone | _}) = toDo;
                        Option.foldLeft((_, done) -> targetIsDone == done, true, isDone)
                    )
                    |> Ok
                    |> resume
            def findToDoById(id, resume) =
                MutMap.get(id, db) |> Option.toOk(toDoNotFound(id)) |> resume
            def upsertToDo(id, input, resume) = {
                MutMap.put(id, ToDo.fromInput(id, input), db);
                MutMap.get(id, db) |> Option.toOk(toDoNotFound(id)) |> resume
            }
            def completeToDo(id, resume) =
                resume(forM(
                    ToDo.ToDo(current) <- MutMap.get(id, db) |> Option.toOk(toDoNotFound(id));
                    _ = MutMap.put(id, ToDo.ToDo({isDone = true | current}), db);
                    updated <- MutMap.get(id, db) |> Option.toOk(toDoNotFound(id))
                ) yield updated)
            def deleteToDo(id, resume) = {
                MutMap.remove(id, db);
                resume(Ok(true))
            }
        }

    def toDoNotFound(id: ToDoId): String =
            "To-do#${ToDoId.toInt(id)} is not found"
}
