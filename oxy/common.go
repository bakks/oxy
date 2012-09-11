package oxy

import "time"
import "errors"
import "strconv"
import "net/http"

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

func CurrencyString(c Currency) string {
  switch c {
    case BTC: return "BTC"
    case USD: return "USD"
  }

  return strconv.Itoa(int(c))
}

type Exchange interface {
  FetchDepth() error
  FetchOrders() error
  FetchAccounts() error
  FetchTrades() error
  GetDepth() *SimpleBook
  GetOrders() *SimpleBook
  GetTrades() []Trade
  GetFee() float64
  GetBalance(Currency) float64
  GetMidpoint() float64
  GetLast() float64
}

type HTTPClient interface {
  Do(*http.Request) (string, error)
}

type Trade struct {
  Price     float64
  Size      float64
  Currency  Currency
  IsBuy     bool
  Timestamp time.Time
}

type Quote struct {
  Price     float64
  Size      float64
  IsBuy     bool
  Currency  Currency
  Start     time.Time
  End       time.Time
  ExtId     string
}

func NewQuote(price, size float64, isBuy bool) Quote {
  return Quote{Price: price, Size: size, IsBuy: isBuy, Currency: USD}
}

func EmptyQuote() Quote {
  return NewQuote(0, 0, true)
}

func NewTrade(price, size float64, c Currency, isBuy bool, timestamp time.Time) Trade {
  return Trade{Price: price, Size: size, Currency: c, IsBuy: isBuy, Timestamp: timestamp}
}

