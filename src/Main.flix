use FlixToDoApi.Routes
use FlixToDoApi.Lib.Config
use FlixToDoApi.Lib.{HttpServer => Server}

def main(): Unit \ {Chan, Sys.Env, IO, Logger, NonDet} =
    let port = Config.port() |> Option.getWithDefault(8888);
    region rc {
        let db = MutMap.empty(rc);
        let idCounter = Ref.fresh(rc, 1);
        Server.create(port)
            |> Server.addRoutes(Routes.exampleRoutes())
            |> Server.addRoutes(Routes.apiRoutes(db, idCounter))
            |> Server.start
    }
