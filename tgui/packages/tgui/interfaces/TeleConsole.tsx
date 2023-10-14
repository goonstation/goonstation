/**
 * @file
 * @copyright 2023
 * @author Valtsu0 (https://github.com/Valtsu0)
 * @license ISC
 */
import { useBackend } from '../backend';
import { Window } from '../layouts';
import { Box, Button, Icon, Input, Section } from '../components';

type TeleConsoleData = {
  xtarget: number
  ytarget: number
  ztarget: number
  host_id: string
  readout: string
  panel_open: boolean
  padNum: number
  max_bookmarks: number
  bookmarks: BookmarkData[];
}

type BookmarkData = {
  ref: string
  name: string
  X: number
  Y: number
  Z: number
}

export const TeleConsole = (_props, context) => {
  const { act, data } = useBackend<TeleConsoleData>(context);
  const { xtarget, ytarget, ztarget, host_id, bookmarks, readout, panel_open, padNum, max_bookmarks } = data;

  return (
    <Window
      theme="ntos"
      width={400}
      height={500}>
      <Window.Content textAlign="center">
        <ConnectionSection />
        <Section>
          {readout}
        </Section>
        <CoordinatesSection />
        <Section>
          <Box>
            <Button
              color="green"
              icon="sign-out-alt"
              onClick={() => act("send")}
              content="Send"
              disabled={!host_id}
            />
            <Button
              color="green"
              icon="sign-in-alt"
              onClick={() => act("receive")}
              content="Receive"
              disabled={!host_id}
            />
            <Button
              color="green"
              onClick={() => act("portal")}
              disabled={!host_id}
            >
              <Icon name="ring" rotation={90} />Toggle Portal
            </Button>
          </Box>
          <Button
            color="green"
            icon="magnifying-glass"
            onClick={() => act("scan")}
            content="Scan"
            disabled={!host_id}
          />
        </Section>
        <Section>
          {"Bookmarks: "}
          {bookmarks.map(mark => {
            return (
              <Box key={mark["ref"]}>
                <Button
                  icon="bookmark"
                  onClick={() => act("restorebookmark", { value: mark["ref"] })}
                  content={mark["name"]}
                />
                {`(${mark["X"]}/${mark["Y"]}/${mark["Z"]})`}
                <Button
                  icon="trash"
                  color="red"
                  onClick={() => act("deletebookmark", { value: mark["ref"] })}
                />
              </Box>
            );
          })}
          {!!(bookmarks.length < max_bookmarks) && ((
            <Box>
              <Input
                onEnter={(e, value) => act('addbookmark', { value: value })}
              />
              {`(${xtarget}/${ytarget}/${ztarget})`}
            </Box>
          ))}

        </Section>
        {!!panel_open && (
          <Section>
            <Box>Open panel:</Box>
            <Box>
              Linked pad number:
              <Button
                content={padNum}
                onClick={() => act("setpad")}
              />
            </Box>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};

export const ConnectionSection = (_props, context) => {
  const { act, data } = useBackend<TeleConsoleData>(context);
  const { host_id } = data;

  return (
    <Section>
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
  );
};

export const CoordinatesSection = (_props, context) => {
  const { act, data } = useBackend<TeleConsoleData>(context);
  const { xtarget, ytarget, ztarget } = data;

  return (
    <Section>
      {"Target Coordinates: "}
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
  );
};
