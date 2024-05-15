import Tooltip from "../ui/tooltip";

import usePrices from "./lib/use-prices";

const PRICE_PRECISION = 1_000_000;

const DollarPrice = () => {
  const [twapPrice, spotPrice] = usePrices();

  return (
    <div id="DollarPrice" className="panel">
      <h2>Ubiquity Dollar Price</h2>
      <Tooltip content="Swap for DAI/USDC/USDT" placement="bottom">
        <div>
          <span>${(spotPrice && spotPrice.div(PRICE_PRECISION).toNumber().toFixed(6)) || "· · ·"}</span>
          <span>Spot</span>
        </div>
      </Tooltip>
      <Tooltip content="Time weighted average price" placement="bottom">
        <div>
          <span>${(twapPrice && twapPrice.div(PRICE_PRECISION).toNumber().toFixed(6)) || "· · ·"}</span>
          <span>TWAP</span>
        </div>
      </Tooltip>
    </div>
  );
};

export default DollarPrice;
