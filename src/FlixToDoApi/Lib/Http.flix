pub mod FlixToDoApi.Lib.Http {
    mod Route {
        use FlixToDoApi.Lib.Http.{Method, Path, Request, Response}

        pub enum Route[ef: Eff](Method, Path, Request -> Response \ ef)

        pub def method(r: Route[ef]): Method =
            let Route(m, _, _) = r;
            m

        pub def path(r: Route[ef]): Path =
            let Route(_, p, _) = r;
            p

        pub def requestHandler(r: Route[ef]): Request -> Response \ ef =
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
                case "PUT" => Some(Put)
                case "DELETE" => Some(Delete)
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
        use Util.Json

        pub enum Response({
            status = Status,
            body = Body
        })

        mod Status {
            pub enum Status with Eq, ToString {
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

        pub def json(s: Status, x: a): Response with Json.ToJson[a] =
            Response.Response({status = s, body = x |> Json.ToJson.toJson |> Body.Json})
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

        pub def json(b: Body): Option[Util.Json] =
            match b {
                case Json(j) => Some(j)
                case _ => None
            }
    }
}
