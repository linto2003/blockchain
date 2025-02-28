package main

import (
	"encoding/json"
	"fmt"
	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

type OrderFulfillment struct {
	contractapi.Contract
}

type Dispatch struct {
	OrderID   string `json:"orderId"`
	PharmacistID string `json:"pharmacistId"`
	Status    string `json:"status"`
}

// ✅ Dispatch Order
func (of *OrderFulfillment) DispatchOrder(ctx contractapi.TransactionContextInterface, orderID, pharmacistID string) error {
	dispatch := Dispatch{OrderID: orderID, PharmacistID: pharmacistID, Status: "Dispatched"}
	dispatchJSON, _ := json.Marshal(dispatch)
	return ctx.GetStub().PutState(orderID, dispatchJSON)
}

// ✅ Query Dispatch
func (of *OrderFulfillment) QueryDispatch(ctx contractapi.TransactionContextInterface, orderID string) (*Dispatch, error) {
	dispatchJSON, _ := ctx.GetStub().GetState(orderID)
	if dispatchJSON == nil {
		return nil, fmt.Errorf("Dispatch record not found")
	}
	var dispatch Dispatch
	json.Unmarshal(dispatchJSON, &dispatch)
	return &dispatch, nil
}

func main() {
	chaincode, _ := contractapi.NewChaincode(new(OrderFulfillment))
	chaincode.Start()
}
