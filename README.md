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

<details>
<summary>usage examples</summary>

```sh
# List to-dos: initial state
curl localhost:8888/todos -s | jq
[]

# Add three to-dos
curl localhost:8888/todos -s -X POST -H 'Content-Type: application/json' -d '{"title": "foo", "detail": "..."}' | jq
{
  "detail": "...",
  "id": 1,
  "title": "foo"
}

curl localhost:8888/todos -s -X POST -H 'Content-Type: application/json' -d '{"title": "bar", "detail": "..."}' | jq
{
  "detail": "...",
  "id": 2,
  "title": "bar"
}

curl localhost:8888/todos -s -X POST -H 'Content-Type: application/json' -d '{"title": "baz", "detail": "..."}' | jq
{
  "detail": "...",
  "id": 3,
  "title": "baz"
}

# List to-dos: after added
curl -s localhost:8888/todos -s | jq
[
  {
    "detail": "...",
    "id": 1,
    "title": "foo"
  },
  {
    "detail": "...",
    "id": 2,
    "title": "bar"
  },
  {
    "detail": "...",
    "id": 3,
    "title": "baz"
  }
]

# Update a to-do
curl localhost:8888/todos/2 -s -X PUT -H 'Content-Type: application/json' -d '{"title": "quz", "detail": "..."}' | jq

# Complete a to-do
curl localhost:8888/todos/3/completed -s -X PUT | jq

# List to-dos: after update
curl localhost:8888/todos -s | jq
[
  {
    "detail": "...",
    "id": 1,
    "title": "foo"
  },
  {
    "detail": "...",
    "id": 2,
    "title": "quz"
  },
  {
    "detail": "...",
    "id": 3,
    "title": "baz"
  }
]

# List to-dos with query
curl localhost:8888/todos?q=uz -s | jq
[
  {
    "detail": "...",
    "id": 2,
    "title": "quz"
  }
]

# List completed to-dos
curl localhost:8888/todos?isDone=true -s | jq
[
  {
    "detail": "...",
    "id": 3,
    "title": "baz"
  }
]

# List incomplete to-dos
curl localhost:8888/todos?isDone=false -s | jq
[
  {
    "detail": "...",
    "id": 1,
    "title": "foo"
  },
  {
    "detail": "...",
    "id": 2,
    "title": "quz"
  }
]

# Delete a to-do
curl localhost:8888/todos/1 -s -X DELETE | jq

# List to-dos: after deleted
curl localhost:8888/todos -s | jq
[
  {
    "detail": "...",
    "id": 2,
    "title": "quz"
  },
  {
    "detail": "...",
    "id": 3,
    "title": "baz"
  }
]
```

</details>

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
