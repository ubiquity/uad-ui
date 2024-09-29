# UbiquityPoolSecurityMonitor Off-Chain part

A crucial component of the `UbiquityPoolSecurityMonitor` contract workflow is its off-chain integration. The `checkLiquidityVertex()` function must be periodically triggered by OpenZeppelin Defender to ensure continuous liquidity monitoring and security assessments.

The workflow consists of four key components:

1. **[OpenZeppelin Actions](https://docs.openzeppelin.com/defender/module/actions)**: Executes a cron job that triggers the Relayer to call the `checkLiquidityVertex()` function.
2. **[OpenZeppelin Relayer](https://docs.openzeppelin.com/defender/module/relayers)**: Performs the transaction that invokes the `checkLiquidityVertex()` function.
3. **UbiquityPoolSecurityMonitor Contract**: Conducts the on-chain liquidity check, takes necessary actions if an incident occurs, and emits the `MonitorPaused` event.
4. **[OpenZeppelin Monitor](https://docs.openzeppelin.com/defender/module/monitor)**: Listens for the `MonitorPaused` event and sends alerts via email or other designated channels.

### Workflow diagram
![Workflow Diagram](../../../../../utils/UbiquityPoolSecurityMonitorWorkflow.drawio.png)


### OpenZeppelin Defender Setup

To integrate OpenZeppelin Defender with the `UbiquityPoolSecurityMonitor`, follow the steps below:

#### 1. Relayer Setup

Complete only **Part 1** of the [OpenZeppelin Defender Relayer tutorial](https://docs.openzeppelin.com/defender/tutorial/relayer). This will configure the Relayer to handle transactions for calling the `checkLiquidityVertex()` function.

#### 2. Actions Setup

Follow the [OpenZeppelin Defender Actions tutorial](https://docs.openzeppelin.com/defender/tutorial/actions) to set up Actions. While configuring your Action, choose the Relayer you set up in step 1, and use the following script for your newly created Action:

```javascript
const { Defender } = require('@openzeppelin/defender-sdk');

exports.handler = async function (credentials) {
  const client = new Defender(credentials);

  const txRes = await client.relaySigner.sendTransaction({
    to: '0xb60ce3bf27B86d3099F48dbcDB52F5538402EF7B', // Address of UbiquityPoolSecurityMonitor contract
    speed: 'fast',
    data: '0x9ba8a26c', // Encoded function signature for checkLiquidityVertex() of the UbiquityPoolSecurityMonitor
    gasLimit: '80000',
  });

  return txRes.hash;
};
```

#### 3. Monitor Setup

Follow the [OpenZeppelin Defender Monitor tutorial](https://docs.openzeppelin.com/defender/tutorial/monitor) to configure a Monitor that listens for the MonitorPaused event emitted by the UbiquityPoolSecurityMonitor contract. Set up your alerts using the desired source (e.g., email or other alerting mechanisms).



