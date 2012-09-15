package oxy

import "fmt"
import "testing"
import "strconv"
import "time"
import "../oxy"

var mtgox *oxy.MtGox = oxy.NewMtGox()

func TestFetchOrders(t *testing.T) {
  mtgox.SetHTTPClient(NewTestHTTPClient())
  mtgox.FetchOrders()
  orders := mtgox.GetOrders()

  if orders.BidsLength() != 1 || orders.AsksLength() != 0 {
    t.Error("did not fetch correct number of orders")
  }

  bid, _ := orders.GetBid(0)

  if bid.Price != 0.00001 {
    t.Error("did not parse order price correctly")
  }

  if bid.Size != 0.1 {
    t.Error("did not parse order size correctly")
  }

  if !bid.IsBuy {
    t.Error("bid order should have correct IsBuy value")
  }

  if bid.Start.Unix() != 1346373055 {
    t.Error("incorrect order timestamp " + strconv.Itoa(int(bid.Start.Unix())))
  }

  if bid.ExtId != "f4a11c80-a27e-40a7-9913-2706f79ef1f6" {
    t.Error("incorrect external id: " + bid.ExtId)
  }
}

func ftoa(x float64) string {
  return strconv.FormatFloat(x, 'f', 5, 64)
}

func iso8601(x string) time.Time {
  str, _ := time.Parse(time.RFC3339, x)
  return str
}

func VerifyTrades(trades []oxy.Trade, t *testing.T) {
  bids := 0
  asks := 0

  for _, trade := range trades {
    if trade.Price < 0.001 || trade.Price > 99999 {
      t.Error("extreme price: " + ftoa(trade.Price))
    }

    if trade.Size < 0.0000001 || trade.Size > 99999 {
      t.Error("extreme size: " + ftoa(trade.Size))
    }

    if trade.Currency != oxy.USD {
      t.Error("weird currency: " + oxy.CurrencyString(trade.Currency))
    }

    if trade.IsBuy {
      bids++
    } else {
      asks++
    }

    if trade.Timestamp.Unix() < iso8601("2012-01-01T00:00:00Z").Unix() ||
       trade.Timestamp.Unix() > time.Now().Unix() {
      t.Error("extreme timestamp: " + trade.Timestamp.Format(time.RFC3339))
    }
  }

  if bids < 200 || asks < 200 {
    t.Error("unbalanced bids and asks: bids " + strconv.Itoa(bids) + " asks " + strconv.Itoa(asks))
  }
}

func TestFetchTrades(t *testing.T) {
  mtgox.SetHTTPClient(NewTestHTTPClient())
  mtgox.FetchTrades()
  trades := mtgox.GetTrades()

  if len(trades) < 500 {
    t.Error("did not fetch enough trades")
  }

  trade := trades[0]

  if trade.Price != 10.8999 {
    t.Error("did not parse price correctly")
  }

  if trade.Size != 21.80517958 {
    t.Error("did not parse size correctly")
  }

  if trade.Currency != oxy.USD {
    t.Error("did not parse currency correctly")
  }

  if !trade.IsBuy {
    t.Error("did not parse side correctly")
  }

  if trade.Timestamp.Unix() != 1346286717 {
    t.Error("did not parse timestamp correctly")
  }

  VerifyTrades(trades, t)
}

func VerifyAccounts(mtgox *oxy.MtGox, t *testing.T) {
  fee := mtgox.GetFee()
  if fee <= 0 || fee >= 1 {
    t.Error("extreme fee value: " + ftoa(fee))
  }

  usd := mtgox.GetBalance(oxy.USD)
  if usd <= 0 || usd > 5000 {
    t.Error("extreme USD balance: " + ftoa(usd))
  }

  btc := mtgox.GetBalance(oxy.BTC)
  if btc <= 0 || btc > 1000 {
    t.Error("extreme BTC balance: " + ftoa(btc))
  }
}

func TestFetchAccounts(t *testing.T) {
  mtgox.SetHTTPClient(NewTestHTTPClient())
  mtgox.FetchAccounts()

  if mtgox.GetFee() != 0.006 {
    t.Error("incorrect fee value: " + ftoa(mtgox.GetFee()))
  }

  if mtgox.GetBalance(oxy.USD) != 22.01601 {
    t.Error("incorrect USD balance: " + ftoa(mtgox.GetBalance(oxy.USD)))
  }

  if mtgox.GetBalance(oxy.BTC) != 25.035 {
    t.Error("incorrect BTC balance: " + ftoa(mtgox.GetBalance(oxy.BTC)))
  }

  VerifyAccounts(mtgox, t)
}

func VerifyQuote(quote oxy.Quote, isBuy bool, t *testing.T) {
  if quote.Price < 0.00001 || quote.Price > 10000000 {
    fmt.Println("extreme price: " + ftoa(quote.Price))
  }

  if quote.Size < 0.00001 || quote.Size > 100000 {
    fmt.Println("extreme size: " + ftoa(quote.Size))
  }

  if quote.IsBuy != isBuy {
    t.Error("incorrect side")
  }

  if quote.Currency != oxy.USD {
    t.Error("weird currency: " + oxy.CurrencyString(quote.Currency))
  }

  if quote.Start.Unix() < iso8601("2011-01-01T00:00:00Z").Unix() ||
     quote.Start.Unix() > time.Now().Unix() {
    t.Error("extreme timestamp: " + quote.Start.Format(time.RFC3339))
  }
}

func VerifyDepth(book *oxy.SimpleBook, t *testing.T) {
  bid, _ := book.Bid()
  ask, _ := book.Ask()

  if bid.Price > ask.Price {
    t.Error("crossed book")
  }

  if bid.Price + 2 < ask.Price {
    t.Error("wide spread")
  }

  if book.BidsLength() < 500 {
    t.Error("book has few bids: " + strconv.Itoa(book.BidsLength()))
  }

  if book.AsksLength() < 500 {
    t.Error("book has few asks: " + strconv.Itoa(book.AsksLength()))
  }

  for i := 0; i < book.BidsLength(); i++ {
    bid, _ := book.GetBid(i)
    VerifyQuote(bid, true, t)
  }

  for i := 0; i < book.AsksLength(); i++ {
    ask, _ := book.GetAsk(i)
    VerifyQuote(ask, false, t)
  }
}

func TestFetchDepth(t *testing.T) {
  mtgox.SetHTTPClient(NewTestHTTPClient())
  mtgox.FetchDepth()

  VerifyDepth(mtgox.GetDepth(), t)

  bid, _ := mtgox.GetDepth().GetBid(0)
  ask, _ := mtgox.GetDepth().GetAsk(0)

  if bid.Price != 10.7931 {
    t.Error("incorrect bid price: " + ftoa(bid.Price))
  }

  if bid.Size != 14.08249999 {
    t.Error("incorrect bid size: " + ftoa(bid.Size))
  }

  if !bid.IsBuy {
    t.Error("incorrect bid side")
  }

  if bid.Currency != oxy.USD {
    t.Error("incorrect bid currency")
  }

  if bid.Start.Unix() != 1344229187 {
    t.Error("incorrect start time: " + strconv.Itoa(int(bid.Start.Unix())))
  }

  if ask.Price != 10.8699 {
    t.Error("incorrect ask price: " + ftoa(bid.Price))
  }

  if ask.Size != 2.99 {
    t.Error("incorrect ask size: " + ftoa(bid.Size))
  }

  if ask.IsBuy {
    t.Error("incorrect ask side")
  }

  if ask.Currency != oxy.USD {
    t.Error("incorrect ask currency")
  }

  if ask.Start.Unix() != 1344229184 {
    t.Error("incorrect start time: " + strconv.Itoa(int(ask.Start.Unix())))
  }

}

