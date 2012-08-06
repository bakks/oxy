package oxy

import "time"

type Currency int32
const BTC Currency = 0
const USD Currency = 1

type Exchange interface {
  Info()
  Balance()
}


type Trade struct {
  Price     float64
  Size      float64
  Buy       Currency
  Sell      Currency
}

type Quote struct {
  Price     float64
  Size      float64
  IsBuy     bool
  Currency  Currency
  Start     time.Time
  End       time.Time
}

func NewQuote(price, size float64, isBuy bool) Quote {
  return Quote{Price: price, Size: size, IsBuy: isBuy, Currency: USD}
}

func EmptyQuote() Quote {
  return NewQuote(0, 0, true)
}


