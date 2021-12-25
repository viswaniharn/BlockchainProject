# BlockchainProject
This project was done as part of my course "Blockchain Application development" from University at Buffalo

Prerequisites for deploying:
1. Ganache
2. Truffle
3. NPM
4. OpenZepplin Node module
5. Metamask wallet extension

Instructions to deploy:
1. Go to rsm-contract folder.
2. OpenGanacheandQuickStart.Copythemnemonic.
3. Open Metamask and press “Import Using Secret Recovery Phase” and set a new password and select all accounts.
4. Compile “truffle compile” command. It should compile without any errors.
5. Copy the contract address for Royalties.
6. Also the first address should have a little less ether for the deployment.
7. Do “truffle migrate–reset”.
8. Go to rsm-app folder.
9. Compile “npmstart”
10. It should start a server on port 3000.
