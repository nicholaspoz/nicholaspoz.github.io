# Split-Flap Animation Performance Investigation

## Problem Statement
Large matrices of split-flap characters have poor performance due to many independent CSS animations running simultaneously, causing high CPU usage and janky animations.

## Attempted Solution: RAF-Based Animation Coordination
We tried to implement a centralized `AnimationManager` using `requestAnimationFrame` to coordinate animations, limiting concurrent animations to ~12 at a time.

## Technical Issues Discovered

### 1. **Shared Component State**
- **Problem**: The `init()` function in Lustre components runs ONCE for all instances of the component
- **Impact**: All `split-flap-char` components share the same model state, including `char_id`
- **Evidence**: Console shows same `char_id` for all characters
- **Root Cause**: Lustre's component architecture doesn't create separate instances per DOM element

### 2. **Event Target Issues**
- **Problem**: `event.emit()` bubbles up through DOM hierarchy 
- **Impact**: Event target is parent element (e.g., `nick-dot-bingo`) not the `split-flap-char` element
- **Evidence**: AnimationManager receives wrong element reference in `e.target`
- **Root Cause**: Events bubble up shadow DOM boundaries differently than expected

### 3. **Shadow DOM Complications**  
- **Problem**: Components use shadow DOM (`component.open_shadow_root(True)`)
- **Impact**: DOM queries from global JavaScript can't access shadow DOM internals
- **Workaround**: We moved to pure event-based approach, but events still don't carry correct element references

## Architecture Problems

### Current Flow (Broken):
1. User changes letter attribute
2. **All components** get same `char_id` from shared `init()`
3. Component emits `animation-needed` event
4. Event bubbles to parent element (not the char element)
5. AnimationManager gets wrong element reference
6. Animation coordination fails

### What We Need:
1. **Unique IDs per component instance**
2. **Correct event targets** pointing to actual char elements
3. **Element reference system** that works across shadow DOM

## Files Modified
- `split_flap/src/components/char.gleam` - Added animation state management and event system
- `js/animation_manager.js` - RAF-based animation coordinator
- `index.html` & `bleed.html` - Include animation manager script

## Next Steps / Alternatives

### Option 1: Fix Current Approach
- Generate unique IDs per element (not per component class)
- Fix event targeting to point to correct elements
- Research Lustre component instance management

### Option 2: Simpler Performance Fixes
- **CSS-only approach**: Use `animation-delay` and `animation-duration` variations
- **Intersection Observer**: Only animate visible characters
- **Reduced animation complexity**: Remove expensive CSS properties during animation
- **Staggered starts**: Add random delays to spread out animation load

### Option 3: Different Architecture  
- Move away from individual web components
- Single component managing matrix of characters
- Direct DOM manipulation with RAF

## Key Learnings
1. **Lustre component instances share state** - major architectural constraint
2. **Event bubbling in shadow DOM** is complex and unpredictable
3. **Performance gains require limiting concurrent animations**, but coordination is harder than expected
4. **Simple CSS optimizations** might give better ROI than complex coordination

## Immediate Recommendations
1. **Revert to simple CSS approach** for now
2. **Focus on CSS performance optimizations**: remove box-shadows during animation, use `will-change` properly
3. **Implement viewport culling** if not all characters are always visible
4. **Consider animation budget**: disable animations entirely when > 30 characters need updating

---

*Investigation paused due to fundamental architecture issues with Lustre component state management and event targeting.*