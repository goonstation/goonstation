import { Button, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

interface SwingSignData {
  message: string;
  maxRows: number;
  maxCols: number;
}

export const SwingSign = () => {
  const { act, data } = useBackend<SwingSignData>();
  const { message, maxRows, maxCols } = data;

  const textareaStyle = {
    overflow: 'hidden',
    background: '#0A0A0A',
    color: '#FFFFFF',
    outline: '1px #6A93C3',
    textalign: 'center',
    wrap: 'hard',
  };

  return (
    <Window
      width={30 + maxCols * 8} // Size depending on specified text space
      height={95 + maxRows * 15}
      title="Swing sign"
    >
      <Window.Content /* scrollable */>
        <Section>
          <Stack vertical fill>
            <Stack.Item>
              <Button
                content="Save"
                onClick={() => {
                  data['message'] = (
                    document.getElementById('messageTA') as HTMLTextAreaElement
                  ).value;
                  act('save_message', data); // Send it back
                }}
              />
            </Stack.Item>
            <Stack.Item /* width="200px" */>
              <textarea
                id="messageTA"
                cols={maxCols}
                rows={maxRows}
                // \n's count as extra signs so to accomodate it we're giving extra maxRows-1 worth of space
                maxLength={maxCols * maxRows + maxRows - 1}
                style={textareaStyle}
                placeholder="Your message goes here..."
                onInput={(e) => {
                  const target = e.target as HTMLTextAreaElement;
                  let lines = target.value.split(/\n/g); // Split text into rows of text
                  for (let i = 0; i < lines.length; i++) {
                    // Fix overflowing text
                    if (lines[i] && lines[i].length > maxCols) {
                      // Check if line overflows
                      let newLine = lines[i].substring(0, maxCols); // Extract line from the beginning
                      lines[i] = lines[i].substring(maxCols, lines[i].length); // Replace the old line with what remains
                      lines.splice(i, 0, newLine); // Insert new line into the [i] spot
                    }
                  }
                  if (lines && lines.length > maxRows) {
                    // Delete excess rows
                    lines.splice(maxRows, lines.length - maxRows);
                  }
                  target.value = lines.join('\n'); // Join the lines array back together
                }}
              >
                {message}
              </textarea>
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
