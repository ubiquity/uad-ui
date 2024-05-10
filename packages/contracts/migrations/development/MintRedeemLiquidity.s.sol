// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Script.sol";
import "./Deploy002_Diamond_Dollar_Governance.s.sol";
import "../../src/dollar/core/UbiquityDollarToken.sol";
import "../../src/dollar/facets/UbiquityPoolFacet.sol";
import "forge-std/console.sol";

contract MintRedeemLiquidity is Script {
    Deploy002_Diamond_Dollar_Governance public deploy002;
    UbiquityDollarToken public dollarToken;
    UbiquityPoolFacet public ubiquityPoolFacet;
    IERC20 public collateralToken;

    uint256 private constant INITIAL_MINT_AMOUNT = 1000 ether;

    function setUp() public {
        deploy002 = new Deploy002_Diamond_Dollar_Governance();
        dollarToken = deploy002.dollarToken();

        // ubiquityPoolFacet = UbiquityPoolFacet(address(deploy002.diamond()));

        // collateralToken = deploy002.collateralToken();
    }

    function run() public {
        console.log("dollarToken address:", address(dollarToken));
        // console.log("ubiquityPoolFacet address:", address(ubiquityPoolFacet));

        // uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        // address deployer = vm.addr(deployerPrivateKey);

        // // Create 3 new accounts
        // address account1 = getNewAccount();
        // address account2 = getNewAccount();
        // address account3 = getNewAccount();

        // // Mint tokens to accounts 1 and 2
        // mintTokens(account1, INITIAL_MINT_AMOUNT);
        // mintTokens(account2, INITIAL_MINT_AMOUNT);

        // // Add liquidity from accounts 1 and 2
        // addLiquidity(account1, INITIAL_MINT_AMOUNT / 2);
        // addLiquidity(account2, INITIAL_MINT_AMOUNT / 2);

        // // Redeem 30% of liquidity from account 3
        // uint256 redeemAmount = (INITIAL_MINT_AMOUNT * 3) / 10;
        // redeemLiquidity(account3, redeemAmount);
    }

    // function mintTokens(address account, uint256 amount) public {
    //     vm.startBroadcast(vm.envUint("ADMIN_PRIVATE_KEY"));
    //     dollarToken.mint(account, amount);
    //     vm.stopBroadcast();
    // }

    // function addLiquidity(address account, uint256 amount) public {
    //     vm.startBroadcast(vm.envUint("ADMIN_PRIVATE_KEY"));
    //     collateralToken.transfer(account, amount);
    //     vm.stopBroadcast();

    //     vm.prank(account);
    //     collateralToken.approve(address(ubiquityPoolFacet), amount);
    //     ubiquityPoolFacet.mint(0, amount);
    // }

    // function redeemLiquidity(address account, uint256 amount) public {
    //     vm.prank(account);
    //     ubiquityPoolFacet.redeem(0, amount, account);
    // }

    // function getNewAccount() public returns (address) {
    //     uint256 privateKey = uint256(
    //         keccak256(abi.encodePacked(block.timestamp))
    //     );
    //     return vm.addr(privateKey);
    // }
}
