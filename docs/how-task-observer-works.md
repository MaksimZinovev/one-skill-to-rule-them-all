General context: Pi skills are instruction documents loaded into the agent's context, not separate programs.

Q: Does task-observer run as a second agent?
A: No — the same pi agent follows both your task instructions and the observer's rules.

Q: Does it overload the agent?
A: No — it stays silent and only logs when it notices a pattern, correction, or gap.

Q: When does it act?
A: When you ask, "Any observations logged?" It surfaces grouped observations for your approval.

Q: How are updates installed?
A: Approved observations become staged files; you copy the updated skill into `~/.pi/agent/skills/`.
