/**
 * Copyright (c) 2025 @Azrun
 * SPDX-License-Identifier: MIT
 */

import { Collapsible, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { DataInputOptions } from './common/DataInput';

type DataGroupViewerData = {
  title: string;
  groups: Array<DataInputGroup>;
};

type DataInputGroup = {
  name: string;
  objects?: Array<DataInputObjectProps>;
  groups?: Array<DataInputGroup>;
};

interface DataInputGroupsProps {
  groups: Array<DataInputGroup>;
}

interface DataInputObjectsProps {
  objects: Array<DataInputObjectProps>;
}

interface DataInputObjectProps {
  name: string;
  byondRef: string;
  options: any;
}

export const DataInputObjects = (props: DataInputObjectsProps) => {
  return props && props.objects.length ? (
    Object.entries(props.objects).map(([objKey, object]) => (
      <Section key={objKey} title={object.name}>
        <DataInputOptions byondRef={object.byondRef} options={object.options} />
      </Section>
    ))
  ) : (
    <Section>No Objects Found</Section>
  );
};

export const DataInputGroups = (props: DataInputGroupsProps) => {
  return props && props.groups.length
    ? Object.entries(props.groups).map(([groupKey, groupData]) => (
        <Collapsible key={groupKey} title={groupData.name} open>
          {groupData.objects?.length ? (
            <DataInputObjects objects={groupData.objects} />
          ) : null}
          {groupData.groups?.length ? (
            <DataInputGroups groups={groupData.groups} />
          ) : null}
        </Collapsible>
      ))
    : '--Empty Group--';
};

export const DataGroupViewer = () => {
  const { data } = useBackend<DataGroupViewerData>();

  return (
    <Window title={data.title} width={500} height={800}>
      <Window.Content scrollable>
        <DataInputGroups groups={data.groups} />
      </Window.Content>
    </Window>
  );
};
