# Product Plan

## Vision

Create a mobile learning app that makes neural networks and machine learning understandable through visual cause-and-effect, layered learning paths, and carefully designed explanations. The app should feel intelligent and crafted, not trendy, childish, or artificially generated.

The strongest product idea is not "gamified AI learning." It is "a visual lab for understanding how machine learning systems behave."

## Product Goals

- Help learners build intuition for neural networks, not just memorize definitions
- Support users who begin at very different knowledge levels
- Make hidden processes visible: activations, weights, errors, training progress, and architecture choices
- Use interactivity where it clarifies concepts
- Preserve depth and rigor in intermediate and advanced content
- Meet modern App Store expectations for onboarding, accessibility, and mobile usability

## Non-Goals

- Badge-heavy gamification
- Empty streak mechanics or rewards disconnected from learning
- Over-simplifying advanced topics until they become inaccurate
- Overloading every lesson with drag-and-drop or simulations
- Generic "AI app" visual design

## Audience

Primary audience:

- High school students
- College students
- Self-taught adult learners
- Curious technical beginners

Secondary audience:

- Educators looking for visual teaching support
- Learners refreshing fundamentals before deeper ML study

Assumption:

Users may arrive with no calculus, no coding, or no ML vocabulary. The app should allow multiple entry points instead of forcing a single linear path.

## Learning Model

The app should use three depth bands rather than strict academic difficulty gates.

### Beginner

Goal:
Build intuition through direct manipulation and immediate visual feedback.

Characteristics:

- Very interactive
- Minimal jargon at first
- Strong visual metaphors
- Short lesson units
- Cause-and-effect emphasis

Examples:

- Adjust an input value and watch outputs change
- Set a desired output and see how error shifts
- Watch connection lines brighten, widen, or change color as weights update
- Compare a network before and after training

### Intermediate

Goal:
Explain how multi-layer networks learn over time and how design choices affect behavior.

Characteristics:

- More structured explanations
- Training visualization becomes central
- Users explore hidden layers, activation flow, loss curves, and parameter changes
- Interactivity is still important, but paired with stronger conceptual framing

Examples:

- Observe a small classifier train over epochs
- Toggle activation functions and compare decision boundaries
- Explore underfitting vs overfitting
- Inspect how learning rate changes training behavior

### Advanced

Goal:
Support deeper conceptual understanding without forcing every concept into a toy simulation.

Characteristics:

- More information density
- Rich diagrams and expandable annotations
- Less interaction when interaction would trivialize or distract
- Stronger emphasis on architecture, tradeoffs, and interpretation

Examples:

- Compare CNNs, RNNs, transformers, and diffusion models conceptually
- Explore backpropagation as a guided visual explanation
- Study optimization tradeoffs and failure modes
- Use layered diagrams, annotated equations, and explorable callouts

## Core Experience Pillars

### 1. Visualize the Invisible

The app should reveal what learners normally cannot see:

- Weight changes
- Signal flow
- Activation strength
- Error propagation
- Decision boundaries
- Training progress over time

Suggested visual language:

- Brighter or more saturated edges for stronger connections
- Wider lines for larger weight magnitude
- Warm/cool color shifts for positive vs negative influence
- Pulse or motion to indicate forward-pass activity
- Soft backflow animation for gradient-based updates

### 2. Start Anywhere

Do not force everyone into "Lesson 1."

Recommended entry points:

- "I’m new to this"
- "I know the basics"
- "I want to understand training"
- "I want architecture deep dives"

The app can still recommend a path after users choose an entry point.

### 3. Interactivity With Purpose

Every interactive element should answer a question such as:

- What changed?
- Why did the output change?
- What is the network optimizing?
- What happens if this parameter is too large or too small?

If an interaction does not improve understanding, replace it with a stronger static explanation.

### 4. Human, Crafted Visual Identity

The interface must not look AI-generated. It should feel authored.

Design principles:

- Use custom illustrations with a recognizable style
- Avoid generic glowing meshes and stock "futuristic AI" motifs
- Favor limited, intentional color systems over random rainbow gradients
- Use typography with personality, but preserve readability
- Let diagrams feel diagrammatic, not decorative
- Prefer asymmetry, rhythm, and editorial composition over template-like layouts

## Information Architecture

Recommended top-level app structure:

1. Home
2. Explore
3. Visual Lab
4. Paths
5. Library

### Home

- Resume where the learner left off
- Recommended next lesson or simulation
- Featured concept of the day
- Optional progress summary without turning the app into a reward system

### Explore

- Browse by topic, not only by level
- Example categories:
  - What is a neuron?
  - Weights and bias
  - Forward pass
  - Loss
  - Gradient descent
  - Overfitting
  - CNNs
  - Transformers

### Visual Lab

The signature area of the app.

Features:

- Interactive mini neural networks
- Parameter controls
- Input/output testing
- Training playback
- Visual overlays for activations, weights, and errors

### Paths

Curated progressions for users who want structure.

Examples:

- Neural Networks from Scratch
- How Training Works
- Machine Learning Essentials
- Deep Learning Architectures

### Library

- Glossary
- Diagram reference
- Formula explanations
- Saved lessons
- Downloaded assets or offline content

## Core Feature Set

### Feature 1: Interactive Neural Network Sandbox

This is the anchor experience.

Minimum version:

- Small feedforward network
- Editable input nodes
- Target output selection
- Visualized forward pass
- Visualized weight updates after training steps
- Loss indicator

Important UX rule:

The learner should always know what changed and why.

### Feature 2: Training Playback

Users should be able to:

- Start training
- Pause
- Step epoch-by-epoch
- Compare before vs after
- Slow down animations to inspect change

### Feature 3: Concept Cards and Diagrams

Not every lesson needs a simulator.

Use:

- Scrollable explorable diagrams
- Tap-to-reveal annotations
- Linked glossary definitions
- Compact examples with plain-language summaries

### Feature 4: Layered Explanations

Each lesson can expose increasing depth:

- Intuition
- Mechanism
- Math
- Real-world use

This makes the app useful across different ages and backgrounds without splitting the product into separate versions.

### Feature 5: Thoughtful Progress Tracking

Track:

- Topics explored
- Simulations completed
- Saved concepts
- Path progress

Avoid:

- Arbitrary badges
- Loot-box style rewards
- Progress systems that pressure users instead of helping them learn

## Suggested Content Map

### Foundations

- What is machine learning?
- What is a neural network?
- Inputs, outputs, and features
- Weights and bias
- Activation functions

### Learning Process

- Forward pass
- Loss and error
- Gradient descent
- Backpropagation
- Epochs and batches

### Model Behavior

- Underfitting and overfitting
- Generalization
- Learning rate
- Normalization
- Regularization

### Architectures

- Feedforward networks
- Convolutional neural networks
- Recurrent neural networks
- Transformers
- Autoencoders

### Practice and Reality

- Classification vs regression
- Datasets and labels
- Bias in data
- Evaluation metrics
- Limits and misconceptions

## Onboarding

Keep onboarding short and useful.

Recommended onboarding flow:

1. Ask what the user wants to learn
2. Ask their confidence level
3. Offer a suggested starting path
4. Show one signature interaction immediately

The app should demonstrate value quickly instead of explaining itself at length.

## Accessibility

Required standards:

- Dynamic Type support
- High contrast options
- VoiceOver-friendly controls and diagrams
- Alternative encodings beyond color alone
- Large tap targets
- Motion reduction settings for training animations

Important note:

Because the app will visualize weights and signal strength, color should never be the only carrier of meaning. Width, labels, icons, and pattern changes should support comprehension.

## Visual Direction

Recommended visual keywords:

- Editorial
- Diagrammatic
- Tactile
- Precise
- Warmly technical

Avoid:

- Neon sci-fi AI cliches
- Corporate dashboard blandness
- Childish ed-tech styling
- Overly polished generic illustrations

A good benchmark is "museum exhibit meets design-forward textbook" rather than "mobile game" or "AI startup landing page."

## Success Metrics

- Users can explain core neural network concepts more clearly after interacting
- Users spend time inside the Visual Lab because it teaches, not because it manipulates attention
- Users move between beginner and deeper content without feeling locked out
- The app earns positive feedback for clarity, originality, and polish

## MVP Recommendation

The first release should focus on one excellent loop instead of broad coverage.

Recommended MVP:

- iOS app in SwiftUI
- One polished interactive feedforward-network lab
- One beginner path
- One intermediate training visualization path
- One advanced architecture overview section
- Glossary and saved progress
- Strong onboarding and accessibility support

This is enough to validate the core idea without spreading effort too thin.
