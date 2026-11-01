import { createRenderer } from 'tgui/renderer';
import { Button } from 'tgui-core/components';

const render = createRenderer();

export const SingleButton = () => {
  const node = <Button>Hello world!</Button>;
  render(node);
};

export const SingleButtonWithCallback = () => {
  const node = <Button onClick={() => undefined}>Hello world!</Button>;
  render(node);
};

export const ListOfButtons = () => {
  const nodes: React.JSX.Element[] = [];
  for (let i = 0; i < 100; i++) {
    const node = <Button key={i}>Hello world! {i}</Button>;
    nodes.push(node);
  }
  render(<div>{nodes}</div>);
};

export const ListOfButtonsWithCallback = () => {
  const nodes: React.JSX.Element[] = [];
  for (let i = 0; i < 100; i++) {
    const node = (
      <Button key={i} onClick={() => undefined}>
        Hello world! {i}
      </Button>
    );
    nodes.push(node);
  }
  render(<div>{nodes}</div>);
};

export const ListOfButtonsWithIcons = () => {
  const nodes: React.JSX.Element[] = [];
  for (let i = 0; i < 100; i++) {
    const node = (
      <Button key={i} icon={'arrow-left'}>
        Hello world! {i}
      </Button>
    );
    nodes.push(node);
  }
  render(<div>{nodes}</div>);
};

export const ListOfButtonsWithTooltips = () => {
  const nodes: React.JSX.Element[] = [];
  for (let i = 0; i < 100; i++) {
    const node = (
      <Button key={i} tooltip={'Hello world!'}>
        Hello world! {i}
      </Button>
    );
    nodes.push(node);
  }
  render(<div>{nodes}</div>);
};
