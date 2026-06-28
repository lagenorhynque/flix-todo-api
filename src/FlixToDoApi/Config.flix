pub mod FlixToDoApi.Config {
    pub def port(): Option[Int32] \ Sys.Env =
        forM(
            portStr <- Sys.Env.getVar("PORT");
            portNum <- Int32.fromString(portStr)
        ) yield portNum
}
