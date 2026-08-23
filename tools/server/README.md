# Server Tools

Files for running the server in production. Somewhat specific to Goonstation's server setup.

## Usage

```sh
docker compose --env-file .env.<SERVER_ID> up -d

# e.g.
docker compose --env-file .env.dev up -d
```

## Config

Every game server instance has an .env file with some basic config. They must be named with the server ID, and contain a `SS13_ID` variable with the same value. E.g. `.env.dev` should contain `SS13_ID=dev`.

Any variables defined in these env files will override variables in `buildByond.conf` with the same name.

## Assumptions

- `/pop/ss13` exists on the host machine and contains:
  - `byond/` - Contains BYOND installations named by version, e.g. `byond/516.1666`
  - `rust-g/` - Contains a `librust_g.so` file
  - `byond-tracy/` - Contains a `libprof.so` file
- [Monocker](https://github.com/petersem/monocker) is setup on the host machine
