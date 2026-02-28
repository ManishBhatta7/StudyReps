# StudyReps: Implementation Brainstorm
*The "Steve Jobs" Minimalist Approach.*

## 🔪 What We Are NOT Building (The Cutting Room Floor)
To make this work flawlessly, we must kill the bloat. 
*   *No Note-Taking Canvas:* Too much UI clutter on the screen. The focus is the voice interaction.
*   *No Custom Android Launchers/OS:* Too engineering-heavy and expensive for an MVP.
*   *No Complex Handwritten Math Detection:* Too error-prone right now. Keep them speaking.
*   *No Gamified Avatars or Point Shops:* The reward is learning, not a digital hat.
*   *No Complex Visual Pacing Metronomes:* Distracting.

## 🚀 The MVP Delivery: The "Focus PWA" (Progressive Web App)
We start with a PWA (accessible on iPads, Android tablets, and laptops). It bypasses App Stores and allows instant iteration.

### The ONLY 4 Features We Build:

1.  **The Video Feed:** 
    *   A beautifully simple, distraction-free feed of educational videos. No infinite algorithmic scrolling.
2.  **The "Vocal Lock" Engine:**
    *   The core IP. The video pauses based on transcript analysis.
    *   A massive, inviting microphone button appears. The AI asks a question contextually related to the last 2 minutes.
    *   Speech-to-text validates the response before securely unlocking the next segment.
3.  **The "Fullscreen Commitment":**
    *   The PWA uses the browser's Fullscreen API to expand over everything else.
    *   If the Page Visibility API detects the student switched tabs to Instagram, the session hard-pauses, heavily tracks it as a "loss of focus," and breaks their current streak.
4.  **The Parent WhatsApp Webhook:**
    *   A dead-simple backend service. When the 30-minute study session ends, it automatically texts the parent a summary report via a WhatsApp business API.

That is the entire product. Simple, flawless, and deeply impactful.
