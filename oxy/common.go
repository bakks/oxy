package oxy

import "time"
import "errors"

type Currency int32
const BTC Currency = 0
const USD Currency = 1

func CastCurrency(currencyStr string) (error, Currency) {
  switch currencyStr {
    case "BTC": return nil, BTC
    case "USD": return nil, USD
  }

  return errors.New("could not match string to currency"), BTC
}

type Exchange interface {
  FetchDepth() error
  Depth() SimpleBook
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


