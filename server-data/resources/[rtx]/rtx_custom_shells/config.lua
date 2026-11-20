Config = {}

-- Spawn the doors by themselves when a housing script spawns this shell object on its own
-- (RTX Housing, ps-housing, VMS Housing, qb-interior and others just call CreateObject). Keep it true.
Config.AutoDoors = true

-- Also spawn the furniture that was placed in the RTX Shell Creator when a housing script spawns the shell.
-- Most housing scripts have their own furniture, so keep it false there. SpawnShell and EnterShell
-- spawn the furniture unless you pass {props = false}.
Config.AutoProps = false

-- How far around the player a shell spawned by another script is looked for (metres).
Config.AutoDistance = 150.0

-- Doors inside the shell swing open by themselves when you walk up to them and close behind you.
-- Locked doors are spawned frozen and never open. Only garage doors are opened with a key.

-- Control that opens and closes garage doors (38 = E).
Config.DoorKey = 38

-- How close you have to be to a garage door to open it (metres).
Config.DoorDistance = 3.2

-- Open and close garage doors for every player in the same routing bucket, not only for you.
Config.SyncDoors = true

-- Elevators: the cabin really moves between the floors and takes you with it.
-- Control that calls the elevator and rides to the chosen floor (38 = E). Arrow keys or the mouse wheel choose the floor.
Config.ElevatorUp = 38

-- Control that rides one floor down straight away (47 = G).
Config.ElevatorDown = 47

-- How fast the cabin moves (metres per second).
Config.ElevatorSpeed = 1.5

-- Move the elevators for every player in the same routing bucket, not only for you.
Config.SyncElevators = true

-- Elevator sounds: doors, motor, the stop, the chime and the buttons. They play in 3D from where they happen.
Config.ElevatorSounds = true

-- Volume of the elevator sounds (0.0 - 1.0).
Config.ElevatorVolume = 0.8

-- Texts shown next to garage doors and in the elevators.
Config.Texts = {
	garageopen = "Open the garage",
	garageclose = "Close the garage",
	elevatorcall = "~INPUT_CONTEXT~ Call the elevator",
	elevatorcoming = "The elevator is on its way",
	elevatorchoose = "~INPUT_CELLPHONE_UP~ ~INPUT_CELLPHONE_DOWN~ Choose a floor~n~~INPUT_CONTEXT~ Go"
}
