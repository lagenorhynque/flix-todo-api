use FlixToDoApi.Config
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
                Response({status = Status.Ok, body = "Hello from HTTP server!"})
            ),
            Route(Method.Post, "/echo", req ->
                let Request({body | _}) = req;
                Response({status = Status.Ok, body = body})
            )
        })
        |> Server.start
