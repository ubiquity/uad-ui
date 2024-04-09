#!/bin/bash

# load env variables
source .env

# Deploy001_Diamond_Dollar_Governance (deploys Diamond, Dollar and Governance related contracts)
forge script migrations/mainnet/Deploy001_Diamond_Dollar_Governance.s.sol:Deploy001_Diamond_Dollar_Governance --rpc-url $RPC_URL --broadcast -vvvv
