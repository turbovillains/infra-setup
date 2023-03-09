package main

import (
	"os"
	"fmt"
	"strings"
	"hash/fnv"
	"encoding/base32"
)

var encoding = base32.NewEncoding("abcdefghijklmnopqrstuvwxyz234567")

func main() {
	if len(os.Args) < 2 {
		fmt.Print("Insert the client name as parameter")
		os.Exit(1)
	}
	toDecodeString := []byte(os.Args[1])
	encodedString := strings.TrimRight(encoding.EncodeToString(fnv.New64().Sum(toDecodeString)), "=")
	fmt.Print(encodedString)
}
