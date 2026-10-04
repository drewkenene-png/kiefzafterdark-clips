# Roblox Dev Notes

#roblox

General notes and gotchas for working in Roblox Studio.

## Workflow
- Save the place as `.rbxlx` (XML) when sharing it with tools outside Studio.
- Scripts that change gameplay (speed, size, coins) run on the **server**. Visuals (hover, bounce, cards) run on the **client**.
- `ProximityPrompt` is the easy way to make a "press E to drink" interaction.
- `BillboardGui` is the easy way to show a floating label over a part.

## Useful services
- `TweenService` – smooth hover and bounce motion
- `RunService.RenderStepped` – per-frame client animation
- `UserInputService` / `Mouse.Target` – detect what the player is looking at
- `ReplicatedStorage` – put shared data modules here so client and server read the same thing

## Links
- [[Roblox/Potion Shop]]
