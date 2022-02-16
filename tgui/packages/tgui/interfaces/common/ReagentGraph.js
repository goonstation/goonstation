import { Box, ColorBox, Flex, NoticeBox, Tooltip } from '../../components';

export const ReagentGraph = props => {
  const {
    container,
    height,
    ...rest
  } = props;
  const { maxVolume, totalVolume, finalColor } = container;
  const contents = container.contents || [];
  rest.height = height || "50px";

  return (
    <Box {...rest}>
      <Flex height="100%" direction="column">
        <Flex.Item grow>
          <Flex height="100%">
            {contents.map((reagent, index) => (
              <Flex.Item grow={reagent.volume/maxVolume} key={reagent.id}>
                <Tooltip content={`${reagent.name} (${reagent.volume}u)`} position="bottom">
                  <Box
                    px={0}
                    my={0}
                    height="100%"
                    backgroundColor={`rgb(${reagent.colorR}, ${reagent.colorG}, ${reagent.colorB})`}
                  />
                </Tooltip>
              </Flex.Item>
            ))}
            <Flex.Item grow={((maxVolume - totalVolume)/maxVolume)}>
              <Tooltip content={`Nothing (${maxVolume - totalVolume}u)`} position="bottom">
                <NoticeBox
                  px={0}
                  my={0}
                  height="100%"
                  backgroundColor="rgba(0, 0, 0, 0)" // invisible noticebox kind of nice
                />
              </Tooltip>
            </Flex.Item>
          </Flex>
        </Flex.Item>
        <Flex.Item>
          <Tooltip
            content={
              <Box>
                <ColorBox color={finalColor} /> Current Mixture Color
              </Box>
            }
            position="bottom">
            <Box height="14px" // same height as a Divider
              backgroundColor={contents.length ? finalColor : "rgba(0, 0, 0, 0.1)"}
              textAlign="center">
              {container.fake || (
                <Box
                  as="span"
                  backgroundColor="rgba(0, 0, 0, 0.5)"
                  px={1}>
                  {`${totalVolume}/${maxVolume}`}
                </Box>
              )}
            </Box>
          </Tooltip>
        </Flex.Item>
      </Flex>
    </Box>
  );
};

