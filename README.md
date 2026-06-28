# flix-todo-api

A simple to-do API implemented in Flix.

## Usage

```sh
flix run
```

OR

```sh
PORT=<port number> flix run
```

## API specification

- `GET /todos`
  - query parameters:
    - `q`: query string
    - `isDone`: boolean
- `GET /todos/{toDoId}`
- `POST /todos/{toDoId}`
  - request body:
    ```json
    {
      "title": "...",
      "detail": "..."
    }
    ```
- `PUT /todos/{toDoId}`
  - request body:
    ```json
    {
      "title": "...",
      "detail": "..."
    }
    ```
- `DELETE /todos/{toDoId}`
- `PUT /todos/{toDoId}/completed`
