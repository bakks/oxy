package oxy

import "testing"
import "../oxy"

func TestMtGoxParsing(t *testing.T) {
  mtgox := oxy.NewMtGox()
  mtgox.SetHTTPClient(NewTestHTTPClient())

  mtgox.FetchOrders()
  mtgox.FetchTrades()
  mtgox.FetchAccounts()
  mtgox.FetchDepth()
}

