import { Provider } from "@ethersproject/providers";
import { Contract, ethers } from "ethers";
import { useEffect, useState } from "react";
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
// misc
import AggregatorV3InterfaceArtifact from "@ubiquity/contracts/out/AggregatorV3Interface.sol/AggregatorV3Interface.json";
import CurveStableSwapNGArtifact from "../../../config/abis/curve-stable-swap-ng.json";

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
  // misc
  chainlinkPriceFeedLusdUsd: Contract | null;
  curveLusdDollarPool: Contract | null;
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

  // set protocol as not yet initialized
  const [isProtocolInitialized, setIsProtocolInitialized] = useState(false);

  const [protocolContracts, setProtocolContracts] = useState<ProtocolContracts>({
    // separately deployed contracts (i.e. not part of the diamond)
    dollarToken: null,
    governanceToken: null,
    // diamond facets
    accessControlFacet: null,
    managerFacet: null,
    ownershipFacet: null,
    ubiquityPoolFacet: null,
    // misc
    chainlinkPriceFeedLusdUsd: null,
    curveLusdDollarPool: null,
  });

  // get deployment transactions from all migrations
  const deploymentTransactions = getDeploymentTransactions(chainId);

  // find Diamond address in all of the deployment transactions
  let diamondAddress = "";
  deploymentTransactions.map((tx: DeploymentTransaction) => {
    if (tx.transactionType === "CREATE") {
      // find the diamond address
      if (tx.contractName === "Diamond") diamondAddress = tx.contractAddress;
    }
  });

  // fetch contracts instances from ManagerFacet
  useEffect(() => {
    const fetchContractInstances = async () => {
      // set diamond facets
      const accessControlFacet = new ethers.Contract(diamondAddress, AccessControlFacetArtifact.abi, <Provider>provider);
      const managerFacet = new ethers.Contract(diamondAddress, ManagerFacetArtifact.abi, <Provider>provider);
      const ownershipFacet = new ethers.Contract(diamondAddress, OwnershipFacetArtifact.abi, <Provider>provider);
      const ubiquityPoolFacet = new ethers.Contract(diamondAddress, UbiquityPoolFacetArtifact.abi, <Provider>provider);
      
      // set core contracts
      const dollarToken = new ethers.Contract(await managerFacet.dollarTokenAddress(), UbiquityDollarTokenArtifact.abi, <Provider>provider);
      const governanceToken = new ethers.Contract(await managerFacet.governanceTokenAddress(), UbiquityGovernanceArtifact.abi, <Provider>provider);

      // set misc contracts
      const [chainlinkPriceFeedLusdUsdAddress] = await ubiquityPoolFacet.stableUsdPriceFeedInformation();
      const chainlinkPriceFeedLusdUsd = new ethers.Contract(chainlinkPriceFeedLusdUsdAddress, AggregatorV3InterfaceArtifact.abi, <Provider>provider);
      const curveLusdDollarPool = new ethers.Contract(await managerFacet.stableSwapPlainPoolAddress(), CurveStableSwapNGArtifact, <Provider>provider);

      // update UI
      setProtocolContracts({
        // diamond facets
        accessControlFacet,
        managerFacet,
        ownershipFacet,
        ubiquityPoolFacet,
        // separately deployed core contracts (i.e. not part of the diamond)
        dollarToken,
        governanceToken,
        // misc
        chainlinkPriceFeedLusdUsd,
        curveLusdDollarPool,
      });
      setIsProtocolInitialized(true);
    };

    fetchContractInstances();
  }, []);

  return [isProtocolInitialized, protocolContracts];
};

/**
 * Helper methods
 */

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
