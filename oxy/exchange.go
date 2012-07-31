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

func NewQuote(price, size float64, isBuy bool) Quote {
  return Quote{price: price, size: size, isBuy: isBuy, currency: USD}
}

func EmptyQuote() Quote {
  return NewQuote(0, 0, true)
}


