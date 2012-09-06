package oxy

import "fmt"
import "errors"
import "strconv"
import "strings"
import "time"
import "encoding/json"
import "net/http"
import "net/url"
import "hash"
import "crypto/sha512"
import "crypto/hmac"
import "encoding/base64"

const MTGOX_KEY string        = "7d71c7f4-7ff3-454e-87a5-6851a4962edf"
const MTGOX_SECRET string     = "KjUXf1eyq/JgX3+LFVm4BzrpQIeqx02YI9LveEzfIO37PQ8Dy8fIFlO8s84eARM9LvVE/ujesyJf41j0y6fcGg=="
const MTGOX_TOKEN string      = "7W2JJFDUEL47VDCVTSKC2TPGJV222EVX"

const MTGOX_DOMAIN string     = "https://mtgox.com"
const MTGOX_FULLDEPTH string  = "/api/1/BTCUSD/fulldepth"
const MTGOX_TRADES string     = "/api/1/BTCUSD/trades"
const MTGOX_TICKER string     = "/api/1/BTCUSD/ticker"
const MTGOX_TRADE string      = "/api/1/BTCUSD/private/order/add"
const MTGOX_CANCEL string     = "/code/cancelOrder.php"
const MTGOX_INFO string       = "/api/1/generic/private/info"
const MTGOX_ORDERS string     = "/api/1/generic/private/orders"

// TODO rewrite error handling code

type MtGox struct {
  client      HTTPClient
  domain      string
  key         string
  secret      string
  quoteTime   time.Time
  depth       SimpleBook
  orders      SimpleBook
  trades      []Trade
  fee         float64
  balance     map[Currency]float64
}

func NewMtGox() *MtGox {
  var x MtGox
  x.client = NewOxyHTTPClient()
  x.domain = MTGOX_DOMAIN
  x.key = MTGOX_KEY
  x.secret = MTGOX_SECRET
  x.depth = *NewSimpleBook()
  x.orders = *NewSimpleBook()
  x.fee = -1
  x.balance = make(map[Currency]float64)

  return &x
}

func (x *MtGox) SetHTTPClient(client HTTPClient) {
  x.client = client
}

func (x *MtGox) GetResponses() {
  var order = map[string]interface{} {
    "type" : "bid",
    "amount_int" : 10000000,
    "price_int" : 1,
  }

  x.request(MTGOX_TRADE, order)

  fmt.Println(MTGOX_FULLDEPTH)
  x.request(MTGOX_FULLDEPTH, nil)
  fmt.Println("-----------------")
  fmt.Println(MTGOX_TRADES)
  x.request(MTGOX_TRADES, nil)
  fmt.Println("-----------------")
  fmt.Println(MTGOX_TICKER)
  x.request(MTGOX_TICKER, nil)
  fmt.Println("-----------------")
  fmt.Println(MTGOX_INFO)
  x.request(MTGOX_INFO, nil)
  fmt.Println("-----------------")
  fmt.Println(MTGOX_ORDERS)
  x.request(MTGOX_ORDERS, nil)
}

func (x *MtGox) GetOrders() SimpleBook {
  return x.orders
}

func (x *MtGox) GetDepth() *SimpleBook {
  return &x.depth
}

func (x *MtGox) GetTrades() []Trade {
  return x.trades
}

func (x *MtGox) GetFee() float64 {
  return x.fee
}

func (x *MtGox) GetBalance(c Currency) float64 {
  return x.balance[c]
}

func (x *MtGox) GetLast() float64 {
  if len(x.trades) == 0 {
    return -1
  }

  return x.trades[0].Price
}

func (x *MtGox) GetMidpoint() float64 {
  bid, err1 := x.depth.Bid()
  ask, err2 := x.depth.Ask()

  if err1 != nil || err2 != nil {
    return -1
  }

  return (bid.Price + ask.Price) / 2
}

func (x *MtGox) FetchOrders() error {
  r := x.request(MTGOX_ORDERS, nil).([]interface{})
  x.orders.Clear()

  for _, o := range r {
    order := o.(map[string]interface{})
    priceBlock := order["price"].(map[string]interface{})
    price, err := strconv.ParseFloat(priceBlock["value"].(string), 64)

    if err != nil {
      return err
    }

    sizeBlock := order["amount"].(map[string]interface{})
    size, err := strconv.ParseFloat(sizeBlock["value"].(string), 64)

    if err != nil {
      return err
    }

    orderType := order["type"].(string)
    timestamp := time.Unix(int64(order["date"].(float64)), 0).UTC()

    q := NewQuote(price, size, (orderType == "bid"))
    q.Start = timestamp
    x.orders.Add(q)
  }

  return nil
}

func (x *MtGox) FetchTrades() error {
  r := x.request(MTGOX_TRADES, nil).([]interface{})
  x.trades = x.trades[:0]

  for _, t := range r {
    tradeDoc := t.(map[string]interface{})
    price, err := strconv.ParseFloat(tradeDoc["price"].(string), 64)

    if err != nil {
      return err
    }

    size, err := strconv.ParseFloat(tradeDoc["amount"].(string), 64)

    if err != nil {
      return err
    }

    err, currency := CastCurrency(tradeDoc["price_currency"].(string))

    if err != nil {
      return err
    }

    tradeType := tradeDoc["trade_type"].(string)
    var isBuy bool

    if tradeType == "bid" {
      isBuy = true
    } else if tradeType == "ask" {
      isBuy = false
    } else {
      return errors.New("invalid trade_type")
    }

    timestamp := time.Unix(int64(tradeDoc["date"].(float64)), 0).UTC()
    trade := NewTrade(price, size, currency, isBuy, timestamp)
    x.trades = append(x.trades, trade)
  }

  return nil
}

func (x *MtGox) FetchAccounts() error {
  r := x.request(MTGOX_INFO, nil).(map[string]interface{})

  x.fee = r["Trade_Fee"].(float64)

  wallets := r["Wallets"].(map[string]interface{})

  for k, v := range wallets {
    err, currency := CastCurrency(k)

    if err != nil {
      return err
    }

    mapValue := v.(map[string]interface{})
    balance := mapValue["Balance"].(map[string]interface{})
    value, err := strconv.ParseFloat(balance["value"].(string), 64)

    if err != nil {
      return err
    }

    x.balance[currency] = value
  }

  return nil
}

func (x *MtGox) FetchDepth() error {
  r := x.request(MTGOX_FULLDEPTH, nil).(map[string]interface{})
  x.depth.Clear()

  bids := r["bids"].([]interface{})
  asks := r["asks"].([]interface{})

  for _, b := range bids {
    bid := b.(map[string]interface{})
    q := NewQuote(bid["price"].(float64), bid["amount"].(float64), true)
    t, err := strconv.ParseInt(bid["stamp"].(string), 10, 64)

    if err != nil {
      return err
    }

    q.Start = time.Unix(t / 1000000, t - (t / 1000000) * 1000000).UTC()
    x.depth.Add(q)
  }

  for _, a := range asks {
    ask := a.(map[string]interface{})
    q := NewQuote(ask["price"].(float64), ask["amount"].(float64), false)
    t, err := strconv.ParseInt(ask["stamp"].(string), 10, 64)

    if err != nil {
      return err
    }

    q.Start = time.Unix(t / 1000000, t - (t / 1000000) * 1000000).UTC()
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

func (x *MtGox) request(path string, args map[string]interface{}) interface{} {
  if args == nil {
    args = make(map[string]interface{})
  }

  args["nonce"] = fmt.Sprintf("%d", time.Now().UnixNano())

  strargs := urlEncode(args)
  req, _ := http.NewRequest("POST", x.domain + path, strings.NewReader(strargs))
  secret, _ := base64.StdEncoding.DecodeString(x.secret)

  var h hash.Hash = hmac.New(sha512.New, secret)
  h.Write([]byte(strargs))
  signature := base64.StdEncoding.EncodeToString(h.Sum(nil))

  req.Header.Add("Rest-Key", x.key)
  req.Header.Add("Rest-Sign", signature)
  req.Header.Add("Content-type", "application/x-www-form-urlencoded")

  body, err := x.client.Do(req)

  if err != nil {
    return nil
  }

  var v map[string]interface{}
  err = json.Unmarshal([]byte(body), &v)

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
    return v["return"].(interface{})
  } else {
    return v
  }

  return nil
}
