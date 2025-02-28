package main

import (
	"encoding/json"
	"fmt"
	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

type MedicineDelivery struct {
	contractapi.Contract
}

type Delivery struct {
	DeliveryID string `json:"deliveryId"`
	OrderID    string `json:"orderId"`
	PartnerID  string `json:"partnerId"`
	Status     string `json:"status"`
}

// ✅ Update Delivery Status
func (md *MedicineDelivery) UpdateDelivery(ctx contractapi.TransactionContextInterface, deliveryID, orderID, partnerID, status string) error {
	delivery := Delivery{DeliveryID: deliveryID, OrderID: orderID, PartnerID: partnerID, Status: status}
	deliveryJSON, _ := json.Marshal(delivery)
	return ctx.GetStub().PutState(deliveryID, deliveryJSON)
}

// ✅ Query Delivery
func (md *MedicineDelivery) QueryDelivery(ctx contractapi.TransactionContextInterface, deliveryID string) (*Delivery, error) {
	deliveryJSON, _ := ctx.GetStub().GetState(deliveryID)
	if deliveryJSON == nil {
		return nil, fmt.Errorf("Delivery not found")
	}
	var delivery Delivery
	json.Unmarshal(deliveryJSON, &delivery)
	return &delivery, nil
}


func main() {
	chaincode, _ := contractapi.NewChaincode(new(MedicineDelivery))
	chaincode.Start()
}
