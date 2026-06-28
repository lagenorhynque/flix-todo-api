pub mod FlixToDoApi.Lib.Http {
    mod Route {
        use FlixToDoApi.Lib.Http.{Method, Path, Request, Response}

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
        body = Body
    })

    mod Response {
        use FlixToDoApi.Lib.Http.Body

        pub enum Response({
            status = Status,
            body = Body
        })

        mod Status {
            pub enum Status {
                case Ok
                case Created
                case NoContent
                case BadRequest
                case NotFound
            }

            pub def toCode(s: Status): Int32 =
                match s {
                    case Status.Ok => 200
                    case Status.Created => 201
                    case Status.NoContent => 204
                    case Status.BadRequest => 400
                    case Status.NotFound => 404
                }
        }
    }

    mod Body {
        pub enum Body {
            case PlainText(String)
            case Json(Util.Json)
        }

        pub def contentType(b: Body): String =
            match b {
                case PlainText(_) => "text/plain"
                case Json(_) => "application/json"
            }
    }
}
