# Tgui event dispatch

## Philosophy

In the previous TGUI backend state, both DM messages and UI actions were handled through an event message system using actions, selectors, reducers, and middleware. This event system is designed to handle only DM messages - separating UI actions into direct state access (eg `setSomeState(true)`) or helpers (eg `updateSetting({ thing: true })`).

The idea behind this was to reduce the amount of abstractions needed and draw a clear line between what is a server message and what is a UI action.

There are three layers to this system:

1. The event bus, which maintains the list of handlers.
2. The handlers, which delegate backend calls and update application state.
3. The store, ie the application state.

## Usage

### 1. Creating your event handler

> events/handlers/someFunc.ts

```ts
type ExpectedPayload = {
  greeting: string;
};

export function someFunc(payload: ExpectedPayload) {
  // Do something with the payload
  logger.log('Received: ', payload.greeting);
}
```

### 2. Building the event handler

> events/listeners.ts

```ts
import { someFunc } from './handlers/someFunc';

const listeners = {
  eventType: someFunc,
} as const;
```

You can even shorten this by naming your function the same as the event type. An event of type `myType` would call the `myType` function directly:

```ts
export function myType(payload: MyPayload) {
  logger.log('whatever!');
}

const listeners = {
  myType,
} as const;
```

### 3. Setting up your event dispatch

> events/listeners.ts

```ts
import { EventBus } from 'tgui-core/eventbus';

const listeners = {
  myType,
  'some/Thing': someThingHandler, // valid
  'other/Thing': () => store.set(someAtom, true), // technically okay but can get messy :).
} as const;

export const bus = new EventBus(listeners);
```

### 4. Subscribe to byond events

> index.tsx

```ts
Byond.subscribe((type, payload) => bus.dispatch({ type, payload }));
```

## Converting the old system over

This process takes time! But it's not impossible. For the most part, backend calls can be directly extracted into a function with similar state management.

> middleware.js

Ex:

```ts
if (type === 'audio/playMusic') {
  const { url, ...options } = payload;
  player.play(url, options);
  return next(action);
}
```

Becomes:

```ts
function audioPlayMusic(payload: PayloadType): void {
  const { url, ...options } = payload;
  player.play(url, options);

  // no need to call next, it's all handled here
}
```

### When to use store.set/get vs useAtom

Functionally, there is no difference. If it makes it simpler, you can leave UI actions as external javascript helpers with `store.set`/`store.get`. Wrapping functions into React components is the 'technically correct' way to do things, and the React way tends to be more concise in the long run.

### When to create handlers vs direct state access

Is it a backend call from DM? Put it on the event bus! If it isn't, there's no reason not to have your UI directly interface with a function or the state directly.
