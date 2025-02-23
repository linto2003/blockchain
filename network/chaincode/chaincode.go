package main

import (
	"encoding/json"
	"fmt"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

// MedicineOrderChaincode defines the smart contract
type MedicineOrderChaincode struct {
	contractapi.Contract
}

// Order represents a medicine order
type Order struct {
	OrderID              string `json:"orderId"`
	CustomerID           string `json:"customerId"`
	MedicineName         string `json:"medicineName"`
	Quantity             int    `json:"quantity"`
	Location             string `json:"location"`
	RequiresPrescription bool   `json:"requiresPrescription"`
	PrescriptionCode     string `json:"prescriptionCode"`
	Status               string `json:"status"` // Created, Verified, Processed, Delivered
	PrescriptionVerified bool   `json:"prescriptionVerified"`
}

// CreateOrder creates a new medicine order
func (c *MedicineOrderChaincode) CreateOrder(ctx contractapi.TransactionContextInterface, orderID, customerID, medicineName, location string, quantity int, requiresPrescription bool, prescriptionCode string) error {
	exists, err := c.OrderExists(ctx, orderID)
	if err != nil {
		return err
	}
	if exists {
		return fmt.Errorf("order %s already exists", orderID)
	}

	order := Order{
		OrderID:              orderID,
		CustomerID:           customerID,
		MedicineName:         medicineName,
		Quantity:             quantity,
		Location:             location,
		RequiresPrescription: requiresPrescription,
		PrescriptionCode:     prescriptionCode,
		Status:               "Created",
		PrescriptionVerified: false,
	}

	orderJSON, err := json.Marshal(order)
	if err != nil {
		return err
	}

	return ctx.GetStub().PutState(orderID, orderJSON)
}

// VerifyPrescription verifies the prescription for the order
func (c *MedicineOrderChaincode) VerifyPrescription(ctx contractapi.TransactionContextInterface, orderID, prescriptionCode string) error {
	order, err := c.ReadOrder(ctx, orderID)
	if err != nil {
		return err
	}

	if !order.RequiresPrescription {
		return fmt.Errorf("order %s does not require a prescription", orderID)
	}

	if order.PrescriptionCode != prescriptionCode {
		return fmt.Errorf("prescription code does not match for order %s", orderID)
	}

	order.PrescriptionVerified = true
	order.Status = "Verified"

	orderJSON, err := json.Marshal(order)
	if err != nil {
		return err
	}

	return ctx.GetStub().PutState(orderID, orderJSON)
}

// ProcessOrder processes the order by the pharmacist
func (c *MedicineOrderChaincode) ProcessOrder(ctx contractapi.TransactionContextInterface, orderID string) error {
	order, err := c.ReadOrder(ctx, orderID)
	if err != nil {
		return err
	}

	if order.RequiresPrescription && !order.PrescriptionVerified {
		return fmt.Errorf("prescription for order %s has not been verified", orderID)
	}

	order.Status = "Processed"

	orderJSON, err := json.Marshal(order)
	if err != nil {
		return err
	}

	return ctx.GetStub().PutState(orderID, orderJSON)
}

// DeliverOrder marks the order as delivered by the delivery person
func (c *MedicineOrderChaincode) DeliverOrder(ctx contractapi.TransactionContextInterface, orderID string) error {
	order, err := c.ReadOrder(ctx, orderID)
	if err != nil {
		return err
	}

	if order.Status != "Processed" {
		return fmt.Errorf("order %s has not been processed yet", orderID)
	}

	order.Status = "Delivered"

	orderJSON, err := json.Marshal(order)
	if err != nil {
		return err
	}

	return ctx.GetStub().PutState(orderID, orderJSON)
}

// ReadOrder retrieves an order by its ID
func (c *MedicineOrderChaincode) ReadOrder(ctx contractapi.TransactionContextInterface, orderID string) (*Order, error) {
	orderJSON, err := ctx.GetStub().GetState(orderID)
	if err != nil {
		return nil, fmt.Errorf("failed to read order: %v", err)
	}
	if orderJSON == nil {
		return nil, fmt.Errorf("order %s does not exist", orderID)
	}

	var order Order
	err = json.Unmarshal(orderJSON, &order)
	if err != nil {
		return nil, err
	}

	return &order, nil
}

// OrderExists checks if an order exists
func (c *MedicineOrderChaincode) OrderExists(ctx contractapi.TransactionContextInterface, orderID string) (bool, error) {
	orderJSON, err := ctx.GetStub().GetState(orderID)
	if err != nil {
		return false, fmt.Errorf("failed to check order existence: %v", err)
	}
	return orderJSON != nil, nil
}

// GetAllOrders retrieves all orders from the ledger
func (c *MedicineOrderChaincode) GetAllOrders(ctx contractapi.TransactionContextInterface) ([]*Order, error) {
	resultsIterator, err := ctx.GetStub().GetStateByRange("", "")
	if err != nil {
		return nil, err
	}
	defer resultsIterator.Close()

	var orders []*Order
	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()
		if err != nil {
			return nil, err
		}

		var order Order
		err = json.Unmarshal(queryResponse.Value, &order)
		if err != nil {
			return nil, err
		}
		orders = append(orders, &order)
	}

	return orders, nil
}

// InitLedger initializes the ledger with some default data
func (c *MedicineOrderChaincode) InitLedger(ctx contractapi.TransactionContextInterface) error {
	orders := []Order{
		{OrderID: "1", CustomerID: "cust1", MedicineName: "Paracetamol", Quantity: 10, Location: "New York", RequiresPrescription: false, Status: "Created", PrescriptionVerified: false},
		{OrderID: "2", CustomerID: "cust2", MedicineName: "Amoxicillin", Quantity: 5, Location: "Los Angeles", RequiresPrescription: true, PrescriptionCode: "RX123", Status: "Created", PrescriptionVerified: false},
		{OrderID: "3", CustomerID: "cust3", MedicineName: "Ibuprofen", Quantity: 20, Location: "Chicago", RequiresPrescription: false, Status: "Created", PrescriptionVerified: false},
	}

	for _, order := range orders {
		orderJSON, err := json.Marshal(order)
		if err != nil {
			return err
		}

		err = ctx.GetStub().PutState(order.OrderID, orderJSON)
		if err != nil {
			return err
		}
	}

	return nil
}

func main() {
	chaincode, err := contractapi.NewChaincode(new(MedicineOrderChaincode))
	if err != nil {
		fmt.Printf("Error creating chaincode: %v\n", err)
		return
	}

	if err := chaincode.Start(); err != nil {
		fmt.Printf("Error starting chaincode: %v\n", err)
	}
}
