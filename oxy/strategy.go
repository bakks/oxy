package oxy

import "fmt"

func Run() {
  var exch Exchange = NewMtGox()
  fmt.Println(exch.GetFee())
}

