import { Image } from 'tgui/components';
import { createRenderer } from 'tgui/renderer';
import { backendUpdate } from 'tgui/backend';
import { configureStore, StoreProvider } from 'tgui/store';

const store = configureStore({ sideEffets: false });

const renderUi = createRenderer((dataJson: string) => {
  store.dispatch(backendUpdate({
    data: Byond.parseJson(dataJson),
  }));
  return (
    <StoreProvider store={store}>
      <Image
        src={dataJson["img"]}
        width="100%"
        height="100%"
      />
    </StoreProvider>
  );
});

// im not sorry
const base_64_image_as_a_var_fuck = "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\
Nzfz/0My/AONoC6uFfBRHAAAAAElFTkSuQmCC";

export const empty = JSON.stringify({ img: "" });
export const Default = () => renderUi(empty);

export const withBase64 = JSON.stringify({ img: base_64_image_as_a_var_fuck });
export const WithBase64 = () => renderUi(withBase64);

export const withPath = JSON.stringify({ img: '~obj~item~wirecutters~green-wirecutters-green-2.png' });
export const WithPath = () => renderUi(withPath);
