
package main

import (
	"encoding/json"
	"fmt"
	"strconv"

	// "github.com/hyperledger/fabric/core/chaincode/shim" 
	"github.com/hyperledger/fabric-chaincode-go/shim"
	
	// pb "github.com/hyperledger/fabric/protos/peer"
	pb "github.com/hyperledger/fabric-protos-go/peer"
)

type Order struct {
	OrderID    string `json:"orderID"`
	CustomerID string `json:"customerID"`
	Medicine   string `json:"medicine"`
	Quantity   int    `json:"quantity"`
	Status     string `json:"status"`
}

type OrderChaincode struct {}

// Init initializes the ledger with no orders
func (t *OrderChaincode) Init(stub shim.ChaincodeStubInterface) pb.Response {
	return shim.Success(nil)
}

// Invoke handles create, query, update, and status operations
func (t *OrderChaincode) Invoke(stub shim.ChaincodeStubInterface) pb.Response {
	function, args := stub.GetFunctionAndParameters()

	switch function {
	case "createOrder":
		return t.createOrder(stub, args)
	case "getOrder":
		return t.getOrder(stub, args)
	case "updateOrder":
		return t.updateOrder(stub, args)
	case "getOrderStatus":
		return t.getOrderStatus(stub, args)
	default:
		return shim.Error("Unknown function call")
	}
}

// createOrder creates a new order
func (t *OrderChaincode) createOrder(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	if len(args) != 4 {
		return shim.Error("Incorrect number of arguments. Expecting OrderID, CustomerID, Medicine, Quantity")
	}

	quantity, err := strconv.Atoi(args[3])
	if err != nil {
		return shim.Error("Invalid quantity")
	}

	order := Order{
		OrderID:    args[0],
		CustomerID: args[1],
		Medicine:   args[2],
		Quantity:   quantity,
		Status:     "Pending",
	}

	orderJSON, err := json.Marshal(order)
	if err != nil {
		return shim.Error("Failed to marshal order")
	}

	if err := stub.PutState(order.OrderID, orderJSON); err != nil {
		return shim.Error("Failed to save order")
	}

	return shim.Success(nil)
}

// getOrder retrieves an order by OrderID
func (t *OrderChaincode) getOrder(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting OrderID")
	}

	orderJSON, err := stub.GetState(args[0])
	if err != nil {
		return shim.Error("Failed to get order")
	}
	if orderJSON == nil {
		return shim.Error("Order not found")
	}

	return shim.Success(orderJSON)
}

// updateOrder updates the status of an existing order
func (t *OrderChaincode) updateOrder(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	if len(args) != 2 {
		return shim.Error("Incorrect number of arguments. Expecting OrderID, Status")
	}

	orderJSON, err := stub.GetState(args[0])
	if err != nil {
		return shim.Error("Failed to get order")
	}
	if orderJSON == nil {
		return shim.Error("Order not found")
	}

	order := Order{}
	if err := json.Unmarshal(orderJSON, &order); err != nil {
		return shim.Error("Failed to unmarshal order")
	}

	order.Status = args[1]

	updatedOrderJSON, err := json.Marshal(order)
	if err != nil {
		return shim.Error("Failed to marshal updated order")
	}

	if err := stub.PutState(order.OrderID, updatedOrderJSON); err != nil {
		return shim.Error("Failed to update order")
	}

	return shim.Success(nil)
}

// getOrderStatus retrieves the status of an order by OrderID
func (t *OrderChaincode) getOrderStatus(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting OrderID")
	}

	orderJSON, err := stub.GetState(args[0])
	if err != nil {
		return shim.Error("Failed to get order")
	}
	if orderJSON == nil {
		return shim.Error("Order not found")
	}

	order := Order{}
	if err := json.Unmarshal(orderJSON, &order); err != nil {
		return shim.Error("Failed to unmarshal order")
	}

	return shim.Success([]byte(order.Status))
}

func main() {
	if err := shim.Start(new(OrderChaincode)); err != nil {
		fmt.Printf("Error starting Order chaincode: %s", err)
	}
}
