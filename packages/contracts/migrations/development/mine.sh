#!/bin/bash

# load env variables
source .env

# Deploy002_Diamond_Dollar_Governance (deploys Diamond, Dollar and Governance related contracts)
forge script migrations/development/Deploy002_Diamond_Dollar_Governance.s.sol:Deploy002_Diamond_Dollar_Governance --rpc-url $RPC_URL --broadcast -vv





