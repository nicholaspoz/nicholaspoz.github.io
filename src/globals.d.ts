// Global type declarations

interface FlipEvent {
  character: string;
  index: number;
}

declare global {
  interface HTMLElementEventMap {
    flip: CustomEvent<FlipEvent>;
  }
}
