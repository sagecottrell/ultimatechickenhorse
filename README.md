## how to use

- launch multiple instances
- make one the host, then the other instances are clients
- on the host, set the watch path to the current directory
- the host should select a scene to send to the clients (testscene.tscn is a good one)
- after all clients are loaded into the scene, the host can use the buttons in the bottom right to unlock player movement 
	- either instantly, or after a countdown

## todo

- [ ] simple enemy that follows the player, force player to respawn
- [ ] player HP
- [ ] sounds
- [ ] player death animation
- [ ] more prefabs
	- [ ] static obstacles of various shapes
		- [X] trees
		- [X] rocks
		- [X] cubes
		- [X] nuclear cube
- [ ] example scenes
	- [X] gravity area
	- [ ] CSG cave using path3d
	- [ ] moving platform
- [ ] server switch cameras
	- [X] level cameras
	- [ ] player first person camera
	- [X] player freecam
- [X] countdown
	- [X] player unlock button
- [ ] client disconnect logic
