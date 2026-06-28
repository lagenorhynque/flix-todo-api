pub mod FlixToDoApi.HttpServer {
    import java.nio.charset.StandardCharsets
    use FlixToDoApi.Http
    import com.sun.net.httpserver.{HttpExchange, HttpHandler, HttpServer}
    import java.lang.{Runtime, Thread}
    import java.lang.{String => JString}
    import java.net.InetSocketAddress
    import java.nio.charset.Charset

    pub def create(port: Int32): HttpServer \ IO =
        HttpServer.create(new InetSocketAddress(port), 0)

    pub def addRoutes(routes: List[Http.Route], server: HttpServer): HttpServer \ IO =
        routes
            |> extractRoutes
            |> Map.forEach((k, v) -> discard server.createContext(k, v));
        server

    def extractRoutes(routes: List[Http.Route]): Map[Http.Path, HttpHandler] \ IO =
        routes
            |> List.groupBy(Http.Route.path)
            |> List.toMapWith(rs ->
                let path = rs |> Nel.head |> Http.Route.path;
                (path, buildHandler(path, rs))
            )

    def buildHandler(_p: Http.Path, rs: Nel[Http.Route]): HttpHandler \ IO =
        new HttpHandler {
            def handle(_this: HttpHandler, exchange: HttpExchange): Unit \ IO =
                let method = exchange.getRequestMethod() |> Http.Method.fromString;
                let path = exchange.getRequestURI().getPath();
                let response = Option.foldLeft(
                    (_, route) ->
                        let request = extractRequest(exchange);
                        Http.Route.requestHandler(route)(request),
                    Http.Response.Response({status = Http.ResponseStatusCode.NotFound, body = "Not Found"}),
                    findTargetRoute(method, path, rs)
                );
                writeResponse(response, exchange)
        }

    def findTargetRoute(method: Option[Http.Method], path: Http.Path, routes: Nel[Http.Route]): Option[Http.Route] =
        Option.flatMap(
            m -> Nel.findLeft(r -> m == Http.Route.method(r) and path == Http.Route.path(r), routes),
            method
        )

    def extractRequest(exchange: HttpExchange): Http.Request \ IO =
        Http.Request.Request({
            pathParams = Map.empty(),
            queryParams = Map.empty(),
            body = extractRequestBody(exchange)
        })

    // def extractPathParams(p: Http.Path): Map[String, String] = ???

    // def extractQueryParams(p: Http.Path): Map[String, String] = ???

    def extractRequestBody(exchange: HttpExchange): String \ IO =
        let is = exchange.getRequestBody();
        new JString(is.readAllBytes(), StandardCharsets.UTF_8)

    def writeResponse(response: Http.Response, exchange: HttpExchange): Unit \ IO =
            let Http.Response.Response({status, body}) = response;
            exchange.sendResponseHeaders(Http.ResponseStatusCode.toInt(status), body |> String.length |> Int32.toInt64);
            let os = exchange.getResponseBody();
            os.write(body.getBytes());
            os.close()

    pub def start(server: HttpServer): Unit \ {Chan, IO, NonDet, Logger} =
        server.start();
        let port = server.getAddress().getPort();
        Logger.info("To-do API server started on port ${port}.");
        keepRunningUntilInterrupted(server)

    def keepRunningUntilInterrupted(server: HttpServer): Unit \ {Chan, IO, NonDet} =
        let (tx, rx): (Sender[String], Receiver[String]) = Channel.buffered(1);
        Runtime.getRuntime().addShutdownHook(new Thread {
            def $run(_this: Thread): Unit \ {Chan, IO} =
                println("Shutting down...");
                Channel.send("interrupted", tx);
                server.stop(0);
                println("To-do API server stopped.")
        });
        discard Channel.recv(rx)
}
