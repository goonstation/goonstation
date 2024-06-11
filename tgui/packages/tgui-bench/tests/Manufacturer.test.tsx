import { Manufacturer } from 'tgui/interfaces/Manufacturer';
import { backendUpdate } from 'tgui/backend';
import { createRenderer } from 'tgui/renderer';
import { configureStore, StoreProvider } from 'tgui/store';

const store = configureStore({ sideEffets: false });

const renderUi = createRenderer((dataJson: string) => {
  store.dispatch(backendUpdate({
    data: Byond.parseJson(dataJson),
  }));
  return (
    <StoreProvider store={store}>
      <Manufacturer />
    </StoreProvider>
  );
});

export const data = JSON.stringify({
  delete_allowed: 1,
  queue: [],
  progress_pct: 0,
  panel_open: 1,
  hacked: 1,
  malfunction: 0,
  mode: "ready",
  wire_bitflags: 15,
  banking_info: {
    name: "Staffie McPubs",
    current_money: 69420,
  },
  speed: 4,
  repeat: 1,
  resource_data: [
    {
      name: "Steel",
      id: "steel",
      amount: 5,
      byondRef: "[0x000000]",
      satisfies: [],
    },
  ],
  manudrive_uses_left: 0,
  indicators: {
    electrified: 0,
    malfunctioning: 0,
    hacked: 1,
    hasPower: 1,
  },
  fabricator_name: "Manufacturer Performance Testing Dummy Data 9001",
  all_categories: [
    "Tool",
    "Clothing",
    "Resource",
    "Component",
    "Machinery",
    "Medicine",
    "Miscellaneous",
    "Downloaded",
  ],
  available_blueprints: [],
  hidden_blueprints: [],
  downloaded_blueprints: [],
  recipe_blueprints: [],
  wires: [],
  rockboxes: [],
  manudrive: {
    name: "",
    limit: 0,
  },
  min_speed: 1,
  max_speed_normal: 3,
  max_speed_hacked: 5,
});

export const Default = () => renderUi(data);
