pub mod FlixToDoApi.Lib.HttpServer {
    use FlixToDoApi.Lib.Http
    use Util.Json
    import com.sun.net.httpserver.{HttpExchange, HttpHandler, HttpServer}
    import java.lang.{Runtime, Thread}
    import java.lang.{String => JString}
    import java.net.InetSocketAddress
    import java.nio.charset.StandardCharsets

    pub def create(port: Int32): HttpServer \ IO =
        HttpServer.create(new InetSocketAddress(port), 0)

    pub def addRoutes(routes: List[Http.Route[ef]], server: HttpServer): HttpServer \ IO =
        routes
            |> extractRoutes
            |> Map.forEach((p, h) -> discard server.createContext(p, h));
        server

    def extractRoutes(routes: List[Http.Route[ef]]): Map[Http.Path, HttpHandler] \ IO =
        routes
            |> List.groupBy(Http.Route.path >> commonPath)
            |> List.toMapWith(rs ->
                let path = rs |> Nel.head |> Http.Route.path |> commonPath;
                (path, buildHandler(rs))
            )

    def commonPath(path: Http.Path): Http.Path =
        path |> Regex.stripSuffix(regex"/\\{.+") |> Option.getWithDefault(path)

    def buildHandler(routes: Nel[Http.Route[ef]]): HttpHandler \ IO =
        new HttpHandler {
            def handle(_this: HttpHandler, exchange: HttpExchange): Unit \ ef + IO =
                let requestMethod = exchange.getRequestMethod() |> Http.Method.fromString;
                let requestPath = exchange.getRequestURI().getPath();
                let requestQuery = exchange.getRequestURI().getQuery() |> Object.toOption;
                let response = Option.foldLeft(
                    (_, route) ->
                        let request = Http.Request.Request({
                            pathParams = extractPathParams(requestPath, Http.Route.path(route)),
                            queryParams = extractQueryParams(requestQuery),
                            body = extractRequestBody(exchange)
                        });
                        Http.Route.requestHandler(route)(request),
                    Http.Response.Response({status = Http.Response.Status.NotFound, body = Http.Body.PlainText("Route not found")}),
                    findTargetRoute(requestMethod, requestPath, routes)
                );
                writeResponse(response, exchange)
        }

    def pathPattern(path: Http.Path): Regex =
        path
            |> Regex.replace(src = regex"\\{.+?\\}", dst = "([^/]+?)")
            |> String.toRegex
            |> Result.getWithDefault(Regex.unmatchable())

    def findTargetRoute(requestMethod: Option[Http.Method], requestPath: String, routes: Nel[Http.Route[ef]]): Option[Http.Route[ef]] =
        Option.flatMap(
            m -> Nel.findLeft(
                r -> m == Http.Route.method(r) and Regex.isMatch(r |> Http.Route.path |> pathPattern, requestPath),
                routes
            ),
            requestMethod
        )

    def extractPathParams(requestPath: String, path: Http.Path): Map[String, String] =
        let pathPattern = pathPattern(path);
        let paramKeys = Regex.submatches(regex"(?<=\\{).+?(?=\\})", path);
        let paramValues = Regex.capture(pathPattern, requestPath);
        List.zip(paramKeys, paramValues) |> List.toMap

    def extractQueryParams(requestQuery: Option[String]): Map[String, String] =
        Option.foldLeft(
            (_, queryString) ->
                queryString
                    |> Regex.split(regex"&")
                    |> List.filterMap(entry ->
                        match Regex.split(regex"=",entry) {
                            case k :: v :: Nil => Some((k, v))
                            case _ => None
                        }
                    )
                    |> List.toMap,
            Map.empty(),
            requestQuery
        )

    def extractRequestBody(exchange: HttpExchange): Http.Body \ IO =
        let is = exchange.getRequestBody();
        let s = new JString(is.readAllBytes(), StandardCharsets.UTF_8);
        let contentType = exchange.getRequestHeaders().getFirst("Content-Type")
            |> Object.toOption
            |> Option.getWithDefault("text/plain");
        match contentType {
            case "application/json" =>
                Json.parse(s) |> Result.getWithDefault(Json.JString("")) |> Http.Body.Json
            case _ => Http.Body.PlainText(s)
        }

    def writeResponse(response: Http.Response, exchange: HttpExchange): Unit \ IO =
            let Http.Response.Response({status, body}) = response;
            let bodyString = match body {
                case Http.Body.PlainText(s) => s
                case Http.Body.Json(j) => Json.toCompactString(j)
            };
            exchange.getResponseHeaders().set("Content-Type", Http.Body.contentType(body));
            exchange.sendResponseHeaders(Http.Response.Status.toCode(status), bodyString |> String.length |> Int32.toInt64);
            let os = exchange.getResponseBody();
            os.write(bodyString.getBytes());
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
