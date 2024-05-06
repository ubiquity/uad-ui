import { FC } from "react";
import "@uniswap/widgets/fonts.css";

import DollarPrice from "@/components/redeem/dollar-price";

import dynamic from "next/dynamic";
const WalletConnectionWall = dynamic(() => import("@/components/ui/wallet-connection-wall"), { ssr: false }); //@note Fix: (Hydration Error)

const index: FC = (): JSX.Element => {
  return (
    <WalletConnectionWall>
      <DollarPrice />
    </WalletConnectionWall>
  );
};

export default index;
