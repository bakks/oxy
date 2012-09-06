package oxy

import "fmt"
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

func (x *SimpleBook) Clear() {
  x.bids = x.bids[:0]
  x.asks = x.asks[:0]
}

func (x *SimpleBook) Add(quote Quote) {
  if quote.IsBuy {
    if len(x.bids) == 0 || quote.Price < x.bids[len(x.bids)-1].Price {
      x.bids = append(x.bids, quote)
    } else {
      i := 0
      for ; quote.Price < x.bids[i].Price; i++ {}

      x.bids = sliceInsert(x.bids, i, quote)
    }
  } else {
    if len(x.asks) == 0 || quote.Price > x.asks[len(x.asks)-1].Price {
      x.asks = append(x.asks, quote)
    } else {
      i := 0
      for ; quote.Price > x.asks[i].Price; i++ {}

      x.asks = sliceInsert(x.asks, i, quote)
    }
  }
}

func (x *SimpleBook) BidsLength() int {
  return len(x.bids)
}

func (x *SimpleBook) AsksLength() int {
  return len(x.asks)
}

func (x *SimpleBook) GetBid(i int) (Quote, error) {
  if i >= len(x.bids) {
    return EmptyQuote(), errors.New("Invalid bid")
  }
  return x.bids[i], nil
}

func (x *SimpleBook) GetAsk(i int) (Quote, error) {
  if i >= len(x.asks) {
    return EmptyQuote(), errors.New("Invalid ask")
  }
  return x.asks[i], nil
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

func (x *SimpleBook) Print() {
  fmt.Println("--- book -------------------")

  for i := len(x.asks) - 1; i >= 0; i-- {
    fmt.Printf("ask\t%'4d\t%'4d\n", x.asks[i].Price, x.asks[i].Size)
  }

  for i := 0; i < len(x.bids); i++ {
    fmt.Printf("bid\t%'4d\t%'4d\n", x.bids[i].Price, x.bids[i].Size)
  }
  fmt.Println("----------------------------")
}


