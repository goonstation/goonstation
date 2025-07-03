/**
 * @file
 * @copyright 2024
 * @author garash2k
 * @license ISC
 */
import { resource } from '../../../goonstation/cdn';
import { AlertContentWindow } from '../types';

const HivemindContentWindow = () => {
  return (
    <div className="traitor-tips">
      <h1 className="center">You have been absorbed by a changeling!</h1>
      <img
        src={resource('images/antagTips/changeling-image.png')}
        className="center"
      />

      <p>
        This is <em>not</em> the end, you are now a part of the changeling
        hivemind.
      </p>

      <p>
        As a member of the hivemind, you can assist your master in a variety of
        ways:
      </p>
      <span className="small indent">
        <p>
          <em>Talk</em> to them, giving them any information that might further
          their goals.
        </p>
        <p>
          <em>Point</em> things out to them, only your master and other hivemind
          members can see your points.
        </p>
        <p className="image-right">
          <em>Be animated</em> as a sentient body part.
          <img
            src={resource('images/antagTips/handspider.png')}
            className="right"
          />
        </p>
        <p>
          <em>Spit acid</em> by clicking while your master is in horror form.
        </p>
      </span>
      <p>
        You may exit the hivemind and return to ghost form by using the
        &quot;Exit hivemind&quot; command under the commands tab at the top
        right of your screen.
      </p>
      <p>
        For more information, consult{' '}
        <a href="https://wiki.ss13.co/index.php?search=Changeling">the wiki</a>
      </p>
    </div>
  );
};

export const acw: AlertContentWindow = {
  title: "You've been absorbed into the Hivemind!",
  component: HivemindContentWindow,
};
