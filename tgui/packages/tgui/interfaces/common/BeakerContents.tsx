import { Box } from 'tgui-core/components';

interface BeakerContentsProps {
  beakerContents;
  beakerLoaded;
}

export const BeakerContents = (props: BeakerContentsProps) => {
  const { beakerLoaded, beakerContents } = props;
  return (
    <Box>
      {!beakerLoaded && (
        <Box color="label">
          No beaker loaded.
        </Box>
      ) || beakerContents.length === 0 && (
        <Box color="label">
          Beaker is empty.
        </Box>
      )}
      {beakerContents.map(chemical => (
        <Box key={chemical.name} color="label">
          {chemical.volume} units of {chemical.name}
        </Box>
      ))}
    </Box>
  );
};
