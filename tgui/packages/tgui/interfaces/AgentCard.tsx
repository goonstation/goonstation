import { useState } from 'react';
import {
  Button,
  Image,
  Input,
  LabeledList,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

interface AgentCardData {
  placeholderName: string;
  placeholderAssignment: string;
  equippedId: CardData | null;

  usablePronouns: string[];
  cardStyles: CardStyle[];
  defaultCardStyle: CardStyle;
}

interface CardData {
  name: string;
  assignment: string;
  icon: string;
  pronouns: string;
}

interface CardStyle {
  name: string;
  state: string;
  keepState: boolean;
  refIcon;
}

export const AgentCard = () => {
  const { act, data } = useBackend<AgentCardData>();
  const {
    placeholderName,
    placeholderAssignment,
    equippedId,
    usablePronouns,
    cardStyles,
    defaultCardStyle,
  } = data;
  const [cardName, setCardName] = useState<string>();
  const [cardAssignment, setCardAssignment] = useState<string>();
  const [cardPronouns, setCardPronouns] = useState<string | null>(null);
  const [cardStyle, setCardStyle] = useState<CardStyle>(defaultCardStyle);

  return (
    <Window width={400} height={365} theme="syndicate">
      <Window.Content>
        <Section
          title="Identity"
          buttons={
            <Button
              icon="id-card"
              tooltip="Sets the appearance of the card to mirror your worn ID."
              color="green"
              disabled={equippedId === null}
              onClick={() => {
                setCardName(equippedId?.name);
                setCardAssignment(equippedId?.assignment);
                setCardStyle(
                  // match sprite if possible, use Plain if not
                  cardStyles.find((x) => x.state === equippedId?.icon) ||
                    defaultCardStyle,
                );
                setCardPronouns(equippedId ? equippedId.pronouns : null);
              }}
            >
              Match My ID
            </Button>
          }
        >
          <LabeledList>
            <LabeledList.Item label="Name">
              <Input
                fluid
                placeholder={placeholderName}
                value={cardName}
                maxLength={100}
                onChange={setCardName}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Assignment">
              <Input
                fluid
                placeholder={placeholderAssignment}
                value={cardAssignment}
                maxLength={100}
                onChange={setCardAssignment}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Pronouns">
              <Button
                key={'None'}
                onClick={() => setCardPronouns(null)}
                selected={cardPronouns === null}
              >
                None
              </Button>
              {usablePronouns.map((pronoun) => (
                <Button
                  key={pronoun}
                  onClick={() => setCardPronouns(pronoun)}
                  selected={cardPronouns === pronoun}
                >
                  {pronoun}
                </Button>
              ))}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Card Appearance">
          {cardStyles.map((style) => (
            <Button
              key={style.state}
              onClick={() =>
                setCardStyle(
                  cardStyles.find((x) => x.state === style.state) ||
                    defaultCardStyle,
                )
              }
              selected={style.state === cardStyle?.state}
            >
              <Image
                verticalAlign="middle"
                my="0.2rem"
                mr="0.5rem"
                height="24px"
                width="24px"
                src={style.refIcon}
              />
              {style.name}
            </Button>
          ))}
        </Section>
        <Section fontSize="16px" textAlign="center">
          <Button.Confirm
            icon="pen"
            fluid
            tooltip="You can only do this once!"
            onClick={() =>
              act('forge', {
                cardName: cardName?.length ? cardName : placeholderName,
                cardAssignment: cardAssignment?.length
                  ? cardAssignment
                  : placeholderAssignment,
                cardStyle,
                cardPronouns,
              })
            }
          >
            Forge ID
          </Button.Confirm>
        </Section>
      </Window.Content>
    </Window>
  );
};
