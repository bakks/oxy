package oxy

func Run() {
  exch := NewMtGox()

  exch.Info()
  exch.Balance()
}

