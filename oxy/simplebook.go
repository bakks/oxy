package oxy

import "errors"

type SimpleBook struct {
  bids []Quote
  asks []Quote
}

func NewSimpleBook() *SimpleBook {
  x := SimpleBook{
    make([]Quote, 0, 512),
    make([]Quote, 0, 512),
  }

  return &x
}

func sliceInsert(s []Quote, index int, value Quote) []Quote {
  length := len(s)
  s = append(s, s[length - 1])

  for i := length - 2; i >= index; i-- {
    s[i+1] = s[i]
  }

  s[index] = value

  return s
}

func (x *SimpleBook) AddQuote(quote Quote) {
  if quote.isBuy {
    if len(x.bids) == 0 || quote.price < x.bids[len(x.bids)-1].price {
      x.bids = append(x.bids, quote)
    } else {
      i := 0
      for ; quote.price < x.bids[i].price; i++ {}

      x.bids = sliceInsert(x.bids, i, quote)
    }
  } else {
    if len(x.asks) == 0 || quote.price > x.asks[len(x.asks)-1].price {
      x.asks = append(x.asks, quote)
    } else {
      i := 0
      for ; quote.price > x.asks[i].price; i++ {}

      x.asks = sliceInsert(x.asks, i, quote)
    }
  }
}

func (x *SimpleBook) Bid() (Quote, error) {
  if len(x.bids) == 0 {
    return EmptyQuote(), errors.New("No valid bids")
  }

  return x.bids[0], nil
}

func (x *SimpleBook) Ask() (Quote, error) {
  if len(x.asks) == 0 {
    return EmptyQuote(), errors.New("No valid asks")
  }

  return x.asks[0], nil
}

