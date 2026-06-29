pub mod FlixToDoApi.ToDo {
    use FlixToDoApi.Input.ToDoInput

    pub enum ToDo({
        id = ToDoId,
        title = String,
        detail = String,
        isDone = Bool
    })

    pub def fromInput(id: ToDoId, input: ToDoInput): ToDo =
        let ToDoInput.ToDoInput({title, detail}) = input;
        ToDo.ToDo({id = id, title = title, detail = detail, isDone = false})

    pub def matchesWithTitleOrDetail(q: Option[String], toDo: ToDo): Bool =
        let ToDo.ToDo({title, detail | _}) = toDo;
        Option.foldLeft(
            (_, searchQuery) ->
                String.contains(substr = searchQuery, title)
                or String.contains(substr = searchQuery, detail),
            true,
            q
        )

    pub def matchesWithIsDone(isDone: Option[Bool], toDo: ToDo): Bool =
        let ToDo.ToDo({isDone = targetIsDone | _}) = toDo;
        Option.foldLeft((_, done) -> targetIsDone == done, true, isDone)

    mod ToDoId {
        pub enum ToDoId(Int32) with Eq, Order

        pub def fromInt(id: Int32): ToDoId =
            ToDoId(id)

        pub def toInt(toDoId: ToDoId): Int32 =
            let ToDoId(id) = toDoId;
            id
    }
}
