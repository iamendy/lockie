import { ethers } from "ethers";
import useGetBalance from "../hooks/useGetBalance";
import { useCountdown } from "../hooks/useCountdown";
import { useState } from "react";
import { useContractRead, useAccount } from "wagmi";
import connect from "../constants/connect";
import Loader from "./icons/Loader";
import Lock from "./icons/Lock";
import Balance from "./icons/Balance";
import Earnings from "./icons/Earnings";

const SavingsCard = () => {
  const balance = useGetBalance();
  const [isOpen, setIsOpen] = useState(false);
  const { address } = useAccount();

  const {
    data: ethBal,
    isLoading,
    error,
  } = useContractRead({
    //@ts-ignore
    address: connect?.lockie?.address,
    //@ts-ignore
    abi: connect?.lockie?.abi,
    functionName: "getSavingsBal",
    watch: true,
    args: [address],
  });

  const { data: mcusdBal } = useContractRead({
    //@ts-ignore
    address: connect?.mToken?.address,
    //@ts-ignore
    abi: connect?.mToken?.abi,
    functionName: "balanceOf",
    watch: true,
    args: [address],
  });

  return (
    <div className="relative bg-gray/5 rounded-lg py-8 px-3 lg:px-8 w-full overflow-hidden shadow-md">
      <div className="flex flex-col gap-y-5">
        <div className="flex items-center justify-between">
          <div className="text-left">
            <p className="text-xl font-semibold flex flex-col ">
              <span>
                {
                  //@ts-ignore
                  ethers.formatEther(ethBal || 0)
                }{" "}
                cUSD
              </span>
              <small className="text-xs text-gray/40">
                ~{" "}
                {
                  //@ts-ignore
                  parseFloat(
                    //@ts-ignore
                    ethers?.formatUnits(ethBal || "0", 18)
                  ).toFixed(2) * 1000
                }{" "}
                NGN
              </small>
            </p>
            <span className="flex items-center justify-start mt-2">
              {" "}
              <Lock /> Savings
            </span>
          </div>

          <div className="text-right">
            <p className="text-xl font-semibold flex flex-col ">
              <span>
                {
                  //@ts-ignore
                  parseFloat(
                    //@ts-ignore
                    ethers?.formatUnits(balance || "0", 18)
                  ).toFixed(2)
                }{" "}
                cUSD
              </span>
              <small className="text-xs text-gray/40">
                ~{" "}
                {
                  //@ts-ignore
                  parseFloat(
                    //@ts-ignore
                    ethers?.formatUnits(balance || "0", 18)
                  ).toFixed(2) * 1000
                }{" "}
                NGN
              </small>
            </p>
            <span className="flex items-center justify-end mt-2">
              <Balance /> Bal
            </span>
          </div>
        </div>

        <div className="line w-[60%] mx-auto h-[1px] lg:hidden" />

        <div className="text-center lg:hidden">
          <span className="flex items-center justify-center mt-2">
            <Earnings /> Earnings
          </span>
          <p className="text-xl font-semibold flex flex-col ">
            <span className="text-gray text-xs">
              {
                //@ts-ignore
                parseFloat(
                  //@ts-ignore
                  ethers?.formatUnits(mcusdBal || "0", 6)
                ).toFixed(2)
              }{" "}
              cUSD
            </span>

            <span>
              {
                //@ts-ignore
                parseFloat(
                  //@ts-ignore
                  ethers?.formatUnits(mcusdBal || "0", 18)
                ).toFixed(2)
              }{" "}
              cUSD
            </span>
            <small className="text-xs text-gray/40">
              ~{" "}
              {
                //@ts-ignore
                parseFloat(
                  //@ts-ignore
                  ethers?.formatUnits(mcusdBal || "0", 18)
                ).toFixed(2) * 1000
              }{" "}
              NGN
            </small>
          </p>
        </div>
      </div>
    </div>
  );
};
export default SavingsCard;
