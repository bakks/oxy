package oxy

import "./mtgox"

func Run() {
  var exch Exchange = mtgox.New()

  exch.Info()
  exch.Balance()
}

