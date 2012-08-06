package oxy

import "testing"
import "../oxy"

func TestNewSimpleBook(t *testing.T) {
  oxy.NewSimpleBook()
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
    if int(book.GetBid(i).Price) != int(last - 1) {
      t.Error("broken book")
    }

    last = book.GetBid(i).Price
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
    if int(book.GetAsk(i).Price) != int(last + 1) {
      t.Error("broken book")
    }

    last = book.GetAsk(i).Price
  }
}
