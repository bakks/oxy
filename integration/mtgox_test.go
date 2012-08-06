package oxy

import "testing"
import "strconv"
import "../oxy"

func TestFetchDepth(t *testing.T) {
  x := oxy.NewMtGox()

  x.FetchDepth()
  book := x.Depth()

  if book.BidsLength() < 1 || book.BidsLength() > 99999 {
    t.Error("bad number of bids: " + strconv.Itoa(book.BidsLength()))
  }

  if book.AsksLength() < 1 || book.AsksLength() > 99999 {
    t.Error("bad number of asks: " + strconv.Itoa(book.AsksLength()))
  }
}


