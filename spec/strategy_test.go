package oxy

import "testing"
import "../oxy"

// assumes levels == 1
func TestStrategy(t *testing.T) {
  exch := oxy.NewMtGox()
  exch.SetHTTPClient(NewTestHTTPClient())
  strat := oxy.NewStrategy(exch)
  strat.Initialize()
  book := strat.CreateOrderBook()

  if book.BidsLength() != 1 {
    t.Error("too many bids")
  }

  if book.AsksLength() != 1 {
    t.Error("too many asks")
  }

  fee := 0.006
  midpt := 10.8315

  if exch.GetMidpoint() != midpt {
    t.Error("incorrect test midpoint: " + ftoa(exch.GetMidpoint()))
  }

  bid, err := book.Bid()

  if err != nil {
    t.Error("get bid error")
  }

  if bid.Size != strat.DefaultSize {
    t.Error("incorrect bid size")
  }

  targetBidPrice := midpt - midpt * fee * (1 + strat.TakeRate)
  if bid.Price != targetBidPrice {
    t.Error("incorrect bid price: expected " + ftoa(targetBidPrice) + " got " + ftoa(bid.Price))
  }

  ask, err := book.Ask()

  if err != nil {
    t.Error("get ask error")
  }

  if ask.Size != strat.DefaultSize {
    t.Error("incorrect ask size")
  }

  targetAskPrice := midpt + midpt * fee * (1 + strat.TakeRate)
  if ask.Price != targetAskPrice {
    t.Error("incorrect ask price: expected " + ftoa(targetAskPrice) + " got " + ftoa(ask.Price))
  }

  if targetAskPrice < targetBidPrice || ask.Price < bid.Price {
    t.Error("crossed orders bid " + ftoa(targetBidPrice) + " ask " + ftoa(targetAskPrice))
  }
}

