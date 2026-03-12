/**
 * @file
 * @copyright 2024
 * @author Original Azrun (https://github.com/Azrun)
 * @license ISC
 */

import { Button, Section } from 'tgui-core/components';

interface DiskSectionProps {
  isDiskPresent: boolean;
  onScanDisk: () => void;
  onEjectDisk: () => void;
}

export const DiskSection = (props: DiskSectionProps) => {
  const { isDiskPresent, onScanDisk, onEjectDisk } = props;

  if (!isDiskPresent) {
    return null;
  }
  return (
    <Section title="Disk Controls">
      <Button icon="upload" onClick={onScanDisk}>
        Read from Disk
      </Button>
      <Button icon="eject" color="bad" onClick={onEjectDisk}>
        Eject Disk
      </Button>
    </Section>
  );
};
