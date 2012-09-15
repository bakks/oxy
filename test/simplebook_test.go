package oxy

import "testing"
import "../oxy"

func TestNewSimpleBook(t *testing.T) {
  x := oxy.NewSimpleBook()

  if x.BidsLength() != 0 || x.AsksLength() != 0 {
    t.Error("did not init to empty")
  }

  _, err := x.Bid()

  if err == nil {
    t.Error("should have gotten error")
  }

  _, err = x.GetBid(0)

  if err == nil {
    t.Error("should have gotten error")
  }

  _, err = x.Ask()

  if err == nil {
    t.Error("should have gotten error")
  }

  _, err = x.GetAsk(0)

  if err == nil {
    t.Error("should have gotten error")
  }
}

func TestSimpleBookBids(t *testing.T) {
  q1 := oxy.NewQuote(5, 1, true)
  q2 := oxy.NewQuote(4, 1, true)
  q3 := oxy.NewQuote(3, 1, true)
  q4 := oxy.NewQuote(2, 1, true)
  q5 := oxy.NewQuote(1, 1, true)

  book := oxy.NewSimpleBook()

  book.Add(q2)
  book.Add(q5)
  book.Add(q1)
  book.Add(q3)
  book.Add(q4)

  var last float64 = 6

  for i := 0; i < book.BidsLength(); i++ {
    bid, err := book.GetBid(i)

    if err != nil {
      t.Error("unexpected error", err)
    }

    if int(bid.Price) != int(last - 1) {
      t.Error("broken book")
    }

    last = bid.Price
  }
}

func TestSimpleBookAsks(t *testing.T) {
  q1 := oxy.NewQuote(1, 1, false)
  q2 := oxy.NewQuote(2, 1, false)
  q3 := oxy.NewQuote(3, 1, false)
  q4 := oxy.NewQuote(4, 1, false)
  q5 := oxy.NewQuote(5, 1, false)

  book := oxy.NewSimpleBook()

  book.Add(q2)
  book.Add(q5)
  book.Add(q1)
  book.Add(q3)
  book.Add(q4)

  var last float64 = 0

  for i := 0; i < book.AsksLength(); i++ {
    ask, err := book.GetAsk(i)

    if err != nil {
      t.Error("unexpected error", err)
    }

    if int(ask.Price) != int(last + 1) {
      t.Error("broken book")
    }

    last = ask.Price
  }
}

func TestSimpleBookRemoves(t *testing.T) {
  q1 := oxy.NewQuote(5, 1, true)
  q2 := oxy.NewQuote(4, 1, true)
  q3 := oxy.NewQuote(3, 1, true)
  q4 := oxy.NewQuote(2, 1, true)
  q5 := oxy.NewQuote(1, 1, true)

  book := oxy.NewSimpleBook()

  book.Add(q2)
  book.Add(q5)
  book.Add(q1)
  book.Add(q3)
  book.Add(q4)

  result := book.Remove(q2)

  if !result {
    t.Error("remove failed")
  }

  bid, _ := book.GetBid(0)

  if !bid.Equals(q1) {
    t.Error("remove failed")
  }

  bid, _ = book.GetBid(1)

  if !bid.Equals(q3) {
    t.Error("remove failed")
  }

  result = book.Remove(q2)

  if result {
    t.Error("empty remove was successful")
  }
}
