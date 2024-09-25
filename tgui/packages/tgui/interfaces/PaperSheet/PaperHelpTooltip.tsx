import { Box, Table } from 'tgui-core/components';

export const HelpToolip = () => {
  return (
    <Box
      position="absolute"
      left="10px"
      top="25px"
      width="300px"
      height="350px"
      backgroundColor="#E8E4C9" // offset from paper color
      textAlign="center"
    >
      <h3>Markdown Syntax</h3>
      <Table>
        <Table.Row>
          <Table.Cell>
            <Box># Heading</Box>
          </Table.Cell>
          <Table.Cell>
            <h2>Heading</h2>
          </Table.Cell>
        </Table.Row>

        <Table.Row>
          <Table.Cell>
            <Box>## Sub Heading</Box>
          </Table.Cell>
          <Table.Cell>
            <h4>Sub Heading</h4>
          </Table.Cell>
        </Table.Row>

        <Table.Row>
          <Table.Cell>_Italic Text_</Table.Cell>
          <Table.Cell>
            <i>Italic Text</i>
          </Table.Cell>
        </Table.Row>

        <Table.Row>
          <Table.Cell>**Bold Text**</Table.Cell>
          <Table.Cell>
            <b>Bold Text</b>
          </Table.Cell>
        </Table.Row>

        <Table.Row>
          <Table.Cell>`Code Text`</Table.Cell>
          <Table.Cell>
            <code>Code Text</code>
          </Table.Cell>
        </Table.Row>

        <Table.Row>
          <Table.Cell>~~Strikethrough Text~~</Table.Cell>
          <Table.Cell>
            <s>Strikethrough Text</s>
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <br />
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Box>Horizontal Rule</Box>
            ---
          </Table.Cell>
          <Table.Cell>
            Horizontal Rule
            <hr />
          </Table.Cell>
        </Table.Row>

        <Table.Row>
          <Table.Cell>
            <Table>
              <Table.Row>* List Element 1</Table.Row>
              <Table.Row>* List Element 2</Table.Row>
              <Table.Row>* Etc...</Table.Row>
            </Table>
          </Table.Cell>
          <Table.Cell>
            <ul>
              <li>List Element 1</li>
              <li>List Element 2</li>
              <li>Etc...</li>
            </ul>
          </Table.Cell>
        </Table.Row>

        <Table.Row>
          <Table.Cell>
            <Table>
              <Table.Row>1. List Element 1</Table.Row>
              <Table.Row>2. List Element 2</Table.Row>
              <Table.Row>3. Etc...</Table.Row>
            </Table>
          </Table.Cell>
          <Table.Cell>
            <ol>
              <li>List Element 1</li>
              <li>List Element 2</li>
              <li>Etc...</li>
            </ol>
          </Table.Cell>
        </Table.Row>

        <Table.Row>
          <Table.Cell>%sign</Table.Cell>
          <Table.Cell>
            <i>Your Name Here</i>
          </Table.Cell>
        </Table.Row>
      </Table>
    </Box>
  );
};
