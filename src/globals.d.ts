// Global type declarations

// declare var gsap: {
//   timeline: (config?: any) => any;
//   set: (target: any, vars: any) => void;
//   to: (target: any, vars: any) => any;
// };

interface FlipEvent {
  character: string;
  index: number;
}

declare global {
  interface HTMLElementEventMap {
    flip: CustomEvent<FlipEvent>;
  }
}
