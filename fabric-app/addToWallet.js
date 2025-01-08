const { Wallets } = require('fabric-network');
const fs = require('fs');
const path = require('path');

async function main() {
  try {
    // Create a new file system based wallet for managing identities.
    const walletPath = path.join(process.cwd(), 'wallet');
    const wallet = await Wallets.newFileSystemWallet(walletPath);
    console.log(`Wallet path: ${walletPath}`);

    // Load the new identity's credentials.
    const credPath = path.join(__dirname, '../network/crypto-config/peerOrganizations/hospital.com/users/User1@hospital.com/msp');
    const certificate = fs.readFileSync(path.join(credPath, 'signcerts', 'User1@hospital.com-cert.pem')).toString();
    const privateKey = fs.readFileSync(path.join(credPath, 'keystore', 'priv_sk')).toString();

    // Create a new identity object for the new user.
    const identity = {
      credentials: {
        certificate,
        privateKey,
      },
      mspId: 'HospitalMSP',
      type: 'X.509',
    };

    // Add the new identity to the wallet.
    await wallet.put('User1', identity);
    console.log(`Successfully added identity for User1 to the wallet`);
  } catch (error) {
    console.error(`Failed to add identity to the wallet: ${error}`);
    process.exit(1);
  }
}

main();