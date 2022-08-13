# project-zomboid-server
#### A container image (made with docker) for Steam+Planet Zomboid Server.

An always updated PlanetZomboid server which updates from steam anytime the container boots up.

## Basic Usage Info
This repo containers an example docker-compose file. Using that you can either locally build the image yourself, or adjust the compose file to point to the ghrc.io image.
This can be a good starting point for deploying to docker based systems, but you should modify it to fit your needs. This can include setting volume mounts and customizing environment variables.

At minimum, you must set a `SERVER_NAME` environment variable which will be used for the server config, map and save file names.

### Public Server options

To enable a public server, simply set the following ENV variables:

```
SERVER_PUBLIC
SERVER_DISPLAY_NAME
SERVER_DESCRIPTION
```

**ServerPassword:** If you would like to have a password protected public server, simply set the `SERVER_PASSWORD` env variable.

### Server Mods

To enable mods, you will use the same convention as the single player version of the game. Because of this it's often best to use Steam's workshop to setup a local server teh way you would like.
Once you have all the modes you'd like to use and verified they are working correctly in a "local" server you can copy those configs to the container.

The above method is suggested because the game requires that you define two fields to get the mods to load properly.
One that tells it which workshop modes to download and a second one which tells it how to load the mods.
These are:

```
SERVER_MODS
SERVER_WORKSHOP_IDS
```

### Paths to map to persistent volumes
These are the paths you should map (in the container) to a persistent data store of your choice.

- zomboid_app:/home/steam/project-zomboid-dedicated/:rw
- zomboid_data:/home/steam/Zomboid/:rw

In this example, we show docker volumes (mapped to persistent local storage) named `zomboid_app` and `zomboid_data` for the steam game data and server game files respectively.
