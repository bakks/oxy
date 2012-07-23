package kilo

func Run() {
  exch := NewMtGox()

  exch.Info()
  exch.Balance()
}

