# github-issue-fetcher

A tool that you can look back on activities every year and month

## Usage

```
perl github-issue-fetcher.pl \
--target_repo=golang/go \
--state=closed \
--assignee=bradfitz
```

The result below is mostly omitted because it is too long.

```
# Activities in Jan 2016
- [net/http: go1.6beta1, nil pointer in http.Client](https://github.com/golang/go/issues/13839)
- [net/http: net/http.(*http2pipe).Write: invalid memory address or nil pointer dereference](https://github.com/golang/go/issues/13932)
- [net/http: TestServerValidatesHostHeader timeout](https://github.com/golang/go/issues/13950)
- [net/http: Transport.CloseIdleConnections doesn't close idle http2 connections](https://github.com/golang/go/issues/13975)
- [net/http: http2 negative content length](https://github.com/golang/go/issues/14003)
- [net/http: http2 transport doesn't respect all http1 Transport fields](https://github.com/golang/go/issues/14008)
- [x/net/http2: validate received header values ](https://github.com/golang/go/issues/14029)
- [build: darwin-386-10_10 builder not using cgo?](https://github.com/golang/go/issues/14083)
- [net/http/httputil: DumpResponse could corrupt Response object](https://github.com/golang/go/issues/14036)
- [x/net/context/ctxhttp: race condition preventing response from being closed](https://github.com/golang/go/issues/14065)
- [net/http: check that http2 logs no more than http1](https://github.com/golang/go/issues/13925)
- [doc: Windows default build from source behavior is CGO enabled but docs don't mention C compiler dependency](https://github.com/golang/go/issues/13954)

### Total value of label
- The number of Documentation is 1
- The number of Builders is 1

# Activities in Feb 2016
- [net/http: http2 Transport retains Request.Body after request is complete, not GCed](https://github.com/golang/go/issues/14084)
- [x/net/http2: Exporting h2 connection setup](https://github.com/golang/go/issues/12737)
- [x/net/http2: should interpret Connection: close request header as Request.Close = true](https://github.com/golang/go/issues/14227)
- [runtime: typo in comment about timer type's fields](https://github.com/golang/go/issues/14259)
- [net/http: Server.ListenAndServeTLS not compatible with tls.Config.GetCertificate](https://github.com/golang/go/issues/14268)
- [os/exec: understand 387 fd leak](https://github.com/golang/go/issues/7808)
- [net/http: allow control of case of header key](https://github.com/golang/go/issues/5022)
- [net/http: rejects requests where headers have whitespace](https://github.com/golang/go/issues/14392)
- [mime/multipart: sort written headers](https://github.com/golang/go/issues/14198)
- [net/http/httputil: NewSingleHostReverseProxy doesn't pass http authentication ](https://github.com/golang/go/issues/14469)
- [x/net/http2: Transport.TLSConfig.ServerName is ignored](https://github.com/golang/go/issues/14501)
- [net/http/httputil: permit ReverseProxy to change Host header](https://github.com/golang/go/issues/14413)
- [net/http/httptest: Server.CloseClientConnections does not force a connection error in go1.6rc2](https://github.com/golang/go/issues/14290)

### Total value of label
- The number of Documentation is 1
```
