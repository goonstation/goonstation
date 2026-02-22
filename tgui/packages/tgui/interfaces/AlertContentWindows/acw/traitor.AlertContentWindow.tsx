/**
 * @file
 * @copyright 2024
 * @author garash2k
 * @license ISC
 */
import { resource } from '../../../goonstation/cdn';
import { AlertContentWindow } from '../types';

const TraitorContentWindow = () => {
  return (
    <div className="traitor-tips">
      <h1 className="center">You are a traitor!</h1>
      <img
        src={resource('images/antagTips/traitor-image.png')}
        className="center"
      />

      <p>
        1. The Syndicate has provided you with a disguised uplink. It should be
        your <em>PDA</em> or <em>headset</em>, but it might be a{' '}
        <em>standalone unit</em> if nothing else is available.
      </p>

      <p>
        2. The details and your objectives will always be stored in your notes.
        To access them, use the <em>Notes</em> verb.
      </p>

      <p>
        2. To unlock a <em>PDA</em>:<br />
        <span className="small indent">
          1. Put your PDA in an empty hand and click on it.
          <br />
          2. Under &apos;General Functions&apos;, select &apos;Messenger&apos;.
          <br />
          3. Click &apos;Set Ring Message&apos;.
          <br />
          4. Enter the password.
        </span>
      </p>
      <p>
        3. To unlock a <em>headset</em>:<br />
        <span className="small indent">
          1. Put your headset in an empty hand and click on it.
          <br />
          2. Dial in the frequency assigned to you.
          <br />
          3. Press the &apos;Lock&apos; button after you&apos;re done buying the
          items.
          <br />
          4. It will now function as a regular headset again.
        </span>
      </p>
      <p>
        4. To unlock a <em>standalone uplink</em>:<br />
        <span className="small indent">
          1. Put the uplink into an empty hand and click on it.
          <br />
          2. Enter the password.
        </span>
      </p>

      <p>
        For more information, consult{' '}
        <a href="https://wiki.ss13.co/index.php?search=Traitor">the wiki</a>
      </p>
    </div>
  );
};

export const acw: AlertContentWindow = {
  title: 'Traitor Tips',
  theme: 'syndicate',
  component: TraitorContentWindow,
};
