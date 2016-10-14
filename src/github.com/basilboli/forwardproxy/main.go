package main

import (
	"github.com/elazarl/goproxy"
	"log"
	"net/http"
)

func main() {
	proxy := goproxy.NewProxyHttpServer()
	proxy.Verbose = true
	hostAddr := "0.0.0.0:8080"
	log.Printf("Starting proxy on %s\n", hostAddr)
	log.Fatal(http.ListenAndServe(hostAddr, proxy))
}
