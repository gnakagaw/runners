package main

import (
	"fmt"
	"time"
)

type Person struct {
	age      int
	name     string
	birthDay time.Time
}

func main() {
	var p Person
	p.age = 28
	p.name = "John"
	fmt.Println("name:%\n", p.name)
}
