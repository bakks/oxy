package oxy

import "testing"

func TestNewSimpleBook(t *testing.T) {
  NewSimpleBook()
}

func TestSimpleBookBids(t *testing.T) {
  q1 := NewQuote(5, 1, true)
  q2 := NewQuote(4, 1, true)
  q3 := NewQuote(3, 1, true)
  q4 := NewQuote(2, 1, true)
  q5 := NewQuote(1, 1, true)

  book := NewSimpleBook()

  book.AddQuote(q2)
  book.AddQuote(q5)
  book.AddQuote(q1)
  book.AddQuote(q3)
  book.AddQuote(q4)

  var last float64 = 6

  for i := 0; i < len(book.bids); i++ {
    if int(book.bids[i].price) != int(last - 1) {
      t.Error("broken book")
    }

    last = book.bids[i].price
  }
}

func TestSimpleBookAsks(t *testing.T) {
  q1 := NewQuote(1, 1, false)
  q2 := NewQuote(2, 1, false)
  q3 := NewQuote(3, 1, false)
  q4 := NewQuote(4, 1, false)
  q5 := NewQuote(5, 1, false)

  book := NewSimpleBook()

  book.AddQuote(q2)
  book.AddQuote(q5)
  book.AddQuote(q1)
  book.AddQuote(q3)
  book.AddQuote(q4)

  var last float64 = 0

  for i := 0; i < len(book.asks); i++ {
    if int(book.asks[i].price) != int(last + 1) {
      t.Error("broken book")
    }

    last = book.asks[i].price
  }
}
