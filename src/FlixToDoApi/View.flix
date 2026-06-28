pub mod FlixToDoApi.View {
    use FlixToDoApi.ToDo
    use Util.Json
    use Util.Json.{JNumber, JObject, JString, ToJson}

    pub enum ToDoView({
        id = Int32,
        title = String,
        detail = String
    })

    instance ToJson[ToDoView] {
        pub def toJson(toDo: ToDoView): Json =
            let ToDoView.ToDoView({id, title, detail}) = toDo;
            JObject(Map#{
                "id" => JNumber(Int32.toBigDecimal(id)),
                "title" => JString(title),
                "detail" => JString(detail)
            })
    }

    pub def fromToDo(toDo: ToDo): ToDoView =
        let ToDo.ToDo({id, title, detail | _}) = toDo;
        ToDoView.ToDoView({id = id, title = title, detail = detail})

    pub def empty(): Json =
        JString("")

    pub enum ErrorView({
        detail = String
    })

    instance ToJson[ErrorView] {
        pub def toJson(error: ErrorView): Json =
            let ErrorView.ErrorView({detail}) = error;
            JObject(Map#{
                "detail" => JString(detail)
            })
    }
}
