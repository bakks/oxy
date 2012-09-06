package oxy

func Run() {
  var exch *MtGox = NewMtGox()
  exch.AddOrder(true, 0.000001, 0.000001)
  exch.FetchOrders()
  exch.GetOrders().Print()
  order, err := exch.GetOrders().Bid()

  if err != nil {
    return
  }

  exch.CancelOrder(order.ExtId)
}

