import useProtocolContracts from "@/components/lib/hooks/contracts/use-protocol-contracts";
import useWeb3 from "@/components/lib/hooks/use-web-3";
import { BigNumber, utils } from "ethers";
import { useEffect, useState } from "react";

/**
 * Returns Dollar TWAP and spot prices with 6 decimals
 * @returns Dollar TWAP and spot prices
 */
const usePrices = (): [BigNumber | null, BigNumber | null, () => Promise<void>] => {
  const [isProtocolInitialized, protocolContracts] = useProtocolContracts();
  const { provider } = useWeb3();

  const [twapPrice, setTwapPrice] = useState<BigNumber | null>(null);
  const [spotPrice, setSpotPrice] = useState<BigNumber | null>(null);

  async function refreshPrices() {
    try {
      if (!isProtocolInitialized || !provider) {
        return;
      }

      /**
       * How TWAP price is calculated:
       * 1) Fetch LUSD/USD quote from chainlink
       * 2) Fetch Dollar/LUSD quote from Curve's TWAP oracle
       * 3) Calculate Dollar/USD quote 
       */
      const newTwapPrice = await protocolContracts.ubiquityPoolFacet.getDollarPriceUsd();

      /**
       * How spot price is calculated:
       * 1) Fetch LUSD/USD quote from chainlink
       * 2) Fetch Dollar/LUSD spot quote from Curve's pool
       * 3) Calculate Dollar/USD quote 
       */
      // 8 decimals answer
      const latestRoundDataLusdUsd = await protocolContracts.chainlinkPriceFeedLusdUsd.latestRoundData();
      // 18 decimals response
      const dollarLusdQuote = await protocolContracts.curveLusdDollarPool.get_dy(1, 0, utils.parseEther('1'));
      // convert to 6 decimals
      const newSpotPrice = latestRoundDataLusdUsd.answer.mul(dollarLusdQuote).div(1e20.toString());

      setTwapPrice(newTwapPrice);
      setSpotPrice(newSpotPrice);

    } catch (error) {
      console.log("Error in refreshPrices: ", error);
    }
  }

  useEffect(() => {
    refreshPrices();
  }, [provider]);

  return [twapPrice, spotPrice, refreshPrices];
};

export default usePrices;
