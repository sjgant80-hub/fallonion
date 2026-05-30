# ◊ fallonion · sovereign Tor hidden service

**For when your customer is in a jurisdiction where the open internet is throttled or surveilled.**

[**Live**](https://sjgant80-hub.github.io/fallonion/) · [Setup](./setup.sh) · MIT · ◊·κ=1 · prime 317

## Setup

```bash
gh repo clone sjgant80-hub/fallonion
cd fallonion
bash setup.sh start                       # installs tor + writes hidden-service config
sudo tor -f /etc/tor/torrc.fallonion      # start tor
bash setup.sh address                     # print your .onion address
```

Run a static server (e.g. [fallcdn](https://sjgant80-hub.github.io/fallcdn/) in Caddy mode) on `127.0.0.1:8443`. Your `.onion` mirrors that content via Tor.

## Honest scope

Most operators don't need this. It's specifically for customers/contacts in actively-firewalled jurisdictions (China, Iran, Russia, etc.). Skip it unless you have a real use case.

## The complete stack

This is **Layer 4** of the defensive estate. Layers 1-3 handle 95% of threats. Layer 4 handles the last 5% — politically censored access.

## License

MIT · ◊·κ=1
