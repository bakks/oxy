package oxy

func Run() {
  var exch Exchange = NewMtGox()

  exch.Info()
  exch.Balance()
}

