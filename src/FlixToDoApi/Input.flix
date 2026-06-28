pub mod FlixToDoApi.Input {
    use Util.Json
    use Util.Json.{FromJson, JsonError, ToJson}
    pub enum ToDoInput({
        title = String,
        detail = String
    })

    instance FromJson[ToDoInput] {
        pub def fromJson(j: Json): Result[JsonError, ToDoInput] =
            forM(
                title <- FromJson.decodeAtKey("title", j);
                detail <- FromJson.decodeAtKey("detail", j)
            ) yield ToDoInput.ToDoInput({detail = detail, title = title})
    }
}
