package main

import (
	"bufio"
	"fmt"
	"net"
	"os"
	"strings"
)

func main() {
	arguments := os.Args
	if len(arguments) == 1 {
		fmt.Println("Please provide host:port.")
		return
	}

	CONNECT := arguments[1]
	c, err := net.Dial("tcp", CONNECT)
	if err != nil {
		fmt.Println("Error: Cannot connect to server")
		return
	}

	// Initial message
	fmt.Println("Connecting, please wait...")
	message, connectErr := bufio.NewReader(c).ReadString('\n')
	if connectErr != nil {
		fmt.Println("Error: Cannot receive server's response")
		return
	}
	fmt.Println(message)

	// Command loop
	for {
		reader := bufio.NewReader(os.Stdin)
		fmt.Print(">> ")
		text, _ := reader.ReadString('\n')
		fmt.Fprintf(c, text+"\n")
		for {
			message, _ = bufio.NewReader(c).ReadString('\n')
			message = strings.TrimSpace(string(message))
			if message == "###STOP" {
				break
			} else {
				fmt.Println(message)
			}
		}
	}
}
