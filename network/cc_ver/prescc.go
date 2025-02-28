package main

import (
	"encoding/json"
	"fmt"
	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

// PrescriptionContract for prescription verification
type PrescriptionContract struct {
	contractapi.Contract
}

// Prescription structure
type Prescription struct {
	PrescriptionID string `json:"prescriptionID"`
	UserID         string `json:"userID"`
	DoctorID       string `json:"doctorID"`
	Verified       bool   `json:"verified"`
}

// Upload Prescription
func (c *PrescriptionContract) UploadPrescription(ctx contractapi.TransactionContextInterface, prescriptionID, userID, doctorID string) error {
	prescription := Prescription{
		PrescriptionID: prescriptionID,
		UserID:         userID,
		DoctorID:       doctorID,
		Verified:       false,
	}
	prescriptionJSON, err := json.Marshal(prescription)
	if err != nil {
		return err
	}
	return ctx.GetStub().PutState(prescriptionID, prescriptionJSON)
}

// Verify Prescription
func (c *PrescriptionContract) VerifyPrescription(ctx contractapi.TransactionContextInterface, prescriptionID string) error {
	prescriptionJSON, err := ctx.GetStub().GetState(prescriptionID)
	if err != nil || prescriptionJSON == nil {
		return fmt.Errorf("Prescription not found")
	}
	var prescription Prescription
	json.Unmarshal(prescriptionJSON, &prescription)
	prescription.Verified = true
	newPrescriptionJSON, _ := json.Marshal(prescription)
	return ctx.GetStub().PutState(prescriptionID, newPrescriptionJSON)
}

// InitLedger initializes the ledger with some default data
func (c *PrescriptionContract) InitLedger(ctx contractapi.TransactionContextInterface) error {
    prescriptions := []Prescription{
        {PrescriptionID: "prescription1", UserID: "user1", DoctorID: "doctor1", Verified: false},
        {PrescriptionID: "prescription2", UserID: "user2", DoctorID: "doctor2", Verified: false},
        {PrescriptionID: "prescription3", UserID: "user3", DoctorID: "doctor3", Verified: false},
    }

    for _, prescription := range prescriptions {
        prescriptionJSON, err := json.Marshal(prescription)
        if err != nil {
            return err
        }

        err = ctx.GetStub().PutState(prescription.PrescriptionID, prescriptionJSON)
        if err != nil {
            return err
        }
    }

    return nil
}


func main() {
	cc, err := contractapi.NewChaincode(new(PrescriptionContract))
	if err != nil {
		fmt.Printf("Error creating chaincode: %s", err)
	}
	if err := cc.Start(); err != nil {
		fmt.Printf("Error starting chaincode: %s", err)
	}
}
