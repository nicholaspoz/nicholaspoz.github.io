// Minimal GSAP type declarations
declare namespace gsap {
  namespace core {
    interface Timeline {
      pause(): this;
      play(): this;
      kill(): this;
      seek(position: any): this;
      nextLabel(): string;
      set(target: any, vars: any, position?: any): this;
      to(target: any, vars: any): this;
      call(callback: () => void, params?: any, position?: any): this;
      add(child: any, position?: any): this;
      addLabel(label: string, position?: any): this;
      getChildren(nested?: boolean, tweens?: boolean, timelines?: boolean): any[];
    }
  }

  function timeline(vars?: any): core.Timeline;
  function registerPlugin(...plugins: any[]): void;
  function config(config: any): void;
}

declare const TextPlugin: any;
