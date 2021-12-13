use tonic::{transport::Server, Request, Response, Status};

use hello_world::greeter_server::{Greeter, GreeterServer};
use hello_world::{HelloReply, HelloRequest};

pub mod hello_world {
    tonic::include_proto!("helloworld");
}

#[derive(Debug, Default)]
pub struct MyGreeter {}

#[tonic::async_trait]
impl Greeter for MyGreeter {
    async fn say_hello(
        &self,
        request: Request<HelloRequest>,
    ) -> Result<Response<HelloReply>, Status> {
        println!("Got a request: {:?}", request);

        let reply = hello_world::HelloReply {
            message: format!("Hello {}!", request.into_inner().name).into(),
        };

        Ok(Response::new(reply))
    }
}


use actix_web::{web, App, HttpRequest, HttpServer, Responder};
async fn health(_req: HttpRequest) -> impl Responder {
    "worked!!!1"
}


#[actix_web::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let addr = "0.0.0.0:8080".parse()?;
    let greeter = MyGreeter::default();

   let grpc_fut=  Server::builder()
        .add_service(GreeterServer::new(greeter))
        .serve(addr);
    let _h = tokio::spawn(grpc_fut);

      HttpServer::new(|| {
        App::new()
            .route("/health", web::get().to(health))
    })
        .bind(("0.0.0.0", 8082))?
        .run().await ?;

    Ok(())
}