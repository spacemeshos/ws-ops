# ws-ops

A Web Services DevOps script that deploys the following services:

- Public API
- Explorer
- Dashboard

`networks.json` file contains specification what networks (production, testnet,
devnet) are active. To deploy new network, just add it to `networks.json` and
GitHub Actions pipeline will deploy all sort of things. If you delete network
specification from `networks.json`, this network services will be uninstalled,
be careful.

GitHub Actions pipeline located [here](.github/workflows/ci.yaml). It works
like this:

- The `GCLOUD_KEY` to access Google Cloud is stored in repository Secrets.
  gcloud is setting up with this key.
- The config files are downloaded by running
  [templates/download-configs.t](templates/download-configs.t).
- The helms that were installed on cluster are downloaded to helm-list.json
- [templates/networks.t](templates/networks.t) starts. It creates values.yaml
  files for each helm and runs the upgrade (install, if helm not installed).
  If a network exists on the cluster, but is not present in `networks.json` -
  uninstall helms belonging to this network.

## Discovery service

`networks.json` published via GitHub Pages on this
[link](https://discover.spacemesh.io/networks.json).
