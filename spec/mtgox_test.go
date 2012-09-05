package oxy

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

  bid := orders.GetBid(0)

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
}

func ftoa(x float64) string {
  return strconv.FormatFloat(x, 'f', 5, 64)
}

func iso8601(x string) time.Time {
  str, _ := time.Parse(time.RFC3339, x)
  return str
}

func TestFetchTrades(t *testing.T) {
  mtgox.SetHTTPClient(NewTestHTTPClient())
  mtgox.FetchTrades()
  trades := mtgox.GetTrades()

  if len(trades) < 500 {
    t.Error("did not fetch enough trades")
  }

  bids := 0
  asks := 0
  
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

  for _, trade := range trades {
    if trade.Price < 0.001 || trade.Price > 99999 {
      t.Error("extreme price: " + ftoa(trade.Price))
    }

    if trade.Size < 0.001 || trade.Size > 99999 {
      t.Error("extreme size: " + ftoa(trade.Price))
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
       trade.Timestamp.Unix() > iso8601("2015-01-01T00:00:00Z").Unix() {
      t.Error("extreme timestamp: " + trade.Timestamp.Format(time.RFC3339))
    }
  }

  if bids < 200 || asks < 200 {
    t.Error("unbalanced bids and asks: bids " + strconv.Itoa(bids) + " asks " + strconv.Itoa(asks))
  }
}

func TestFetchAccounts(t *testing.T) {
  mtgox.SetHTTPClient(NewTestHTTPClient())
  mtgox.FetchAccounts()
}

func TestFetchDepth(t *testing.T) {
  mtgox.SetHTTPClient(NewTestHTTPClient())
  mtgox.FetchDepth()
}

