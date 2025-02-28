const express = require('express');
const bodyParser = require('body-parser');
const { Gateway, Wallets } = require('fabric-network');
const path = require('path');
const fs = require('fs');
const yaml = require('js-yaml');

const app = express();
const port = 3000;

// Middleware
app.use(bodyParser.json());

// Load connection profile
const ccpPath = path.resolve(__dirname, 'connection-profile.yaml');
const ccp = yaml.load(fs.readFileSync(ccpPath, 'utf8'));
const walletPath = path.join(process.cwd(), 'wallet');

// Function to get contract instance
async function getContract() {
    const wallet = await Wallets.newFileSystemWallet(walletPath);
    const gateway = new Gateway();
    await gateway.connect(ccp, { wallet, identity: 'User1', discovery: { enabled: true, asLocalhost: false } });
    const network = await gateway.getNetwork('medlinechannel');
    const contract = network.getContract('gocc1'); // Ensure this matches your chaincode name
    return { contract, gateway };
}

// Create Order API
app.post('/createOrder', async (req, res) => {
    try {
        const { orderId, customerId, medicineName, quantity, location, requiresPrescription, prescriptionCode } = req.body;
        const { contract, gateway } = await getContract();

        // Ensure quantity is a valid integer
        const quantityInt = parseInt(quantity);
        if (isNaN(quantityInt)) {
            throw new Error('Invalid quantity value');
        }

        // Ensure requiresPrescription is a boolean
        const requiresPrescriptionBool = (requiresPrescription === 'true');

        await contract.submitTransaction('CreateOrder', orderId, customerId, medicineName, location, quantityInt.toString(), requiresPrescriptionBool.toString(), prescriptionCode);

        await gateway.disconnect();
        res.status(200).json({ message: 'Order created successfully' });
    } catch (error) {
        console.error(`Failed to create order: ${error}`);
        res.status(500).json({ error: `Failed to create order: ${error.message}` });
    }
});

// Update Order API
app.post('/updateOrder', async (req, res) => {
    try {
        const { orderID, status } = req.body;
        const { contract, gateway } = await getContract();

        await contract.submitTransaction('ProcessOrder', orderID, status);

        await gateway.disconnect();
        res.status(200).json({ message: 'Order updated successfully' });
    } catch (error) {
        console.error(`Failed to update order: ${error}`);
        res.status(500).json({ error: `Failed to update order: ${error.message}` });
    }
});

// Query Order API
app.get('/queryOrder/:orderID', async (req, res) => {
    try {
        const { orderID } = req.params;
        const { contract, gateway } = await getContract();

        console.log(`Querying order with ID: ${orderID}`);
        const result = await contract.evaluateTransaction('ReadOrder', orderID);

        await gateway.disconnect();
        res.status(200).json(JSON.parse(result.toString()));
    } catch (error) {
        console.error(`Failed to query order: ${error}`);
        res.status(500).json({ error: `Failed to query order: ${error.message}` });
    }
});

// Get All Orders API
app.get('/queryAllOrders', async (req, res) => {
    try {
        const { contract, gateway } = await getContract();

        console.log(`Querying all orders`);
        const result = await contract.evaluateTransaction('GetAllOrders');

        await gateway.disconnect();
        res.status(200).json(JSON.parse(result.toString()));
    } catch (error) {
        console.error(`Failed to query all orders: ${error}`);
        res.status(500).json({ error: `Failed to query orders: ${error.message}` });
    }
});


// Verify Prescription API
app.post('/verify', async (req, res) => {
    try {
        const { orderID, prescriptionCode } = req.body;
        const { contract, gateway } = await getContract();

        await contract.submitTransaction('VerifyPrescription', orderID, prescriptionCode);

        await gateway.disconnect();
        res.status(200).json({ message: 'Prescription verified successfully' });
    } catch (error) {
        console.error(`Failed to verify prescription: ${error}`);
        res.status(500).json({ error: `Failed to verify prescription: ${error.message}` });
    }
});


// Deliver Order API
app.post('/deliverOrder', async (req, res) => {
    try {
        const { orderID } = req.body;
        const { contract, gateway } = await getContract();

        await contract.submitTransaction('DeliverOrder', orderID);

        await gateway.disconnect();
        res.status(200).json({ message: 'Order delivered successfully' });
    } catch (error) {
        console.error(`Failed to deliver order: ${error}`);
        res.status(500).json({ error: `Failed to deliver order: ${error.message}` });
    }
});

// Server Start
app.listen(port, () => {
    console.log(`Fabric API listening at http://localhost:${port}`);
});
