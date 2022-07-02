import { useBackend } from '../backend';
import { Box, Button, Flex, Modal, Section, LabeledControls, TimeDisplay } from '../components';
import { formatTime } from '../format';
import { Window } from '../layouts';

export const RiotGear = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    authed,
    authorisations,
    hasID,
    hasAccess,
    maxSecAccess,
    existingAuthorisation,
    canAuth,
    cooldown,
    showModal,
    modalText,
    modal,
  } = data;

  const displayModal = () => {
    data.modal = true;
  };

  return (
    <Window
      title={`Armoury Authorisation`}
      width={800}
      height={280}
    >
      <Window.Content>
        {(modalText === "") && (data.modal = false)}
        {(!!showModal || (!!modal && modalText !== "")) && (
          <Modal
            fontSize="20px"
            mr={2}
            p={3}>
            <Box>
              {(!!cooldown && !!authed && !!maxSecAccess && !!hasAccess && !!hasID) && <TimeDisplay value={cooldown} timing={"true"} format={formatTime} />}
              {modalText}
            </Box>
          </Modal>
        )}

        <Section>
          <Flex>
            <Flex.Item width="50%">
              <LabeledControls.Item>
                <Button
                  width={30}
                  height={3.5}
                  textAlign={"center"}
                  fontSize={2}
                  color={existingAuthorisation ? 'blue' : 'green'}
                  disabled={authed ? true : false}
                  onClick={() => (maxSecAccess
                    ? (existingAuthorisation
                      ? act('Repeal')
                      : act('HoS-Authorise'))
                    : (canAuth
                      ? (existingAuthorisation
                        ? act('Repeal')
                        : act('Authorise'))
                      : displayModal())
                  )}>
                  <Flex width={30} height={3.5} align="center" justify="center">
                    <Flex.Item>
                      {existingAuthorisation ? 'Repeal' : 'Authorise'}
                    </Flex.Item>
                  </Flex>
                </Button>
              </LabeledControls.Item>
            </Flex.Item>
            <Flex.Item width="50%">
              <LabeledControls.Item>
                <Button
                  width={30}
                  height={3.5}
                  textAlign={"center"}
                  fontSize={2}
                  color={'red'}
                  disabled={authed ? false : true}
                  onClick={() => (maxSecAccess && act('Deauthorise'))}>
                  <Flex width={30} height={3.5} align="center" justify="center">
                    <Flex.Item>
                      Deauthorise
                    </Flex.Item>
                  </Flex>
                </Button>
              </LabeledControls.Item>
            </Flex.Item>
          </Flex>
        </Section>
        <Section
          mb={0}
          title="Authorisations:"
          style={{ 'border-bottom': '2px solid rgba(51, 51, 51, 0.4);' }}
        >
          <Flex className="cloning-console__flex__head">
            <Flex.Item className="cloning-console__head__row" mr={2}>
              <Flex.Item
                className="cloning-console__head__item"
                width={18}>
                Name
              </Flex.Item>
              <Flex.Item
                className="cloning-console__head__item"
                width={18}>
                Rank
              </Flex.Item>
              <Flex.Item
                className="cloning-console__head__item"
                width={28}>
                Fingerprint ID
              </Flex.Item>
            </Flex.Item>
          </Flex>
        </Section>
        <Section>
          <Flex>
            <Flex.Item className="cloning-console__flex__table" height="89px" mt={-1.5}>
              <Flex.Item>
                {Object.keys(authorisations).map(authorisation => (
                  <Flex.Item key={data.authorisations[authorisation].name} className="cloning-console__body__row">
                    <Flex.Item
                      className="cloning-console__body__item"
                      width={18}>
                      <Flex.Item align="center">{data.authorisations[authorisation].name}</Flex.Item>
                    </Flex.Item>
                    <Flex.Item
                      className="cloning-console__body__item"
                      width={18}>
                      <Flex.Item align="center">{data.authorisations[authorisation].rank}</Flex.Item>
                    </Flex.Item>
                    <Flex.Item
                      className="cloning-console__body__item"
                      width={28}>
                      <Flex.Item align="center">{data.authorisations[authorisation].prints}</Flex.Item>
                    </Flex.Item>
                  </Flex.Item>
                ))}
              </Flex.Item>
            </Flex.Item>
          </Flex>
        </Section>
      </Window.Content>
    </Window>
  );
};
