# TODO

Bootstrap:

- [x] Caddy http-only
- [x] Update DNS on startup
- [x] Caddy secure-only
- [x] Forge user/group
- [x] Forge data dir
- [x] Copyparty
- [x] Forge from S3
- [ ] Discord bot to start/stop VM
- [ ] Discord bot to backup foundry worlds
- [ ] CD of discord bot using CloudBuild

Startup:

- [x] Install git
- [x] Clone repo
- [x] Run bootstrap script
- [x] Shutdown on error

Refinement:

- [ ] Auth gate
- [ ] Dynamically get managed zone name when updating DNS
- [ ] Parameterise copyparty service
- [ ] Parameterise forge service
- [ ] Parameterise foundry settings (including port)
- [ ] Lock down IAM conditions on roles
- [ ] Remove DNS records on shutdown
- [ ] Lock down Discord Bot by using shared secret and verifying the payload signature.
