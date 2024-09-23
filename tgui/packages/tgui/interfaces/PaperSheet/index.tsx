/**
 * @file
 * @copyright 2020 WarlockD (https://github.com/warlockd)
 * @author Original WarlockD (https://github.com/warlockd)
 * @author Changes stylemistake
 * @author Changes ThePotato97
 * @author Changes ZeWaka
 * @license MIT
 */

import { marked } from 'marked';
import { useEffect, useState } from 'react';
import { Box, Flex, Tabs, TextArea } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { sanitizeText } from '../../sanitize';
import { HelpToolip } from './PaperHelpTooltip';
import { PaperSheetStamper, PaperSheetView } from './Stamps';
const MAX_PAPER_LENGTH = 5000; // Question, should we send this with ui_data?

// Hacky, yes, works?...yes
const textWidth = (text: string, font: string, fontsize: string) => {
  // default font height is 12 in tgui
  font = fontsize + 'x ' + font;
  const c = document.createElement('canvas');
  const ctx = c.getContext('2d');
  ctx.font = font;
  return ctx.measureText(text).width;
};

const setFontinText = (
  text: string,
  font: string,
  color: string,
  bold = false,
) => {
  return (
    '<span style="' +
    'color:' +
    color +
    ';' +
    'font-family:' +
    font +
    ';' +
    (bold ? 'font-weight: bold;' : '') +
    '">' +
    text +
    '</span>'
  );
};

const createIDHeader = (index) => {
  return 'paperfield_' + index;
};

// To make a field you do a [_______] or however long the field is
// we will then output a TEXT input for it that hopefully covers
// the exact amount of spaces
const fieldRegex = /\[(_+)\]/g;
// TODO: regex needs documentation
const fieldTagRegex =
  /\[<input\s+(?!disabled)(.*?)\s+id="(?<id>paperfield_\d+)"(.*?)\/>\]/gm;
const signRegex = /%s(?:ign)?(?=\\s|$)?/gim;

const createInputField = (length, width, font, fontsize, color, id) => {
  return (
    '[<input ' +
    'type="text" ' +
    'style="' +
    "font:'" +
    fontsize +
    'x ' +
    font +
    "';" +
    "color:'" +
    color +
    "';" +
    'min-width:' +
    width +
    ';' +
    'max-width:' +
    width +
    ';' +
    '" ' +
    'id="' +
    id +
    '" ' +
    'maxlength=' +
    length +
    ' ' +
    'size=' +
    length +
    ' ' +
    '/>]'
  );
};

const createFields = (txt, font, fontsize, color, counter) => {
  const retText = txt.replace(fieldRegex, (match, p1, offset, string) => {
    const width = textWidth(match, font, fontsize) + 'px';
    return createInputField(
      p1.length,
      width,
      font,
      fontsize,
      color,
      createIDHeader(counter++),
    );
  });
  return {
    counter,
    text: retText,
  };
};

const signDocument = (txt: string, color: string, user: string) => {
  return txt.replace(signRegex, () => {
    return setFontinText(user, 'Times New Roman', color, true);
  });
};

const runMarkedDefault = (value: string) => {
  // Override function, any links and images should
  // kill any other marked tokens we don't want here
  const walkTokens = (token) => {
    switch (token.type) {
      case 'url':
      case 'autolink':
      case 'reflink':
      case 'link':
      case 'image':
        token.type = 'text';
        // Once asset system is up change to some default image
        // or rewrite for icon images
        token.href = '';
        break;
    }
  };
  const markedOptions: marked.MarkedOptions = {
    breaks: true,
    smartypants: true,
    smartLists: true,
    walkTokens,
    // Once assets are fixed might need to change this for them
    baseUrl: 'thisshouldbreakhttp',
  };
  return marked(value, markedOptions);
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
const checkAllFields = (txt, font, color, userName, bold = false) => {
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
      const dom = document.getElementById(id) as HTMLInputElement;
      // make sure we got data, and kill any html that might
      // be in it
      const domText = dom && dom.value ? dom.value : '';
      if (domText.length === 0) {
        continue;
      }
      const sanitizedText = sanitizeText(dom.value.trim(), false, []);
      if (sanitizedText.length === 0) {
        continue;
      }
      // this is easier than doing a bunch of text manipulations
      const target = dom.cloneNode(true) as HTMLInputElement;
      // in case they sign in a field
      if (sanitizedText.match(signRegex)) {
        target.style.fontFamily = 'Times New Roman';
        bold = true;
        target.defaultValue = userName;
      } else {
        target.style.fontFamily = font;
        target.defaultValue = sanitizedText;
      }
      if (bold) {
        target.style.fontWeight = 'bold';
      }
      target.style.color = color;
      target.disabled = true;
      const wrap = document.createElement('div');
      wrap.appendChild(target);
      values[id] = sanitizedText; // save the data
      replace.push({ value: '[' + wrap.innerHTML + ']', rawText: fullMatch });
    }
  }
  if (replace.length > 0) {
    for (const o of replace) {
      txt = txt.replace(o.rawText, o.value);
    }
  }
  return { text: txt, fields: values };
};

interface PaperSheetEditProps {
  value: string;
  textColor: string;
  fontFamily: string;
  stamps: Array<Array<string>>;
  backgroundColor: string;
}

interface PaperSheetEditData {
  text: string;
  penColor: string;
  penFont: string;
  isCrayon: boolean;
  fieldCounter: number;
  editUsr: string;
}

const PaperSheetEdit: React.FC<PaperSheetEditProps> = ({
  value,
  textColor,
  fontFamily,
  stamps,
  backgroundColor,
}) => {
  const [previewSelected, setPreviewSelected] = useState('Preview');
  const [oldText] = useState(value || '');
  const [textAreaText, setTextAreaText] = useState('');
  const [combinedText, setCombinedText] = useState(value || '');
  const [showingHelpTip, setShowingHelpTip] = useState(false);

  const { data } = useBackend<PaperSheetEditData>();
  const { text, penColor, penFont, isCrayon, fieldCounter, editUsr } = data;

  const createPreview = (value, doFields = false) => {
    const out = { text: text, fieldCounter: 0, formFields: {} };
    value = value.trim();
    if (value.length > 0) {
      const sanitizedText = sanitizeText(value);
      const signedText = signDocument(sanitizedText, penColor, editUsr);
      const fieldedText = createFields(
        signedText,
        penFont,
        12,
        penColor,
        fieldCounter,
      );
      const formattedText = runMarkedDefault(fieldedText.text);
      const fontedText = setFontinText(
        formattedText,
        penFont,
        penColor,
        isCrayon,
      );
      out.text += fontedText;
      out.fieldCounter = fieldedText.counter;
    }
    if (doFields) {
      const finalProcessing = checkAllFields(
        out.text,
        penFont,
        penColor,
        editUsr,
        isCrayon,
      );
      out.text = finalProcessing.text;
      out.formFields = finalProcessing.fields;
    }
    return out;
  };

  const onInputHandler = (e) => {
    let value = e.target.value;
    if (value !== textAreaText) {
      const combinedLength = oldText.length + textAreaText.length;
      if (combinedLength > MAX_PAPER_LENGTH) {
        if (combinedLength - MAX_PAPER_LENGTH >= value.length) {
          value = '';
        } else {
          value = value.substr(
            0,
            value.length - (combinedLength - MAX_PAPER_LENGTH),
          );
        }
        if (value === textAreaText) {
          return;
        }
      }
      setTextAreaText(value);
      setCombinedText(createPreview(value).text);
    }
  };

  const finalUpdate = (newText) => {
    const { act } = useBackend();
    const finalProcessing = createPreview(newText, true);
    act('save', finalProcessing);
    setTextAreaText('');
    setPreviewSelected('save');
    setCombinedText(finalProcessing.text);
  };

  return (
    <Flex direction="column" fillPositionedParent>
      <Flex.Item>
        <Tabs fluid>
          <Tabs.Tab
            key="marked_edit"
            textColor="black"
            backgroundColor={previewSelected === 'Edit' ? 'grey' : 'white'}
            selected={previewSelected === 'Edit'}
            onClick={() => setPreviewSelected('Edit')}
          >
            Edit
          </Tabs.Tab>
          <Tabs.Tab
            key="marked_preview"
            textColor="black"
            backgroundColor={previewSelected === 'Preview' ? 'grey' : 'white'}
            selected={previewSelected === 'Preview'}
            onClick={() => {
              setPreviewSelected('Preview');
              setCombinedText(createPreview(textAreaText).text);
            }}
          >
            Preview
          </Tabs.Tab>
          <Tabs.Tab
            key="marked_done"
            textColor="black"
            backgroundColor={
              previewSelected === 'confirm'
                ? 'red'
                : previewSelected === 'save'
                  ? 'grey'
                  : 'white'
            }
            selected={
              previewSelected === 'confirm' || previewSelected === 'save'
            }
            onClick={() => {
              if (previewSelected === 'confirm') {
                finalUpdate(textAreaText);
              } else if (previewSelected === 'Edit') {
                setPreviewSelected('confirm');
                setCombinedText(createPreview(textAreaText).text);
              } else {
                setPreviewSelected('confirm');
              }
            }}
          >
            {previewSelected === 'confirm' ? 'Confirm' : 'Save'}
          </Tabs.Tab>
          <Tabs.Tab
            key="marked_help"
            textColor={'black'}
            backgroundColor="white"
            icon="question-circle-o"
            onMouseOver={() => setShowingHelpTip(true)}
            onMouseLeave={() => setShowingHelpTip(false)}
          >
            Help
          </Tabs.Tab>
        </Tabs>
      </Flex.Item>
      <Flex.Item grow={1} basis={1}>
        {previewSelected === 'Edit' ? (
          <TextArea
            value={textAreaText}
            textColor={textColor}
            fontFamily={fontFamily}
            height={window.innerHeight - 60 + 'px'}
            backgroundColor={backgroundColor}
            onInput={onInputHandler}
          />
        ) : (
          <PaperSheetView
            value={combinedText}
            stamps={stamps}
            fontFamily={fontFamily}
            textColor={textColor}
          />
        )}
      </Flex.Item>
      {showingHelpTip && <HelpToolip />}
    </Flex>
  );
};

export const PaperSheet = () => {
  const { data } = useBackend<PaperSheetData>();
  const {
    editMode,
    text,
    paperColor,
    penColor,
    penFont,
    stamps,
    stampClass,
    sizeX,
    sizeY,
    name,
    scrollbar,
  } = data;
  const [stampList, setStampList] = useState<Array<Array<string>>>([]);
  const [editModeState, setEditModeState] = useState(editMode || 0);

  useEffect(() => {
    setStampList(stamps || []);
  }, [stamps]);

  useEffect(() => {
    if (editMode !== undefined) {
      setEditModeState(editMode);
    }
  }, [editMode]);

  const decideMode = (mode: number) => {
    switch (mode) {
      case 0:
        return <PaperSheetView value={text} stamps={stampList} readOnly />;
      case 1:
        return (
          <PaperSheetEdit
            value={text}
            textColor={penColor}
            fontFamily={penFont}
            stamps={stampList}
            backgroundColor={paperColor}
          />
        );
      case 2:
        return (
          <PaperSheetStamper
            value={text}
            stamps={stampList}
            stampClass={stampClass}
          />
        );
      default:
        return 'ERROR ERROR WE CANNOT BE HERE!!';
    }
  };

  return (
    <Window
      title={name}
      theme="paper"
      width={sizeX || 400}
      height={sizeY || 500}
    >
      <Window.Content backgroundColor={paperColor} scrollable={scrollbar}>
        <Box id="page" fillPositionedParent>
          {decideMode(editModeState)}
        </Box>
      </Window.Content>
    </Window>
  );
};
