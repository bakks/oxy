package mtgox

import "fmt"
import "strings"
import "time"
import "io/ioutil"
import "net/http"
import "net/url"
import "hash"
import "crypto/sha512"
import "crypto/hmac"
import "encoding/base64"

const MTGOX_KEY string = "7d71c7f4-7ff3-454e-87a5-6851a4962edf"
const MTGOX_SECRET string = "KjUXf1eyq/JgX3+LFVm4BzrpQIeqx02YI9LveEzfIO37PQ8Dy8fIFlO8s84eARM9LvVE/ujesyJf41j0y6fcGg=="

type MtGox struct {
  client *http.Client
  domain string
  key string
  secret string
  quotetime time.Time
}

func New() *MtGox {
  var x MtGox
  x.client = &http.Client{}
  x.domain = "https://mtgox.com"
  x.key = MTGOX_KEY
  x.secret = MTGOX_SECRET

  return &x
}

func (x *MtGox) Info() {
  x.request("/api/1/BTCUSD/ticker", nil)
}

func (x *MtGox) Balance() {
  x.request("/api/1/generic/private/info", nil)
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

func (x *MtGox) request(path string, args map[string]interface{}) string {
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

  r,err := x.client.Do(req)

  if err != nil {
    fmt.Println("error", err)
    return ""
  }

  defer r.Body.Close()

  body,_ := ioutil.ReadAll(r.Body)
  fmt.Println(string(body))
  return string(body)
}
