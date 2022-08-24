/**
 * @file
 * @copyright 2020 WarlockD (https://github.com/warlockd)
 * @author Original WarlockD (https://github.com/warlockd)
 * @author Changes stylemistake
 * @author Changes ThePotato97
 * @license MIT
 */
import { resolveAsset } from '../assets';
import { Component } from 'inferno';
import marked from 'marked';
import { useBackend } from '../backend';
import { Box, Flex, Tabs, TextArea, Table } from '../components';
import { Window } from '../layouts';
import { clamp } from 'common/math';
import { sanitizeText } from '../sanitize';
const MAX_PAPER_LENGTH = 5000; // Question, should we send this with ui_data?
const WINDOW_TITLEBAR_HEIGHT = 30;
// Hacky, yes, works?...yes
const textWidth = (text, font, fontsize) => {
  // default font height is 12 in tgui
  font = fontsize + "x " + font;
  const c = document.createElement('canvas');
  const ctx = c.getContext("2d");
  ctx.font = font;
  return ctx.measureText(text).width;
};

const setFontinText = (text, font, color, bold=false) => {
  return "<span style=\""
    + "color:" + color + ";"
    + "font-family:" + font + ";"
    + ((bold)
      ? "font-weight: bold;"
      : "")
    + "\">" + text + "</span>";
};

const createIDHeader = index => {
  return "paperfield_" + index;
};
// To make a field you do a [_______] or however long the field is
// we will then output a TEXT input for it that hopefully covers
// the exact amount of spaces
const fieldRegex = /\[(_+)\]/g;
// TODO: regex needs documentation
const fieldTagRegex = /\[<input\s+(?!disabled)(.*?)\s+id="(?<id>paperfield_\d+)"(.*?)\/>\]/gm;
const signRegex = /%s(?:ign)?(?=\\s|$)?/igm;

const createInputField = (length, width, font,
  fontsize, color, id) => {
  return "[<input "
      + "type=\"text\" "
      + "style=\""
      + "font:'" + fontsize + "x " + font + "';"
      + "color:'" + color + "';"
      + "min-width:" + width + ";"
      + "max-width:" + width + ";"
      + "\" "
      + "id=\"" + id + "\" "
      + "maxlength=" + length +" "
      + "size=" + length + " "
      + "/>]";
};

const createFields = (txt, font, fontsize, color, counter) => {
  const retText = txt.replace(fieldRegex, (match, p1, offset, string) => {
    const width = textWidth(match, font, fontsize) + "px";
    return createInputField(p1.length,
      width, font, fontsize, color, createIDHeader(counter++));
  });
  return {
    counter,
    text: retText,
  };
};

const signDocument = (txt, color, user) => {
  return txt.replace(signRegex, () => {
    return setFontinText(user, "Times New Roman", color, true);
  });
};

const runMarkedDefault = value => {
  // Override function, any links and images should
  // kill any other marked tokens we don't want here
  const walkTokens = token => {
    switch (token.type) {
      case 'url':
      case 'autolink':
      case 'reflink':
      case 'link':
      case 'image':
        token.type = 'text';
        // Once asset system is up change to some default image
        // or rewrite for icon images
        token.href = "";
        break;
    }
  };
  return marked(value, {
    breaks: true,
    smartypants: true,
    smartLists: true,
    walkTokens,
    // Once assets are fixed might need to change this for them
    baseUrl: 'thisshouldbreakhttp',
  });
};

/*
** This gets the field, and finds the dom object and sees if
** the user has typed something in.  If so, it replaces,
** the dom object, in txt with the value, spaces so it
** fits the [] format and saves the value into a object
** There may be ways to optimize this in javascript but
** doing this in byond is nightmarish.
**
** It returns any values that were saved and a corrected
** html code or null if nothing was updated
*/
const checkAllFields = (txt, font, color, userName, bold=false) => {
  let matches;
  let values = {};
  let replace = [];
  // I know its tempting to wrap ALL this in a .replace
  // HOWEVER the user might not of entered anything
  // if thats the case we are rebuilding the entire string
  // for nothing, if nothing is entered, txt is just returned
  while ((matches = fieldTagRegex.exec(txt)) !== null) {
    const fullMatch = matches[0];
    const id = matches.groups.id;
    if (id) {
      const dom = document.getElementById(id);
      // make sure we got data, and kill any html that might
      // be in it
      const domText = dom && dom.value ? dom.value : "";
      if (domText.length === 0) {
        continue;
      }
      const sanitizedText = sanitizeText(dom.value.trim(), []);
      if (sanitizedText.length === 0) {
        continue;
      }
      // this is easier than doing a bunch of text manipulations
      const target = dom.cloneNode(true);
      // in case they sign in a field
      if (sanitizedText.match(signRegex)) {
        target.style.fontFamily = "Times New Roman";
        bold = true;
        target.defaultValue = userName;
      }
      else {
        target.style.fontFamily = font;
        target.defaultValue = sanitizedText;
      }
      if (bold) {
        target.style.fontWeight = "bold";
      }
      target.style.color = color;
      target.disabled = true;
      const wrap = document.createElement('div');
      wrap.appendChild(target);
      values[id] = sanitizedText; // save the data
      replace.push({ value: "[" + wrap.innerHTML + "]", rawText: fullMatch });
    }
  }
  if (replace.length > 0) {
    for (const o of replace) {

      txt = txt.replace(o.rawText, o.value);
    }
  }
  return { text: txt, fields: values };
};

const pauseEvent = e => {
  if (e.stopPropagation) { e.stopPropagation(); }
  if (e.preventDefault) { e.preventDefault(); }
  e.cancelBubble=true;
  e.returnValue=false;
  return false;
};

const Stamp = (props, context) => {
  const {
    image,
    opacity,
    activeStamp,
  } = props;
  const stampTransform = {
    'left': image.x + 'px',
    'top': image.y + 'px',
    'transform': 'rotate(' + image.rotate + 'deg)',
    'opacity': opacity || 1.0,
  };
  return (
    image.sprite.match("stamp-.*") ? (
      <img
        id={activeStamp && "stamp"}
        style={stampTransform}
        className="paper__stamp"
        src={resolveAsset(image.sprite)}
      />
    )
      : (
        <Box
          id={activeStamp && "stamp"}
          style={stampTransform}
          className="paper__stamp-text">
          {image.sprite}
        </Box>
      )
  );
};

const setInputReadonly = (text, readonly) => {
  return readonly
    ? text.replace(/<input\s[^d]/g, '<input disabled ')
    : text.replace(/<input\sdisabled\s/g, '<input ');
};

// got to make this a full component if we
// want to control updates
export const PaperSheetView = (props, context) => {
  const {
    value = "",
    stamps = [],
    backgroundColor,
    readOnly,
  } = props;
  const stampList = stamps || [];
  const textHtml = {
    __html: '<span class="paper-text">'
      + setInputReadonly(value, readOnly)
      + '</span>',
  };
  return (
    <Box
      className="paper__page"
      position="relative"
      backgroundColor={backgroundColor}
      width="100%"
      height="100%">
      <Box
        color="black"
        backgroundColor={backgroundColor}
        fillPositionedParent
        width="100%"
        height="100%"
        dangerouslySetInnerHTML={textHtml}
        p="10px" />
      {stampList.map((o, i) => (
        <Stamp key={o[0] + i}
          image={{ sprite: o[0], x: o[1], y: o[2], rotate: o[3] }} />
      ))}
    </Box>
  );
};

// again, need the states for dragging and such
class PaperSheetStamper extends Component {
  constructor(props, context) {
    super(props, context);
    this.state = {
      x: 0,
      y: 0,
      rotate: 0,
    };
    this.style = null;
    this.handleMouseMove = e => {
      const pos = this.findStampPosition(e);
      if (!pos) { return; }
      // center offset of stamp & rotate
      pauseEvent(e);
      this.setState({ x: pos[0], y: pos[1], rotate: pos[2] });
    };
    this.handleMouseClick = e => {
      if (e.pageY <= WINDOW_TITLEBAR_HEIGHT) { return; }
      const { act } = useBackend(this.context);
      const stampObj = {
        x: this.state.x, y: this.state.y, r: this.state.rotate,
      };
      act("stamp", stampObj);
    };
  }

  findStampPosition(e) {
    let rotating;
    const windowRef = document.querySelector('.Layout__content');
    if (e.shiftKey) {
      rotating = true;
    }

    const stamp = document.getElementById("stamp");
    if (stamp)
    {
      const stampHeight = stamp.clientHeight;
      const stampWidth = stamp.clientWidth;

      const currentHeight = rotating
        ? this.state.y
        : e.pageY + windowRef.scrollTop - stampHeight;
      const currentWidth = rotating ? this.state.x : e.pageX - (stampWidth / 2);

      const widthMin = 0;
      const heightMin = 0;

      const widthMax = windowRef.clientWidth - stampWidth;
      const heightMax = (
        windowRef.clientHeight + windowRef.scrollTop - stampHeight
      );

      const radians = Math.atan2(
        e.pageX - currentWidth,
        e.pageY - currentHeight
      );

      const rotate = rotating
        ? radians * (180 / Math.PI) * -1
        : this.state.rotate;

      return [
        clamp(currentWidth, widthMin, widthMax),
        clamp(currentHeight, heightMin, heightMax),
        rotate,
      ];
    }
  }

  componentDidMount() {
    document.addEventListener("mousemove", this.handleMouseMove);
    document.addEventListener("click", this.handleMouseClick);
  }

  componentWillUnmount() {
    document.removeEventListener("mousemove", this.handleMouseMove);
    document.removeEventListener("click", this.handleMouseClick);
  }

  render() {
    const {
      value,
      stampClass,
      stamps,
    } = this.props;
    const stampList = stamps || [];
    const currentPos = {
      sprite: stampClass,
      x: this.state.x,
      y: this.state.y,
      rotate: this.state.rotate,
    };
    return (
      <>
        <PaperSheetView
          readOnly
          value={value}
          stamps={stampList} />
        <Stamp
          activeStamp
          opacity={0.5}
          image={currentPos} />
      </>
    );
  }
}

// ugh.  So have to turn this into a full
// component too if I want to keep updates
// low and keep the weird flashing down
class PaperSheetEdit extends Component {
  constructor(props, context) {
    super(props, context);
    this.state = {
      previewSelected: "Preview",
      oldText: props.value || "",
      textAreaText: "",
      combinedText: props.value || "",
      showingHelpTip: false,
    };
  }

  // This is the main rendering part, this creates the html from marked text
  // as well as the form fields
  createPreview(value, doFields = false) {
    const { data } = useBackend(this.context);
    const {
      text,
      penColor,
      penFont,
      isCrayon,
      fieldCounter,
      editUsr,
    } = data;
    const out = { text: text };
    // check if we are adding to paper, if not
    // we still have to check if someone entered something
    // into the fields
    value = value.trim();
    if (value.length > 0) {
      // Second, we sanitize the text of html
      const sanitizedText = sanitizeText(value);
      const signedText = signDocument(sanitizedText, penColor, editUsr);
      // Third we replace the [__] with fields as markedjs fucks them up
      const fieldedText = createFields(
        signedText, penFont, 12, penColor, fieldCounter);
      // Fourth, parse the text using markup
      const formattedText = runMarkedDefault(fieldedText.text);
      // Fifth, we wrap the created text in the pin color, and font.
      // crayon is bold (<b> tags), maybe make fountain pin italic?
      const fontedText = setFontinText(
        formattedText, penFont, penColor, isCrayon);
      out.text += fontedText;
      out.fieldCounter = fieldedText.counter;
    }
    if (doFields) {
      // finally we check all the form fields to see
      // if any data was entered by the user and
      // if it was return the data and modify the text
      const finalProcessing = checkAllFields(
        out.text, penFont, penColor, editUsr, isCrayon);
      out.text = finalProcessing.text;
      out.formFields = finalProcessing.fields;
    }
    return out;
  }

  onInputHandler(e, value) {
    if (value !== this.state.textAreaText) {
      const combinedLength = this.state.oldText.length
        + this.state.textAreaText.length;
      if (combinedLength > MAX_PAPER_LENGTH) {
        if ((combinedLength - MAX_PAPER_LENGTH) >= value.length) {
          // Basically we cannot add any more text to the paper
          value = '';
        } else {
          value = value.substr(0, value.length
            - (combinedLength - MAX_PAPER_LENGTH));
        }
        // we check again to save an update
        if (value === this.state.textAreaText) {
          // Do nothing
          return;
        }
      }
      this.setState(() => ({
        textAreaText: value,
        combinedText: this.createPreview(value),
      }));
    }
  }
  // the final update send to byond, final upkeep
  finalUpdate(newText) {
    const { act } = useBackend(this.context);
    const finalProcessing = this.createPreview(newText, true);
    act('save', finalProcessing);
    this.setState(() => { return {
      textAreaText: "",
      previewSelected: "save",
      combinedText: finalProcessing.text,
    }; });
    // byond should switch us to readonly mode from here
  }

  render() {
    const {
      textColor,
      fontFamily,
      stamps,
      backgroundColor,
    } = this.props;
    return (
      <Flex
        direction="column"
        fillPositionedParent>
        <Flex.Item>
          <Tabs
            size="100%">
            <Tabs.Tab
              key="marked_edit"
              textColor="black"
              backgroundColor={this.state.previewSelected === "Edit"
                ? "grey"
                : "white"}
              selected={this.state.previewSelected === "Edit"}
              onClick={() => this.setState({ previewSelected: "Edit" })}>
              Edit
            </Tabs.Tab>
            <Tabs.Tab
              key="marked_preview"
              textColor="black"
              backgroundColor={this.state.previewSelected === "Preview"
                ? "grey"
                : "white"}
              selected={this.state.previewSelected === "Preview"}
              onClick={() => this.setState(() => {
                const newState = {
                  previewSelected: "Preview",
                  textAreaText: this.state.textAreaText,
                  combinedText: this.createPreview(
                    this.state.textAreaText).text,
                };
                return newState;
              })}>
              Preview
            </Tabs.Tab>
            <Tabs.Tab
              key="marked_done"
              textColor="black"
              backgroundColor={this.state.previewSelected === "confirm"
                ? "red"
                : this.state.previewSelected === "save"
                  ? "grey"
                  : "white"}
              selected={this.state.previewSelected === "confirm"
                || this.state.previewSelected === "save"}
              onClick={() => {
                if (this.state.previewSelected === "confirm") {
                  this.finalUpdate(this.state.textAreaText);
                }
                else if (this.state.previewSelected === "Edit") {
                  this.setState(() => {
                    const newState = {
                      previewSelected: "confirm",
                      textAreaText: this.state.textAreaText,
                      combinedText: this.createPreview(
                        this.state.textAreaText).text,
                    };
                    return newState;
                  });
                }
                else {
                  this.setState({ previewSelected: "confirm" });
                }
              }}>
              {this.state.previewSelected === "confirm" ? "Confirm" : "Save"}
            </Tabs.Tab>
            <Tabs.Tab
              key="marked_help"
              textColor={'black'}
              backgroundColor="white"
              icon="question-circle-o"
              onmouseover={() => {
                this.setState({ showingHelpTip: true });
              }}
              onmouseout={() => {
                this.setState({ showingHelpTip: false });
              }}>
              Help
            </Tabs.Tab>
          </Tabs>
        </Flex.Item>
        <Flex.Item
          grow={1}
          basis={1}>
          {this.state.previewSelected === "Edit" && (
            <TextArea
              value={this.state.textAreaText}
              textColor={textColor}
              fontFamily={fontFamily}
              height={(window.innerHeight - 60) + "px"}
              backgroundColor={backgroundColor}
              onInput={this.onInputHandler.bind(this)} />
          ) || (
            <PaperSheetView
              value={this.state.combinedText}
              stamps={stamps}
              fontFamily={fontFamily}
              textColor={textColor} />
          )}
        </Flex.Item>
        {this.state.showingHelpTip && (
          <HelpToolip />
        )}
      </Flex>
    );
  }
}

export const PaperSheet = (props, context) => {
  const { data } = useBackend(context);
  const {
    editMode,
    text,
    paperColor = "white",
    penColor = "black",
    penFont = "Verdana",
    stamps,
    stampClass,
    sizeX,
    sizeY,
    name,
  } = data;
  const stampList = !stamps
    ? []
    : stamps;
  const decideMode = mode => {
    switch (mode) {
      case 0:
        return (
          <PaperSheetView
            value={text}
            stamps={stampList}
            readOnly />
        );
      case 1:
        return (
          <PaperSheetEdit
            value={text}
            textColor={penColor}
            fontFamily={penFont}
            stamps={stampList}
            backgroundColor={paperColor} />
        );
      case 2:
        return (
          <PaperSheetStamper
            value={text}
            stamps={stampList}
            stampClass={stampClass} />
        );
      default:
        return "ERROR ERROR WE CANNOT BE HERE!!";
    }
  };
  return (
    <Window
      title={name}
      theme="paper"
      width={sizeX || 400}
      height={sizeY || 500}>
      <Window.Content
        backgroundColor={paperColor}
        scrollable>
        <Box
          id="page"
          fitted
          fillPositionedParent>
          {decideMode(editMode)}
        </Box>
      </Window.Content>
    </Window>
  );
};

const HelpToolip = () => {
  return (
    <Box
      position="absolute"
      left="10px"
      top="25px"
      width="300px"
      height="350px"
      backgroundColor="#E8E4C9" // offset from paper color
      textAlign="center">
      <h3>
        Markdown Syntax
      </h3>
      <Table>
        <Table.Row>
          <Table.Cell>
            <Box>
              Heading
            </Box>
            =====
          </Table.Cell>
          <Table.Cell>
            <h2>
              Heading
            </h2>
          </Table.Cell>
        </Table.Row>

        <Table.Row>
          <Table.Cell>
            <Box>
              Sub Heading
            </Box>
            ------
          </Table.Cell>
          <Table.Cell>
            <h4>
              Sub Heading
            </h4>
          </Table.Cell>
        </Table.Row>

        <Table.Row>
          <Table.Cell>
            _Italic Text_
          </Table.Cell>
          <Table.Cell>
            <i>
              Italic Text
            </i>
          </Table.Cell>
        </Table.Row>

        <Table.Row>
          <Table.Cell>
            **Bold Text**
          </Table.Cell>
          <Table.Cell>
            <b>
              Bold Text
            </b>
          </Table.Cell>
        </Table.Row>

        <Table.Row>
          <Table.Cell>
            `Code Text`
          </Table.Cell>
          <Table.Cell>
            <code>
              Code Text
            </code>
          </Table.Cell>
        </Table.Row>

        <Table.Row>
          <Table.Cell>
            ~~Strikethrough Text~~
          </Table.Cell>
          <Table.Cell>
            <s>
              Strikethrough Text
            </s>
          </Table.Cell>
        </Table.Row>

        <Table.Row>
          <Table.Cell>
            <Box>
              Horizontal Rule
            </Box>
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
              <Table.Row>
                * List Element 1
              </Table.Row>
              <Table.Row>
                * List Element 2
              </Table.Row>
              <Table.Row>
                * Etc...
              </Table.Row>
            </Table>
          </Table.Cell>
          <Table.Cell>
            <ul>
              <li>
                List Element 1
              </li>
              <li>
                List Element 2
              </li>
              <li>
                Etc...
              </li>
            </ul>
          </Table.Cell>
        </Table.Row>

        <Table.Row>
          <Table.Cell>
            <Table>
              <Table.Row>
                1. List Element 1
              </Table.Row>
              <Table.Row>
                2. List Element 2
              </Table.Row>
              <Table.Row>
                3. Etc...
              </Table.Row>
            </Table>
          </Table.Cell>
          <Table.Cell>
            <ol>
              <li>
                List Element 1
              </li>
              <li>
                List Element 2
              </li>
              <li>
                Etc...
              </li>
            </ol>
          </Table.Cell>
        </Table.Row>
      </Table>
    </Box>
  );
};
