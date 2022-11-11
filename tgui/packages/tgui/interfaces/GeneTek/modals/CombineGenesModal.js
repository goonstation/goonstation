/**
 * @file
 * @copyright 2021
 * @author BenLubar (https://github.com/BenLubar)
 * @license ISC
 */

import { useBackend, useSharedState } from "../../../backend";
import { Box, Button, Modal } from "../../../components";

export const CombineGenesModal = (props, context) => {
  const { data, act } = useBackend(context);
  const [isCombining, setIsCombining] = useSharedState(context, "iscombining", false);
  const {
    savedMutations,
    combining = [],
  } = data;

  return (
    <Modal full>
      <Box width={16} mr={2}>
        <Box bold mb={2}>
          Select genes to combine
        </Box>
        <Box mb={2}>
          {savedMutations.map(g => (
            <Box key={g.ref}>
              {combining.indexOf(g.ref) >= 0 ? (
                <Button
                  icon="check"
                  color="blue"
                  onClick={() => act("togglecombine", { ref: g.ref })} />
              ) : (
                <Button
                  icon="blank"
                  color="grey"
                  onClick={() => act("togglecombine", { ref: g.ref })} />
              )}
              {" " + g.name}
            </Box>
          ))}
        </Box>
        <Box inline width="50%" textAlign="center">
          <Button
            icon="sitemap"
            disabled={!combining.length}
            onClick={() => {
              act("combinegenes");
              setIsCombining(false);
            }}>
            Combine
          </Button>
        </Box>
        <Box inline width="50%" textAlign="center">
          <Button
            color="bad"
            icon="times"
            onClick={() => setIsCombining(false)}>
            Cancel
          </Button>
        </Box>
      </Box>
    </Modal>
  );
};
