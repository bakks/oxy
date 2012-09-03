package oxy

import "fmt"
import "net/http"
import "io/ioutil"

type OxyHTTPClient struct {
  client *http.Client
}

func NewOxyHTTPClient() *OxyHTTPClient {
  return &OxyHTTPClient{&http.Client{}}
}

func (x *OxyHTTPClient) Do(req *http.Request) (string, error) {
  response, err := x.client.Do(req)

  if err != nil {
    fmt.Println("http request to " + req.URL.String() + " failed", err)
    return "", err
  }

  defer response.Body.Close()

  body, err := ioutil.ReadAll(response.Body)

  if err != nil {
    fmt.Println("could not read response from request to " + req.URL.String(), err)
    return "", err
  }

  fmt.Println(string(body))

  return string(body), nil
}

