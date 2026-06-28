pub mod FlixToDoApi.ToDo {
    use FlixToDoApi.Input.ToDoInput

    pub enum ToDo({
        id = Int32,
        title = String,
        detail = String,
        isDone = Bool
    })

    pub def fromInput(id: Int32, input: ToDoInput): ToDo =
        let ToDoInput.ToDoInput({title, detail}) = input;
        ToDo.ToDo({id = id, title = title, detail = detail, isDone = false})
}
