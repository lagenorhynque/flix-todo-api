use FlixToDoApi.Lib.Config
use FlixToDoApi.Lib.Http.Body
use FlixToDoApi.Lib.Http.Method
use FlixToDoApi.Lib.Http.Request.Request
use FlixToDoApi.Lib.Http.Response.Response
use FlixToDoApi.Lib.Http.Response.Status
use FlixToDoApi.Lib.Http.Route.Route
use FlixToDoApi.Lib.{HttpServer => Server}

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
