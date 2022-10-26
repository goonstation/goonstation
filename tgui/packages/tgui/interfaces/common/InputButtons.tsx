/**
 * @file
 * @copyright 2022
 * @author jlsnow301 (https://github.com/jlsnow301)
 * @license ISC
 */

import { useBackend } from '../../backend';
import { Box, Button, Stack } from '../../components';

 type InputButtonsData = {
 };

 type InputButtonsProps = {
   input: string | number | null;
   inputIsValid?: Validator;
 };

export type Validator = {
   isValid: boolean;
   error: string | null;
 };

export const InputButtons = (props: InputButtonsProps, context) => {
  const { act } = useBackend<InputButtonsData>(context);
  const { input, inputIsValid } = props;

  const submitButton = (
    <Button
      color="good"
      disabled={inputIsValid && !inputIsValid.isValid}
      fluid={false}
      onClick={() => act('submit', { entry: input })}
      pt={0}
      textAlign="center"
      tooltip={inputIsValid?.error || null}
      width={6}>
      {'Submit'}
    </Button>
  );
  const cancelButton = (
    <Button
      color="bad"
      fluid={false}
      onClick={() => act('cancel')}
      pt={0}
      textAlign="center"
      width={6}>
      {'Cancel'}
    </Button>
  );

  const leftButton = cancelButton;
  const rightButton = submitButton;

  return (
    <Stack>
      <Stack.Item>{leftButton}</Stack.Item>
      <Stack.Item grow>
        {inputIsValid && !inputIsValid.isValid && inputIsValid.error && (
          <Box color="average" nowrap textAlign="center">
            {inputIsValid.error}
          </Box>
        )}
      </Stack.Item>
      <Stack.Item>{rightButton}</Stack.Item>
    </Stack>
  );
};
