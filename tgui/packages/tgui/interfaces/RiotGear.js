import { useBackend, useLocalState } from '../backend';
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
    mismatchedAppearance,
    mismatchedID,
    maxSecAccess,
    existingAuthorisation,
    nameOnFile,
    printOnFile,
    cooldown,
  } = data;

  const [nameModal, displayNameModal] = useLocalState(context, 'nameIsOnFile', '');
  const [printModal, displayPrintModal] = useLocalState(context, 'printIsOnFile', '');

  return (
    <Window
      title={`Armoury Authorisation`}
      width={800}
      height={280}
    >
      <Window.Content>
        {(!hasID && !authed) && (
          <Modal
            fontSize="20px"
            mr={2}
            p={3}>
            <Box>
              No ID Given!
            </Box>
          </Modal>
        )}
        {(!hasAccess && !(!hasID) && !authed) && (
          <Modal
            fontSize="20px"
            mr={2}
            p={3}>
            <Box>
              Insufficient Access Level!
            </Box>
          </Modal>
        )}
        {(!(!mismatchedID) && !(!hasAccess) && !(!hasID) && !authed) && (
          <Modal
            fontSize="20px"
            mr={2}
            p={3}>
            <Box>
              ID Registration Does Not Match User!
            </Box>
          </Modal>
        )}
        {(!(!mismatchedAppearance) && !mismatchedID && !(!hasAccess) && !(!hasID) && !authed) && (
          <Modal
            fontSize="20px"
            mr={2}
            p={3}>
            <Box>
              User Appearance Does Not Match User Voiceprint!
            </Box>
          </Modal>
        )}
        {(!(!cooldown) && !mismatchedAppearance && !mismatchedID && !(!hasAccess) && !(!hasID)) && (
          <Modal
            fontSize="20px"
            mr={2}
            p={3}>
            <Box>
              <TimeDisplay value={cooldown} timing={"true"} format={formatTime} /> Before Any Commands May Be Accepted Again.
            </Box>
          </Modal>
        )}
        {(!maxSecAccess && !cooldown && !(!authed)) && (
          <Modal
            fontSize="20px"
            mr={2}
            p={3}>
            <Box>
              Armoury Access Has Been Authorised!
            </Box>
          </Modal>
        )}
        {nameModal && (
          <Modal
            fontSize="20px"
            mr={2}
            p={3}>
            <Box>
              Authorisation Already Issued By User!
            </Box>
          </Modal>
        )}
        {printModal && (
          <Modal
            fontSize="20px"
            mr={2}
            p={3}>
            <Box>
              User Fingerprint ID Already On File!
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
                    ? act('HoS-Authorise')
                    : ((nameOnFile === printOnFile)
                      ? (existingAuthorisation
                        ? act('Repeal')
                        : act('Authorise'))
                      : (nameOnFile
                        ? displayNameModal(true)
                        : displayPrintModal(true)))
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
                style={{ 'width': '200px' }}>Name
              </Flex.Item>
              <Flex.Item
                className="cloning-console__head__item"
                style={{ 'width': '200px' }}>Rank
              </Flex.Item>
              <Flex.Item
                className="cloning-console__head__item"
                style={{ 'width': '300px' }}>Fingerprint ID
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
                      style={{ 'width': '200px' }}><Flex.Item align="center">{data.authorisations[authorisation].name}</Flex.Item>
                    </Flex.Item>
                    <Flex.Item
                      className="cloning-console__body__item"
                      style={{ 'width': '200px' }}><Flex.Item align="center">{data.authorisations[authorisation].rank}</Flex.Item>
                    </Flex.Item>
                    <Flex.Item
                      className="cloning-console__body__item"
                      style={{ 'width': '320px' }}><Flex.Item align="center">{data.authorisations[authorisation].prints}</Flex.Item>
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
