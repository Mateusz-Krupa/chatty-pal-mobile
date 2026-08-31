## Context

`CampaignSpeakingCard` owns the selected segmented-control index, while `CampaignSpeakingView` initializes its own index to zero. Navigation currently does not transfer the card selection, so all sessions begin at the first stage.

## Goals / Non-Goals

**Goals:**
- Carry the selected stage index into the practice view.
- Keep each stage's existing greeting and isolated chat store.
- Cover a non-first-stage launch with a unit test.

**Non-Goals:**
- Redesign speaking-stage navigation.
- Change the existing in-practice stage selector.

## Decisions

- Add an `initialStageIndex` initializer parameter to `CampaignSpeakingView` and seed its state from it. This keeps stage selection explicit at the navigation boundary and avoids shared mutable state.
- Clamp the supplied index to the task's available stage range. The card supplies a valid index, but this ensures programmatic callers cannot create an invalid state.

## Risks / Trade-offs

- An invalid programmatic index would previously fall back to the first stage implicitly. Clamping preserves that safe behavior.
