/**
 * @file
 * @copyright 2023
 * @author garash2k
 * @license ISC
 */
import { Section } from 'tgui-core/components';

import type { AlertContentWindow } from '../types';

const RpRulesContentWindow = () => {
  return (
    <Section title="Welcome to Goonstation!">
      The roleplay servers use our main rules and unique roleplay rules listed
      below. If you do not agree to this second set of rules, please play on our
      Classic servers.
      <Section title="1. Make an effort to roleplay." mt={1}>
        Play a coherent, believable character. Playing a violent or racist
        character is not allowed. Play your character as though they wish to
        keep their job at Nanotrasen. This includes listening to security and
        the chain of command and, if you are a member of command, taking your
        job as a leader seriously in-character. Only minor crime is permitted
        for non-antagonists. Avoid memes (e.g. sus, pog, amogus), txt spk (e.g.
        lol, wtf), and out of game terminology when you are playing your
        character. LOOC is available if you need to communicate out of
        character. In addition, if you notice a character who is
        Afk/disconnected, please do not attack or mess with them beyond taking
        them to cryo.
      </Section>
      <Section title="2. Escalate through roleplay before attacking other players.">
        The goal of the roleplay server is character interaction and interesting
        scenarios. Both crew and antagonists are expected to roleplay escalation
        before engaging in hostilities. As an antagonist, your goal is to
        increase, not decrease, roleplay opportunities. Give people a sense of
        dread, an obvious motive, or some means of roleplaying and reacting,
        before you harm them. As security, your priority is the crew’s safety
        and maintaining the peace. You should treat criminals fairly and
        determine appropriate consequences for their actions. Enemies to
        Nanotrasen such as confirmed non-human antagonists and open syndicate
        members may be treated harshly.
      </Section>
      <Section title="3. After you’ve selected a job, be sure to stay in your lane.">
        While you are capable of doing anything within the game mechanics, allow
        those who have selected the relevant job to attempt the task first. As
        an example, breaking into medical and treating yourself when there are
        medical staff present is not okay. Choosing captain just to go and work
        the genetics machine all round is not acceptable.
      </Section>
      <Section title="4. As an antagonist you are free to kill and grief, provided you escalate per rule 2.">
        You are not required to be evil, but you do have a broad toolset to push
        the round forward and make things exciting. Treat your role as an
        interesting challenge and not an excuse to destroy other people’s game
        experiences. Your objectives do not allow you to ignore any rule, RP or
        otherwise. As an antagonist, you are not protected against being
        murdered or griefed, but it is expected that the crew roleplays and does
        not kill you just for the sake of killing an antagonist.
      </Section>
      <Section title="5. Do not use out of game information in game.">
        Only use in-game information; the things your character can perceive or
        could know. While we have no hard rule on what a character can and
        cannot know, be reasonable about your character’s knowledge and
        capabilities. Do not call out antagonists based on information that is
        only obvious as a player. For example, the drowsiness effects on your
        screen are not a good in-character basis to call out a changeling. The
        debris and adventure zones are for enhancing roleplay. Rushing through
        them for the sake of items alone is prohibited. It is reasonable for the
        crew to assume people with syndicate gear such as red space suits are
        antagonists.
      </Section>
      <Section title="6. Be kind to other players.">
        Be respectful and considerate of other players, as their experiences are
        just as important as your own. Do not use LOOC or other means of
        communication to put down other players or accuse them of rulebreaking.
        If your problem with another player extends to rulebreaking, press F1 to
        contact the admins. It is your responsibility to respect the boundaries
        of others when you RP. If you feel uncomfortable, or worry that people
        are uncomfortable, don’t be afraid to use LOOC to communicate.
        Furthermore, do not advantage your friends in game or exclude others
        from roleplaying opportunities without good cause.
      </Section>
      <Section title="7. These rules are extra rules for the roleplay server.">
        The core rules still apply to the roleplay server. Do not argue with the
        administration about the RP rules or core rules.
      </Section>
    </Section>
  );
};

export const acw: AlertContentWindow = {
  width: 800,
  height: 600,
  title: 'Goonstation RP Server Guidelines and Rules',
  component: RpRulesContentWindow,
};
