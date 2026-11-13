/**
 * @file
 * @copyright 2026
 * @author JORJ949
 * @license ISC
 */
import { AlertContentWindow } from '../types';

const NukeopAIContentWindow = () => {
  return (
    <div className="traitor-tips">
      <h1 className="center">You are Syndicate Mission Control!</h1>

      <p>
        As a Syndicate AI, your main priority is following the{' '}
        <a href="https://wiki.ss13.co/AI_Laws#Syndicatee">syndicate laws</a>
        . Even if they have been changed from the default. <br />
        <br />
        Your task is to assist Syndicate Operatives in completing their mission
        by feeding them information using your access to the station camera
        network and radio channels.
        <br />
        <br />
        <h2>Your syndicate firmware grants you the following:</h2>
        <span>
          - You can visit certain syndicate off-station areas, such as the{' '}
          <em>Cairngorm</em>, by tracking someone there.
          <br />
          <br />- You can track humans that are <em>invisible</em> or wearing{' '}
          <em>agent cards</em>.
          <br />
          <br />- You can create announcements and holograms from off-station.
          Interacting with most station objects still requires you to be
          on-station.
          <br />
          <br />- Your announcements and radio messages are syndicate-themed.
          Revealing your allegiance to anyone that hears them!
          <br />
          <br />- Your primary radio is tuned to the{' '}
          <em>Syndicate Frequency</em>, talk and listen to your fellow
          operatives with a message prefix of <em>:z</em> or with your default
          radio channel hotkey.
          <br />
          <br />- Your secure channels radio is tuned to the{' '}
          <em>General Frequency</em>, talk to the station with a message prefix
          of <em>:3</em>.
        </span>
      </p>
    </div>
  );
};

export const acw: AlertContentWindow = {
  title: 'Syndicate Mission Control Tips!',
  theme: 'syndicate',
  component: NukeopAIContentWindow,
};
