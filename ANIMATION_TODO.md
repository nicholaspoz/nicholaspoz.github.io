# Split-Flap Animation Optimization Todo

Implementation roadmap for migrating to Web Animations API with `animationiteration` event approach for better performance.

## Animation Implementation Todo List

### Core Animation Infrastructure

1. **Create Web Animations API keyframes with proper flip timing**
   - Define 4-phase keyframes object: idle → flip-down → hold → flip-up
   - Timing using offset values: 0, 0.33, 0.66, 1.0
   - Use `iterations` option for sequence length control

2. **Simplify char.gleam CSS - remove animation-specific styles**
   - Remove old CSS animation keyframes and classes
   - Keep only static styling (layout, colors, transforms base)
   - Maintain existing visual appearance

3. **Create JavaScript FFI functions for Web Animations API with event handling**
   - `animateCharacterSequence(elementId, charSequence)` - single character
   - `animateAllCharactersStaggered(elementIds, sequences, staggerMs)` - full display
   - `setupGlobalAnimationListener()` - event delegation

### Character Logic

4. **Implement character sequence generation from adjacency list**
   - Port existing adjacency list logic to generate full sequences
   - Function to build path from current char to target char
   - Handle edge cases (invalid targets, loops)

5. **Add global animation iteration event listener for all characters**
   - Single event listener using event delegation on `animationiteration`
   - Store character sequences on DOM elements via properties
   - Update content on each iteration event

### Display Coordination

6. **Implement staggered animation start timing across display**
   - Calculate stagger delays for natural wave effect
   - Handle row-by-row vs character-by-character timing
   - Coordinate with existing display grid structure

7. **Update display_v2.gleam to use new animation approach**
   - Replace old state-driven updates with FFI calls
   - Trigger animations when content changes
   - Integrate with existing Content types (Text/Link)

### Cleanup & Optimization

8. **Remove old Lustre state management from char component**
   - Strip out Model, Msg, update functions
   - Keep only static rendering for initial DOM structure
   - Maintain web component registration

9. **Handle animation cleanup and memory management**
   - Remove event listeners when components unmount
   - Cancel running animations on new targets
   - Clear stored sequences from DOM elements

10. **Test performance with 196 simultaneous character animations**
    - Benchmark against current implementation
    - Profile memory usage and frame rates
    - Test on lower-end devices

## Key Files to Work With

- `split_flap/src/components/char.gleam` - CSS and component structure
- `split_flap/src/components/display_v2.gleam` - Your new implementation
- `split_flap/src/split_flap.ffi.mjs` - JavaScript animation functions
- Root justfile/HTML for testing

## Technical Approach Summary

**Current Issue**: Each character uses setTimeout chains and individual Lustre state management, causing performance problems with 196 characters (7×28 grid).

**New Approach**:
- Web Animations API with `iterations` set to sequence length
- Single global `animationiteration` event listener updates content
- No RAF polling or setTimeout coordination needed
- Event-driven content updates at exact animation boundaries

**Expected Benefits**:
- **Significantly better performance** than current timeout-based system
- **Perfect timing synchronization** across all characters
- **Lower memory usage** - no individual state management per character
- **Easier debugging** - single event handler vs 196 timeout chains
- **Better browser optimization** - Web Animations API over CSS keyframes

## Implementation Notes

**Web Animations API Keyframes Structure**:
```javascript
const keyframes = [
  { transform: 'rotateX(0deg)', offset: 0 },      // Show current char
  { transform: 'rotateX(80deg)', offset: 0.33 },  // Flip down
  { transform: 'rotateX(80deg)', offset: 0.66 },  // Hold flip
  { transform: 'rotateX(0deg)', offset: 1.0 }     // Flip up to show next char
];

element.animate(keyframes, {
  duration: 150,           // Duration per iteration
  iterations: sequenceLength,
  fill: 'forwards'
});
```

**Event Handler Pattern**:
```javascript
// Single global listener handles all characters
document.addEventListener('animationiteration', (e) => {
  const element = e.target;
  const sequence = element._charSequence;
  const currentIndex = ++element._currentIndex;

  if (currentIndex < sequence.length) {
    element.textContent = sequence[currentIndex];
  }
});
```

**Staggered Timing**:
- Start animations with `setTimeout` stagger delays
- Once started, Web Animations API handles all timing
- Creates natural "wave" effect across display

This approach should provide smooth 60fps performance even with the full 196-character display grid.