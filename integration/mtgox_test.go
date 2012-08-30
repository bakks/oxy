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

  book := x.Depth()

  if book.BidsLength() < 1 || book.BidsLength() > 99999 {
    t.Error("bad number of bids: " + strconv.Itoa(book.BidsLength()))
  }

  if book.AsksLength() < 1 || book.AsksLength() > 99999 {
    t.Error("bad number of asks: " + strconv.Itoa(book.AsksLength()))
  }
}


