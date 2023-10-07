import { useBackend } from '../backend';
import { Window } from '../layouts';
import { Box, Button, Icon, Section } from '../components';

type TeleConsoleParams = {
  xtarget: number
  ytarget: number
  ztarget: number
  host_id: string
  readout: string
  panel_open: boolean
  padNum: number
  max_bookmarks: number
  bookmarks: [];
}

export const TeleConsole = (_props, context) => {
  const { act, data } = useBackend<TeleConsoleParams>(context);
  const { xtarget, ytarget, ztarget, host_id, bookmarks, readout, panel_open, padNum, max_bookmarks } = data;

  return (
    <Window
      theme="ntos"
      width={400}
      height={500}>
      <Window.Content textAlign="center">
        <Section width="80%" mx="auto">
          {host_id ? (
            <Box color="green">
              <Box>
                <Icon name="check" /> Connected to host!
              </Box>
              <Button
                icon="power-off"
                content="RESET CONNECTION"
                color="red"
                onClick={() => act('reconnect', { value: 2 })}
              />
            </Box>
          ) : (
            <Box color="red">
              <Box>
                <Icon name="warning" /> No connection to host!
              </Box>
              <Button
                icon="power-off"
                content="Retry"
                color="green"
                onClick={() => act('reconnect', { value: 1 })}
              />
            </Box>
          )}
        </Section>
        <Section width="80%" mx="auto">
          {readout}
        </Section>
        <Section width="80%" mx="auto">
          {"Taget Cordinates: "}
          <Box>
            {"X: "}
            <Button
              icon="backward"
              onClick={() => act('setX', { value: xtarget - 10 })}
            />
            <Button
              icon="caret-left"
              onClick={() => act('setX', { value: xtarget - 1 })}
            />
            <Button.Input
              content={xtarget}
              onCommit={(e, value) => act('setX', { value: value })}
            />
            <Button
              icon="caret-right"
              onClick={() => act('setX', { value: xtarget + 1 })}
            />
            <Button
              icon="forward"
              onClick={() => act('setX', { value: xtarget + 10 })}
            />
          </Box>
          <Box>
            {"Y: "}
            <Button
              icon="backward"
              onClick={() => act('setY', { value: ytarget - 10 })}
            />
            <Button
              icon="caret-left"
              onClick={() => act('setY', { value: ytarget - 1 })}
            />
            <Button.Input
              content={ytarget}
              onCommit={(e, value) => act('setY', { value: value })}
            />
            <Button
              icon="caret-right"
              onClick={() => act('setY', { value: ytarget + 1 })}
            />
            <Button
              icon="forward"
              onClick={() => act('setY', { value: ytarget + 10 })}
            />
          </Box>
          <Box>
            {"Z: "}
            <Button
              icon="caret-left"
              onClick={() => act('setZ', { value: ztarget - 1 })}
            />
            <Button.Input
              content={ztarget}
              onCommit={(e, value) => act('setZ', { value: value })}
            />
            <Button
              icon="caret-right"
              onClick={() => act('setZ', { value: ztarget + 1 })}
            />
          </Box>
        </Section>
        <Section width="80%" mx="auto">
          <Box>
            <Button
              color={host_id ? "green" : "gray"}
              icon="sign-out-alt"
              onClick={() => act("send")}
              content="Send"
            />
            <Button
              color={host_id ? "green" : "gray"}
              icon="sign-in-alt"
              onClick={() => act("receive")}
              content="Recieve"
            />
            <Button
              color={host_id ? "green" : "gray"}
              onClick={() => act("portal")}
            >
              <Icon name="ring" rotation={90} />Toggle Portal
            </Button>
          </Box>
          <Button
            color={host_id ? "green" : "geay"}
            icon="magnifying-glass"
            onClick={() => act("scan")}
            content="Scan"
          />
        </Section>
        <Section width="80%" mx="auto">
          {"Bookmarks: "}
          <Button
            color={bookmarks.length < max_bookmarks ? "green" : "gray"}
            icon="add"
            onClick={() => act("addbookmark")}
          />
          {bookmarks.map(mark => {
            return (
              <Box key={mark["ref"]}>
                <Button
                  icon="bookmark"
                  onClick={() => act("restorebookmark", { value: mark["ref"] })}
                  content={mark["name"]}
                />
                {mark["xyz"]}
                <Button
                  icon="trash"
                  color="red"
                  onClick={() => act("deletebookmark", { value: mark["ref"] })}
                />
              </Box>
            );
          })}
        </Section>
        {panel_open ? (
          <Section width="80%" mx="auto">
            <Box>
              {"Open panel:"}
            </Box>
            <Box>
              {"Linked pad number:"}
              <Button
                content={padNum}
                onClick={() => act("setpad")}
              />
            </Box>
          </Section>
        ) : null}
      </Window.Content>
    </Window>
  );
};
