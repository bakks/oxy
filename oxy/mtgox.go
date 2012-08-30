package oxy

import "fmt"
import "strconv"
import "strings"
import "time"
import "encoding/json"
import "io/ioutil"
import "net/http"
import "net/url"
import "hash"
import "crypto/sha512"
import "crypto/hmac"
import "encoding/base64"

const MTGOX_KEY string = "7d71c7f4-7ff3-454e-87a5-6851a4962edf"
const MTGOX_SECRET string = "KjUXf1eyq/JgX3+LFVm4BzrpQIeqx02YI9LveEzfIO37PQ8Dy8fIFlO8s84eARM9LvVE/ujesyJf41j0y6fcGg=="

const MTGOX_FULLDEPTH string = "/api/1/BTCUSD/fulldepth"
const MTGOX_TICKER string = "/api/1/BTCUSD/ticker"
const MTGOX_INFO string = "/api/1/generic/private/info"
const MTGOX_ORDERS string = "/api/1/generic/private/orders"

// TODO rewrite error handling code

type MtGox struct {
  client      *http.Client
  domain      string
  key         string
  secret      string
  quoteTime   time.Time
  depth       SimpleBook
  orders      SimpleBook
  fee         float64
  balance     map[Currency]float64
}

func NewMtGox() *MtGox {
  var x MtGox
  x.client = &http.Client{}
  x.domain = "https://mtgox.com"
  x.key = MTGOX_KEY
  x.secret = MTGOX_SECRET
  x.depth = *NewSimpleBook()
  x.orders = *NewSimpleBook()
  x.fee = -1
  x.balance = make(map[Currency]float64)

  return &x
}

func (x *MtGox) Depth() SimpleBook {
  return x.depth
}

func (x *MtGox) FetchOrders() error {
  r := x.request(MTGOX_ORDERS, nil)
  x.orders.Clear()

  for _, o := range r {
    order := o.(map[string]interface{})
    priceBlock := order["price"].(map[string]interface{})
    price := priceBlock["value"].(float64)
    sizeBlock := order["amount"].(map[string]interface{})
    size := sizeBlock["size"].(float64)
    orderType := order["type"].(string)
    q := NewQuote(price, size, (orderType == "bid"))
    x.orders.Add(q)
  }

  return nil
}

func (x *MtGox) FetchAccounts() error {
  r := x.request(MTGOX_INFO, nil)

  x.fee = r["Trade_Fee"].(float64)

  wallets := r["Wallets"].(map[string]interface{})

  for k, v := range wallets {
    err, currency := CastCurrency(k)

    if err != nil {
      return err
    }

    mapValue := v.(map[string]interface{})
    balance := mapValue["Balance"].(map[string]interface{})
    value := balance["value"].(float64)
    x.balance[currency] = value
  }

  return nil
}

func (x *MtGox) GetFee() float64 {
  return x.fee
}

func (x *MtGox) GetBalance(c Currency) float64 {
  return x.balance[c]
}

func (x *MtGox) FetchDepth() error {
  r := x.request(MTGOX_FULLDEPTH, nil)
  x.depth.Clear()

  bids := r["bids"].([]interface{})
  asks := r["asks"].([]interface{})

  for _, b := range bids {
    bid := b.(map[string]interface{})
    q := NewQuote(bid["price"].(float64), bid["amount"].(float64), true)
    t,_ := strconv.ParseInt(bid["stamp"].(string), 10, 64)

    q.Start = time.Unix(t / 1000000, t - (t / 1000000)).UTC()
    x.depth.Add(q)
  }

  for _, a := range asks {
    ask := a.(map[string]interface{})
    q := NewQuote(ask["price"].(float64), ask["amount"].(float64), false)
    t,_ := strconv.ParseInt(ask["stamp"].(string), 10, 64)

    q.Start = time.Unix(t / 1000000, t - (t / 1000000)).UTC()
    x.depth.Add(q)
  }

  x.quoteTime = time.Now()

  return nil
}

func urlEncode(args map[string]interface{}) string {
  values := make(url.Values)

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

    values.Add(k, strval)
  }

  return values.Encode()
}

func (x *MtGox) request(path string, args map[string]interface{}) map[string]interface{} {
  if args == nil {
    args = make(map[string]interface{})
  }

  args["nonce"] = fmt.Sprintf("%d", time.Now().UnixNano())

  strargs := urlEncode(args)
  req,_ := http.NewRequest("POST", x.domain + path, strings.NewReader(strargs))
  secret,_ := base64.StdEncoding.DecodeString(x.secret)

  var h hash.Hash = hmac.New(sha512.New, secret)
  h.Write([]byte(strargs))
  signature := base64.StdEncoding.EncodeToString(h.Sum(nil))

  req.Header.Add("Rest-Key", x.key)
  req.Header.Add("Rest-Sign", signature)
  req.Header.Add("Content-type", "application/x-www-form-urlencoded")

  r, err := x.client.Do(req)

  if err != nil {
    fmt.Println("error", err)
    return nil
  }

  defer r.Body.Close()

  body,_ := ioutil.ReadAll(r.Body)
  fmt.Println(string(body))

  var v map[string]interface{}
  err = json.Unmarshal(body, &v)

  if err != nil {
    fmt.Println(err)
  }

  if v == nil {
    fmt.Println("Returned JSON unmarshaled to nil")
  }

  if v["result"] != nil && v["result"] != "success" {
    fmt.Println("result not success: " + v["result"].(string))
    return nil
  }

  if v["return"] != nil {
    return v["return"].(map[string]interface{})
  } else {
    return v
  }

  return nil
}
