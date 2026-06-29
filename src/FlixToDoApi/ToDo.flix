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

    mod ToDoId {
        pub enum ToDoId(Int32) with Eq, Order

        pub def fromInt(id: Int32): ToDoId =
            ToDoId(id)

        pub def toInt(toDoId: ToDoId): Int32 =
            let ToDoId(id) = toDoId;
            id
    }
}
