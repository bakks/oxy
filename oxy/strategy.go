package oxy

import "fmt"

type Strategy struct {
  exch            Exchange
  TakeRate        float64
  TakeIncrement   float64
  Levels          int
  DefaultSize     float64
  PriceThreshold  float64
}

func NewStrategy(exchange Exchange) *Strategy {
  var x Strategy

  x.TakeRate        = 0.1
  x.TakeIncrement   = 0.2
  x.Levels          = 1
  x.DefaultSize     = 1.0
  x.PriceThreshold  = 0.005

  x.exch = exchange

  return &x
}

func (x *Strategy) Run() {
}

func (x *Strategy) Initialize() {
  err := x.exch.FetchDepth()
  if err != nil {
    panic("problem initializing strategy: " + err.Error())
  }

  err = x.exch.FetchAccounts()
  if err != nil {
    panic("problem initializing strategy: " + err.Error())
  }

  err = x.exch.FetchOrders()
  if err != nil {
    panic("problem initializing strategy: " + err.Error())
  }

  err = x.exch.CancelAll()
  if err != nil {
    panic("problem initializing strategy: " + err.Error())
  }

  err = x.exch.FetchOrders()
  if err != nil {
    panic("problem initializing strategy: " + err.Error())
  }
}

func (x *Strategy) iteration() {
  err := x.exch.FetchDepth()

  if err != nil {
    fmt.Println("error in strategy iteration: " + err.Error())
    return
  }

  book := x.CreateOrderBook()
  err = x.exch.SetOrders(book, x.PriceThreshold)

  if err != nil {
    fmt.Println("error setting order book: " + err.Error())
    return
  }
}

func (x *Strategy) CreateOrderBook() *SimpleBook {
  fee := x.exch.GetFee()
  if fee < 0 || fee > 0.2 {
    panic("possibly incorrect trading fee: " + ftoa(fee))
  }

  midpt := x.exch.GetMidpoint()
  if midpt < 0 {
    panic("incorrect midpoint: " + ftoa(midpt))
  }

  book := NewSimpleBook()

  for i := 0; i < x.Levels; i++ {
    halfSpreadPerc := fee * (1 + x.TakeRate + x.TakeIncrement * float64(i))
    halfSpread := midpt * halfSpreadPerc
    bidPrice := midpt - halfSpread
    askPrice := midpt + halfSpread

    bid := NewQuote(bidPrice, x.DefaultSize, true)
    book.Add(bid)

    ask := NewQuote(askPrice, x.DefaultSize, false)
    book.Add(ask)
  }

  return book
}

