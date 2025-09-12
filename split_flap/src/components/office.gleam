import components/bingo
import lustre
import lustre/attribute
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
          bingo.element(),
        ]),
      ]),
    ]),
  ])
}

const css = "
  :host {
    --position-x: 50%;
    --position-y: 60%;
    --min-height: 55cqw;
    width: 100%;
    height: 100%;
    min-height: var(--min-height);
    overflow-x: hidden;
    overflow-y: scroll;
    position: relative;
    container-type: inline-size;
  }
  
  .office-void {
    width: 100%;
    height: 100%;
    min-height: var(--min-height);
    overflow: hidden;
    position: relative;
    container-type: size;
  }
  
  .office-void-bg {
    position: absolute;
    width: max(100cqw, 100cqh);
    height: max(100cqw, 100cqh);
    left: var(--position-x);
    top: var(--position-y);
    transform: translate(calc(var(--position-x) * -1), calc(var(--position-y) * -1));
    background-image: url(./img/bg-3840.webp);
    background-size: cover;
    background-position: var(--position-x) var(--position-y);
  }
  
  .split-flap-void {
    position: absolute;
    /* background: lime; */
    /* mix-blend-mode: difference; */
    /* do not, and I repeat, do not touch this—otherwise the flip-flap will be very very sad and I will cry */
    top: 28.75%;
    left: 26.66%;
    width: 46.66%;
    height: 23.4%;
    container-type: size; 
  }

  nick-dot-bingo::part(panel) {
    background: rgba(50, 50, 50, 0.3);    
    box-shadow: none;
  }
"
