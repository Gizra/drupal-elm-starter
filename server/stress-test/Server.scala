import scala.concurrent.duration._

import io.gatling.core.Predef._
import io.gatling.http.Predef._
import io.gatling.jdbc.Predef._

class Server extends Simulation {
  val testServerUrl = scala.util.Properties.envOrElse("SERVER_BASE_URL", "http://starter.local")

  val httpProtocol = http
    .baseURL(testServerUrl)
    .acceptHeader("*/*")
    .acceptEncodingHeader("gzip, deflate")
    .acceptLanguageHeader("en-US,en;q=0.5")
    .doNotTrackHeader("1")
    .userAgentHeader("Mozilla/5.0 (X11; Linux x86_64; rv:58.0) Gecko/20100101 Firefox/58.0")

  val scn = scenario("Gizra")
    .exec(http("request_0")
      .get("/")
      .check(status.is(403))
    )
    .exec(http("request_1")
      .get("/api")
    )
    .exec(http("request_2")
      .get("/user/login")
      .check(css("#user-login input[name=form_build_id]", "value").saveAs("buildid"))
    )
    .exec(http("request_3")
      .post("/user/login")
      .formParam("form_id", "user_login")
      .formParam("form_build_id", "${buildid}")
      .formParam("op", "Log+in")
      .formParam("name", "admin")
      .formParam("pass", "admin")
    )
    .exec(http("request_4")
      .get("/")
      .check(status.is(200))
    )
    .exec(http("request_5")
      .get("/api")
    )
    .exec(http("request_6")
      .get("/api/me")
    )
    .exec(http("request_7")
      .get("/api/items")
    )


  setUp(scn.inject(
    rampUsers(10) over(1 seconds),
  )).protocols(httpProtocol)

}
