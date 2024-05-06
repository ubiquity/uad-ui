import Link from "next/link";
import Icon, { IconsNames } from "../ui/icon";
import LightDarkMode from "./light-dark-mode";
import BuildInfo from "./build-info";
import WalletConnect from "./wallet-connect";
import AnvilRpcs from "./anvil/anvil-rpcs";

const PROD = process.env.NODE_ENV == "production";

const Sidebar = () => {
  return (
    <>
      <input type="checkbox" />
      <div id="Sidebar">
        <div>
          <ul>
            <li>
              <div>
                <Link href="/" id="Logo">
                  <div>
                    <div>
                      <Icon icon="dollar" />
                    </div>
                    <div>
                      <span>Ubiquity Dollar (Beta)</span>
                    </div>
                  </div>
                </Link>
              </div>
            </li>
            <li>
              <hr />
            </li>
            <Item text="Pool" href="/pool" icon="💸"></Item>
          </ul>

          <ul>
            <Item text="Docs" href="https://github.com/ubiquity/ubiquity-dollar/wiki" icon="📑"></Item>
            <Item text="Blog" href="https://dao.ubq.fi/" icon="📰"></Item>
          </ul>
          <hr />

          <footer>
            <div className="utils">
              <BuildInfo />
              <LightDarkMode />
            </div>
            <WalletConnect />
          </footer>
          <hr />
          <ul>
            <li>
              <SocialLinkItem href="https://twitter.com/UbiquityDAO" alt="Twitter" icon="twitter" />
            </li>
            <li>
              <SocialLinkItem href="https://t.me/ubiquitydao" alt="Telegram" icon="telegram" />
            </li>
            <li>
              <SocialLinkItem href="https://github.com/ubiquity" alt="Github" icon="github" />
            </li>
            <li>
              <SocialLinkItem href="https://discord.gg/SjymJ5maJ4" alt="Discord" icon="discord" />
            </li>
          </ul>
        </div>
        <hr />
        {!PROD && <AnvilRpcs />}
      </div>
    </>
  );
};

const SocialLinkItem = ({ href, icon, alt }: { href: string; icon: IconsNames; alt: string }) => (
  <a href={href} target="_blank" rel="noopener noreferrer" title={alt}>
    <div>
      <Icon icon={icon} />
    </div>
  </a>
);

const Item = ({ text, href }: { text: string; href: string; icon: string }) => {
  const isExternal = href.startsWith("http");
  return (
    <li>
      <div>
        <Link href={href} target={href.match(/https?:\/\//) ? "_blank" : ""}>
          <span>{text}</span>
          <span>{isExternal ? <Icon icon="external" /> : null}</span>
        </Link>
      </div>
    </li>
  );
};

export default Sidebar;
