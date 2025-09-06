import lustre
import lustre/attribute
import lustre/component
import lustre/element.{type Element}
import lustre/element/html

pub fn register() {
  let component = lustre.simple(fn(_) { Nil }, fn(_, _) { Nil }, view)

  lustre.register(component, "bingo-office")
}

fn view(_) -> Element(Nil) {
  element.fragment([
    html.style([], css),
    html.div([attribute.class("office-void")], [
      html.div([attribute.class("office-void-bg")], [
        html.div([attribute.class("split-flap-void")], [
          component.named_slot("split-flap", [], []),
        ]),
      ]),
    ]),
  ])
}

const css = "
  :host {
    --position-x: 50%;
    --position-y: 35%;
    width: 100%;
    height: 100%;
    position: relative;
  }
  
  .office-void {
    width: 100%;
    height: 100%;
    position: relative;  
    overflow: hidden;
  }
  
  .office-void-bg {
    position: absolute;
    width: max(100vw, 100vh);
    height: max(100vw, 100vh);
    left: var(--position-x);
    top: var(--position-y);
    transform: translate(calc(var(--position-x) * -1), calc(var(--position-y) * -1));
    background-image: url(./img/bg-1280.webp);
    background-size: cover;
    background-position: var(--position-x) var(--position-y);
  }
  
  .split-flap-void {
    position: absolute;
    /* background: lime; */
    /* mix-blend-mode: difference; */
    /* do not, and I repeat, do not touch this—otherwise the flip-flap will be very very sad and I will cry */
    top: 21.78%;
    left: 35.77%;
    width: 28.50%;
    height: 14.4%;
  }

  @media (min-width: 1280px) {
    .office-void-bg {
      background-image: url(./img/bg-1920.webp);
    }
  }
  
  @media (min-width: 1920px) {
    .office-void-bg {
      background-image: url(./img/bg-2560.webp);
    }
  }
  
  @media (min-width: 2560px) {
    .office-void-bg {
      background-image: url(./img/bg-3840.webp);
    }
  }
"
