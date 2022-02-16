import { Box, Flex, Icon, Section } from '../../components';

export const ReagentList = props => {
  const {
    container,
    buttonsForEach,
    height,
    ...rest
  } = props;
  const contents = container.contents || [];
  rest.height = height || 6;

  return (
    <Section scrollable>
      <Box {...rest}>
        {contents.length ? contents.map((reagent, index) => (
          <Flex key={reagent.id} mb={0.5}>
            <Flex.Item grow>
              <Icon
                pr={0.9}
                name="circle"
                style={{
                  "text-shadow": "0 0 3px #000;",
                }}
                color={`rgb(${reagent.colorR}, ${reagent.colorG}, ${reagent.colorB})`}
              />
              {`( ${reagent.volume}u ) ${reagent.name}`}
            </Flex.Item>
            <Flex.Item>
              {buttonsForEach(reagent)}
            </Flex.Item>
          </Flex>
        )) : (
          <Box color="label">
            <Icon
              pr={0.9}
              name="circle-o"
              style={{
                "text-shadow": "0 0 3px #000;",
              }}
            />
            Empty
          </Box>)}
      </Box>
    </Section>
  );
};
