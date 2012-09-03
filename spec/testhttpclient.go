package oxy

import "fmt"
import "os"
import "errors"
import "net/http"

type TestHTTPClient struct {
}

func NewTestHTTPClient() *TestHTTPClient {
  return &TestHTTPClient{}
}

var mockedEndpoints = map[string]string {
    "https://mtgox.com/api/1/generic/private/info": "mtgox/info.json",
    "https://mtgox.com/api/1/generic/private/orders": "mtgox/orders.json",
    "https://mtgox.com/api/1/BTCUSD/fulldepth": "mtgox/fulldepth.json",
    "https://mtgox.com/api/1/BTCUSD/trades": "mtgox/trades.json",
    "https://mtgox.com/api/1/BTCUSD/ticker": "mtgox/ticker.json",
}

func (x *TestHTTPClient) Do(req *http.Request) (string, error) {
  path := req.URL.String()
  fmt.Println("TestHTTPClient request " + path)

  if testFile, ok := mockedEndpoints[path]; ok {
    return x.readTestFile(testFile), nil
  }

  return "", errors.New("Could not mock endpoint " + path)
}

func (x *TestHTTPClient) readTestFile(filename string) string {
  file, err := os.Open("asset/" + filename)

  if err != nil {
    panic("could not open test file " + filename)
  }

  buff := make([]byte, 1000000)
  n, err := file.Read(buff)

  if err != nil {
    panic("could not read test file " + filename)
  }

  return string(buff[0:n])
}

