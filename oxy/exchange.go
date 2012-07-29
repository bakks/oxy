package oxy

import "fmt"
import "strings"
import "time"
import "io/ioutil"
import "net/http"
import "hash"
import "crypto/sha512"
import "crypto/hmac"
import "encoding/base64"

type Currency int32
const BTC Currency = 0
const USD Currency = 1

const MTGOX_KEY string = "7d71c7f4-7ff3-454e-87a5-6851a4962edf"
const MTGOX_SECRET string = "KjUXf1eyq/JgX3+LFVm4BzrpQIeqx02YI9LveEzfIO37PQ8Dy8fIFlO8s84eARM9LvVE/ujesyJf41j0y6fcGg=="

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
  req,_ := http.NewRequest("POST", "https://mtgox.com/api/1/BTCUSD/ticker", nil)
  response := x.request(req)
  fmt.Println(response)
}

func (x *MtGox) Balance() {
  args := make(map[string]interface{})
  args["nonce"] = fmt.Sprintf("%d", time.Now().UnixNano())

  strargs := ""
  i := 0

  for k, v := range args {
    strval := ""

    switch t := v.(type) {
      case int:
        strval = fmt.Sprintf("%d", t)
      case int64:
        strval = fmt.Sprintf("%d", t)
      case string:
        strval = t
      default:
        fmt.Printf("Could not recognize type %T for key %s", k, t)
    }

    if i > 0 {
      strargs += "&"
    }
    strargs += k + "=" + strval
    i++
  }

  req,_ := http.NewRequest("POST", "https://mtgox.com/api/1/generic/private/info", strings.NewReader(strargs))

  secret,_ := base64.StdEncoding.DecodeString(MTGOX_SECRET)

  var h hash.Hash = hmac.New(sha512.New, secret)
  h.Write([]byte(strargs))
  signature := base64.StdEncoding.EncodeToString(h.Sum(nil))

  req.Header.Add("Rest-Key", MTGOX_KEY)
  req.Header.Add("Rest-Sign", signature)
  req.Header.Add("Content-type", "application/x-www-form-urlencoded")

  response := x.request(req)
  fmt.Println(response)
}

