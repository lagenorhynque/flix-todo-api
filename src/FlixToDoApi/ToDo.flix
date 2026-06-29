pub mod FlixToDoApi.ToDo {
    use FlixToDoApi.Input.ToDoInput

    pub enum ToDo({
        id = ToDoId,
        title = String,
        detail = String,
        isDone = Bool
    })

    instance Eq[ToDo] {
        pub def eq(a: ToDo, b: ToDo): Bool =
            let ToDo.ToDo({id = idA, title = titleA, detail = detailA, isDone = isDoneA}) = a;
            let ToDo.ToDo({id = idB, title = titleB, detail = detailB, isDone = isDoneB}) = b;
            idA == idB
                and titleA == titleB
                and detailA == detailB
                and isDoneA == isDoneB
    }

    instance ToString[ToDo] {
        pub def toString(a: ToDo): String =
            let ToDo.ToDo({id, title, detail, isDone}) = a;
            "ToDo({id = ${id}, title = ${title}, detail = ${detail}, isDone = ${isDone}})"
    }

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

    pub def complete(toDo: ToDo): ToDo =
        let ToDo.ToDo(current) = toDo;
        ToDo.ToDo({isDone = true | current})

    mod ToDoId {
        pub enum ToDoId(Int32) with Eq, Order, ToString

        pub def toInt(toDoId: ToDoId): Int32 =
            let ToDoId(id) = toDoId;
            id
    }
}
