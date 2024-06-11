import { BlueprintButton } from 'tgui/interfaces/Manufacturer/components/BlueprintButton';
import { backendUpdate } from 'tgui/backend';
import { createRenderer } from 'tgui/renderer';
import { configureStore, StoreProvider } from 'tgui/store';
import { useBackend } from 'tgui/backend';

// This component needs a lot of special properties and thus
// should be setup as it is in the wild
export const BlueprintButtonTest = (_, context) => {
  const { data } = useBackend<any>(context);
  return (
    <BlueprintButton
      actionRemoveBlueprint={data.actionRemoveBlueprint}
      actionVendProduct={data.actionVendProduct}
      key={data.byondRef}
      blueprintData={data.blueprintData}
      manufacturerSpeed={data.manufacturerSspeed}
      materialData={data.materialData}
      deleteAllowed={data.delete_allowed !== 0}
      hasPower={!!data.hasPower}
    />
  );
};

const store = configureStore({ sideEffets: false });

const renderUi = createRenderer((dataJson: string) => {
  store.dispatch(backendUpdate({
    data: Byond.parseJson(dataJson),
  }));
  return (
    <StoreProvider store={store}>
      <BlueprintButtonTest />
    </StoreProvider>
  );
});

const aRB = (byondRef:string) => (Math.random());
const aVP = () => (Math.random());

export const data = JSON.stringify({
  actionRemoveBlueprint: aRB,
  actionVendProduct: aVP,
  blueprintData: {
    name: "Test Blueprint",
    requirement_data: [{
      name: "Dense Metal",
      id: "metal_dense",
      amount: "5",
    }],
    item_names: ["Dense Metal"],
    item_descriptions: [""],
    create: 1,
    time: 5,
    category: "Tool",
    byondRef: "[0x000000]",
    img: null,
    apply_material: false,
    show_cost: false,
    isMechBlueprint: false,
  },
  materialData: [
    {
      name: "Steel",
      id: "steel",
      amount: 5,
      byondRef: "[0x000000]",
      satisfies: [],
    },
  ],
  manufacturerSpeed: 3,
  deleteAllowed: 1,
  hasPower: 1,
});

export const Default = () => renderUi(data);
