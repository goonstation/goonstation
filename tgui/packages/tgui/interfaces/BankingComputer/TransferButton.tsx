/**
 * @file
 * @copyright 2024
 * @author mloccy (https://github.com/mloccy)
 * @license MIT
 */

import { useBackend, useLocalState } from "../../backend";
import { Button } from "../../components";
import { BankComputerStatus, Transfer } from "./type";

interface TransferButtonProps {
  id: string,
  type: string,
  frozen: boolean,
}

const transferButtonTooltip = (isAuthenticated: boolean, isFrozen: boolean) => {
  if (!isAuthenticated) {
    return "Please login to transfer funds.";
  } else if (isAuthenticated && isFrozen) {
    return "Cannot withdraw from account as it is frozen.";
  }

  return "";
};

const isSelfTransfer = (transferInfo: Transfer, myType: string, myId: string) => {
  if (transferInfo === null) {
    return false;
  } else {
    return ((myType === transferInfo.fromType) && (myId === transferInfo.fromId));
  }
};

const buttonText = (transferring: boolean, selfTransfer: boolean) => {

  if (transferring && !selfTransfer) {
    return "Transfer To";
  } else if (transferring && selfTransfer) {
    return "Cancel Transfer";
  } else {
    return "Transfer";
  }
};

const colorButton = (isTransferring: boolean, transferInfo: Transfer, myType: string, myId: string) => {
  const isSelf = (transferInfo === null)
    ? false
    : isSelfTransfer(transferInfo, myType, myId);

  if (isSelf && isTransferring) {
    return "grey";
  } else if (!isSelf && isTransferring) {
    return "red";
  } else {
    return "blue";
  }
};

export const TransferButton = (props: TransferButtonProps, context) => {
  const { act, data } = useBackend<BankComputerStatus>(context);
  const [transferring, setTransferring] = useLocalState<boolean>(context, "transferring", false);
  const [transferInfo, setTransferInfo] = useLocalState<Transfer>(context, "transferInfo", null);
  return (
    <Button
      title={transferButtonTooltip(data.authenticated, props.frozen)}
      disabled={(!data.authenticated) || props.frozen}
      onClick={() => {

        setTransferring(!transferring);

        if (!transferring) {
          let transferObj = {
            "fromId": props.id,
            "fromType": props.type,

            "toId": "",
            "toType": null,
          };

          setTransferInfo(transferObj);
        } else {
          if (isSelfTransfer(transferInfo, props.type, props.id)) {
            return;
          } else {
            let fullTransferObj = {
              "fromId": transferInfo.fromId,
              "fromType": transferInfo.fromType,

              "toId": props.id,
              "toType": props.type,
            };

            act("transfer", fullTransferObj);
          }
        }

      }}
      color={colorButton(transferring, transferInfo, props.type, props.id)}>
      {buttonText(transferring, isSelfTransfer(transferInfo, props.type, props.id))}
    </Button>
  );
};
