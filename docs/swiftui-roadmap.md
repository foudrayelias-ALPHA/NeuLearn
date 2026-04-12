# SwiftUI Roadmap

## Recommendation

Build the first version as a native iOS app with SwiftUI.

Why this is the strongest fit:

- Best alignment with an iOS-first App Store launch
- Excellent support for polished motion, accessibility, and responsive layout
- Easier to make the app feel intentional and premium on Apple platforms
- Simpler integration with native gestures, animation timing, and performance tuning for diagram-heavy interfaces

React Native remains a reasonable future option if cross-platform delivery becomes urgent, but it is not the best first choice for a highly visual, interaction-rich educational product where polish is part of the value.

## Architecture Goals

- Modular content and simulation systems
- Clear separation between educational content and rendering logic
- Reusable visualization primitives
- Easy expansion into additional lesson types
- Future portability of lesson data and concept models

## Recommended App Modules

### 1. App Shell

Responsibilities:

- Navigation
- Onboarding
- User preferences
- Progress persistence

### 2. Content Engine

Responsibilities:

- Lesson definitions
- Path definitions
- Glossary entries
- Content metadata

Implementation idea:

- Store lesson content as structured JSON or local data models
- Separate prose/content from interactive view code where possible

### 3. Visualization Engine

Responsibilities:

- Node rendering
- Connection rendering
- Weight styling
- Activation overlays
- Training animation timelines

Implementation idea:

- Build reusable SwiftUI views for nodes, edges, labels, and overlays
- Use `Canvas` or custom drawing where needed for performant network diagrams

### 4. Simulation Engine

Responsibilities:

- Small neural network state
- Forward pass logic
- Loss calculation
- Gradient/update playback state

Important note:

This does not need to be a general ML framework. It should be a controlled educational simulation layer designed for clarity.

### 5. Progress and Personalization

Responsibilities:

- Saved lessons
- Path completion state
- Recently viewed topics
- Recommended next concept

## Suggested Folder Structure

```text
NNApp/
  App/
  Features/
    Home/
    Explore/
    VisualLab/
    Paths/
    Library/
  Shared/
    UI/
    Visualization/
    Models/
    Persistence/
    Content/
  Simulation/
  Assets/
```

## Data Modeling Direction

Keep educational content portable.

Suggested core models:

- `Lesson`
- `LessonSection`
- `LearningPath`
- `GlossaryTerm`
- `SimulationPreset`
- `ProgressRecord`

This allows:

- adding new lessons without rewriting screens
- reusing concepts across multiple paths
- keeping Android/web options open later

## Key SwiftUI Implementation Notes

### Visualization

- Use custom drawing for connections and activation effects
- Animate state changes carefully; motion should explain, not distract
- Support reduced motion from the start

### Accessibility

- Label diagram elements semantically
- Provide textual descriptions for interactive simulations
- Allow alternate list/table views for learners who cannot rely on visual diagrams

### Performance

- Keep neural network examples intentionally small in the MVP
- Precompute visual states where useful for playback
- Avoid overbuilding a large live-training engine too early

## MVP Build Phases

### Phase 1: Foundation

- Create SwiftUI app shell
- Establish visual system
- Build navigation and onboarding
- Define content data models

### Phase 2: Signature Experience

- Build feedforward network visualization
- Add input/output controls
- Add weight and activation rendering
- Add step-based training playback

### Phase 3: Guided Learning

- Add beginner lesson path
- Add intermediate training lessons
- Add advanced architecture explainers
- Add glossary and saved progress

### Phase 4: Polish

- Accessibility pass
- App Store readiness pass
- Illustration integration
- Microcopy refinement
- Performance tuning

## Design System Guidance

Because the product must not look AI-generated, the design system should be intentionally narrow and authored.

Recommended rules:

- Define a restrained color palette with semantic meaning
- Choose typography with character, not default app blandness
- Use a consistent illustration grammar for nodes, lines, labels, and diagrams
- Build custom transitions for training and explanation states
- Prefer whitespace and composition over decorative effects

## Future Android Strategy

If Android becomes a priority later, preserve flexibility by keeping these layers platform-light:

- Lesson data
- Glossary content
- Simulation rules
- Progress model

That way, a future Android client can share content logic even if the UI is implemented separately.

## Immediate Next Build Step

The best next move is to scaffold a SwiftUI app around one standout demo:

- a small neural network sandbox
- a training playback screen
- one guided beginner lesson using the same visualization system

If that loop feels excellent, the rest of the product has a strong foundation.
