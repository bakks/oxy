package kilo

import "fmt"
import "time"
import "io/ioutil"
import "net/http"

type Currency int32
const BTC Currency = 0
const USD Currency = 1

const MTGOX_KEY string = "0eebcce3-e9a6-4390-8619-6897671e7386"
const MTGOX_SECRET string = "gQDmqXhMnR6RsXKzL7yIvXO1SEdQQCaiPWYT65gGVp0csiEPTITz3Uu1U0JPUNs0ZMQLt6nW59Pql7cMw1azFg"

type Exchange interface {
  New()
  Info()
  Balance()
}

type MtGox struct {
  client *http.Client
  key string
  secret string
}



type Trade struct {
  price     float64
  size      float64
  buy       Currency
  sell      Currency
}

type Quote struct {
  price     float64
  size      float64
  isBuy     bool
  currency  Currency
  start     time.Time
  end       time.Time
}

func NewMtGox() *MtGox {
  var x MtGox
  x.client = &http.Client{}
  x.key = MTGOX_KEY
  x.secret = MTGOX_SECRET

  return &x
}

func (x *MtGox) request(req *http.Request) string {
  r,err := x.client.Do(req)

  if err != nil {
    fmt.Println("error", err)
    return ""
  }
  
  defer r.Body.Close()

  body,_ := ioutil.ReadAll(r.Body)
  return string(body)
}

func (x *MtGox) Info() {
  req,_ := http.NewRequest("GET", "https://mtgox.com/api/1/BTCUSD/ticker", nil)
  response := x.request(req)
  fmt.Println(response)
}

func (x *MtGox) Balance() {
  req,_ := http.NewRequest("GET", "https://mtgox.com/api/1/generic/private/info", nil)
  response := x.request(req)
  fmt.Println(response)
}

