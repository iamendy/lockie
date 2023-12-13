# Lockie [Minipay]

Live Demo - [Watch Video](https://drive.google.com/file/d/1yUIWSLDOX2UzLD5x91ifjGiSGzbOJjm3/view) <br />
Minipay Link - [Lockie dApp](https://lockie-minipay.vercel.app) <br />
Slides - [Presentation Slides](https://he-s3.s3.amazonaws.com/media/sprint/lancelot-hackathon-4/team/1887941/b21642elockie_slides.pdf)

## ✨ Description

Lockie is an open-source widget that allows users to save better and earn yield on Minipay.

We aim to help Africans hedge against hyperinflation by integrating with Minipay to provide an intuitive interface for saving and easily getting yield on cUSD.

![Lockie Dashboard](https://lockie-minipay.vercel.app/img/preview.png)

## 💻 How we built Lockie

We created and deployed Lockie smart contract on Celo Mainnet:

1. Lockie 0x7a457555f836281c0A4E4dffDcF82878e5Fa0d9b - [View on Celo scan](https://celoscan.io/address/v)

Here are some of the recent transactions on Lockie:

1. Savings [View txn on Celo Scan](https://celoscan.io/tx/0xe579d538f22cb96f45f744d356274e998e4426fc7ed932e784914177d9e41d94)

2. Withdraw [View txn on Celo Scan](https://celoscan.io/tx/0x926e516a67bf03b434b14ddea28eb8c96d895bdaaa3b3c477c90377386d67213)

This is an original work by our team. We built our solution using: **`CELO Composer`**, **`NextJs/Typescript`**, **`Wagmi`**, **`Rainbowkit`**, **`TailwindCSS`** and **`Remix`**

## 🧑‍💻 Instructions for testing locally

\***\* Smart contract \*\***

Note: Recommend using [Remix](https://remix.ethereum.org) for quick smart contract deployment, or alternatively hardhat:

1. Deploy `Lockie` on Celo by running the necessary Hardhat script

\***\* Frontend \*\***

2. Update your deployed `Lockie` address on the `packages/react-app/constants/connect.ts file.

3. run `cp .env.example .env`

4. Update the fields on the .env file with your keys

5. Run `yarn dev` to start the DApp on your development environment.

6. You can connect from your Minipay wallet and enjoy a world of limitless possibilities.
