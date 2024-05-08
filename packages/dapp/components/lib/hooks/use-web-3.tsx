import { JsonRpcProvider, JsonRpcSigner, Web3Provider } from "@ethersproject/providers";
import { useAccount, useChainId, useProvider, useSigner } from "wagmi";
import { WagmiConfig, createClient } from "wagmi";
import { mainnet, localhost, foundry } from "wagmi/chains";
import { WalletConnectConnector } from "wagmi/connectors/walletConnect";
import { InjectedConnector } from "wagmi/connectors/injected";
import { CoinbaseWalletConnector } from "wagmi/connectors/coinbaseWallet";
import { MetaMaskConnector } from "wagmi/connectors/metaMask";
import { ConnectKitProvider, getDefaultClient } from "connectkit";
import { FC } from "react";
import { ChildrenShim } from "./children-shim-d";
import ubqConfig from "ubq-connect-config";

const IS_DEV = process.env.NODE_ENV == "development";
export const LOCAL_NODE_ADDRESS = "http://localhost:8545";

export type PossibleProviders = Web3Provider | JsonRpcProvider | null;

export type Web3State = {
  metamaskInstalled: boolean;
  jsonRpcEnabled: boolean;
  providerMode: "none" | "metamask" | "jsonrpc";
  provider: PossibleProviders;
  connecting: boolean;
  walletAddress: null | string;
  chainId: number;
  signer?: JsonRpcSigner;
};

const metamaskInstalled = (typeof window !== "undefined" ? window.ethereum : undefined);

const defaultChains = [mainnet, localhost, foundry /*, hardhat*/];

const client = createClient(
  getDefaultClient({
    chains: defaultChains,
    appName: "Ubiquity DAO",
    appDescription: "World's first scalable digital dollar",
    appIcon: "https://dao.ubq.fi/favicon.ico",
    appUrl: "https://dao.ubq.fi/",
    autoConnect: true,
    connectors: [
      new MetaMaskConnector({
        chains: defaultChains,
        options: {
          shimDisconnect: true,
          UNSTABLE_shimOnConnectSelectAccount: true,
        },
      }),
      new InjectedConnector({
        chains: defaultChains,
        options: {
          name: "Injected Wallet",
          getProvider: () => typeof window !== 'undefined' ? window.ethereum : undefined,
          shimDisconnect: true,
        },
      }),
      new CoinbaseWalletConnector({
        chains: defaultChains,
        options: {
          appName: "Ubiquity DAO",
          appLogoUrl: "https://dao.ubq.fi/favicon.ico",
          darkMode: true,
          headlessMode: true,
          jsonRpcUrl: process.env.NEXT_PUBLIC_JSON_RPC_URL || "",
        },
      }),
      new WalletConnectConnector({
        chains: defaultChains,
        options: {
          showQrModal: false,
          projectId: process.env.NEXT_PUBLIC_WALLET_CONNECT_ID || ubqConfig.walletConnectProjectId || "",
          metadata: {
            name: "Ubiquity DAO",
            description: "World's first scalable digital dollar",
            url: "https://dao.ubq.fi/",
            icons: ["https://dao.ubq.fi/favicon.ico"],
          },
        },
      }),
    ],
  })
);

export const UseWeb3Provider: FC<ChildrenShim> = ({ children }) => {
  return (
    <WagmiConfig client={client}>
      <ConnectKitProvider
        theme="midnight"
        customTheme={{
          "--ck-body-background": "#000",
          "--ck-border-radius": "8px",
        }}
        mode="dark"
      >
        {children}
      </ConnectKitProvider>
    </WagmiConfig>
  );
};

const useWeb3 = (): Web3State => {
  const provider = useProvider();
  const { isConnecting, address } = useAccount();
  const { data: signer } = useSigner();
  const chainId = useChainId();

  return {
    metamaskInstalled,
    jsonRpcEnabled: IS_DEV,
    providerMode: "none",
    provider: provider as PossibleProviders,
    connecting: isConnecting,
    walletAddress: address as string,
    signer: signer as JsonRpcSigner,
    chainId
  };
};

export default useWeb3;
