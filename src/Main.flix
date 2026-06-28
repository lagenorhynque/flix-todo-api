use FlixToDoApi.Config
use FlixToDoApi.Http.Body
use FlixToDoApi.Http.Method
use FlixToDoApi.Http.Request.Request
use FlixToDoApi.Http.Response.Response
use FlixToDoApi.Http.Route.Route
use FlixToDoApi.Http.{ResponseStatusCode => Status}
use FlixToDoApi.{HttpServer => Server}

def main(): Unit \ {Chan, Sys.Env, IO, Logger, NonDet} =
    let port = Config.port() |> Option.getWithDefault(8888);
    Server.create(port)
        |> Server.addRoutes(List#{
            Route(Method.Get, "/hello", _req ->
                Response({status = Status.Ok, body = Body.PlainText("Hello from HTTP server!")})
            ),
            Route(Method.Post, "/echo", req ->
                let Request({body | _}) = req;
                Response({status = Status.Ok, body = body})
            ),
            Route(Method.Get, "/foo/{fooId}/bar/{barId}", req ->
                let Request({pathParams, queryParams | _}) = req;
                Response({status = Status.Ok, body = Body.PlainText("pathParams=${pathParams}, queryParams=${queryParams}")})
            )
        })
        |> Server.start
