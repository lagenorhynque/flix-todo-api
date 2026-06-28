pub mod FlixToDoApi.Http {
    mod Route {
        use FlixToDoApi.Http.{Method, Path, Request, Response}

        pub enum Route(Method, Path, Request -> Response)

        pub def method(r: Route): Method =
            let Route(m, _, _) = r;
            m

        pub def path(r: Route): Path =
            let Route(_, p, _) = r;
            p

        pub def requestHandler(r: Route): Request -> Response =
            let Route(_, _, h) = r;
            h
    }

    mod Method {
        pub enum Method with Eq, ToString {
            case Get
            case Post
            case Put
            case Delete
        }

        pub def fromString(s: String): Option[Method] =
            match s {
                case "GET" => Some(Get)
                case "POST" => Some(Post)
                case "Put" => Some(Put)
                case "Delete" => Some(Delete)
                case _ => None
            }
    }

    pub type alias Path = String

    pub enum Request({
        pathParams = Map[String, String],
        queryParams = Map[String, String],
        body = String
    })

    pub enum Response({
        status = ResponseStatusCode,
        body = String
    })

    mod ResponseStatusCode {
        pub enum ResponseStatusCode {
            case Ok
            case Created
            case NoContent
            case BadRequest
            case NotFound
        }

        pub def toInt(code: ResponseStatusCode): Int32 =
            match code {
                case ResponseStatusCode.Ok => 200
                case ResponseStatusCode.Created => 201
                case ResponseStatusCode.NoContent => 204
                case ResponseStatusCode.BadRequest => 400
                case ResponseStatusCode.NotFound => 404
            }
    }
}
