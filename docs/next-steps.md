# Immediate Build Steps

This scaffold gives the project a starting shape, but there are two practical next actions before deeper feature work:

1. Generate or create the Xcode project
2. Replace the static demo simulation with a step-based training model

## 1. Generate the Xcode Project

This repo includes `project.yml` for XcodeGen, but XcodeGen is not installed in the current environment.

Options:

- Install XcodeGen and run `xcodegen generate`
- Create an Xcode iOS App project manually and point it at the `NNApp/` source tree

## 2. Build the First Real Interaction

The most important next implementation target is the Visual Lab screen.

Replace the placeholder visualization with:

- forward-pass recomputation on input change
- a "train one step" action
- an epoch playback timeline
- before/after comparison for weights and output
- accessible text summaries for every state change

## 3. Lock the Visual Style Early

Before adding many screens, define:

- final type scale
- color system
- node/edge illustration grammar
- motion rules for forward pass and training updates

This is the easiest way to protect the app from drifting into a generic "AI app" look.
