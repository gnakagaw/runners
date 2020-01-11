package main

import (
	"errors"
	"fmt"
)

func main() {
	validate(1)
}

func validate(num int) error {
	if num < 0 {
		return errors.New("error")
	}
	fmt.Println("ok")
	return nil
}
