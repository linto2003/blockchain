package main

import (
	"fmt"
	"encoding/json"
	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

type OrderProcessing struct {
	contractapi.Contract
}

type Order struct {
	OrderID    string `json:"orderId"`
	UserID     string `json:"userId"`
	Medicine   string `json:"medicine"`
	Quantity   int    `json:"quantity"`
	Status     string `json:"status"`
}

// ✅ Place Order
func (op *OrderProcessing) PlaceOrder(ctx contractapi.TransactionContextInterface, orderID, userID, medicine string, quantity int) error {
	order := Order{OrderID: orderID, UserID: userID, Medicine: medicine, Quantity: quantity, Status: "Pending"}
	orderJSON, _ := json.Marshal(order)
	return ctx.GetStub().PutState(orderID, orderJSON)
}

// ✅ Query Order
func (op *OrderProcessing) QueryOrder(ctx contractapi.TransactionContextInterface, orderID string) (*Order, error) {
	orderJSON, err := ctx.GetStub().GetState(orderID)
	if err != nil || orderJSON == nil {
		return nil, fmt.Errorf("order not found")
	}
	var order Order
	json.Unmarshal(orderJSON, &order)
	return &order, nil
}

func main() {
	chaincode, _ := contractapi.NewChaincode(new(OrderProcessing))
	chaincode.Start()
}
