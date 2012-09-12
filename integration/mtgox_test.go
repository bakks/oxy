package oxy

import "testing"
import "strconv"
import "../oxy"

func TestFetchAccounts(t *testing.T) {
  x := oxy.NewMtGox()
  err := x.FetchAccounts()

  if err != nil {
    t.Error("could not fetch accounts")
  }

  if x.GetFee() <= 0.0 {
    x := strconv.FormatFloat(x.GetFee(), 'f', 4, 64)
    t.Error("invalid trading fee: " + x)
  }

  btc := x.GetBalance(oxy.BTC)
  if btc <= 0 {
    x := strconv.FormatFloat(btc, 'f', 4, 64)
    t.Error("invalid BTC balance: " + x)
  }

  usd := x.GetBalance(oxy.USD)
  if usd <= 0 {
    x := strconv.FormatFloat(usd, 'f', 4, 64)
    t.Error("invalid USD balance: " + x)
  }
}

func TestFetchDepth(t *testing.T) {
  x := oxy.NewMtGox()

  err := x.FetchDepth()

  if err != nil {
    t.Error("could not fetch depth")
  }

  book := x.GetDepth()

  if book.BidsLength() < 1 || book.BidsLength() > 99999 {
    t.Error("bad number of bids: " + strconv.Itoa(book.BidsLength()))
  }

  if book.AsksLength() < 1 || book.AsksLength() > 99999 {
    t.Error("bad number of asks: " + strconv.Itoa(book.AsksLength()))
  }
}

func TestAddCancel(t *testing.T) {
  x := oxy.NewMtGox()

  err := x.FetchOrders()
  if err != nil { t.Error("couldn't fetch orders", err) }
  err = x.CancelAll()
  if err != nil { t.Error("couldn't cancel orders", err) }
  err = x.FetchOrders()
  if err != nil { t.Error("couldn't fetch orders", err) }

  if x.GetOrders().BidsLength() != 0 || x.GetOrders().BidsLength() != 0 {
    t.Error("did not cancel all orders")
  }

  BID_PRICE := 0.1
  ASK_PRICE := 999999999.0

  err = x.AddOrder(true, BID_PRICE, 0.1)
  if err != nil { t.Error("couldn't add order", err) }
  err = x.AddOrder(false, ASK_PRICE, 0.1)
  if err != nil { t.Error("couldn't add order", err) }

  err = x.FetchOrders()
  if err != nil { t.Error("couldn't fetch orders", err) }

  if x.GetOrders().BidsLength() != 1 {
    t.Error("did not add bid")
  }

  if x.GetOrders().AsksLength() != 1 {
    t.Error("did not add ask")
  }

  bid, _ := x.GetOrders().Bid()

  if bid.Price != BID_PRICE || bid.Size != 0.1 {
    t.Error("incorrect bid added")
  }

  ask, _ := x.GetOrders().Ask()

  if ask.Price != ASK_PRICE || ask.Size != 0.1 {
    t.Error("incorrect ask added")
  }

  err = x.CancelAll()
  if err != nil { t.Error("couldn't cancel orders", err) }
  err = x.FetchOrders()
  if err != nil { t.Error("couldn't fetch orders", err) }

  if x.GetOrders().BidsLength() != 0 || x.GetOrders().BidsLength() != 0 {
    t.Error("did not cancel all orders")
  }
}


