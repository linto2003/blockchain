const express = require('express');
const bodyParser = require('body-parser');
const { Gateway, Wallets } = require('fabric-network');
const path = require('path');
const fs = require('fs');
const yaml = require('js-yaml');

const app = express();
const port = 3000;

app.use(bodyParser.json());

const ccpPath = path.resolve(__dirname, 'connection-profile.yaml');
const ccp = yaml.load(fs.readFileSync(ccpPath, 'utf8'));
const walletPath = path.join(process.cwd(), 'wallet');

async function getContract() {
  const wallet = await Wallets.newFileSystemWallet(walletPath);
  const gateway = new Gateway();
  await gateway.connect(ccp, { wallet, identity: 'User1', discovery: { enabled: true, asLocalhost: false } });
  const network = await gateway.getNetwork('medlinechannel');
  const contract = network.getContract('gocc1'); // Ensure this matches the committed chaincode name
  return { contract, gateway };
}

app.post('/createOrder', async (req, res) => {
  try {
    const { orderId, customerId, medicineName, quantity, location, requiresPrescription, prescriptionCode, status, prescriptionVerified } = req.body;
    const { contract, gateway } = await getContract();
    await contract.submitTransaction('CreateOrder', orderId, customerId, medicineName, location, quantity, requiresPrescription, prescriptionCode, status, prescriptionVerified);
    await gateway.disconnect();
    res.status(200).send('Order created successfully');
  } catch (error) {
    console.error(`Failed to create order: ${error}`);
    res.status(500).send(`Failed to create order: ${error.message}`);
  }
});

app.post('/updateOrder', async (req, res) => {
  try {
    const { orderID, status } = req.body;
    const { contract, gateway } = await getContract();
    await contract.submitTransaction('ProcessOrder', orderID);
    await gateway.disconnect();
    res.status(200).send('Order updated successfully');
  } catch (error) {
    console.error(`Failed to update order: ${error}`);
    res.status(500).send(`Failed to update order: ${error.message}`);
  }
});

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
    console.error(`Error details: ${JSON.stringify(error)}`);
    res.status(500).send(`Failed to query order: ${error.message}`);
  }
});

app.listen(port, () => {
  console.log(`Fabric app listening at http://localhost:${port}`);
});