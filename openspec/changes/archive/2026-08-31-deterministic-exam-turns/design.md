# Design

`CampaignSpeakingView` supplies a static first examiner turn for each known lesson/stage. It is appended locally and may be spoken, so the model only receives the learner's first real answer. In exam mode, `ChatEngine` requests a separate `examReadyAnswer` and renders it below the learner bubble; ordinary free chat keeps the minimal proofreading path. `requestExamFeedback` marks its response as non-speaking, while ordinary examiner turns retain TTS. The server prompt is a defensive second layer: examiner bubbles do not correct language during the task.

No persisted checklist or API shape changes are needed.
