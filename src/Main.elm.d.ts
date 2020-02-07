type ElmOptions = void;

interface CommandPort<T> {
  subscribe(handler: (payload: T) => void): void;
}

export interface Ports {}

interface Main {
  init(options: ElmOptions): { ports: Ports };
}

declare module Elm {
  namespace Elm { export const Main: Main; }
}

export default Elm;
