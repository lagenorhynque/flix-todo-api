pub mod FlixToDoApi.Db {
    use FlixToDoApi.Input
    use FlixToDoApi.Lib.Http.{Request, Response}
    use FlixToDoApi.ToDo

    pub eff Db {
        def listToDos(q: Option[String], isDone: Option[Bool]): Result[String, List[ToDo]]
        def findById(id: Int32): Result[String, ToDo]
        def upsertToDo(id: Int32, input: Input.ToDoInput): Result[String, ToDo]
        def completeToDo(id: Int32): Result[String, ToDo]
        def deleteToDo(id: Int32): Result[String, Bool]
    }

    pub def runWithInMemoryDb(db: MutMap[Int32, ToDo, r], f: Unit -> a \ ef): a \ (ef - Db) + r =
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
            def findById(id, resume) =
                MutMap.get(id, db) |> Option.toOk(toDoNotFound(id)) |> resume
            def upsertToDo(id, input, resume) = {
                MutMap.put(id, ToDo.fromInput(id, input), db);
                MutMap.get(id, db) |> Option.toOk(toDoNotFound(id)) |> resume
            }
            def completeToDo(id, resume) = {
                match MutMap.get(id, db) {
                    case Some(ToDo.ToDo(x)) =>
                        MutMap.put(id, ToDo.ToDo({isDone = true | x}), db);
                        MutMap.get(id, db) |> Option.toOk(toDoNotFound(id))
                    case _ => Err(toDoNotFound(id))
                }
                    |> resume
            }
            def deleteToDo(id, resume) = {
                MutMap.remove(id, db);
                resume(Ok(true))
            }
        }

    def toDoNotFound(id: Int32): String =
            "To-do#${id} is not found"
}
