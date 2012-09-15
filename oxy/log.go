package oxy

import "log"

type FileWriter interface {
  file *File
}

func NewFileWriter(filename string) (*FileWriter, error) {
  f, err := os.Open(filename, os.O_APPEND, 0666) 
  defer f.Close()

  var x FileWriter
  x.file = f

  return &x, err
}

func (x *FileWriter) Write(p []byte) (n int, err error) {
  n, err := io.WriteString(f, string(p))
}

var LOG_WRITER *FileWriter = nil

func GetLogger(name string) log.Logger {
  if LOG_WRITER == nil {
    date := time.Now().Format(time.RFC3339)
    filename := "oxy." + date
    LOG_WRITER = NewFileWriter(filename)
  }

  log.New(LOG_WRITER, name, log.Ldate | log.Lmicroseconds)
}

