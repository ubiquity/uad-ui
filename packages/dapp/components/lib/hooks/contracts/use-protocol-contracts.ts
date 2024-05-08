import { Provider } from "@ethersproject/providers";
import { Contract, ethers } from "ethers";
import { GOVERNANCE_TOKEN_ADDRESS } from "../../utils";
import useWeb3 from "../use-web-3";

// contract build artifacts
// separately deployed contracts
import UbiquityDollarTokenArtifact from "@ubiquity/contracts/out/UbiquityDollarToken.sol/UbiquityDollarToken.json";
import UbiquityGovernanceArtifact from "@ubiquity/contracts/out/UbiquityGovernance.sol/UbiquityGovernance.json";
// diamond facets
import AccessControlFacetArtifact from "@ubiquity/contracts/out/AccessControlFacet.sol/AccessControlFacet.json";
import ManagerFacetArtifact from "@ubiquity/contracts/out/ManagerFacet.sol/ManagerFacet.json";
import OwnershipFacetArtifact from "@ubiquity/contracts/out/OwnershipFacet.sol/OwnershipFacet.json";
import UbiquityPoolFacetArtifact from "@ubiquity/contracts/out/UbiquityPoolFacet.sol/UbiquityPoolFacet.json";

type DeploymentTransaction = {
  transactionType: string,
  contractName: string,
  contractAddress: string,
  arguments: any, // string[] | null
};

export type ProtocolContracts = {
  // separately deployed core contracts (i.e. not part of the diamond)
  dollarToken: Contract | null;
  governanceToken: Contract | null;
  // diamond facets
  accessControlFacet: Contract | null;
  managerFacet: Contract | null;
  ownershipFacet: Contract | null;
  ubiquityPoolFacet: Contract | null;
};

/**
 * Returns all of the available protocol contracts
 *
 * Right now the Ubiquity org uses:
 * - separately deployed contracts (https://github.com/ubiquity/ubiquity-dollar/tree/development/packages/contracts/src/dollar/core)
 * - contracts deployed as diamond proxy facets (https://github.com/ubiquity/ubiquity-dollar/tree/development/packages/contracts/src/dollar/facets)
 */
const useProtocolContracts = () => {
  // get current web3 provider
  const { chainId, provider } = useWeb3();

  // all protocol contracts
  const protocolContracts: ProtocolContracts = {
    // separately deployed contracts (i.e. not part of the diamond)
    dollarToken: null,
    governanceToken: null,
    // diamond facets
    accessControlFacet: null,
    managerFacet: null,
    ownershipFacet: null,
    ubiquityPoolFacet: null,
  };

  let diamondAddress = "";

  // By default set `UbiquityGovernance` token contract to already deployed on mainnet address.
  // If there is some mock instance (for testnet/anvil) then it will be overridden later in the code.
  protocolContracts.governanceToken = new ethers.Contract(GOVERNANCE_TOKEN_ADDRESS, UbiquityGovernanceArtifact.abi, <Provider>provider);

  // get deployment transactions from all migrations
  const deploymentTransactions = getDeploymentTransactions(chainId);

  // for all of the deployment transactions
  deploymentTransactions.map((tx: DeploymentTransaction) => {
    if (tx.transactionType === "CREATE") {
      // get `UbiquityDollarToken` contract instance (deployed separately, not part of the diamond)
      if (tx.contractName === "UbiquityDollarToken") {
        protocolContracts.dollarToken = new ethers.Contract(
          getContractProxyAddress(tx.contractAddress, deploymentTransactions), 
          UbiquityDollarTokenArtifact.abi, 
          <Provider>provider
        );
      }
      // get `UbiquityGovernance` token contract instance (for mainnet use already deployed contract, for testnet/anvil mock is used)
      if (tx.contractName === "UbiquityGovernance") {
        protocolContracts.governanceToken = new ethers.Contract(tx.contractAddress, UbiquityGovernanceArtifact.abi, <Provider>provider);
      }
      // find the diamond address
      if (tx.contractName === "Diamond") diamondAddress = tx.contractAddress;
    }
  });

  // assign diamond facets
  protocolContracts.accessControlFacet = new ethers.Contract(diamondAddress, AccessControlFacetArtifact.abi, <Provider>provider);
  protocolContracts.managerFacet = new ethers.Contract(diamondAddress, ManagerFacetArtifact.abi, <Provider>provider);
  protocolContracts.ownershipFacet = new ethers.Contract(diamondAddress, OwnershipFacetArtifact.abi, <Provider>provider);
  protocolContracts.ubiquityPoolFacet = new ethers.Contract(diamondAddress, UbiquityPoolFacetArtifact.abi, <Provider>provider);

  return protocolContracts;
};

/**
 * Helper methods
 */

/**
 * Returns ERC1967Proxy address (which should be used in the frontend) by contract implementation address
 * @param contractImplementationAddress Contract implementation address
 * @param deploymentTransactions Deployment transactions
 * @returns Proxy address
 */
function getContractProxyAddress(
  contractImplementationAddress: string,
  deploymentTransactions: DeploymentTransaction[],
) {
  let contractProxyAddress = '';

  for (let i = 0; i < deploymentTransactions.length; i++) {
    if (deploymentTransactions[i].transactionType === 'CREATE' && deploymentTransactions[i].contractName === 'ERC1967Proxy') {
      // get implementation address from constructor arguments `new ERC1967Proxy(implementationAddress,initPayload);`
      const txImplementationAddress = deploymentTransactions[i].arguments[0];
      // if fetched implemetation address equals to `contractImplementationAddress` then we found correct proxy contract
      if (txImplementationAddress.toLowerCase() === contractImplementationAddress.toLowerCase()) {
        contractProxyAddress = deploymentTransactions[i].contractAddress;
        break;
      }
    }
  }

  if (contractProxyAddress === '') throw new Error(`Contract proxy address not found for implementation ${contractImplementationAddress}`);

  return contractProxyAddress;
}

/**
 * Returns all deployment transactions (from all migrations)
 * @param chainId Chain id
 * @returns All deployment transactions
 */
function getDeploymentTransactions(chainId: number): DeploymentTransaction[] {
  let deploymentTransactions: DeploymentTransaction[] = [];
  
  try {
    // import deployment migrations
    const deploy001 = require(`@ubiquity/contracts/broadcast/Deploy001_Diamond_Dollar_Governance.s.sol/${chainId}/run-latest.json`);

    deploymentTransactions = [
      ...deploy001.transactions,
    ];
  } catch (err: any) {
    console.error(err);
  } finally {
    return deploymentTransactions;
  }
}

export default useProtocolContracts;
