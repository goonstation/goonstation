/**
 * @file
 * @copyright 2021
 * @author Luxizzle (https://github.com/Luxizzle)
 * @license MIT
 */

import { decodeHtmlEntities } from 'common/string';
import {
  BlockQuote,
  Box,
  Button,
  LabeledList,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import { ColorButton } from '../../components';
import { CharacterPreferencesData } from './type';

export const GeneralTab = () => {
  const { act, data } = useBackend<CharacterPreferencesData>();

  let ellipsis = function ellipsis(text) {
    return text.length > 200 ? text.substring(0, 200) + '…' : text;
  };

  return (
    <>
      <Section title="Records">
        <LabeledList>
          <LabeledList.Item
            label="Name"
            buttons={
              <Button.Checkbox
                checked={data.randomName}
                onClick={() => act('update-randomName')}
              >
                Random
              </Button.Checkbox>
            }
          >
            <Button onClick={() => act('update-nameFirst')}>
              {data.nameFirst}
            </Button>
            <Button
              onClick={() => act('update-nameMiddle')}
              color={data.nameMiddle === '' ? 'grey' : 'default'}
            >
              {data.nameMiddle !== '' ? (
                data.nameMiddle
              ) : (
                <Box italic>None</Box>
              )}
            </Button>
            <Button onClick={() => act('update-nameLast')}>
              {data.nameLast}
            </Button>
          </LabeledList.Item>
          <LabeledList.Item label="Hyphenate Name">
            <Button.Checkbox
              checked={data.hyphenateName}
              onClick={() => act('toggle-hyphenation')}
            >
              Y/N
            </Button.Checkbox>
          </LabeledList.Item>
          <LabeledList.Item label="Body Type">
            <Button onClick={() => act('update-gender')}>{data.gender}</Button>
          </LabeledList.Item>
          <LabeledList.Item label="Pronouns">
            <Button onClick={() => act('update-pronouns')}>
              {data.pronouns}
            </Button>
          </LabeledList.Item>
          <LabeledList.Item label="Age">
            <Button onClick={() => act('update-age')}>{data.age}</Button>
          </LabeledList.Item>
          <LabeledList.Item label="Blood Type">
            <Button onClick={() => act('update-bloodType')}>
              {data.bloodRandom ? (
                <Box as="span" italic>
                  Random
                </Box>
              ) : (
                data.bloodType
              )}
            </Button>
          </LabeledList.Item>
          <LabeledList.Item
            label="Bank PIN"
            buttons={
              <Button.Checkbox
                checked={!data.pin}
                onClick={() => act('update-pin', { random: !!data.pin })}
              >
                Random
              </Button.Checkbox>
            }
          >
            <Button onClick={() => act('update-pin')}>
              {data.pin ?? (
                <Box as="span" italic>
                  Random
                </Box>
              )}
            </Button>
          </LabeledList.Item>
          <LabeledList.Item
            label="Flavor Text"
            buttons={
              <Button onClick={() => act('update-flavorText')} icon="wrench">
                Edit
              </Button>
            }
          >
            <BlockQuote>
              {data.flavorText ? (
                decodeHtmlEntities(data.flavorText)
              ) : (
                <Box italic>None</Box>
              )}
            </BlockQuote>
          </LabeledList.Item>
          <LabeledList.Item
            label="Security Note"
            buttons={
              <Button onClick={() => act('update-securityNote')} icon="wrench">
                Edit
              </Button>
            }
          >
            <BlockQuote>
              {data.securityNote ? (
                decodeHtmlEntities(data.securityNote)
              ) : (
                <Box italic>None</Box>
              )}
            </BlockQuote>
          </LabeledList.Item>
          <LabeledList.Item
            label="Medical Note"
            buttons={
              <Button onClick={() => act('update-medicalNote')} icon="wrench">
                Edit
              </Button>
            }
          >
            <BlockQuote>
              {data.medicalNote ? (
                decodeHtmlEntities(data.medicalNote)
              ) : (
                <Box italic>None</Box>
              )}
            </BlockQuote>
          </LabeledList.Item>
          <LabeledList.Item
            label="Syndicate Intelligence"
            buttons={
              <Button onClick={() => act('update-syndintNote')} icon="wrench">
                Edit
              </Button>
            }
          >
            <BlockQuote>
              {data.syndintNote ? (
                ellipsis(decodeHtmlEntities(data.syndintNote))
              ) : (
                <Box italic>None</Box>
              )}
            </BlockQuote>
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section title="Other names">
        <LabeledList>
          <LabeledList.Item label="Preferred Cyborg Name">
            <Button
              onClick={() => act('update-robotName')}
              color={data.robotName ? 'default' : 'grey'}
            >
              {data.robotName ? data.robotName : <Box italic>None</Box>}
            </Button>
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section title="Equipment">
        <LabeledList>
          <LabeledList.Item label="PDA Ringtone">
            <Button onClick={() => act('update-pdaRingtone')}>
              {data.pdaRingtone}
            </Button>
            <Button
              onClick={() => act('previewSound', { pdaRingtone: 1 })}
              icon="volume-up"
            >
              Preview
            </Button>
          </LabeledList.Item>
          <LabeledList.Item label="PDA Background Color">
            <ColorButton
              color={data.pdaColor}
              onClick={() => act('update-pdaColor')}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Use Satchel">
            <Button.Checkbox
              checked={data.useSatchel}
              onClick={() => act('toggle-satchel')}
            >
              Y/N
            </Button.Checkbox>
          </LabeledList.Item>
          <LabeledList.Item label="Preferred Uplink">
            <Button onClick={() => act('update-uplink')}>
              {data.preferredUplink}
            </Button>
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </>
  );
};
